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

    METHODS validateDriverAvailability FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateDriverAvailability.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

 METHOD AssignDriver.
    " 1. Read the currently selected Driver ID for the booking
    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( DriverId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).

      " 2. Fetch the driver's availability from the database
      SELECT SINGLE availability_status
        FROM zcit_driver
        WHERE driver_id = @booking-DriverId
        INTO @DATA(lv_availability).

      " 3. CRITICAL CHECK: Block if unavailable
      " Note: Ensure the database value is actually 'NO' and not 'N' or a boolean.
      IF lv_availability = 'NO' OR lv_availability = 'No' OR lv_availability = 'no'.

        " This stops the action from making any changes
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        " This displays the error message on the UI when the button is clicked
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Action Canceled: This driver is marked as NO for availability!' )
                      ) TO reported-booking.

      ELSE.
        " 4. Driver is available -> Proceed with updating the status
        MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
          ENTITY Booking
            UPDATE FIELDS ( Status StatusCriticality )
            WITH VALUE #( ( %tky              = booking-%tky
                            Status            = 'Driver Assigned'
                            StatusCriticality = 2 ) ).
      ENDIF.
    ENDLOOP.

    " 5. Read the result to return to the UI
    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(final_bookings).

    result = VALUE #( FOR b IN final_bookings ( %tky = b-%tky %param = b ) ).
  ENDMETHOD.

  METHOD CompleteTrip.
    MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
         UPDATE FIELDS ( Status statuscriticality )
         WITH VALUE #( FOR key IN keys (
                         %tky = key-%tky
                         Status = 'Completed'
                         StatusCriticality = 3 ) ). " 3 = Green

    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).
    result = VALUE #( FOR booking IN bookings ( %tky = booking-%tky %param = booking ) ).
  ENDMETHOD.

  METHOD StartTrip.
     MODIFY ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
         UPDATE FIELDS ( Status StatusCriticality )
         WITH VALUE #( FOR key IN keys (
                         %tky = key-%tky
                         Status = 'Trip Started'
                         StatusCriticality = 5 ) ). " 5 = Blue

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

  METHOD validateDriverAvailability.
    " 1. Read the Driver IDs from the bookings being saved
    READ ENTITIES OF zi_cit_booking IN LOCAL MODE
      ENTITY Booking
        FIELDS ( DriverId ) WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      " Skip if no driver is selected yet
      CHECK booking-DriverId IS NOT INITIAL.

      " 2. Check driver availability from the driver table
      SELECT SINGLE availability_status
        FROM zcit_driver
        WHERE driver_id = @booking-DriverId
        INTO @DATA(lv_availability).

      " 3. If unavailable, trigger ERROR to abort the save
      " Checking upper and lower case just to be safe
      IF lv_availability = 'NO' OR lv_availability = 'No' OR lv_availability = 'no'.

        " This stops the save!
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.

        " This sends the message to the UI
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'The selected driver is not available!' )
                      ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

