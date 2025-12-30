{{/*
Validate PDB configuration
*/}}
{{- define "chartname.validate-pdb" -}}
{{- if and .Values.pdb.enabled (le (int .Values.workload.replicaCount) 1) -}}
{{- fail "PodDisruptionBudget is enabled but replicaCount is <= 1. PDB requires multiple replicas to be effective." -}}
{{- end -}}
{{- end -}}
