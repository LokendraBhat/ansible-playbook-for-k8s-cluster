#!/bin/bash

spath=$(pwd)

echo "Updating Repositiories and Kernel Version"
dnf update

echo -e "Installing Dependencies\n"
dnf groupinstall 'Development Tools' -y
dnf install wget gcc pcre-devel openssl-devel zlib-devel tar make -y

echo -e "\nDownloading HAProxy Source Tarball\nBy Default it downloads haproxy 2.8.1 for which EOL is 2028"
cd ${spath} && wget https://www.haproxy.org/download/2.8/src/haproxy-2.8.10.tar.gz

echo -e "\nExtracting Tarball"
tar xvzf haproxy-2.8.1.tar.gz

echo -e "\nAdding User and Group for HAProxy Service"
groupadd -g 1005 haproxy && useradd haproxy -u 1005 -g 1005 -s /bin/bash

echo -e "\nInstalling HAProxy From the tarball with OpenSSl Module and prometheus service"
cd ${spath}/haproxy-2.8.10 && make  TARGET=linux-glibc USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1 USE_SYSTEMD=1 && make install

echo -e "\nCreating Required Directories and Files"
mkdir -p /etc/haproxy/conf.d &&  mkdir -p /var/lib/haproxy && touch /var/lib/haproxy/stats

echo -e "\nCopying Init File for systemctl commands and enabling service"
unlink /usr/sbin/haproxy
ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy
cd ${spath}/haproxy-2.8.10 && cp examples/haproxy.cfg /etc/haproxy/haproxy.cfg
#copy these files
#/etc/haproxy/haproxy.cfg
#/usr/lib/systemd/system/haproxy.service
systemctl daemon-reload
systemctl start haproxy
systemctl enable haproxy
