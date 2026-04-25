# Use Eclipse Temurin for a reliable Java 21 runtime
FROM eclipse-temurin:21-jre-jammy

# Install necessary tools
RUN apt-get update && apt-get install -y bash curl tzdata gosu \
    && ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && echo "Asia/Ho_Chi_Minh" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd -g 1000 waterfall && \
    useradd -u 1000 -g waterfall -m -s /bin/bash waterfall

# Set the working directory
WORKDIR /proxy

# Pre-create necessary directories
RUN mkdir -p /proxy/plugins /proxy/modules /proxy/security \
    && chown -R waterfall:waterfall /proxy

# Copy the server files
COPY --chown=waterfall:waterfall . /proxy/

# Make the entrypoint script executable
COPY --chown=waterfall:waterfall docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose the default Waterfall port
EXPOSE 25565/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
