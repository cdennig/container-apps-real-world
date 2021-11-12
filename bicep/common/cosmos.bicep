@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

var cosmosAccount = 'cosmos-scm-${env}-${uniqueString(resourceGroup().id)}'
var location = resourceGroup().location
var cosmosDbName = 'scmvisitreports'
var cosmosDbContainerName = 'visitreports'

@description('Resource tags object to use')
param resourceTag object

// CosmosDB Account
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: cosmosAccount
  location: location
  kind: 'GlobalDocumentDB'
  tags: resourceTag
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Eventual'
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: resourceGroup().location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-03-15' = {
  name: '${cosmos.name}/${cosmosDbName}'
  location: location
  tags: resourceTag
  properties: {
    resource: {
      id: cosmosDbName
    }
    options: {
      throughput: 400
    }
  }

  resource container 'containers@2021-03-15' = {
    name: cosmosDbContainerName
    properties: {
      resource: {
        id: cosmosDbContainerName
        partitionKey: {
          paths: [
            '/type'
          ]
          kind: 'Hash'
        }
        indexingPolicy: {
          indexingMode: 'consistent'
          includedPaths: [
            {
              path: '/*'
            }
          ]
        }
      }
    }
  }
}
