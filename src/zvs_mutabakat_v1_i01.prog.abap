*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_V1_I01
*&---------------------------------------------------------------------*
TYPE-POOLS : icon,vrm .

TABLES:kna1 , bkpf , bseg , zvs_mutabakat .

CLASS : lcl_report DEFINITION DEFERRED .

DATA: go_report TYPE REF TO lcl_report.

DATA: lt_values TYPE vrm_values,
      ls_value  TYPE vrm_value.


TYPES: BEGIN OF ty_tablo,
         gv_bukrs       TYPE bkpf-bukrs, " şirket kodu
         gv_state_icon  TYPE icon_d, " mutabakt durumu için icon
         gv_states      TYPE char25, " mutabakat durumu
         gv_belno       TYPE bkpf-belnr, " belge numarası
         gv_gjahr       TYPE bkpf-gjahr, " yıl
         gv_name1       TYPE kna1-name1, " muhatap adı
         gv_umskz       TYPE bseg-umskz, "ödk göstergesi
         gv_doc_type    TYPE bkpf-blart, "belge türü
         gv_doc_date    TYPE bkpf-bldat, "belge tarihi
         gv_waers       TYPE bkpf-waers, " para birimi
         gv_amount      TYPE bseg-wrbtr, "tutar
         gv_kunnr       TYPE bseg-kunnr, "müşteri numarası
         gv_description TYPE t003t-ltext, " açıklama
         btn_details    TYPE icon_d, " detay butonu için icon

       END OF ty_tablo.


TYPES:BEGIN OF ty_popup,
        doc_date   TYPE bapi3007_2-doc_date,   " Tarih
        doc_type   TYPE bapi3007_2-doc_type,   " Tip
        item_num   TYPE bapi3007_2-item_num,   " Kalem
        ref_doc_no TYPE bapi3007_2-ref_doc_no, " Referans
        db_cr_ind  TYPE bapi3007_2-db_cr_ind,  " ODK (S/H)
        odk_metni  TYPE char10,                " ODK Metni (Borç/Alacak)
        amount     TYPE bapi3007_2-amount,     " Tutar
        currency   TYPE bapi3007_2-currency,   " para birimi
      END OF ty_popup.

DATA: gt_popup TYPE TABLE OF ty_popup.


DATA: gt_tablo TYPE TABLE OF ty_tablo.
