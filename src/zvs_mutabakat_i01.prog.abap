*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_I01
*&---------------------------------------------------------------------*

*- begin of -* Tables *-
tables: bkpf , kna1 , lfa1 .
tables: zvs_mut_baslik , zvs_mut_kalem .
*- end of   -* Tables *-


*- begin of -* Class Definitions *-
class : lcl_report definition deferred .
*- end of   -* Class Definitions *-


*- begin of -* Global Data *-
data  : go_report type ref to lcl_report .

data  : gt_data   type table of zvs_mut_kalem , " ALV'ye basacağımız ana veri
        gs_data   type zvs_mut_kalem ,
        gv_mut_id type char10 . " Yeni mutabakat için ID tutucu
*- end of   -* Global Data *-
