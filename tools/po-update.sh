#!/bin/sh

set -e

if test "$1" = "-h" -o "$1" = "--help"; then
	echo "Use: $0 [<language>]"
	echo "Run without arguments to update all translation files."
	exit 0
fi

cd "$(readlink -f "$(dirname "$0")/..")"

VERSION=(0.1.0)
DOMAIN=(manalog)

intltool-extract --type=gettext/ini extras/manalog.desktop.in
intltool-extract --type=gettext/ini extras/manalog-root.desktop.in
intltool-extract --type=gettext/xml extras/org.mageia.manalog.policy.in

POT_DIR="$PWD/po"
test -d "$POT_DIR"

POT_FILE="$POT_DIR/$DOMAIN.pot"

/usr/bin/xgettext \
	--package-name "$DOMAIN" \
	--package-version "$VERSION" \
	--language=Python --from-code=UTF-8 --keyword=_ --keyword=N_ \
	--no-escape --add-location --sort-by-file \
	--add-comments=I18N \
	--output="$POT_FILE" \
	manalog/manalog.py \
	extras/manalog.desktop.in.h \
	extras/manalog-root.desktop.in.h \
	extras/org.mageia.manalog.policy.in.h

/bin/sed --in-place --expression="s/charset=CHARSET/charset=UTF-8/" "$POT_FILE"

intltool-merge --desktop-style po extras/manalog.desktop.in extras/manalog.desktop
intltool-merge --desktop-style po extras/manalog-root.desktop.in extras/manalog-root.desktop
intltool-merge --desktop-style po extras/org.mageia.manalog.policy.in extras/org.mageia.manalog.policy

rm -f extras/manalog.desktop.in.h
rm -f extras/manalog-root.desktop.in.h
rm -f extras/org.mageia.manalog.policy.in.h

update_po() {
	local LL_CC="$1"
	local PO_FILE="$POT_DIR/$LL_CC.po"

        echo "Update $(basename "$PO_FILE"):"
	/usr/bin/msgmerge \
		--update --no-fuzzy-matching \
		--no-escape --add-location --sort-by-file \
		--lang="$LL_CC" \
		"$PO_FILE" "$POT_FILE"
}

if test "$1"; then
	update_po "$1"
else
	for l in $(ls -1 "$POT_DIR"/*.po); do
		l="$(basename "$l")"
		update_po "${l%.po}"
	done
fi
