FROM python:{{ python_version }}-slim

ARG USER_ID
ARG GROUP_ID

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Node.js for MCP tools (Playwright, Context7 via npx)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install uv (system-wide so it is available to the non-root user)
ENV UV_INSTALL_DIR=/usr/local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install opencode (relocate binary to a system path)
RUN curl -fsSL https://opencode.ai/install.sh | sh \
    && [ -f /root/.local/bin/opencode ] && mv /root/.local/bin/opencode /usr/local/bin/ || true

# Install Playwright system deps + Chromium into a shared location
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright
RUN npx playwright install chromium --with-deps \
    && chmod -R a+rX /usr/local/share/playwright

# Non-root user matching the host UID/GID (passed via build args)
RUN groupadd --gid ${GROUP_ID} dev \
    && useradd --uid ${USER_ID} --gid dev --create-home --shell /bin/bash dev

# Marker so tools (e.g. AGENTS.md instructions) can detect they are running
# inside the dev container and run commands directly instead of via docker.
ENV INSIDE_DEV_CONTAINER=1

USER dev
WORKDIR /workspace
