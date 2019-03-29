cd additional_policies
./TBSM_rm_project_push_policies.sh $1 $2 $3
cp tbsmshell*.sh $HOME
cd ..
cp -r opviewassets/rm $3/opview/assets
cp -r opviewdisplays/*.html $3/opview/displays

