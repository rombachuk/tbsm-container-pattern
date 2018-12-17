#!/bin/bash
su - bsmadmin -c "nohup /usr/bin/python $1/sitestatus-tracker.py $1/ >/dev/null 2>&1 &"
