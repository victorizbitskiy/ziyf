METHOD call_iyf.

  DATA lv_ziyf_enabled TYPE abap_bool.
  DATA lt_active_tools TYPE wmngr_tool_list.
  DATA ls_active_tools LIKE LINE OF lt_active_tools.
  DATA lo_wb_pgeditor TYPE REF TO cl_wb_pgeditor.
  DATA lx_root TYPE REF TO cx_root.
  DATA lv_program TYPE slin_program_name.

  IF sy-ucomm <> 'WB_CHECK'.
    RETURN.
  ENDIF.

  GET PARAMETER ID 'ZIYF' FIELD lv_ziyf_enabled.
  IF lv_ziyf_enabled = abap_false.
    RETURN.
  ENDIF.

  lt_active_tools = tool_manager->get_active_tools( ).
  READ TABLE lt_active_tools INTO ls_active_tools INDEX 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  TRY.
      lo_wb_pgeditor ?= ls_active_tools->ref.
      lv_program = lo_wb_pgeditor->source_id.
    CATCH cx_root INTO lx_root.
  ENDTRY.
  IF lv_program IS NOT INITIAL.
    CALL FUNCTION 'ZIYF' EXPORTING iv_program = lv_program.
  ENDIF.

ENDMETHOD.
