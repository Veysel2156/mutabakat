*&---------------------------------------------------------------------*
*& Include          ZVS_MUTABAKAT_V1_I04
*&---------------------------------------------------------------------*
INITIALIZATION.

  CREATE OBJECT go_report .
  go_report->initialization( ).

AT SELECTION-SCREEN OUTPUT.
  go_report->set_first_status( ).



START-OF-SELECTION.
  go_report->get_data( ).
  go_report->prepare_alv( ).
