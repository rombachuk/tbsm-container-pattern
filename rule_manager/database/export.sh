#!/bin/bash
now=`date +%Y%m%d%H%M%S`
db2 connect to $1 user $2 using $3
db2 export to content/export/rulemgr_rule.$now.del of del modified by coldelX09 select '*' from rulemgr_rule 
db2 terminate
