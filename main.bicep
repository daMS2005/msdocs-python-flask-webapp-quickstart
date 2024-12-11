// Parameters
param dmoneyContainerRegistryName string = 'dmoneycontainerregistry' // Container Registry Name
param dmoneyAppServicePlanName string = 'dmoneyAppServicePlan' // App Service Plan Name
param location string = 'westeurope' // Desired Azure Region
param dmoneyWebAppName string = 'dmoneyWebApp' // Web App Name

// Azure Container Registry Module
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'deployContainerRegistry'
  params: {
    adminCredentialsKeyVaultResourceId: keyVault.outputs.keyVaultUri
    containerRegistryName: dmoneyContainerRegistryName
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
module keyVault 'modules/key-vault.bicep' = {
  name: 'deployKeyVault'
  params: {
    name: 'dmoneyKeyVault'
    location: location
    objectId: 'your-object-id'
    registryName: 'dmoneyContainerRegistry'
    ServicePrincipalId: '2c9d3d07-9aac-4d2e-9337-60284d4a993b'
  }
}




