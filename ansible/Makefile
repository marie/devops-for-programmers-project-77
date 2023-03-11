install-roles:
	ansible-galaxy install -r requirements.yml

pre-deploy:
	ansible-playbook --vault-password-file vault_password -i inventory.ini  --tags pre-deploy playbook.yml

deploy:
	ansible-playbook --vault-password-file vault_password -i inventory.ini --tags deploy playbook.yml

monitoring:
	ansible-playbook --vault-password-file vault_password -i inventory.ini --tags monitoring playbook.yml

edit-secrets:
	ansible-vault edit --vault-password-file vault_password ./group_vars/webservers/vault.yml
