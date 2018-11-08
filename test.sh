#!/usr/bin/env bash

##############################################################
#                     PARAMETER                              #
#------------------------------------------------------------#
# $1 => provider name                                        #
# default values for linux: vmware-iso, virtualbox-iso, qemu #
# default values for osx: parallels-iso                      #
#------------------------------------------------------------#
# $2 => git branch name                                      #
# default value is prod                                      #
#------------------------------------------------------------#
# $3 => vagrant box name                                     #
# default values is stretch (stretch, xenial)                #
#------------------------------------------------------------#


# default values
BRANCH=prod
OS=`uname`
BOX=stretch

if [ -n "$3" ]; then
  $BOX=$3
fi

if [ "$2" = "master" ]; then
  # "master" is prod branch for 
  # vagrant subutai boxes provision script
  BRANCH=master
  BOX_NAME=subutai/$BOX-master
else
  # "stage" is master branch for 
  # vagrant subutai boxes provision script
  BOX_NAME=subutai/$BOX
fi

if [ -n "$1" ]; then
  PROVIDERS="$1"
  for provider in $PROVIDERS; do
    case "$provider" in
      "vmware-iso")
        break
        ;;
      "virtualbox-iso")
        break
        ;;
      "qemu")
        break
        ;;
      "parallels-iso")
        break
        ;;
      *) echo "Bad hypervisor name in hypervisor list: $provider"; exit 1
        ;;
    esac
  done
elif [ -z "$PROVIDERS" ]; then
   if [ $OS = "Darwin" ]; then
     PROVIDERS='parallels-iso'
   else
     PROVIDERS='vmware-iso virtualbox-iso qemu'
   fi
fi

PEER_DIRECTORY="$HOME/peer"

# clean build directory if exist
if [ -d $BUILD_DIRECTORY ]; then
  echo "Removing build directory: "$PEER_DIRECTORY
  rm -rf $PEER_DIRECTORY
fi

mkdir -p $PEER_DIRECTORY

for hypervizor in $PROVIDERS; do
  # Go project path
  cd $PEER_DIRECTORY

  case "$hypervizor" in
      "vmware-iso")
        PROVIDER="vmware_desktop";
        ;;
      "virtualbox-iso")
        PROVIDER="virtualbox";
        ;;
      "qemu")
        PROVIDER="libvirt";
        ;;
      "parallels-iso")
        PROVIDER="parallels";
        ;;
  esac

  # clean 
  rm -rf .vagrant
  rm -f Vagrantfile
  echo "-----------------"
  echo "Provider: "$PROVIDER
  echo "-----------------"
  # update boxes
  vagrant box update --box $BOX_NAME --provider $PROVIDER

  vagrant init $BOX_NAME
  SUBUTAI_ENV=$BRANCH vagrant up --provider $PROVIDER
  vagrant destroy -f
  SUBUTAI_ENV=$BRANCH DISK_SIZE=200 vagrant up --provider $PROVIDER
  vagrant destroy -f
done

