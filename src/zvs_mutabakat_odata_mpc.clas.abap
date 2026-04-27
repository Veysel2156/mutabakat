CLASS zvs_mutabakat_odata_mpc DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_mgw_push_abs_data
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_types~get_timestamp
      REDEFINITION .

  PROTECTED SECTION.
    METHODS define_entity_sets
      REDEFINITION .
    METHODS define_entity_types
      REDEFINITION .
    METHODS define_associations
      REDEFINITION .
    METHODS define_navigation_properties
      REDEFINITION .

  PRIVATE SECTION.

ENDCLASS.


CLASS zvs_mutabakat_odata_mpc IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_types~get_timestamp.
    zcl_mutabakat_odata_helpers=>get_service_timestamp(
      IMPORTING
        ev_timestamp = ev_timestamp
    ).
  ENDMETHOD.

  METHOD define_entity_types.
    " ==================== BASLIK (Header) Entity Type ====================
    DATA(lo_baslik) = model->create_entity_type(
      iv_entity_name = 'Baslik'
      iv_entity_type_category = /iwbep/if_mgw_med_odata_types=>gc_category_entity_type
    ).

    lo_baslik->add_key_property(
      iv_property_name = 'ID'
      iv_primitive_type = /iwbep/if_mgw_med_odata_types=>gc_property_type_key
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_baslik->add_property(
      iv_property_name = 'Mutabakat_Nr'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_baslik->add_property(
      iv_property_name = 'Status'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_baslik->add_property(
      iv_property_name = 'Aciklama'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_baslik->add_property(
      iv_property_name = 'Tarih'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_datetime
    ).

    lo_baslik->add_property(
      iv_property_name = 'Kullanici'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    " ==================== KALEM (Item) Entity Type ====================
    DATA(lo_kalem) = model->create_entity_type(
      iv_entity_name = 'Kalem'
      iv_entity_type_category = /iwbep/if_mgw_med_odata_types=>gc_category_entity_type
    ).

    lo_kalem->add_key_property(
      iv_property_name = 'Kalem_ID'
      iv_primitive_type = /iwbep/if_mgw_med_odata_types=>gc_property_type_key
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_kalem->add_property(
      iv_property_name = 'ID'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_kalem->add_property(
      iv_property_name = 'Detay_Aciklamasi'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

    lo_kalem->add_property(
      iv_property_name = 'Satir_Durum'
      iv_data_type = /iwbep/if_mgw_med_odata_types=>gc_property_datatype_string
    ).

  ENDMETHOD.

  METHOD define_entity_sets.
    " Baslik Entity Set
    DATA(lo_baslik_set) = model->create_entity_set(
      iv_entity_set_name = 'BaslikSet'
      iv_entity_type_name = 'Baslik'
    ).

    " Kalem Entity Set
    DATA(lo_kalem_set) = model->create_entity_set(
      iv_entity_set_name = 'KalemSet'
      iv_entity_type_name = 'Kalem'
    ).

  ENDMETHOD.

  METHOD define_associations.
    " Association: Baslik to Kalem (1:N)
    model->create_association(
      iv_association_name = 'Baslik_Kalem'
      iv_from_entity_type_name = 'Baslik'
      iv_from_multiplicity = /iwbep/if_mgw_med_odata_types=>gc_multiplicity_one
      iv_to_entity_type_name = 'Kalem'
      iv_to_multiplicity = /iwbep/if_mgw_med_odata_types=>gc_multiplicity_many
      iv_from_property_name = 'ID'
      iv_to_property_name = 'ID'
    ).

  ENDMETHOD.

  METHOD define_navigation_properties.
    " Navigation: Baslik -> Kalem
    model->create_navigation_property(
      iv_entity_type_name = 'Baslik'
      iv_navigation_name = 'Kalemler'
      iv_association_name = 'Baslik_Kalem'
      iv_from_role_name = 'Baslik'
      iv_to_role_name = 'Kalem'
    ).

  ENDMETHOD.

ENDCLASS.
