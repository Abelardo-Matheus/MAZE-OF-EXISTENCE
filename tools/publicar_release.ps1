<#
  Publica uma nova versao jogavel do Maze of Existence no GitHub Releases.
  Depois disso, o install.ps1 (e o comando de 1 linha do README) passam a baixar essa versao.

  Passo a passo:
    1. No GameMaker: alvo Windows (VM) > Build > Create Executable > "Package as Zip".
       (Tambem funciona com a pasta do build ou com o instalador .exe.)
    2. Na raiz do repositorio, no cmd:
         powershell -ExecutionPolicy Bypass -File tools\publicar_release.ps1 -Versao v1.1.0 -Build "C:\caminho\MAZE OF EXISTENCE.zip"
       Opcional: -Notas "texto das novidades"   -Rascunho (cria como draft)

  Requer o GitHub CLI (https://cli.github.com) logado: gh auth login
#>
param(
    [Parameter(Mandatory = $true)][string]$Versao,
    [Parameter(Mandatory = $true)][string]$Build,
    [string]$Notas = '',
    [switch]$Rascunho
)

$ErrorActionPreference = 'Stop'
$Repo = 'Abelardo-Matheus/MAZE-OF-EXISTENCE'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI (gh) nao encontrado. Instale com:  winget install --id GitHub.cli   e depois rode:  gh auth login'
}
gh auth status *> $null
if ($LASTEXITCODE -ne 0) { throw 'Voce nao esta logado no gh. Rode:  gh auth login' }

if (-not (Test-Path $Build)) { throw "Build nao encontrado: $Build" }
$item = Get-Item $Build
$out  = Join-Path $env:TEMP 'maze_release'
New-Item -ItemType Directory -Path $out -Force | Out-Null

if ($item.PSIsContainer) {
    # Pasta do build -> zip com nome fixo
    $asset = Join-Path $out 'MazeOfExistence-Windows.zip'
    if (Test-Path $asset) { Remove-Item $asset -Force }
    Write-Host "Compactando $($item.FullName) ..."
    Compress-Archive -Path (Join-Path $item.FullName '*') -DestinationPath $asset
} elseif ($item.Extension -eq '.zip') {
    $asset = Join-Path $out 'MazeOfExistence-Windows.zip'
    Copy-Item $item.FullName $asset -Force
} elseif ($item.Extension -eq '.exe') {
    $asset = Join-Path $out 'MazeOfExistence-Setup.exe'
    Copy-Item $item.FullName $asset -Force
} else {
    throw 'O build precisa ser uma pasta, um .zip ou um .exe.'
}

if (-not $Notas) { $Notas = "Versao $Versao do Maze of Existence. Instale pelo comando do README ou baixe o arquivo abaixo." }

$args_ = @('release', 'create', $Versao, $asset, '--repo', $Repo, '--title', "Maze of Existence $Versao", '--notes', $Notas)
if ($Rascunho) { $args_ += '--draft' }

Write-Host "Publicando $Versao em github.com/$Repo/releases ..."
gh @args_
if ($LASTEXITCODE -ne 0) { throw 'Falha ao criar a release.' }

Remove-Item $out -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Pronto! Link direto: https://github.com/$Repo/releases/latest/download/$(Split-Path $asset -Leaf)" -ForegroundColor Green
