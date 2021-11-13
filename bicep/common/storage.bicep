@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Resource tags object to use')
param resourceTag object

var stForFunctiontName = 'stfn${env}${take(uniqueString(resourceGroup().id), 11)}'
var stgResourcesName = 'strs${env}${take(uniqueString(resourceGroup().id), 11)}'

var location = resourceGroup().location

// StorageAccount for Azure Functions
resource stgForFunctions 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stForFunctiontName
  location: location
  tags: resourceTag
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}


resource stgResources 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: stgResourcesName
  location: location
  tags: resourceTag
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output storageResConnString string =  'DefaultEndpointsProtocol=https;AccountName=${stgResources.name};AccountKey=${listKeys(stgResources.id, stgResources.apiVersion).keys[0].value}'
output storageForFunctionsConnString string = 'DefaultEndpointsProtocol=https;AccountName=${stgForFunctions.name};AccountKey=${listKeys(stgForFunctions.id, stgForFunctions.apiVersion).keys[0].value}'
