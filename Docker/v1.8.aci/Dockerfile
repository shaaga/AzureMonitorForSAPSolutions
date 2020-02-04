FROM python:3.4-slim

ARG RELEASE
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install git -y
RUN pip3 install hdbcli azure_storage_logging azure-mgmt-storage azure-identity azure-keyvault-secrets msrestazure
RUN mkdir -p /var/opt/microsoft/sapmon/${RELEASE}
RUN git clone https://github.com/Azure/AzureMonitorForSAPSolutions.git --branch ${RELEASE} ${RELEASE}
RUN cp -a ${RELEASE}/* /var/opt/microsoft/sapmon/${RELEASE}
ADD monitorApp.sh monitorApp.sh
CMD ["sh","monitorApp.sh"]
