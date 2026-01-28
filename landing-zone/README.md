# Azure Landing Zone with VPN Gateway, Bastion, and VM

This Terraform configuration creates an Azure Landing Zone for a single subscription with the following components:

## Architecture Components

1. **Virtual Network (VNet)**: A network with address space 10.0.0.0/16 containing three subnets:
   - GatewaySubnet (10.0.1.0/24) - For VPN Gateway
   - AzureBastionSubnet (10.0.2.0/24) - For Azure Bastion
   - VM Subnet (10.0.3.0/24) - For Virtual Machines

2. **VPN Gateway**: A VPN Gateway for hybrid connectivity (default SKU: VpnGw1)

3. **Azure Bastion**: Secure RDP/SSH access without exposing VMs to the public internet

4. **Windows Virtual Machine**: A Windows Server 2022 VM with:
   - Public IP address for direct RDP access
   - Network Security Group allowing RDP (port 3389)
   - Premium SSD storage
   - Random generated admin password

## Prerequisites

- Azure subscription
- Terraform >= 1.9.2
- Azure CLI (for authentication)

## Azure Verified Modules (AVM)

This configuration uses the following Azure Verified Modules:

1. **Virtual Network**: `Azure/avm-res-network-virtualnetwork/azurerm` (v0.4.2)

Note: The Virtual Machine uses the standard AzureRM provider resource (`azurerm_windows_virtual_machine`) for simplified network interface management with custom public IP and NSG configuration.

## Deployment

### 1. Authenticate to Azure

```bash
az login
az account set --subscription <subscription-id>
```

### 2. Initialize Terraform

```bash
cd landing-zone
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Deploy the Infrastructure

```bash
terraform apply
```

### 5. Retrieve Outputs

After deployment, retrieve important information:

```bash
# Get all outputs
terraform output

# Get VM admin password (sensitive)
terraform output -raw vm_admin_password

# Get VM public IP for RDP connection
terraform output -raw vm_public_ip
```

## Connecting to the Virtual Machine

### Option 1: Direct RDP via Public IP

```bash
# On Windows
mstsc /v:<vm_public_ip>

# On macOS/Linux
rdesktop <vm_public_ip>
# or
xfreerdp /v:<vm_public_ip> /u:azureadmin
```

Use the admin username and password from Terraform outputs.

### Option 2: Azure Bastion (Recommended for Production)

1. Navigate to the Azure Portal
2. Go to the Virtual Machine resource
3. Click "Connect" → "Bastion"
4. Enter the admin credentials
5. Connect securely through the browser

## Security Considerations

⚠️ **IMPORTANT**: This configuration is for demonstration purposes. For production use:

1. **RDP Access**: Change `allowed_rdp_source_address` variable to your specific IP address or IP range instead of "*" (all sources)
2. **Strong Passwords**: Consider using Azure Key Vault for password management
3. **Network Security**: Implement additional NSG rules based on your security requirements
4. **VPN Configuration**: Configure VPN Gateway connections to your on-premises network
5. **Azure Bastion**: Use Azure Bastion (included) for secure access instead of public IP + RDP

## Customization

Edit `variables.tf` or create a `terraform.tfvars` file to customize:

```hcl
# terraform.tfvars example
location                     = "eastus"
resource_group_name          = "rg-my-landing-zone"
vm_size                      = "Standard_D4s_v3"
allowed_rdp_source_address   = "203.0.113.0/24"  # Your public IP range
```

## Resource Naming

Default resource names follow Azure naming conventions:
- Resource Group: `rg-landing-zone`
- VNet: `vnet-landing-zone`
- VPN Gateway: `vng-landing-zone`
- Bastion: `bastion-landing-zone`
- VM: `vm-landing-zone`

## Cost Estimation

Approximate monthly costs (East US region):
- VPN Gateway (VpnGw1): ~$140
- Azure Bastion (Basic): ~$140
- Windows VM (Standard_D2s_v3): ~$120
- Public IPs (3): ~$11
- VNet: Free (data transfer charges apply)

**Total**: ~$411/month (approximate)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### VPN Gateway Deployment Time
VPN Gateway deployment can take 30-45 minutes. This is normal Azure behavior.

### Bastion Connection Issues
Ensure your browser allows pop-ups from portal.azure.com for Azure Bastion.

### RDP Connection Timeout
- Verify the NSG allows your source IP address
- Confirm the VM is running
- Check that the public IP is assigned

## References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Azure Virtual Network Documentation](https://docs.microsoft.com/azure/virtual-network/)
- [Azure VPN Gateway Documentation](https://docs.microsoft.com/azure/vpn-gateway/)
- [Azure Bastion Documentation](https://docs.microsoft.com/azure/bastion/)
- [Azure Virtual Machines Documentation](https://docs.microsoft.com/azure/virtual-machines/)
