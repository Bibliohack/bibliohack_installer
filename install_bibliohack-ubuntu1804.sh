#!/bin/bash

error_msg() {
	echo "$1"
	exit 1
}

pdfbeads_check() {
	check=$( $PDFBEADS_DIR/bin/pdfbeads -h | head -n 1 )
	if [ "$check" == "Usage: pdfbeads [options] [files to process] > out.pdf" ]
	 then
	  return 0
	else
	  return 1
	fi
}

chdkptp_check() {
	if "$INSTALADORES_DIR/chdkptp" "test" chdkptp_dir="$CHDKPTP_DIR"; then
	  return 0
	else
	  return 1
	fi
}

tecgraf_check() {
	iup_ver=$("$INSTALADORES_DIR/tecgraf" print_ver=iup tecgraf_dir="$TECGRAF_DIR")
	cd_ver=$("$INSTALADORES_DIR/tecgraf" print_ver=cd tecgraf_dir="$TECGRAF_DIR")
   if [ "$iup_ver" == "" ] || [ "$cd_ver" == "" ]; then
	  return 1
	elif [ "$iup_ver" == "3.8" ] && [ "$cd_ver" == "5.6.1" ]; then
	  return 0
   else
     echo "tecgraf: versiones no compatibles iup_ver=$iup_ver (3.8) cd_ver=$cd_ver (5.6.1)"
     echo "debe desinstalarlas manualmente antes de usar este instalador"
     exit 1
	fi
}

#install_gem() {
#}

cp_and_untar() {
	# ORIGPATH: path/to/file.tar.gz; DESTDIR: path/to/dir; TARBASECUSTOM: alt tar dir basename (opt)
	[[ ! -z "$1" ]] && ORIGPATH="$1" || return 1
	[[ ! -z "$2" ]] && DESTDIR="$2" || return 1
	[[ ! -z "$3" ]] && TARBASECUSTOM="$3"  
	[[ -f "$ORIGPATH" ]] || return 1
	[[ -d "$DESTDIR" ]] || return 1
	
	current="$PWD"
   cd "$DESTDIR"
	if tar -tf "$ORIGPATH" >/dev/null 2>&1; then
		cp "$ORIGPATH" "$DESTDIR" | exit 1
		TARFILE=`basename "$ORIGPATH"`
		TARBASE=`tar -tf "$TARFILE" | sort | head -1`
		if [[ -z "$TARBASECUSTOM" ]]; then
			tar xf "$TARFILE"
			[[ -d "$TARBASE" ]] && ret=0 || ret=1
			cd "$current"
			return $ret
		else
			mkdir "$TARBASECUSTOM" || exit 1
			tar xf "$TARFILE" -C "$TARBASECUSTOM" --strip-components=1 && ret=0 || ret=1
			cd "$current"
			return $ret
		fi
	else
		cd "$current"
		return 1
	fi
}

OSNAME=`lsb_release -is`
CODENM=`lsb_release -cs`
RELEASN=`lsb_release -rs`

if [ "$RELEASN" == '18.04' ] && [ "$OSNAME" == 'Ubuntu' ]; then
   echo "*** Instalando Bibliohack en $OSNAME $CODENAME $RELEASN ***" 
else
	echo "Este instalador no funciona en $OSNAME $RELEASE"
	echo "Debe instalarse en Ubuntu 18.04 bionic"
	exit 1
fi

OWN_SCRIPT_DIR=$(dirname "$0")
cd "$OWN_SCRIPT_DIR"
INSTALADORES_DIR="$(pwd -P)"
cd "$INSTALADORES_DIR"

BIBLIOHACK_DIR=/opt/bibliohack
TMPDIR="$BIBLIOHACK_DIR/.tmp"
RESOURCES="$BIBLIOHACK_DIR/resources"
COMPONENTS="$BIBLIOHACK_DIR/components"

[[ "$1" != "" ]] && BIBLIOHACK_ORIG="$1" || error_msg "error: BIBLIOHACK_ORIG='$BIBLIOHACK_ORIG'"
BIBLIOHACK_ORIG_SRCDIR="$BIBLIOHACK_ORIG/src"

PDFBEADS_DIR="$COMPONENTS/pdfbeads-kopi" # esta carpeta se crea via tar!
CHDKPTP_DIR="$RESOURCES/chdkptp-461"
TECGRAF_DIR="$RESOURCES/tecgraf"

[[ -d "$BIBLIOHACK_DIR" ]] || {
	sudo mkdir "$BIBLIOHACK_DIR" || exit 1
}
sudo chmod a+rw "$BIBLIOHACK_DIR"

[[ -d "$RESOURCES" ]] || {
	mkdir "$RESOURCES" || exit 1
}
[[ -d "$COMPONENTS" ]] || {
	mkdir "$COMPONENTS" || exit 1
}
[[ -d "$TMPDIR" ]] || {
	mkdir "$TMPDIR" || exit 1
}

# --------------------------------------------------------
# desktop

# faltaron: python sgml-base
# quedaronm sin instalar: python_2.7.15~rc1-1_amd64.deb alacarte metacity-common python-gi libmetacity1:amd64 metacity gnome-session-flashback
# luego de: sudo apt --fix-broken install, instal: python sgml-base

