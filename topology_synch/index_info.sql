
drop index cells_4g_ele_idx @
create index cells_4g_ele_idx on cells_4g ( ElementName1,ElementName2,ElementName3,ElementName4,ElementName5,ElementName6,EventCategory,Location,VFElementName) @
drop index cells_4g_ele_idx2 @
create index cells_4g_ele_idx2 on cells_4g ( Location,TechDomain4,ElementName4,EventCategory) @
drop index cells_4g_ele_idx3 @
create index cells_4g_ele_idx3 on cells_4g ( VFElementName,TechDomain6) @
drop index cells_4g_ele_idx4 @
create index cells_4g_ele_idx4 on cells_4g ( Location,ElementName6) @
drop index cells_4g_ele_idx5 @
create index cells_4g_ele_idx5 on cells_4g ( Location,VFElementName) @

drop index cells_3g_ele_idx @
create index cells_3g_ele_idx on cells_3g ( ElementName1,ElementName2,ElementName3,ElementName4,ElementName5,ElementName6,EventCategory,Location,VFElementName) @
drop index cells_3g_ele_idx2 @
create index cells_3g_ele_idx2 on cells_3g ( Location,TechDomain4,ElementName4,EventCategory) @
drop index cells_3g_ele_idx3 @
create index cells_3g_ele_idx3 on cells_3g ( VFElementName,TechDomain6) @
drop index cells_3g_ele_idx4 @
create index cells_3g_ele_idx4 on cells_3g ( Location,ElementName6) @
drop index cells_3g_ele_idx5 @
create index cells_3g_ele_idx5 on cells_3g ( Location,VFElementName) @

drop index cells_2g_ele_idx @
create index cells_2g_ele_idx on cells_2g ( ElementName1,ElementName2,ElementName3,ElementName4,ElementName5,ElementName6,EventCategory,Location,VFElementName) @
drop index cells_2g_ele_idx2 @
create index cells_2g_ele_idx2 on cells_2g ( Location,TechDomain4,ElementName4,EventCategory) @
drop index cells_2g_ele_idx3 @
create index cells_2g_ele_idx3 on cells_2g ( VFElementName,TechDomain6) @
drop index cells_2g_ele_idx4 @
create index cells_2g_ele_idx4 on cells_2g ( Location,ElementName6) @
drop index cells_2g_ele_idx5 @
create index cells_2g_ele_idx5 on cells_2g ( Location,VFElementName) @

commit work @

