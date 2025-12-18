# Azure + Terraform Commands for dev-environment

## Interactive Azure CLI (PowerShell)

1. Authenticate interactively:

```powershell
az login
```

2. Select the dev subscription (replace with name or ID):

```powershell
az account set --subscription "a7717208-57cc-4349-a407-70aa2cc79962"
```

3. Run Terraform from the `dev-environment` folder:

```powershell
cd C:\Users\rajamohanrajendran\Documents\multivm\dev-environment
terraform init
terraform validate
terraform plan -var-file=data\dev.tfvars -out=tfplan
terraform apply "tfplan"
```

## Interactive Azure CLI (Windows CMD)

```cmd
az login
az account set --subscription "Your-Dev-Subscription-Name-or-ID"
cd C:\Users\rajamohanrajendran\Documents\multivm\dev-environment
terraform init
terraform validate
terraform plan -var-file=data\dev.tfvars -out=tfplan
terraform apply "tfplan"
```

## Service Principal (non-interactive / CI)

1. Create a service principal (one-time) and capture the output values:

```powershell
az ad sp create-for-rbac --name "tf-dev-sp" --role Contributor --scopes /subscriptions/a7717208-57cc-4349-a407-70aa2cc79962
```

2. Set environment variables for Terraform to pick up (PowerShell example):

```powershell
setx ARM_CLIENT_ID     "2b15a721-3080-48a9-898d-fef9fb1f17a0"
setx ARM_CLIENT_SECRET "Itb8Q~2G4z1X2Y_sTIPchVzMq8QlSJLpEokJ0b~E"
setx ARM_TENANT_ID     "1ac9b81f-b616-4cce-9322-e7e448475bd3"
setx ARM_SUBSCRIPTION_ID "a7717208-57cc-4349-a407-70aa2cc79962"
# Restart the shell to load environment variables
```

3. Run Terraform non-interactively:

```powershell
cd C:\Users\rajamohanrajendran\Documents\multivm\dev-environment
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
