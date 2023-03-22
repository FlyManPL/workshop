@description('Resources location')
param location string = resourceGroup().location

@description('Naming prefix')
param resourcePrefix string

@allowed([
  'prod'
  'test'
])
@description('Environment')
param environment string

@description('Address Prefix')
param vnetPrefix string = '10.0.0.0/16'

@description('Subnet Name')
param subnetName string = 'Default'

@description('Subnet Prefix')
param subnetPrefix string = '10.0.0.0/24'

var vnetName = '${resourcePrefix}-vnet-${environment}'
var nsgName = '${resourcePrefix}-nsg-${environment}'

var sourceAddressPrefix = (environment == 'prod') ? '10.0.0.0/8' : '*'


resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'nsgRule'
        properties: {
          description: 'Allow RDP access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: sourceAddressPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}
