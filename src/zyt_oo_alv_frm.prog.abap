*&---------------------------------------------------------------------*
*& Include          ZYT_OO_ALV_FRM
*&---------------------------------------------------------------------*

 SELECTION-SCREEN BEGIN OF BLOCK blockid1.

   SELECT-OPTIONS: s_anlage FOR ever-anlage,
                   s_vkonto FOR ever-vkonto,
                   s_opbel  FOR erdk-opbel.

 SELECTION-SCREEN END OF BLOCK blockid1.

 FORM get_data.

   SELECT
         ever~anlage
         ever~vkonto
         ever~auszdat
         ever~vertrag
         erdk~opbel
         erdk~partner
         erdk~total_amnt
         FROM ever
         INNER JOIN erdk ON erdk~vkont = ever~vkonto
         INNER JOIN but000 ON erdk~partner = but000~partner
         INTO CORRESPONDING FIELDS OF TABLE gt_alv_table
         WHERE ever~anlage IN s_anlage
         AND ever~vkonto IN s_vkonto
         AND erdk~opbel IN s_opbel.

*        DATA: lt_alv_table_copy TYPE gty_alv_table OCCURS 0 WITH HEADER LINE,  " Mükerrer kayıtlardan ilk geleni alv'ye basmak için bu alanı açabilirsin.
*              ls_alv_table_copy TYPE gty_alv_table.
*
*        lt_alv_table_copy[] = gt_alv_table[].
*
*        DATA: lt_erdk TYPE erdk OCCURS 0 WITH HEADER LINE,
*              ls_erdk TYPE erdk.
*
*        SELECT opbel
*          FROM erdk
*          INTO CORRESPONDING FIELDS OF TABLE lt_erdk.
*
*        CLEAR gt_alv_table.
*
*        LOOP AT lt_erdk INTO ls_erdk.
*          READ TABLE lt_alv_table_copy WITH KEY opbel = ls_erdk-opbel.
*          IF sy-subrc EQ 0.
*            gs_alv_table-anlage     = lt_alv_table_copy-anlage.
*            gs_alv_table-vkonto     = lt_alv_table_copy-vkonto.
*            gs_alv_table-auszdat    = lt_alv_table_copy-auszdat.
*            gs_alv_table-vertrag    = lt_alv_table_copy-vertrag.
*            gs_alv_table-opbel      = lt_alv_table_copy-opbel.
*            gs_alv_table-partner    = lt_alv_table_copy-partner.
*            gs_alv_table-total_amnt = lt_alv_table_copy-total_amnt.
*
*            APPEND gs_alv_table TO gt_alv_table.
*          ENDIF.
*
*        ENDLOOP.

   SELECT
     partner
     type
     name_first
     name_last
     name_org1
     name_org2
      FROM but000 INTO CORRESPONDING FIELDS OF TABLE gt_but000.

   LOOP AT gt_alv_table INTO gs_alv_table.
     IF gs_alv_table-auszdat EQ '99991231'.
       gs_alv_table-durum = '@5B@'.
     ELSEIF gs_alv_table-auszdat NE '99991231'.
       gs_alv_table-durum = '@5D@'.
     ENDIF.

     MODIFY gt_alv_table FROM gs_alv_table. CLEAR gs_alv_table.
   ENDLOOP.

   DATA: lv_firstname_lastname(30) TYPE c,
         lv_org_name1_name2(30)    TYPE c.



   LOOP AT gt_but000 INTO gs_but000.
     IF gs_but000-type EQ '1'.
       LOOP AT gt_alv_table INTO gs_alv_table WHERE partner = gs_but000-partner.

         CONCATENATE gs_but000-name_first gs_but000-name_last
            INTO lv_firstname_lastname SEPARATED BY space.

         gs_alv_table-name = lv_firstname_lastname.
         MODIFY gt_alv_table FROM gs_alv_table. CLEAR gs_alv_table.
       ENDLOOP.
     ELSEIF gs_but000-type EQ '2'.

       CONCATENATE gs_but000-name_org1 gs_but000-name_org2
           INTO lv_org_name1_name2 SEPARATED BY space.

       LOOP AT gt_alv_table INTO gs_alv_table WHERE partner = gs_but000-partner.
         gs_alv_table-name = lv_org_name1_name2.
         MODIFY gt_alv_table FROM gs_alv_table. CLEAR gs_alv_table.
       ENDLOOP.
     ENDIF.
   ENDLOOP.

 ENDFORM.


 FORM set_layout.
   gs_layout-zebra      = abap_true.
   gs_layout-cwidth_opt = abap_true.
   gs_layout-ctab_fname = 'CELL_COLOR'.
 ENDFORM.

 FORM register_f4 .

   DATA: lt_f4 TYPE  lvc_t_f4,
         ls_f4 TYPE  lvc_s_f4.

   CLEAR: ls_f4.

   ls_f4-fieldname = 'KATSAYI'.
   ls_f4-register = 'X'.
   APPEND ls_f4 TO lt_f4.


   CALL METHOD go_alv->register_f4_for_fields
     EXPORTING
       it_f4 = lt_f4.

 ENDFORM.

 FORM set_merge.

   CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
     EXPORTING
       i_structure_name       = 'ZGVN_ALV'
     CHANGING
       ct_fieldcat            = gt_fieldcat
     EXCEPTIONS
       inconsistent_interface = 1
       program_error          = 2
       OTHERS                 = 3.
   IF sy-subrc <> 0.
