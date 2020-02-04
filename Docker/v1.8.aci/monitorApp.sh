#!/bin/sh

HanaDbPassword="$(cat /mnt/secrets/hanadbpassword)"
LogAnalyticsSharedKey="$(cat /mnt/secrets/loganalyticssharedkey)"
echo "Onboarding"
python3 /var/opt/microsoft/sapmon/$Version/sapmon/payload/sapmon.py onboard \
        --HanaHostname $HanaHostname \
        --HanaDbName $HanaDbName \
        --HanaDbUsername $HanaDbUsername \
        --HanaDbSqlPort $HanaDbSqlPort \
        --LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId \
        --LogAnalyticsSharedKey $LogAnalyticsSharedKey \
        --HanaDbPassword $HanaPassword > /tmp/monitor.log.out

echo "monitoring"

infinite=1
while [ $infinite -eq 1 ]
do
  python3 /var/opt/microsoft/sapmon/$Version/sapmon/payload/sapmon.py monitor
  sleep 60s
done


