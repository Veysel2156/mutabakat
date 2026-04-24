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
      send_mutabakat_mail
        IMPORTING
          is_data           TYPE zvs_mut_kalem
        EXPORTING
          ev_error_text     TYPE string
        RETURNING
          VALUE(rv_success) TYPE abap_bool .
ENDCLASS .
*- end of -* Class Definition *-

*- begin of -* Class implementation *-
CLASS lcl_report IMPLEMENTATION .

  METHOD initialization .
    " Program ilk açıldığında yapılacak atamalar
  ENDMETHOD .

  METHOD set_first_status .
    " Ekran (Selection Screen) manipülasyonları
    LOOP AT SCREEN.
      IF r_mush = abap_true.
        IF screen-name CP 'S_LIFNR*'.
          screen-input = 0.
        ELSEIF screen-name CP 'S_KUNNR*'.
          screen-input = 1.
        ENDIF.
      ELSEIF r_sati = abap_true.
        IF screen-name CP 'S_KUNNR*'.
          screen-input = 0.
        ELSEIF screen-name CP 'S_LIFNR*'.
          screen-input = 1.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD .

  METHOD at_selection_screen .
    " Kullanıcı F8'e bastığında yapılacak yetki ve giriş kontrolleri
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD p_bukrs
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      MESSAGE s000(su) WITH |{ p_bukrs } şirket kodu için görüntüleme yetkiniz yok.| DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    ENDIF.

    IF r_mush = abap_true AND s_kunnr[] IS INITIAL.
      MESSAGE s000(su) WITH 'Müşteri seçimi için müşteri aralığı giriniz.' DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    ENDIF.
    IF r_sati = abap_true AND s_lifnr[] IS INITIAL.
      MESSAGE s000(su) WITH 'Satıcı seçimi için satıcı aralığı giriniz.' DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    ENDIF.

    IF p_monat < 1 OR p_monat > 12.
      MESSAGE s000(su) WITH 'Dönem (Ay) 01-12 aralığında olmalıdır.' DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    ENDIF.
    IF p_limit <= 0.
      MESSAGE s000(su) WITH 'Üst limit 1 veya daha büyük olmalıdır.' DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDMETHOD .

  METHOD get_data .
    CLEAR : gt_data .

*- begin of -* Müşteri Verilerini Çekme *-
    IF r_mush = 'X' .
      SELECT
        kunnr AS cari_no,
        waers,
        SUM(
          CASE shkzg
            WHEN 'S' THEN dmbtr
            ELSE - dmbtr
          END
        ) AS bakiye
        FROM bsid
        WHERE bukrs = @p_bukrs
          AND kunnr IN @s_kunnr
          AND gjahr = @p_gjahr
        GROUP BY kunnr, waers
        INTO TABLE @DATA(lt_mus_bal).

      IF lt_mus_bal IS NOT INITIAL.
        SELECT
          kna1~kunnr AS cari_no,
          adr6~smtp_addr AS mail_adres
          FROM kna1
          INNER JOIN adr6 ON adr6~addrnumber = kna1~adrnr
          FOR ALL ENTRIES IN @lt_mus_bal
          WHERE kna1~kunnr = @lt_mus_bal-cari_no
          INTO TABLE @DATA(lt_mus_mail).
        SORT lt_mus_mail BY cari_no.
        DELETE ADJACENT DUPLICATES FROM lt_mus_mail COMPARING cari_no.
      ENDIF.

      LOOP AT lt_mus_bal INTO DATA(ls_mus_bal).
        CLEAR gs_data.
        gs_data-cari_no = ls_mus_bal-cari_no.
        gs_data-koart   = 'D'.
        gs_data-waers   = ls_mus_bal-waers.
        gs_data-bakiye  = ls_mus_bal-bakiye.
        READ TABLE lt_mus_mail INTO DATA(ls_mus_mail) WITH KEY cari_no = ls_mus_bal-cari_no BINARY SEARCH.
        IF sy-subrc = 0.
          gs_data-mail_adres = ls_mus_mail-mail_adres.
        ENDIF.
        APPEND gs_data TO gt_data.
      ENDLOOP.
*- end of   -* Müşteri Verilerini Çekme *-

