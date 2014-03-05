;; Read over blank lines, return once hit not blank line
function mvn_kp_iuvs_ascii_read_blanks, lun
  while not eof(lun) do begin
    temp = ''
    readf, lun, temp
    line = strsplit(temp, ' ', /EXTRACT)
    if strlen(line[0]) gt 0 then break
  endwhile

  ;; Return split line read in that is not emtpy
  return, line
end


pro mvn_kp_iuvs_ascii_common, lun, in_struct
  
  ;; read in from config info about iuvs data
  iuvs_data_spec = mvn_kp_config(/iuvs_data)
  num_common = iuvs_data_spec.num_common
 
 ;; Read in until we hit 'TIME_START'
  while not eof(lun) do begin
    temp=''
    readf, lun, temp
    line = strsplit(temp, ' ', /extract)
    
    if line[0] eq 'TIME_START' then begin
      ;; We've reached the common block, break out and handle all variables in next for block.
      break      
    endif
  endwhile
   
  ;; Add TIME_START and TIME_STOP as strings
  in_struct.(0) = string(line[2])
  readf, lun, temp
  line = strsplit(temp, ' ', /EXTRACT)
  in_struct.(1) = string(line[2])
  
  
  for i=2, num_common-1 do begin
     temp = ''
     readf, lun, temp
     line = strsplit(temp, ' ', /extract)
     
     ;; These are arrays of 3 values split but commas & white space
     if (line[0] eq 'SC_GEO') or (line[0] eq 'SC_MSO') or (line[0] eq 'SUN_GEO') then begin
      
      ;; Remove commas from first two & convert to double
      val1 = strsplit(line[2], ',', /EXTRACT)
      val2 = strsplit(line[3], ',', /EXTRACT)
      val3 = line[4]
      
      in_struct.(i) = [double(val1), double(val2), double(val3)]
      
     endif else begin

      ;; Float scalars, fill in as such
      in_struct.(i) = float(line[2])      
     endelse
     
  endfor
  
  return
end

pro mvn_kp_read_iuvs_ascii_periapse, lun, in_struct
  ;; Assume next line with data will contain a single specicies and temperature
  temp = ''
 
  ;; Temperature_id, temperature, and temperature_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)
  in_struct.temperature_id = string(line[0])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)
  in_struct.temperature = float(line[1])
  readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
  in_struct.temperature_err = float(line[1])
    

  ;; Scale Height ID, Scale Height, and Scale Height Err
  line =   mvn_kp_iuvs_ascii_read_blanks(lun)
  in_struct.scale_height_id = line
  readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
  in_struct.scale_height = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
  in_struct.scale_height_err = float(line[1:*])
  
  ;; Density_ID, Density, Altitude
  line = mvn_kp_iuvs_ascii_read_blanks(lun)
  readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
  in_struct.density_id  = string(line[1:*])
  num_dens = (size(in_struct.density, /DIMENSIONS))[1]
  for i=0, num_dens-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.alt[i] = float(line[0])
    in_struct.density[*, i] = float(line[1:*])
  endfor

  ;; Density Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)
  readf, lun, temp
  num_dens = (size(in_struct.density_err, /DIMENSIONS))[1]
  for i=0, num_dens-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.density_err[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance, Radiance_ID
  line = mvn_kp_iuvs_ascii_read_blanks(lun)
  readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
  in_struct.radiance_id  = string(line[1:*])
  num_rads = (size(in_struct.radiance, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)
  readf, lun, temp
  num_rads = (size(in_struct.radiance, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.alt[i] = float(line[0])
    in_struct.radiance_err[*, i] = float(line[1:*])
  endfor

end

pro mvn_kp_read_iuvs_ascii_c_l_disk, lun, in_struct
  temp = ''

  ;; Ozone_depth, Ozone_depth_err  
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'OZONE_DEPTH') then message, "Cannot parse IUVS ascii"
  in_struct.ozone_depth     = float(line[2])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT) 
  in_struct.ozone_depth_err = float(line[2])
  
  ;; Auroral_index, Dust_depth, Dust_depth_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'AURORAL_INDEX') then message, "Cannot parse IUVS ascii"
  in_struct.auroral_index  = float(line[2])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & if (line[0] ne 'DUST_DEPTH') then message, "Cannot parse IUVS ascii"
  in_struct.dust_depth     = float(line[2])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)
  in_struct.dust_depth_err = float(line[2])

  ;; Radiance_ID, Radiance & Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.radiance_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance_err = float(line[1:*])

  return
