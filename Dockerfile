# syntax=docker/dockerfile:1
# Custom sandbox template with bun and agent-browser
FROM docker/sandbox-templates:claude-code

USER root

# Install bun
RUN curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun/bin/bun /usr/local/bin/bun \
    && ln -s /usr/local/bin/bun /usr/local/bin/bunx

# Install Playwright browser system deps manually (playwright install-deps fails on Ubuntu 25.10)
# See: https://github.com/microsoft/playwright/issues/38874
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0t64 \
    libnspr4 \
    libnss3 \
    libatk1.0-0t64 \
    libdbus-1-3 \
    libatspi2.0-0t64 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxcb1 \
    libxkbcommon0 \
    libasound2t64 \
    && rm -rf /var/lib/apt/lists/*

# Install agent-browser CLI and Chromium
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/browsers
RUN npm install -g agent-browser \
    && agent-browser install \
    && chmod -R 755 /opt/browsers

USER agent
