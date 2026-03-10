@EndUserText.label: 'Driver Master Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true  // This annotation requires at least one defaultSearchElement
define root view entity ZC_CIT_DRIVER
  provider contract transactional_query
  as projection on ZI_CIT_DRIVER
{
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true // 
  key DriverId,
      
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @Search.defaultSearchElement: true 
      DriverName,
      
      LicenseNumber,
      PhoneNumber,
      VehicleNumber,
      AvailabilityStatus,
      LocalLastChangedAt
}
