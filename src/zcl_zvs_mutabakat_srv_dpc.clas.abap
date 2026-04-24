CLASS zcl_zvs_mutabakat_srv_dpc DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_mgw_push_abs_data
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS send_notification_email
      IMPORTING
        !is_data TYPE zvs_mutabakat .

    INTERFACES /iwbep/if_sb_dpc_comm_services .
    INTERFACES /iwbep/if_sb_gen_dpc_injection .

    METHODS /iwbep/if_mgw_appl_srv_runtime~get_entityset
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_entity
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~update_entity
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_entity
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~delete_entity
        REDEFINITION .
  PROTECTED SECTION.

    DATA mo_injection TYPE REF TO /iwbep/if_sb_gen_dpc_injection .

    METHODS mutabakatset_create_entity
      IMPORTING
        !iv_entity_name          TYPE string
        !iv_entity_set_name      TYPE string
        !iv_source_name          TYPE string
        !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
        !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c OPTIONAL
        !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
        !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider OPTIONAL
      EXPORTING
        !er_entity               TYPE zcl_zvs_mutabakat_srv_mpc=>ts_mutabakat
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .
    METHODS mutabakatset_delete_entity
      IMPORTING
        !iv_entity_name          TYPE string
        !iv_entity_set_name      TYPE string
        !iv_source_name          TYPE string
        !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
        !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_d OPTIONAL
        !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .
    METHODS mutabakatset_get_entity
      IMPORTING
        !iv_entity_name          TYPE string
        !iv_entity_set_name      TYPE string
        !iv_source_name          TYPE string
        !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
        !io_request_object       TYPE REF TO /iwbep/if_mgw_req_entity OPTIONAL
        !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity OPTIONAL
        !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      EXPORTING
        !er_entity               TYPE zcl_zvs_mutabakat_srv_mpc=>ts_mutabakat
        !es_response_context     TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_entity_cntxt
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .
    METHODS mutabakatset_get_entityset
      IMPORTING
        !iv_entity_name           TYPE string
        !iv_entity_set_name       TYPE string
        !iv_source_name           TYPE string
        !it_filter_select_options TYPE /iwbep/t_mgw_select_option
        !is_paging                TYPE /iwbep/s_mgw_paging
        !it_key_tab               TYPE /iwbep/t_mgw_name_value_pair
        !it_navigation_path       TYPE /iwbep/t_mgw_navigation_path
        !it_order                 TYPE /iwbep/t_mgw_sorting_order
        !iv_filter_string         TYPE string
        !iv_search_string         TYPE string
        !io_tech_request_context  TYPE REF TO /iwbep/if_mgw_req_entityset OPTIONAL
      EXPORTING
        !et_entityset             TYPE zcl_zvs_mutabakat_srv_mpc=>tt_mutabakat
        !es_response_context      TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_context
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .
    METHODS mutabakatset_update_entity
      IMPORTING
        !iv_entity_name          TYPE string
        !iv_entity_set_name      TYPE string
        !iv_source_name          TYPE string
        !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
        !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_u OPTIONAL
        !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
        !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider OPTIONAL
      EXPORTING
        !er_entity               TYPE zcl_zvs_mutabakat_srv_mpc=>ts_mutabakat
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .

    METHODS check_subscription_authority
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZVS_MUTABAKAT_SRV_DPC IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_entity.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_CRT_ENTITY_BASE
*&* This class has been generated on 04/17/2026 06:47:15 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZVS_MUTABAKAT_SRV_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

    DATA mutabakatset_create_entity TYPE zcl_zvs_mutabakat_srv_mpc=>ts_mutabakat.
    DATA lv_entityset_name TYPE string.

    lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

    CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  MutabakatSet
*-------------------------------------------------------------------------*
      WHEN 'MutabakatSet'.
