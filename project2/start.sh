#!/bin/bash

export PORT=5103

cd ~/www/stormchat
./bin/stormchat stop || true
./bin/stormchat start

