@EndUserText.label: 'TO PROJECT THE BOOKING'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_CIT_BOOKING 
  provider contract transactional_query
  as projection on ZI_CIT_BOOKING
{
  key BookingUuid,
      BookingId,
      CustomerName,
      PickupLocation,
      DropLocation,
      BookingDate,
      Status,
      StatusCriticality, // <-- Directly project the field from ZI
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,
      
      @Consumption.valueHelpDefinition: [{ 
          entity: { name: 'ZI_CIT_VH_DRIVER', element: 'DriverId' },
          additionalBinding: [
            { localElement: 'VehicleNumber', element: 'VehicleNumber', usage: #RESULT },
            { localElement: 'DriverName',    element: 'DriverName',    usage: #RESULT },
            { localElement: 'PhoneNumber',   element: 'PhoneNumber',   usage: #RESULT }
          ] 
      }]
      @ObjectModel.text.element: ['DriverName']
      DriverId,
      
      DriverName,
      PhoneNumber,
      VehicleNumber,
      FareAmount,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      
      _Driver
}
