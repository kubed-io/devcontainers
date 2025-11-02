ARG BASE_IMAGE=mcr.microsoft.com/vscode/devcontainers/base:ubuntu

FROM ${BASE_IMAGE} AS devcontainer

ARG NODE_VERSION="none" \
    TARGETPLATFORM="linux/amd64" \
    BUILDPLATFORM="linux/amd64"

USER root

RUN <<EOF
mkdir -p /kubed
chown -R vscode:vscode /kubed
EOF

COPY --chown=vscode:vscode ./scripts /kubed/scripts

RUN <<EOF
chmod +x /kubed/scripts/*.sh
/kubed/scripts/install.sh direnv fzf 1password-cli openvpn
EOF

USER vscode

## 
# Now codeserver version as well
##
FROM codercom/code-server:latest AS codeserver 

ARG TARGETPLATFORM="linux/amd64" \
    BUILDPLATFORM="linux/amd64"

USER root

RUN <<EOF 

# make some dirs 
mkdir -p /kubed /kubed/code-server /home/coder/.local/share/code-server /projects
chown -R coder:coder /kubed /home/coder/.local/share/code-server /projects

# add coder to docker group
groupadd -g 983 docker
usermod -aG docker coder
EOF

COPY --chown=coder:coder ./scripts /kubed/scripts

RUN <<EOF 
chmod +x /kubed/scripts/*.sh
/kubed/scripts/install.sh direnv fzf 1password-cli docker-ce-cli openvpn
EOF

USER coder 
