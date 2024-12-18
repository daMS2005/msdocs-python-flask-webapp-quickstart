// Parameters
param dmoneyContainerRegistryName string = 'dmoneycontainerregistry' // Container Registry Name
param dmoneyAppServicePlanName string = 'dmoneyAppServicePlan' // App Service Plan Name
param location string = 'westeurope' // Desired Azure Region
param dmoneyWebAppName string = 'dmoneyWebApp' // Web App Name
param keyVaultName string = 'dmoneyKeyVault' // Key Vault Name
// Azure Container Registry Module
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'deployContainerRegistry'
  params: {
    dmoneyContainerRegistryName: dmoneyContainerRegistryName
    location: location
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
    kind: 'app'
    serverFarmResourceId: dmoneyAppServicePlan.outputs.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.outputs.loginServer}/dmoneyimage:latest'
      appCommandLine: ''
    }
    appSettingsArray: [
      {
        name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
        value: 'false'
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_URL'
        value: containerRegistry.outputs.loginServer
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        value: containerRegistry.outputs.username
      }
      {
        name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        value: containerRegistry.outputs.password
      }
    ]
  }
}
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [] // Explicitly set to an empty array
  }
}

// Output for verification or integration
output keyVaultUri string = keyVault.properties.vaultUri