* Implement suitable error handling here
   ENDIF.

   DATA: lv_colnum TYPE int1.
   lv_colnum = 0.

* Set field properties
   LOOP AT gt_fieldcat INTO gs_fieldcat .
     lv_colnum = lv_colnum + 1.
     CASE gs_fieldcat-fieldname.
       WHEN 'OPBEL'.
         gs_fieldcat-outputlen    = 4.
         gs_fieldcat-col_pos      = lv_colnum.
         gs_fieldcat-hotspot      = 'X'.
       WHEN 'ANLAGE'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
         gs_fieldcat-hotspot      = 'X'.
       WHEN 'VKONTO'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN 'VERTRAG'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN 'DURUM'.
         gs_fieldcat-scrtext_l = 'Durum'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN 'PARTNER'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN 'NAME'.
         gs_fieldcat-scrtext_l    = 'Ad Soyad'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN 'TOTAL_AMNT'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN 'KATSAYI'.
         gs_fieldcat-scrtext_l    = 'Ceza Çarpanı'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
         gs_fieldcat-edit         = 'X'.
         gs_fieldcat-style        = cl_gui_alv_grid=>mc_style_f4.
       WHEN 'CEZA'.
         gs_fieldcat-scrtext_l    = 'Ceza Tutarı'.
         gs_fieldcat-outputlen    = 20.
         gs_fieldcat-col_pos      = lv_colnum.
       WHEN OTHERS.
         gs_fieldcat-no_out       = 'X'.
     ENDCASE.
     gs_fieldcat-scrtext_s = gs_fieldcat-scrtext_l.
     gs_fieldcat-scrtext_m = gs_fieldcat-scrtext_l.
     gs_fieldcat-reptext = gs_fieldcat-scrtext_l.

     CLEAR gs_fieldcat-key.
     MODIFY gt_fieldcat FROM gs_fieldcat .
   ENDLOOP.

 ENDFORM.


 FORM display_alv.

   CREATE OBJECT go_alv
     EXPORTING
       i_parent = cl_gui_container=>screen0.

   PERFORM register_f4.

   CREATE OBJECT go_event_receiver.

   SET HANDLER go_event_receiver->handle_hotspot_click FOR go_alv.
   SET HANDLER go_event_receiver->handle_onf4 FOR go_alv.
   SET HANDLER go_event_receiver->handle_data_changed FOR go_alv.


   CALL METHOD go_alv->set_table_for_first_display
     EXPORTING
       "i_structure_name = 'ZGVN_ALV'
       is_layout       = gs_layout
     CHANGING
       it_outtab       = gt_alv_table
       it_fieldcatalog = gt_fieldcat.

   CALL METHOD go_alv->register_edit_event
     EXPORTING
       i_event_id = cl_gui_alv_grid=>mc_evt_modified.

   CALL METHOD go_alv->register_edit_event
     EXPORTING
       i_event_id = cl_gui_alv_grid=>mc_evt_enter.

   CALL SCREEN 0100.



 ENDFORM.
