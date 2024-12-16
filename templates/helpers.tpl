{{/*
Generate common labels
*/}}
{{- define "auto-scale-metrics.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | quote }}
{{- end }}

{{/*
Generate name template
*/}}
{{- define "auto-scale-metrics.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
