@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Environment ID of container app')
param containerEnvId string

param searchServiceName string
param searchServiceAdminKey string

// ApplicationInsights name
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbName = 'sb-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbtContactsName = 'sbt-contacts'

@description('Function Storage Connection String')
param stgForFunctionConnectionString string

var location = resourceGroup().location
var indexerName = 'scmcontacts'

resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' existing = {
  name: sbName
}

resource sbtContacts 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' existing = {
  name: '${sbName}/${sbtContactsName}'
}

resource sbtContactsListenRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2017-04-01' existing = {
  name: '${sbtContacts.name}/listen'
}

module searchService '../container-http.bicep' = {
  name: 'search'
  params: {
    location: location
    containerAppName: 'search'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-search-api:2.0'
    containerPort: 5000
    isExternalIngress: true
    minReplicas: 2
    env: [
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
      {
        name: 'ContactSearchOptions__IndexName'
        value: indexerName
      }
      {
        name: 'ContactSearchOptions__ServiceName'
        value: searchServiceName
      }
      {
        name: 'ContactSearchOptions__AdminApiKey'
        value: searchServiceAdminKey
      }
    ]
  }
}

module funcSearchIndexerService '../container-worker.bicep' = {
  name: 'func-search-indexer'
  params: {
    location: location
    containerAppName: 'func-search-indexer'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-search-func:1.0'
    minReplicas: 2
    env: [
      {
        name: 'AzureWebJobsStorage'
        value: stgForFunctionConnectionString
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: stgForFunctionConnectionString
      }
      {
        name: 'WEBSITE_CONTENTSHARE'
        value: 'func-search-indexer'
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'dotnet'
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~3'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
      {
        name: 'ServiceBusConnectionString'
        value: replace(listKeys(sbtContactsListenRule.id, sbtContactsListenRule.apiVersion).primaryConnectionString, 'EntityPath=${sbtContactsName}', '')
      }
      {
        name: 'ContactIndexerOptions__IndexName'
        value: indexerName
      }
      {
        name: 'ContactIndexerOptions__ServiceName'
        value: searchServiceName
      }
      {
        name: 'ContactIndexerOptions__AdminApiKey'
        value: searchServiceAdminKey
      }
    ]
  }
}
