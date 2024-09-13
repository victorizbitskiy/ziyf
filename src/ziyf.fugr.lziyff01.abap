*----------------------------------------------------------------------*
***INCLUDE LZIYFF01.
*----------------------------------------------------------------------*
FORM pbo.

  CONSTANTS lc_go_to_slin_button_name TYPE screen-name VALUE 'GO_TO_SLIN'.

  DATA lv_picture_name TYPE w3objid.
  DATA ls_result_stat TYPE slin_result_stat.
  DATA ls_parse_result TYPE ty_parse_result.

  PERFORM set_pf_status_and_titlebar.
  PERFORM set_invisible USING lc_go_to_slin_button_name '0'.
  PERFORM extended_program_check USING gv_program CHANGING ls_result_stat.
  PERFORM parse_program_check_result USING ls_result_stat CHANGING ls_parse_result.
  PERFORM set_info_fields USING ls_parse_result CHANGING gv_errors_info gv_warnings_info.
  PERFORM get_picture_name USING ls_parse_result CHANGING lv_picture_name.
  PERFORM load_picture USING lv_picture_name.

  IF ls_parse_result-errors IS INITIAL AND ls_parse_result-warnings IS INITIAL.
    PERFORM set_invisible USING lc_go_to_slin_button_name '1'.
  ENDIF.

ENDFORM.

FORM extended_program_check USING iv_program TYPE slin_program_name
                            CHANGING cs_result TYPE slin_result_stat.

  DATA ls_test_flags TYPE rslin_test_flags.

  ls_test_flags-x_per = abap_true.
  ls_test_flags-x_cal = abap_true.
  ls_test_flags-x_dat = abap_true.
  ls_test_flags-x_opf = abap_true.
  ls_test_flags-x_unr = abap_true.
  ls_test_flags-x_ges = abap_true.
  ls_test_flags-x_mes = abap_true.
  ls_test_flags-x_pfs = abap_true.
  ls_test_flags-x_bre = abap_true.
  ls_test_flags-x_woo = abap_false.
  ls_test_flags-x_wrn = abap_true.
  ls_test_flags-x_ste = abap_true.
  ls_test_flags-x_txt = abap_true.
  ls_test_flags-x_aut = abap_true.
  ls_test_flags-x_sub = abap_true.
  ls_test_flags-x_loa = abap_true.
  ls_test_flags-x_mls = abap_true.
  ls_test_flags-x_put = abap_false.
  ls_test_flags-x_hel = abap_false.
  ls_test_flags-x_sec = abap_false.

  CALL FUNCTION 'EXTENDED_PROGRAM_CHECK'
    EXPORTING
      program     = iv_program
      test_flags  = ls_test_flags
    IMPORTING
      result_stat = cs_result.

ENDFORM.

FORM set_pf_status_and_titlebar.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDFORM.

FORM set_invisible USING iv_fieldname TYPE screen-name
                         iv_value TYPE screen-invisible.

  LOOP AT SCREEN.
    IF screen-name = iv_fieldname.
      screen-invisible = iv_value.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM parse_program_check_result USING is_result_stat TYPE slin_result_stat
                                CHANGING cs_result TYPE ty_parse_result.

  DATA ls_set LIKE LINE OF is_result_stat-set.

  LOOP AT is_result_stat-set INTO ls_set WHERE ecnt IS NOT INITIAL OR wcnt IS NOT INITIAL.
    cs_result-errors = cs_result-errors + ls_set-ecnt.
    cs_result-warnings = cs_result-warnings + ls_set-wcnt.
  ENDLOOP.

ENDFORM.

FORM set_info_fields USING is_parse_result TYPE ty_parse_result
                     CHANGING cv_errors_info TYPE string
                              cv_warnings_info TYPE string.

  DATA lv_errors TYPE string.
  DATA lv_warnings TYPE string.

  lv_errors = is_parse_result-errors.
  lv_warnings = is_parse_result-warnings.

  CONCATENATE lv_errors 'errors' INTO cv_errors_info.
  CONCATENATE lv_warnings 'warnings' INTO cv_warnings_info.

ENDFORM.

