<#
  Maze of Existence - instalador para Windows
  ------------------------------------------------------------
  Baixa a versao mais recente publicada em GitHub Releases,
  instala em %LOCALAPPDATA%\Programs\MazeOfExistence, cria atalhos
  (Area de Trabalho e Menu Iniciar) e abre o jogo.

  Uso direto no cmd (sem clonar):
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Abelardo-Matheus/MAZE-OF-EXISTENCE/main/install.ps1 | iex"

  Uso a partir do repositorio clonado:
    install.cmd                 (instala a versao mais recente)
    install.cmd -Version v1.1.0 (instala uma versao especifica)
    install.cmd -NoLaunch       (instala sem abrir o jogo)
    install.cmd -Uninstall      (remove o jogo e os atalhos)
#>

function Install-MazeOfExistence {
    [CmdletBinding()]
    param(
        [string]$Version    = 'latest',
        [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\MazeOfExistence'),
        [switch]$NoShortcut,
        [switch]$NoLaunch,
        [switch]$Uninstall
    )

    $ErrorActionPreference = 'Stop'
    $ProgressPreference    = 'SilentlyContinue'   # deixa o download muito mais rapido no PowerShell 5
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Repo      = 'Abelardo-Matheus/MAZE-OF-EXISTENCE'
    $GameName  = 'Maze of Existence'
    $OldDemo   = 'https://drive.google.com/file/d/13MptVvlLx8gzgrO_MtDW82ynJM82T_KS/view?usp=sharing'
    $Desktop   = [Environment]::GetFolderPath('Desktop')
    $StartMenu = Join-Path ([Environment]::GetFolderPath('Programs')) $GameName
    $LinkName  = "$GameName.lnk"

    function Say([string]$msg, [string]$color = 'Cyan') { Write-Host "[Maze] $msg" -ForegroundColor $color }

    # ---------------- Desinstalar ----------------
    if ($Uninstall) {
        Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -and $_.Path.StartsWith($InstallDir, [StringComparison]::OrdinalIgnoreCase) } |
            Stop-Process -Force -ErrorAction SilentlyContinue
        foreach ($p in @($InstallDir, $StartMenu, (Join-Path $Desktop $LinkName))) {
            if (Test-Path $p) { Remove-Item $p -Recurse -Force; Say "Removido: $p" }
        }
        Say "$GameName foi desinstalado. (Seus saves em %LOCALAPPDATA% foram mantidos.)" 'Green'
        return
    }

    # ---------------- Encontrar a release ----------------
    $api = if ($Version -eq 'latest') { "https://api.github.com/repos/$Repo/releases/latest" }
           else { "https://api.github.com/repos/$Repo/releases/tags/$Version" }
    Say "Procurando a versao '$Version' em github.com/$Repo ..."
    try {
        $release = Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent' = 'maze-of-existence-installer' }
    } catch {
        Say "Nenhuma versao publicada foi encontrada (GitHub Releases)." 'Yellow'
        Say "Abrindo a demo antiga (Beta 1.0) no Google Drive para download manual..." 'Yellow'
        Start-Process $OldDemo
        return
    }

    # Preferencia: .zip (jogo portatil). Alternativa: .exe (instalador do GameMaker).
    $assets = @($release.assets)
    $asset  = $assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
    if (-not $asset) { $asset = $assets | Where-Object { $_.name -like '*.exe' } | Select-Object -First 1 }
    if (-not $asset) { throw "A release $($release.tag_name) nao tem nenhum arquivo .zip ou .exe para baixar." }

    $sizeMb = [math]::Round($asset.size / 1MB, 1)
    Say "Baixando $($asset.name) ($sizeMb MB) - versao $($release.tag_name) ..."
    $tmp = Join-Path $env:TEMP ("maze_" + [guid]::NewGuid().ToString('N') + [IO.Path]::GetExtension($asset.name))
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing

    # ---------------- Instalar ----------------
    if ($asset.name -like '*.exe') {
        Say 'Abrindo o instalador. Siga as instrucoes na tela...'
        Start-Process -FilePath $tmp -Wait
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        Say "Pronto! $GameName $($release.tag_name) instalado." 'Green'
        return
    }

    if (Test-Path $InstallDir) {
        Say 'Removendo a versao anterior...'
        Remove-Item $InstallDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Say "Extraindo para $InstallDir ..."
    Expand-Archive -Path $tmp -DestinationPath $InstallDir -Force
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue

    # Se o zip tiver uma unica pasta dentro, sobe o conteudo um nivel
    $top = @(Get-ChildItem $InstallDir)
    if ($top.Count -eq 1 -and $top[0].PSIsContainer) {
        Get-ChildItem $top[0].FullName -Force | Move-Item -Destination $InstallDir -Force
        Remove-Item $top[0].FullName -Recurse -Force
    }

    $exe = Get-ChildItem $InstallDir -Filter *.exe -Recurse |
           Where-Object { $_.Name -notmatch 'unins|setup|crash' } |
           Sort-Object { $_.FullName.Length } | Select-Object -First 1
    if (-not $exe) { throw "Nao encontrei o executavel do jogo dentro de $($asset.name)." }

    Set-Content -Path (Join-Path $InstallDir 'version.txt') -Value $release.tag_name

    # ---------------- Atalhos ----------------
    if (-not $NoShortcut) {
        $shell = New-Object -ComObject WScript.Shell
        New-Item -ItemType Directory -Path $StartMenu -Force | Out-Null
        foreach ($lnk in @((Join-Path $Desktop $LinkName), (Join-Path $StartMenu $LinkName))) {
            $s = $shell.CreateShortcut($lnk)
            $s.TargetPath       = $exe.FullName
            $s.WorkingDirectory = $exe.DirectoryName
            $s.IconLocation     = $exe.FullName
            $s.Save()
        }
        Say 'Atalhos criados na Area de Trabalho e no Menu Iniciar.'
    }

    Say "Pronto! $GameName $($release.tag_name) instalado em $InstallDir" 'Green'

    if (-not $NoLaunch) {
        Say 'Abrindo o jogo...'
        Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName
    }
}

Install-MazeOfExistence @args
