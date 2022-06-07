#!/bin/bash

sudo touch /usr/local/rke2-download.log
sudo chmod 666 /usr/local/rke2-download.log
exec >/usr/local/rke2-download.log 2>&1

set -e

export INSTALL_RKE2_METHOD="yum"
export INSTALL_RKE2_TYPE="${type}"
export INSTALL_RKE2_VERSION="${rke2_version}"

read_os() {
  ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
  VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
}

get_installer() {
  curl -fsSL https://get.rke2.io -o install.sh
  chmod u+x install.sh
}

{
  echo "*** Begin RKE2 download and install script ***"

  read_os
  get_installer

  case $ID in
  centos)
    yum install -y unzip

    case $VERSION in
    7*)
      echo "Detected CentOS 7"
      ./install.sh

      ;;
    8*)
      echo "Detected CentOS 8"
      ./install.sh

      ;;
    esac
    ;;

  rhel)
    yum install -y unzip

    case $VERSION in
    7*)
      echo "Detected RHEL 7"
      yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
      ./install.sh
      ;;
    8*)
      echo "Detected RHEL 8"
      ./install.sh
      ;;
    esac
    ;;

  *)
    echo "$${ID} $${VERSION} is not currently supported"
    exit 1
    ;;
  esac

  echo "*** End  RKE2 download and install script ***"
}
