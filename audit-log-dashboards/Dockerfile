FROM grafana/grafana:10.2.0

# Switch to root to install plugins and copy files
USER root

# Install Trino datasource plugin
RUN grafana cli plugins install trino-datasource

# Copy provisioning configurations
COPY provisioning /etc/grafana/provisioning

# Copy pre-built dashboards
COPY dashboards /var/lib/grafana/dashboards

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Fix permissions — provisioning dir writable so entrypoint can update datasource config
RUN chown -R 472:0 /var/lib/grafana && \
    chown -R 472:0 /etc/grafana/provisioning && \
    chmod -R 775 /etc/grafana/provisioning && \
    chmod -R 775 /etc/grafana/provisioning/datasources

# Switch back to grafana user
USER 472

# Environment variables
ENV GF_AUTH_ANONYMOUS_ENABLED=true \
    GF_AUTH_ANONYMOUS_ORG_ROLE=Admin \
    GF_AUTH_DISABLE_LOGIN_FORM=true \
    GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=trino-datasource

# Trino connection defaults (override at runtime)
ENV TRINO_URL=http://localhost:8080 \
    TRINO_CATALOG=vast \
    TRINO_USER=grafana \
    TRINO_PASSWORD=""

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
