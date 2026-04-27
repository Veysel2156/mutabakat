* Structure for Kalem (Item) Entity in OData Service
* This structure maps to zvs_mut_kalem table

TYPES: BEGIN OF zvs_mutabakat_odata_s_kalem,
  kalem_id TYPE string,              " Primary Key (Item ID)
  id TYPE string,                    " Foreign Key to Baslik
  detay_aciklamasi TYPE string,      " Item Detail Description
  satir_durum TYPE string,           " Item Status: D=Draft, O=Open
END OF zvs_mutabakat_odata_s_kalem.