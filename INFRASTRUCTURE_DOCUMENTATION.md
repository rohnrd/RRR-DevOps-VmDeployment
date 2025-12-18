# Azure VM Deployment Infrastructure Documentation

**Project**: RRR-DevOps-VmDeployment  
**Environment**: dev  
**Generated**: December 18, 2025  
**Configuration**: dev-environment/data/dev.tfvars.json

---

## Table of Contents
1. [Resources That Will Be Created](#resources-that-will-be-created)
2. [Resources That Will NOT Be Created](#resources-that-will-not-be-created)
3. [Resource Relationship Diagram](#resource-relationship-diagram)
4. [Detailed Resource Specifications](#detailed-resource-specifications)
5. [Network Architecture](#network-architecture)
6. [Security Configuration](#security-configuration)
7. [Cost Estimation](#cost-estimation)

---

## Resources That Will Be Created

Based on your current configuration (`dev.tfvars.json`), the following Azure resources will be created:

### 1. **SSH Key Pair** (Terraform-Generated)
- **Resource**: `tls_private_key.ssh`
- **Type**: TLS Private Key (4096-bit RSA)
- **Purpose**: SSH authentication for Linux VM
- **Location**: Terraform state (can be exported)
- **Count**: 1

### 2. **Resource Group**
- **Name**: `devvm-rg`
- **Location**: East US
- **Purpose**: Container for all VM-related resources
- **Count**: 1

### 3. **Virtual Network (VNet)**
- **Name**: `devvm-vnet`
- **Location**: East US
- **Address Space**: 10.0.0.0/16
- **Purpose**: Network isolation and connectivity
- **Count**: 1

### 4. **Subnet**
- **Name**: `default`
- **Address Prefix**: 10.0.1.0/24
- **Parent**: devvm-vnet
- **Purpose**: VM network segment
- **Count**: 1

### 5. **Public IP Addresses**
- **Names**: 
  - `devvm-pip-1` (for Windows VM)
  - `devvm-pip-2` (for Linux VM)
- **Allocation Method**: Dynamic
- **SKU**: Basic
- **Purpose**: Internet access for VMs
- **Count**: 2

### 6. **Network Interfaces (NICs)**
- **Names**:
  - `devvm-nic-1` (Windows VM)
  - `devvm-nic-2` (Linux VM)
- **Private IP**: Dynamic allocation from subnet
- **Public IP**: Attached (as per config)
- **Count**: 2

### 7. **Windows Virtual Machine**
- **Name**: `devvm-win-1`
- **Size**: Standard_DS1_v2
- **OS**: Windows Server 2019 Datacenter
- **Publisher**: MicrosoftWindowsServer
- **Admin User**: azureuser
- **Authentication**: Password
- **OS Disk**: 
  - Storage: Standard_LRS
  - Caching: ReadWrite
- **NIC**: devvm-nic-1
- **Count**: 1

### 8. **Linux Virtual Machine**
- **Name**: `devvm-lin-1`
- **Size**: Standard_DS1_v2
- **OS**: Ubuntu Server 18.04 LTS
- **Publisher**: Canonical
- **Admin User**: azureuser
- **Authentication**: SSH Key (auto-generated)
- **OS Disk**:
  - Storage: Standard_LRS
  - Caching: ReadWrite
- **NIC**: devvm-nic-2
- **Count**: 1

---

## Resources That Will NOT Be Created

### Infrastructure Components NOT Created:

1. **Network Security Groups (NSGs)**
   - ❌ No firewall rules defined
   - ❌ No inbound/outbound port restrictions
   - ⚠️ **Security Risk**: VMs may be exposed to internet without proper firewall rules

2. **Load Balancers**
   - ❌ No traffic distribution
   - ❌ No high availability configuration

3. **Application Gateways**
   - ❌ No Layer 7 load balancing
   - ❌ No WAF (Web Application Firewall)

4. **Azure Bastion**
   - ❌ No secure RDP/SSH access
   - ⚠️ **Note**: Direct public IP access is used instead

5. **Virtual Network Peering**
   - ❌ No connectivity to other VNets

6. **VPN Gateway**
   - ❌ No site-to-site VPN
   - ❌ No point-to-site VPN

7. **Storage Accounts**
   - ❌ No separate storage for diagnostics
   - ❌ No boot diagnostics enabled

8. **Managed Disks (Data Disks)**
   - ❌ Only OS disks are created
   - ❌ No additional data disks

9. **Backup Vault**
   - ❌ No Azure Backup configured
   - ⚠️ **Risk**: No automated backup solution

10. **Azure Monitor / Log Analytics**
    - ❌ No monitoring dashboards
    - ❌ No log collection
    - ❌ No alerts configured

11. **Key Vault**
    - ❌ SSH keys stored in Terraform state only
    - ❌ Passwords not stored in secure vault

12. **Private Endpoints**
    - ❌ No private link connections

13. **Availability Sets / Availability Zones**
    - ❌ No high availability configuration
    - ⚠️ **Note**: Single point of failure

14. **VM Extensions**
    - ❌ No custom script extensions
    - ❌ No antivirus/monitoring agents
    - ❌ No Azure AD authentication

15. **DNS Zones**
    - ❌ No custom DNS configuration
    - Uses Azure-provided DNS only

---

## Resource Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AZURE SUBSCRIPTION                               │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    Resource Group: devvm-rg                        │ │
│  │                      Location: East US                             │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐ │ │
│  │  │         Virtual Network: devvm-vnet (10.0.0.0/16)            │ │ │
│  │  │                                                               │ │ │
│  │  │  ┌─────────────────────────────────────────────────────────┐ │ │ │
│  │  │  │   Subnet: default (10.0.1.0/24)                         │ │ │ │
│  │  │  │                                                          │ │ │ │
│  │  │  │   ┌──────────────┐         ┌──────────────┐            │ │ │ │
│  │  │  │   │   NIC-1      │         │   NIC-2      │            │ │ │ │
│  │  │  │   │ (devvm-nic-1)│         │ (devvm-nic-2)│            │ │ │ │
│  │  │  │   │ Private IP:  │         │ Private IP:  │            │ │ │ │
│  │  │  │   │  Dynamic     │         │  Dynamic     │            │ │ │ │
│  │  │  │   └──────┬───────┘         └──────┬───────┘            │ │ │ │
│  │  │  └──────────┼────────────────────────┼────────────────────┘ │ │ │
│  │  └─────────────┼────────────────────────┼──────────────────────┘ │ │
│  │                │                        │                        │ │
│  │       ┌────────┴────────┐      ┌────────┴────────┐              │ │
│  │       │   Public IP-1   │      │   Public IP-2   │              │ │
│  │       │  (devvm-pip-1)  │      │  (devvm-pip-2)  │              │ │
│  │       │   Dynamic       │      │   Dynamic       │              │ │
│  │       └────────┬────────┘      └────────┬────────┘              │ │
│  │                │                        │                        │ │
│  │       ┌────────▼────────┐      ┌────────▼────────┐              │ │
│  │       │  Windows VM     │      │   Linux VM      │              │ │
│  │       │  devvm-win-1    │      │   devvm-lin-1   │              │ │
│  │       ├─────────────────┤      ├─────────────────┤              │ │
│  │       │ OS: Win 2019    │      │ OS: Ubuntu 18.04│              │ │
│  │       │ Size: DS1_v2    │      │ Size: DS1_v2    │              │ │
│  │       │ Auth: Password  │      │ Auth: SSH Key   │              │ │
│  │       │                 │      │                 │              │ │
│  │       │ ┌─────────────┐ │      │ ┌─────────────┐ │              │ │
│  │       │ │  OS Disk    │ │      │ │  OS Disk    │ │              │ │
│  │       │ │ Standard_LRS│ │      │ │ Standard_LRS│ │              │ │
│  │       │ │ ReadWrite   │ │      │ │ ReadWrite   │ │              │ │
│  │       │ └─────────────┘ │      │ └─────────────┘ │              │ │
│  │       └─────────────────┘      └─────────────────┘              │ │
│  │                                                                  │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                 Terraform State (Outside Azure)                  │ │
│  │                                                                  │ │
│  │    ┌────────────────────────────────────────┐                   │ │
│  │    │  TLS Private Key (SSH)                 │                   │ │
│  │    │  - Algorithm: RSA 4096-bit             │                   │ │
│  │    │  - Public Key → Linux VM               │                   │ │
│  │    │  - Private Key → Stored in State       │                   │ │
│  │    └────────────────────────────────────────┘                   │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘

LEGEND:
  ┌──┐
  │  │  = Resource Container
  └──┘
  
   │
   ▼   = Dependency/Association
```

---

## Detailed Resource Specifications

### Virtual Machine Specifications

#### Windows VM (devvm-win-1)
```yaml
Compute:
  Size: Standard_DS1_v2
  vCPUs: 1
  RAM: 3.5 GB
  Temp Storage: 7 GB
  Max Data Disks: 4
  Max NICs: 2
  
Operating System:
  Publisher: MicrosoftWindowsServer
  Offer: WindowsServer
  SKU: 2019-Datacenter
  Version: latest
  
Storage:
  OS Disk Type: Standard_LRS
  OS Disk Size: ~127 GB (default)
  Caching: ReadWrite
  
Network:
  Private IP: Dynamic (10.0.1.x)
  Public IP: Dynamic (assigned at boot)
  NIC: devvm-nic-1
  
Authentication:
  Username: azureuser
  Method: Password
  Password: P@ssw0rd1234!
  
Access:
  RDP Port: 3389 (NOT restricted by NSG - ⚠️ Security Risk)
  Connection: Public IP required
```

#### Linux VM (devvm-lin-1)
```yaml
Compute:
  Size: Standard_DS1_v2
  vCPUs: 1
  RAM: 3.5 GB
  Temp Storage: 7 GB
  Max Data Disks: 4
  Max NICs: 2
  
Operating System:
  Publisher: Canonical
  Offer: UbuntuServer
  SKU: 18.04-LTS
  Version: latest
  
Storage:
  OS Disk Type: Standard_LRS
  OS Disk Size: ~30 GB (default)
  Caching: ReadWrite
  
Network:
  Private IP: Dynamic (10.0.1.x)
  Public IP: Dynamic (assigned at boot)
  NIC: devvm-nic-2
  
Authentication:
  Username: azureuser
  Method: SSH Key (auto-generated)
  Key Size: RSA 4096-bit
  
Access:
  SSH Port: 22 (NOT restricted by NSG - ⚠️ Security Risk)
  Connection: ssh -i key.pem azureuser@<public-ip>
```

---

## Network Architecture

### IP Address Allocation

| Resource | IP Type | Address Range | Allocation | Purpose |
|----------|---------|---------------|------------|---------|
| VNet | Virtual | 10.0.0.0/16 | Static | Network container (65,536 IPs) |
| Subnet | Virtual | 10.0.1.0/24 | Static | VM segment (256 IPs, ~251 usable) |
| Windows VM NIC | Private | 10.0.1.4-254 | Dynamic | Internal communication |
| Linux VM NIC | Private | 10.0.1.4-254 | Dynamic | Internal communication |
| Windows VM Public IP | Public | Azure-assigned | Dynamic | Internet access/RDP |
| Linux VM Public IP | Public | Azure-assigned | Dynamic | Internet access/SSH |

### Network Flow

```
Internet
   │
   ├──────────────────────┐
   │                      │
   ▼                      ▼
Public IP-1            Public IP-2
(Dynamic)              (Dynamic)
   │                      │
   ▼                      ▼
NIC-1                  NIC-2
10.0.1.x              10.0.1.y
   │                      │
   └──────────┬───────────┘
              │
              ▼
         Subnet: default
         (10.0.1.0/24)
              │
              ▼
         VNet: devvm-vnet
         (10.0.0.0/16)
              │
              ▼
      Resource Group: devvm-rg
```

### Communication Matrix

| From | To | Protocol | Status |
|------|----|---------|---------| 
| Internet | Windows VM | RDP (3389) | ⚠️ OPEN (No NSG) |
| Internet | Linux VM | SSH (22) | ⚠️ OPEN (No NSG) |
| Windows VM | Linux VM | All | ✅ Allowed (same subnet) |
| Linux VM | Windows VM | All | ✅ Allowed (same subnet) |
| Windows VM | Internet | All | ✅ Allowed (outbound) |
| Linux VM | Internet | All | ✅ Allowed (outbound) |

---

## Security Configuration

### ⚠️ Security Gaps (Critical)

1. **No Network Security Groups**
   - All ports are open to the internet
   - No inbound traffic filtering
   - **Recommendation**: Add NSG with rules:
     ```
     - Allow RDP (3389) from YOUR_IP only
     - Allow SSH (22) from YOUR_IP only
     - Deny all other inbound traffic
     ```

2. **Password in Plain Text**
   - Admin password stored in tfvars.json
   - Password visible in Terraform state
   - **Recommendation**: Use Azure Key Vault

3. **No Disk Encryption**
   - OS disks not encrypted with customer-managed keys
   - **Recommendation**: Enable Azure Disk Encryption

4. **No Monitoring/Logging**
   - No audit logs
   - No intrusion detection
   - **Recommendation**: Enable Azure Monitor and Security Center

5. **Public IP Addresses**
   - VMs directly exposed to internet
   - **Recommendation**: Use Azure Bastion or VPN Gateway

### Authentication Security

| VM | Method | Security Level | Notes |
|----|--------|----------------|-------|
| Windows | Password | ⚠️ Medium | Password visible in config files |
| Linux | SSH Key | ✅ High | 4096-bit RSA, auto-generated |

---

## Cost Estimation

### Monthly Cost Breakdown (East US Region)

| Resource | Quantity | Unit Price | Monthly Cost |
|----------|----------|------------|--------------|
| **Compute** |
| Windows VM (DS1_v2) | 1 | ~$72/month | $72.00 |
| Linux VM (DS1_v2) | 1 | ~$42/month | $42.00 |
| **Storage** |
| Standard LRS Disk (Windows) | 127 GB | ~$5.89/month | $5.89 |
| Standard LRS Disk (Linux) | 30 GB | ~$1.39/month | $1.39 |
| **Network** |
| Public IP (Basic, Dynamic) | 2 | ~$2.50/month each | $5.00 |
| VNet (included) | 1 | Free | $0.00 |
| Outbound Data Transfer | ~5 GB | $0.087/GB | ~$0.44 |
| **Total Estimated Monthly Cost** | | | **~$126.72** |

### Cost Optimization Tips
1. **Use Azure Reserved Instances**: Save up to 72% on VM costs
2. **Resize VMs**: B-series (burstable) could be cheaper for dev workloads
3. **Stop VMs when not in use**: Eliminates compute charges (storage charges remain)
4. **Use Spot VMs**: Save up to 90% for interruptible workloads

---

## Deployment Steps

### Prerequisites
```powershell
# Install Azure CLI
winget install Microsoft.AzureCLI

# Install Terraform
winget install Hashicorp.Terraform

# Login to Azure
az login
```

### Deployment Commands
```powershell
# Navigate to dev-environment
cd dev-environment

# Initialize Terraform (download providers)
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan -var-file="data/dev.tfvars.json"

# Deploy infrastructure
terraform apply -var-file="data/dev.tfvars.json"

# Get SSH keys (after deployment)
.\get-ssh-keys.ps1
```

### Access Your VMs

**Windows VM (RDP):**
```powershell
# Get public IP
terraform output vm_public_ips

# Connect via Remote Desktop
mstsc /v:<public-ip>
# Username: azureuser
# Password: P@ssw0rd1234!
```

**Linux VM (SSH):**
```powershell
# Export SSH key
terraform output -raw ssh_private_key > linux_key.pem

# Connect
ssh -i linux_key.pem azureuser@<public-ip>
```

---

## Cleanup

### Destroy All Resources
```powershell
# Remove all Azure resources
terraform destroy -var-file="data/dev.tfvars.json"

# Confirm with 'yes'
```

⚠️ **Warning**: This will permanently delete:
- Both VMs and their data
- All network resources
- Public IPs
- Resource group

---

## Configuration Files Reference

### Key Files in Repository

```
dev-environment/
├── main.tf                    # Main configuration (module call, SSH key generation)
├── provider.tf                # Azure & TLS provider configuration
├── variables.tf               # Variable definitions
├── terraform.tfvars.json      # Default variable values
├── get-ssh-keys.ps1          # Script to retrieve SSH keys after deployment
└── data/
    └── dev.tfvars.json       # Environment-specific variables (CURRENT CONFIG)

modules/
└── windows_vm/
    ├── main.tf               # VM resource definitions
    ├── variables.tf          # Module input variables
    └── outputs.tf            # Module outputs
```

### Current Configuration (dev.tfvars.json)
```json
{
  "name_prefix": "devvm",
  "location": "East US",
  "admin_username": "azureuser",
  "admin_password": "P@ssw0rd1234!",
  "admin_ssh_key": "",
  "use_existing_subnet": false,
  "existing_subnet_id": "",
  "use_existing_resource_group": false,
  "existing_resource_group_name": "",
  "create_public_ip": true,
  "vms": [
    {
      "name": "rrr-dummy-vm1",
      "os_type": "windows",
      "vm_size": "Standard_DS1_v2"
    },
    {
      "name": "rrr-dummy-vm2",
      "os_type": "linux",
      "vm_size": "Standard_DS1_v2"
    }
  ]
}
```

⚠️ **Note**: The `vms` array structure is defined but **NOT currently used** by the Terraform module. The module still uses `os_type` and `vm_count` variables instead. To use the array-based configuration, the module would need to be refactored.

---

## Known Limitations

1. **Single OS Type Deployment**: Current module creates VMs of one OS type at a time
   - To deploy both Windows and Linux simultaneously, module needs refactoring
   
2. **No NSG Configuration**: Network security must be added manually

3. **Dynamic Public IPs**: IP addresses change when VMs are stopped/started
   - Consider Static IPs for production

4. **No High Availability**: Single VM instances without availability sets

5. **Legacy Ubuntu Version**: Ubuntu 18.04 LTS (consider upgrading to 20.04 or 22.04)

6. **No Backup Configuration**: Manual backup setup required

7. **Terraform State Local**: State file stored locally (consider remote backend for teams)

---

## Recommendations

### Immediate Actions (High Priority)
1. ✅ Add Network Security Groups with restrictive rules
2. ✅ Move secrets to Azure Key Vault
3. ✅ Enable boot diagnostics
4. ✅ Upgrade Ubuntu to 20.04 or 22.04 LTS

### Short-term Improvements
1. Configure Azure Backup
2. Enable Azure Monitor and alerts
3. Implement availability sets or zones
4. Use static public IPs or Azure Bastion

### Long-term Enhancements
1. Implement Azure Policy for governance
2. Set up CI/CD pipeline for infrastructure
3. Use remote Terraform backend (Azure Storage)
4. Implement infrastructure testing (Terratest)

---

## Support & Troubleshooting

### Common Issues

**Issue**: Terraform fails with authentication error
```powershell
# Solution: Re-authenticate
az login
az account set --subscription <subscription-id>
```

**Issue**: Public IP not assigned
```
# Solution: Stop and start VM to trigger IP assignment
az vm stop --resource-group devvm-rg --name devvm-win-1
az vm start --resource-group devvm-rg --name devvm-win-1
```

**Issue**: SSH key permission denied
```bash
# Solution: Set correct permissions
chmod 600 linux_key.pem
```

---

## Version Information

- **Terraform**: >= 1.0
- **Azure Provider**: ~> 3.0
- **TLS Provider**: ~> 4.0
- **Azure CLI**: >= 2.50.0

---

## Document Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2025-12-18 | 1.0 | Initial documentation |

---

**Document Owner**: DevOps Team  
**Last Updated**: December 18, 2025  
**Review Cycle**: Quarterly
