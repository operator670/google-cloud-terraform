# Global External IP Address
resource "google_compute_global_address" "default" {
  name    = "${var.name}-ip"
  project = var.project_id
}

# IPv6 Address (Optional)
resource "google_compute_global_address" "ipv6" {
  count = var.create_ipv6_address ? 1 : 0

  name       = "${var.name}-ipv6"
  project    = var.project_id
  ip_version = "IPV6"
}

# Health Checks
resource "google_compute_health_check" "default" {
  for_each = { for backend in var.backends : backend.name => backend }

  name    = "${var.name}-${each.value.name}-hc"
  project = var.project_id

  check_interval_sec  = each.value.health_check.check_interval_sec
  timeout_sec         = each.value.health_check.timeout_sec
  healthy_threshold   = each.value.health_check.healthy_threshold
  unhealthy_threshold = each.value.health_check.unhealthy_threshold

  http_health_check {
    port         = each.value.health_check.port
    request_path = each.value.health_check.request_path
  }
}

# Backend Services
resource "google_compute_backend_service" "default" {
  for_each = { for backend in var.backends : backend.name => backend }

  name                  = "${var.name}-${each.value.name}"
  project               = var.project_id
  protocol              = each.value.protocol
  port_name             = each.value.port_name
  timeout_sec           = each.value.timeout_sec
  enable_cdn            = var.enable_cdn || each.value.enable_cdn
  session_affinity      = each.value.session_affinity
  affinity_cookie_ttl_sec = each.value.affinity_cookie_ttl
  health_checks         = [google_compute_health_check.default[each.key].id]
  security_policy       = var.enable_cloud_armor ? var.cloud_armor_policy : null

  # Cloud CDN Configuration
  dynamic "cdn_policy" {
    for_each = (var.enable_cdn || each.value.enable_cdn) && var.cdn_policy != null ? [var.cdn_policy] : []
    content {
      cache_mode                   = cdn_policy.value.cache_mode
      default_ttl                  = cdn_policy.value.default_ttl
      max_ttl                      = cdn_policy.value.max_ttl
      client_ttl                   = cdn_policy.value.client_ttl
      negative_caching             = cdn_policy.value.negative_caching
      serve_while_stale            = cdn_policy.value.serve_while_stale
      signed_url_cache_max_age_sec = cdn_policy.value.signed_url_cache_max_age_sec

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? [cdn_policy.value.cache_key_policy] : []
        content {
          include_host           = cache_key_policy.value.include_host
          include_protocol       = cache_key_policy.value.include_protocol
          include_query_string   = cache_key_policy.value.include_query_string
          query_string_whitelist = cache_key_policy.value.query_string_whitelist
          query_string_blacklist = cache_key_policy.value.query_string_blacklist
        }
      }
    }
  }

  dynamic "backend" {
    for_each = each.value.instance_groups
    content {
      group = backend.value
    }
  }
}

# URL Map
resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  project         = var.project_id
  default_service = values(google_compute_backend_service.default)[0].id

  dynamic "host_rule" {
    for_each = var.url_map_host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }
}

# HTTP to HTTPS Redirect URL Map (Optional)
resource "google_compute_url_map" "https_redirect" {
  count = var.ssl_enabled && var.enable_http_to_https_redirect ? 1 : 0

  name    = "${var.name}-https-redirect"
  project = var.project_id

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# Google-managed SSL Certificates
resource "google_compute_managed_ssl_certificate" "default" {
  for_each = var.ssl_enabled ? toset(var.ssl_certificates) : []

  name    = "${var.name}-cert-${replace(each.value, ".", "-")}"
  project = var.project_id

  managed {
    domains = [each.value]
  }
}

# Target HTTPS Proxy
resource "google_compute_target_https_proxy" "default" {
  count = var.ssl_enabled ? 1 : 0

  name             = "${var.name}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.default.id
  ssl_certificates = concat(
    [for cert in google_compute_managed_ssl_certificate.default : cert.id],
    var.ssl_certificate_ids
  )
  ssl_policy = var.use_ssl_policy ? var.ssl_policy : null
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = var.ssl_enabled && var.enable_http_to_https_redirect ? google_compute_url_map.https_redirect[0].id : google_compute_url_map.default.id
}

# Global Forwarding Rule (HTTPS)
resource "google_compute_global_forwarding_rule" "https" {
  count = var.ssl_enabled ? 1 : 0

  name       = "${var.name}-https"
  project    = var.project_id
  target     = google_compute_target_https_proxy.default[0].id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}

# Global Forwarding Rule (HTTP)
resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.name}-http"
  project    = var.project_id
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
  ip_address = google_compute_global_address.default.address
}

# IPv6 Forwarding Rules (Optional)
resource "google_compute_global_forwarding_rule" "https_ipv6" {
  count = var.ssl_enabled && var.create_ipv6_address ? 1 : 0

  name       = "${var.name}-https-ipv6"
  project    = var.project_id
  target     = google_compute_target_https_proxy.default[0].id
  port_range = "443"
  ip_address = google_compute_global_address.ipv6[0].address
}

resource "google_compute_global_forwarding_rule" "http_ipv6" {
  count = var.create_ipv6_address ? 1 : 0

  name       = "${var.name}-http-ipv6"
  project    = var.project_id
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
  ip_address = google_compute_global_address.ipv6[0].address
}
