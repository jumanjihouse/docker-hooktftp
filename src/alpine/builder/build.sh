#!/bin/sh
set -e

# Do not build as root!
[ $(id -u) -eq 0 ] && exit 1

mkdir -p $HOME/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
go get github.com/epeli/hooktftp
cp $GOPATH/bin/hooktftp /tmp/
