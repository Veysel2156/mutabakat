*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_I03
*&---------------------------------------------------------------------*

*- begin of -* Class Definition *-
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    DATA : mo_alv TYPE REF TO cl_salv_table .
    METHODS:
      initialization ,
      set_first_status ,
      at_selection_screen ,
      get_data ,
      prepare_alv ,
      on_user_command FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function ,
      send_mutabakat_mail IMPORTING is_data TYPE zvs_mut_kalem .
ENDCLASS .
*- end of -* Class Definition *-

*- begin of -* Class implementation *-
CLASS lcl_report IMPLEMENTATION .

  METHOD initialization .
    " Program ilk açıldığında yapılacak atamalar
  ENDMETHOD .

  METHOD set_first_status .
    " Ekran (Selection Screen) manipülasyonları
  ENDMETHOD .

  METHOD at_selection_screen .
    " Kullanıcı F8'e bastığında yapılacak yetki ve giriş kontrolleri
  ENDMETHOD .

  METHOD get_data .
    CLEAR : gt_data .

*- begin of -* Müşteri Verilerini Çekme *-
    IF r_mush = 'X' .
      " Müşteri (Açık Kalemler - BSID) okuması (Saf haliyle çekiyoruz)
      SELECT kunnr AS cari_no ,
             'D'   AS koart ,
             shkzg ,
             dmbtr ,
             waers
        FROM bsid
        WHERE bukrs = @p_bukrs
          AND kunnr IN @s_kunnr
          AND gjahr = @p_gjahr
        INTO TABLE @DATA(lt_musteri_raw) .

      " ABAP tarafında gruplama ve Bakiye hesaplama
      LOOP AT lt_musteri_raw INTO DATA(ls_mus_raw) .

        " Bu müşteri zaten gt_data'ya eklendi mi diye bakıyoruz
        READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs_data>)
                           WITH KEY cari_no = ls_mus_raw-cari_no
                                    waers   = ls_mus_raw-waers .
        IF sy-subrc <> 0 .
          " Eklenmemişse yeni boş bir satır açıp mailini buluyoruz
          CLEAR gs_data .
          gs_data-cari_no = ls_mus_raw-cari_no .
          gs_data-koart   = ls_mus_raw-koart .
          gs_data-waers   = ls_mus_raw-waers .

          SELECT SINGLE smtp_addr
            FROM adr6
            INNER JOIN kna1 ON kna1~adrnr = adr6~addrnumber
            WHERE kna1~kunnr = @ls_mus_raw-cari_no
            INTO @gs_data-mail_adres .

          APPEND gs_data TO gt_data .

          " Eklediğimiz satırı <fs_data> pointer'ına bağlıyoruz ki tutarı güncelleyelim
          READ TABLE gt_data ASSIGNING <fs_data>
                             WITH KEY cari_no = ls_mus_raw-cari_no
                                      waers   = ls_mus_raw-waers .
        ENDIF .

        " Borç (S) ise topla, Alacak (H) ise çıkar
        IF ls_mus_raw-shkzg = 'S' .
          <fs_data>-bakiye = <fs_data>-bakiye + ls_mus_raw-dmbtr .
        ELSE .
          <fs_data>-bakiye = <fs_data>-bakiye - ls_mus_raw-dmbtr .
        ENDIF .

      ENDLOOP .
*- end of   -* Müşteri Verilerini Çekme *-