# agregar tango-icon-theme

# --------------------------------------------------------
echo "instalando 'build essential'"

BUILD_ESSENTIAL="INSTALLED"

if [ "$BUILD_ESSENTIAL" != "INSTALLED" ]; then
	current_folder="$PWD"
	cd "$BIBLIOHACK_ORIG/deb/build-essential"
	sudo dpkg -iEG *.deb || {
		>&2 echo "ERROR al instalar con dpkg"
		exit 1
	}
	cd "$current_folder"
fi

# --------------------------------------------------------
echo "instalando tecgraf"

if ! tecgraf_check; then
	[[ -d "$TECGRAF_DIR" ]] || {
		mkdir "$TECGRAF_DIR" || exit 1
	}
	$INSTALADORES_DIR/tecgraf install profile=d tecgraf_dir="$TECGRAF_DIR" orig_dpkg_dir="$BIBLIOHACK_ORIG/deb/tecgraf" orig_dir="$BIBLIOHACK_ORIG/tecgraf" || exit 1
fi

# --------------------------------------------------------
echo "instalando chdkptp"

# Se encontraron errores al procesar:
# python3_3.6.7-1~18.04_amd64.deb
# python3-minimal_3.6.7-1~18.04_amd64.deb
# python3-distutils
# python3-lib2to3
# libglib2.0-dev-bin
# libglib2.0-dev:amd64
# libcairo2-dev:amd64

# dpkg: acerca de python3_3.6.7-1~18.04_amd64.deb que contiene python3, problema de predependencia:
# python3 predepende de python3-minimal (= 3.6.7-1~18.04)
#  python3-minimal está instalado, pero tiene versión 3.6.5-3ubuntu1.
# TODO descargar los paquetes compatibles con 3.6.5-3!!

if ! chdkptp_check; then
	[[ -d "$CHDKPTP_DIR" ]] || {
		mkdir "$CHDKPTP_DIR" || exit 1
	}
	echo $INSTALADORES_DIR/chdkptp install profile=d tecgraf_dir="$TECGRAF_DIR" chdkptp_dir="$CHDKPTP_DIR" orig_dpkg_dir="$BIBLIOHACK_ORIG/deb/chdkptp" orig_path="$BIBLIOHACK_ORIG/src/chdkptp-461.tar.gz"

	$INSTALADORES_DIR/chdkptp install profile=d tecgraf_dir="$TECGRAF_DIR" chdkptp_dir="$CHDKPTP_DIR" orig_dpkg_dir="$BIBLIOHACK_ORIG/deb/chdkptp" orig_path="$BIBLIOHACK_ORIG/src/chdkptp-461.tar.gz" || error_msg "fallo la instalacion de chdkptp"
else
	echo "chdkptp ya instalado"
fi

# --------------------------------------------------------
echo "instalando pdfbeads"

if ! pdfbeads_check; then
	current_folder="$PWD"

	GEMS_ORIG="$BIBLIOHACK_ORIG/gem"
	PDFBEADS_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG/deb/ruby-pdfbeads"

	cd "$PDFBEADS_ORIG_DPKG_DIR" || exit 1
	sudo dpkg -iEG *.deb || exit 1

   verify_iconv=$(gem list -i iconv)
	if [ "$verify_iconv" == "false" ]; then
		echo "instalando iconv"
		cp "$GEMS_ORIG/iconv_ubuntu_bionic-x86_64-rubygem.tar.gz" "$TMPDIR/" || exit 1
		cd "$TMPDIR/"
		tar xzvf iconv_ubuntu_bionic-x86_64-rubygem.tar.gz || exit 1
		cd iconv/cache || exit 1

		sudo gem install --force --local *.gem || exit 1
		verify_iconv=$(gem list -i iconv)
		[[ "$verify_iconv" == "false" ]] && error_msg "error: no se pudo instalar iconv"
	else
		if [ "$verify_iconv" == "true" ]; then
			echo "iconv ya instalado"
		else
			echo "error!!"
			exit 1
		fi
	fi
	cp "$BIBLIOHACK_ORIG_SRCDIR/pdfbeads-kopi.tar.gz" "$COMPONENTS" | exit 1
	cd "$COMPONENTS" || exit 1
	tar xzvf pdfbeads-kopi.tar.gz
	[[ -d "$PDFBEADS_DIR" ]] || error_msg "'$PDFBEADS_DIR' no existe!"

	if pdfbeads_check; then 
		echo "pdfbeads instalado ok"
	else 
		echo "error! pdfbeads no se instalo correctamente"
	fi

	cd "$current_folder"
else
	echo "pdfbeads ya instalado"
fi

# ------------------------------------------
# tesseract
# sudo dpkg -iEG *.deb OK!!


# ------------------------------------------
# evince/geeqie
# sudo dpkg -iEG *.deb OK!!

# ------------------------------------------
# scantailor universal
# cd scantailor
# sudo dpkg -iEG *.deb  OK!!
# cd scantailor-universal-qt5
# sudo dpkg -iEG *.deb  OK!!
# corre OK!!! OJO al descomprimir queda ./scantailor_universal-0.2.5-ubuntu_bionic-x86_64-bin/scantailor-universal

# ------------------------------------------
# keybase dpkg ok

exit 0

