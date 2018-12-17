
set serveroutput on @

call populate_ran_pool_counts ()  @

commit work @

call populate_ran_bsc_counts ()  @

commit work @

call populate_ran_rnc_counts ()  @

commit work @

call populate_ran_enodeb_counts ()  @

commit work @

call populate_ran_nodeb_counts ()  @

commit work @

call populate_ran_bts_counts ()  @

commit work @

#call populate_ran_sitesector_counts ()  @

commit work @

call populate_ran_site_counts ()  @

commit work @

