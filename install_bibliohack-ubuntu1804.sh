#!/bin/bash

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

# --------------------------------------------------------

OWN_SCRIPT_DIR=$(dirname "$0")
cd "$OWN_SCRIPT_DIR"
INSTALADORES_DIR="$(pwd -P)"
cd "$INSTALADORES_DIR"

# --------------------------------------------------------

BIBLIOHACK_DIR=/opt/bibliohack
TMPDIR="$BIBLIOHACK_DIR/.tmp"
RESOURCES="$BIBLIOHACK_DIR/resources"
COMPONENTS="$BIBLIOHACK_DIR/components"

[[ "$1" != "" ]] && BIBLIOHACK_ORIG="$1" || error_msg "error: BIBLIOHACK_ORIG='$BIBLIOHACK_ORIG'"

BIBLIOHACK_ORIG_SRCDIR="$BIBLIOHACK_ORIG/src"
BIBLIOHACK_ORIG_DPKG="$BIBLIOHACK_ORIG/deb"

SCANTAILOR_ADVANCED_DIR="$COMPONENTS/scantailor-advanced"
SCANTAILOR_UNIVERSAL_DIR="$COMPONENTS/scantailor-universal"
SCANTAILOR_ENHANCED_DIR="$COMPONENTS/scantailor-enhanced"
PDFBEADS_DIR="$COMPONENTS/pdfbeads-kopi"
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
# chdkptp orig paths
CHDKPTP_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/chdkptp"
CHDKPTP_SRC_TAR_PATH="$BIBLIOHACK_ORIG_SRCDIR/chdkptp-461.tar.gz"

# tecgraf orig paths
TECGRAF_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/tecgraf"
TECGRAF_ORIG="$BIBLIOHACK_ORIG/tecgraf"

# pdfbeads orig paths
GEMS_ORIG="$BIBLIOHACK_ORIG/gem"
ICONV_RUBYGEM_TAR="iconv_ubuntu_bionic-x86_64-rubygem.tar.gz"
PDFBEADS_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/ruby-pdfbeads"
PDFBEADS_SRC_TAR_PATH="$BIBLIOHACK_ORIG_SRCDIR/pdfbeads-kopi.tar.gz"

# tesseract orig paths
TESSERACT_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/tesseract"

# scantailor orig paths
SCANTAILOR_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/scantailor"
SCANTAILOR_UNIVERSAL_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/scantailor-universal-qt5"
SCANTAILOR_ADVANCED_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/scantailor-advanced-qt5-extra"

SCANTAILOR_ENHANCED_TAR_PATH="$BIBLIOHACK_ORIG_BINDIR/scantailor_enhanced-???-ubuntu_bionic-18.04-x86_64-bin.tar.gz"
SCANTAILOR_UNIVERSAL_TAR_PATH="$BIBLIOHACK_ORIG_BINDIR/scantailor_universal-0.2.5-ubuntu_bionic-x86_64-bin.tar.gz"
SCANTAILOR_ADVANCED_TAR_PATH="$BIBLIOHACK_ORIG_BINDIR/scantailor_advanced-1.0.16-ubuntu_bionic-18.04-x86_64-bin.tar.xz"

# dalclick orig paths
DALCLICK_ORIG_DPKG_DIR="$BIBLIOHACK_ORIG_DPKG/dalclick"
DALCLICK_SRC_TAR_PATH="$BIBLIOHACK_ORIG_SRCDIR/dalclick.tar.gz"

# fcen-tesis orig paths
FCENTESIS_SRC_TAR_PATH="$BIBLIOHACK_ORIG_SRCDIR/fcen-tesis.tar.gz"

error_msg() {
	echo "$1"
	exit 1
}

scantailor_advanced_check() {
	check=$( $SCANTAILOR_UNIVERSAL_DIR/scantailor-cli -h | sed -n '2p' )
	if [ "$check" == "Scan Tailor is a post-processing tool for scanned pages." ]
	 then
	  return 0
	else
	  return 1
	fi
}

scantailor_universal_check() {
	check=$( $SCANTAILOR_UNIVERSAL_DIR/scantailor-cli -h | sed -n '2p' )
	if [ "$check" == "Scan Tailor is a post-processing tool for scanned pages." ]
	 then
	  return 0
	else
	  return 1
	fi
}

