#!/bin/bash

export PORT=5103
export MIX_ENV=prod
export GIT_PATH=/home/stormchat/src/stormchat

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
  echo "Error: Must check out git repo to $GIT_PATH"
  echo "  Current directory is $PWD"
  exit 1
fi

if [ $USER != "stormchat" ]; then
  echo "Error: must run as user 'stormchat'"
  echo "  Current user is $USER"
  exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/stormchat ]; then
  echo mv ~/www/stormchat ~/old/$NOW
  mv ~/www/stormchat ~/old/$NOW
fi

mkdir -p ~/www/stormchat
REL_TAR=~/src/stormchat/_build/prod/rel/stormchat/releases/0.0.1/stormchat.tar.gz
(cd ~/www/stormchat && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/stormchat/src/stormchat/start.sh
CRONTAB

#. start.sh
