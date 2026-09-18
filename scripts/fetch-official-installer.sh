#!/bin/bash
set -euo pipefail

: "${ABB_RPM_URL:?Set ABB_RPM_URL to Synology's official RPM ZIP URL.}"
curl --fail --location --retry 3 --output 'Synology Active Backup for Business Agent-3.1.0-4967-x64-rpm.zip' "$ABB_RPM_URL"
