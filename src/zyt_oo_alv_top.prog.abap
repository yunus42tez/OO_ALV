*&---------------------------------------------------------------------*
*& Include          ZYT_OO_ALV_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: icon.

TABLES: ever,
        erdk,
        but000.

DATA: go_alv TYPE REF TO cl_gui_alv_grid.

DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat,
      gs_layout   TYPE lvc_s_layo.


TYPES: BEGIN OF gty_alv_table,

         auszdat    LIKE ever-auszdat,
         opbel      LIKE erdk-opbel,
         anlage     LIKE ever-anlage,
         vkonto     LIKE ever-vkonto,
         vertrag    LIKE ever-vertrag,
         durum      TYPE icon_d,
         partner    LIKE erdk-partner,
         name       TYPE char30,
         total_amnt LIKE erdk-total_amnt,
         katsayi    TYPE int4,
         ceza       TYPE int4,
         cell_color TYPE lvc_t_scol,

       END OF gty_alv_table.

DATA: gt_alv_table TYPE TABLE OF gty_alv_table,
      gs_alv_table TYPE gty_alv_table,
      gs_cell      TYPE lvc_s_scol.

FIELD-SYMBOLS: <gfs_ceza> LIKE gs_alv_table.

CLASS cl_event_receiver DEFINITION DEFERRED.
DATA: go_event_receiver TYPE REF TO cl_event_receiver.


DATA: gt_but000 TYPE TABLE OF but000,
      gs_but000 TYPE but000.

DATA: gv_f4_id TYPE i.
