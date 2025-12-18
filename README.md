# multivm Terraform workspace

This workspace contains a reusable Terraform module that creates an Azure Windows VM and a sample `dev-environment` that consumes the module.

Quick start (from `dev-environment`):

```bash
cd dev-environment
terraform init
terraform apply -var-file=data/dev.tfvars
```

Files:
- modules/vm: Terraform module that creates resource group, vnet, subnet, public IP, NIC and VMs (Windows or Linux).
- dev-environment: Example environment that references the module. Use the `data/dev.tfvars` file to set values for the dev environment.

Notes:
- This example targets Azure via the `azurerm` provider. Make sure you are authenticated (e.g., `az login`).
- Replace the example admin password with a secure secret in real usage and consider using a secure secret store.