*     Call the entity set generated method
        mutabakatset_create_entity(
             EXPORTING iv_entity_name     = iv_entity_name
                       iv_entity_set_name = iv_entity_set_name
                       iv_source_name     = iv_source_name
                       io_data_provider   = io_data_provider
                       it_key_tab         = it_key_tab
                       it_navigation_path = it_navigation_path
                       io_tech_request_context = io_tech_request_context
           	 IMPORTING er_entity          = mutabakatset_create_entity
        ).
*     Send specific entity data to the caller interfaces
        copy_data_to_ref(
          EXPORTING
            is_data = mutabakatset_create_entity
          CHANGING
            cr_data = er_entity
       ).

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~create_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             io_data_provider   = io_data_provider
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
      ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~delete_entity.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_DEL_ENTITY_BASE
*&* This class has been generated on 04/17/2026 06:47:15 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZVS_MUTABAKAT_SRV_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

    DATA lv_entityset_name TYPE string.

    lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

    CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  MutabakatSet
*-------------------------------------------------------------------------*
      WHEN 'MutabakatSet'.
*     Call the entity set generated method
        mutabakatset_delete_entity(
             EXPORTING iv_entity_name     = iv_entity_name
                       iv_entity_set_name = iv_entity_set_name
                       iv_source_name     = iv_source_name
                       it_key_tab         = it_key_tab
                       it_navigation_path = it_navigation_path
                       io_tech_request_context = io_tech_request_context
        ).

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~delete_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
    ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entity.
*&-----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_GETENTITY_BASE
*&* This class has been generated  on 04/17/2026 06:47:15 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZVS_MUTABAKAT_SRV_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

    DATA mutabakatset_get_entity TYPE zcl_zvs_mutabakat_srv_mpc=>ts_mutabakat.
    DATA lv_entityset_name TYPE string.
    DATA lr_entity TYPE REF TO data.                        "#EC NEEDED

    lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

    CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  MutabakatSet
*-------------------------------------------------------------------------*
      WHEN 'MutabakatSet'.
*     Call the entity set generated method
        mutabakatset_get_entity(
             EXPORTING iv_entity_name     = iv_entity_name
                       iv_entity_set_name = iv_entity_set_name
                       iv_source_name     = iv_source_name
                       it_key_tab         = it_key_tab
                       it_navigation_path = it_navigation_path
                       io_tech_request_context = io_tech_request_context
           	 IMPORTING er_entity          = mutabakatset_get_entity
                       es_response_context = es_response_context
        ).

        IF mutabakatset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = mutabakatset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~get_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TMP_ENTITYSET_BASE
*&* This class has been generated on 04/17/2026 06:47:15 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZVS_MUTABAKAT_SRV_DPC_EXT
*&-----------------------------------------------------------------------------------------------*
    DATA mutabakatset_get_entityset TYPE zcl_zvs_mutabakat_srv_mpc=>tt_mutabakat.
    DATA lv_entityset_name TYPE string.

    lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

    CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  MutabakatSet
*-------------------------------------------------------------------------*
      WHEN 'MutabakatSet'.
*     Call the entity set generated method
        mutabakatset_get_entityset(
          EXPORTING
           iv_entity_name = iv_entity_name
           iv_entity_set_name = iv_entity_set_name
           iv_source_name = iv_source_name
           it_filter_select_options = it_filter_select_options
           it_order = it_order
           is_paging = is_paging
           it_navigation_path = it_navigation_path
           it_key_tab = it_key_tab
           iv_filter_string = iv_filter_string
           iv_search_string = iv_search_string
           io_tech_request_context = io_tech_request_context
         IMPORTING
           et_entityset = mutabakatset_get_entityset
           es_response_context = es_response_context
         ).
