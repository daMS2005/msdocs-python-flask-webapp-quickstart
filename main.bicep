// Parameters
param dmoneyContainerRegistryName string = 'dmoneycontainerregistry' // Container Registry Name
param dmoneyAppServicePlanName string = 'dmoneyAppServicePlan' // App Service Plan Name
param location string = 'westeurope' // Desired Azure Region
param dmoneyWebAppName string = 'dmoneyWebApp' // Web App Name

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

// Azure Container Registry Module
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'deployContainerRegistry'
  params: {
    containerRegistryName: dmoneyContainerRegistryName
    adminCredentialsKeyVaultResourceId: keyVault.outputs.resourceId
    adminCredentialsKeyVaultSecretUserName: 'ACR-Username'
    adminCredentialsKeyVaultSecretUserPassword: 'ACR-Password'
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

// Pass appSettings as an array
module webApp 'modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: dmoneyWebAppName
    location: location
    serverFarmResourceId: dmoneyAppServicePlan.outputs.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.outputs.loginServer}/dmoneyimage:latest'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      DOCKER_REGISTRY_SERVER_URL: 'https://${dmoneyContainerRegistryName}.azurecr.io'
    }
    dockerAppSettings: {
      DOCKER_REGISTRY_SERVER_USERNAME: '${keyVault.outputs.vaultUri}/secrets/ACR-Username'
      DOCKER_REGISTRY_SERVER_PASSWORD: '${keyVault.outputs.vaultUri}/secrets/ACR-Password'
    }
  }
}