scantailor_enhanced_check() {
	check=$( $SCANTAILOR_UNIVERSAL_DIR/scantailor-cli -h | sed -n '2p' )
	if [ "$check" == "Scan Tailor is a post-processing tool for scanned pages." ]
	 then
	  return 0
	else
	  return 1
	fi
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

dpkg_install() {
	[[ ! -z "$1" ]] && ORIGDPKG="$1" || return 1
	current_folder="$PWD"
	cd "$ORIGDPKG"
	sudo dpkg -iEG *.deb || {
		>&2 echo "ERROR al instalar con dpkg"
		cd "$current_folder"
		return 1
	}
	cd "$current_folder"
	return 0
}

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

tecgraf_ok="
"
chdkptp_ok="
"
pdfbeads_ok="
"
tesseract_ok=" _____                                 _      ___  _  __
|_   _|__  ___ ___  ___ _ __ __ _  ___| |_   / _ \| |/ /
  | |/ _ \/ __/ __|/ _   '__/ _\` |/ __| __| | | | | ' /
  | |  __/\__ \__ \  __/ | | (_| | (__| |_  | |_| | . \\
  |_|\___||___/___/\___|_|  \__,_|\___|\__|  \___/|_|\_\\
"
scantailor_ok=""

dalclick_ok=""

fcentesis_ok=""

echo "$tesseract_ok"

exit 1
# --------------------------------------------------------
# desktop

# faltaron: python sgml-base
# quedaronm sin instalar: python_2.7.15~rc1-1_amd64.deb alacarte metacity-common python-gi libmetacity1:amd64 metacity gnome-session-flashback
# luego de: sudo apt --fix-broken install, instal: python sgml-base

# agregar tango-icon-theme

# --------------------------------------------------------
echo "instalando 'build essential'"

# BUILD_ESSENTIAL="INSTALLED"

if [ "$BUILD_ESSENTIAL" != "INSTALLED" ]; then
	dpkg_install "$BIBLIOHACK_ORIG/deb/build-essential"
fi

# --------------------------------------------------------
echo "instalando tecgraf"

if ! tecgraf_check; then
	[[ -d "$TECGRAF_DIR" ]] || {
		mkdir "$TECGRAF_DIR" || exit 1
	}
   echo $INSTALADORES_DIR/tecgraf install profile=d tecgraf_dir="$TECGRAF_DIR" orig_dpkg_dir="$TECGRAF_ORIG_DPKG_DIR" orig_dir="$TECGRAF_ORIG"
	$INSTALADORES_DIR/tecgraf install profile=d tecgraf_dir="$TECGRAF_DIR" orig_dpkg_dir="$TECGRAF_ORIG_DPKG_DIR" orig_dir="$TECGRAF_ORIG" || exit 1
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
	echo $INSTALADORES_DIR/chdkptp install profile=d tecgraf_dir="$TECGRAF_DIR" chdkptp_dir="$CHDKPTP_DIR" orig_dpkg_dir="$CHDKPTP_ORIG_DPKG_DIR" orig_path="$CHDKPTP_SRC_TAR_PATH"
	$INSTALADORES_DIR/chdkptp install profile=d tecgraf_dir="$TECGRAF_DIR" chdkptp_dir="$CHDKPTP_DIR" orig_dpkg_dir="$CHDKPTP_ORIG_DPKG_DIR" orig_path="$CHDKPTP_SRC_TAR_PATH" || error_msg "fallo la instalacion de chdkptp"
else
	echo "chdkptp ya instalado"
fi

# --------------------------------------------------------
echo "instalando pdfbeads"

if ! pdfbeads_check; then

	dpkg_install "$PDFBEADS_ORIG_DPKG_DIR"

   verify_iconv=$(gem list -i iconv)
	if [ "$verify_iconv" == "false" ]; then
		echo "instalando iconv"
	   current_folder="$PWD"
		TARBASE=""; cp_and_untar "$GEMS_ORIG/$ICONV_RUBYGEM_TAR" "$TMPDIR" || exit 1
		cd "${TMPDIR}/${TARBASE}" || {echo "error: cd ${TMPDIR}/${TARBASE}"; exit 1;}
		cd iconv/cache || exit 1
		sudo gem install --force --local *.gem || exit 1
		cd "$current_folder"
		verify_iconv=$(gem list -i iconv)
		[[ "$verify_iconv" == "false" ]] && error_msg "error: no se pudo instalar iconv"
	else
		if [ "$verify_iconv" == "true" ]; then
			echo "iconv ya instalado ok"
		else
			echo "error!!"
			exit 1
		fi
	fi
	CUSTOM_TARDIR="${PDFBEADS_DIR##*/}"
	cp_and_untar "$PDFBEADS_SRC_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	[[ -d "$PDFBEADS_DIR" ]] || error_msg "'$PDFBEADS_DIR' no existe!"

	if pdfbeads_check; then
		echo "pdfbeads instalado ok"
	else
		echo "error! pdfbeads no se instalo correctamente"
	fi

else
	echo "pdfbeads ya instalado"
fi

# ------------------------------------------
# tesseract
# TESSERACT="INSTALLED"

if [ "$TESSERACT" != "INSTALLED" ]; then
	dpkg_install "$TESSERACT_ORIG_DPKG_DIR" || exit 1
fi

# ------------------------------------------
# scantailor

if ! scantailor_enhanced_check; then
	dpkg_install "$SCANTAILOR_ORIG_DPKG_DIR" || exit 1
	CUSTOM_TARDIR="${SCANTAILOR_ENHANCED_DIR##*/}"
	cp_and_untar "$SCANTAILOR_ENHANCED_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	scantailor_enhanced_check && echo "Scantailor Enhanced instalado: OK" || exit 1
else
	echo "Scantailor Enhanced ya instalado"
fi

if ! scantailor_universal_check; then
	dpkg_install "$SCANTAILOR_UNIVERSAL_ORIG_DPKG_DIR" || exit 1
	CUSTOM_TARDIR="${SCANTAILOR_UNIVERSAL_DIR##*/}"
	cp_and_untar "$SCANTAILOR_UNIVERSAL_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	scantailor_universal_check && echo "Scantailor Universal instalado: OK" || exit 1
else
	echo "Scantailor Universal ya instalado"
fi

if ! scantailor_advanced_check; then
	dpkg_install "$SCANTAILOR_ADVANCED_ORIG_DPKG_DIR" || exit 1
	CUSTOM_TARDIR="${SCANTAILOR_ADVANCED_DIR##*/}"
	cp_and_untar "$SCANTAILOR_ADVANCED_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	scantailor_advanced_check && echo "Scantailor Advanced instalado: OK" || exit 1
else
	echo "Scantailor Advanced ya instalado"
fi

# ------------------------------------------
# evince/geeqie
# sudo dpkg -iEG *.deb OK!!

# ------------------------------------------
# keybase dpkg ok

exit 0
