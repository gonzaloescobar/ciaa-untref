#!/bin/bash
# Script realizado en base a lo indicado en http://www.proyecto-ciaa.com.ar/devwiki/doku.php?id=desarrollo:edu-ciaa:edu-ciaa-nxp:python:configuracion_entorno_linux
arch=$(arch)
ciaa_ide_path=$HOME/ciaa-ide

echo ""
echo "**************************************"
echo "Instalando script para CIAA-IDE-Linux."
echo "**************************************"
# Ingreso como administrador
sudo ls /root
echo "******************************************"
echo "Buscando y descargando compilador en /opt"
echo "******************************************"
wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q2-update/+download/gcc-arm-none-eabi-4_8-2014q2-20140609-linux.tar.bz2
mv gcc-arm-none-eabi-4_8-2014q2-20140609-linux.tar.bz2 /opt/
cd /opt
tar jxf gcc-arm-none-eabi-4_8-2014q2-20140609-linux.tar.bz2
rm gcc-arm-none-eabi-4_8-2014q2-20140609-linux.tar.bz2

# Para agregar el compilador al PATH, editamos el archivo .bashrc el 
# cual contiene un script que se ejecutara cuando ingresemos a la terminal con el usuario root.
echo "******************************************"
echo "Modifica el archivo .bashrc"
echo "******************************************"

if ! grep -r "PATH=$PATH:/opt/gcc-arm-none-eabi-4_8-2014q2/bin/" /root/.bashrc ; then
	echo "Ar"
	echo "PATH=$PATH:/opt/gcc-arm-none-eabi-4_8-2014q2/bin/" >> /root/.bashrc
    exit 0
fi

# Se descarga el PHP con la ultima version ya que la 5.0 no se encuentra habilitada
echo "******************************************"
echo "Descargando PHP"
echo "******************************************"
sudo apt-get install php7.0-cli

# Validacion para instalar las librerias para la version de 64 bits
if [ $arch = x86_64 ];
then
echo 'Se instalara las librerias para OpenOCD en la version para 64 bits'
sudo apt-get install libgtk2.0-0:i386 libxtst6:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 libglu1-mesa:i386 libncurses5:i386 libudev1:i386 libusb-1.0:i386 libusb-0.1:i386 gtk2-engines-murrine:i386 libnss3-1d:i386 libwebkitgtk-1.0-0
exit 0
fi

# Instalacion para el chip FT2232 y el paquete libusb
echo "**************************************************************************"
echo "Se instalara el driver necesario para el chip FT2232 y el paquete libusb"
echo "**************************************************************************"
sudo apt-get install libftdi-dev
sudo apt-get install libusb-1.0-0-dev
echo "**************************************************************************"
echo "Antes de compilar el openocd necesitamos instalar el siguiente paquete"
echo "**************************************************************************"
sudo apt-get install pkg-config

# Instalacion y configuracion de OpenOCD
echo "**************************************************************************"
echo "Vamos a configurar e instalar OpenOCD (Versión 0.9.0)"
echo "**************************************************************************"
wget http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.9.0/openocd-0.9.0.tar.bz2
tar -xvjf openocd-0.9.0.tar.bz2

# Compilamos OpenOCD
echo "**************************************************************************"
echo "Compilamos el OpenOCD para que funcione con nuestro chip FT2232"
echo "**************************************************************************"
cd openocd-0.9.0
./configure --enable-ftdi 
make
sudo make install

echo "**************************************************************************"
echo "Fin del Script"
echo "**************************************************************************"















