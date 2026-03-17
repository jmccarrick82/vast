#!/bin/bash
# Generate Trino datasource config from environment variables at container startup.
# This allows customers to configure their Trino connection without rebuilding the image.

TRINO_URL="${TRINO_URL:-http://localhost:8080}"
TRINO_CATALOG="${TRINO_CATALOG:-vast}"
TRINO_USER="${TRINO_USER:-grafana}"
TRINO_PASSWORD="${TRINO_PASSWORD:-}"

cat > /etc/grafana/provisioning/datasources/trino.yaml << EOF
apiVersion: 1

datasources:
  - name: Trino-AuditLog
    type: trino-datasource
    access: proxy
    url: ${TRINO_URL}
    isDefault: true
    jsonData:
      catalog: ${TRINO_CATALOG}
      schema: ""
      username: ${TRINO_USER}
    secureJsonData:
      password: "${TRINO_PASSWORD}"
    editable: true
EOF

echo "Trino datasource configured:"
echo "  URL:     ${TRINO_URL}"
echo "  Catalog: ${TRINO_CATALOG}"
echo "  User:    ${TRINO_USER}"

# Start Grafana
exec /run.sh
