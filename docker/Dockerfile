# Use Alpine Linux with Go for a lightweight base
FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    git \
    curl \
    jq \
    bash \
    python3 \
    py3-pip

# Install Gitleaks
ARG GITLEAKS_VERSION=v8.24.2
RUN curl -sL https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks-linux-x64 \
    -o /usr/local/bin/gitleaks && \
    chmod +x /usr/local/bin/gitleaks && \
    gitleaks version

# Create app directory
WORKDIR /app

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy default configuration
COPY .gitleaks.toml /app/.gitleaks.toml

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["gitleaks", "git", "/scan", "-v"]
