@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Environment ID of container app')
param containerEnvId string

param textAnalyticsEndpoint string
param textAnalyticsKey string

// ApplicationInsights name
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var cosmosAccount = 'cosmos-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbName = 'sb-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbtVisitReportsName = 'sbt-visitreports'
var sbtContactsName = 'sbt-contacts'

@description('Function Storage Connection String')
param stgForFunctionConnectionString string

var location = resourceGroup().location

resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' existing = {
  name: cosmosAccount
}

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' existing = {
  name: sbName
}

resource sbtVisitReports 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' existing = {
  name: '${sb.name}/${sbtVisitReportsName}'
}

resource sbtVisitReportsSendRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2017-04-01' existing = {
  name: '${sbtVisitReports.name}/send'
}

resource sbtVisitReportsListenRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2017-04-01' existing = {
  name: '${sbtVisitReports.name}/listen'
}

resource sbtContacts 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' existing = {
  name: '${sb.name}/${sbtContactsName}'
}

resource sbtContactsListenRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2017-04-01' existing = {
  name: '${sbtContacts.name}/listen'
}


module visitreportsService '../container-http.bicep' = {
  name: 'visitreports'
  params: {
    location: location
    containerAppName: 'visitreports'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-visitreports-api:2.0'
    containerPort: 3000
    isExternalIngress: true
    minReplicas: 2
    secrets:[
      {
        name: 'sbvrconnection'
        value: listKeys(sbtVisitReportsSendRule.id, sbtVisitReportsSendRule.apiVersion).primaryConnectionString
      }
      {
        name: 'sbcontactconnection'
        value: listKeys(sbtContactsListenRule.id, sbtContactsListenRule.apiVersion).primaryConnectionString
      }
      {
        name: 'cosmoskey'
        value: listKeys(cosmos.id, cosmos.apiVersion).primaryMasterKey
      }
    ]
    env: [
      {
        name: 'APPINSIGHTS_KEY'
        value: appi.properties.InstrumentationKey
      }
      {
        name: 'COSMOSDB'
        value: cosmos.properties.documentEndpoint
      }
      {
        name: 'CUSTOMCONNSTR_COSMOSKEY'
        secretRef: 'cosmoskey'
      }
      {
        name: 'CUSTOMCONNSTR_SBVRTOPIC_CONNSTR'
        secretRef: 'sbvrconnection'
      }
      {
        name: 'CUSTOMCONNSTR_SBCONTACTSTOPIC_CONNSTR'
        value: listKeys(sbtContactsListenRule.id, sbtContactsListenRule.apiVersion).primaryConnectionString
      }
    ]
  }
}

module funcTextAnalyticsService '../container-worker.bicep' = {
  name: 'func-textanalytics'
  params: {
    location: location
    containerAppName: 'func-textanalytics'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-textanalytics-func:1.0'
    minReplicas: 2
    secrets:[
      {
        name: 'functionsstorage'
        value: stgForFunctionConnectionString
      }
      {
        name: 'sbconnection'
        value: replace(listKeys(sbtVisitReportsListenRule.id, sbtVisitReportsListenRule.apiVersion).primaryConnectionString, 'EntityPath=${sbtVisitReportsName}', '')
      }
      {
        name: 'cosmoskey'
        value: listKeys(cosmos.id, cosmos.apiVersion).primaryMasterKey
      }
      {
        name: 'takey'
        value: textAnalyticsKey
      }
    ]
    env: [
      {
        name: 'AzureWebJobsStorage'
        secretRef: 'functionsstorage'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'node'
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
        secretRef: 'sbconnection'
      }
      {
        name: 'COSMOSDB'
        value: cosmos.properties.documentEndpoint
      }
      {
        name: 'COSMOSKEY'
        secretRef: 'cosmoskey'
      }
      {
        name: 'TA_SUBSCRIPTIONENDPOINT'
        value: textAnalyticsEndpoint
      }
      {
        name: 'TA_SUBSCRIPTION_KEY'
        secretRef: 'takey'
      }
    ]
  }
}

output visitreportsUri string = visitreportsService.outputs.fqdn
