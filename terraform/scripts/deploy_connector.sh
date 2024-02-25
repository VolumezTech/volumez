#!/bin/bash

tenant_token=$1
signup_domain=$2 # default signup.volumez.com

package_not_found () {
    echo "<><><> Package not Found for $1 - Exiting" 
    exit 1
}

failed_vlzconnector_install () {
    echo "<><><> Failed to install vlzconnector on $1 - Exiting"
    exit 1
}

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
fi

echo "<><><> Running connector deploy on $OS"

if [[ "$OS" = "Ubuntu" ]]; then
    sudo curl --fail https://${signup_domain}/connector/ubuntu/vlzconnector.list -o /etc/apt/sources.list.d/vlzconnector.list || package_not_found $OS
    sudo mkdir -p /opt/vlzconnector
    echo -n ${tenant_token} | sudo tee -a /opt/vlzconnector/tenantToken
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -q -y vlzconnector || failed_vlzconnector_install $OS
elif [[ "$OS" = "Amazon Linux" ]]; then
    sudo curl --fail https://${signup_domain}/connector/amzn/amzn.repo -o /etc/yum.repos.d/volumez.repo || package_not_found $OS
    sudo mkdir -p /opt/vlzconnector
    echo -n ${tenant_token} | sudo tee -a /opt/vlzconnector/tenantToken
    sudo yum -y install vlzconnector || failed_vlzconnector_install $OS
elif [[ "$OS" = "SLES" ]]; then
    sudo curl --fail https://${signup_domain}/connector/sles/sles.repo -o /etc/zypp/repos.d/volumez.repo || package_not_found $OS
    sudo mkdir -p /opt/vlzconnector
    echo -n ${tenant_token} | sudo tee -a /opt/vlzconnector/tenantToken
    sudo zypper --non-interactive install -y vlzconnector || failed_vlzconnector_install $OS
elif [[ "$OS" = "Red Hat Enterprise Linux" ]]; then
    sudo curl --fail https://${signup_domain}/connector/rhel/rhel.repo -o /etc/yum.repos.d/volumez.repo || package_not_found $OS
    sudo mkdir -p /opt/vlzconnector
    echo -n ${tenant_token} | sudo tee -a /opt/vlzconnector/tenantToken
    sudo yum -y install '--exclude=kernel*' --nobest vlzconnector || failed_vlzconnector_install $OS
else
    echo "$OS - is not supported - exiting"
    exit 1
fi

echo "<><><> Finished Connector install on $OS!"