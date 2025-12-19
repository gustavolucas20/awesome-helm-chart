{{/*
Validate PDB configuration
*/}}
{{- define "chartname.validate-pdb" -}}
{{- if and .Values.security.pdb.enabled (le (int .Values.replicaCount) 1) -}}
{{- fail "PodDisruptionBudget is enabled but replicaCount is <= 1. PDB requires multiple replicas to be effective." -}}
{{- end -}}
{{- end -}}
