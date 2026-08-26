@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'to know about BOOKING'
define root view entity ZI_CIT_BOOKING 
  as select from zcit_booking
  association [0..1] to ZI_CIT_DRIVER as _Driver on $projection.DriverId = _Driver.DriverId
{
  key booking_uuid          as BookingUuid,
      booking_id            as BookingId,
      customer_name         as CustomerName,
      pickup_location       as PickupLocation,
      drop_location         as DropLocation,
      booking_date          as BookingDate,
      status                as Status,
      currency_code         as CurrencyCode,
      driver_id             as DriverId,
      
      statuscriticality     as StatusCriticality, // <-- Corrected alias
      
      _Driver.DriverName    as DriverName,
      _Driver.PhoneNumber   as PhoneNumber,
      vehicle_number        as VehicleNumber,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      fare_amount           as FareAmount,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      _Driver
}
