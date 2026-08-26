@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Driver Master Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CIT_DRIVER
  as select from zcit_driver
{
  key driver_id as DriverId,
  driver_name as DriverName,
  license_number as LicenseNumber, 
  phone_number as PhoneNumber,
  vehicle_number as VehicleNumber,
  
  // FIXED LINE: Pointing to the correct database column
  availability_status as AvailabilityStatus,

  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
