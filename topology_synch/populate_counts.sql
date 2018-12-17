
set serveroutput on @

call populate_l3_counts ()  @

commit work @

