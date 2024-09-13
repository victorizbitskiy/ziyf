FUNCTION-POOL ziyf.                         "MESSAGE-ID ..

TYPES:
  BEGIN OF gty_parse_result,
    errors   TYPE i,
    warnings TYPE i,
  END OF gty_parse_result.

DATA ok_code LIKE sy-ucomm.
DATA gv_program TYPE slin_program_name.
DATA go_container TYPE REF TO cl_gui_custom_container.
DATA gv_errors_info TYPE string.
DATA gv_warnings_info TYPE string.
