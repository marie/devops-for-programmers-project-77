### Hexlet tests and linter status:
[![Actions Status](https://github.com/marie/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/marie/devops-for-programmers-project-77/actions)

## Terraform

### Requirements

* terraform 1.3.9 (https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform)
* yc (https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider)
* make (https://www.gnu.org/software/make/#download)

### Steps

**Clone project**

**Run**

```bash
cd terraform

make decrypt-vars # decrypt vars from terraform.tfvars.encrypted to terraform.tfvars

make init # init terraform

make apply # apply infrastructure with terraform
make destroy # destroy infrastructure with terraform

make encrypt-vars # run when terraform.tfvars is changed. Ecrypts vars from terraform.tfvars to terraform.tfvars.encrypted
```


## Ansible

### Requirements

* ansible 2.13.7 (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* make (https://www.gnu.org/software/make/#download)

### Steps

**Clone project**

* Set to variable db_address correct db host
* Set correct ips in inventory.ini

**Run**

```bash
cd ansible

make install-roles # to install ansible roles

make pre-deploy # to set up servers
make deploy # deploy the app

make monitoring # to set up monitoring

make edit-secrets # for editing secrets in ansible vault
```


### Application

https://cold-may.ru/


