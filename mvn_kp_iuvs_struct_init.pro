;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    iuvs_record: in, required, type=structure
;       the single data record structure to hold IUVS KP data
;    instruments: in, optional, type=struct
;      a struct that signals which types of data have been requested, so that only those fields are included in the structures.
;


;-
pro MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instruments=instruments


  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  ; IF NOT IN DEBUG MODE, SET ACTION TAKEN ON ERROR TO BE
  ; PRINT THE CURRENT PROGRAM STACK, RETURN TO THE MAIN PROGRAM LEVEL AND STOP
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  
  ;; Default to filling all instruments if not specified
  if not keyword_set(instruments) then begin
    instruments = CREATE_STRUCT('lpw',      1, 'static',   1, 'swia',     1, $
                                'swea',     1, 'mag',      1, 'sep',      1, $
                                'ngims',    1, 'periapse', 1, 'c_e_disk', 1, $
                                'c_e_limb', 1, 'c_e_high', 1, 'c_l_disk', 1, $
                                'c_l_limb', 1, 'c_l_high', 1, 'apoapse' , 1, 'stellarocc', 1)
  endif
  
  ;; ------------------------------------------------------------------------------------ ;;
  ;; -------------------------- Create IUVS structure ----------------------------------- ;;
  

  ;CREATE THE STRUCT CONTAINING THE COMMON PORTION OF ALL IUVS OBSERVATIONS
  iuvs_record_common = create_struct(             $
    'time_start'                   ,'',           $
    'time_stop'                    ,'',           $
    'sza'                          ,0.0,          $
    'local_time'                   ,0.0,          $
    'lat'                          ,0.0,          $
    'lon'                          ,0.0,          $
    'lat_mso'                      ,0.0,          $
    'lon_mso'                      ,0.0,          $
    'orbit_number'                 ,0L,           $
    'mars_season_ls'               ,0.0,          $
    'spacecraft_geo'               ,dblarr(3),    $
    'spacecraft_mso'               ,dblarr(3),    $
    'sun_geo'                      ,dblarr(3),    $
    'spacecraft_geo_longitude'     ,0.0,          $
    'spacecraft_geo_latitude'      ,0.0,          $
    'spacecraft_mso_longitude'     ,0.0,          $
    'spacecraft_mso_latitude'      ,0.0,          $
    'subsolar_point_geo_longitude' ,0.0,          $
    'subsolar_point_geo_latitude'  ,0.0,          $
    'spacecraft_sza'               ,0.0,          $
    'spacecraft_local_time'        ,0.0,          $
    'spacecraft_altitude'          ,0.0,          $
    'mars_sun_distance'            ,0.0)
    
  iuvs_record_temp = create_struct(['orbit'],0L)


  ;INCLUDE IUVS STELLAR OCCULTATION DATA STRUCTURE
  if instruments.stellarocc then begin
    i5 = {stellar, test1:0.0}
    
    iuvs_record_temp1 = create_struct(['stellar_occ'],i5,iuvs_record_temp)
  endif else  iuvs_record_temp1 = create_struct(iuvs_record_temp)


  ;INCLUDE IUVS APOAPSE DATA STRUCTURE
  if instruments.apoapse then begin
    i2 = create_struct(                        $
      NAME               ='apoapse',       $
      iuvs_record_common ,                 $
      'ozone_depth'      ,fltarr(90,45),   $
      'ozone_depth_err'  ,fltarr(90,45),   $
      'auroral_index'    ,fltarr(90,45),   $
      'dust_depth'       ,fltarr(90,45),   $
      'dust_depth_err'   ,fltarr(90,45),   $
      'radiance_id'      ,strarr(4),       $
      'radiance'         ,fltarr(4,90,45), $
      'radiance_err'     ,fltarr(4,90,45), $
      'sza_bp'           ,fltarr(90,45),   $
      'local_time_bp'    ,fltarr(90,45),   $
      'lon_bins'         ,fltarr(90),      $
      'lat_bins'         ,fltarr(45))
      
    iuvs_record_temp2 = create_struct(['apoapse'],i2,iuvs_record_temp1)
  endif else  iuvs_record_temp2 = create_struct(iuvs_record_temp1)

  
  ;INCLUDE IUVS LO RES HIGH ALITUDE CORONA DATA STRUCTURE
  if instruments.c_l_high then begin
    i6 = create_struct(                          $
      NAME                    ='c_l_high',   $
      iuvs_record_common      ,              $
      'half_int_distance_id'  ,strarr(6),    $
      'half_int_distance'     ,fltarr(6),    $
      'half_int_distance_err' ,fltarr(6),    $
      'density_id'            ,strarr(4),    $
      'density'               ,fltarr(4,77), $
      'density_err'           ,fltarr(4,77), $
      'radiance_id'           ,strarr(6),    $
      'radiance'              ,fltarr(6,77), $
      'radiance_err'          ,fltarr(6,77), $
      'alt'                   ,fltarr(77))
      
    iuvs_record_temp3 = create_struct(['corona_lo_high'],i6,iuvs_record_temp2)
  endif else  iuvs_record_temp3 = create_struct(iuvs_record_temp2)

 
  ;INCLUDE IUVS LO RES LIMB CORONA DATA STRUCTURE
  if instruments.c_l_limb then begin
    i7 = create_struct(                       $
      NAME               ='c_l_limb',     $
      iuvs_record_common ,                $
      'scale_height_id'  ,strarr(7),      $
      'scale_height'     ,fltarr(7),      $
      'scale_height_err' ,fltarr(7),      $
      'density_id'       ,strarr(7),      $
      'density'          ,fltarr(7,31),   $
      'density_err'      ,fltarr(7,31),   $
      'radiance_id'      ,strarr(11),     $
      'radiance'         ,fltarr(11,31),  $
      'radiance_err'     ,fltarr(11,31),  $
      'temperature_id'   ,'',             $
      'temperature'      ,0.0,            $
      'temperature_err'  ,0.0,            $
      'alt'              ,fltarr(31))
      
    iuvs_record_temp4 = create_struct(['corona_lo_limb'],i7,iuvs_record_temp3)
  endif else  iuvs_record_temp4 = create_struct(iuvs_record_temp3)

  
  ;INCLUDE IUVS LO RES DISK CORONA DATA STRUCTURE
  if instruments.c_l_disk then begin
    i8 = create_struct(                    $
      NAME               ='c_l_disk',  $
      iuvs_record_common ,             $
      'ozone_depth'      ,0.0,         $
      'ozone_depth_err'  ,0.0,         $
      'auroral_index'    ,0.0,         $
      'dust_depth'       ,0.0,         $
      'dust_depth_err'   ,0.0,         $
      'radiance_id'      ,strarr(4),   $
      'radiance'         ,fltarr(4),   $
      'radiance_err'     ,fltarr(4))
      
    iuvs_record_temp5 = create_struct(['corona_lo_disk'],i8,iuvs_record_temp4)
  endif else  iuvs_record_temp5 = create_struct(iuvs_record_temp4)

  
  ;INCLUDE IUVS ECHELLE HIGH ALTITUDE CORONA DATA STRUCTURE 
  if instruments.c_e_high then begin    
    i3 = create_struct(                           $
          NAME                     ='c_e_high',   $
          iuvs_record_common ,                    $
          'half_int_distance_id'   ,strarr(3),    $ 
          'half_int_distance'      ,fltarr(3),    $ 
          'half_int_distance_err'  ,fltarr(3),    $
          'radiance_id'            ,strarr(3),    $ 
          'radiance'               ,fltarr(3,77), $ 
          'radiance_err'           ,fltarr(3,77), $ 
          'alt'                    ,fltarr(77))
    
             iuvs_record_temp6 = create_struct(['corona_e_high'],i3,iuvs_record_temp5)
  endif else iuvs_record_temp6 = create_struct(iuvs_record_temp5)

  
  ;INCLUDE IUVS ECHELLE LIMB CORONA DATA STRUCTURE
  if instruments.c_e_limb then begin
    i4 = create_struct(                           $
      NAME                     ='c_e_limb',   $
      iuvs_record_common ,                    $
      'half_int_distance_id'   ,strarr(3),    $
      'half_int_distance'      ,fltarr(3),    $
      'half_int_distance_err'  ,fltarr(3),    $
      'radiance_id'            ,strarr(3),    $
      'radiance'               ,fltarr(3,31), $
      'radiance_err'           ,fltarr(3,31), $
      'alt'                    ,fltarr(31))
      
    iuvs_record_temp7 = create_struct(['corona_e_limb'],i4,iuvs_record_temp6)
  endif else  iuvs_record_temp7 = create_struct(iuvs_record_temp6)
  
  
  ;INCLUDE IUVS ECHELLE DISK CORONA DATA STRUCTURE
  if instruments.c_e_disk then begin
    i9 = create_struct(                 $
      NAME            ='c_e_disk',  $
      iuvs_record_common ,          $
      'radiance_id'   ,strarr(3),   $
      'radiance'      ,fltarr(3),   $
      'radiance_err'  ,fltarr(3))
      
    iuvs_record_temp8 = create_struct(['corona_e_disk'],i9,iuvs_record_temp7)
  endif else  iuvs_record_temp8 = create_struct(iuvs_record_temp7)

  
  ;INCLUDE IUVS PERIAPSE DATA STRUCTURE
  if instruments.periapse then begin
    i1 = create_struct(                          $
      NAME                ='periapse',       $
      iuvs_record_common,                    $
      'scale_height_id'   ,strarr(7),        $
      'scale_height'      ,fltarr(7),        $
      'scale_height_err'  ,fltarr(7),        $
      'density_id'        ,strarr(7),        $
      'density'           ,fltarr(7,31),     $
      'density_err'       ,fltarr(7,31),     $
      'radiance_id'       ,strarr(11),       $
      'radiance'          ,fltarr(11,31),    $
      'radiance_err'      ,fltarr(11,31),    $
      'temperature_id'    ,'',               $
      'temperature'       ,0.0,              $
      'temperature_err'   ,0.0,              $
      'alt'               ,fltarr(31))
      
    iuvs_record_temp9 = create_struct(['periapse'],[i1,i1,i1],iuvs_record_temp8)
  endif else  iuvs_record_temp9 = create_struct(iuvs_record_temp8)

  
  ;COPY TO OUTPUT STRUCTURE
  iuvs_record = 0
  iuvs_record = create_struct(iuvs_record_temp9)
  iuvs_common = iuvs_record_common

end