*- begin of -* Satıcı Verilerini Çekme *-
    ELSEIF r_sati = 'X' .
      SELECT
        lifnr AS cari_no,
        waers,
        SUM(
          CASE shkzg
            WHEN 'S' THEN dmbtr
            ELSE - dmbtr
          END
        ) AS bakiye
        FROM bsik
        WHERE bukrs = @p_bukrs
          AND lifnr IN @s_lifnr
          AND gjahr = @p_gjahr
        GROUP BY lifnr, waers
        INTO TABLE @DATA(lt_sat_bal).

      IF lt_sat_bal IS NOT INITIAL.
        SELECT
          lfa1~lifnr AS cari_no,
          adr6~smtp_addr AS mail_adres
          FROM lfa1
          INNER JOIN adr6 ON adr6~addrnumber = lfa1~adrnr
          FOR ALL ENTRIES IN @lt_sat_bal
          WHERE lfa1~lifnr = @lt_sat_bal-cari_no
          INTO TABLE @DATA(lt_sat_mail).
        SORT lt_sat_mail BY cari_no.
        DELETE ADJACENT DUPLICATES FROM lt_sat_mail COMPARING cari_no.
      ENDIF.

      LOOP AT lt_sat_bal INTO DATA(ls_sat_bal).
        CLEAR gs_data.
        gs_data-cari_no = ls_sat_bal-cari_no.
        gs_data-koart   = 'K'.
        gs_data-waers   = ls_sat_bal-waers.
        gs_data-bakiye  = ls_sat_bal-bakiye.
        READ TABLE lt_sat_mail INTO DATA(ls_sat_mail) WITH KEY cari_no = ls_sat_bal-cari_no BINARY SEARCH.
        IF sy-subrc = 0.
          gs_data-mail_adres = ls_sat_mail-mail_adres.
        ENDIF.
        APPEND gs_data TO gt_data.
      ENDLOOP.
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

        TRY.
            DATA(lo_col_bak) = lo_columns->get_column( 'BAKIYE' ).
            lo_col_bak->set_short_text( 'Bakiye' ).
            lo_col_bak->set_medium_text( 'Bakiye' ).
            lo_col_bak->set_long_text( 'Güncel Bakiye' ).
          CATCH cx_salv_not_found.
        ENDTRY.

        TRY.
            DATA(lo_col_wrs) = lo_columns->get_column( 'WAERS' ).
            lo_col_wrs->set_short_text( 'P.B.' ).
            lo_col_wrs->set_medium_text( 'Para Birimi' ).
            lo_col_wrs->set_long_text( 'Para Birimi' ).
          CATCH cx_salv_not_found.
        ENDTRY.
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

      if lines( lt_rows ) > p_limit.
        message s000(su) with |Seçim sayısı ({ lines( lt_rows ) }) üst limiti ({ p_limit }) aşıyor. Lütfen daraltın.| display like 'E'.
        return.
      endif.

      data: lv_question type string,
            lv_answer   type c length 1.
      lv_question = |Seçili { lines( lt_rows ) } satır için e-posta gönderilecek. Devam edilsin mi?| .
      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = 'Mutabakat Mail Gönderimi'
          text_question         = lv_question
          text_button_1         = 'Evet'
          text_button_2         = 'Hayır'
          display_cancel_button = abap_true
        importing
          answer                = lv_answer.
      if lv_answer <> '1'.
        message s000(su) with 'İşlem kullanıcı tarafından iptal edildi.'.
        return.
      endif.

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
      try.
          insert zvs_mut_baslik from ls_baslik .
        catch cx_sy_open_sql_db into data(lx_sql_hdr).
          message s000(su) with lx_sql_hdr->get_text( ) display like 'E'.
          return.
      endtry.
*- end of   -* Başlık Kaydı Oluşturma *-

      data: lv_sayac_ok type i value 0,
            lv_sayac_er type i value 0,
            lv_sayac_no type i value 0.
      loop at lt_rows into data(lv_row) .
        read table gt_data index lv_row into data(ls_selected) .
        if sy-subrc = 0 .
          data(lv_err_text) = ``.
          data(lv_success) = me->send_mutabakat_mail(
                               exporting
                                 is_data       = ls_selected
                               importing
                                 ev_error_text = lv_err_text ).

