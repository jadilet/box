#!/usr/bin/env bash

PROJECT_PATH="$HOME/OptDyn/Project/packer"
BRANCH=master
VERSION=`cat $PROJECT_PATH/version`
OS=`uname`
PROVIDER=""

if [ "$BRANCH" = "master" ]; then
  BOX=subutai/stretch-master
else
  BOX=subutai/stretch
fi

if [ -n "$1" ]; then
  PROVIDERS="$1"
  for box in $PROVIDERS; do
    case "$box" in
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
      *) echo "Bad hypervisor name in hypervisor list: $box"; exit 1
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


mkdir -p $BRANCH

if [ ! -d "$PROJECT_PATH" ]; then
  echo "Incorrect project path: "$PROJECT_PATH
  exit 1
fi

BUILD_DIRECTORY="$BRANCH/$VERSION"

# clean build directory if exist
#if [ -d $BUILD_DIRECTORY ]; then
#  echo "Removing build directory: "$BUILD_DIRECTORY
#  rm -rf $BRANCH/$VERSION
#fi

mkdir -p $BUILD_DIRECTORY

for hypervizor in $PROVIDERS; do
  # Go project path
  cd $PROJECT_PATH

  #echo 'n' | ./build.sh stretch $hypervizor $BRANCH
  # move box to build directory
  #mv vagrant-subutai-stretch-*.box ~/box/$BUILD_DIRECTORY
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
  rm -f Vagrantfile
  echo "-----------------"
  echo "Provider: "$PROVIDER
  echo "-----------------"

  vagrant init $BOX
  SUBUTAI_ENV=$BRANCH vagrant up --provider $PROVIDER
  vagrant destroy -f
  SUBUTAI_ENV=$BRANCH DISK_SIZE=200 vagrant up --provider $PROVIDER
  vagrant destroy -f
done

