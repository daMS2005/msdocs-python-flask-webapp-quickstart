param name string
param location string
param serverFarmResourceId string
param siteConfig object
param appSettingsKeyValuePairs object
param dockerAppSettings object = {}
param containerImageName string
param containerImageTag string

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: {
      ...siteConfig
      linuxFxVersion: 'DOCKER|${containerImageName}:${containerImageTag}'
    }
    appSettings: [
      for key in appSettingsKeyValuePairs: {
        name: key.name
        value: key.value
      }
    ]
      appSettings: [
  for keyValue in array(dockerAppSettings): {
    name: keyValue.key
    value: keyValue.value
      }
    ]
    
  }
}
