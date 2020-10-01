#!/bin/bash
set -e

az extension add -n sap-hana 2>/dev/null
az extension add -n log-analytics 2>/dev/null

SAPMON_RG=$1
SAPMON_NAME=$2
VERSION_TO_UPDATE=$3

SAPMON=$(az sapmonitor show -g ${SAPMON_RG} -n ${SAPMON_NAME})
if [ $? -ne 0 ]; then
    echo "Unable to find SapMonitor"
    exit 1
fi

echo ${SAPMON} | jq

SUBSCRIPTION_ID=$(echo ${SAPMON} | jq .id -r | cut -d'/' -f3)
SAPMON_ID=$(echo ${SAPMON} | jq .managedResourceGroupName -r | cut -d'-' -f3)
COLLECTOR_VERSION=$(echo ${SAPMON} | jq .sapMonitorCollectorVersion -r)
MONITOR_SUBNET=$(echo ${SAPMON} | jq .monitorSubnet -r)
VNET_RG=$(echo ${MONITOR_SUBNET} | cut -d'/' -f5)
VNET_NAME=$(echo ${MONITOR_SUBNET} | cut -d'/' -f9)
SUBNET_NAME=$(echo ${MONITOR_SUBNET} | cut -d'/' -f11)
LAWS_ARM_ID=$(echo ${SAPMON} | jq .logAnalyticsWorkspaceArmId -r)
LAWS_SUBSCRIPTION=$(echo ${LAWS_ARM_ID} | cut -d'/' -f3)
LAWS_RG=$(echo ${LAWS_ARM_ID} | cut -d'/' -f5)
LAWS_NAME=$(echo ${LAWS_ARM_ID} | cut -d'/' -f9)

UNSUPPORTED_VERSIONS=("" "v1.5" "v1.6" "v2.0-beta" "2.0" "2.1" "2.2")

if [[ " ${UNSUPPORTED_VERSIONS[@]} " =~ " ${COLLECTOR_VERSION} " ]]; then
    echo "The SapMonitor is of an unsupported version, please recreate the SapMonitor"
    exit 1
fi

while true; do
    read -p "Is this the SapMonitor you want to update? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Version to update is set
if [[ ! -z "$VERSION_TO_UPDATE" ]]; then
    while true; do
        read -p "This will also update your SapMonitor version from ${COLLECTOR_VERSION} to ${VERSION_TO_UPDATE}, is that OK? (y/n): " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    COLLECTOR_VERSION=${VERSION_TO_UPDATE}
fi

echo "==== Fetching Log-Analytics information ===="
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --subscription ${LAWS_SUBSCRIPTION} \
    --resource-group ${LAWS_RG} \
    --workspace-name ${LAWS_NAME} \
    --query "customerId" \
    --output tsv)
SHARED_KEY=$(az monitor log-analytics workspace get-shared-keys \
    --subscription ${LAWS_SUBSCRIPTION} \
    --resource-group ${LAWS_RG} \
    --workspace-name ${LAWS_NAME} \
    --query "primarySharedKey" \
    --output tsv)

echo "==== Configuring Collector VM ===="
COMMAND_TO_EXECUTE="docker rm -f "'$(docker ps -aq)'" 2>/dev/null || true && \
docker run --network host mcr.microsoft.com/oss/azure/azure-monitor-for-sap-solutions:${COLLECTOR_VERSION} python3 /var/opt/microsoft/sapmon/${COLLECTOR_VERSION}/sapmon/payload/sapmon.py onboard --logAnalyticsWorkspaceId ${WORKSPACE_ID} --logAnalyticsSharedKey ${SHARED_KEY} --enableCustomerAnalytics > /tmp/monitor.log.out && \
mkdir -p /var/opt/microsoft/sapmon/state && \
docker run --name sapmon-ver-${COLLECTOR_VERSION} --detach --restart always --network host --volume /var/opt/microsoft/sapmon/state:/var/opt/microsoft/sapmon/${COLLECTOR_VERSION}/sapmon/state --env Version=${COLLECTOR_VERSION} mcr.microsoft.com/oss/azure/azure-monitor-for-sap-solutions:${COLLECTOR_VERSION} sh /var/opt/microsoft/sapmon/${COLLECTOR_VERSION}/monitorapp.sh ${COLLECTOR_VERSION}"

az vm extension set \
    --resource-group sapmon-rg-${SAPMON_ID} \
    --vm-name sapmon-vm-${SAPMON_ID} \
    --name customScript \
    --publisher Microsoft.Azure.Extensions \
    --protected-settings "{\"commandToExecute\": \"${COMMAND_TO_EXECUTE}\"}" \
    --output none

echo "==== Update Complete ===="
