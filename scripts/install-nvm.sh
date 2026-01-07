#!/usr/bin/env bash
set -euo pipefail

NVM_INSTALL_URL="${NVM_INSTALL_URL:-https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh}"

if [ -z "${NVM_DIR:-}" ]; then
    if [ -z "${XDG_CONFIG_HOME:-}" ]; then
        NVM_DIR="$HOME/.nvm"
    else
        NVM_DIR="$XDG_CONFIG_HOME/nvm"
    fi
fi
export NVM_DIR

mkdir -p "$NVM_DIR"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Installing nvm into $NVM_DIR ..."
    export PROFILE="$NVM_DIR/.nvm-profile"
    : >"$PROFILE"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$NVM_INSTALL_URL" | bash
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$NVM_INSTALL_URL" | bash
    else
        echo "Error: need either curl or wget to install nvm." >&2
        exit 1
    fi
else
    echo "nvm already installed at $NVM_DIR"
fi

bashrc="${BASHRC_PATH:-$HOME/.bashrc}"
touch "$bashrc"

if ! grep -qF '# >>> nvm >>>' "$bashrc"; then
    cat >>"$bashrc" <<'EOF'
# >>> nvm >>>
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# <<< nvm <<<
EOF
fi
