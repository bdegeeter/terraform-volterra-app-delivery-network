#!/bin/bash
set -e
set -o pipefail
SCRIPT_NAME=$(basename ${0})

NAME=$1
VK8S_NAMESPACE=$2
VK8S_NAME=$3
VK8S_KUBECONFIG_OUT_FILE=$4

jq \
  --arg name $NAME \
  --arg vk8sNs $VK8S_NAMESPACE \
  --arg vk8sName $VK8S_NAME \
  -n '{ "namespace": "system", "name": $name , "spec": { "type": "KUBE_CONFIG", "virtualK8sNamespace": $vk8sNs , "virtualK8sName": $vk8sName }, "expirationDays": 10 }' \
  >/tmp/${SCRIPT_NAME}.request.json

#https://www.volterra.io/docs/api/api-credential#operation/ves.io.schema.api_credential.CustomAPI.Create?query=api_credentials


REQ_CODE=$(curl -X 'POST' -s -w "%{http_code}" -k \
  --cert-type P12 \
  --cert ${VOLT_API_P12_FILE}:${VES_P12_PASSWORD} \
  --retry 5 \
  --retry-delay 5 \
  --retry-max-time 60 \
  -d @/tmp/${SCRIPT_NAME}.request.json \
  -H 'Content-Type: application/json' \
  -H 'X-Volterra-Useragent: v1/pgm=.terraform_providers_registry.terraform.io_volterraedge_volterra_0.10.0_darwin_amd64_terraform-provider-volterra_v0.10.0/host=foo' \
  -o /tmp/${SCRIPT_NAME}-ves-api-creds.out.json \
  "${VOLT_API_URL}/web/namespaces/system/api_credentials"
)
if [[ $REQ_CODE -ne 200 ]]; then
printf "API HTTP Status Code: %s\n" $REQ_CODE
exit 1
fi

rm -f $VK8S_KUBECONFIG_OUT_FILE
cat /tmp/${SCRIPT_NAME}-ves-api-creds.out.json |jq -r '.data' |base64 -d > $VK8S_KUBECONFIG_OUT_FILE
printf "Created KUBECONFIG: %s\n" $VK8S_KUBECONFIG_OUT_FILE