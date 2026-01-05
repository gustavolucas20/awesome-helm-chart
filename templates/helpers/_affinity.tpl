{{/*
Affinity template.
Values.affinity is used if present.
*/}}
{{- define "chartname.affinity" -}}
{{- if .Values.workload.affinity -}}
{{- toYaml .Values.workload.affinity -}}
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

{{/*
Return a soft nodeAffinity definition
{{ include "common.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a hard nodeAffinity definition
{{ include "common.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a nodeAffinity definition
{{ include "common.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.nodes" -}}
{{- if .values -}}
{{- if eq .type "soft" }}
{{- include "common.affinities.nodes.soft" . -}}
{{- else if eq .type "hard" }}
{{- include "common.affinities.nodes.hard" . -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods.soft" (dict "component" "FOO" "context" $) -}}
*/}}
{{- define "common.affinities.pods.soft" -}}
{{- $component := default "" .component -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchLabels:
          {{- if $component }}
          app.kubernetes.io/component: {{ $component | quote }}
          {{- end }}
          {{- include "chartname.selectorLabels" .context | nindent 10 }}
      topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods.hard" (dict "component" "FOO" "context" $) -}}
*/}}
{{- define "common.affinities.pods.hard" -}}
{{- $component := default "" .component -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        {{- if $component }}
        app.kubernetes.io/component: {{ $component | quote }}
        {{- end }}
        {{- include "chartname.selectorLabels" .context | nindent 8 }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.pods" -}}
{{- if eq .type "soft" }}
{{- include "common.affinities.pods.soft" . -}}
{{- else if eq .type "hard" }}
{{- include "common.affinities.pods.hard" . -}}
{{- end -}}
{{- end -}}
