param name string
param location string
param kind string
param serverFarmResourceId string
param siteConfig object
param appSettingsArray array // Accept the array

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
    appSettings: appSettingsArray // Use the array directly
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output id string = webApp.id
