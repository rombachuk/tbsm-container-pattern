
rm *.log
db2 connect to $1 user $2 using $3
db2 -td@ -vf create_rulemgr_schema.sql > reload.log
db2 -td@ -vf create_rulemgr_sp.sql >> reload.log
db2 terminate
./load_from_seeds.sh $1 $2 $3
