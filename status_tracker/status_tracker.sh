#!/bin/bash
su - $2 -c "nohup /usr/bin/python $1/status_tracker.py $1/ >/dev/null 2>&1 &"
