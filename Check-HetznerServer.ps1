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
function Write-Head([string]$t) {
    Write-Host "`n=== $t ===" -ForegroundColor Cyan
}

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
Write-Info (Invoke-SSH "free -h | awk 'NR==2{print ""RAM: "" `$3 "" / "" `$2}'")
$diskPct = [int]((Invoke-SSH "df / | awk 'NR==2{print `$5}' | tr -d '%'") -replace '\D')
if ($diskPct -ge 85) { Write-Warn "Disk: $diskPct% voll!" } else { Write-OK "Disk: $diskPct% belegt" }

# Docker
Write-Head "Docker Container"
$containers = Invoke-SSH 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
$containers | ForEach-Object { Write-Info $_ }

$stopped = Invoke-SSH 'docker ps -a --filter status=exited --format "{{.Names}}"'
if ($stopped) {
    Write-Warn "Gestoppt: $($stopped -join ', ')"
}

# Caddy
Write-Head "Caddy"
$caddy = Invoke-SSH 'docker ps --filter name=caddy --format "{{.Names}} | {{.Status}}"'
if ($caddy) { Write-OK $caddy } else { Write-Err "Caddy nicht gefunden!" }

# Family-Brain
Write-Head "Family-Brain"
$fb = Invoke-SSH 'docker ps -a --filter name=family-brain --format "{{.Names}} | {{.Status}}"'
if ($fb) {
    foreach ($line in $fb) {
        if ($line -match 'Up') { Write-OK $line } else {
            Write-Err $line
            Write-Info "--- Letzte Logs ---"
            $name = ($line -split '\|')[0].Trim()
            Invoke-SSH "docker logs $name --tail 10" | ForEach-Object { Write-Info $_ }
        }
    }
} else { Write-Warn "Kein family-brain Container gefunden." }

# Systemd-Fehler
Write-Head "Systemd"
$failed = Invoke-SSH 'systemctl --failed --no-legend'
if ($failed -and $failed.Trim()) { Write-Err "Fehlgeschlagen: $failed" } else { Write-OK "Keine Fehler" }

Write-Host ""