*- begin of -* Kalem Kaydı Oluşturma *-
          " Gönderilen her maili detay tablosuna yazıyoruz
          data: ls_kalem type zvs_mut_kalem .
          move-corresponding ls_selected to ls_kalem .
          ls_kalem-mut_id = lv_timestamp .
          if ls_selected-mail_adres is initial.
            ls_kalem-durum = '3'.
            lv_sayac_no = lv_sayac_no + 1.
          elseif lv_success = abap_true.
            ls_kalem-durum = '1'.
            lv_sayac_ok = lv_sayac_ok + 1.
          else.
            ls_kalem-durum = '2'.
            lv_sayac_er = lv_sayac_er + 1.
          endif.

          try.
              insert zvs_mut_kalem from ls_kalem .
            catch cx_sy_open_sql_db into data(lx_sql_itm).
              lv_sayac_er = lv_sayac_er + 1.
          endtry.
*- end of   -* Kalem Kaydı Oluşturma *-

        endif .
      endloop .

      commit work .
      message s000(su) with |İşlem tamamlandı. Gönderilen: { lv_sayac_ok }, Hatalı: { lv_sayac_er }, E-Posta yok: { lv_sayac_no }.| .
    endif .
  ENDMETHOD .

  METHOD send_mutabakat_mail .
    clear ev_error_text.
    rv_success = abap_false.

    if is_data-mail_adres is initial.
      ev_error_text = 'E-Posta adresi boş.'.
      return.
    endif.

    try.
        data(lo_send_request) = cl_bcs=>create_persistent( ) .

        DATA: lt_text TYPE bcsy_text .
        APPEND '<html><body style="font-family:Arial,Helvetica,sans-serif;font-size:10pt;">' TO lt_text.
        APPEND '<p>Sayın İlgili,</p>' TO lt_text.
        APPEND '<p>Sistemimizdeki güncel bakiyeniz aşağıdaki gibidir:</p>' TO lt_text.
        APPEND |<p><b>Tutar:</b> { is_data-bakiye } { is_data-waers }</p>| TO lt_text.
        APPEND |<p><b>Şirket Kodu:</b> { p_bukrs } &nbsp; <b>Dönem:</b> { p_gjahr }/{ p_monat }</p>| TO lt_text.
        APPEND '<p>Mutabık olmamanız durumunda lütfen tarafımıza dönüş yapınız.</p>' TO lt_text.
        APPEND '<p>İyi çalışmalar dileriz.</p>' TO lt_text.
        APPEND '<hr/>' TO lt_text.
        APPEND |<p style="color:#666;">Bu e-posta otomatik oluşturulmuştur. Referans: { sy-repid } - { sy-datum } { sy-uzeit }</p>| TO lt_text.
        APPEND '</body></html>' TO lt_text.

        data(lo_document) = cl_document_bcs=>create_document(
                              i_type         = 'HTM'
                              i_subject      = p_subj
                              i_text         = lt_text ).
        lo_send_request->set_document( lo_document ) .

        data(lv_mail) = conv ad_smtpadr( is_data-mail_adres ) .
        data(lo_recipient) = cl_cam_address_bcs=>create_internet_address( lv_mail ) .
        lo_send_request->add_recipient( i_recipient = lo_recipient ) .

        lo_send_request->set_send_immediately( p_immed ) .

        if p_from is not initial.
          try.
              data(lo_sender) = cl_cam_address_bcs=>create_internet_address( conv ad_smtpadr( p_from ) ).
              lo_send_request->set_sender( lo_sender ).
            catch cx_bcs.
          endtry.
        endif.

        data(lv_sent) = lo_send_request->send( i_with_error_screen = abap_false ) .
        rv_success = cond abap_bool( when lv_sent = abap_true then abap_true else abap_false ).
        if rv_success = abap_false.
          ev_error_text = 'Gönderim başarısız.'.
        endif.

      catch cx_bcs into DATA(lx_bcs).
        ev_error_text = lx_bcs->get_text( ).
        rv_success = abap_false.
    endtry.
  ENDMETHOD.
ENDCLASS .
*- end of   -* Class Implementation *-
