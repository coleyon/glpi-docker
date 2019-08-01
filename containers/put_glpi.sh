#!/bin/bash

# Reference: https://github.com/DiouxX/docker-glpi/blob/master/glpi-start.sh

export DEBIAN_FRONTEND=noninteractive

# Check the choice of version or take the latest
[[ ! "$VERSION_GLPI" ]] \
	&& VERSION_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \")
TAR_GLPI=$(basename ${SRC_GLPI})
FOLDER_GLPI=glpi/
FOLDER_WEB=/var/www/html/
FOLDER_PATCHES=/tmp/patches

# Downloading and extracting sources of GLPI
if [ "$(ls ${FOLDER_WEB}${FOLDER_GLPI})" ];
then
	echo "GLPI is already installed"
else
	wget -P ${FOLDER_WEB} ${SRC_GLPI}
	tar -xzf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}
	rm -Rf ${FOLDER_WEB}${TAR_GLPI}
	chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}
fi

# add truetype ipafont for printing japanese pdf
/var/www/html/glpi/vendor/tecnickcom/tcpdf/tools/tcpdf_addfont.php -i /usr/share/fonts/truetype/fonts-japanese-gothic.ttf
/var/www/html/glpi/vendor/tecnickcom/tcpdf/tools/tcpdf_addfont.php -i /usr/share/fonts/truetype/fonts-japanese-mincho.ttf
echo "IPA True Type font installed for GLPI."

# apply patches
if [ "$(ls ${FOLDER_PATCHES}/*.patch 2>/dev/null)" ];
then
	cd $FOLDER_WEB$FOLDER_GLPI
	for patchfile in `find $FOLDER_PATCHES -maxdepth 1 -type f -name "*.patch"`; do
		patch -u -t -p1 < $patchfile
	done
else
	echo "Patching step skipped."
fi
