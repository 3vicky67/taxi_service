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
  @ObjectModel.text.element: ['DriverName'] // Associates the ID with the Name on the UI
  DriverId,
  
  DriverName,     // <-- Added
  PhoneNumber,    // <-- Added
  VehicleNumber,
  FareAmount,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  
  _Driver
}
