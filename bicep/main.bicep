@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@secure()
@description('Sql server\'s admin password')
param sqlUserPwd string

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')

module common 'common/commonmain.bicep' = {
  name: 'deployCommon'
  params: {
    env: env
    sqlUserPwd: sqlUserPwd
  }
}

module contacts 'contacts/contactsmain.bicep' = {
  name: 'deployContacts'
  params: {
    env: env
    containerEnvId: common.outputs.containerEnvId
    sqlConnString: common.outputs.sqlConnString
  }
  dependsOn: [
    common
  ]
}

module resources 'resources/resourcesmain.bicep' = {
  name: 'deployResources'
  params: {
    env: env
    containerEnvId: common.outputs.containerEnvId
    storageConnString: common.outputs.storageResConnString
    stgForFunctionConnectionString: common.outputs.storageForFunctionsConnString
  }
  dependsOn: [
    common
  ]
}

module search 'search/searchmain.bicep' = {
  name: 'deploySearch'
  params: {
    env: env
    containerEnvId: common.outputs.containerEnvId
    stgForFunctionConnectionString: common.outputs.storageForFunctionsConnString
    searchServiceAdminKey: common.outputs.searchAdminKey
    searchServiceName: common.outputs.searchName
  }
  dependsOn: [
    common
  ]
}

module visitreport 'visitreports/visitreportsmain.bicep' = {
  name: 'deployVisitreports'
  params: {
    env: env
    containerEnvId: common.outputs.containerEnvId
    stgForFunctionConnectionString: common.outputs.storageForFunctionsConnString
    textAnalyticsEndpoint: common.outputs.textAnalyticsEndpoint
    textAnalyticsKey: common.outputs.textAnalyticsKey
  }
  dependsOn: [
    common
  ]
}

module frontend 'frontend/frontendmain.bicep' = {
  name: 'deployFrontend'
  params: {
    env: env
    containerEnvId: common.outputs.containerEnvId
    contactsUri: contacts.outputs.contactsUri
    resourcesUri: resources.outputs.resourcesUri
    searchUri: search.outputs.searchUri
    visitreportsUri: visitreport.outputs.visitreportsUri
  }
  dependsOn: [
    common
    contacts
    resources
    search
    visitreport
  ]
}
