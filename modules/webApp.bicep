resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
    appSettings: [
      for key in union(appSettingsKeyValuePairs, dockerAppSettings): {
        name: key
        value: union(appSettingsKeyValuePairs, dockerAppSettings)[key]
      }
    ]
  }
}
