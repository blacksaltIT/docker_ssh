#!/usr/bin/env bash

# Create the current user in passwd
cp /etc/passwd /tmp/passwd
export LD_PRELOAD=/usr/lib/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

echo "$SSH_USERNAME:x:$(id -u):$(id -g):Assigned UID user:/home/user/:/bin/bash" >> /tmp/passwd
mkdir /home/user
export HOME=/home/user

# sshd config
if [[ ! -f ~/server/sshd_config ]]; then
    mkdir -p ~/server
    cp /etc/ssh/sshd_config ~/server/

    sed -i 's/Port 22/Port 10022/' ~/server/sshd_config && \
    sed -i 's/UsePrivilegeSeparation yes/UsePrivilegeSeparation no/' ~/server/sshd_config
    sed -i "s,#AuthorizedKeysFile	%h/.ssh/authorized_keys,AuthorizedKeysFile	/home/user/.ssh/authorized_keys," ~/server/sshd_config
    sed -i "s,UsePAM yes,UsePAM no," ~/server/sshd_config
    sed -i "s,ServerKeyBits 1024,ServerKeyBits 2048," ~/server/sshd_config
    echo "GatewayPorts yes" >> ~/server/sshd_config

    sed -i "/^HostKey/d" ~/server/sshd_config
    echo "HostKey /home/user/server/ssh_host_rsa_key" >> ~/server/sshd_config
fi

# server keys
if [[ ! -f ~/server/ssh_host_rsa_key && ! -f ~/server/ssh_host_rsa_key.pub ]]; then
    mkdir -p ~/server
    if [[ -n ${RSA_PUBKEY} && -n ${RSA_PRIVKEY} ]]; then
        echo -n "${RSA_PUBKEY}" > ~/server/ssh_host_rsa_key.pub
        echo -n "${RSA_PRIVKEY}" > ~/server/ssh_host_rsa_key
    else
        ssh-keygen -N "" -b 2048 -f ~/server/ssh_host_rsa_key
    fi

    chmod 644 ~/server/ssh_host_rsa_key.pub
    chmod 600 ~/server/ssh_host_rsa_key
fi

# .ssh
if [[ ! -d ~/.ssh ]]; then
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
fi

# authorized_keys
if [[ -n ${AUTHORIZED_KEYS} ]]; then
    echo "${AUTHORIZED_KEYS}" > ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

# allow custom config edits
if [[ -n ${POSTPROCESS_CONFIG_SCRIPT} ]]; then
    sed -i "${POSTPROCESS_CONFIG_SCRIPT}" ~/server/sshd_config
fi

# run sshd
mkfifo /var/run/sshd.pipe
cat /var/run/sshd.pipe &
exec /usr/sbin/sshd -D -f ~/server/sshd_config -E /var/run/sshd.pipe