*     Send specific entity data to the caller interface
        copy_data_to_ref(
          EXPORTING
            is_data = mutabakatset_get_entityset
          CHANGING
            cr_data = er_entityset
        ).

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~get_entityset(
          EXPORTING
            iv_entity_name = iv_entity_name
            iv_entity_set_name = iv_entity_set_name
            iv_source_name = iv_source_name
            it_filter_select_options = it_filter_select_options
            it_order = it_order
            is_paging = is_paging
            it_navigation_path = it_navigation_path
            it_key_tab = it_key_tab
            iv_filter_string = iv_filter_string
            iv_search_string = iv_search_string
            io_tech_request_context = io_tech_request_context
         IMPORTING
           er_entityset = er_entityset ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~update_entity.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_UPD_ENTITY_BASE
*&* This class has been generated on 04/17/2026 06:47:15 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_ZVS_MUTABAKAT_SRV_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

    DATA mutabakatset_update_entity TYPE zcl_zvs_mutabakat_srv_mpc=>ts_mutabakat.
    DATA lv_entityset_name TYPE string.
    DATA lr_entity TYPE REF TO data.                        "#EC NEEDED

    lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

    CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  MutabakatSet
*-------------------------------------------------------------------------*
      WHEN 'MutabakatSet'.
*     Call the entity set generated method
        mutabakatset_update_entity(
             EXPORTING iv_entity_name     = iv_entity_name
                       iv_entity_set_name = iv_entity_set_name
                       iv_source_name     = iv_source_name
                       io_data_provider   = io_data_provider
                       it_key_tab         = it_key_tab
                       it_navigation_path = it_navigation_path
                       io_tech_request_context = io_tech_request_context
           	 IMPORTING er_entity          = mutabakatset_update_entity
        ).
        IF mutabakatset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = mutabakatset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~update_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             io_data_provider   = io_data_provider
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_sb_dpc_comm_services~commit_work.
* Call RFC commit work functionality
    DATA lt_message      TYPE bapiret2.                     "#EC NEEDED
    DATA lv_message_text TYPE bapi_msg.
    DATA lo_logger       TYPE REF TO /iwbep/cl_cos_logger.
    DATA lv_subrc        TYPE syst-subrc.

    lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).

    IF iv_rfc_dest IS INITIAL OR iv_rfc_dest EQ 'NONE'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = abap_true
        IMPORTING
          return = lt_message.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        DESTINATION iv_rfc_dest
        EXPORTING
          wait                  = abap_true
        IMPORTING
          return                = lt_message
        EXCEPTIONS
          communication_failure = 1000 MESSAGE lv_message_text
          system_failure        = 1001 MESSAGE lv_message_text
          OTHERS                = 1002.

      IF sy-subrc <> 0.
        lv_subrc = sy-subrc.
        /iwbep/cl_sb_gen_dpc_rt_util=>rfc_exception_handling(
            EXPORTING
              iv_subrc            = lv_subrc
              iv_exp_message_text = lv_message_text
              io_logger           = lo_logger ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD /iwbep/if_sb_dpc_comm_services~get_generation_strategy.
* Get generation strategy
    rv_generation_strategy = '1'.
  ENDMETHOD.


  METHOD /iwbep/if_sb_dpc_comm_services~log_message.
* Log message in the application log
    DATA lo_logger TYPE REF TO /iwbep/cl_cos_logger.
    DATA lv_text TYPE /iwbep/sup_msg_longtext.

    MESSAGE ID iv_msg_id TYPE iv_msg_type NUMBER iv_msg_number
      WITH iv_msg_v1 iv_msg_v2 iv_msg_v3 iv_msg_v4 INTO lv_text.

    lo_logger = mo_context->get_logger( ).
    lo_logger->log_message(
      EXPORTING
       iv_msg_type   = iv_msg_type
       iv_msg_id     = iv_msg_id
       iv_msg_number = iv_msg_number
       iv_msg_text   = lv_text
       iv_msg_v1     = iv_msg_v1
       iv_msg_v2     = iv_msg_v2
       iv_msg_v3     = iv_msg_v3
       iv_msg_v4     = iv_msg_v4
       iv_agent      = 'DPC' ).
  ENDMETHOD.


  METHOD /iwbep/if_sb_dpc_comm_services~rfc_exception_handling.
* RFC call exception handling
    DATA lo_logger  TYPE REF TO /iwbep/cl_cos_logger.

    lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).

    /iwbep/cl_sb_gen_dpc_rt_util=>rfc_exception_handling(
      EXPORTING
        iv_subrc            = iv_subrc
        iv_exp_message_text = iv_exp_message_text
        io_logger           = lo_logger ).
  ENDMETHOD.


  METHOD /iwbep/if_sb_dpc_comm_services~rfc_save_log.
    DATA lo_logger  TYPE REF TO /iwbep/cl_cos_logger.
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.

    lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).
    lo_message_container = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    " Save the RFC call log in the application log
    /iwbep/cl_sb_gen_dpc_rt_util=>rfc_save_log(
      EXPORTING
        is_return            = is_return
        iv_entity_type       = iv_entity_type
        it_return            = it_return
        it_key_tab           = it_key_tab
        io_logger            = lo_logger
        io_message_container = lo_message_container ).
  ENDMETHOD.


  METHOD /iwbep/if_sb_dpc_comm_services~set_injection.
