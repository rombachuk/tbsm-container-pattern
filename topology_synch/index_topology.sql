
drop index d1_l1_idx @ 
create index dl_l1_idx on d1_l1 ( L1,L2,L3) @

drop index d2_l1_idx @ 
create index d2_l1_idx on d2_l1 ( L1,L2,L3) @

drop index d3_l1_idx @ 
create index d3_l1_idx on d3_l1 ( L1,L2,L3) @

drop index d4_l2_idx @ 
create index d4_l2_idx on d4_l2 ( L2,L3) @


commit work @

