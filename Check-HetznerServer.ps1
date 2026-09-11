#Requires -Version 5.1
param(
    [string]$Server  = 'family-brain.boder.de',
    [string]$User    = 'root',
    [string]$KeyFile = 'D:\bjoer\OneDrive\Bjoern\Source\family-brain\.ssh\id_ed25519'
)

function Invoke-SSH([string]$cmd) {
    & ssh -i $KeyFile -o 'StrictHostKeyChecking=no' -o 'ConnectTimeout=10' "$User@$Server" $cmd 2>&1
}

function Write-OK([string]$t)   { Write-Host "  [OK]  $t" -ForegroundColor Green  }
function Write-Err([string]$t)  { Write-Host "  [XX]  $t" -ForegroundColor Red    }
function Write-Warn([string]$t) { Write-Host "  [!!]  $t" -ForegroundColor Yellow }
function Write-Info([string]$t) { Write-Host "        $t" -ForegroundColor Gray   }
function Write-Head([string]$t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

# Verbindungstest
Write-Host "Verbinde mit $User@$Server ..." -ForegroundColor Yellow
if ((Invoke-SSH 'echo OK') -notcontains 'OK') {
    Write-Err "SSH-Verbindung fehlgeschlagen."
    exit 1
}
Write-OK "Verbindung OK"

# System
Write-Head "System"
Write-Info (Invoke-SSH 'uptime')
Write-Info (Invoke-SSH 'free -h | awk "NR==2{print \"RAM: \" $3 \" / \" $2}"')
$diskPct = [int]((Invoke-SSH 'df / | awk "NR==2{gsub(/%/,\"\",$5); print $5}"') | Select-Object -First 1)
if ($diskPct -ge 85) { Write-Warn "Disk: $diskPct% voll!" } else { Write-OK "Disk: $diskPct% belegt" }

# Docker - alle Container
Write-Head "Docker Container"
Invoke-SSH 'docker ps -a' | ForEach-Object { Write-Info $_ }

# Caddy
Write-Head "Caddy"
$caddy = Invoke-SSH 'docker ps --filter name=caddy --filter status=running -q'
if ($caddy) {
    $info = Invoke-SSH 'docker ps --filter name=caddy | tail -1'
    Write-OK $info
} else {
    Write-Err "Caddy laeuft NICHT!"
    Write-Info (Invoke-SSH 'docker ps -a --filter name=caddy | tail -1')
}

# Family-Brain
Write-Head "Family-Brain"
$fbLines = Invoke-SSH 'docker ps -a | grep family-brain'
if ($fbLines) {
    foreach ($line in $fbLines) {
        if ($line -match '\bUp\b') {
            Write-OK $line
        } else {
            Write-Err $line
            Write-Head "Letzte Logs"
            $name = ($line -split '\s+')[0]  # Container-ID, nicht Name
            # Name aus separatem Befehl holen
            $fbName = Invoke-SSH 'docker ps -a --filter name=family-brain --format "{{.Names}}"' 2>$null
            if (-not $fbName) { $fbName = $name }
            Invoke-SSH "docker logs $fbName --tail 10" | ForEach-Object { Write-Info $_ }
        }
    }
} else {
    Write-Warn "Kein family-brain Container gefunden."
}

# Systemd-Fehler (cloud-init ignorieren)
Write-Head "Systemd"
$failed = Invoke-SSH 'systemctl --failed --no-legend' | Where-Object { $_ -notmatch 'cloud-init' }
if ($failed) { Write-Warn "Fehlgeschlagen: $($failed -join ', ')" } else { Write-OK "Keine Fehler" }

Write-Host ""
