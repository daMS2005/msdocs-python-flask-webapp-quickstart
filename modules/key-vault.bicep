// Parameters
param name string // Name of the Key Vault
param location string // Location of the Key Vault
param enableVaultForDeployment bool = true // Enable Key Vault for deployment
param roleAssignments array // Array of role assignments for Key Vault

// Key Vault Resource
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    enabledForDeployment: enableVaultForDeployment
  }
}

// Role Assignments for Key Vault
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for role in roleAssignments: {
  name: guid(keyVault.id, role.principalId, role.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: role.roleDefinitionIdOrName
    principalId: role.principalId
    principalType: role.principalType
    scope: keyVault.id
  }
}]

// Outputs
output resourceId string = keyVault.id
output vaultUri string = keyVault.properties.vaultUri
