#!/usr/bin/env bash
set -e

# add some bashrc features
echo "Configuring custom .bashrc entries..."
{
    echo 'eval "$(direnv hook bash)"'
} >> ~/.bashrc 

OP_GIT_SETUP="false"

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# if OP_CONNECT_HOST and OP_CONNECT_TOKEN are set, then we don't need to sign in
if [ -n "$OP_CONNECT_HOST" ] && [ -n "$OP_CONNECT_TOKEN" ]; then
    echo "1Password Connect environment variables detected, skipping sign-in."
    OP_GIT_SETUP="true"
elif [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
    echo "1Password Service Account Token detected, skipping sign-in."
    OP_GIT_SETUP="true"
else 
    if [ "${CODESPACES}" != "true" ]; then
        echo "Using 1Password CLI to fetch SSH keys..."
        eval $(op signin --account my)
        OP_GIT_SETUP="true"
    fi
fi

# var for the ssh ref
OP_SSH_REF="op://$OP_VAULT_NAME/$OP_SSH_SECRET"

# configure SSH either using socket or by fetching keys directly
if [ -S "$HOME/.1password/agent.sock" ] && [ -d /opt/1Password ]; then
    echo "1Password SSH agent socket found, configuring SSH to use it..."
else
    if [ "$OP_GIT_SETUP" = "true" ]; then
        echo "1Password SSH agent socket not found, fetching SSH keys directly from 1Password..."
        op read "$OP_SSH_REF/private key?ssh-format=openssh" > ~/.ssh/github
        op read "$OP_SSH_REF/public key" > ~/.ssh/github.pub
        chmod 600 ~/.ssh/github
        chmod 644 ~/.ssh/github.pub
        echo "Setting git committer name and email from 1Password..."
        export GIT_COMMITTER_NAME="$(op read "$OP_SSH_REF/User/name")"
        export GIT_COMMITTER_EMAIL="$(op read "$OP_SSH_REF/User/email")"

        # configure git with ssh from op cli
        cat <<EOF > ~/.ssh/config
Host github.com
   HostName github.com
   User git
   IdentityFile ~/.ssh/github
   IdentitiesOnly yes
EOF

        # now the gitconfig
        cat <<EOF > ~/.gitconfig
[user]
 name = $GIT_COMMITTER_NAME
 email = $GIT_COMMITTER_EMAIL
 signingkey = ~/.ssh/github.pub

[core]
 excludesfile = ~/.gitignore

[gpg]
 format = ssh

[commit]
 gpgsign = true
EOF

        # build the common gitignore
        cat <<EOF > ~/.gitignore
.DS_Store
*.log
*.tmp
stuff
.vscode/settings.json
EOF
    # end of op git setup
    fi
fi
