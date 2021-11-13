@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Environment ID of container app')
param containerEnvId string

// ApplicationInsights name
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
// ServiceBus names
var sbName = 'sb-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbtContactsName = 'sbt-contacts'

@description('SQL Connection String')
param sqlConnString string

var location = resourceGroup().location

resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' existing = {
  name: sbName
}

resource sbtContacts 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' existing = {
  name: '${sb.name}/${sbtContactsName}'
}

resource sbtContactsSendRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2017-04-01' existing = {
  name: '${sbtContacts.name}/send'
}

module contactsService '../container-http.bicep' = {
  name: 'contacts'
  params: {
    location: location
    containerAppName: 'contacts'
    environmentId: containerEnvId
    containerImage: 'ghcr.io/cdennig/adc-contacts-api:2.0'
    containerPort: 5000
    isExternalIngress: true
    minReplicas: 2
    secrets: [
      {
        name: 'sqlconnectionstring'
        value: sqlConnString
      }
    ]
    env: [
      {
        name: 'ConnectionStrings__DefaultConnectionString'
        secretRef: 'sqlconnectionstring'
      }
      {
        name: 'EventServiceOptions__ServiceBusConnectionString'
        value: listKeys(sbtContactsSendRule.id, sbtContactsSendRule.apiVersion).primaryConnectionString
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
    ]
  }
}

output contactsUri string = contactsService.outputs.fqdn
