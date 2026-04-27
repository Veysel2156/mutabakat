CLASS zvs_mutabakat_odata_dpc DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_mgw_dpc_std
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_types~get_timestamp
      REDEFINITION .

  PROTECTED SECTION.
    METHODS baslikset_get_entityset
      REDEFINITION .
    METHODS baslikset_get_entity
      REDEFINITION .
    METHODS baslikset_create_entity
      REDEFINITION .
    METHODS baslikset_update_entity
      REDEFINITION .
    METHODS baslikset_delete_entity
      REDEFINITION .

    METHODS kalemset_get_entityset
      REDEFINITION .
    METHODS kalemset_get_entity
      REDEFINITION .
    METHODS kalemset_create_entity
      REDEFINITION .

    METHODS baslik_kalemler_get_entityset
      REDEFINITION .

  PRIVATE SECTION.
    DATA: mo_helpers TYPE REF TO zcl_mutabakat_odata_helpers .

ENDCLASS.


CLASS zvs_mutabakat_odata_dpc IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_types~get_timestamp.
    IF mo_helpers IS INITIAL.
      CREATE OBJECT mo_helpers.
    ENDIF.
    mo_helpers->get_service_timestamp(
      IMPORTING
        ev_timestamp = ev_timestamp
    ).
  ENDMETHOD.

  " ==================== BASLIKSET OPERATIONS ====================

  METHOD baslikset_get_entityset.
    DATA: lt_baslik TYPE TABLE OF zvs_mutabakat_odata_s_baslik,
          ls_baslik TYPE zvs_mutabakat_odata_s_baslik,
          lt_source TYPE TABLE OF zvs_mut_baslik.

    " Select all Baslik records from database
    SELECT * INTO TABLE lt_source FROM zvs_mut_baslik
      ORDER BY id DESC.

    IF sy-subrc EQ 0.
      LOOP AT lt_source INTO DATA(ls_source).
        MOVE-CORRESPONDING ls_source TO ls_baslik.
        APPEND ls_baslik TO lt_baslik.
      ENDLOOP.
    ENDIF.

    " Copy to response structure
    MOVE-CORRESPONDING lt_baslik TO et_entityset.
    er_entityset->set_data( lt_baslik ).

  ENDMETHOD.

  METHOD baslikset_get_entity.
    DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lv_id TYPE string,
          ls_baslik TYPE zvs_mutabakat_odata_s_baslik,
          ls_source TYPE zvs_mut_baslik.

    " Get key from request
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ID'.
    IF sy-subrc EQ 0.
      lv_id = ls_key_tab-value.
    ENDIF.

    " Validate key
    IF lv_id IS INITIAL.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'ID field is mandatory'.
    ENDIF.

    " Select record from database
    SELECT SINGLE * INTO ls_source FROM zvs_mut_baslik
      WHERE id = lv_id.

    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_found_exception
        EXPORTING
          textid = /iwbep/cx_mgw_not_found_exception=>not_found.
    ENDIF.

    MOVE-CORRESPONDING ls_source TO ls_baslik.
    er_entity->set_data( ls_baslik ).

  ENDMETHOD.

  METHOD baslikset_create_entity.
    DATA: ls_baslik TYPE zvs_mutabakat_odata_s_baslik,
          ls_source TYPE zvs_mut_baslik,
          lv_id TYPE string.

    " Get incoming data
    io_entity->get_data(
      IMPORTING
        es_data = ls_baslik
    ).

    " Validate mandatory fields
    IF ls_baslik-id IS INITIAL OR
       ls_baslik-mutabakat_nr IS INITIAL.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'ID and Mutabakat_Nr are mandatory'.
    ENDIF.

    " Check for duplicates
    SELECT SINGLE * INTO ls_source FROM zvs_mut_baslik
      WHERE id = ls_baslik-id.

    IF sy-subrc EQ 0.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'ID already exists'.
    ENDIF.

    " Map and insert
    MOVE-CORRESPONDING ls_baslik TO ls_source.
    ls_source-tarih = sy-datum.
    ls_source-kullanici = sy-uname.

    INSERT INTO zvs_mut_baslik VALUES ls_source.

    IF sy-subrc EQ 0.
      er_entity->set_data( ls_baslik ).
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'Error creating Baslik'.
    ENDIF.

  ENDMETHOD.

  METHOD baslikset_update_entity.
    DATA: ls_baslik TYPE zvs_mutabakat_odata_s_baslik,
          ls_source TYPE zvs_mut_baslik,
          ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lv_id TYPE string.

    " Get key
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ID'.
    IF sy-subrc EQ 0.
      lv_id = ls_key_tab-value.
    ENDIF.

    " Get update data
    io_entity->get_data( IMPORTING es_data = ls_baslik ).

    " Select existing record
    SELECT SINGLE * INTO ls_source FROM zvs_mut_baslik
      WHERE id = lv_id.

    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_found_exception
        EXPORTING
          textid = /iwbep/cx_mgw_not_found_exception=>not_found.
    ENDIF.

    " Update fields (preserve key)
    IF ls_baslik-status IS NOT INITIAL.
      ls_source-status = ls_baslik-status.
    ENDIF.
    IF ls_baslik-aciklama IS NOT INITIAL.
      ls_source-aciklama = ls_baslik-aciklama.
    ENDIF.

    " Update database
    UPDATE zvs_mut_baslik FROM ls_source.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING ls_source TO ls_baslik.
      er_entity->set_data( ls_baslik ).
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'Error updating Baslik'.
    ENDIF.

  ENDMETHOD.

  METHOD baslikset_delete_entity.
    DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lv_id TYPE string,
          ls_source TYPE zvs_mut_baslik.

    " Get key
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ID'.
    IF sy-subrc EQ 0.
      lv_id = ls_key_tab-value.
    ENDIF.

    " Select record
    SELECT SINGLE * INTO ls_source FROM zvs_mut_baslik
      WHERE id = lv_id.

    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_found_exception
        EXPORTING
          textid = /iwbep/cx_mgw_not_found_exception=>not_found.
    ENDIF.

    " Delete from database
    DELETE FROM zvs_mut_baslik WHERE id = lv_id.

    IF sy-subrc EQ 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'Error deleting Baslik'.
    ENDIF.

  ENDMETHOD.

  " ==================== KALEMSET OPERATIONS ====================

  METHOD kalemset_get_entityset.
    DATA: lt_kalem TYPE TABLE OF zvs_mutabakat_odata_s_kalem,
          ls_kalem TYPE zvs_mutabakat_odata_s_kalem,
          lt_source TYPE TABLE OF zvs_mut_kalem.

    SELECT * INTO TABLE lt_source FROM zvs_mut_kalem
      ORDER BY kalem_id DESC.

    IF sy-subrc EQ 0.
      LOOP AT lt_source INTO DATA(ls_source).
        MOVE-CORRESPONDING ls_source TO ls_kalem.
        APPEND ls_kalem TO lt_kalem.
      ENDLOOP.
    ENDIF.

    MOVE-CORRESPONDING lt_kalem TO et_entityset.
    er_entityset->set_data( lt_kalem ).

  ENDMETHOD.

  METHOD kalemset_get_entity.
    DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lv_kalem_id TYPE string,
          ls_kalem TYPE zvs_mutabakat_odata_s_kalem,
          ls_source TYPE zvs_mut_kalem.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Kalem_ID'.
    IF sy-subrc EQ 0.
      lv_kalem_id = ls_key_tab-value.
    ENDIF.

    SELECT SINGLE * INTO ls_source FROM zvs_mut_kalem
      WHERE kalem_id = lv_kalem_id.

    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_found_exception
        EXPORTING
          textid = /iwbep/cx_mgw_not_found_exception=>not_found.
    ENDIF.

    MOVE-CORRESPONDING ls_source TO ls_kalem.
    er_entity->set_data( ls_kalem ).

  ENDMETHOD.

  METHOD kalemset_create_entity.
    DATA: ls_kalem TYPE zvs_mutabakat_odata_s_kalem,
          ls_source TYPE zvs_mut_kalem.

    io_entity->get_data( IMPORTING es_data = ls_kalem ).

    IF ls_kalem-kalem_id IS INITIAL OR ls_kalem-id IS INITIAL.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'Kalem_ID and ID are mandatory'.
    ENDIF.

    MOVE-CORRESPONDING ls_kalem TO ls_source.

    INSERT INTO zvs_mut_kalem VALUES ls_source.

    IF sy-subrc EQ 0.
      er_entity->set_data( ls_kalem ).
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = /iwbep/cx_mgw_busi_exception=>business_error
          message_v1 = 'Error creating Kalem'.
    ENDIF.

  ENDMETHOD.

  " ==================== NAVIGATION PROPERTIES ====================

  METHOD baslik_kalemler_get_entityset.
    DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lv_baslik_id TYPE string,
          lt_kalem TYPE TABLE OF zvs_mutabakat_odata_s_kalem,
          ls_kalem TYPE zvs_mutabakat_odata_s_kalem,
          lt_source TYPE TABLE OF zvs_mut_kalem.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ID'.
    IF sy-subrc EQ 0.
      lv_baslik_id = ls_key_tab-value.
    ENDIF.

    " Get Kalemler for this Baslik
    SELECT * INTO TABLE lt_source FROM zvs_mut_kalem
      WHERE id = lv_baslik_id
      ORDER BY kalem_id.

    IF sy-subrc EQ 0.
      LOOP AT lt_source INTO DATA(ls_source).
        MOVE-CORRESPONDING ls_source TO ls_kalem.
        APPEND ls_kalem TO lt_kalem.
      ENDLOOP.
    ENDIF.

    MOVE-CORRESPONDING lt_kalem TO et_entityset.
    er_entityset->set_data( lt_kalem ).

  ENDMETHOD.

ENDCLASS.