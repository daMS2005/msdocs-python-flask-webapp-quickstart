param name string
param location string
param serverFarmResourceId string
param siteConfig object
param appSettingsKeyValuePairs object
param dockerAppSettings object

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
    appSettings: [
      for key in keys(union(appSettingsKeyValuePairs, dockerAppSettings)): {
        name: key
        value: union(appSettingsKeyValuePairs, dockerAppSettings)[key]
      }
    ]
  }
}
