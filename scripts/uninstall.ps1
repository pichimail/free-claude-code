param(
    [switch] $DryRun,
    [switch] $Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]] $RemainingArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PackageName = "chinna-free-claude"
$CfcHomeDirname = ".cfc"
$CfcCommands = @(
    "cfc-server",
    "cfc-claude",
    "cfc-codex",
    "cfc-init",
    "chinna-free-claude"
)

function Show-Usage {
    @"
Usage: uninstall.ps1 [options]

Removes the Chinna-Free-Claude uv tool and deletes ~/.cfc/.
Does not remove uv, Claude Code, Codex, or the uv-managed Python runtime.

Options:
  -DryRun                Print commands without running them.
  -Help                  Show this help text.
"@
}

function Write-Step {
    param([string] $Message)

    Write-Host ""
    Write-Host "==> $Message"
}

function Format-Argument {
    param([string] $Value)

    if ($Value -match '^[A-Za-z0-9_./:@%+=,\[\]-]+$') {
        return $Value
    }

    return "'" + ($Value -replace "'", "''") + "'"
}

function Test-MissingUvToolError {
    param([string] $Output)

    $normalized = $Output.ToLowerInvariant()
    return (
        $normalized.Contains("not installed") -or
        $normalized.Contains("no tool") -or
        $normalized.Contains("nothing to uninstall")
    )
}

function Add-PathEntry {
    param([string] $PathEntry)

    if ([string]::IsNullOrWhiteSpace($PathEntry)) {
        return
    }

    $separator = [IO.Path]::PathSeparator
    $entries = @()
    if (-not [string]::IsNullOrEmpty($env:Path)) {
        $entries = $env:Path -split [regex]::Escape([string] $separator)
    }

    if ($entries -notcontains $PathEntry) {
        $env:Path = "$PathEntry$separator$env:Path"
    }
}

function Add-UvToPath {
    Add-PathEntry (Join-Path $HOME ".local\bin")
    Add-PathEntry (Join-Path $HOME ".cargo\bin")
}

function Assert-NoCfcProcessesRunning {
    $running = @()

    foreach ($commandName in $CfcCommands) {
        $processes = @(Get-Process -Name $commandName -ErrorAction SilentlyContinue)
        if ($processes.Count -gt 0) {
            $running += $commandName
        }
    }

    if ($running.Count -gt 0) {
        throw "Chinna-Free-Claude is still running ($($running -join ', ')). Stop those processes, then rerun uninstall."
    }
}

function Uninstall-ChinnaFreeClaude {
    Add-UvToPath

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host "uv not found on PATH; skipping uv tool uninstall."
        return
    }

    Write-Host "+ uv tool uninstall $PackageName"
    if (-not $DryRun) {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            $output = (& uv tool uninstall $PackageName 2>&1 | Out-String).Trim()
            $exitCode = $LASTEXITCODE
            if ($exitCode -eq 0) {
                return
            }
            if (Test-MissingUvToolError -Output $output) {
                Write-Host "Chinna-Free-Claude uv tool not installed or already removed; skipping uv tool uninstall."
                return
            }
            if (-not [string]::IsNullOrWhiteSpace($output)) {
                [Console]::Error.WriteLine($output)
            }
            throw "uv tool uninstall $PackageName failed with exit code $exitCode; aborting before deleting ~/.cfc."
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
    }
}

function Purge-CfcHome {
    $cfcHome = Join-Path $HOME $CfcHomeDirname
    if (-not (Test-Path -LiteralPath $cfcHome)) {
        Write-Host "No FCC config directory at $cfcHome; skipping purge."
        return
    }

    $commandText = @(
        "Remove-Item",
        "-LiteralPath",
        (Format-Argument $cfcHome),
        "-Recurse",
        "-Force"
    ) -join " "
    Write-Host "+ $commandText"

    if (-not $DryRun) {
        Remove-Item -LiteralPath $cfcHome -Recurse -Force
    }
}

if ($Help) {
    Show-Usage
    return
}

if ($RemainingArgs.Count -gt 0) {
    Show-Usage
    throw "Unknown option: $($RemainingArgs -join ' ')"
}

Write-Step "Checking for running Chinna-Free-Claude processes"
Assert-NoCfcProcessesRunning

Write-Step "Removing Chinna-Free-Claude uv tool"
Uninstall-ChinnaFreeClaude

Write-Step "Purging FCC config and data from ~/.cfc"
Purge-CfcHome

Write-Host ""
Write-Host "Chinna-Free-Claude has been removed."
Write-Host "uv, Claude Code, Codex, and the uv-managed Python runtime were left installed."
