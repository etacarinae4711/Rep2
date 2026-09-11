#Requires -Version 5.1
<#
.SYNOPSIS
    Verbindet sich per SSH zum Hetzner-Server und prueft den Status
    von Docker-Containern (family-brain, Caddy, MCP) sowie System-Gesundheit.

.PARAMETER Server
    Hostname oder IP-Adresse des Hetzner-Servers

.PARAMETER User
    SSH-Benutzername (Standard: root)

.PARAMETER KeyFile
    Pfad zum privaten SSH-Schluessel (optional, z.B. ~/.ssh/id_rsa)
#>
param(
    [string]$Server  = 'family-brain.boder.de',
    [string]$User    = 'root',
    [string]$KeyFile = 'D:\bjoer\OneDrive\Bjoern\Source\family-brain\.ssh\id_ed25519'
)

# ── SSH-Hilfsfunktion ────────────────────────────────────────────────────────
function Invoke-SSH([string]$command) {
    $result = & ssh -i $KeyFile -o 'StrictHostKeyChecking=no' -o 'ConnectTimeout=10' "$User@$Server" $command 2>&1
    return $result
}

# ── Farb-Hilfsfunktionen ─────────────────────────────────────────────────────
function Write-Header([string]$text) {
    Write-Host "`n$('═' * 60)" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "$('═' * 60)" -ForegroundColor Cyan
}

function Write-OK([string]$text)   { Write-Host "  [OK]  $text" -ForegroundColor Green    }
function Write-Warn([string]$text) { Write-Host "  [!!]  $text" -ForegroundColor Yellow   }
function Write-Err([string]$text)  { Write-Host "  [XX]  $text" -ForegroundColor Red      }
function Write-Info([string]$text) { Write-Host "        $text" -ForegroundColor DarkGray }

# ── Verbindung testen ────────────────────────────────────────────────────────
Write-Host "`nVerbinde mit $User@$Server ..." -ForegroundColor Yellow
$ping = Invoke-SSH 'echo OK'
if ($ping -notcontains 'OK') {
    Write-Err "SSH-Verbindung fehlgeschlagen. Server erreichbar?"
    exit 1
}
Write-OK "SSH-Verbindung erfolgreich."

# ════════════════════════════════════════════════════════════════════════════
# 1. SYSTEM-ÜBERSICHT
# ════════════════════════════════════════════════════════════════════════════
Write-Header "System-Gesundheit"

$uptime  = Invoke-SSH 'uptime -p'
$loadAvg = Invoke-SSH "cat /proc/loadavg | awk '{print $1, $2, $3}'"
$ram     = Invoke-SSH "free -h | awk 'NR==2{printf \"Gesamt: %s  Genutzt: %s  Frei: %s\", $2, $3, $4}'"
$disk    = Invoke-SSH "df -h / | awk 'NR==2{printf \"Genutzt: %s von %s (%s)\", $3, $2, $5}'"

Write-Info "Uptime:    $uptime"
Write-Info "Load:      $loadAvg  (1/5/15 Min)"
Write-Info "RAM:       $ram"
Write-Info "Disk /:    $disk"

# Warnung bei hoher Disk-Nutzung
$diskPct = Invoke-SSH "df / | awk 'NR==2{print $5}' | tr -d '%'"
if ([int]$diskPct -ge 85) {
    Write-Warn "Festplatte zu $diskPct% voll!"
} else {
    Write-OK "Festplatte OK ($diskPct% belegt)"
}

# ════════════════════════════════════════════════════════════════════════════
# 2. DOCKER-CONTAINER
# ════════════════════════════════════════════════════════════════════════════
Write-Header "Docker Container"

