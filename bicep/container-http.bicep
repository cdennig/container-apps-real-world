param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param containerPort int
param isExternalIngress bool
// param containerRegistry string
param env array = []
param minReplicas int = 0
@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'
param secrets array = []
var cpu = json('0.5')
var memory = '1.0Gi'

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      secrets: secrets
      activeRevisionsMode: revisionMode
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
          resources: {
            cpu: cpu
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
      }
      // dapr: {
      //   enabled: true
      //   appPort: containerPort
      //   appId: containerAppName
      //   components: daprComponents
      // }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
