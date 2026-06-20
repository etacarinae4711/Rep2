#Requires -Version 5.1
<#
.SYNOPSIS
    Identifiziert Duplikat-Fotos die in _Diverse Ordnern UND in nicht-Diverse Ordnern liegen.
    Jaehrliche interaktive Bereinigung.

.PARAMETER CsvPath
    Pfad zur CSV-Datei (photo_scan_*.csv)

.PARAMETER WhatIf
    Nur anzeigen, nichts loeschen oder verschieben.
#>
param(
    [string]$CsvPath = "D:\Source\Sonstiges\photo_scan_20260527_073124.csv",
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Farb-Hilfsfunktionen ────────────────────────────────────────────────────
function Write-Header($text) {
    Write-Host "`n$('═' * 70)" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "$('═' * 70)" -ForegroundColor Cyan
}
function Write-DivLine() { Write-Host $('─' * 70) -ForegroundColor DarkGray }

# ── CSV laden ───────────────────────────────────────────────────────────────
Write-Host "Lade CSV: $CsvPath ..." -ForegroundColor Yellow

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV nicht gefunden: $CsvPath"
    exit 1
}

# Die CSV hat im ersten Feld einen mehrzeiligen Kommentar als Spaltentitel –
# wir lesen die Rohdaten und extrahieren ab der Zeile mit 'FilePath'.
$rawLines = Get-Content $CsvPath -Encoding UTF8

# Kopfzeile finden (enthaelt 'FilePath;FileName')
$headerIdx = -1
for ($i = 0; $i -lt $rawLines.Count; $i++) {
    if ($rawLines[$i] -match 'FilePath;FileName') {
        $headerIdx = $i
        break
    }
}
if ($headerIdx -lt 0) {
    # Fallback: erste Zeile ohne fuehrendes " als Header versuchen
    $headerIdx = 0
}

# Ab Headerzeile als CSV einlesen
$csvContent = $rawLines[$headerIdx..($rawLines.Count - 1)] | Out-String
$allRows = ConvertFrom-Csv -InputObject $csvContent -Delimiter ';'

Write-Host "  $($allRows.Count) Eintraege geladen." -ForegroundColor Green

# ── Nur Hash-Duplikate behalten ─────────────────────────────────────────────
$dupRows = $allRows | Where-Object { $_.Hash_IsDuplicate -eq 'True' -and $_.FilePath -ne '' }
Write-Host "  $($dupRows.Count) Zeilen mit Hash-Duplikaten." -ForegroundColor Green

# ── Hilfsfunktion: ist ein Pfad ein Diverse-Ordner? ─────────────────────────
function Test-IsDiverse([string]$path) {
    # Passt auf Z:\beva\JJJJ\JJJJ_Diverse oder JJJJ_diverse (auch Unterordner)
    return $path -match '[/\\]\d{4}[_\- ](?i)Diverse([/\\]|$)'
}

# ── Duplikat-Gruppen bilden (nach Hash) ─────────────────────────────────────
# Jede Gruppe = alle Dateien mit gleichem Hash
$groups = $dupRows | Group-Object -Property Hash

# Nur Gruppen behalten, die MINDESTENS eine Diverse-Datei UND
# mindestens eine Nicht-Diverse-Datei enthalten
$interestingGroups = @()
foreach ($g in $groups) {
    $diverse    = @($g.Group | Where-Object { Test-IsDiverse $_.FilePath })
    $nonDiverse = @($g.Group | Where-Object { -not (Test-IsDiverse $_.FilePath) })
    if ($diverse.Count -gt 0 -and $nonDiverse.Count -gt 0) {
        $interestingGroups += [PSCustomObject]@{
            Hash        = $g.Name
            Diverse     = $diverse
            NonDiverse  = $nonDiverse
            FolderYear  = ($g.Group | Select-Object -First 1).FolderYear
        }
    }
}

Write-Host "  $($interestingGroups.Count) Gruppen: Diverse-Kopie UND nicht-Diverse-Kopie vorhanden." -ForegroundColor Green

if ($interestingGroups.Count -eq 0) {
    Write-Host "`nKeine relevanten Duplikate gefunden. Fertig." -ForegroundColor Green
    exit 0
}

# ── Nach Jahr gruppieren ─────────────────────────────────────────────────────
$byYear = $interestingGroups | Group-Object -Property FolderYear | Sort-Object Name

# ── Protokoll-Liste (fuer spaetere Ausfuehrung) ──────────────────────────────
$pendingActions = [System.Collections.Generic.List[PSCustomObject]]::new()

