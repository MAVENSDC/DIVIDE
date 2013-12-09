;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    iuvs_record: in, required, type=structure
;       the single data record structure to hold IUVS KP data
;    instrument_array: in, required, type=intarr(13)
;       an array that signals which types of data have been requested, so that only those fields are included in the structures.
;


;-
pro MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instrument_array


  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; -------------------------- Create IUVS structure ----------------------------------- ;;
  
  iuvs_record_temp = create_struct(['orbit'],0L)

  if instrument_array[7] eq 1 then begin    ;INCLUDE IUVS PERIAPSE DATA STRUCTURE
    i1 = {periapse,time_start:'', time_stop:'', scale_height_id:strarr(7), scale_height:fltarr(7), scale_height_err:fltarr(7), $
          density_id:strarr(7), density:fltarr(7,31), density_err:fltarr(7,31), radiance_id:strarr(11), $
          radiance:fltarr(11,31), radiance_err:fltarr(11,31), temperature_id:'', temperature:0.0, temperature_err:0.0, sza:0.0,$
          local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, alt:fltarr(31), orbit_number:0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp1 = create_struct(['periapse'],[i1,i1,i1],iuvs_record_temp)
  endif else begin
    iuvs_record_temp1 = create_struct(iuvs_record_temp)
  endelse
  if instrument_array[8] eq 1 then begin    ;INCLUDE IUVS APOAPSE DATA STRUCTURE
    i2 = {apoapse, time_start:'', time_stop:'', ozone_depth:fltarr(90,45), ozone_depth_err:fltarr(90,45), auroral_index:fltarr(90,45), dust_depth:fltarr(90,45), $
          dust_depth_err:fltarr(90,45), radiance_id:strarr(4), radiance:fltarr(4,90,45), radiance_err:fltarr(4,90,45), sza_bp:fltarr(90,45), $
          local_time_bp:fltarr(90,45), lon_bins:fltarr(90), lat_bins:fltarr(45), sza:0.0,$
          local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, orbit_number:0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp2 = create_struct(['apoapse'],i2,iuvs_record_temp1)
  endif else begin
    iuvs_record_temp2 = create_struct(iuvs_record_temp1)
  endelse
  if instrument_array[9] eq 1 then begin    ;INCLUDE IUVS ECHELLE HIGH ALTITUDE CORONA DATA STRUCTURE
    i3 = {c_e_high, time_start:'', time_stop:'', half_int_distance_id:strarr(3), half_int_distance:fltarr(3), half_int_distance_err:fltarr(3), $
          radiance_id:strarr(3), radiance:fltarr(3,77), radiance_err:fltarr(3,77), sza:0.0, local_time:0.0, lat:0.0, lon:0.0, $
          lat_mso:0.0, lon_mso:0.0, alt:fltarr(77), orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), sun_mso:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp3 = create_struct(['corona_e_high'],i3,iuvs_record_temp2)
  endif else begin
    iuvs_record_temp3 = create_struct(iuvs_record_temp2)
  endelse
  if instrument_array[10] eq 1 then begin    ;INCLUDE IUVS ECHELLE LIMB CORONA DATA STRUCTURE
    i4 = {c_e_limb, time_start:'', time_stop:'', half_int_distance_id:strarr(3), half_int_distance:fltarr(3), half_int_distance_err:fltarr(3), $
          radiance_id:strarr(3), radiance:fltarr(3,31), radiance_err:fltarr(3,31), sza:0.0, local_time:0.0, lat:0.0, lon:0.0, $
          lat_mso:0.0, lon_mso:0.0, alt:fltarr(31), orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), sun_mso:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp4 = create_struct(['corona_e_limb'],i4,iuvs_record_temp3)
  endif else begin
    iuvs_record_temp4 = create_struct(iuvs_record_temp3)
  endelse
  if instrument_array[11] eq 1 then begin    ;INCLUDE IUVS STELLAR OCCULTATION DATA STRUCTURE
    i5 = {stellar, time_start:'', time_stop:'', test1:0.0}
    iuvs_record_temp5 = create_struct(['stellar_occ'],i5,iuvs_record_temp4)
  endif else begin
    iuvs_record_temp5 = create_struct(iuvs_record_temp4)
  endelse
  if instrument_array[12] eq 1 then begin     ;INCLUDE IUVS LO RES HIGH ALITUDE CORONA DATA STRUCTURE
    i6 = {c_l_high, time_start:'', time_stop:'', half_int_distance_id:strarr(6), half_int_distance:fltarr(6), half_int_distance_err:fltarr(6), $
          density_id:strarr(4), density:fltarr(4,77), density_err:fltarr(4,77), radiance_id:strarr(6), radiance:fltarr(6,77), radiance_err:fltarr(6,77), $
          sza:0.0, local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, alt:fltarr(77), orbit_number:0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp6 = create_struct(['corona_lo_high'],i6,iuvs_record_temp5)
  endif else begin
    iuvs_record_temp6 = create_struct(iuvs_record_temp5)
  endelse
  if instrument_array[13] eq 1 then begin     ;INCLUDE IUVS LO RES LIMB CORONA DATA STRUCTURE
    i7 = {c_l_limb, time_start:'', time_stop:'', scale_height_id:strarr(7), scale_height:fltarr(7), scale_height_err:fltarr(7), density_id:strarr(7), density:fltarr(7,31), $
          density_err:fltarr(7,31), radiance_id:strarr(11), radiance:fltarr(11,31), radiance_err:fltarr(11,31), temperature_id:'', temperature:0.0, temperature_err:0.0, $
          sza:0.0, local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, alt:fltarr(31), orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp7 = create_struct(['corona_lo_limb'],i7,iuvs_record_temp6)
  endif else begin
    iuvs_record_temp7 = create_struct(iuvs_record_temp6)
  endelse
  if instrument_array[14] eq 1 then begin     ;INCLUDE IUVS LO RES DISK CORONA DATA STRUCTURE
    i8 = {c_l_disk, time_start:'', time_stop:'', ozone_depth:0.0, ozone_depth_err:0.0, auroral_index:0.0, dust_depth:0.0, $
          dust_depth_err:0.0, radiance_id:strarr(4), radiance:fltarr(4), radiance_err:fltarr(4), sza:0.0, local_time:0.0, $
          lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, orbit_number:0L,  mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), sun_mso:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp8 = create_struct(['corona_lo_disk'],i8,iuvs_record_temp7)
  endif else begin
    iuvs_record_temp8 = create_struct(iuvs_record_temp7)
  endelse
  if instrument_array[15] eq 1 then begin     ;INCLUDE IUVS ECHELLE LIMB CORONA DATA STRUCTURE
    i9 = {c_e_disk, time_start:'', time_stop:'', radiance_id:strarr(3), radiance:fltarr(3), radiance_err:fltarr(3), sza:0.0,$
          local_time:0.0, lat:0.0, lon:0.0, lat_mso:0.0, lon_mso:0.0, orbit_number: 0L, mars_season_ls:0.0, spacecraft_geo:dblarr(3),$
          spacecraft_mso:dblarr(3), sun_geo:dblarr(3), spacecraft_geo_longitude:0.0,$
          spacecraft_geo_latitude:0.0, spacecraft_mso_longitude:0.0, spacecraft_mso_latitude:0.0,$
          subsolar_point_geo_longitude:0.0, subsolar_point_geo_latitude:0.0, spacecraft_sza:0.0, spacecraft_local_time:0.0, spacecraft_altitude:0.0,$
          mars_sun_distance:0.0}
    iuvs_record_temp9 = create_struct(['corona_e_disk'],i9,iuvs_record_temp8)
  endif else begin
    iuvs_record_temp9 = create_struct(iuvs_record_temp8)
  endelse
  
  iuvs_record = 0
  iuvs_record = create_struct(iuvs_record_temp9)

end