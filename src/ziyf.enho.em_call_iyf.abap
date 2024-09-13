METHOD call_iyf.

  DATA lv_ziyf_enabled TYPE abap_bool.
  DATA lv_program TYPE slin_program_name.

  IF sy-ucomm <> 'WB_CHECK'.
    RETURN.
  ENDIF.

  GET PARAMETER ID 'ZIYF' FIELD lv_ziyf_enabled.
  IF lv_ziyf_enabled = abap_false.
    RETURN.
  ENDIF.

  lv_program = navigation_context+3.

  IF lv_program IS NOT INITIAL.
    CALL FUNCTION 'ZIYF' EXPORTING iv_program = lv_program.
  ENDIF.

ENDMETHOD.
