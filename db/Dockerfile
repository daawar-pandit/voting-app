FROM postgres:15-alpine

# Set environment variables for PostgreSQL
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

# Download and install the postgres_exporter
RUN apk add --no-cache curl && \
    curl -L https://github.com/prometheus-community/postgres_exporter/releases/download/v0.11.1/postgres_exporter-0.11.1.linux-amd64.tar.gz | tar -xz && \
    mv postgres_exporter-0.11.1.linux-amd64/postgres_exporter /usr/local/bin && \
    rm -rf postgres_exporter-0.11.1.linux-amd64*

# Expose PostgreSQL port and the exporter port
EXPOSE 5432 9187

# Add the health check script, initialization scripts, and change permissions
COPY postgres.sh /usr/local/bin/postgres.sh
RUN chmod +x /usr/local/bin/postgres.sh

# Switch to the 'postgres' user to run PostgreSQL as an unprivileged user
USER postgres

# Configure postgres_exporter to connect to PostgreSQL using environment variables
ENV DATA_SOURCE_NAME="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB?sslmode=disable"

# Start PostgreSQL and postgres_exporter with data directory initialization and pg_hba.conf update
CMD ["sh", "-c", "\
    mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql/data && \
    if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then \
        initdb -D /var/lib/postgresql/data; \
        echo 'host all postgres 0.0.0.0/0 trust' >> /var/lib/postgresql/data/pg_hba.conf; \
    fi && \
    postgres -D /var/lib/postgresql/data & /usr/local/bin/postgres_exporter --web.listen-address=:9187"]
