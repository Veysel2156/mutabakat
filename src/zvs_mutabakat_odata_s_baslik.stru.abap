* Structure for Baslik (Header) Entity in OData Service
* This structure maps to zvs_mut_baslik table

TYPES: BEGIN OF zvs_mutabakat_odata_s_baslik,
  id TYPE string,                    " Primary Key
  mutabakat_nr TYPE string,          " Mutabakat Number
  status TYPE string,                " D=Draft, E=Entry, O=Open, A=Approved
  aciklama TYPE string,              " Description
  tarih TYPE timestamp,              " Date Created
  kullanici TYPE string,             " Created by User
END OF zvs_mutabakat_odata_s_baslik.