# ── Jahres-Schleife ──────────────────────────────────────────────────────────
foreach ($yearGroup in $byYear) {
    $year   = $yearGroup.Name
    $groups = $yearGroup.Group

    Write-Header "Jahr $year  –  $($groups.Count) Duplikat-Gruppen"

    # Jahres-Zusammenfassung
    $totalDiverseFiles    = ($groups | ForEach-Object { $_.Diverse.Count    } | Measure-Object -Sum).Sum
    $totalNonDiverseFiles = ($groups | ForEach-Object { $_.NonDiverse.Count } | Measure-Object -Sum).Sum
    Write-Host ("  Diverse-Kopien:      {0,4}" -f $totalDiverseFiles)   -ForegroundColor Magenta
    Write-Host ("  Nicht-Diverse-Kopien:{0,4}" -f $totalNonDiverseFiles) -ForegroundColor White
    Write-DivLine

    # Gruppen auflisten
    $idx = 1
    foreach ($grp in $groups) {
        Write-Host "`n  Gruppe $idx/$($groups.Count)  [Hash: $($grp.Hash.Substring(0,12))...]" -ForegroundColor Yellow

        Write-Host "    DIVERSE (Kandidat zum Loeschen):" -ForegroundColor Magenta
        foreach ($f in $grp.Diverse) {
            $size = [math]::Round([double]$f.FileSizeBytes / 1MB, 2)
            Write-Host "      [-D-]  $($f.FilePath)  ($size MB)" -ForegroundColor Magenta
        }

        Write-Host "    NICHT-DIVERSE (behalten):" -ForegroundColor Green
        foreach ($f in $grp.NonDiverse) {
            $size = [math]::Round([double]$f.FileSizeBytes / 1MB, 2)
            Write-Host "      [===]  $($f.FilePath)  ($size MB)" -ForegroundColor Green
        }
        $idx++
    }

    # ── Jahres-Menü ─────────────────────────────────────────────────────────
    Write-DivLine
    Write-Host "`n  Was soll fuer Jahr $year gemacht werden?" -ForegroundColor Cyan
    Write-Host "    [L] Alle Diverse-Kopien dieses Jahres LOESCHEN" -ForegroundColor Red
    Write-Host "    [V] Alle Diverse-Kopien dieses Jahres in _Geloescht-Ordner VERSCHIEBEN" -ForegroundColor DarkYellow
    Write-Host "    [E] Einzeln entscheiden (Gruppe fuer Gruppe)" -ForegroundColor White
    Write-Host "    [U] Ueberspringen (nichts tun)" -ForegroundColor DarkGray
    Write-Host "    [Q] Abbrechen und alle bisher geplanten Aktionen ausfuehren" -ForegroundColor DarkRed
    Write-Host ""

    $choice = ''
    while ($choice -notin @('L','V','E','U','Q')) {
        $choice = (Read-Host "  Eingabe").Trim().ToUpper()
    }

    switch ($choice) {
        'Q' {
            Write-Host "`nAbbruch. Fuehre bisher geplante Aktionen aus..." -ForegroundColor Yellow
            break
        }
        'U' {
            Write-Host "  Uebersprungen." -ForegroundColor DarkGray
            continue
        }
        'L' {
            foreach ($grp in $groups) {
                foreach ($f in $grp.Diverse) {
                    $pendingActions.Add([PSCustomObject]@{
                        Action = 'Delete'; FilePath = $f.FilePath; Year = $year
                    })
                }
            }
            Write-Host "  $($groups | ForEach-Object { $_.Diverse.Count } | Measure-Object -Sum | Select-Object -ExpandProperty Sum) Dateien zum Loeschen vorgemerkt." -ForegroundColor Red
        }
        'V' {
            foreach ($grp in $groups) {
                foreach ($f in $grp.Diverse) {
                    $pendingActions.Add([PSCustomObject]@{
                        Action = 'Move'; FilePath = $f.FilePath; Year = $year
                    })
                }
            }
            Write-Host "  $($groups | ForEach-Object { $_.Diverse.Count } | Measure-Object -Sum | Select-Object -ExpandProperty Sum) Dateien zum Verschieben vorgemerkt." -ForegroundColor DarkYellow
        }
        'E' {
            # Einzeln entscheiden
            $subIdx = 1
            foreach ($grp in $groups) {
                Write-Host "`n  ── Gruppe $subIdx/$($groups.Count) ──" -ForegroundColor Yellow
                Write-Host "    DIVERSE:" -ForegroundColor Magenta
                foreach ($f in $grp.Diverse) {
                    Write-Host "      $($f.FilePath)" -ForegroundColor Magenta
                }
                Write-Host "    BEHALTEN:" -ForegroundColor Green
                foreach ($f in $grp.NonDiverse) {
                    Write-Host "      $($f.FilePath)" -ForegroundColor Green
                }
                Write-Host "    [L]oeschen  [V]erschieben  [U]eberspringen"
                $sub = ''
                while ($sub -notin @('L','V','U')) {
                    $sub = (Read-Host "    Eingabe").Trim().ToUpper()
                }
                if ($sub -ne 'U') {
                    $action = if ($sub -eq 'L') { 'Delete' } else { 'Move' }
                    foreach ($f in $grp.Diverse) {
                        $pendingActions.Add([PSCustomObject]@{
                            Action = $action; FilePath = $f.FilePath; Year = $year
                        })
                    }
                }
                $subIdx++
            }
        }
    }

    if ($choice -eq 'Q') { break }
}

