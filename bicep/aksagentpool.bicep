param AksName string

param PoolName string

@description('The zones to use for a node pool')
param availabilityZones array = []

@description('OS disk type')
param osDiskType string = 'Ephemeral'

@description('VM SKU')
param agentVMSize string = 'Standard_DS3_v2'

@description('Disk size in GB')
param osDiskSizeGB int = 0

@description('The number of agents for the user node pool')
param agentCount int = 3

@description('The maximum number of nodes for the user node pool')
param agentCountMax int = 0
var autoScale = agentCountMax > agentCount

@description('The maximum number of pods per node.')
param maxPods int = 30

param subnetId string

resource aks 'Microsoft.ContainerService/managedClusters@2021-10-01' existing = {
  name: AksName
}

resource nodepool 'Microsoft.ContainerService/managedClusters/agentPools@2021-10-01' = {
  parent: aks
  name: PoolName
  properties: {
    mode: 'User'
    vmSize: agentVMSize
    count: agentCount
    minCount: autoScale ? agentCount : json('null')
    maxCount: autoScale ? agentCountMax : json('null')
    enableAutoScaling: autoScale
    availabilityZones: !empty(availabilityZones) ? availabilityZones : null
    osDiskType: osDiskType
    osDiskSizeGB: osDiskSizeGB
    osType: 'Linux'
    maxPods: maxPods
    type: 'VirtualMachineScaleSets'
    vnetSubnetID: !empty(subnetId) ? subnetId : json('null')
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}
