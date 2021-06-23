vault {
  address = "http://localhost:8200"
  token = "s.6ZlvUSO93OW4tlyTFOEkgnxl"
  renew_token = true


retry {
    enabled = true
    attempts = 5
    backoff = "250ms"
  }

}

template {
  source      = "/etc/consul-template.d/yet-cert.tpl"
  destination = "/etc/nginx/certs/yet.crt"
  perms       = "0600"
  command     = "systemctl reload nginx"
}

template {
  source      = "/etc/consul-template.d/yet-key.tpl"
  destination = "/etc/nginx/certs/yet.key"
  perms       = "0600"
  command     = "systemctl reload nginx"

