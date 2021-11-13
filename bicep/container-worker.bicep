param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param env array = []
param secrets array = []
param minReplicas int = 0
@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'

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
    }
  }
}
