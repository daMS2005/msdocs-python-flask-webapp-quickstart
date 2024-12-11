param dmoneyContainerRegistryName string
param location string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: dmoneyContainerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output loginServer string = containerRegistry.properties.loginServer
output username string = listCredentials(containerRegistry.id, '2021-12-01-preview').username
output password string = listCredentials(containerRegistry.id, '2021-12-01-preview').passwords[0].value