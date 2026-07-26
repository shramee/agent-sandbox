# Generic agent sandbox: Node/Python/Go/Foundry toolchain + Claude Code,
# for running coding agents against whatever project directory gets mounted in.
FROM nikolaik/python-nodejs:python3.14-nodejs26

# --- Use specific user ID and avoid conflicts
ARG USER_ID=1001
ARG USER_NAME=agent

ENV HOME="/home/${USER_NAME}" \
    PNPM_HOME="/home/${USER_NAME}/.local/share/pnpm" \
    GOPATH="/home/${USER_NAME}/go"
ENV PATH="$PNPM_HOME/bin:$GOPATH/bin:/home/${USER_NAME}/.foundry/bin:/usr/local/go/bin:${PATH}"

# --- Install base dependencies ---
RUN apt-get update && apt-get install -y \
    sudo git zsh curl wget build-essential

# --- Go (useful for Go-based projects/tooling) ---
ARG GO_VERSION=1.26.2
RUN ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o /tmp/go.tgz \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm /tmp/go.tgz

# --- Foundry (forge/cast/anvil) for Solidity projects ---
RUN curl -fsSL https://foundry.paradigm.xyz | bash \
    && $HOME/.foundry/bin/foundryup

# --- pnpm + Claude Code CLI ---
RUN corepack enable \
    && corepack prepare pnpm@latest --activate \
    && pnpm i -g command-code @anthropic-ai/claude-code

# --- Add and switch to user ---
RUN groupadd -g ${USER_ID} ${USER_NAME} && \
    useradd -m -u ${USER_ID} -g ${USER_ID} -s /bin/bash ${USER_NAME} && \
    chsh -s /bin/zsh ${USER_NAME} && \
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

# Set the default shell for subsequent RUN commands
SHELL ["/bin/zsh", "-c"]

# Add ${USER_NAME} user to sudoers with no password
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the ${USER_NAME} user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Set up a default .zshrc if one isn't mounted, to ensure login works
RUN printf 'export ZSH="/home/%s/.oh-my-zsh"\n\nZSH_THEME="robbyrussell"\n\nplugins=(git)\n\nsource $ZSH/oh-my-zsh.sh\n' "${USER_NAME}" > /home/${USER_NAME}/.zshrc-default

# Keep the container running
CMD ["sleep", "infinity"]
