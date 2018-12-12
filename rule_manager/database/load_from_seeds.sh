db2 connect to $1 user $2 using $3
db2 import from content/seed/env_seed.lookup of del modified by coldelX09 insert into rulemgr_rule 
db2 -td@ -vf content/addlike/env_addlike.sql
db2 terminate
