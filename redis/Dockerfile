FROM redis:alpine

# Add the health check script
COPY redis.sh /usr/local/bin/redis.sh
RUN chmod +x /usr/local/bin/redis.sh

# Expose Redis port
EXPOSE 6379

# Default command to run Redis
CMD ["redis-server"]