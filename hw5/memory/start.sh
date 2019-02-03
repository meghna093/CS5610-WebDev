#!/bin/bash

export PORT=5109

cd ~/www/memory
./bin/memory stop || true
./bin/memory start

