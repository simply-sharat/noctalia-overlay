#!/usr/bin/env sh
set -eu

SYSTEM=/etc/xdg/quickshell/noctalia-shell
DEST="$HOME/.config/quickshell/noctalia-shell"
SRC="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/noctalia-shell"

if [ ! -d "$SYSTEM" ]; then
    echo "error: system noctalia-shell not found at $SYSTEM" >&2
    echo "install it first (e.g. pacman -S noctalia-shell)" >&2
    exit 1
fi

rm -rf "$DEST"
cp -r "$SYSTEM" "$DEST"
chmod -R u+w "$DEST"

cp -r "$SRC/." "$DEST/"

echo "Installed custom noctalia-shell overlay at $DEST"
echo
echo "Restart the shell with:"
echo "  pkill -f 'qs -c noctalia-shell'"
echo "  setsid -f qs -c noctalia-shell >/tmp/qs.log 2>&1 </dev/null"
