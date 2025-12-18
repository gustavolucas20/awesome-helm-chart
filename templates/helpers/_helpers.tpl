{{/*
Expand the name of the chart.
Cria o nome completo base (Ex: myapp-production)
*/}}
{{- define "chartname.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
Define o nome completo do recurso: {{.Release.Name}}-{{template "chartname.name" .}}
*/}}
{{- define "chartname.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
Usado para identificar o Chart específico que instalou o recurso.
*/}}
{{- define "chartname.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
Define um conjunto padrão de labels para todos os recursos.
Isto é crucial para rastreamento e organização.
*/}}
{{- define "chartname.labels" -}}
helm.sh/chart: {{ include "chartname.chart" . }}
{{ include "chartname.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
Define o conjunto mínimo de labels que o Deployment e o Service usam para selecionar os Pods.
*/}}
{{- define "chartname.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chartname.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "chartname.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- default (include "chartname.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}