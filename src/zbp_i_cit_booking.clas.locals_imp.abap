CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS AssignDriver FOR MODIFY
      IMPORTING keys FOR ACTION Booking~AssignDriver RESULT result.

    METHODS CompleteTrip FOR MODIFY
      IMPORTING keys FOR ACTION Booking~CompleteTrip RESULT result.

    METHODS StartTrip FOR MODIFY
      IMPORTING keys FOR ACTION Booking~StartTrip RESULT result.

    METHODS calculateBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~calculateBookingId.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~setInitialStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD AssignDriver.
    MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
         UPDATE FIELDS ( Status )
         WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'Driver Assigned' ) ).

    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).
    result = VALUE #( FOR booking IN bookings ( %tky = booking-%tky %param = booking ) ).
  ENDMETHOD.

  METHOD CompleteTrip.
    MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
         UPDATE FIELDS ( Status )
         WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'Completed' ) ).

    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).
    result = VALUE #( FOR booking IN bookings ( %tky = booking-%tky %param = booking ) ).
  ENDMETHOD.

  METHOD StartTrip.
     MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
         UPDATE FIELDS ( Status )
         WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'In Progress' ) ).

    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).
    result = VALUE #( FOR booking IN bookings ( %tky = booking-%tky %param = booking ) ).
  ENDMETHOD.

  METHOD calculateBookingId.
    " 1. Read records being saved
    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( BookingId ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    " 2. Remove records that already have an ID (e.g., during updates)
    DELETE bookings WHERE BookingId IS NOT INITIAL.
    CHECK bookings IS NOT INITIAL.

    " 3. Get the current highest Booking ID from the database
    DATA max_booking_id TYPE zcit_booking-booking_id.
    SELECT SINGLE FROM zcit_booking FIELDS MAX( booking_id ) INTO @max_booking_id.

    " 4. Extract the numeric part and increment it
    DATA(next_number) = 1000. " Default starting base number
    IF max_booking_id IS NOT INITIAL AND max_booking_id CS 'BK'.
      DATA(numeric_part) = substring_after( val = max_booking_id sub = 'BK' ).
      IF numeric_part CO ' 0123456789'. " Ensure it contains only numbers
        next_number = CONV i( numeric_part ).
      ENDIF.
    ENDIF.

    " 5. Assign the new IDs to the records
    MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( BookingId )
        WITH VALUE #( FOR booking IN bookings
                      " Increment number safely for each new record
                      LET curr_num = next_number + sy-tabix
                          " Simple string template formatting (e.g., 'BK' + '1001')
                          formatted_id = |BK{ curr_num }| IN
                      ( %tky      = booking-%tky
                        BookingId = formatted_id ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DELETE bookings WHERE Status IS NOT INITIAL.
    CHECK bookings IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR booking IN bookings
                      ( %tky = booking-%tky
                        Status = 'Booked' ) ).
  ENDMETHOD.

ENDCLASS.