*- begin of -* Satıcı Verilerini Çekme *-
    ELSEIF r_sati = 'X' .
      " Satıcı (Açık Kalemler - BSIK) okuması
      SELECT lifnr AS cari_no ,
             'K'   AS koart ,
             shkzg ,
             dmbtr ,
             waers
        FROM bsik
        WHERE bukrs = @p_bukrs
          AND lifnr IN @s_lifnr
     "     AND gjahr = @p_gjahr
        INTO TABLE @DATA(lt_satici_raw) .

      " ABAP tarafında gruplama ve Bakiye hesaplama
      LOOP AT lt_satici_raw INTO DATA(ls_sat_raw) .

        READ TABLE gt_data ASSIGNING FIELD-SYMBOL(<fs_data_sat>)
                           WITH KEY cari_no = ls_sat_raw-cari_no
                                    waers   = ls_sat_raw-waers .
        IF sy-subrc <> 0 .
          CLEAR gs_data .
          gs_data-cari_no = ls_sat_raw-cari_no .
          gs_data-koart   = ls_sat_raw-koart .
          gs_data-waers   = ls_sat_raw-waers .

          SELECT SINGLE smtp_addr
            FROM adr6
            INNER JOIN lfa1 ON lfa1~adrnr = adr6~addrnumber
            WHERE lfa1~lifnr = @ls_sat_raw-cari_no
            INTO @gs_data-mail_adres .

          APPEND gs_data TO gt_data .

          READ TABLE gt_data ASSIGNING <fs_data_sat>
                             WITH KEY cari_no = ls_sat_raw-cari_no
                                      waers   = ls_sat_raw-waers .
        ENDIF .

        " Borç/Alacak mantığı
        IF ls_sat_raw-shkzg = 'S' .
          <fs_data_sat>-bakiye = <fs_data_sat>-bakiye + ls_sat_raw-dmbtr .
        ELSE .
          <fs_data_sat>-bakiye = <fs_data_sat>-bakiye - ls_sat_raw-dmbtr .
        ENDIF .

      ENDLOOP .
    ENDIF .
*- end of   -* Satıcı Verilerini Çekme *-

    IF gt_data IS INITIAL .
      MESSAGE s000(su) WITH 'Seçilen kriterlere uygun açık kalem bulunamadı!' .
    ENDIF .

  ENDMETHOD .

  METHOD prepare_alv .
    " Eğer veri yoksa boşuna ALV ekranı açıp sistemi yormayalım
    CHECK gt_data IS NOT INITIAL.
    TRY.

        cl_salv_table=>factory(
          IMPORTING
            r_salv_table   = mo_alv                          " Basis Class Simple ALV Tables
          CHANGING
            t_table        = gt_data
        ).
        "Standart Butonları Ekle (Filtre, Sıralama, Excel'e İndir vb.)
        DATA(lo_function) = mo_alv->get_functions( ).
        lo_function->set_all( abap_true ).

        "Kolon Genişliklerini İçindeki Veriye Göre Otomatik Ayarla (Zebra deseni dahil)
        DATA(lo_columns) = mo_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        DATA(lo_display) = mo_alv->get_display_settings( ).
        lo_display->set_striped_pattern( cl_salv_display_settings=>true ).

        "Kolon İsimlerini Özelleştirme
        TRY .
            " CARI_NO kolonunun başlığını düzeltelim
            DATA(lo_col_cari) = lo_columns->get_column( 'CARI_NO' ) .
            lo_col_cari->set_short_text( 'Cari No' ) .
            lo_col_cari->set_medium_text( 'Müşteri/Satıcı No' ) .
            lo_col_cari->set_long_text( 'Müşteri/Satıcı Numarası' ) .

            " MAIL_ADRES kolonunun başlığını düzeltelim
            DATA(lo_col_mail) = lo_columns->get_column( 'MAIL_ADRES' ) .
            lo_col_mail->set_short_text( 'E-Posta' ) .
            lo_col_mail->set_medium_text( 'E-Posta Adresi' ) .
            lo_col_mail->set_long_text( 'Kayıtlı E-Posta Adresi' ) .

          CATCH cx_salv_not_found .
            " Kolon bulunamazsa program çökmesin, sessizce geçsin
        ENDTRY .
        mo_alv->set_screen_status(
          EXPORTING
            report        =  sy-repid                " ABAP Program: Current Master Program
            pfstatus      = 'STANDARD'               " Screens, Current GUI Status
            set_functions = mo_alv->c_functions_all ).
        DATA(lo_selection) = mo_alv->get_selections( ).
        lo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).

        DATA(lo_event) = mo_alv->get_event( ).
        SET HANDLER me->on_user_command FOR lo_event.

        mo_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lo_error) .
        MESSAGE lo_error TYPE 'E' .
    ENDTRY .


  ENDMETHOD .

  method on_user_command .
    if e_salv_function = '&SEND' .
      data(lo_selections) = mo_alv->get_selections( ) .
      data(lt_rows) = lo_selections->get_selected_rows( ) .

      if lt_rows is initial .
        message s000(su) with 'Lütfen mail atılacak satırları seçiniz!' display like 'E' .
        return .
      endif .

