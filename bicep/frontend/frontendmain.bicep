@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Environment ID of container app')
param containerEnvId string
param contactsUri string
param resourcesUri string
param searchUri string
param visitreportsUri string

// ApplicationInsights name
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var location = resourceGroup().location

resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}
module frontendService '../container-http.bicep' = {
  name: 'frontend'
  params: {
    location: location
    containerAppName: 'frontend'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-frontend-ui:2.0'
    containerPort: 80
    isExternalIngress: true
    minReplicas: 1
    env: [
      {
        name: 'SCMCONTACTSEP'
        value: contactsUri
      }
      {
        name: 'SCMRESOURCESEP'
        value: resourcesUri
      }
      {
        name: 'SCMSEARCHEP'
        value: searchUri
      }
      {
        name: 'SCMREPORTSEP'
        value: visitreportsUri
      }
      {
        name: 'AIKEY'
        value: appi.properties.InstrumentationKey
      }      
    ]
  }
}

output frontendUri string = frontendService.outputs.fqdn
