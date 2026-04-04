$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repoRoot

Write-Host "Atualizando repositorio (origin/main)..."
git pull --ff-only origin main

$pythonCmd = $null

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCmd = "py"
} else {
    $pythonExe = Join-Path $env:LocalAppData "Programs\Python\Python312\python.exe"
    if (Test-Path -LiteralPath $pythonExe) {
        $pythonCmd = $pythonExe
    }
}

if (-not $pythonCmd) {
    throw "Python nao encontrado. Instale Python 3.12 e tente novamente."
}

Write-Host "Usando Python: $pythonCmd"
if ($pythonCmd -eq "python") {
    python --version
} elseif ($pythonCmd -eq "py") {
    py --version
} else {
    & $pythonCmd --version
}

Write-Host ""
Write-Host "Iniciando servidor local em http://127.0.0.1:8000"
Write-Host "Pressione Ctrl+C para encerrar."

if ($pythonCmd -eq "python") {
    python .\python.py
} elseif ($pythonCmd -eq "py") {
    py .\python.py
} else {
    & $pythonCmd .\python.py
}
