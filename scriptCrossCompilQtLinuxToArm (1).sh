#!/bin/bash
LIENCOMPILATEURARM="https://launchpadlibrarian.net/155358238/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz"
LIENARCHIVEQT="http://download.qt.io/archive/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz"
NOMARCHIVECOMPILATEUR="gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz"
NOMARCHIVEQT="qt-everywhere-opensource-src-4.8.5.tar.gz"
VERSIONQT="4.8.5"
NOMDOSSIER="installQt"
NOMDOSSIERCOMPILATEUR="gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux"
NOMDOSSIERQT="qt-everywhere-opensource-src-4.8.5"
QMAKECONF="$NOMDOSSIERQT/mkspecs/qws/linux-arm-gnueabi-g++/qmake.conf"
REPERTOIRE="/usr/local/Qt-$VERSIONQT-arm"
COEUR=$(grep -c ^processor /proc/cpuinfo)

echo "Script pour installer QT dans le but de cross compiler pour une architecture ARM"
echo "Ce script peut prendre un certain temps à s'executer, veuillez patienter"

cd $HOME

if [ -d "$NOMDOSSIER" ]; then
    echo "Dossier $NOMDOSSIER déjà existant"
    echo "Suppression de $NOMDOSSIER"
    rm -r $NOMDOSSIER
fi

mkdir $NOMDOSSIER 

cd $NOMDOSSIER

echo "Télechargement de l'archive du SDK de QT $VERSIONQT"

wget -c $LIENARCHIVEQT

if [ -d "$NOMARCHIVEQT" ]; then
    echo "Erreur lors du téléchargement"
    exit
fi

echo "Archive : $NOMARCHIVEQT téléchargée"
echo "Décompression de l'archive"

tar xzvf $NOMARCHIVEQT > /dev/null

#if [ -d "$NOMDOSSIERQT" ]; then
#    echo "Erreur lors de la décompression"
#    exit
#fi

echo "Archive décompressée"
echo "Suppression de l'archive : $NOMARCHIVEQT"

rm -r $NOMARCHIVEQT

echo "Téléchargement de l'archive du compilateur ARM"

wget -c $LIENCOMPILATEURARM

if [ -d $NOMARCHIVECOMPILATEUR ]; then
    echo "Erreur lors du téléchargement"
    exit
fi

echo "Archive : $NOMARCHIVECOMPILATEUR téléchargée"
echo "Décompression de l'archive"

tar xJf $NOMARCHIVECOMPILATEUR > /dev/null

#if [ -d $NOMDOSSIERCOMPILATEUR ]; then
#    echo "Erreur lors de la décompression"
#    exit
#fi

echo "Archive décompressée"
echo "Suppression de l'archive : $NOMARCHIVECOMPILATEUR"

echo "Test du compilateur téléchargé"

$NOMDOSSIERCOMPILATEUR/bin/arm-linux-gnueabihf-gcc --version > tmp.txt

if [ 'grep -Fxq "Copyright" tmp.txt' ]; then
    echo "Compilateur OK"
else
    echo "Erreur avec le compilateur"
    exit
fi

rm tmp.txt

echo "Modification de $QMAKECONF"

sed -i 's/\(.*QMAKE_CC.*\)/QMAKE_CC                     = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-gcc/g' $QMAKECONF
sed -i 's/\(.*QMAKE_CXX.*\)/QMAKE_CXX                   = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-g++/g' $QMAKECONF
sed -i 's/\(.*QMAKE_LINK.*\)/QMAKE_LINK                 = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-g++/g' $QMAKECONF
sed -i 's/\(.*QMAKE_LINK_SHLIB.*\)/QMAKE_LINK_SHLIB     = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-g++/g' $QMAKECONF
sed -i 's/\(.*QMAKE_AR.*\)/QMAKE_AR                     = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-ar cqs/g' $QMAKECONF
sed -i 's/\(.*QMAKE_OBJCOPY.*\)/QMAKE_OBJCOPY           = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-objcopy/g' $QMAKECONF
sed -i 's/\(.*QMAKE_STRIP.*\)/QMAKE_STRIP               = \/home\/felix\/installQt\/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux\/bin\/arm-linux-gnueabihf-strip/g' $QMAKECONF

echo "Lancement du script configure de QT"
echo "Installation de QT $VERSIONQT dans $REPERTOIRE"

cd $HOME/$NOMDOSSIER/$NOMDOSSIERQT

./configure -opensource -confirm-license -prefix $REPERTOIRE -embedded arm -little-endian -no-pch -xplatform qws/linux-arm-gnueabi-g++

echo "Lancement du make sur tous les coeurs de la machine"
echo "Il y a $COEUR coeurs"

COEUR=$(($COEUR+1))
make -j$COEUR ARCH=arm CROSS_COMPILE=$HOME/$NOMDOSSIER/$NOMDOSSIERCOMPILATEUR/bin/arm-linux-gnueabihf-

echo " DONE EASY SHIT BWAHAHAHAHA"
