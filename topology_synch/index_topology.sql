
drop index l1_s1_idx @ 
create index l1_s1_idx on l1_s1 ( L1,L2,L3) @

drop index l1_s2_idx @ 
create index l1_s2_idx on l1_s1 ( L1,L2,L3) @

drop index l1_s3_idx @ 
create index l1_s3_idx on l1_s1 ( L1,L2,L3) @


commit work @

