@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@secure()
@description('Sql server\'s admin password')
param sqlUserPwd string

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')

// KeyVault Role Assignments
param roleAssignments array

module common 'common/commonmain.bicep' = {
  name: 'deployCommon'
  params: {
    env: env
    roleAssignments: roleAssignments
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

// output sqlUserName string = contacts.outputs.sqlUserName

// module resources 'resources/resourcesmain.bicep' = {
//   name: 'deployResources'
//   params: {
//     env: env
//   }
//   dependsOn: [
//     common
//   ]
// }

// module visitreports 'visitreports/visitreportsmain.bicep' = {
//   name: 'deployVisitReports'
//   params: {
//     env: env
//   }
//   dependsOn: [
//     common
//   ]
// }

// module search 'search/searchmain.bicep' = {
//   name: 'deploySearch'
//   params: {
//     env: env
//   }

//   dependsOn: [
//     common
//   ]
// }

// module frontend 'frontend/frontendmain.bicep' = {
//   name: 'deployFrontend'
//   params: {
//     env: env
//   }

//   dependsOn: [
//     common
//   ]
// }
