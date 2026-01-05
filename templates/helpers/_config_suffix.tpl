{{/*
Return the suffix for the config files configmap
*/}}
{{- define "chartname.configFilesSuffix" -}}
{{- if .Values.config -}}
{{- .Values.config.configFilesPath | default "files" -}}
{{- else -}}
files
{{- end -}}
{{- end -}}