* Unit test injection
    IF io_unit IS BOUND.
      mo_injection = io_unit.
    ELSE.
      mo_injection = me.
    ENDIF.
  ENDMETHOD.


  METHOD check_subscription_authority.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
      EXPORTING
        textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
        method = 'CHECK_SUBSCRIPTION_AUTHORITY'.
  ENDMETHOD.


  METHOD mutabakatset_create_entity.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
      EXPORTING
        textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
        method = 'MUTABAKATSET_CREATE_ENTITY'.
  ENDMETHOD.


  METHOD mutabakatset_delete_entity.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
      EXPORTING
        textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
        method = 'MUTABAKATSET_DELETE_ENTITY'.
  ENDMETHOD.


  METHOD mutabakatset_get_entity.
    DATA: ls_key   TYPE /iwbep/s_mgw_name_value_pair,
          lv_bukrs TYPE zvs_mutabakat-recon_company_id,
          lv_kunnr TYPE zvs_mutabakat-customer_id,
          lv_id    TYPE zvs_mutabakat-recon_id.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'ReconCompanyId'.
    IF sy-subrc = 0. lv_bukrs = ls_key-value. ENDIF.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'CustomerId'.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_key-value
        IMPORTING
          output = lv_kunnr.
    ENDIF.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'ReconId'.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_key-value
        IMPORTING
          output = lv_id.
    ENDIF.

    SELECT SINGLE * FROM zvs_mutabakat
      INTO @DATA(ls_mutabakat)
      WHERE recon_company_id = @lv_bukrs
        AND customer_id      = @lv_kunnr
        AND recon_id         = @lv_id.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_mutabakat TO er_entity.

      SELECT SINGLE name1 FROM kna1
        INTO @er_entity-customername
        WHERE kunnr = @ls_mutabakat-customer_id.

      er_entity-amount   = ls_mutabakat-tutar.
      er_entity-currency = 'USD'.
    ENDIF.
  ENDMETHOD.


  METHOD mutabakatset_get_entityset.
    DATA: lv_bukrs TYPE zvs_mutabakat-recon_company_id,
          lv_kunnr TYPE zvs_mutabakat-customer_id.

    LOOP AT it_filter_select_options INTO DATA(ls_filter).
      READ TABLE ls_filter-select_options INTO DATA(ls_opt) INDEX 1.
      IF sy-subrc = 0.
        IF ls_filter-property = 'ReconCompanyId' OR ls_filter-property = 'RECON_COMPANY_ID'.
          lv_bukrs = ls_opt-low.
        ELSEIF ls_filter-property = 'CustomerId' OR ls_filter-property = 'CUSTOMER_ID'.
          lv_kunnr = ls_opt-low.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SELECT * FROM zvs_mutabakat
      INTO TABLE @DATA(lt_mutabakat)
      WHERE recon_company_id = @lv_bukrs
        AND customer_id      = @lv_kunnr
      ORDER BY recon_id DESCENDING.

    READ TABLE lt_mutabakat INTO DATA(ls_mutabakat) INDEX 1.
    IF sy-subrc = 0.
      DATA: ls_entity LIKE LINE OF et_entityset.
      MOVE-CORRESPONDING ls_mutabakat TO ls_entity.

      SELECT SINGLE name1 FROM kna1
        INTO @DATA(lv_name1)
        WHERE kunnr = @ls_mutabakat-customer_id.
      IF sy-subrc = 0.
        ls_entity-customername = lv_name1.
      ENDIF.

      ls_entity-amount   = ls_mutabakat-tutar.
      ls_entity-currency = 'USD'.

      APPEND ls_entity TO et_entityset.
    ENDIF.
  ENDMETHOD.


