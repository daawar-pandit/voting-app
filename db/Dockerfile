# Use the official PostgreSQL base image
FROM postgres:15-alpine

# Set default environment variables for PostgreSQL
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

# Create a directory for health check scripts if it doesn't already exist
RUN mkdir -p /healthchecks

# Copy your custom health check script into the container
COPY healthchecks/postgres.sh /healthchecks/postgres.sh
RUN chmod +x /healthchecks/postgres.sh

# Download and install the postgres_exporter
RUN apk add --no-cache curl && \
    curl -L https://github.com/prometheus-community/postgres_exporter/releases/download/v0.11.1/postgres_exporter-0.11.1.linux-amd64.tar.gz | tar -xz && \
    mv postgres_exporter-0.11.1.linux-amd64/postgres_exporter /usr/local/bin && \
    rm -rf postgres_exporter-0.11.1.linux-amd64*

# Expose PostgreSQL port and the exporter port
EXPOSE 5432 9187

# Configure postgres_exporter to connect to PostgreSQL using environment variables
# ECS will override these environment variables if provided in the ECS Task Definition
ENV DATA_SOURCE_NAME="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@${DB_HOST:-localhost}:5432/$POSTGRES_DB?sslmode=disable"

# Default command to run both PostgreSQL and postgres_exporter
CMD ["sh", "-c", "postgres & /usr/local/bin/postgres_exporter --web.listen-address=:9187 --extend.query-path=/healthchecks/queries.yaml"]
