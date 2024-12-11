// Existing Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

// Define the container registry dynamically or pass as a parameter
param containerRegistryName string
param adminCredentialsKeyVaultResourceId string
param adminCredentialsKeyVaultSecretUserName @secure()
param adminCredentialsKeyVaultSecretUserPassword1 @secure()
param adminCredentialsKeyVaultSecretUserPassword2 @secure()

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-01-01' existing = {
  name: containerRegistryName
}

// Store the container registry credentials in Key Vault
resource secretUserName 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserName}'
  properties: {
    value: listCredentials(containerRegistry.id, '2022-01-01').username
  }
}

resource secretUserPassword1 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserPassword1}'
  properties: {
    value: listCredentials(containerRegistry.id, '2022-01-01').passwords[0].value
  }
}

resource secretUserPassword2 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyVault.name}/${adminCredentialsKeyVaultSecretUserPassword2}'
  properties: {
    value: listCredentials(containerRegistry.id, '2022-01-01').passwords[1].value
  }
}

// Outputs to expose login server and credentials dynamically
output loginServer string = containerRegistry.properties.loginServer
output username string = listCredentials(containerRegistry.id, '2022-01-01').username
output password string = listCredentials(containerRegistry.id, '2022-01-01').passwords[0].value
