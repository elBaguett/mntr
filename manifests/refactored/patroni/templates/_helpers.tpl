{{- define "patroni.fullname" -}}
{{- printf "%s-%s" .Release.Name "patroni" | trunc 63 | trimSuffix "-" -}}
{{- end }}