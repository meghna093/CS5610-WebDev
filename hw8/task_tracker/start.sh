#!/bin/bash

export PORT=5105

cd ~/www/task_tracker
./bin/task_tracker stop || true
./bin/task_tracker start
