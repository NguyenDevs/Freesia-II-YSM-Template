# Use Eclipse Temurin for a reliable Java 21 runtime
FROM eclipse-temurin:21-jre-jammy

# Install necessary tools
RUN apt-get update && apt-get install -y bash curl tzdata gosu \
    && ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && echo "Asia/Ho_Chi_Minh" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd -g 1000 velocity && \
    useradd -u 1000 -g velocity -m -s /bin/bash velocity

# Set the working directory
WORKDIR /proxy

# Pre-create necessary directories
RUN mkdir -p /proxy/plugins /proxy/logs /proxy/security \
    && chown -R velocity:velocity /proxy

# Copy the server files (using the JAR name found in the directory)
COPY --chown=velocity:velocity . /proxy/

# Make the entrypoint script executable
COPY --chown=velocity:velocity docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose the default Velocity port
EXPOSE 25565/tcp
EXPOSE 25565/udp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
