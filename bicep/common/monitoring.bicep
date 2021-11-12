@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Resource tags object to use')
param resourceTag object

var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var logAnalyticsWorkspaceName = 'laws-scm-${env}-${uniqueString(resourceGroup().id)}'
var location = resourceGroup().location

// ApplicationInsights
resource appi 'Microsoft.Insights/components@2015-05-01' = {
  name: appiName
  location: location
  tags: resourceTag
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// LogAnalytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: resourceTag
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}
