# Devcontainers  

A collection of re-usable devcontainers and features commonly used in the Kubed Org. 

## 1Password Integration

This repo mainly started in an effort to wrangle 1Password cli integration with all the ways to run devcontainers and all the ways to use 1Password. 

### Connect Servers with Devcontainers  

If you have already set `OP_CONNECT_TOKEN` and `OP_CONNECT_HOST`, then the devcontainer will use those values to connect to your 1Password Connect server.

When you run devcontainers locally you can use a connect server and have the initialize script create a short-lived token and generate a `secrets.env` file for the devcontainer to use with connect server details. For this to work do not set the `OP_CONNECT_TOKEN` environment variable, but do set the following environment variables in your shell before starting the devcontainer: 
- `OP_CONNECT_HOST` - The hostname of your 1Password Connect server
- `OP_VAULT_NAME` - The vault name to use
- `OP_CONNECT_SERVER` - The server name to use

### Service Account with Codespaces  

When using Codespaces the recommended way to connect to 1Password is to use a service account. You can follow the instructions [here](https://developer.1password.com/docs/services/service-accounts/) to create a service account and generate a private key file. Then simply add the `OP_SERVICE_ACCOUNT_TOKEN` environment variable to your Codespace with the token. The devcontainer will automatically use that to authenticate with 1Password.

### SSH Secret 

Set an environment variable named ``OP_SSH_SECRET`` to the name of a secret in 1Password and in the same vault as `OP_VAULT_NAME` that contains your SSH private key. The [on-create.sh](./scripts/on-create.sh) script will fetch that secret and add it to the containers `~/.ssh` folder as `github` and `github.pub` files and set the appropriate permissions. 

The `.gitconfig` is configured to use the SSH key for authentication and signing commits. Make sure the same key is configured in Github for SSH access and commit signing. In the same secret as `OP_SSH_SECRET`, add a section titled `User` and add a `name` and `email` field to configure git commit signing.

This will ultimately make it so all of your commits will be signed, not just authenticated. 
