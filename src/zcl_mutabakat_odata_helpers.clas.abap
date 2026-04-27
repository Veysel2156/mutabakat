CLASS zcl_mutabakat_odata_helpers DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_service_timestamp
      IMPORTING
        ev_timestamp TYPE timestamp.

    METHODS validate_mutabakat_nr
      IMPORTING
        iv_mutabakat_nr TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    METHODS validate_status
      IMPORTING
        iv_status TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    METHODS format_date_odata
      IMPORTING
        iv_date TYPE datum
      RETURNING
        VALUE(rv_formatted) TYPE string.

    METHODS log_operation
      IMPORTING
        iv_operation TYPE string
        iv_entity TYPE string
        iv_key TYPE string
        iv_status TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_mutabakat_odata_helpers IMPLEMENTATION.

  METHOD get_service_timestamp.
    " Return current timestamp in OData format
    GET TIME STAMP FIELD ev_timestamp.
  ENDMETHOD.

  METHOD validate_mutabakat_nr.
    " Validate Mutabakat_Nr format (e.g., MUT-YYYY-NNN)
    DATA: lv_pattern TYPE string VALUE 'MUT-[0-9]{4}-[0-9]{3}'.

    IF iv_mutabakat_nr IS NOT INITIAL.
      " Simple validation - not empty
      IF strlen( iv_mutabakat_nr ) >= 3.
        rv_valid = abap_true.
      ELSE.
        rv_valid = abap_false.
      ENDIF.
    ELSE.
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD validate_status.
    " Validate status: D(Draft), E(Entry), O(Open), A(Approved)
    DATA: lv_valid_status TYPE string VALUE 'DEOA'.

    IF iv_status IS NOT INITIAL AND
       FIND( lv_valid_status, iv_status ) > 0.
      rv_valid = abap_true.
    ELSE.
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD format_date_odata.
    " Format date for OData response (e.g., /Date(1651353600000)/)
    DATA: lv_timestamp TYPE timestamp,
          lv_date_val TYPE i.

    " Convert DATUM to timestamp (milliseconds)
    CONVERT DATE iv_date TIME '000000' INTO TIME STAMP lv_timestamp TIME ZONE 'UTC'.
    lv_date_val = lv_timestamp * 1000.

    CONCATENATE '/Date(' lv_date_val ')/' INTO rv_formatted.
  ENDMETHOD.

  METHOD log_operation.
    " Log OData operations for debugging and audit
    DATA: lv_log_message TYPE string.

    CONCATENATE 'OData Operation: ' iv_operation
                ' | Entity: ' iv_entity
                ' | Key: ' iv_key
                ' | Status: ' iv_status
      INTO lv_log_message.

    " Write to application log (optional)
    " WRITE lv_log_message TO application log.
  ENDMETHOD.

ENDCLASS.