$dockerRunning = Invoke-SSH 'docker info >/dev/null 2>&1 && echo YES || echo NO'
if ($dockerRunning -notcontains 'YES') {
    Write-Err "Docker läuft NICHT oder kein Zugriff."
} else {
    Write-OK "Docker Daemon läuft."

    # Alle Container auflisten
    $containers = Invoke-SSH 'docker ps --format "{{.Names}}|{{.Status}}|{{.Ports}}" 2>/dev/null'

    if (-not $containers) {
        Write-Warn "Keine laufenden Container gefunden."
    } else {
        Write-Host ""
        Write-Host ("  {0,-35} {1,-20} {2}" -f "NAME", "STATUS", "PORTS") -ForegroundColor DarkCyan
        Write-Host ("  {0}" -f ('-' * 58))                                 -ForegroundColor DarkGray

        foreach ($line in $containers) {
            $parts  = $line -split '\|'
            $name   = $parts[0]
            $status = $parts[1]
            $ports  = if ($parts.Count -gt 2) { $parts[2] } else { '' }

            # Farbe je nach Status
            if ($status -match '^Up') {
                $color = 'Green'
                $icon  = '[OK]'
            } else {
                $color = 'Red'
                $icon  = '[XX]'
            }
            Write-Host ("  $icon {0,-32} {1,-20} {2}" -f $name, $status, $ports) -ForegroundColor $color
        }
    }

    # Gestoppte Container extra anzeigen
    $stopped = Invoke-SSH 'docker ps -a --filter "status=exited" --format "{{.Names}}|{{.Status}}" 2>/dev/null'
    if ($stopped) {
        Write-Host ""
        Write-Warn "Gestoppte Container:"
        foreach ($line in $stopped) {
            $parts = $line -split '\|'
            Write-Info "  $($parts[0])  –  $($parts[1])"
        }
    }
}

# ════════════════════════════════════════════════════════════════════════════
# 3. CADDY
# ════════════════════════════════════════════════════════════════════════════
Write-Header "Caddy Webserver"

# Caddy als systemd-Dienst?
$caddyService = Invoke-SSH 'systemctl is-active caddy 2>/dev/null'
# Caddy als Docker-Container?
$caddyDocker  = Invoke-SSH 'docker ps --filter "name=caddy" --format "{{.Names}}|{{.Status}}" 2>/dev/null'

if ($caddyService -eq 'active') {
    Write-OK "Caddy systemd-Dienst: aktiv"
} elseif ($caddyDocker) {
    foreach ($line in $caddyDocker) {
        $parts = $line -split '\|'
        if ($parts[1] -match '^Up') {
            Write-OK "Caddy Docker-Container: $($parts[0]) – $($parts[1])"
        } else {
            Write-Err "Caddy Docker-Container gestoppt: $($parts[0]) – $($parts[1])"
        }
    }
} else {
    Write-Err "Caddy nicht gefunden (weder systemd noch Docker)."
}

# ════════════════════════════════════════════════════════════════════════════
# 4. FAMILY-BRAIN
# ════════════════════════════════════════════════════════════════════════════
Write-Header "Family-Brain"

$fbContainers = Invoke-SSH 'docker ps -a --filter "name=family-brain" --format "{{.Names}}|{{.Status}}|{{.Ports}}" 2>/dev/null'

if ($fbContainers) {
    foreach ($line in $fbContainers) {
        $parts  = $line -split '\|'
        $name   = $parts[0]
        $status = $parts[1]
        $ports  = if ($parts.Count -gt 2) { $parts[2] } else { '' }
        if ($status -match '^Up') {
            Write-OK "$name  –  $status"
            if ($ports) { Write-Info "Ports: $ports" }
        } else {
            Write-Err "$name  –  $status (gestoppt!)"
            # Letzte Logzeilen bei Fehler
            Write-Host "  Letzte Logs:" -ForegroundColor DarkYellow
            $logs = Invoke-SSH "docker logs $name --tail 10 2>&1"
            $logs | ForEach-Object { Write-Info "    $_" }
        }
    }
} else {
    Write-Warn "Kein family-brain Container gefunden."
}

# ════════════════════════════════════════════════════════════════════════════
# 5. SYSTEMD FEHLER
# ════════════════════════════════════════════════════════════════════════════
Write-Header "Systemd Fehler"

$failed = Invoke-SSH 'systemctl --failed --no-legend 2>/dev/null'
if ($failed -and $failed.Trim() -ne '') {
    Write-Err "Fehlgeschlagene Dienste:"
    $failed | ForEach-Object { Write-Info "  $_" }
} else {
    Write-OK "Keine fehlgeschlagenen systemd-Dienste."
}

# ════════════════════════════════════════════════════════════════════════════
# ABSCHLUSS
# ════════════════════════════════════════════════════════════════════════════
Write-Host "`n$('═' * 60)" -ForegroundColor Cyan
Write-Host "  Pruefung abgeschlossen – $Server" -ForegroundColor Cyan
Write-Host "$('═' * 60)`n" -ForegroundColor Cyan
