{{- /* yet-key.tpl */ -}}
{{ with secret "pki_int/issue/example-dot-com" "common_name=netology.example.com" "ttl=2m"}}
{{ .Data.private_key }}{{ end }}

