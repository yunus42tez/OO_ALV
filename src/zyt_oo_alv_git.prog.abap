*&---------------------------------------------------------------------*
*& Report ZYT_ODEV1_OO_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zyt_oo_alv_git.

INCLUDE zyt_oo_alv_top.
INCLUDE zyt_oo_alv_cls.
INCLUDE zyt_oo_alv_pbo.
INCLUDE zyt_oo_alv_pai.
INCLUDE zyt_oo_alv_frm.

START-OF-SELECTION.

  PERFORM get_data.

  PERFORM set_layout.

  PERFORM set_merge.

  PERFORM display_alv.
