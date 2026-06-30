FROM python:{{ python_version }}-slim

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

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Install opencode
RUN curl -fsSL https://opencode.ai/install.sh | sh

# Install Playwright system deps + Chromium
RUN npx playwright install chromium --with-deps

WORKDIR /workspace
