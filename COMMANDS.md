# Azure + Terraform Commands for dev-environment

## Interactive Azure CLI (PowerShell)


```powershell
cd C:\Users\rajamohanrajendran\Documents\GitRepo\Vm
setx ARM_CLIENT_ID     "2b15a721-3080-48a9-898d-fef9fb1f17a0"
setx ARM_CLIENT_SECRET "Itb8Q~2G4z1X2Y_sTIPchVzMq8QlSJLpEokJ0b~E"
setx ARM_TENANT_ID     "1ac9b81f-b616-4cce-9322-e7e448475bd3"
setx ARM_SUBSCRIPTION_ID "a7717208-57cc-4349-a407-70aa2cc79962"
terraform init
terraform validate
terraform plan -no-color -out=tfplan > terraform-plan-clean.txt
terraform plan -out=tfplan
terraform apply -auto-approve "tfplan"
```
"appId": "2b15a721-3080-48a9-898d-fef9fb1f17a0",
  "displayName": "tf-dev-sp",
  "password": "Itb8Q~2G4z1X2Y_sTIPchVzMq8QlSJLpEokJ0b~E",
  "tenant": "1ac9b81f-b616-4cce-9322-e7e448475bd3"

## Notes & Tips
- Replace placeholders (subscription id, service principal values) before running.
- For Linux VMs, set `os_type = "linux"` and provide `admin_ssh_key` in `data/dev.tfvars`.
- To attach NICs to an existing subnet set `use_existing_subnet = true` and provide `existing_subnet_id`.
- To use an existing resource group set `use_existing_resource_group = true` and provide `existing_resource_group_name`.
- Consider configuring a remote backend (e.g., Azure Storage) before running in teams/CI.

Usage:
After running terraform apply, execute:
cd dev-environment
.\get-ssh-keys.ps1

cd dev-environment.\get-ssh-keys.ps1
What It Does:
Retrieves SSH keys from Terraform state
Saves keys to ./ssh-keys/ directory:
id_rsa (private key)
id_rsa.pub (public key)
Creates SSH_CONNECTION_INFO.txt with:
Full public and private key
VM IP addresses
SSH connection commands
PuTTY conversion instructions
Displays all connection information in the console