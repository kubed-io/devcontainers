#!/usr/bin/env bash
set -e

mkdir -p ~/.ovpn

# Save the configuration from the secret if it is present
if [ ! -z "${OPENVPN_CONFIG}" ]; then 
    echo "${OPENVPN_CONFIG}" > ~/.ovpn/vpnconfig.ovpn
fi
if [ ! -z "${OPENVPN_AUTH}" ]; then 
    echo "${OPENVPN_AUTH}" > ~/.ovpn/auth.txt
fi

# Start up the VPN client using the config stored in vpnconfig.ovpn by save-config.sh
# check if vpnconfig.ovpn exists as a file, if it does then start openvpn
if [ -f ~/.ovpn/vpnconfig.ovpn ]; then
    echo "Discovered OpenVPN configuration file, starting OpenVPN..."
    nohup ${sudo_cmd} /bin/sh -c "openvpn --config ~/.ovpn/vpnconfig.ovpn --log ~/.ovpn/openvpn.log --auth-user-pass ~/.ovpn/auth.txt &" | tee ~/.ovpn/openvpn-launch.log
else
    echo "No OpenVPN configuration file found, skipping OpenVPN startup."
fi
