param(
    [Parameter(Mandatory = $true)]
    [string]$CommitMessage,

    [string[]]$Files,

    [switch]$StageAll
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repoRoot

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    Write-Host "git $($Args -join ' ')"
    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: git $($Args -join ' ')"
    }
}

function Get-GitOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    $output = & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: git $($Args -join ' ')"
    }

    return ($output | Out-String).Trim()
}

$branch = Get-GitOutput @("branch", "--show-current")
if (-not $branch) {
    throw "Nao foi possivel identificar o branch atual."
}

if ($branch -eq "main") {
    throw "Execute este script a partir de um branch de tarefa, nunca direto na main."
}

$statusBefore = Get-GitOutput @("status", "--short")
$hasChanges = -not [string]::IsNullOrWhiteSpace($statusBefore)

if (-not $hasChanges) {
    throw "Nao ha alteracoes para publicar."
}

if ($StageAll -and $Files) {
    throw "Use StageAll ou Files, nao os dois ao mesmo tempo."
}

Write-Host ""
Write-Host "Sincronizando com origin/main antes da publicacao..."
Invoke-Git @("fetch", "origin", "main")
Invoke-Git @("rebase", "--autostash", "origin/main")

if ($StageAll) {
    Invoke-Git @("add", "-A")
} elseif ($Files -and $Files.Count -gt 0) {
    $addArgs = @("add") + $Files
    Invoke-Git $addArgs
}

$statusAfterStage = Get-GitOutput @("status", "--short")
if ($statusAfterStage -match "^\?\?") {
    throw "Ainda existem arquivos nao rastreados. Informe Files ou use -StageAll se quiser inclui-los."
}

$cachedStatus = Get-GitOutput @("diff", "--cached", "--name-only")
if ([string]::IsNullOrWhiteSpace($cachedStatus)) {
    throw "Nao ha nada no staging para commitar."
}

Write-Host ""
Write-Host "Branch atual: $branch"
Write-Host "Arquivos no commit:"
$cachedStatus -split "`r?`n" | ForEach-Object {
    if ($_.Trim()) {
        Write-Host " - $_"
    }
}

Write-Host ""
Write-Host "Criando commit..."
Invoke-Git @("commit", "-m", $CommitMessage)

Write-Host ""
Write-Host "Enviando branch de tarefa..."
Invoke-Git @("push", "-u", "origin", $branch)

Write-Host ""
Write-Host "Atualizando main e fazendo merge fast-forward..."
Invoke-Git @("checkout", "main")
Invoke-Git @("pull", "--ff-only", "origin", "main")
Invoke-Git @("merge", "--ff-only", $branch)
Invoke-Git @("push", "origin", "main")

Write-Host ""
Write-Host "Publicacao concluida com sucesso."
Write-Host "Branch publicada: $branch"
Write-Host "Main atualizada no remoto."
