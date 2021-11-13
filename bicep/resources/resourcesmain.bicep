@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Environment ID of container app')
param containerEnvId string

// ApplicationInsights name
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbName = 'sb-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbqThumbnailsName = 'sbq-scm-thumbnails'

@description('Resources Storage Connection String')
param storageConnString string

@description('Function Storage Connection String')
param stgForFunctionConnectionString string

var location = resourceGroup().location

resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' existing = {
  name: sbName
}

resource sbqThumbnails 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' existing = {
  name: '${sb.name}/${sbqThumbnailsName}'
}

resource sbqThumbnailsSendRule 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2017-04-01' existing = {
  name: '${sbqThumbnails.name}/send'
}

resource sbqThumbnailsListenRule 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2017-04-01' existing = {
  name: '${sbqThumbnails.name}/listen'
}

module resourcesService '../container-http.bicep' = {
  name: 'resources'
  params: {
    location: location
    containerAppName: 'resources'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-resources-api:2.0'
    containerPort: 5000
    isExternalIngress: true
    minReplicas: 2
    env: [
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
      {
        name: 'ImageStoreOptions__StorageAccountConnectionString'
        value: storageConnString
      }
      {
        name: 'ImageStoreOptions__ImageContainer'
        value: 'rawimages'
      }
      {
        name: 'ImageStoreOptions__ThumbnailContainer'
        value: 'thumbnails'
      }
      {
        name: 'ServiceBusQueueOptions__ThumbnailQueueConnectionString'
        value: listKeys(sbqThumbnailsSendRule.id, sbqThumbnailsSendRule.apiVersion).primaryConnectionString
      }
      {
        name: 'ServiceBusQueueOptions__ImageContainer'
        value: 'rawimages'
      }
      {
        name: 'ServiceBusQueueOptions__ThumbnailContainer'
        value: 'thumbnails'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
    ]
  }
}

module funcImageResizerService '../container-worker.bicep' = {
  name: 'func-imageresizer'
  params: {
    location: location
    containerAppName: 'func-imageresizer'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-resources-func:1.0'
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
        value: 'func-image-resizer'
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
      {
        name: 'ServiceBusConnectionString'
        value: replace(listKeys(sbqThumbnailsListenRule.id, sbqThumbnailsListenRule.apiVersion).primaryConnectionString, 'EntityPath=${sbqThumbnailsName}', '')
      }
      {
        name: 'QueueName'
        value: sbqThumbnailsName
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
        name: 'ImageProcessorOptions__StorageAccountConnectionString'
        value: storageConnString
      }
      {
        name: 'ImageProcessorOptions__ImageWidth'
        value: '100'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
    ]
  }
}
