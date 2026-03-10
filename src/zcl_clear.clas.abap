CLASS zcl_clear DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_clear IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Delete all records from active and draft tables
    DELETE FROM zcit_driver.
    DELETE FROM zcit_driver_d.
    DELETE FROM zcit_booking.
    DELETE FROM zcit_booking_d.
    COMMIT WORK.

    DELETE FROM zcit_driver.
    IF sy-subrc = 0.
      out->write( '✅ Success: All corrupted data deleted. Table is now clean.' ).
    ELSE.
      out->write( 'Table is already empty!' ).
    ENDIF.

    out->write( 'Test data deleted successfully! You can now activate your table.' ).
  ENDMETHOD.
ENDCLASS.
