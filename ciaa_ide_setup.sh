#!/bin/sh
#
# Copyright 2015, Pablo Ridolfi. All rights reserved.
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
ciaa_script_path=/vagrant
ciaa_ide_path=/vagrant/ciaa-ide

echo ""
echo "**************************************"
echo "Instalation script for CIAA-IDE-Linux."
echo "**************************************"

echo ""
if [ $arch = x86_64 ]
then
	echo "**********************************************"
	echo "1) Installing additional packages (64-bits)..."
	echo "**********************************************"
	sudo apt-get update
	sudo apt-get -y install php5-cli --fix-missing
else
	echo "**********************************************"
	echo "1) Installing additional packages (32-bits)..."
	echo "**********************************************"
	sudo apt-get update
	sudo apt-get -y install php5-cli --fix-missing
fi

echo ""
echo "*********************************"
echo "2) Adding $USER to dialout group."
echo "*********************************"
sudo adduser $USER dialout

echo ""
echo "**********************************************"
echo "3) Creating folder $ciaa_ide_path..."
echo "**********************************************"
mkdir $ciaa_ide_path
cd $ciaa_ide_path

echo ""
echo "*******************************************************"
echo "4) Downloading and unpacking arm-none-eabi toolchain..."
echo "*******************************************************"
wget https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q1-update/+download/gcc-arm-none-eabi-4_9-2015q1-20150306-linux.tar.bz2
tar -xjvf gcc-arm-none-eabi-4_9-2015q1-20150306-linux.tar.bz2
toolchain_path=$ciaa_ide_path/gcc-arm-none-eabi-4_9-2015q1

echo ""
echo "*************************************************"
echo "4) Downloading, unpacking and building OpenOCD..."
echo "*************************************************"
wget http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.9.0/openocd-0.9.0.tar.bz2
tar -xvjf openocd-0.9.0.tar.bz2
openocd_path=$ciaa_ide_path/openocd-0.9.0
cd $openocd_path
./configure --enable-ftdi
make

echo ""
echo "**********************************************"
echo "5) Adding udev rules and restarting service..."
echo "**********************************************"
sudo cp $openocd_path/contrib/99-openocd.rules /etc/udev/rules.d/
sudo service udev restart

echo ""
echo "******************************************"
echo "6) Cloning CIAA-Firmware GIT repository..."
echo "******************************************"
cd $ciaa_ide_path
sudo apt-get -y install git
git clone --recursive https://github.com/juliani2/Firmware.git

echo ""
if [ $arch = x86_64 ]
then
	echo "*****************************************"
	echo "7) Downloading Eclipse C/C++ (64-bits)..."
	echo "*****************************************"
	wget http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/luna/SR2/eclipse-cpp-luna-SR2-linux-gtk-x86_64.tar.gz
	tar -xzvf eclipse-cpp-luna-SR2-linux-gtk-x86_64.tar.gz
else
	echo "*****************************************"
	echo "7) Downloading Eclipse C/C++ (32-bits)..."
	echo "*****************************************"
	wget http://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/luna/SR2/eclipse-cpp-luna-SR2-linux-gtk.tar.gz
	tar -xzvf eclipse-cpp-luna-SR2-linux-gtk.tar.gz
fi

echo ""
if [ $arch = x86_64 ]
then
	echo "**********************************************"
	echo "8) Downloading and installing JRE (64-bits)..."
	echo "**********************************************"
 	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jre-7u79-linux-x64.tar.gz
	cd $ciaa_ide_path/eclipse
	tar -xzvf ../jre-7u79-linux-x64.tar.gz
else
	echo "**********************************************"
	echo "8) Downloading and installing JRE (32-bits)..."
	echo "**********************************************"
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jre-7u79-linux-i586.tar.gz
	cd $ciaa_ide_path/eclipse
	tar -xzvf ../jre-7u79-linux-i586.tar.gz
fi
mv jre1.7.0_79/ jre/

echo ""
echo "**************************"
echo "9) Writing start script..."
echo "**************************"
cd $ciaa_ide_path
echo "#!/bin/sh
export PATH=\$PATH:$toolchain_path/bin:$openocd_path/src
echo \"Starting CIAA-IDE...\"
$ciaa_ide_path/eclipse/eclipse &" > ciaa-ide
chmod +x ciaa-ide

echo ""
echo "*****************************"
echo "10) Updating splash screen..."
echo "*****************************"
cd $ciaa_ide_path
wget http://www.proyecto-ciaa.com.ar/devwiki/lib/exe/fetch.php?media=docu:fw:bm:ide:splash.bmp.tar.gz -O splash.bmp.tar.gz
cd eclipse/plugins/org.eclipse.platform_4.4.2.v20150204-1700/
mv splash.bmp splash.bmp.old
tar -xzvf ../../../splash.bmp.tar.gz

echo ""
echo "*****************************"
echo "11) Move .cproject and .project..."
echo "*****************************"
mv $ciaa_script_path/project  $ciaa_ide_path/Firmware/.project
mv $ciaa_script_path/cproject $ciaa_ide_path/Firmware/.cproject

echo ""
echo "*****************************"
echo "12) Delete bz2 and gz files"
echo "*****************************"
cd $ciaa_ide_path
rm *.gz
rm *.bz2
rm *.bz2.*

echo ""
echo "****************************************************************************************"
echo "Done! You can run CIAA-IDE by executing"
echo "$ $ciaa_ide_path/ciaa-ide"
echo "Remember to install GNU ARM plug-in on Eclipse (http://gnuarmeclipse.livius.net/)."
echo "Help > Install New Software... > Work with: http://gnuarmeclipse.sourceforge.net/updates"
echo "****************************************************************************************"