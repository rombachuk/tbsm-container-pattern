cd additional_policies
./TBSM_rm_project_push_policies.sh $1 $2 $3
cd ..
cp -r opviewassets/rm $3/opview/assets
cp -r opviewdisplays/*.html $3/opview/displays
cd database
./reload.sh $4 $5 $6