end

pro mvn_kp_read_iuvs_ascii_c_l_limb, lun, in_struct
  temp = ''
 
  ;; Temperature_ID, Temperature, Temperature_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.temperature_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.temperature     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.temperature_err = float(line[1:*])
  
  ;; Scale_height_id, Scale_height, Scale_height_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.scale_height_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.scale_height     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.scale_height_err = float(line[1:*])
  
  ;; Density
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'DENSITY') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.density_id       = string(line[1:*])
  num_dens = (size(in_struct.density, /DIMENSIONS))[1]
  for i=0, num_dens-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.alt[i] = float(line[0])
    in_struct.density[*, i] = float(line[1:*])
  endfor
  
  ;; Density Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'DENSITY_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_dens = (size(in_struct.density_err, /DIMENSIONS))[1]
  for i=0, num_dens-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.density_err[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance_id   = string(line[1:*])
  num_rads = (size(in_struct.radiance, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_rads = (size(in_struct.radiance_err, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance_err[*, i] = float(line[1:*])
  endfor
  
  return
end

pro mvn_kp_read_iuvs_ascii_c_l_high, lun, in_struct
  temp = ''
  
  ;; Half_int_distance_id, Half_int_distance, & Half_int_distance_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.half_int_distance_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.half_int_distance     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.half_int_distance_err = float(line[1:*])
  
  ;; Density_id, Density, alt
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'DENSITY') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.density_id       = string(line[1:*])
  num_dens = (size(in_struct.density, /DIMENSIONS))[1]
  for i=0, num_dens-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.alt[i] = float(line[0])
    in_struct.density[*, i] = float(line[1:*])
  endfor
  
  ;; Density Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'DENSITY_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_dens = (size(in_struct.density_err, /DIMENSIONS))[1]
  for i=0, num_dens-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.density_err[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance, radiance_id
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance_id   = string(line[1:*])
  num_rads = (size(in_struct.radiance, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_rads = (size(in_struct.radiance_err, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance_err[*, i] = float(line[1:*])
  endfor
  
  return
end


pro mvn_kp_read_iuvs_ascii_c_e_disk, lun, in_struct
  temp = ''
  
  ;; Radiance_ID, Radiance & Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.radiance_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance_err = float(line[1:*])
  
  return
end

pro mvn_kp_read_iuvs_ascii_c_e_limb, lun, in_struct
  temp = ''
 
  ;; Half_int_distance_id, Half_int_distance, & Half_int_distance_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.half_int_distance_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.half_int_distance     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.half_int_distance_err = float(line[1:*])
  
  ;; Radiance
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance_id   = string(line[1:*])
  num_rads = (size(in_struct.radiance, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.alt[i] = float(line[0])
    in_struct.radiance[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_rads = (size(in_struct.radiance_err, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance_err[*, i] = float(line[1:*])
  endfor
  
  return
end

pro mvn_kp_read_iuvs_ascii_c_e_high, lun, in_struct
  temp = ''
  
   ;; Half_int_distance_id, Half_int_distance, & Half_int_distance_err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & in_struct.half_int_distance_id  = string(line)
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.half_int_distance     = float(line[1:*])
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.half_int_distance_err = float(line[1:*])
  
  ;; Radiance
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.radiance_id   = string(line[1:*])
  num_rads = (size(in_struct.radiance, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.alt[i] = float(line[0])
    in_struct.radiance[*, i] = float(line[1:*])
  endfor
  
  ;; Radiance Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'RADIANCE_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_rads = (size(in_struct.radiance_err, /DIMENSIONS))[1]
  for i=0, num_rads-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.radiance_err[*, i] = float(line[1:*])
  endfor
  
  return
end


pro mvn_kp_read_iuvs_ascii_apoapse, lun, in_struct
  temp = ''
  
  ;; Solar Zenith Angle Backplane
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'SOLAR_ZENITH_ANGLE_BACKPLANE') then message, "Cannot parse IUVS ascii"
  readf, lun, temp & line = strsplit(temp, ' ',/EXTRACT)  & in_struct.lon_bins  = string(line)
  num_sza_bps = (size(in_struct.sza_bp, /DIMENSIONS))[1]
  for i=0, num_sza_bps-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.lat_bins[i]  = float(line[0])
    in_struct.sza_bp[*, i] = float(line[1:*])
  endfor
  
  ;; Local Time Backplane
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'LOCAL_TIME_BACKPLANE') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_ltimes = (size(in_struct.local_time_bp, /DIMENSIONS))[1]
  for i=0, num_ltimes-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.local_time_bp[*, i] = float(line[1:*])
  endfor

  ;; Ozone Depth
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'OZONE_DEPTH') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_odepths = (size(in_struct.ozone_depth, /DIMENSIONS))[1]
  for i=0, num_odepths-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.ozone_depth[*, i] = float(line[1:*])
  endfor
  
  ;; Ozone Depth Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'OZONE_DEPTH_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_odepth_errs = (size(in_struct.ozone_depth_err, /DIMENSIONS))[1]
  for i=0, num_odepth_errs-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.ozone_depth_err[*, i] = float(line[1:*])
  endfor
  
  ;; Auroral Index
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'AURORAL_INDEX') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_aurorals = (size(in_struct.auroral_index, /DIMENSIONS))[1]
  for i=0, num_aurorals-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.auroral_index[*, i] = float(line[1:*])
  endfor
  
  ;; Dust Depth
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'DUST_DEPTH') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_dusts = (size(in_struct.dust_depth, /DIMENSIONS))[1]
  for i=0, num_dusts-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.dust_depth[*, i] = float(line[1:*])
  endfor
  
  ;; Dust Depth Err
  line = mvn_kp_iuvs_ascii_read_blanks(lun)               & if (line[0] ne 'DUST_DEPTH_ERR') then message, "Cannot parse IUVS ascii"
  readf, lun, temp
  num_dust_errs = (size(in_struct.dust_depth_err, /DIMENSIONS))[1]
  for i=0, num_dust_errs-1 do begin
    readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
    in_struct.dust_depth_err[*, i] = float(line[1:*])
  endfor  
  

  ;; Radiance_id, radiance & Radiance Err
  for j=0, n_elements(in_struct.radiance_id)-1 do begin
    line = mvn_kp_iuvs_ascii_read_blanks(lun)
    line2 = strsplit(line, '_', /EXTRACT)                   & if (line2[0] ne 'RADIANCE') then message, "Cannot parse IUVS ascii"
    rad_trim = stregex(line, '\_.*$', /EXTRACT)
    rad_id   = strmid(rad_trim, 1)
    in_struct.radiance_id[j] = rad_id
    readf, lun, temp
    num_rads = (size(in_struct.lat_bins, /DIMENSIONS))[0]
    for i=0, num_rads-1 do begin
      readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
      in_struct.radiance[j, *, i] = float(line[1:*])
    endfor
    
    line = mvn_kp_iuvs_ascii_read_blanks(lun)
    readf, lun, temp
    num_rads = (size(in_struct.lat_bins, /DIMENSIONS))[0]
    for i=0, num_rads-1 do begin
      readf, lun, temp & line = strsplit(temp, ' ', /EXTRACT)
      in_struct.radiance_err[j, *, i] = float(line[1:*])
    endfor
    
  endfor
  
  return
end



;;
;;
;; Main procedure - Read in one iuvs ascii file
;;
;;
;;
;;
pro mvn_kp_read_iuvs_ascii, filename, iuvs_record
  
  
  ;; Init struct with all instruments
  instrument_array = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]  
  MVN_KP_IUVS_STRUCT_INIT, iuvs_record, instrument_array
 
  ;; Set for collecting orbit number later
  orbit_number = -1
  
  ;; Open file for reading
  openr, lun, filename, /get_lun
  
  ;; Read in each line
  periapse_i = 0
  while not eof(lun) do begin
    temp = ''
    readf, lun, temp
    line = strsplit(temp, ' ', /extract)
    
    if(line[0] eq 'OBSERVATION_MODE') then begin
      
      ;; ======== If periapse mode ====================
      if(line[2] eq 'PERIAPSE') then begin
        temp_periapse = iuvs_record.periapse[periapse_i]
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_periapse
        
        ;; Read in Periapse specific values
        mvn_kp_read_iuvs_ascii_periapse, lun, temp_periapse
                
        iuvs_record.periapse[periapse_i] = temp_periapse
        periapse_i++
        orbit_number = iuvs_record.periapse[0].orbit_number
        continue
      endif
      
      ;; ======== If corona lores disk mode ===========
      if(line[2] eq 'CORONA_LORES_DISK') then begin
        temp_c_l_disk = iuvs_record.corona_lo_disk
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_c_l_disk
        
        ;; Read in c_l_disk specific values
        mvn_kp_read_iuvs_ascii_c_l_disk, lun, temp_c_l_disk
        
        iuvs_record.corona_lo_disk = temp_c_l_disk
        orbit_number = temp_c_l_disk.orbit_number
        continue
      endif
      
      ;; ======== If corona lores limb mode ===========
      if(line[2] eq 'CORONA_LORES_LIMB') then begin
        temp_c_l_limb = iuvs_record.corona_lo_limb
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_c_l_limb
        
        ;; Read in c_l_limb specific values
        mvn_kp_read_iuvs_ascii_c_l_limb, lun, temp_c_l_limb
        
        iuvs_record.corona_lo_limb = temp_c_l_limb
        orbit_number = temp_c_l_limb.orbit_number
        continue
      endif
      
      ;; ======== If corona lores high mode ===========
      if(line[2] eq 'CORONA_LORES_HIGH') then begin
        temp_c_l_high = iuvs_record.corona_lo_high
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_c_l_high
        
        ;; Read in c_l_high specific values
        mvn_kp_read_iuvs_ascii_c_l_high, lun, temp_c_l_high
        
        iuvs_record.corona_lo_high = temp_c_l_high
        orbit_number = temp_c_l_high.orbit_number
        continue
      endif
      
      ;; ======== If corona echelle disk mode ===========
      if(line[2] eq 'CORONA_ECHELLE_DISK') then begin
        temp_c_e_disk = iuvs_record.corona_e_disk
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_c_e_disk
        
        ;; Read in c_e_disk specific values
        mvn_kp_read_iuvs_ascii_c_e_disk, lun, temp_c_e_disk
        
        iuvs_record.corona_e_disk = temp_c_e_disk
        orbit_number = temp_c_e_disk.orbit_number
        continue
      endif
      
      ;; ======== If conona echelle limb mode ===========
      if(line[2] eq 'CORONA_ECHELLE_LIMB') then begin
        temp_c_e_limb = iuvs_record.corona_e_limb
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_c_e_limb
        
        ;; Read in c_e_limb specific values
        mvn_kp_read_iuvs_ascii_c_e_limb, lun, temp_c_e_limb
        
        iuvs_record.corona_e_limb = temp_c_e_limb
        orbit_number = temp_c_e_limb.orbit_number
        continue
      endif
      
      ;; ======== If corona echelle high mode ===========
      if(line[2] eq 'CORONA_ECHELLE_HIGH') then begin
        temp_c_e_high = iuvs_record.corona_e_high
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_c_e_high
        
        ;; Read in c_e_high specific values
        mvn_kp_read_iuvs_ascii_c_e_high, lun, temp_c_e_high
        
        iuvs_record.corona_e_high = temp_c_e_high
        orbit_number = temp_c_e_high.orbit_number
        continue
      endif
      
      
      ;; ======== If apoapse mode =====================
      if(line[2] eq 'APOAPSE') then begin
        temp_apoapse = iuvs_record.apoapse
        
        ;; Read in common values
        mvn_kp_iuvs_ascii_common, lun, temp_apoapse
        
        ;; Read in apoapse specific values
        mvn_kp_read_iuvs_ascii_apoapse, lun, temp_apoapse
        
        iuvs_record.apoapse = temp_apoapse
        orbit_number = temp_apoapse.orbit_number
        continue
      endif
      
    endif

  endwhile

  ;; Add in orbit number
  iuvs_record.orbit = orbit_number

  ;; Close file, releasing lun
  free_lun, lun


  return
end