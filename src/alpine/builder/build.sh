#!/bin/sh
set -e

# Do not build as root!
[ $(id -u) -eq 0 ] && exit 1

source $HOME/HOOKTFTP_VERSION

mkdir -p $HOME/go/bin
mkdir -p $HOME/go/src/github.com/tftp-go-team/
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
git clone https://github.com/tftp-go-team/hooktftp.git ~/go/src/github.com/tftp-go-team/hooktftp
cd ~/go/src/github.com/tftp-go-team/hooktftp
git checkout ${HOOKTFTP_VERSION}

# We want static binary.
# Caution: the binary gets built dynamically linked.
# Need to figure out where else to patch or
# perhaps just build as an alpine package.
cd src/
patch -p0 -u -i /home/user/patch0

# We don't have `atftp', so use `tftp' instead.
cd ../test/
patch -p0 -u -i /home/user/patch1
cd ..

make build
make test
cp /home/user/go/src/github.com/tftp-go-team/hooktftp/src/hooktftp /tmp/
