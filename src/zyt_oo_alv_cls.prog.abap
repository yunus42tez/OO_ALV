*&---------------------------------------------------------------------*
*& Include          ZYT_OO_ALV_CLS
*&---------------------------------------------------------------------*

CLASS cl_event_receiver DEFINITION.
  PUBLIC SECTION.

    METHODS:
      handle_top_of_page
        FOR EVENT top_of_page OF cl_gui_alv_grid
        IMPORTING
          e_dyndoc_id
          table_index.

    METHODS:
      handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_row_id
          e_column_id.

    METHODS:
      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no.
    METHODS:
      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed
          e_onf4
          e_onf4_before
          e_onf4_after
          e_ucomm.

    METHODS:
      handle_onf4
        FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname
          e_fieldvalue
          es_row_no
          er_event_data
          et_bad_cells
          e_display .


ENDCLASS.


CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_top_of_page.
  ENDMETHOD.

  METHOD handle_hotspot_click.

    READ TABLE gt_alv_table INTO gs_alv_table INDEX e_row_id .
    IF sy-subrc EQ 0.
      CASE e_column_id.
        WHEN 'OPBEL'.
          SET PARAMETER ID 'E_PRINTDOC' FIELD gs_alv_table-opbel.
          CALL TRANSACTION 'EA40' AND SKIP FIRST SCREEN .
        WHEN 'ANLAGE'.
          SET PARAMETER ID 'ANL' FIELD gs_alv_table-anlage.
          CALL TRANSACTION 'ES32' AND SKIP FIRST SCREEN.

      ENDCASE.

    ENDIF.

  ENDMETHOD.

  METHOD handle_double_click.
  ENDMETHOD.

  METHOD handle_data_changed.

    DATA:ls_modi     TYPE lvc_s_modi.
    DATA: lt_total_amount_temp TYPE erdk-total_amnt.
    CLEAR lt_total_amount_temp.

    LOOP AT er_data_changed->mt_good_cells INTO ls_modi. " f4 yerine manuel giriş.

      READ TABLE gt_alv_table INTO gs_alv_table INDEX ls_modi-row_id.

      IF sy-subrc EQ 0.
        lt_total_amount_temp = gs_alv_table-total_amnt.

        CASE ls_modi-fieldname.
          WHEN 'KATSAYI'.
            LOOP AT gt_alv_table INTO gs_alv_table.

              IF ls_modi-value EQ 0.
                " gs_alv_table-ceza = 0.

              ELSEIF ls_modi-value EQ 2.
                gs_alv_table-ceza =  2 *  lt_total_amount_temp.

              ELSEIF ls_modi-value EQ 3.
                gs_alv_table-ceza =  3 *  lt_total_amount_temp.

              ELSEIF ls_modi-value EQ 5.
                gs_alv_table-ceza =  5 *  lt_total_amount_temp.

              ELSE.
                MESSAGE 'Geçersiz giriş tekrar deneyiniz ! (Olası girişler 2,3,5)' TYPE 'I'.
                EXIT.

              ENDIF.

              er_data_changed->modify_cell(  "2. döndü olmadan burası çalışmıyor.
            EXPORTING
               i_row_id    = ls_modi-row_id
               i_tabix     = sy-tabix
               i_fieldname = 'CEZA'
               i_value     = gs_alv_table-ceza
               ).

            ENDLOOP.

            IF gs_alv_table-ceza >= 1000.

              gs_cell-fname = 'CEZA'.
              gs_cell-color-col = '6'.
              gs_cell-color-int = '1'.
              gs_cell-color-inv = '0'.

              APPEND gs_cell TO gs_alv_table-cell_color.
              MODIFY gt_alv_table FROM gs_alv_table INDEX ls_modi-row_id TRANSPORTING cell_color.
            ENDIF.

            go_alv->refresh_table_display( ). " performans kazanmak için döndügen çıkar.

        ENDCASE.
      ENDIF.
    ENDLOOP.


*********************************************************************************

    IF gv_f4_id NE 0.  " f4 ile seçim yapıldığında.

      READ TABLE gt_alv_table INTO gs_alv_table INDEX gv_f4_id.
      gs_alv_table-ceza = gs_alv_table-katsayi * gs_alv_table-total_amnt.
      ls_modi-row_id = gv_f4_id.

      MODIFY gt_alv_table FROM gs_alv_table INDEX gv_f4_id TRANSPORTING ceza.

      IF gs_alv_table-ceza >= 1000.

        gs_cell-fname = 'CEZA'.
        gs_cell-color-col = '6'.
        gs_cell-color-int = '1'.
        gs_cell-color-inv = '0'.


        APPEND gs_cell TO gs_alv_table-cell_color.
        MODIFY gt_alv_table FROM gs_alv_table INDEX gv_f4_id TRANSPORTING cell_color.
        go_alv->refresh_table_display( ).

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD handle_onf4.

    TYPES: BEGIN OF gty_cezacarpani_f4_valuetab,
             katsayi TYPE int4,
           END OF gty_cezacarpani_f4_valuetab.

    DATA: lt_cezacarpani_f4_valuetab TYPE TABLE OF gty_cezacarpani_f4_valuetab,
          ls_cezacarpani_f4_valuetab TYPE  gty_cezacarpani_f4_valuetab.

    DATA: lt_return_tab TYPE TABLE OF ddshretval,
          ls_return_tab TYPE ddshretval.

    CLEAR: ls_cezacarpani_f4_valuetab.
    ls_cezacarpani_f4_valuetab-katsayi = '2'.
    APPEND ls_cezacarpani_f4_valuetab TO lt_cezacarpani_f4_valuetab.

    CLEAR: ls_cezacarpani_f4_valuetab.
    ls_cezacarpani_f4_valuetab-katsayi = '3'.
    APPEND ls_cezacarpani_f4_valuetab TO lt_cezacarpani_f4_valuetab.

    CLEAR: ls_cezacarpani_f4_valuetab.
    ls_cezacarpani_f4_valuetab-katsayi = '5'.
    APPEND ls_cezacarpani_f4_valuetab TO lt_cezacarpani_f4_valuetab.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield     = 'KATSAYI'
        window_title = 'Ceza Çarpanı'
        value_org    = 'S'
      TABLES
        value_tab    = lt_cezacarpani_f4_valuetab
        return_tab   = lt_return_tab.

    gv_f4_id = es_row_no-row_id.

    READ TABLE lt_return_tab INTO ls_return_tab WITH KEY fieldname = 'F0001'.
    IF sy-subrc EQ 0.
      READ TABLE gt_alv_table ASSIGNING <gfs_ceza> INDEX es_row_no-row_id.
      IF sy-subrc EQ 0.
        <gfs_ceza>-katsayi = ls_return_tab-fieldval.
        go_alv->refresh_table_display( ).
      ENDIF.
    ENDIF.

    er_event_data->m_event_handled = 'X'.

  ENDMETHOD.


ENDCLASS.
