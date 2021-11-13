@minLength(3)
@maxLength(8)
@description('Name of environment')
param env string

@description('Secret Name')
param secretName string

@secure()
@description('Secret Value')
param secretValue string

var keyvaultName = 'kv-scm-${env}-${take(uniqueString(resourceGroup().id), 8)}'


resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvaultName}/${secretName}'
  properties: {
    contentType: 'text/plain'
    value: secretValue
  }
}
