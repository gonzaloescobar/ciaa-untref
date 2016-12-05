#!/bin/sh
#
# This file is part of the CIAA Project: www.proyecto-ciaa.com.ar
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

arch=$(arch)
ciaa_ide_path=/vagrant/ciaa-ide

echo ""
echo "**************************************"
echo "Instalation script for CIAA-IDE-Linux."
echo "**************************************"

echo ""
echo "**********************************************"
echo "1) Creating folder $ciaa_ide_path..."
echo "**********************************************"
mkdir $ciaa_ide_path
cd $ciaa_ide_path

echo ""
echo "*******************************************************"
echo "2) Downloading and unpacking arm-none-eabi toolchain..."
echo "*******************************************************"
wget https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q1-update/+download/gcc-arm-none-eabi-4_9-2015q1-20150306-linux.tar.bz2
tar -xjvf gcc-arm-none-eabi-4_9-2015q1-20150306-linux.tar.bz2
toolchain_path=$ciaa_ide_path/gcc-arm-none-eabi-4_9-2015q1

# Para agregar el compilador al PATH, editamos el archivo .bashrc el
# cual contiene un script que se ejecutara cuando ingresemos a la terminal con el usuario root.
echo "******************************************"
echo "3) Modify .bashrc"
echo "******************************************"

if ! grep -r "PATH=$PATH:/opt/gcc-arm-none-eabi-4_8-2014q2/bin/" /root/.bashrc ; then
	echo "PATH=$PATH:/opt/gcc-arm-none-eabi-4_8-2014q2/bin/" >> /root/.bashrc

fi

echo "**********************************************"
echo "4) Installing additional packages..."
echo "**********************************************"
if [ $arch = x86_64 ]
then
	echo "**********************************************"
	echo "(64-bits)"
	echo "**********************************************"
	sudo apt-get update
	sudo apt-get -y install php5-cli --fix-missing

else
	echo "**********************************************"
	echo "(32-bits)"
	echo "**********************************************"
	sudo apt-get update
	sudo apt-get -y install php5-cli --fix-missing
fi

# Instalacion para el chip FT2232 y el paquete libusb
echo "**************************************************************************"
echo "5) Downloading chip FT2232 and libusb library"
echo "**************************************************************************"
sudo apt-get -y install libftdi-dev
sudo apt-get -y install libusb-1.0-0-dev

#Antes de compilar el openocd necesitamos instalar el siguiente paquete"
sudo apt-get -y install pkg-config

# Instalacion y configuracion de OpenOCD
echo "**************************************************************************"
echo "6) Downloading, unpacking and building OpenOCD..."
echo "**************************************************************************"
wget http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.9.0/openocd-0.9.0.tar.bz2
tar -xvjf openocd-0.9.0.tar.bz2

# Compilamos OpenOCD
echo "**************************************************************************"
echo "7) Compile OpenOCD... "
echo "**************************************************************************"
cd openocd-0.9.0
./configure --enable-ftdi
sudo apt-get install make
make
sudo make install

echo "**************************************************************************"
echo "Done!"
echo "**************************************************************************"