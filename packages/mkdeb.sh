#!/bin/bash

# This is meant to be called by make! 
# If you want to call it yourself, do a 
#	make all
# first.

VERSION=$(git describe | sed -e 's/^v//' -e 's/-/_/g')

BASE_PATH=gsm-ussd_${VERSION}_all
BIN_PATH=$BASE_PATH/usr/bin
MAN_EN_PATH=$BASE_PATH/usr/share/man/man1
MAN_DE_PATH=$BASE_PATH/usr/share/man/de/man1
DEBIAN_PATH=$BASE_PATH/DEBIAN
DOC_PATH=$BASE_PATH/usr/share/doc/gsm-ussd

function create_installation_directories {
	local SUCCESS=1
	mkdir -p $BIN_PATH 2>/dev/null		|| SUCCESS=0
	mkdir -p $MAN_EN_PATH 2>/dev/null	|| SUCCESS=0
	mkdir -p $MAN_DE_PATH 2>/dev/null	|| SUCCESS=0
	mkdir -p $DEBIAN_PATH 2>/dev/null	|| SUCCESS=0
	mkdir -p $DOC_PATH 2>/dev/null	|| SUCCESS=0
	if [[ $SUCCESS -eq 0 ]] ; then
		echo "Could not create installation directories - abort" >&2
		exit 1
	fi
	return 0
}

function copy_gsm-ussd_files {
	local SUCCESS=1
	cp ../gsm-ussd.pl $BIN_PATH/gsm-ussd || SUCCESS=0
	cp ../docs/en.man $MAN_EN_PATH/gsm-ussd.1 || SUCCESS=0
	cp ../docs/de.man $MAN_DE_PATH/gsm-ussd.1 || SUCCESS=0
	gzip --best $MAN_EN_PATH/gsm-ussd.1 || SUCCESS=0
	gzip --best $MAN_DE_PATH/gsm-ussd.1 || SUCCESS=0
	sed -e 's/@@VERSION@@/'$VERSION'/' debcontrol > $DEBIAN_PATH/control || SUCCESS=0
	cp ../LICENSE $DOC_PATH/copyright || SUCCESS=0
	cp ../docs/README.en $DOC_PATH || SUCCESS=0
	cp ../docs/README.de $DOC_PATH || SUCCESS=0
	cp ../README $DOC_PATH || SUCCESS=0
	git log > $DOC_PATH/changelog
	cat > $DOC_PATH/changelog.Debian <<-'EOF'
	gsm-ussd (0.1.0-1) karmic lucid; urgency=low

	  * This file will not be updated
	    Please see normal changelog file for updates,
	    as Debian maintainer andupstream author are identical.

	 -- Jochen Gruse <jochen@zum-quadrat.de>  Wed, 21 Apr 2010 22:59:36 +0200

EOF
	gzip --best $DOC_PATH/changelog
	gzip --best $DOC_PATH/changelog.Debian
	if [[ $SUCCESS -eq 0 ]] ; then
		echo "Could not copy installation files - abort" >&2
		exit 1
	fi
	return 0
}

function build_deb_package {
	fakeroot dpkg-deb --build $BASE_PATH
}

function clean_up {
	rm -rf $BASE_PATH
}

########################################################################
# Main
########################################################################

create_installation_directories

copy_gsm-ussd_files

build_deb_package

clean_up

exit 0
