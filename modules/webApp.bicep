param name string
param location string
param appSettingsKeyValuePairs array
param serverFarmResourceId string
param siteConfig object

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
    appSettings: [
      for setting in appSettingsKeyValuePairs: {
        name: setting.name
        value: setting.value
      }
    ]
  }
}
