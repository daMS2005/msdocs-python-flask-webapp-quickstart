param adminCredentialsKeyVaultResourceId string
@secure()
param adminCredentialsKeyVaultSecretUserName string
@secure()
param adminCredentialsKeyVaultSecretUserPassword string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-01-01' existing = {
  name: '<containerRegistryName>' // Replace or pass dynamically if needed
}

resource secretUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
  dependsOn: [
    keyVault
    containerRegistry
  ]
}

resource secretPassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
  dependsOn: [
    keyVault
    containerRegistry
  ]
}
