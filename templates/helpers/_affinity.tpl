{{/*
Affinity template.
Values.affinity is used if present.
*/}}
{{- define "chartname.affinity" -}}
{{- if .Values.affinity -}}
{{- toYaml .Values.affinity -}}
{{- else -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      labelSelector:
        matchLabels:
          {{- include "chartname.selectorLabels" . | nindent 10 }}
      topologyKey: kubernetes.io/hostname
{{- end -}}
{{- end -}}
