{{- /* yet-cert.tpl */ -}}
{{ with secret "pki_int/issue/example-dot-com" "common_name=netology.example.com"  "ttl=2m" }}
{{ .Data.certificate }}
{{ .Data.issuing_ca }}{{ end }}

