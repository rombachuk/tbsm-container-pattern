#!/bin/bash
db2 connect to $1 user $2 using $3
db2 import from content/export/rulemgr_rule.$4.del of del modified by coldelX09 replace into rulemgr_rule 
db2 terminate
