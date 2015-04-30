;+
; HERE RESTS THE ONE SENTENCE ROUTINE DESCRIPTION
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds 
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;-
pro MVN_KP_MAP2D_IUVS_PLOT, iuvs, flag, mso, lat, lon, colors, $
                            iuvs_color_table, colorbar, data_exist, $
                            minimum, maximum

  if flag eq 'PERIAPSE' then begin
        temperature = fltarr(n_elements(iuvs.periapse.temperature))
        lat = fltarr(n_elements(iuvs.periapse.lat))
        lon = fltarr(n_elements(iuvs.periapse.lon))
        t_ind=0
        for i=0,n_elements(iuvs)-1 do begin
          for j=0,n_elements(iuvs[i].periapse)-1 do begin
            if iuvs[i].periapse[j].temperature ne 0.0 then begin
              temperature[t_ind] = iuvs[i].periapse[j].temperature
              if mso eq 1 then begin
                lat[t_ind] = iuvs[i].periapse[j].lat_mso
                lon[t_ind] = iuvs[i].periapse[j].lon_mso
              endif else begin
                lat[t_ind] = iuvs[i].periapse[j].lat
                lon[t_ind] = iuvs[i].periapse[j].lon
              endelse
              t_ind++
            endif
          endfor
        endfor
        if t_ind gt 0 then begin
          temperature = temperature[0:t_ind-1]
          lat = lat[0:t_ind-1]
          lon = lon[0:t_ind-1]
          colors = intarr(3,n_elements(temperature))
          MVN_KP_MAP2D_SYMBOL_FILL, temperature, colors, iuvs_color_table, $
                                    colorbar
          minimum = min(temperature,/NaN)
          maximum = max(temperature,/NaN)
          data_exist = 1
        endif else begin
          data_exist = 0
        endelse
  endif else begin
    MVN_KP_TAG_PARSER, iuvs, iuvs_base_tag_count, iuvs_first_level_count, $
                       iuvs_second_level_count, iuvs_base_tags,  $
                       iuvs_first_level_tags, iuvs_second_level_tags
    case flag of
      'CORONA_LO_OZONE': begin
                            level1 = 'CORONA_LO_DISK'
                            level2 = 'OZONE_DEPTH'
                            level3 = ''
                         end
      'CORONA_LO_DUST': begin
                          level1 = 'CORONA_LO_DISK'
                            level2 = 'DUST_DEPTH'
                            level3 = ''
                         end
      'CORONA_LO_AURORA': begin
                            level1 = 'CORONA_LO_DISK'
                            level2 = 'AURORAL_INDEX'
                            level3 = ''
                         end
      'CORONA_LO_H_RAD': begin
                            level1 = 'CORONA_LO_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'H'
                         end                   
      'CORONA_LO_CO_RAD': begin
                            level1 = 'CORONA_LO_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'CO'
                         end                   
      'CORONA_LO_NO_RAD': begin
                            level1 = 'CORONA_LO_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'NO'
                         end                   
      'CORONA_LO_O_RAD': begin
                          level1 = 'CORONA_LO_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'O_1304'
                         end                   
      'CORONA_E_H_RAD': begin
                          level1 = 'CORONA_E_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'H'
                         end
      'CORONA_E_D_RAD': begin
                          level1 = 'CORONA_E_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'D'
                         eND  
      'CORONA_E_O_RAD': begin
                          level1 = 'CORONA_E_DISK'
                            level2 = 'RADIANCE'
                            level3 = 'O_1304'
                         end                                    
    endcase 
      check = where(iuvs_base_tags eq level1)
      if check eq -1 then begin
        print,'The IUVS data structure is missing the requested data'
        return
      endif
      check1 = where(iuvs_first_level_tags[total(iuvs_first_level_count[0:check-1]):total(iuvs_first_level_count[0:check])] eq level2)
      if check1 eq -1 then begin
        print,'The IUVS data structure is missing the needed data.'
        return
      endif
        temperature = fltarr(n_elements(iuvs.(check).(check1)))
        lat = fltarr(n_elements(iuvs.(check).lat))
        lon = fltarr(n_elements(iuvs.(check).lon))
        t_ind=0
        for i=0,n_elements(iuvs)-1 do begin
          if level3 eq '' then begin
            if iuvs[i].(check).(check1) ne 0.0 then begin
              temperature[t_ind] = iuvs[i].(check).(check1)
              if mso eq 1 then begin
                lat[t_ind] = iuvs[i].(check).lat_mso
                lon[t_ind] = iuvs[i].(check).lon_mso
              endif else begin
                lat[t_ind] = iuvs[i].(check).lat
                lon[t_ind] = iuvs[i].(check).lon
              endelse
              t_ind++
            endif
          endif else begin      ;RADIANCE DATA EXTRACTION
            if level1 eq 'CORONA_E_DISK' then begin
              case level3 of 
                'H': id = 0
                'D': id = 1
                'O_1304': id = 2
              endcase
            endif
            if level1 eq 'CORONA_LO_DISK' then begin
              case level3 of 
                'H': id = 0
                'O_1304': id = 1
                'CO': id = 2
                'NO': id =3
              endcase
            endif
           if iuvs[i].(check).(check1)[id] ne 0.0 then begin
            temperature[t_ind] = iuvs[i].(check).(check1)[id]
              if mso eq 1 then begin
                lat[t_ind] = iuvs[i].(check).lat_mso
                lon[t_ind] = iuvs[i].(check).lon_mso
              endif else begin
                lat[t_ind] = iuvs[i].(check).lat
                lon[t_ind] = iuvs[i].(check).lon
              endelse
              t_ind++
           endif
          endelse 
        endfor
        if t_ind gt 0 then begin
          temperature = temperature[0:t_ind-1]
          lat = lat[0:t_ind-1]
          lon = lon[0:t_ind-1]
          colors = intarr(3,n_elements(temperature))
          MVN_KP_MAP2D_SYMBOL_FILL, temperature, colors, $
                                    iuvs_color_table, colorbar
          minimum = min(temperature,/NaN)
          maximum = max(temperature,/NaN)
          data_exist = 1 
        endif else begin
          data_exist = 0
        endelse 
    
  endelse 
END
