encrypt-vars:
	ansible-vault encrypt --output terraform.tfvars.encrypted --vault-password-file vault_password terraform.tfvars

decrypt-vars:
	ansible-vault decrypt --output terraform.tfvars --vault-password-file vault_password terraform.tfvars.encrypted

init:
	terraform init

apply:
	terraform apply

destroy:
	terraform destroy
