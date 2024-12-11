
// Existing Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

// Define the container registry dynamically or pass as a parameter
param containerRegistryName string
param adminCredentialsKeyVaultResourceId string
param adminCredentialsKeyVaultSecretUserName string
param adminCredentialsKeyVaultSecretUserPassword1 string
param adminCredentialsKeyVaultSecretUserPassword2 string


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: registryName
}


// Outputs to expose login server and credentials dynamically
output loginServer string = containerRegistry.properties.loginServer
output username string = listCredentials(containerRegistry.id, '2022-01-01').username
output password string = listCredentials(containerRegistry.id, '2022-01-01').passwords[0].value
