#!/bin/bash
set -euo pipefail

url='https://global.synologydownload.com/download/Utility/ActiveBackupBusinessAgent/3.1.0-4967/Linux/x86_64/Synology%20Active%20Backup%20for%20Business%20Agent-3.1.0-4967-x64-rpm.zip'
curl --fail --location --retry 3 --output 'Synology Active Backup for Business Agent-3.1.0-4967-x64-rpm.zip' "$url"
