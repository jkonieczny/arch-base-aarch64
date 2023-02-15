FROM scratch
MAINTAINER binhex

# additional files
##################

# add supervisor conf file
ADD build/*.conf /etc/supervisor.conf

# add install bash script
ADD build/root/*.sh /root/

# add statically linked busybox arm64
ADD build/utils/busybox/busybox /bootstrap/busybox

# unpack tarball
################

# symlink busybox utilities to /bootstrap folder
RUN ["/bootstrap/busybox", "--install", "-s", "/bootstrap"]

# run busybox bourne shell and use sub shell to execute busybox utils (wget, rm...)
# to download and extract tarball. 
# once the tarball is extracted we then use bash to execute the install script to
# install everything else for the base image.
# note, do not line wrap the below command, as it will fail looking for /bin/sh
RUN ["/bootstrap/sh", "-c", "/bootstrap/wget -O /bootstrap/archlinux.tar.gz http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz && /bootstrap/tar --exclude=./etc/resolv.conf --exclude=./etc/hostname --exclude=./etc/hosts -xvf /bootstrap/archlinux.tar.gz -C /"]

RUN ["/usr/sbin/chmod +x /root/install.sh"]

RUN ["/bin/bash -c /root/install.sh"]

# env
#####

# set environment variables for user nobody
ENV HOME /home/nobody

# set environment variable for terminal
ENV TERM xterm

# set environment variables for language
ENV LANG en_GB.UTF-8

# run
#####

# run tini to manage graceful exit and zombie reaping
ENTRYPOINT ["/usr/bin/tini", "--"]
