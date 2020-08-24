# Introduction
This section is for files relating to enabling SapMonitors where the source system VNet blocks outbound internet connections.

# create-install-files.sh
This script is for creating the installation files needed to get the Collector VM running the payload without internet connectivity.
With every release, there should be a corresponding `no-internet-install-<VERSION>.tar` which is created using this script.

# setup.sh
When a customer attempts to create a SapMonitor, if the source system VNet is blocking outbound internet connections, they may get the following error:
```
Failed Monitor Deployment: Status 4; Error \\nW: Failed to fetch http://azure.archive.ubuntu.com/ubuntu/dists/xenial/InRelease  Could not connect to azure.archive.ubuntu.com:80 (51.132.212.186), connection timed out\\nW: Failed to fetch http://azure.archive.ubuntu.com/ubuntu/dists/xenial-updates/InRelease  Unable to connect to azure.archive.ubuntu.com:http:\\nW: Failed to fetch http://azure.archive.ubuntu.com/ubuntu/dists/xenial-backports/InRelease  Unable to connect to azure.archive.ubuntu.com:http:\\nW: Failed to fetch http://security.ubuntu.com/ubuntu/dists/xenial-security/InRelease  Cannot initiate the connection to security.ubuntu.com:80 (2001:67c:1562::15). - connect (101: Network is unreachable) [IP: 2001:67c:1562::15 80]\\nW: Some index files failed to download. They have been ignored, or old ones used instead.\\n\\nWARNING: apt does not have a stable CLI interface. Use with caution in scripts.\\n\\nE: Unable to locate package containerd\\nE: Unable to locate package docker.io\\nE: Couldn't find any package by glob 'docker.io'\\nE: Couldn't find any package by regex 'docker.io'\\n\\\"\\r\\n\\r\\nMore information on troubleshooting is available at https://aka.ms/VMExtensionCSELinuxTroubleshoot \"
```
Or the creation may timeout altogether:
```
cli.azure.cli.core.util : Deployment failed. Correlation ID: cc2f0f53-d610-4581-816e-de360f3e015a. Failed Monitor Deployment: step timed out
Deployment failed. Correlation ID: cc2f0f53-d610-4581-816e-de360f3e015a. Failed Monitor Deployment: step timed out
```
When that happens, the customer can open [cloud shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview), download this script, and execute it like so:
```
./setup.sh <SAPMONITOR_RESOURCE_GROUP> <SAPMONITOR_RESOURCE_NAME>
```