FORM get_picture_name USING is_parse_result TYPE ty_parse_result
                      CHANGING cv_picture_name TYPE w3objid.

  CONSTANTS:
    BEGIN OF lc_face,
      mr_incredible TYPE c LENGTH '1' VALUE '1',
      doomguy       TYPE c LENGTH '1' VALUE '2',
    END OF lc_face.

  CONSTANTS:
    BEGIN OF lc_mr_incredible_picture,
      errors   TYPE w3objid VALUE 'ZIYF_HAS_ERRORS_FACE',
      warnings TYPE w3objid VALUE 'ZIYF_HAS_WARNINGS_FACE',
      ok       TYPE w3objid VALUE 'ZIYF_OK_FACE',
    END OF lc_mr_incredible_picture.

  CONSTANTS:
    BEGIN OF lc_doomguy_picture,
      errors   TYPE w3objid VALUE 'ZIYF_HAS_ERRORS_DOOM_FACE',
      warnings TYPE w3objid VALUE 'ZIYF_HAS_WARNINGS_DOOM_FACE',
      ok       TYPE w3objid VALUE 'ZIYF_OK_DOOM_FACE',
    END OF lc_doomguy_picture.

  DATA lv_face TYPE c LENGTH 1.

  GET PARAMETER ID 'ZIYF_FACE' FIELD lv_face.

  IF is_parse_result-errors IS NOT INITIAL.
    IF lv_face = lc_face-mr_incredible OR lv_face IS INITIAL.
      cv_picture_name = lc_mr_incredible_picture-errors.
    ENDIF.
    IF lv_face = lc_face-doomguy.
      cv_picture_name = lc_doomguy_picture-errors.
    ENDIF.
  ENDIF.

  IF is_parse_result-errors IS INITIAL AND is_parse_result-warnings IS NOT INITIAL.
    IF lv_face = lc_face-mr_incredible OR lv_face IS INITIAL.
      cv_picture_name = lc_mr_incredible_picture-warnings.
    ENDIF.
    IF lv_face = lc_face-doomguy.
      cv_picture_name = lc_doomguy_picture-warnings.
    ENDIF.
  ENDIF.

  IF is_parse_result-errors IS INITIAL AND is_parse_result-warnings IS INITIAL.
    IF lv_face = lc_face-mr_incredible OR lv_face IS INITIAL.
      cv_picture_name = lc_mr_incredible_picture-ok.
    ENDIF.
    IF lv_face = lc_face-doomguy.
      cv_picture_name = lc_doomguy_picture-ok.
    ENDIF.
  ENDIF.

ENDFORM.

FORM load_picture USING iv_picture_name TYPE w3objid.

  DATA lv_url TYPE cndp_url.
  DATA lo_picture_control TYPE REF TO cl_gui_picture.

  CALL FUNCTION 'DP_PUBLISH_WWW_URL'
    EXPORTING
      objid                 = iv_picture_name
      lifetime              = 'T'
    IMPORTING
      url                   = lv_url
    EXCEPTIONS
      dp_invalid_parameters = 1
      no_object             = 2
      dp_error_publish      = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF go_container IS BOUND.
    go_container->free(
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3 ).
  ENDIF.

  IF lo_picture_control IS BOUND.
    lo_picture_control->free(
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3 ).
  ENDIF.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'PICTURE_CONTROL'.

  CREATE OBJECT lo_picture_control EXPORTING parent = go_container.
  lo_picture_control->load_picture_from_url_async( lv_url ).
  lo_picture_control->set_display_mode( cl_gui_picture=>display_mode_stretch ).

ENDFORM.

FORM pai.

  DATA lt_bdcdata TYPE STANDARD TABLE OF bdcdata.
  DATA ls_bdcdata LIKE LINE OF lt_bdcdata.
  DATA lx_root TYPE REF TO cx_root.

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      go_container->free(
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3 ).
      LEAVE TO SCREEN 0.
    WHEN 'GO_TO_SLIN'.
      ls_bdcdata-program = gv_program.
      ls_bdcdata-dynpro = '0100'.
      ls_bdcdata-dynbegin = 'X'.
      APPEND ls_bdcdata TO lt_bdcdata.

      TRY.
          CALL TRANSACTION 'SLIN' WITH AUTHORITY-CHECK USING lt_bdcdata.
        CATCH cx_root INTO lx_root.
          lx_root->get_text( ).
      ENDTRY.
  ENDCASE.

ENDFORM.
