# Dockerized ssh server

With this image you can use the port forward features of ssh. It supports PubKey auth only.

## Features

1. It can run with any user id, so you can use it in OpenShift too
1. You can specify RSA keys of the server (env or mount), so it won't overhelm your `known_hosts`
1. Post process `sshd_config` with a `sed` script
1. If RSA keys not specified they'll be regenerated at startup, not at build time

## How to use

### Variables

Variables are used only if the related files are not mounted.

| Variable                  | Default                                   | Description |
| ------------------------- | ----------------------------------------- | ----------- |
| RSA_PUBKEY                | Generate new key if empty and not mounted | RSA pubkey of ssh server |
| RSA_PRIVKEY               | Generate new key if empty and not mounted | RSA private key of ssh server |
| AUTHORIZED_KEYS           | Empty                                     | Allowed pubkeys. Separate multiple pubkeys with newline |
| SSH_USERNAME              | 'user'                                    | User name of client |
| POSTPROCESS_CONFIG_SCRIPT | Empty                                     | You can specify a `sed` script to postprocess `sshd_config` |

### Mounts

| File                                    | Mode | Description |
| --------------------------------------- | ---- | ----------- |
| /home/user/server/sshd_config           | 644  | You can specify the entire sshd config. It won't be modified by this image except by `POSTPROCESS_CONFIG_SCRIPT` |
| /home/user/server/ssh_host_rsa_key      | 600  | Private RSA key of the server. The default config expects 2048 bit |
| /home/user/server/ssh_host_rsa_key.pub  | 644  | Public RSA key of the server |
| /home/user/.ssh/authorized_keys         | 600  | Allowed public keys |
