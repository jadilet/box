#!/usr/bin/env bash

PLUGIN_PATH=~/vagrant-subutai.gem

# clean plugin file if exist
if [ -e $PLUGIN_PATH ]; then
  rm $PLUGIN_PATH
fi

# download latest built Vagrant Subutai plugin
curl -o $PLUGIN_PATH -L "https://masterbazaar.subutai.io/rest/v1/cdn/raw?name=vagrant-subutai.gem&latest&download"

vagrant plugin uninstall vagrant-subutai
vagrant plugin install $PLUGIN_PATH

if [ $? = 0 ]; then
  echo " ---------------------------------------------------------"
  echo "| SUCCESSFULLY UPDATED THE LASTEST VAGRANT SUBUTAI PLUGIN |"
  echo " ---------------------------------------------------------"
else
  echo " -----------------------------------------------------"
  echo "| FAILED TO UPDATE THE LASTEST VAGRANT SUBUTAI PLUGIN |"
  echo " -----------------------------------------------------"
fi
