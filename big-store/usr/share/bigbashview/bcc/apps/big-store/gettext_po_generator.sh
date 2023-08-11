#!/bin/bash

rm locale/big-store.pot

/usr/lib/python3.10/Tools/i18n/pygettext.py -o "locale/python.pot" *.py

for f in $(find . \( -iname "*.sh.htm" -o -iname "*.sh" \)); do
	echo $f
	bash --dump-po-strings $f >>locale/bash-files.pot
done

xgettext --package-name="big-store" --no-location -L PO -o "locale/bash.pot" -i "locale/bash-files.pot"
rm locale/bash-files.pot
msgcat locale/*.pot >locale/big-store.pot
rm locale/bash.pot locale/python.pot

for lang in {"en","es"}; do
	if [ -e "locale/$lang/LC_MESSAGES/big-store.po" ]; then
		msgmerge -o "locale/$lang/LC_MESSAGES/big-store.po" "locale/$lang/LC_MESSAGES/big-store.po" "locale/big-store.pot"
		msgfmt -v "locale/$lang/LC_MESSAGES/big-store.po" -o "locale/$lang/LC_MESSAGES/big-store.mo"
		sudo install "locale/$lang/LC_MESSAGES/big-store.mo" "/usr/share/locale/$lang/LC_MESSAGES/big-store.mo"
	else
		msginit --no-translator -l "$lang" -i "locale/big-store.pot" -o "locale/$lang/LC_MESSAGES/big-store.po"
		sed -i 's|Content-Type: text/plain; charset=ASCII|Content-Type: text/plain; charset=utf-8|g' "locale/$lang/LC_MESSAGES/big-store.po"
		msgfmt -v "locale/$lang/LC_MESSAGES/big-store.po" -o "locale/$lang/LC_MESSAGES/big-store.mo"
		sudo install "locale/$lang/LC_MESSAGES/big-store.mo" "/usr/share/locale/$lang/LC_MESSAGES/big-store.mo"
	fi
done
exit
