#!/usr/bin/env bash
# ============================================================================
#  Maze of Existence - instalador para Linux
# ----------------------------------------------------------------------------
#  Baixa a versao mais recente publicada em GitHub Releases e instala em
#  ~/.local/share/MazeOfExistence, com atalho no menu de aplicativos e o
#  comando "maze-of-existence" no terminal.
#
#  - Se a release tiver um build nativo de Linux (arquivo com "linux" ou
#    "ubuntu" no nome), usa ele.
#  - Senao, usa o build de Windows (.zip) rodando pelo Wine.
#
#  Uso direto (sem clonar):
#    curl -fsSL https://raw.githubusercontent.com/Abelardo-Matheus/MAZE-OF-EXISTENCE/main/install.sh | bash
#
#  Uso a partir do repositorio clonado:
#    ./install.sh                    (instala a versao mais recente)
#    ./install.sh --version v1.1.0   (instala uma versao especifica)
#    ./install.sh --no-launch        (instala sem abrir o jogo)
#    ./install.sh --uninstall        (remove o jogo e os atalhos; saves ficam)
#    ./install.sh --uninstall --purge (remove tambem os saves do Wine)
# ============================================================================
set -euo pipefail

REPO="Abelardo-Matheus/MAZE-OF-EXISTENCE"
GAME_NAME="Maze of Existence"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_DIR="$DATA_HOME/MazeOfExistence"
WINE_PREFIX_DIR="$DATA_HOME/MazeOfExistence-wine"      # saves do build de Windows ficam aqui
BIN_DIR="$HOME/.local/bin"
LAUNCHER="$BIN_DIR/maze-of-existence"
DESKTOP_FILE="$DATA_HOME/applications/maze-of-existence.desktop"
OLD_DEMO="https://drive.google.com/file/d/13MptVvlLx8gzgrO_MtDW82ynJM82T_KS/view?usp=sharing"

VERSION="latest"
NO_LAUNCH=0
UNINSTALL=0
PURGE=0

say()  { printf '\033[36m[Maze]\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m[Maze]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[Maze]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[Maze]\033[0m %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
    case "$1" in
        --version|-v) VERSION="${2:?faltou a versao, ex.: --version v1.1.0}"; shift 2 ;;
        --no-launch)  NO_LAUNCH=1; shift ;;
        --uninstall)  UNINSTALL=1; shift ;;
        --purge)      PURGE=1; shift ;;
        -h|--help)    sed -n '2,22p' "$0" 2>/dev/null || true; exit 0 ;;
        *) die "Opcao desconhecida: $1 (use --help)" ;;
    esac
done

# ---------------- Desinstalar ----------------
if [ "$UNINSTALL" -eq 1 ]; then
    for p in "$INSTALL_DIR" "$LAUNCHER" "$DESKTOP_FILE"; do
        if [ -e "$p" ]; then rm -rf "$p"; say "Removido: $p"; fi
    done
    if [ "$PURGE" -eq 1 ] && [ -d "$WINE_PREFIX_DIR" ]; then
        rm -rf "$WINE_PREFIX_DIR"; say "Removido (saves): $WINE_PREFIX_DIR"
    fi
    command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DATA_HOME/applications" >/dev/null 2>&1 || true
    ok "$GAME_NAME foi desinstalado.$([ "$PURGE" -eq 1 ] || echo ' (Seus saves foram mantidos.)')"
    exit 0
fi

# ---------------- Ferramentas ----------------
if command -v curl >/dev/null 2>&1; then
    fetch()    { curl -fsSL -H "User-Agent: maze-of-existence-installer" "$1"; }
    download() { curl -fL --progress-bar -o "$2" "$1"; }
elif command -v wget >/dev/null 2>&1; then
    fetch()    { wget -qO- --header="User-Agent: maze-of-existence-installer" "$1"; }
    download() { wget -q --show-progress -O "$2" "$1"; }
else
    die "Preciso do curl ou do wget. Ex.: sudo apt install curl"
fi
command -v unzip >/dev/null 2>&1 || die "Preciso do unzip. Ex.: sudo apt install unzip  (Fedora: sudo dnf install unzip | Arch: sudo pacman -S unzip)"

# ---------------- Encontrar a release ----------------
if [ "$VERSION" = "latest" ]; then
    API="https://api.github.com/repos/$REPO/releases/latest"
else
    API="https://api.github.com/repos/$REPO/releases/tags/$VERSION"
fi
say "Procurando a versao '$VERSION' em github.com/$REPO ..."
if ! JSON="$(fetch "$API")"; then
    warn "Nenhuma versao publicada foi encontrada (GitHub Releases)."
    warn "Demo antiga (Beta 1.0, Windows): $OLD_DEMO"
    exit 1
fi
TAG="$(printf '%s' "$JSON" | grep -o '"tag_name": *"[^"]*"' | head -n1 | sed 's/.*"\([^"]*\)"$/\1/')"
URLS="$(printf '%s' "$JSON" | grep -o '"browser_download_url": *"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')"
[ -n "$URLS" ] || die "A release $TAG nao tem nenhum arquivo para baixar."