*- begin of -* Başlık Kaydı Oluşturma *-
      " Her gönderim grubu için benzersiz bir ID oluşturuyoruz (Timestamp usulü)
      data(lv_timestamp) = |{ sy-datum }{ sy-uzeit }| .

      data: ls_baslik type zvs_mut_baslik .
      ls_baslik-mandt  = sy-mandt .
      ls_baslik-mut_id = lv_timestamp .
      ls_baslik-bukrs  = p_bukrs .
      ls_baslik-gjahr  = p_gjahr .
      ls_baslik-monat  = p_monat .
      ls_baslik-erdat  = sy-datum .
      ls_baslik-ernam  = sy-uname .
      insert zvs_mut_baslik from ls_baslik . " Nüfus kaydı tamam!
*- end of   -* Başlık Kaydı Oluşturma *-

      data: lv_sayac type i value 0 .
      loop at lt_rows into data(lv_row) .
        read table gt_data index lv_row into data(ls_selected) .
        if sy-subrc = 0 .
          me->send_mutabakat_mail( ls_selected ) .

*- begin of -* Kalem Kaydı Oluşturma *-
          " Gönderilen her maili detay tablosuna yazıyoruz
          data: ls_kalem type zvs_mut_kalem .
          move-corresponding ls_selected to ls_kalem .
          ls_kalem-mut_id = lv_timestamp .
          ls_kalem-durum  = '1' . " 1: Gönderildi
          insert zvs_mut_kalem from ls_kalem .
*- end of   -* Kalem Kaydı Oluşturma *-

          lv_sayac = lv_sayac + 1 .
        endif .
      endloop .

      commit work . " Tüm kayıtları veritabanına mühürle
      message s000(su) with |İşlem Tamam! { lv_sayac } adet mail atıldı ve veritabanına kaydedildi.| .
    endif .
  ENDMETHOD .

  METHOD send_mutabakat_mail .
    CHECK is_data-mail_adres IS NOT INITIAL .
    DATA(lo_send_request) = cl_bcs=>create_persistent( ) .
    TRY.


    DATA: lt_text TYPE bcsy_text .
    APPEND 'Sayın İlgili,' TO lt_text .
    APPEND ' ' TO lt_text .
    APPEND |Sistemimizdeki güncel bakiyeniz aşağıdaki gibidir:| TO lt_text .
    APPEND |Tutar: { is_data-bakiye } { is_data-waers }| TO lt_text .
    APPEND ' ' TO lt_text .
    APPEND 'Mutabık olmamanız durumunda lütfen tarafımıza dönüş yapınız.' TO lt_text .
    APPEND 'İyi çalışmalar dileriz.' TO lt_text .

    data(lo_document) = cl_document_bcs=>create_document(
                          i_type         = 'RAW'
                          i_subject      = 'Bakiye Mutabakat Bildirimi'
                          i_text         = lt_text ).
    lo_send_request->set_document( lo_document ) .

        data(lv_mail) = conv ad_smtpadr( is_data-mail_adres ) .
        data(lo_recipient) = cl_cam_address_bcs=>create_internet_address( lv_mail ) .
        lo_send_request->add_recipient( i_recipient = lo_recipient ) .

        lo_send_request->set_send_immediately( 'X' ) .
        lo_send_request->send( i_with_error_screen = 'X' ) .

        commit work .

CATCH cx_bcs INTO DATA(lx_bcs). " <--- Hata olursa buraya düşer
        DATA(lv_msg) = lx_bcs->get_text( ) .
        MESSAGE s000(su) WITH lv_msg DISPLAY LIKE 'E' .
    ENDTRY.




  ENDMETHOD.
ENDCLASS .
*- end of   -* Class Implementation *-
