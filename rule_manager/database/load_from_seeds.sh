db2 connect to $1 user $2 using $3
db2 import from content/seed/s2l1_seed.lookup of del modified by coldelX09 insert into rulemgr_rule 
db2 -td@ -vf content/addlike/s2l1_addlike.sql
db2 terminate