# Preferencia: build nativo de Linux; senao, o .zip de Windows pelo Wine
URL="$(printf '%s\n' "$URLS" | grep -iE '(linux|ubuntu).*\.(zip|tar\.gz|tgz|appimage)$' | head -n1 || true)"
MODO="nativo"
if [ -z "$URL" ]; then
    URL="$(printf '%s\n' "$URLS" | grep -iE '\.zip$' | head -n1 || true)"
    MODO="wine"
fi
[ -n "$URL" ] || die "A release $TAG nao tem build de Linux nem .zip de Windows."

if [ "$MODO" = "wine" ] && ! command -v wine >/dev/null 2>&1; then
    warn "Esta versao ainda nao tem build nativo de Linux: o jogo roda pelo Wine, que nao esta instalado."
    warn "Instale e rode este comando de novo:"
    warn "  Ubuntu/Debian/Mint: sudo apt install wine"
    warn "  Fedora:             sudo dnf install wine"
    warn "  Arch/Manjaro:       sudo pacman -S wine"
    warn "  openSUSE:           sudo zypper install wine"
    exit 1
fi

# ---------------- Baixar ----------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
ARQ="$TMP/$(basename "$URL")"
say "Baixando $(basename "$URL") - versao $TAG ($MODO) ..."
download "$URL" "$ARQ"

# ---------------- Instalar ----------------
if [ -d "$INSTALL_DIR" ]; then
    say "Removendo a versao anterior..."
    rm -rf "$INSTALL_DIR"
fi
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$(dirname "$DESKTOP_FILE")"
say "Extraindo para $INSTALL_DIR ..."
case "$ARQ" in
    *.zip|*.ZIP)           unzip -q "$ARQ" -d "$INSTALL_DIR" ;;
    *.tar.gz|*.tgz)        tar -xzf "$ARQ" -C "$INSTALL_DIR" ;;
    *.AppImage|*.appimage) cp "$ARQ" "$INSTALL_DIR/"; chmod +x "$INSTALL_DIR/$(basename "$ARQ")" ;;
esac

# Se o pacote tiver uma unica pasta dentro, sobe o conteudo um nivel
shopt -s nullglob dotglob
ITENS=("$INSTALL_DIR"/*)
if [ "${#ITENS[@]}" -eq 1 ] && [ -d "${ITENS[0]}" ]; then
    mv "${ITENS[0]}"/* "$INSTALL_DIR"/
    rmdir "${ITENS[0]}"
fi
shopt -u nullglob dotglob

# Acha o executavel
EXE=""
if [ "$MODO" = "wine" ]; then
    EXE="$(find "$INSTALL_DIR" -type f -iname '*.exe' ! -iname '*unins*' ! -iname '*setup*' ! -iname '*crash*' \
           | awk '{ print length, $0 }' | sort -n | head -n1 | cut -d' ' -f2-)"
else
    while IFS= read -r f; do
        if [ "$(head -c4 "$f" | od -An -c | tr -d ' \n')" = "177ELF" ] || [[ "$f" == *.AppImage ]] || [[ "$f" == *.appimage ]]; then
            EXE="$f"; break
        fi
    done < <(find "$INSTALL_DIR" -type f | awk '{ print length, $0 }' | sort -n | cut -d' ' -f2-)
    [ -n "$EXE" ] && chmod +x "$EXE"
fi
[ -n "$EXE" ] || die "Nao encontrei o executavel do jogo dentro de $(basename "$URL")."
echo "$TAG" > "$INSTALL_DIR/version.txt"

# Icone (se o pacote tiver um)
ICONE="$(find "$INSTALL_DIR" -maxdepth 2 -type f -iname 'icon*.png' | head -n1 || true)"

# ---------------- Comando + atalho no menu ----------------
if [ "$MODO" = "wine" ]; then
    cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
# Maze of Existence (build de Windows pelo Wine). Saves em $WINE_PREFIX_DIR
export WINEPREFIX="$WINE_PREFIX_DIR"
export WINEDEBUG=-all
cd "$(dirname "$EXE")"
exec wine "$(basename "$EXE")" "\$@"
EOF
else
    cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
# Maze of Existence (build nativo de Linux)
cd "$(dirname "$EXE")"
exec "./$(basename "$EXE")" "\$@"
EOF
fi
chmod +x "$LAUNCHER"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$GAME_NAME
Comment=Sobreviva do bebe ate a vida adulta
Exec=$LAUNCHER
Path=$(dirname "$EXE")
Icon=${ICONE:-applications-games}
Terminal=false
Categories=Game;ActionGame;
EOF
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DATA_HOME/applications" >/dev/null 2>&1 || true
say "Atalho criado no menu de aplicativos e comando: maze-of-existence"
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) warn "$BIN_DIR nao esta no seu PATH. Rode o jogo pelo menu ou com: $LAUNCHER" ;;
esac

ok "Pronto! $GAME_NAME $TAG instalado em $INSTALL_DIR"

if [ "$NO_LAUNCH" -eq 0 ]; then
    say "Abrindo o jogo..."
    if [ "$MODO" = "wine" ]; then say "(a primeira vez o Wine pode levar alguns segundos preparando tudo)"; fi
    nohup "$LAUNCHER" >/dev/null 2>&1 &
fi
