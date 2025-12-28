FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    ca-certificates \
    sudo \
    zsh \
    python3 \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (handle case where GID/UID 1000 already exists)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if getent group $USER_GID > /dev/null 2>&1; then \
        groupmod -n $USERNAME $(getent group $USER_GID | cut -d: -f1); \
    else \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && if getent passwd $USER_UID > /dev/null 2>&1; then \
        usermod -l $USERNAME -d /home/$USERNAME -m -s /bin/zsh $(getent passwd $USER_UID | cut -d: -f1); \
    else \
        useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME; \
    fi \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Claude Code: binary at ~/.local/bin, config at ~/.claude (both defaults)
# Volta: Node.js version manager at ~/.volta
ENV VOLTA_HOME="/home/vscode/.volta"
ENV PATH="$VOLTA_HOME/bin:/home/vscode/.local/bin:$PATH"

USER $USERNAME

# Install Volta, Node.js (LTS), and Codex CLI
RUN curl https://get.volta.sh | bash \
    && $VOLTA_HOME/bin/volta install node@22.21 \
    && $VOLTA_HOME/bin/volta install @openai/codex

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /workspaces