METHOD mutabakatset_update_entity.
    DATA: ls_request_data LIKE er_entity,
          ls_key          TYPE /iwbep/s_mgw_name_value_pair,
          lv_bukrs        TYPE zvs_mutabakat-recon_company_id,
          lv_kunnr        TYPE zvs_mutabakat-customer_id,
          lv_id           TYPE zvs_mutabakat-recon_id,
          ls_db_record    TYPE zvs_mutabakat.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_request_data ).

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'ReconCompanyId'.
    IF sy-subrc = 0. lv_bukrs = ls_key-value. ENDIF.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'CustomerId'.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING input  = ls_key-value
        IMPORTING output = lv_kunnr.
    ENDIF.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'ReconId'.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING input  = ls_key-value
        IMPORTING output = lv_id.
    ENDIF.

    SELECT SINGLE * FROM zvs_mutabakat
      INTO @ls_db_record
      WHERE recon_company_id = @lv_bukrs
        AND customer_id      = @lv_kunnr
        AND recon_id         = @lv_id.

    IF sy-subrc = 0.
      ls_db_record-recon_state = ls_request_data-recon_state.
      ls_db_record-description = ls_request_data-description.

      UPDATE zvs_mutabakat FROM ls_db_record.

      IF sy-subrc eq 0.
       me->send_notification_email( is_data = ls_db_record  ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


METHOD send_notification_email.
    DATA: lo_send_request TYPE REF TO cl_bcs,
          lo_document     TYPE REF TO cl_document_bcs,
          lo_sender       TYPE REF TO cl_sapuser_bcs,
          lo_recipient    TYPE REF TO if_recipient_bcs,
          lt_main_text    TYPE bcsy_text,
          lv_subject      TYPE so_obj_des,
          lx_bcs          TYPE REF TO cx_bcs.

    TRY.
        lo_send_request = cl_bcs=>create_persistent( ).

        " Mail içeriği
        APPEND 'Sayın İlgili,' TO lt_main_text.
        APPEND |{ is_data-customer_id } numaralı müşteriden bir MUTABAKAT REDDİ gelmiştir.| TO lt_main_text.
        APPEND |Açıklama: { is_data-description }| TO lt_main_text.
        APPEND 'Lütfen SAP üzerinden kontrol ediniz.' TO lt_main_text.

        lv_subject = |DİKKAT: Mutabakat Reddi - Müşteri: { is_data-customer_id }|.

        lo_document = cl_document_bcs=>create_document(
                        i_type    = 'RAW'
                        i_text    = lt_main_text
                        i_subject = lv_subject ).

        lo_send_request->set_document( lo_document ).
        lo_sender = cl_sapuser_bcs=>create( sy-uname ).
        lo_send_request->set_sender( lo_sender ).


        lo_recipient = cl_cam_address_bcs=>create_internet_address( 'muhasebe@sirket.com' ).
        lo_send_request->add_recipient( lo_recipient ).

        lo_send_request->set_send_immediately( i_send_immediately = abap_true ).
        lo_send_request->send( ).

        COMMIT WORK.

      CATCH cx_bcs INTO lx_bcs.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
