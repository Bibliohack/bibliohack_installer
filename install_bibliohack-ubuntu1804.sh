#!/bin/bash

OSNAME=`lsb_release -is`
CODENM=`lsb_release -cs`
RELEASN=`lsb_release -rs`

if [ "$RELEASN" == '18.04' ] && [ "$OSNAME" == 'Ubuntu' ]; then
   echo "*** Instalando Bibliohack en $OSNAME $CODENAME $RELEASN ***"
else
	echo "Este instalador no funciona en $OSNAME $RELEASN '$CODENM'"
	echo "Debe instalarse en Ubuntu 18.04 'bionic'"
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

FCENTESIS_DIR="$BIBLIOHACK_ORIG/fcen-tesis"
DALCLICK_DIR="$BIBLIOHACK_ORIG/dalclick"
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

fcentesis_check() {
   [[ -f "$FCENTESIS_DIR/fcen-postprocessing/scripts/fcen-postprocessing " ]] && return 0 || return 1
}

dalclick_check() {
   [[ -f "$DALCLICK_DIR/dalclick" ]] && return 0 || return 1
}

scantailor_advanced_check() {
	check=$( $SCANTAILOR_ADVANCED_DIR/scantailor-cli -h | sed -n '2p' )
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
	check=$( $SCANTAILOR_ENHANCED_DIR/scantailor-cli -h | sed -n '2p' )
	if [ "$check" == "Scan Tailor is a post-processing tool for scanned pages." ]
	 then
	  return 0
	else
	  return 1
	fi
}

