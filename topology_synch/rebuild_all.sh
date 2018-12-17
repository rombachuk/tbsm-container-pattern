$4/sqllib/bin/db2 connect to $1 user $2 using $3
$4/sqllib/bin/db2 -td@ -vf create_topology.sql
$4/sqllib/bin/db2 -td@ -vf create_counts.sql
$4/sqllib/bin/db2 -td@ -vf create_info.sql
$4/sqllib/bin/db2 -td@ -vf create_status.sql
$4/sqllib/bin/db2 -td@ -vf import_topology.sql
$4/sqllib/bin/db2 -td@ -vf index_topology.sql
$4/sqllib/bin/db2 -td@ -vf index_counts.sql
$4/sqllib/bin/db2 -td@ -vf index_info.sql
$4/sqllib/bin/db2 -td@ -vf index_status.sql
$4/sqllib/bin/db2 -td@ -vf populate_counts_tables.sql
$4/sqllib/bin/db2 -td@ -vf populate_info_tables.sql
$4/sqllib/bin/db2 terminate
