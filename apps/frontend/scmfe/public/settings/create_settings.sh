#!/bin/sh

cat << EOF > /usr/share/nginx/html/settings/settings.js
var uisettings = {
    "endpoint": "https://$SCMCONTACTSEP/",
    "resourcesEndpoint": "https://$SCMRESOURCESEP/",
    "searchEndpoint": "https://$SCMSEARCHEP/",
    "reportsEndpoint": "https://$SCMREPORTSEP/",
    "enableStats": "true",
    "aiKey": "$AIKEY"
}
EOF