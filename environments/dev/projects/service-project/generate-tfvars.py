#!/usr/bin/env python3
"""
Automated Terraform Import Helper
1. Scans import.tf for the resource ID
2. Generates a temporary import configuration
3. Runs terraform plan -generate-config-out
4. Parses the generated config
5. Outputs the compute.auto.tfvars block
"""

import re
import sys
import os
import subprocess
import shutil

# --- Constants ---
IMPORT_FILE = 'import.tf'
TEMP_IMPORT_FILE = 'import_temp.tf'
GENERATED_CONFIG_FILE = 'generated_drift_resource.tf'
TEMP_RESOURCE_NAME = 'google_compute_instance.temp_importer'

def main():
    # 1. Check/Read import.tf
    if not os.path.exists(IMPORT_FILE):
        print(f"Error: {IMPORT_FILE} not found.")
        print("Please create an import.tf file with your desired import target:")
        print('import {\n  id = "projects/..."\n  to = module...\n}')
        sys.exit(1)

    with open(IMPORT_FILE, 'r') as f:
        import_content = f.read()

    # Extract ID
    id_match = re.search(r'id\s*=\s*"([^"]+)"', import_content)
    if not id_match:
        print("Error: Could not find 'id' in import.tf")
        sys.exit(1)
    resource_id = id_match.group(1)
    print(f"Found Resource ID: {resource_id}")

    # 2. Create Temporary Import File
    print(f"Creating temporary import target: {TEMP_RESOURCE_NAME}...")
    temp_import_content = f'''
import {{
  id = "{resource_id}"
  to = {TEMP_RESOURCE_NAME}
}}
'''
    # Backup original import.tf to avoid conflicts
    shutil.move(IMPORT_FILE, f"{IMPORT_FILE}.bak")
    
    with open(TEMP_IMPORT_FILE, 'w') as f:
        f.write(temp_import_content)

    try:
        # 3. Run Terraform Plan to Generate Config
        print("Running terraform plan to generate configuration (this may take a minute)...")
        cmd = [
            "terraform", "plan",
            f"-generate-config-out={GENERATED_CONFIG_FILE}"
        ]
        
        # We assume terraform init has been run.
        # Capturing output to avoid clutter, but printing stderr if it fails
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0 and "Planning failed" not in result.stderr and "Error" not in result.stderr:
             # Terraform plan might return non-zero if there are changes (detailed-exitcode), but here we look for generation success
             pass
        
        # Check if file was created
        if not os.path.exists(GENERATED_CONFIG_FILE):
            print("Error: Terraform failed to generate configuration.")
            print(result.stderr)
            restore_files()
            sys.exit(1)

        print(f"Successfully generated {GENERATED_CONFIG_FILE}")

        # 4. Parse Generated Config
        parse_and_print_config(GENERATED_CONFIG_FILE, resource_id)

    finally:
        # Cleanup
        restore_files()

def restore_files():
    if os.path.exists(TEMP_IMPORT_FILE):
        os.remove(TEMP_IMPORT_FILE)
    if os.path.exists(f"{IMPORT_FILE}.bak"):
        shutil.move(f"{IMPORT_FILE}.bak", IMPORT_FILE)
    # Note: We keep GENERATED_CONFIG_FILE for inspection or let user delete it? 
    # The prompt asked to "create the generated_drift_resource.tf", so we leave it.

