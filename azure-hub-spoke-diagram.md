# Azure Hub and Spoke Architecture with VNet Peering

This diagram illustrates the Azure hub and spoke network topology using VNet peering, which is a recommended pattern from the Azure Well-Architected Framework for enterprise-scale networking.

## Architecture Overview

```mermaid
graph TB
    subgraph "On-Premises"
        OnPrem[On-Premises Network]
    end
    
    subgraph "Azure Cloud"
        subgraph "Hub VNet<br/>10.0.0.0/16"
            VPNGateway[VPN Gateway<br/>ExpressRoute Gateway]
            AzFirewall[Azure Firewall<br/>10.0.1.0/24]
            Bastion[Azure Bastion<br/>10.0.2.0/24]
            SharedServices[Shared Services<br/>DNS, Monitoring<br/>10.0.3.0/24]
        end
        
        subgraph "Spoke VNet 1<br/>10.1.0.0/16<br/>Production Workloads"
            Spoke1App[Application Tier<br/>10.1.1.0/24]
            Spoke1Data[Data Tier<br/>10.1.2.0/24]
        end
        
        subgraph "Spoke VNet 2<br/>10.2.0.0/16<br/>Development Workloads"
            Spoke2App[Application Tier<br/>10.2.1.0/24]
            Spoke2Data[Data Tier<br/>10.2.2.0/24]
        end
        
        subgraph "Spoke VNet 3<br/>10.3.0.0/16<br/>Shared Services"
            Spoke3App[Container Apps<br/>10.3.1.0/24]
            Spoke3Data[Storage Services<br/>10.3.2.0/24]
        end
    end
    
    %% Connections
    OnPrem -.->|Site-to-Site VPN<br/>ExpressRoute| VPNGateway
    VPNGateway -->|Hub VNet| AzFirewall
    AzFirewall ---|Hub VNet| Bastion
    AzFirewall ---|Hub VNet| SharedServices
    
    %% VNet Peering Connections
    AzFirewall <===>|VNet Peering<br/>Bidirectional| Spoke1App
    AzFirewall <===>|VNet Peering<br/>Bidirectional| Spoke2App
    AzFirewall <===>|VNet Peering<br/>Bidirectional| Spoke3App
    
    Spoke1App --- Spoke1Data
    Spoke2App --- Spoke2Data
    Spoke3App --- Spoke3Data
    
    %% Styling
    classDef hubStyle fill:#0078D4,stroke:#004578,stroke-width:3px,color:#fff
    classDef spokeStyle fill:#50E6FF,stroke:#0078D4,stroke-width:2px,color:#000
    classDef onpremStyle fill:#7FBA00,stroke:#5E8C00,stroke-width:2px,color:#fff
    
    class VPNGateway,AzFirewall,Bastion,SharedServices hubStyle
    class Spoke1App,Spoke1Data,Spoke2App,Spoke2Data,Spoke3App,Spoke3Data spokeStyle
    class OnPrem onpremStyle
```

## Key Components

### Hub VNet (10.0.0.0/16)
- **VPN Gateway / ExpressRoute Gateway**: Provides hybrid connectivity to on-premises networks
- **Azure Firewall**: Centralized network security and traffic filtering
- **Azure Bastion**: Secure RDP/SSH connectivity without public IP exposure
- **Shared Services**: DNS, monitoring, and other centralized services

### Spoke VNets
- **Spoke 1 (10.1.0.0/16)**: Production workloads with isolated application and data tiers
- **Spoke 2 (10.2.0.0/16)**: Development/testing environment
- **Spoke 3 (10.3.0.0/16)**: Shared application services (containers, storage)

### VNet Peering
- **Bidirectional peering** between hub and each spoke
- Low latency, high bandwidth connectivity
- Traffic between spokes can be routed through hub firewall for security
- No gateway transit required for spoke-to-spoke communication through hub

## Architecture Benefits

### Security
- **Centralized security controls**: All traffic can be inspected by Azure Firewall
- **Network isolation**: Spokes are isolated from each other by default
- **Secure hybrid connectivity**: Controlled access to on-premises resources
- **Zero Trust**: Azure Bastion eliminates the need for public IPs on VMs

### Reliability
- **High availability**: VNet peering is highly available by design
- **No single point of failure**: Multiple paths for redundancy
- **Regional resiliency**: Can extend to multi-region hub-spoke topologies

### Performance Efficiency
- **Low latency**: VNet peering provides direct network path
- **High throughput**: No bandwidth bottlenecks from appliances
- **Scalability**: Easy to add new spoke VNets as needed

### Cost Optimization
- **Shared resources**: Hub services are shared across all spokes
- **Efficient routing**: Direct peering reduces data transfer costs
- **Pay per use**: Only pay for active VNet peering connections

### Operational Excellence
- **Simplified management**: Centralized governance in hub
- **Clear separation**: Workloads isolated in dedicated spokes
- **Flexible expansion**: Add spokes without impacting existing workloads

## Implementation Considerations

1. **Route Tables**: Configure User Defined Routes (UDRs) to force traffic through Azure Firewall
2. **Network Security Groups (NSGs)**: Apply granular security rules at subnet level
3. **Service Endpoints**: Enable for Azure PaaS services to avoid internet routing
4. **Private Endpoints**: Use for private connectivity to PaaS services
5. **DNS**: Configure custom DNS in hub for name resolution across all VNets
6. **Monitoring**: Implement Azure Monitor, Network Watcher, and NSG Flow Logs

## Reference Architecture

This diagram is based on:
- [Azure Hub-Spoke Network Topology](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Well-Architected Framework - Networking](https://learn.microsoft.com/azure/well-architected/networking/)
- [VNet Peering Best Practices](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview)