tesseract_check() {
	check=$( tesseract -v  2>&1 | head -n 1 )
	if [[ "$check" =~ ^"tesseract 3" ]]
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

# config bibliohack

if [ -f "$BIBLIOHACK_DIR/.config" ]
   . "$BIBLIOHACK_DIR/.config"
fi

if [[ -z $INSTITUCION_ID ]]; then
   echo "Ingresa el nombre de la institución"
   read -p "> " $INSTITUCION

   while true
   do
      echo "Ingresa un nombre identificador sin espacios"
      echo "ni acentos, de entre 2 y 16 caracteres"
      read -p "> " $INSTITUCION_ID
      [[ "$INSTITUCION_ID" =~ ^[a-zA-Z0-9_-]{2,16}$ ]] && break || echo "NO VALIDO!"
   done
   config_file=$(cat << EOF
INSTITUCION="$INSTITUCION_ID"
INSTITUCION_ID="$INSTITUCION_ID"

EOF
   )
   echo "$config_file" > "$BIBLIOHACK_DIR/.config" || exit 1
fi

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
tecgraf_ok=$(cat <<EOF
 _____                         __
|_   _|__  ___ __ _ _ __ __ _ / _|
  | |/ _ \/ __/ _\` | '__/ _\` | |_
  | |  __/ (_| (_| | | | (_| |  _|
  |_|\___|\___\__, |_|  \__,_|_|
             |___/

  ** Instalado **

EOF
)

echo "instalando tecgraf"

if ! tecgraf_check; then
	[[ -d "$TECGRAF_DIR" ]] || {
		mkdir "$TECGRAF_DIR" || exit 1
	}
   echo $INSTALADORES_DIR/tecgraf install profile=d tecgraf_dir="$TECGRAF_DIR" orig_dpkg_dir="$TECGRAF_ORIG_DPKG_DIR" orig_dir="$TECGRAF_ORIG"
	$INSTALADORES_DIR/tecgraf install profile=d tecgraf_dir="$TECGRAF_DIR" orig_dpkg_dir="$TECGRAF_ORIG_DPKG_DIR" orig_dir="$TECGRAF_ORIG" || exit 1
   echo "$tecgraf_ok"
fi

# --------------------------------------------------------

chdkptp_ok=$(cat <<EOF
  ____ _   _ ____  _  ______ _____ ____
 / ___| | | |  _ \| |/ /  _ \_   _|  _ \
| |   | |_| | | | | ' /| |_) || | | |_) |
| |___|  _  | |_| | . \|  __/ | | |  __/
 \____|_| |_|____/|_|\_\_|    |_| |_|

  ** Instalado **

EOF
)

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
   echo "$chdkptp_ok"
else
	echo "chdkptp ya instalado"
fi

# --------------------------------------------------------
pdfbeads_ok=$(cat <<EOF
 ____     _  __ _                    _
|  _ \ __| |/ _| |__   ___  __ _  __| |___
| |_) / _\` | |_| '_ \ / _ \/ _\` |/ _\` / __|
|  __/ (_| |  _| |_) |  __/ (_| | (_| \__ \
|_|   \__,_|_| |_.__/ \___|\__,_|\__,_|___/

  ** Instalado **

EOF
)

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
		echo "$pdfbeads_ok"
	else
		echo "error! pdfbeads no se instalo correctamente"
	fi

else
	echo "pdfbeads ya instalado"
fi

# ------------------------------------------
# tesseract
tesseract_ok=$(cat <<EOF
 _____                                 _
|_   _|__  ___ ___  ___ _ __ __ _  ___| |_
  | |/ _ \/ __/ __|/ _ \ '__/ _\` |/ __| __|
  | |  __/\__ \__ \  __/ | | (_| | (__| |_
  |_|\___||___/___/\___|_|  \__,_|\___|\__|

  ** Instalado **

EOF
)

if ! tesseract_check; then
	dpkg_install "$TESSERACT_ORIG_DPKG_DIR" || exit 1
   echo "$tesseract_ok"
fi

# ------------------------------------------
# scantailor
scantailor_ok=$(cat <<EOF
 ____                  _        _ _
/ ___|  ___ __ _ _ __ | |_ __ _(_) | ___  _ __
\___ \ / __/ _\` | '_ \| __/ _\` | | |/ _ \| '__|
 ___) | (_| (_| | | | | || (_| | | | (_) | |
|____/ \___\__,_|_| |_|\__\__,_|_|_|\___/|_|

  ** Instalado **

EOF
)
scantailor_instalado=""
if ! scantailor_enhanced_check; then
	dpkg_install "$SCANTAILOR_ORIG_DPKG_DIR" || exit 1
	CUSTOM_TARDIR="${SCANTAILOR_ENHANCED_DIR##*/}"
	cp_and_untar "$SCANTAILOR_ENHANCED_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	scantailor_enhanced_check && echo "Scantailor Enhanced instalado: OK" || exit 1
   scantailor_instalado="OK"
else
	echo "Scantailor Enhanced ya instalado"
fi

if ! scantailor_universal_check; then
	dpkg_install "$SCANTAILOR_UNIVERSAL_ORIG_DPKG_DIR" || exit 1
	CUSTOM_TARDIR="${SCANTAILOR_UNIVERSAL_DIR##*/}"
	cp_and_untar "$SCANTAILOR_UNIVERSAL_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	scantailor_universal_check && echo "Scantailor Universal instalado: OK" || exit 1
   scantailor_instalado="OK"
else
	echo "Scantailor Universal ya instalado"
fi

if ! scantailor_advanced_check; then
	dpkg_install "$SCANTAILOR_ADVANCED_ORIG_DPKG_DIR" || exit 1
	CUSTOM_TARDIR="${SCANTAILOR_ADVANCED_DIR##*/}"
	cp_and_untar "$SCANTAILOR_ADVANCED_TAR_PATH" "$COMPONENTS" "$CUSTOM_TARDIR" || exit 1
	scantailor_advanced_check && echo "Scantailor Advanced instalado: OK" || exit 1
   scantailor_instalado="OK"
else
	echo "Scantailor Advanced ya instalado"
fi

[[ "$scantailor_instalado" == "OK" ]] && echo "$scantailor_ok"

# ------------------------------------------
dalclick_ok=$(cat <<EOF
 ____        _      _ _      _
|  _ \  __ _| | ___| (_) ___| | __
| | | |/ _\` | |/ __| | |/ __| |/ /
| |_| | (_| | | (__| | | (__|   <
|____/ \__,_|_|\___|_|_|\___|_|\_\

  ** Instalado **

EOF
)
if ! dalclick_check; then
   dpkg_install "$DALCLICK_ORIG_DPKG_DIR" || exit 1
   CUSTOM_TARDIR="${DALCLICK_DIR##*/}"
   cp_and_untar "$DALCLICK_SRC_TAR_PATH" "$BIBLIOHACK_DIR" "$CUSTOM_TARDIR" || exit 1
   BIB_DIR="/bib/$INSTITUCION_ID"

   [[ -d "/bib" ]] || {
      sudo mkdir /bib || exit 1
   }

   [[ -d "$BIB_DIR" ]] || {
      sudo mkdir "$BIB_DIR" || exit 1
      sudo chmod a+rw "$BIB_DIR" || exit 1
   }

   config_file=$(cat << EOF
# descomente DALCLICK_HOME sólo si desea cambiar el valor por defecto
# DALCLICK_HOME="$HOME/.dalclick"

DALCLICK_PROJECTS="$BIB_DIR"
ROTATE_ODD_DEFAULT="90"
ROTATE_EVEN_DEFAULT="-90"
ROTATE_SINGLE_DEFAULT="180"
FILE_BROWSER='/usr/bin/nautilus'
PDF_VIEWER='/usr/bin/evince'

# NOC_MODE (numero de cámaras)
# 'odd-even', dos cámaras para estativo en 'V'
# 'single', una cámara para estativo plano
NOC_MODE='odd-even'
# PDFBEADS_QUALITY="50" # (1...100), el valor por defecto de pdfbeads es 50

EOF
   )
   components_file=$(cat << EOF
# Components paths

SCANTAILOR_PATH="$SCANTAILOR_UNIVERSAL_DIR/scantailor"
SCANTAILOR_ADV_PATH="$SCANTAILOR_ADVANCED_DIR/scantailor"
PDFBEADS_PATH="$PDFBEADS_DIR/bin/pdfbeads"
CHDKPTP_PATH="$CHDKPTP_DIR/chdkptp"

#SE_BIN="${SCANTAILOR_PATH}-cli" #Scantailor enhanced exec path
#PB_BIN="$PDFBEADS_PATH" #Pdfbeads enhanced

EOF
   )
   if [[ ! -d "$HOME/.dalclick" ]]; then
      mkdir "$HOME/.dalclick" || exit 1
   fi
   echo "config_file" > "$HOME/.dalclick/CONFIG"
   echo "components_file" > "$DALCLICK_DIR/COMPONENTS"
   dalclick_check && echo "dalclick_ok" || exit 1
fi

# ------------------------------------------
fcentesis_ok=$(cat <<EOF
 _____                    _            _
|  ___|__ ___ _ __       | |_ ___  ___(_)___
| |_ / __/ _ \ '_ \ _____| __/ _ \/ __| / __|
|  _| (_|  __/ | | |_____| ||  __/\__ \ \__ \
|_|  \___\___|_| |_|      \__\___||___/_|___/

  ** Instalado **

EOF
)

if ! fcentesis_check; then
   CUSTOM_TARDIR="${FCENTESIS_DIR##*/}"
   cp_and_untar "$FCENTESIS_SRC_TAR_PATH" "$BIBLIOHACK_DIR" "$CUSTOM_TARDIR" || exit 1
   components_file=$(cat << EOF
# Components paths

SE_BIN="$SCANTAILOR_UNIVERSAL_DIR/scantailor-cli" #Scantailor enhanced exec path
PB_BIN="$PDFBEADS_DIR/bin/pdfbeads" #Pdfbeads enhanced

EOF
   )
   echo "$components_file" > "$FCENTESIS_DIR/fcen-postprocessing/scripts/COMPONENTS" || {
      error_msg "No se pudo crear '$FCENTESIS_DIR/fcen-postprocessing/scripts/COMPONENTS'"
   }
   echo "$fcentesis_ok"
fi

# ------------------------------------------
# evince/geeqie
# sudo dpkg -iEG *.deb OK!!

# ------------------------------------------
# keybase dpkg ok

exit 0
