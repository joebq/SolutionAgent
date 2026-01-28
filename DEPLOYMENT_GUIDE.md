# Azure Landing Zone Deployment Guide

## Overview

This repository now contains a complete Azure Landing Zone implementation using Terraform and Azure Verified Modules (AVM). The landing zone includes all components specified in the requirements:

✅ Virtual Network (VNet)  
✅ VPN Gateway  
✅ Azure Bastion  
✅ Windows Virtual Machine with Public IP and RDP access

## Quick Start

### Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Terraform**: Version 1.9.2 or higher
3. **Azure CLI**: For authentication

### Installation Steps

#### 1. Install Terraform (if not already installed)

```bash
# On macOS
brew install terraform

# On Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# On Windows
choco install terraform
```

#### 2. Install Azure CLI

```bash
# On macOS
brew install azure-cli

# On Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# On Windows
choco install azure-cli
```

### Deployment

#### Step 1: Authenticate to Azure

```bash
az login
az account set --subscription <your-subscription-id>
```

#### Step 2: Navigate to Landing Zone Directory

```bash
cd landing-zone
```

#### Step 3: (Optional) Customize Configuration

Create a `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to customize:
- Azure region
- Resource names
- VM size
- **IMPORTANT**: Restrict RDP access by setting `allowed_rdp_source_address` to your public IP

```hcl
# Example terraform.tfvars
location = "eastus"
allowed_rdp_source_address = "203.0.113.5/32"  # Your public IP
```

#### Step 4: Initialize Terraform

```bash
terraform init
```

#### Step 5: Review the Deployment Plan

```bash
terraform plan
```

This will show you all resources that will be created.

#### Step 6: Deploy

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

**Note**: Deployment takes approximately 45-60 minutes due to VPN Gateway provisioning.

#### Step 7: Retrieve Connection Information

After deployment completes:

```bash
# Get VM public IP
terraform output vm_public_ip

# Get VM admin username
terraform output vm_admin_username

# Get VM admin password (sensitive)
terraform output -raw vm_admin_password
```

## Connecting to the Virtual Machine

### Option 1: Direct RDP (Windows)

```bash
mstsc /v:<vm_public_ip>
```

### Option 2: Direct RDP (macOS/Linux)

```bash
# Install Microsoft Remote Desktop from Mac App Store, then connect to IP
# Or use FreeRDP:
xfreerdp /v:<vm_public_ip> /u:azureadmin
```

### Option 3: Azure Bastion (Recommended)

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for your virtual machine: `vm-landing-zone`
3. Click **Connect** → **Bastion**
4. Enter username and password
5. Connect securely through your browser

## Architecture Components

### Network Architecture

```
Virtual Network: 10.0.0.0/16
├── GatewaySubnet: 10.0.1.0/24 (VPN Gateway)
├── AzureBastionSubnet: 10.0.2.0/24 (Azure Bastion)
└── VM Subnet: 10.0.3.0/24 (Virtual Machines)
```

### Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | rg-landing-zone | Container for all resources |
| Virtual Network | vnet-landing-zone | Network isolation |
| VPN Gateway | vng-landing-zone | Hybrid connectivity |
| Azure Bastion | bastion-landing-zone | Secure RDP/SSH access |
| Windows VM | vm-landing-zone | Compute workload |
| Public IPs | 3x Standard SKU | Internet connectivity |
| NSG | vm-landing-zone-nsg | Network security rules |

## Security Recommendations

### Before Production Use

1. **Restrict RDP Access**: 
   ```hcl
   allowed_rdp_source_address = "your.public.ip/32"
   ```

2. **Use Azure Bastion Exclusively**: Remove public IP from VM after testing

3. **Enable Just-In-Time (JIT) Access**: Configure in Azure Security Center

4. **Implement Azure Firewall**: Add centralized network security

5. **Enable Monitoring**: Configure Azure Monitor and Log Analytics

6. **Implement Backup**: Enable Azure Backup for the VM

7. **Use Key Vault**: Store passwords in Azure Key Vault instead of Terraform state

## Cost Considerations

Approximate monthly costs (East US region):

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| VPN Gateway | VpnGw1 | ~$140 |
| Azure Bastion | Basic | ~$140 |
| Windows VM | Standard_D2s_v3 | ~$120 |
| Public IPs (3) | Standard | ~$11 |
| **Total** | | **~$411/month** |

### Cost Optimization Tips

1. **Remove VPN Gateway** if not using hybrid connectivity (saves ~$140/month)
2. **Use smaller VM size** if lower performance is acceptable
3. **Stop/Deallocate VM** when not in use (saves compute costs)
4. **Consider Azure Hybrid Benefit** if you have Windows Server licenses

## Validation

Run the AVM validation scripts to ensure compliance:

```bash
# From repository root
./avm pre-commit  # Format and validate
./avm tflint      # Linting (requires tflint installation)
./avm pr-check    # Full PR checks
```

## Cleanup

To destroy all resources and avoid ongoing charges:

```bash
cd landing-zone
terraform destroy
```

Type `yes` when prompted to confirm destruction.

**Warning**: This will permanently delete all resources and data!

## Troubleshooting

### VPN Gateway Taking Too Long
- This is normal. VPN Gateway deployment takes 30-45 minutes.

### RDP Connection Refused
- Verify NSG allows your IP address
- Ensure VM is running: `az vm get-instance-view -g rg-landing-zone -n vm-landing-zone --query instanceView.statuses[1]`
- Check public IP is assigned: `terraform output vm_public_ip`

### Terraform Init Fails
- Ensure Terraform version >= 1.9.2: `terraform version`
- Check internet connectivity to download modules

### Azure Authentication Errors
- Run `az login` again
- Verify subscription access: `az account show`

## Additional Documentation

- [Landing Zone README](landing-zone/README.md) - Detailed deployment instructions
- [Architecture Documentation](landing-zone/ARCHITECTURE.md) - Architecture diagrams and component details
- [Azure Hub-Spoke Diagram](azure-hub-spoke-diagram.md) - Enterprise hub-spoke reference architecture

## Support and Contributions

For issues or questions:
1. Review the documentation in the `landing-zone/` directory
2. Check [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) documentation
3. Open an issue in the repository

## Next Steps

After successful deployment:

1. **Configure VPN**: Set up site-to-site or point-to-site VPN connections
2. **Deploy Applications**: Install and configure your workloads
3. **Implement Monitoring**: Set up Azure Monitor and alerts
4. **Add Spoke VNets**: Extend to hub-spoke topology as needed
5. **Enable Security Features**: Implement Azure Security Center recommendations

## License

This implementation uses Azure Verified Modules which are licensed under their respective licenses. Check individual module repositories for details.
