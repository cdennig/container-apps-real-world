@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

var resourceTag = {
  Environment: env
  Application: 'SCM'
  Component: 'Common'
}

@secure()
@description('Sql server\'s admin password')
param sqlUserPwd string

// @description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
// param roleAssignments array

module monitoring 'monitoring.bicep' = {
  name: 'deployMonitoring'
  params: {
    env: env
    resourceTag: resourceTag
  }
}

module storage 'storage.bicep' = {
  name: 'deployStorage'
  params: {
    env: env
    resourceTag: resourceTag
  }
}

module search 'search.bicep' = {
  name: 'deploySearch'
  params: {
    env: env
    resourceTag: resourceTag
  }
}

module textanalytics 'textanalytics.bicep' = {
  name: 'deployTextanalytics'
  params: {
    env: env
    resourceTag: resourceTag
  }
}

module servicebus 'servicebus.bicep' = {
  name: 'deployServiceBus'
  params: {
    env: env
    resourceTag: resourceTag
  }
}

module cosmos 'cosmos.bicep' = {
  name: 'deployCosmosAccount'
  params: {
    env: env
    resourceTag: resourceTag
  }
}

// module keyvault 'keyvault.bicep' = {
//   name: 'deployKeyVault'
//   params: {
//     env: env
//     resourceTag: resourceTag
//     roleAssignments: roleAssignments
//   }
// }

module database 'database.bicep' = {
  name: 'deployDatabase'
  params: {
    env: env
    resourceTag: resourceTag
    sqlUserPwd: sqlUserPwd
  }
}

module environment 'environment.bicep' = {
  name: 'deployEnvironment'
  params: {
    env: env
    resourceTag: resourceTag
  }
  dependsOn: [
    monitoring
  ]
}


// module secretAiKey 'secrets.bicep' = {
//   name: 'deployAiKeySecret'
//   params: {
//     env: env
//     secretName: 'AIKEY'
//     secretValue: monitoring.outputs.aikey
//   }
// }

// module secretCosmosUrl 'secrets.bicep' = {
//   name: 'deployCosmosUrl'
//   params: {
//     env: env
//     secretName: 'COSMOSURL'
//     secretValue: cosmos.outputs.cosmosurl
//   }
// }

// module secretCosmosKey 'secrets.bicep' = {
//   name: 'deployCosmosKey'
//   params: {
//     env: env
//     secretName: 'COSMOSKEY'
//     secretValue: cosmos.outputs.cosmoskey
//   }
// }

output containerEnvId string = environment.outputs.environmentId
output sqlConnString string = database.outputs.connectionString
output storageResConnString string = storage.outputs.storageResConnString
output storageForFunctionsConnString string = storage.outputs.storageForFunctionsConnString
output searchName string = search.outputs.name
output searchAdminKey string = search.outputs.adminkey
output textAnalyticsEndpoint string = textanalytics.outputs.endpoint
output textAnalyticsKey string = textanalytics.outputs.key
