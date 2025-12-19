{{/*
Dynamic ConfigMap data generation
This helper renders all files within a specific folder.
*/}}
{{- define "chartname.dynamicFileMap.data" -}}
{{- $context := .context -}}
{{- $folder := .folder -}}
{{- $configFilesPath := $context.Values.configFilesPath -}}
{{/* If folder matches root path, use asterisk to avoid recursive grab of subfolders */}}
{{- $glob := ternary (printf "%s/*" $configFilesPath) (printf "%s/%s/**" $configFilesPath $folder) (eq $folder $configFilesPath) -}}
{{- range $path, $bytes := $context.Files.Glob $glob }}
{{ base $path }}: |-
{{- $content := $context.Files.Get $path -}}
{{- tpl $content $context | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Dynamic ConfigMap generation logic
This helper iterates over the directory structure to find subfolders and generate ConfigMaps.
*/}}
{{- define "chartname.dynamicConfigMaps" -}}
{{- $context := . -}}
{{- $configFilesPath := .Values.configFilesPath -}}
{{- if $configFilesPath }}
{{- $files := .Files.Glob (printf "%s/**" $configFilesPath) -}}
{{- $localDict := dict "previous" "-" -}}
{{- range $path, $bytes := $files }}
  {{- $folder := base (dir $path) -}}
  {{- if not (eq $folder $localDict.previous) }}
    {{- $_ := set $localDict "previous" $folder }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "chartname.fullname" $context }}-{{ $folder | replace "/" "-" | replace "." "-" | lower }}
  labels:
    {{- include "chartname.labels" $context | nindent 4 }}
data:
{{- include "chartname.dynamicFileMap.data" (dict "context" $context "folder" $folder) | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
