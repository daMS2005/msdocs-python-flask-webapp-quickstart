param dmoneyContainerRegistryName string = 'dmoneycontainerregistry'
param dmoneyAppServicePlanName string = 'dmoneyAppServicePlan'
param location string = 'westeurope'
param dmoneyWebAppName string = 'dmoneyWebApp'
param appSettingsKeyValuePairs array = [
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: 'false'
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: 'https://${dmoneyContainerRegistryName}.azurecr.io'
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_USERNAME'
    value: 'username_placeholder' // Replace dynamically if needed
  }
  {
    name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
    value: 'password_placeholder' // Replace dynamically if needed
  }
]

module webApp 'modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: dmoneyWebAppName
    location: location
    appSettingsKeyValuePairs: appSettingsKeyValuePairs
    serverFarmResourceId: dmoneyAppServicePlan.outputs.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dmoneyContainerRegistryName}/dmoneyimage:latest'
      appCommandLine: ''
    }
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'deployContainerRegistry'
  params: {
    
    containerRegistryName: dmoneyContainerRegistryName
    adminCredentialsKeyVaultResourceId: keyVault.outputs.keyVaultUri
    adminCredentialsKeyVaultSecretUserName: 'ACR-Username'
    adminCredentialsKeyVaultSecretUserPassword1: 'ACR-Password1'
    adminCredentialsKeyVaultSecretUserPassword2: 'ACR-Password2'
    
  }
}


// Azure App Service Plan Module
module dmoneyAppServicePlan 'modules/appServicePlan.bicep' = {
  name: 'deployAppServicePlan'
  params: {
    dmoneyAppServicePlanName: dmoneyAppServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'Linux'
    reserved: true
  }
}


module keyVault 'modules/key-vault.bicep' = {
  name: 'deployKeyVault'
  params: {
    name: 'dmoneyKeyVault'
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

