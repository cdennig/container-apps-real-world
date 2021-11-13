#!/bin/sh

cat << EOF > /usr/share/nginx/html/settings/settings.js
var uisettings = {
    "endpoint": "$SCMCONTACTSEP",
    "resourcesEndpoint": "$SCMRESOURCESEP",
    "searchEndpoint": "$SCMSEARCHEP",
    "reportsEndpoint": "$SCMREPORTSEP",
    "enableStats": "true",
    "aiKey": "$AIKEY"
}
EOF