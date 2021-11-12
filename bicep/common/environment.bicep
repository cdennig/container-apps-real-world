@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

var location = resourceGroup().location

var envName = 'kubeenv-scm-${env}-${take(uniqueString(resourceGroup().id), 8)}'
var logAnalyticsWorkspaceName = 'laws-scm-${env}-${uniqueString(resourceGroup().id)}'
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}
resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}

@description('Resource tags object to use')
param resourceTag object

resource environment 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: envName
  location: location
  tags: resourceTag
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    containerAppsConfiguration: {
      daprAIInstrumentationKey: appi.properties.InstrumentationKey
    }
  }
}
