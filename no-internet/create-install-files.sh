#!/bin/bash
set -e

LATEST_RELEASE=$(curl -s https://api.github.com/repos/Azure/AzureMonitorForSAPSolutions/releases/latest | jq .tag_name -r)

wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/containerd.io_1.2.6-3_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_19.03.9~3-0~ubuntu-xenial_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce-cli_19.03.9~3-0~ubuntu-xenial_amd64.deb
docker pull mcr.microsoft.com/oss/azure/azure-monitor-for-sap-solutions:${LATEST_RELEASE}
docker save mcr.microsoft.com/oss/azure/azure-monitor-for-sap-solutions:${LATEST_RELEASE} > azure-monitor-for-sap-solutions-${LATEST_RELEASE}.tar
tar -cvf no-internet-install-${LATEST_RELEASE}.tar containerd.io_1.2.6-3_amd64.deb docker-ce_19.03.9~3-0~ubuntu-xenial_amd64.deb docker-ce-cli_19.03.9~3-0~ubuntu-xenial_amd64.deb azure-monitor-for-sap-solutions-${LATEST_RELEASE}.tar
rm containerd.io_1.2.6-3_amd64.deb
rm docker-ce_19.03.9~3-0~ubuntu-xenial_amd64.deb
rm docker-ce-cli_19.03.9~3-0~ubuntu-xenial_amd64.deb
rm azure-monitor-for-sap-solutions-${LATEST_RELEASE}.tar
