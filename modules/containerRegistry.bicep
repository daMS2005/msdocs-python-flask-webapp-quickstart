// Parameters
param adminCredentialsKeyVaultResourceId string
@secure()
param adminCredentialsKeyVaultSecretUserName string
@secure()
param adminCredentialsKeyVaultSecretUserPassword string

// Existing Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

// Define the container registry dynamically or pass as a parameter
param containerRegistryName string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-01-01' existing = {
  name: containerRegistryName
}

// Key Vault secret for container registry username
resource secretUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: keyVault
  properties: {
    value: listCredentials(containerRegistry.id, '2022-01-01').username
  }
}

// Key Vault secret for container registry password
resource secretPassword 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword
  parent: keyVault
  properties: {
    value: listCredentials(containerRegistry.id, '2022-01-01').passwords[0].value
  }
}

// Outputs to expose login server and credentials dynamically
output loginServer string = containerRegistry.properties.loginServer
output username string = listCredentials(containerRegistry.id, '2022-01-01').username
output password string = listCredentials(containerRegistry.id, '2022-01-01').passwords[0].value
