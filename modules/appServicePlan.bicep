param dmoneyAppServicePlanName string
param location string
param sku object
param kind string
param reserved bool

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: dmoneyAppServicePlanName
  location: location
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

output id string = appServicePlan.id
