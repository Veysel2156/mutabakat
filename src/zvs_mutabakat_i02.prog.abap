*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_I02
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK mainsel WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY DEFAULT '1000' , "şirket kodu
              p_gjahr TYPE gjahr OBLIGATORY DEFAULT sy-datum(4), "mali yıl
              p_monat TYPE monat OBLIGATORY DEFAULT sy-datum+4(2). "dönem


  SELECT-OPTIONS: s_kunnr FOR kna1-kunnr, "Müşteri aralığı
                  s_lifnr FOR lfa1-lifnr.
SELECTION-SCREEN END OF BLOCK mainsel.

SELECTION-SCREEN BEGIN OF BLOCK mailopt WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_immed AS CHECKBOX DEFAULT 'X'.    "Gönderimi hemen tetikle

  PARAMETERS: p_from  TYPE ad_smtpadr LOWER CASE, "Gönderen (boşsa sistem)
              p_subj  TYPE so_obj_des DEFAULT 'Bakiye Mutabakat Bildirimi'.

  PARAMETERS: p_limit TYPE i DEFAULT 200.         "İşlem üst limiti (performans/safety)
SELECTION-SCREEN END OF BLOCK mailopt.


SELECTION-SCREEN BEGIN OF BLOCK recsel WITH FRAME TITLE TEXT-002.

  SELECTION-SCREEN BEGIN OF LINE .
    PARAMETERS: r_mush RADIOBUTTON GROUP rad1 DEFAULT 'X' USER-COMMAND ucomm.
    SELECTION-SCREEN COMMENT 3(20) TEXT-r01 FOR FIELD r_mush.
    SELECTION-SCREEN POSITION 30.
    PARAMETERS: r_sati RADIOBUTTON GROUP rad1.
    SELECTION-SCREEN COMMENT 33(20) TEXT-r02 FOR FIELD r_sati .
  SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN END OF BLOCK recsel.
