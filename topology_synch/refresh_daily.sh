$4/sqllib/bin/db2 connect to $1 user $2 using $3
$4/sqllib/bin/db2 -td@ -vf import_topology.sql > import_topology.log
$4/sqllib/bin/db2 -td@ -vf populate_counts.sql > populate_counts.log
$4/sqllib/bin/db2 -td@ -vf populate_info.sql > populate_info.log