# ── Zusammenfassung & Ausfuehren ─────────────────────────────────────────────
Write-Header "Zusammenfassung der geplanten Aktionen"

if ($pendingActions.Count -eq 0) {
    Write-Host "  Keine Aktionen geplant. Fertig." -ForegroundColor Green
    exit 0
}

$toDelete = @($pendingActions | Where-Object { $_.Action -eq 'Delete' })
$toMove   = @($pendingActions | Where-Object { $_.Action -eq 'Move'   })

Write-Host "  Loeschen:    $($toDelete.Count) Dateien" -ForegroundColor Red
Write-Host "  Verschieben: $($toMove.Count) Dateien"   -ForegroundColor DarkYellow

if ($WhatIf) {
    Write-Host "`n  [WhatIf-Modus] Keine echten Aenderungen." -ForegroundColor Cyan
    $pendingActions | ForEach-Object {
        Write-Host "    $($_.Action.PadRight(6))  $($_.FilePath)" -ForegroundColor DarkGray
    }
    exit 0
}

Write-Host ""
$confirm = Read-Host "  Jetzt wirklich ausfuehren? (ja/nein)"
if ($confirm.Trim().ToLower() -ne 'ja') {
    Write-Host "  Abgebrochen. Keine Aenderungen vorgenommen." -ForegroundColor DarkGray
    exit 0
}

# ── Loeschen ─────────────────────────────────────────────────────────────────
$delOk = 0; $delErr = 0
foreach ($item in $toDelete) {
    try {
        if (Test-Path $item.FilePath) {
            Remove-Item $item.FilePath -Force
            Write-Host "  GELOESCHT: $($item.FilePath)" -ForegroundColor Red
            $delOk++
        } else {
            Write-Host "  NICHT GEFUNDEN (uebersprungen): $($item.FilePath)" -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "  FEHLER beim Loeschen: $($item.FilePath) – $_" -ForegroundColor DarkRed
        $delErr++
    }
}

# ── Verschieben ───────────────────────────────────────────────────────────────
$movOk = 0; $movErr = 0
foreach ($item in $toMove) {
    try {
        if (-not (Test-Path $item.FilePath)) {
            Write-Host "  NICHT GEFUNDEN (uebersprungen): $($item.FilePath)" -ForegroundColor DarkGray
            continue
        }
        # Ziel: im selben Jahres-Ordner einen _Geloescht Unterordner anlegen
        $fileObj  = Get-Item $item.FilePath
        # Jahres-Stammordner = Z:\beva\JJJJ
        $yearRoot = "Z:\beva\$($item.Year)"
        $destDir  = Join-Path $yearRoot "_Geloescht_Diverse_Duplikate"
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        $destPath = Join-Path $destDir $fileObj.Name
        # Bei Namenskollision Zahl anhaengen
        if (Test-Path $destPath) {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($fileObj.Name)
            $ext  = $fileObj.Extension
            $n    = 1
            do { $destPath = Join-Path $destDir "$base`_$n$ext"; $n++ }
            while (Test-Path $destPath)
        }
        Move-Item $item.FilePath $destPath -Force
        Write-Host "  VERSCHOBEN: $($item.FilePath)" -ForegroundColor DarkYellow
        Write-Host "          -> $destPath" -ForegroundColor DarkYellow
        $movOk++
    } catch {
        Write-Host "  FEHLER beim Verschieben: $($item.FilePath) – $_" -ForegroundColor DarkRed
        $movErr++
    }
}

# ── Abschluss ────────────────────────────────────────────────────────────────
Write-Header "Fertig"
Write-Host "  Geloescht:    $delOk OK  /  $delErr Fehler" -ForegroundColor $(if ($delErr -gt 0) {'Red'} else {'Green'})
Write-Host "  Verschoben:   $movOk OK  /  $movErr Fehler" -ForegroundColor $(if ($movErr -gt 0) {'Red'} else {'Green'})
Write-Host ""
