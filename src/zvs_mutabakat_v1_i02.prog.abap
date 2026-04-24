*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_V1_I02
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_statu TYPE zvs_de_statu AS LISTBOX VISIBLE LENGTH 25.
  SELECTION-SCREEN ULINE.

  PARAMETERS: p_bukrs TYPE bkpf-bukrs OBLIGATORY, "şirket kodu
              p_datum TYPE sy-datum.
  SELECT-OPTIONS s_kunnr FOR kna1-kunnr."müşteri no
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
    PARAMETERS:p_mbak AS CHECKBOX DEFAULT 'X',
               p_0bak AS CHECKBOX ,
               p_odkbak AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.
