param name string
param location string
param enableVaultForDeployment bool
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    enableSoftDelete: true
    enabledForDeployment: enableVaultForDeployment
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for role in roleAssignments: {
  name: guid(keyVault.id, role.principalId, role.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: role.roleDefinitionIdOrName
    principalId: role.principalId
    principalType: role.principalType
    scope: keyVault.id
  }
}]