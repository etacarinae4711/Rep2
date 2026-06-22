#Requires -Version 5.1
<#
.SYNOPSIS
    Verschiebt Inhalte aus JJJJ_Diverse-Ordnern nach Z:\_Sammlungen\Quarantaene\Diverse
    und behaelt dabei die Unterordner-Struktur bei.
    Pro Quellordner wird einzeln Ja/Nein gefragt.

.PARAMETER SourceRoot
    Wurzelpfad der Foto-Sammlung (Standard: Z:\beva)

.PARAMETER QuarantaeneRoot
    Ziel-Wurzelpfad fuer verschobene Dateien (Standard: Z:\_Sammlungen\Quarantaene\Diverse)

.PARAMETER WhatIf
    Nur anzeigen, nichts verschieben.
#>
param(
    [string]$SourceRoot      = 'Z:\beva',
    [string]$QuarantaeneRoot = 'Z:\_Sammlungen\Quarantaene\Diverse',
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Farb-Hilfsfunktionen ────────────────────────────────────────────────────
function Write-Header([string]$text) {
    Write-Host "`n$('═' * 70)" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "$('═' * 70)" -ForegroundColor Cyan
}

function Write-DivLine() {
    Write-Host $('─' * 70) -ForegroundColor DarkGray
}

function Ask-YesNo([string]$question) {
    while ($true) {
        $a = (Read-Host "  $question [ja/nein]").Trim().ToLower()
        if ($a -in @('ja','j','yes','y')) { return $true  }
        if ($a -in @('nein','n','no'))    { return $false }
        Write-Host "  Bitte 'ja' oder 'nein' eingeben." -ForegroundColor DarkYellow
    }
}

# ── Quellpfad pruefen ────────────────────────────────────────────────────────
if (-not (Test-Path $SourceRoot)) {
    Write-Error "Quellpfad nicht gefunden: $SourceRoot"
    exit 1
}

Write-Header "Diverse-Ordner Quarantaene"
Write-Host "  Quelle:     $SourceRoot"       -ForegroundColor White
Write-Host "  Quarantaene: $QuarantaeneRoot" -ForegroundColor DarkYellow
if ($WhatIf) {
    Write-Host "  [WhatIf] Kein echter Schreibzugriff." -ForegroundColor Cyan
}

# ── Alle _Diverse-Ordner finden (sortiert nach Pfad) ────────────────────────
# Muster: Z:\beva\JJJJ\JJJJ_Diverse  (und etwaige Unterordner davon)
$diverseFolders = Get-ChildItem -Path $SourceRoot -Recurse -Directory `
    | Where-Object { $_.Name -match '^\d{4}[_\- ](?i)Diverse$' } `
    | Sort-Object FullName

if ($diverseFolders.Count -eq 0) {
    Write-Host "`n  Keine _Diverse-Ordner gefunden. Fertig." -ForegroundColor Green
    exit 0
}

Write-Host "  $($diverseFolders.Count) Diverse-Ordner gefunden.`n" -ForegroundColor Green

# ── Statistik ────────────────────────────────────────────────────────────────
$totalMoved  = 0
$totalSkipped= 0
$totalErrors = 0

# ── Ordner-Schleife ──────────────────────────────────────────────────────────
$folderIdx = 1
foreach ($folder in $diverseFolders) {

    Write-DivLine
    Write-Host ("  [{0}/{1}]  {2}" -f $folderIdx, $diverseFolders.Count, $folder.FullName) `
        -ForegroundColor Yellow

    # Alle Dateien rekursiv im Ordner
    $files = @(Get-ChildItem -Path $folder.FullName -Recurse -File)

    if ($files.Count -eq 0) {
        Write-Host "  (leer – uebersprungen)" -ForegroundColor DarkGray
        $folderIdx++
        continue
    }

    # Groesse berechnen
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    $totalMB    = [math]::Round($totalBytes / 1MB, 1)

    Write-Host ("  {0} Dateien  |  {1} MB" -f $files.Count, $totalMB) -ForegroundColor White

    # Erste paar Dateien anzeigen
    $preview = $files | Select-Object -First 5
    foreach ($f in $preview) {
        $rel = $f.FullName.Substring($folder.FullName.Length)
        Write-Host ("    {0}" -f $rel) -ForegroundColor DarkGray
    }
    if ($files.Count -gt 5) {
        Write-Host ("    ... und {0} weitere" -f ($files.Count - 5)) -ForegroundColor DarkGray
    }

    # Zielpfad berechnen und anzeigen
    # Relativer Pfad: alles ab SourceRoot
    $relFolder = $folder.FullName.Substring($SourceRoot.TrimEnd('\').Length).TrimStart('\')
    $destFolder = Join-Path $QuarantaeneRoot $relFolder

    Write-Host "  Ziel: $destFolder" -ForegroundColor DarkYellow

    # Benutzer fragen
    $doMove = Ask-YesNo "Diesen Ordner verschieben?"

    if (-not $doMove) {
        Write-Host "  Uebersprungen." -ForegroundColor DarkGray
        $totalSkipped += $files.Count
        $folderIdx++
        continue
    }

    # ── Dateien verschieben ──────────────────────────────────────────────────
    $movedCount = 0
    $errorCount = 0

    foreach ($file in $files) {
        # Relativen Pfad der Datei innerhalb des SourceRoot errechnen
        $relFile  = $file.FullName.Substring($SourceRoot.TrimEnd('\').Length).TrimStart('\')
        $destFile = Join-Path $QuarantaeneRoot $relFile
        $destDir  = Split-Path $destFile -Parent

        if ($WhatIf) {
            Write-Host "  [WhatIf] VERSCHIEBE: $($file.FullName)" -ForegroundColor DarkCyan
            Write-Host "                   -> $destFile"           -ForegroundColor DarkCyan
            $movedCount++
            continue
        }

        try {
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }

            # Namenskollision abfangen
            if (Test-Path $destFile) {
                $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $ext  = $file.Extension
                $n    = 1
                do {
                    $destFile = Join-Path $destDir "$base`_$n$ext"
                    $n++
                } while (Test-Path $destFile)
            }

            Move-Item -Path $file.FullName -Destination $destFile -Force
            $movedCount++
        }
        catch {
            Write-Host "  FEHLER: $($file.FullName) – $_" -ForegroundColor Red
            $errorCount++
        }
    }

    Write-Host ("  Verschoben: {0}  Fehler: {1}" -f $movedCount, $errorCount) `
        -ForegroundColor $(if ($errorCount -gt 0) { 'Red' } else { 'Green' })

    $totalMoved  += $movedCount
    $totalErrors += $errorCount
    $folderIdx++
}

# ── Abschluss ────────────────────────────────────────────────────────────────
Write-Header "Fertig"
Write-Host ("  Verschoben:   {0} Dateien" -f $totalMoved)  -ForegroundColor Green
Write-Host ("  Uebersprungen:{0} Dateien" -f $totalSkipped) -ForegroundColor DarkGray
Write-Host ("  Fehler:       {0}"         -f $totalErrors)  `
    -ForegroundColor $(if ($totalErrors -gt 0) { 'Red' } else { 'Green' })
Write-Host ""