def parse_and_print_config(file_path, resource_id):
    with open(file_path, 'r') as f:
        content = f.read()

    # Reuse existing regex extraction logic
    def extract_value(pattern, default=''):
        match = re.search(pattern, content)
        return match.group(1) if match else default

    name = extract_value(r'name\s*=\s*"([^"]+)"')
    zone = extract_value(r'zone\s*=\s*"([^"]+)"')
    machine_type = extract_value(r'machine_type\s*=\s*"([^"]+)"')
    auto_delete = extract_value(r'boot_disk\s*{[^}]*auto_delete\s*=\s*(true|false)', 'true')
    key_revocation = extract_value(r'key_revocation_action_type\s*=\s*"([^"]+)"', 'NONE')
    # Use ID from scan if not found in config (config might have it implied)
    
    # Metadata
    metadata_match = re.search(r'metadata\s*=\s*{([^}]+)}', content)
    metadata_entries = []
    if metadata_match:
        metadata_block = metadata_match.group(1)
        for line in metadata_block.strip().split('\n'):
            kv_match = re.search(r'([a-zA-Z0-9_-]+)\s*=\s*"([^"]+)"', line)
            if kv_match:
                metadata_entries.append(f'    "{kv_match.group(1)}" = "{kv_match.group(2)}"')
    
    # Scopes
    scopes_match = re.search(r'service_account\s*{[^}]*scopes\s*=\s*\[([^\]]+)\]', content, re.DOTALL)
    service_account_scopes = []
    if scopes_match:
        scopes_text = scopes_match.group(1)
        for scope in re.findall(r'"([^"]+)"', scopes_text):
            service_account_scopes.append(f'      "{scope}"')
            
    # Email
    service_account_email = extract_value(r'service_account\s*{[^}]*email\s*=\s*"([^"]+)"')

    # Tags
    tags_match = re.search(r'tags\s*=\s*\[([^\]]*)\]', content)
    tags = []
    if tags_match and tags_match.group(1).strip():
        tags_text = tags_match.group(1)
        tags = [t.strip() for t in re.findall(r'"([^"]+)"', tags_text)]

    # Disk
    disk_match = re.search(r'initialize_params\s*{([^}]+)}', content)
    disk_size_gb = '10'
    disk_type_val = 'pd-balanced'
    image_family = 'debian-12'

    if disk_match:
        disk_block = disk_match.group(1)
        disk_size = re.search(r'size\s*=\s*(\d+)', disk_block)
        disk_type = re.search(r'type\s*=\s*"([^"]+)"', disk_block)
        image = re.search(r'image\s*=\s*"[^"]*images/([^"]+)"', disk_block)
        
        disk_size_gb = disk_size.group(1) if disk_size else '10'
        disk_type_val = disk_type.group(1) if disk_type else 'pd-balanced'
        
        if image:
            img_name = image.group(1)
            if 'debian-12' in img_name or 'bookworm' in img_name:
                image_family = 'debian-12'
            elif 'debian-11' in img_name or 'bullseye' in img_name:
                image_family = 'debian-11'

    # Construction
    metadata_block = ""
    if metadata_entries:
        metadata_block = f'''
    metadata = {{
{chr(10).join(metadata_entries)}
    }}'''

    scopes_block = ""
    if service_account_scopes:
        scopes_block = f'''
    service_account_scopes = [
{", ".join(service_account_scopes)}
    ]''' # Formatting simplified for single line or multi line

    # Re-formatting scopes for cleanliness (multiline)
    if service_account_scopes:
        scopes_content = ",\n".join(service_account_scopes)
        scopes_block = f'''
    service_account_scopes = [
{scopes_content}
    ]'''

    sa_email_block = ""
    if service_account_email:
        sa_email_block = f'''
    service_account_email = "{service_account_email}"'''

    custom_tags = '[]'
    if tags:
        custom_tags_list = [t for t in tags if t not in ['ssh', 'dev', 'prod', 'staging']]
        if custom_tags_list:
            tags_quoted = [f'"{t}"' for t in custom_tags_list]
            custom_tags = f'[{", ".join(tags_quoted)}]'

    # Final Config
    config = f'''
  "{name}" = {{
    instance_name         = "{name}"
    network_project       = "tws-lz-host-networking"
    network_key           = "tws-dev-shared-vpc" # Assumption based on current env
    subnet_name           = "tws-dev-subnet-{zone[:-2]}" # Heuristic inference of subnet
    zone                  = "{zone}"
    machine_type          = "{machine_type}"
    disk_size_gb          = {disk_size_gb}
    disk_type             = "{disk_type_val}"
    image_family          = "{image_family}"
    image_project         = "debian-cloud"
    additional_disks      = []
    enable_snapshots      = false
    deletion_protection   = false
    custom_tags           = {custom_tags}
    enable_external_ip    = false
    boot_disk_auto_delete = {auto_delete}
    key_revocation_action_type = "{key_revocation}"{metadata_block}{sa_email_block}{scopes_block}
  }}
'''
    print("\n" + "="*80)
    print("GENERATED TFVARS ENTRY")
    print("="*80)
    print(config)
    print("="*80)
    print("Action:\n1. Copy block to compute.auto.tfvars\n2. Run terraform plan verify\n3. Run terraform apply")

if __name__ == "__main__":
    main()
