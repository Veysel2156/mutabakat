*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_V1_I03
*&---------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    DATA: mo_popup_alv TYPE REF TO cl_salv_table.
    DATA: mo_alv  TYPE REF TO cl_salv_table.
    METHODS:
      initialization,
      set_first_status,
      create_alv,
      get_data,
      display_alv,
      set_data,
      set_alv,
      prepare_alv,
      save_mutabakat_log IMPORTING is_data TYPE ty_tablo,
      prepare_popup_data IMPORTING is_data TYPE ty_tablo,
      get_next_id RETURNING VALUE(rv_snro) TYPE num10,
      send_email IMPORTING is_data TYPE ty_tablo,
      show_popup CHANGING ct_data TYPE ANY TABLE,
      on_user_command FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function.
    METHODS: on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
  METHOD:set_first_status.
*    CLEAR: lt_values, ls_value.
*    ls_value-key  = '1'.
*    ls_value-text = 'Tümü'.
*    APPEND ls_value TO lt_values.
*    ls_value-key = 'A'.
*    ls_value-text = 'Mutabık'.
*    APPEND ls_value TO lt_values.
*    ls_value-key = 'B'.
*    ls_value-text = 'Mutabık Değil'.
*    APPEND ls_value TO lt_values.
*    ls_value-key = 'C'.
*    ls_value-text = 'Cevap Bekleniyor'.
*    APPEND ls_value TO lt_values.
*    ls_value-key = 'D'.
*    ls_value-text = 'Mutabakat Gönderilmedi'.
*    APPEND ls_value TO lt_values.
*
*    CALL FUNCTION 'VRM_SET_VALUES'
*      EXPORTING
*        id     = 'P_STATU'
*        values = lt_values.

  ENDMETHOD.

  METHOD: get_data.

    SELECT  bkpf~bukrs  AS gv_bukrs,
            bkpf~belnr  AS gv_belno,
            bkpf~gjahr  AS gv_gjahr,
            bkpf~blart  AS gv_doc_type,
            bseg~umskz  AS gv_umskz,
            bkpf~bldat  AS gv_doc_date,
            bkpf~waers  AS gv_waers,
            bseg~wrbtr  AS gv_amount,
            bseg~kunnr  AS gv_kunnr,
            kna1~name1  AS gv_name1,
            t003t~ltext AS gv_description
       FROM bkpf
       INNER JOIN bseg ON bkpf~bukrs = bseg~bukrs
                      AND bkpf~belnr = bseg~belnr
                      AND bkpf~gjahr = bseg~gjahr
       LEFT OUTER JOIN kna1 ON kna1~kunnr = bseg~kunnr
       LEFT OUTER JOIN t003t ON t003t~blart = bkpf~blart
                            AND t003t~spras = @sy-langu
       WHERE bkpf~bukrs = @p_bukrs
       AND bseg~koart = 'D'
       AND bseg~kunnr <> ''
       AND ( @p_datum   IS INITIAL OR  bkpf~bldat  = @p_datum )
       AND kna1~kunnr IN @s_kunnr
       INTO CORRESPONDING FIELDS OF TABLE @gt_tablo.


    me->set_data( ).

    CASE p_statu.
      WHEN 'A'.
        DELETE gt_tablo WHERE gv_states <> TEXT-011.
      WHEN 'B'.
        DELETE gt_tablo WHERE gv_states <> TEXT-012.
      WHEN 'C'.
        DELETE gt_tablo WHERE gv_states <> TEXT-010.
      WHEN 'D'.
        DELETE gt_tablo WHERE gv_states <> TEXT-013.
    ENDCASE.



    IF  p_odkbak = 'X'.
      DELETE gt_tablo WHERE gv_umskz <> 'A'
                        AND gv_umskz <> 'F'.
    ENDIF.
  ENDMETHOD.

  METHOD:set_alv.


    DATA(lo_columns) = mo_alv->get_columns( ).
    DATA(lo_cols) = mo_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).

    DATA(lo_col) = CAST cl_salv_column_table( lo_columns->get_column( 'BTN_DETAILS' ) ).
    lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
    lo_col->set_short_text( 'Detay' ).

    DATA(lo_col_durum) = CAST cl_salv_column_table( lo_columns->get_column( 'GV_STATES' ) ).
    lo_col_durum->set_short_text( 'Durum' ).
    lo_col_durum->set_medium_text( 'Mutabakat Durumu' ).
    lo_col_durum->set_long_text( 'Güncel Mutabakat Durumu' ).

    DATA(lo_col_name) = CAST cl_salv_column_table( lo_columns->get_column( 'GV_NAME1' ) ).
    lo_col_name->set_short_text( 'Muh. Adı' ).
    lo_col_name->set_medium_text( 'Muhatap Adı' ).
    lo_col_name->set_long_text( 'Muhatap Adı' ).


    DATA(lo_col_state) = CAST cl_salv_column_table( lo_columns->get_column( 'GV_STATE_ICON' ) ).
    lo_col_state->set_short_text( 'state' ).
    lo_col_state->set_medium_text( 'G. state' ).
    lo_col_state->set_long_text( 'Güncel state' ).


    mo_alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    mo_alv->set_screen_status(
          pfstatus      = 'ZSTATUS'
          report        = sy-repid
          set_functions = mo_alv->c_functions_all ).

    """"""""""""kolon toplamı yapıyor """""""""""""""""""""""""""""

    DATA(lo_aggrs) = mo_alv->get_aggregations( ).
    lo_aggrs->add_aggregation( columnname = 'GV_AMOUNT' ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    DATA(lo_events) = mo_alv->get_event( ).


    SET HANDLER me->on_link_click FOR lo_events.
    SET HANDLER me->on_user_command FOR lo_events.


  ENDMETHOD.

  METHOD:set_data.

    IF gt_tablo IS NOT INITIAL.
      DATA: lt_z_gecmis TYPE TABLE OF zvs_mutabakat.


      SELECT * FROM zvs_mutabakat
        INTO TABLE lt_z_gecmis
        FOR ALL ENTRIES IN gt_tablo
        WHERE recon_company_id = gt_tablo-gv_bukrs
          AND customer_id      = gt_tablo-gv_kunnr
          AND tutar            = gt_tablo-gv_amount.


      SORT lt_z_gecmis BY recon_id DESCENDING.
    ENDIF.


    LOOP AT gt_tablo ASSIGNING FIELD-SYMBOL(<fs_fx>).
      <fs_fx>-btn_details = icon_select_detail.


      READ TABLE lt_z_gecmis INTO DATA(ls_z)
           WITH KEY recon_company_id = <fs_fx>-gv_bukrs
                    customer_id      = <fs_fx>-gv_kunnr
                    tutar            = <fs_fx>-gv_amount.

      IF sy-subrc = 0.

        CASE ls_z-recon_state.
          WHEN 'A'.
            <fs_fx>-gv_states = TEXT-010."Mutabakat gönderildi
          WHEN 'B'.
            <fs_fx>-gv_states = TEXT-011."Mutabakat onaylandı
          WHEN 'C'.
            <fs_fx>-gv_states = TEXT-012."Mutabakat reddedildi
          WHEN 'D'.
            <fs_fx>-gv_states = TEXT-013."Mutabakat gönderilmedi
        ENDCASE.
      ELSE.

        <fs_fx>-gv_states = TEXT-013."Mutabakat Gönderilmedi
      ENDIF.



      CASE <fs_fx>-gv_states.
        WHEN TEXT-010.
          <fs_fx>-gv_state_icon = icon_yellow_light.
        WHEN TEXT-011.
          <fs_fx>-gv_state_icon = icon_checked.
        WHEN TEXT-012.
          <fs_fx>-gv_state_icon = icon_incomplete.
        WHEN OTHERS.
          <fs_fx>-gv_state_icon = icon_dummy.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD:get_next_id.

    DATA: lv_yeni_id TYPE num10.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'          " SNRO'da verdiğimiz No
        object      = 'ZVS_MUT_NR'  " Yarattığım Obje Adı
      IMPORTING
        number      = lv_yeni_id.

    rv_snro = lv_yeni_id.
  ENDMETHOD.


  METHOD:create_alv.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = mo_alv
      CHANGING
        t_table      = gt_tablo ).

    me->set_alv( ).

  ENDMETHOD.

  METHOD:initialization.

  ENDMETHOD.

  METHOD:display_alv.
    mo_alv->display( ).
  ENDMETHOD.

  METHOD:prepare_alv.
    me->create_alv( ).
    me->display_alv( ).

  ENDMETHOD.

  METHOD:show_popup.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = mo_popup_alv
      CHANGING
        t_table        = ct_data
    ).

    mo_popup_alv->set_screen_popup(
      EXPORTING
        start_column = 10
        end_column   = 120
        start_line   = 5
        end_line     = 25
    ).

    mo_popup_alv->get_functions( )->set_all( abap_true ).

    DATA(lo_display) = mo_popup_alv->get_display_settings( ).
    lo_display->set_list_header( TEXT-009 )."Müşteri Açık Kalem Detayları

    DATA(lo_cols) = mo_popup_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).

    lo_cols->get_column( 'DOC_DATE' )->set_short_text( 'Tarih' ).
    lo_cols->get_column( 'DOC_TYPE' )->set_short_text( 'Tip' ).
    lo_cols->get_column( 'ITEM_NUM' )->set_short_text( 'Kalem' ).
    lo_cols->get_column( 'REF_DOC_NO' )->set_short_text( 'Referans' ).
    lo_cols->get_column( 'DB_CR_IND' )->set_short_text( 'ODK' ).
    lo_cols->get_column( 'ODK_METNI' )->set_short_text( 'ODK Metni' ).
    lo_cols->get_column( 'AMOUNT' )->set_short_text( 'Tutar(UPB)' ).
    lo_cols->get_column( 'CURRENCY' )->set_short_text( 'PB' ).

    mo_popup_alv->display( ).



  ENDMETHOD.

  METHOD:on_link_click.
    IF column = 'BTN_DETAILS'.
      READ TABLE gt_tablo INDEX row ASSIGNING FIELD-SYMBOL(<fs_secilen>).
      IF sy-subrc = 0.
        me->prepare_popup_data( is_data = <fs_secilen> ).
        IF gt_popup IS NOT INITIAL.
          MESSAGE TEXT-003 TYPE 'S'. "Kalem verisi Bulundu

          me->show_popup( CHANGING ct_data = gt_popup ).

        ELSE.
          MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'. "Kalem verisi bulunamadı
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD:send_email.
    DATA: lt_lines     TYPE TABLE OF tline,
          ls_line      TYPE tline,
          lt_body      TYPE bcsy_text,
          lv_text_line TYPE string.

    DATA: lv_link TYPE string.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = 'ST'
        language = sy-langu
        name     = 'ZVS_MUTABAKAT_MAIL' " SO10'da verdiğim isim
        object   = 'TEXT'
      TABLES
        lines    = lt_lines.


    lv_link = |http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false#app-preview?Bukrs={ is_data-gv_bukrs }&Kunnr={ is_data-gv_kunnr }|.


    DATA(lv_tarih) = |{ sy-datum+0(4) }-{ sy-datum+4(2) }|.

    LOOP AT lt_lines INTO ls_line.
      lv_text_line = ls_line-tdline.

      REPLACE ALL OCCURRENCES OF '&MUHATAP_ADI&' IN lv_text_line WITH is_data-gv_name1.
      REPLACE ALL OCCURRENCES OF '&TUTAR&'       IN lv_text_line WITH |{ is_data-gv_amount }|.
      REPLACE ALL OCCURRENCES OF '&PB&'          IN lv_text_line WITH is_data-gv_waers.
      REPLACE ALL OCCURRENCES OF '&TARIH&'       IN lv_text_line WITH lv_tarih.
      REPLACE ALL OCCURRENCES OF '&FIORI_LINK&'  IN lv_text_line WITH lv_link.
      APPEND lv_text_line TO lt_body.
    ENDLOOP.

    DATA(lo_send_request) = cl_bcs=>create_persistent( ).
    DATA(lo_document) = cl_document_bcs=>create_document(
                          i_type    = 'HTM'
                          i_text    = lt_body
                          i_subject = TEXT-014 )."Cari Mutabakat Raporu
    lo_send_request->set_document( lo_document ).

    DATA(lo_sender) = cl_sapuser_bcs=>create( sy-uname ).
    lo_send_request->set_sender( lo_sender ).

    " Test Alıcısı
    DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address( TEXT-008 )."veysel@test.com
    lo_send_request->add_recipient( i_recipient = lo_recipient ).

    DATA(lv_sent) = lo_send_request->send( ).
    COMMIT WORK.

    IF lv_sent = 'X'.

      MESSAGE TEXT-005 TYPE 'S'."Mutabakat Maili Başarıyla Gönderildi!
    ENDIF.
  ENDMETHOD.

  METHOD:on_user_command.
    CASE e_salv_function.
      WHEN '&MAIL'.

        DATA(lt_rows) = mo_alv->get_selections( )->get_selected_rows( ).

        IF lt_rows IS INITIAL.
          MESSAGE TEXT-006 TYPE 'I'. "Lütfen mail atılacak müşterileri seçiniz!
          RETURN.
        ENDIF.


        LOOP AT lt_rows INTO DATA(lv_row).

          READ TABLE gt_tablo INDEX lv_row ASSIGNING FIELD-SYMBOL(<fs_secilen>).
          IF sy-subrc = 0.

            DATA: lv_exists TYPE char1.
            CLEAR lv_exists.
            SELECT SINGLE 'X' FROM zvs_mutabakat
              INTO @lv_exists
              WHERE recon_company_id = @<fs_secilen>-gv_bukrs
                AND customer_id      = @<fs_secilen>-gv_kunnr
                AND tutar            = @<fs_secilen>-gv_amount.



            IF lv_exists = 'X'.
              MESSAGE TEXT-007 TYPE 'I' DISPLAY LIKE 'E'."Bu kişiye daha önce mail gönderildi lütfen başka birini seçin
              CONTINUE. " Döngünün başına dön, sonraki müşteriye geç
            ENDIF.

            me->send_email( is_data = <fs_secilen> ).

            IF sy-subrc EQ 0.

              me->save_mutabakat_log( is_data = <fs_secilen> ).

              <fs_secilen>-gv_states = TEXT-015."Mail Gönderildi

            ENDIF.
          ENDIF.
        ENDLOOP.


        mo_alv->refresh( ).

    ENDCASE.
  ENDMETHOD.

  METHOD:save_mutabakat_log.

    DATA: ls_mutabakat TYPE zvs_mutabakat.
    CLEAR ls_mutabakat.

    ls_mutabakat-recon_id         = me->get_next_id( ). " snro numaram
    ls_mutabakat-recon_spgl_ind   = is_data-gv_umskz.
    ls_mutabakat-recon_date       = sy-datum. " Mutabakatın gönderildiği tarih
    ls_mutabakat-customer_id      = is_data-gv_kunnr.
    ls_mutabakat-recon_company_id = is_data-gv_bukrs.
    ls_mutabakat-recon_state      = 'A'.
    ls_mutabakat-tutar            = is_data-gv_amount.

    INSERT zvs_mutabakat FROM ls_mutabakat.

  ENDMETHOD.

  METHOD:prepare_popup_data.

    DATA: lt_popup TYPE STANDARD TABLE OF bapi3007_2.
    CALL FUNCTION 'BAPI_AR_ACC_GETOPENITEMS'
      EXPORTING
        companycode = is_data-gv_bukrs
        customer    = is_data-gv_kunnr
        keydate     = sy-datum
      TABLES
        lineitems   = lt_popup.

    IF lines( lt_popup ) > 0 .
      CLEAR gt_popup.

      LOOP AT lt_popup INTO DATA(ls_bapi).

        DATA: ls_vitrin TYPE ty_popup.
        CLEAR ls_vitrin.
        MOVE-CORRESPONDING ls_bapi TO ls_vitrin.

        IF ls_vitrin-db_cr_ind = 'S'.
          ls_vitrin-odk_metni = 'Borç'.
        ELSEIF ls_vitrin-db_cr_ind = 'H'.
          ls_vitrin-odk_metni = 'Alacak'.
        ENDIF.
        APPEND ls_vitrin TO gt_popup.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
