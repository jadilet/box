#!/usr/bin/env bash

##############################################################
#                     PARAMETER                              #
#------------------------------------------------------------#
# $1 => provider name                                        #
# default values for linux: vmware-iso, virtualbox-iso, qemu #
# default values for osx: parallels-iso                      #
#------------------------------------------------------------#
# $2 => git branch name                                      #
# default value is master                                    #
#------------------------------------------------------------#
# $3 => vagrant box name                                     #
# default values is stretch                                  #
#------------------------------------------------------------#


# default values
PROJECT_PATH="$HOME/packer"
BRANCH=master
VERSION=`cat $PROJECT_PATH/version`
OS=`uname`
BOX=stretch
GIT_REPOSITORY=https://github.com/subutai-io/packer.git

## clean
rm -rf $PROJECT_PATH

## clone packer project
cd $HOME
git clone $GIT_REPOSITORY
cd $PROJECT_PATH

if [ "$2" = "prod" ]; then
  # "master" is prod branch for 
  # vagrant subutai boxes provision script
  BRANCH=prod
  BOX_NAME=subutai/$BOX
  git checkout master
  git pull origin master
else
  # "stage" is master branch for 
  # vagrant subutai boxes provision script
  BOX_NAME=subutai/$BOX-master
  git checkout stage
  git pull origin stage
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


mkdir -p $HOME/$BRANCH
pkdir -p $HOME/$BRANCH/$BOX

if [ ! -d "$PROJECT_PATH" ]; then
  echo "Incorrect project path: "$PROJECT_PATH
  exit 1
fi

BUILD_DIRECTORY="$HOME/$BRANCH/$BOX/$VERSION"

# clean build directory if exist
if [ -d $BUILD_DIRECTORY ]; then
  echo "Removing build directory: "$BUILD_DIRECTORY
  rm -rf $BRANCH/$VERSION
fi

mkdir -p $BUILD_DIRECTORY

for hypervizor in $PROVIDERS; do
  # Go project path
  cd $PROJECT_PATH

  echo 'n' | ./build.sh $BOX $hypervizor $BRANCH

  if [ $? -gt 0 ]; then
    exit 1
  fi

  # move box to build directory
  mv vagrant-subutai-$BOX-*.box $BUILD_DIRECTORY
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

  mkdir -p $PROJECT_PATH/test
  cd $PROJECT_PATH/test
  # clean 
  rm -rf .vagrant
  rm -f Vagrantfile
  echo "-----------------"
  echo "Provider: "$PROVIDER
  echo "-----------------"

  vagrant init $BOX_NAME
  SUBUTAI_ENV=$BRANCH vagrant up --provider $PROVIDER
  vagrant destroy -f
  SUBUTAI_ENV=$BRANCH DISK_SIZE=200 vagrant up --provider $PROVIDER
  vagrant destroy -f
done

