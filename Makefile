TF_DIR=examples/basic
TF_CMD=terraform -chdir=$(TF_DIR)
TF_VARS=.tfvars.json

.PHONY: tfinit
tfinit:
	$(TF_CMD) init

.PHONY: tffmt
tffmt:
	$(TF_CMD) fmt

.PHONY: tfplan
tfplan:
	$(TF_CMD) plan -var-file=$(TF_VARS)

.PHONY: tfapply
tfapply:
	$(TF_CMD) apply -var-file=$(TF_VARS) -auto-approve

.PHONY: tfdestroy
tfdestroy:
	$(TF_CMD) destroy -var-file=$(TF_VARS) -auto-approve

.PHONY: tfout
tfout:
	$(TF_CMD) output -json |jq -r 'keys[] as $$k | "\($$k)=\(.[$$k] |.value)"'