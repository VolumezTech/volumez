#!/bin/bash

#set -o errexit
mkdir -p /var/log/volumez/

ifautomation=$1
pub_dns=$2
websocket_id=$3
nodes_OS=$4
user_name=$5

echo "Automation:   $ifautomation"
echo "Dev dns:      $pub_dns"
echo "Websocket id: $websocket_id"
echo "Nodes OS:     $nodes_OS"
echo "User Name:    $user_name"

if test "$ifautomation" = "true"; then
    echo "Automation mode is True - continue to deploy stage"
else
    echo "Automation mode is False - Exiting"
    exit 0
fi

export SIO_USER=$user_name

chmod 400 /home/${user_name}/automation-kp.pem
# chown ${user_name}:${user_name} /home/${user_name}/automation-kp.pem
echo "InitiatorName=$(iscsi-iname)" >/etc/iscsi/initiatorname.iscsi

VOLUMEZ_DIR=/home/nk/go/src/bitbucket.org/storingio/volumez
LOGS_DIR=/var/log/volumez
retry=10
connector_installed=false
echo "$(date +%F_%H-%M-%S) - Deploy connector on ${nodes_os}" | tee -a $LOGS_DIR/deploy_connector.log

node_arch=`uname -i`
for i in $(seq 1 $retry); do
    echo "vlzconnector installation on node: $HOSTNAME os: ${nodes_OS} - attempt $i" | tee -a $LOGS_DIR/deploy_connector.log
    scp -i /home/${user_name}/automation-kp.pem -o 'StrictHostKeyChecking no' root@$pub_dns:$VOLUMEZ_DIR/vlzconnector_pkgs/vlzconnector*_${nodes_OS}.${node_arch}.* /home/${user_name}/
    if [ $? != 0 ]; then
        echo "scp failed, vlzconnector installation on node: $HOSTNAME os: ${nodes_OS} - attempt $i - FAILED, sleeping for 30 sec and retrying...." | tee -a $LOGS_DIR/deploy_connector.log
        sleep 30
        continue
    fi

    case ${nodes_OS} in
    rhel)
        sudo rpm -e vlzconnector
        sync
        sudo subscription-manager refresh
        sudo dnf update --disablerepo=* --enablerepo='*microsoft*' -y
        sudo dnf localinstall -y '--exclude=kernel*' --nobest /home/${user_name}/vlzconnector*_${nodes_OS}.${node_arch}.rpm
        ;;
    amzn)
        sudo rpm -e vlzconnector
        sync
        sudo yum localinstall -y /home/${user_name}/vlzconnector*_${nodes_OS}.${node_arch}.rpm
        ;;
    sles)
        sudo rpm -e vlzconnector
        sync
        sudo SUSEConnect
        sudo ZYPP_LOCK_TIMEOUT=120 zypper --no-gpg-checks --non-interactive install /home/${user_name}/vlzconnector*_${nodes_OS}.${node_arch}.rpm
        ;;
    ubuntu)
        sudo apt-get update
        echo "apt-update completed" | tee -a $LOGS_DIR/deploy_connector.log
        sudo ip a | tee -a $LOGS_DIR/deploy_connector.log
        sudo DEBIAN_FRONTEND=noninteractive apt remove -q -y -f vlzconnector
        echo "$(date +%F_%H-%M-%S) - Start - connector install" | tee -a $LOGS_DIR/deploy_connector.log
        # sudo apt install -y linux-modules-extra-$(uname -r)
        sudo DEBIAN_FRONTEND=noninteractive apt install -q -y -f /home/ubuntu/vlzconnector*_${nodes_OS}.${node_arch}.deb
        echo "$(date +%F_%H-%M-%S) - End - connector install" | tee -a $LOGS_DIR/deploy_connector.log
        ;;
    *)
        echo "unknown OS"
        ;;
    esac
    echo "date +%F_%H-%M-%S - Connector status" | tee -a $LOGS_DIR/deploy_connector.log
    sudo systemctl status vlzconnector.service | tee -a $LOGS_DIR/deploy_connector.log
    if [ -f /etc/systemd/system/vlzconnector.service ]; then
        echo "$(date +%F_%H-%M-%S) - vlzconnector installation on node: $HOSTNAME os: ${nodes_OS} - attempt $i - SUCCESS" | tee -a $LOGS_DIR/deploy_connector.log
        connector_installed=true
        break
    else
        echo "$(date +%F_%H-%M-%S) - vlzconnector installation on node: $HOSTNAME os: ${nodes_OS} - attempt $i - FAILED, sleeping for 30 sec and retrying...." | tee -a $LOGS_DIR/deploy_connector.log
        sleep 30
    fi
done

if ${connector_installed}; then
    sudo sed -i '/API_GW_ID/d' /etc/systemd/system/vlzconnector.service || exit 1
    sudo sed -i "/^\[Service\]/a Environment=\"API_GW_ID=${websocket_id}\"" /etc/systemd/system/vlzconnector.service || exit 1
    systemctl daemon-reload || exit 1
    systemctl restart vlzconnector.service || exit 1
    echo "$(date +%F_%H-%M-%S) - connector was restarted" | tee -a $LOGS_DIR/deploy_connector.log
    sleep 1
else
    echo "$(date +%F_%H-%M-%S) - ioconnector installation on node: $HOSTNAME os: ${nodes_OS} - FAILED ($retry attempts)" | tee -a $LOGS_DIR/deploy_connector.log
    exit 1
fi
echo "CONFIGURE HOST $pub_dns: OK"
