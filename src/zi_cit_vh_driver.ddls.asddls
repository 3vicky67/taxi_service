@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Driver'
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZI_CIT_VH_DRIVER 
  as select from zcit_driver 
{
  key driver_id as DriverId,
  driver_name as DriverName,
  phone_number as PhoneNumber,
  vehicle_number as VehicleNumber,
  availability_status as AvailabilityStatus
}
