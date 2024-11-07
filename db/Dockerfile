FROM postgres:15-alpine

# Download and install the postgres_exporter
RUN apk add --no-cache curl && \
    curl -L https://github.com/prometheus-community/postgres_exporter/releases/download/v0.11.1/postgres_exporter-0.11.1.linux-amd64.tar.gz | tar -xz && \
    mv postgres_exporter-0.11.1.linux-amd64/postgres_exporter /usr/local/bin && \
    rm -rf postgres_exporter-0.11.1.linux-amd64*

# Expose PostgreSQL port and the exporter port
EXPOSE 5432 9187

# Switch to the 'postgres' user to run PostgreSQL as an unprivileged user
USER postgres

# Configure postgres_exporter to connect to PostgreSQL using environment variables
ENV DATA_SOURCE_NAME="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB?sslmode=disable"

# Default command to run both PostgreSQL and postgres_exporter
CMD ["sh", "-c", "postgres & /usr/local/bin/postgres_exporter --web.listen-address=:9187"]
