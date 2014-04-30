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
pro MVN_KP_IUVS_CORONA, kp_data, echelle=echelle, lores=lores, disk=disk, limb=limb, high=high, $
                        radiance=radiance, halfint=halfint, density=density, scaleheight=scaleheight, aurora=aurora, dust=dust, ozone=ozone, $
                        species_expand=species_expand, profile_expand=profile_expand, $
                        list=list, range=range, legend=legend, colortable=colortable, window=window, nolabels=nolabels, nolegend=nolegend


;CHECK THAT THE INPUT DATA STRUCTURE CONTAINS THE NECESSARY DATA
  base_tags = tag_names(kp_data)
  error = 0
  data_choice = intarr(6)
  disp_check = intarr(6)
  ;CHECK WHICH DATA THE INPUT STRUCTURE CONTAINS
    check = where(base_tags eq 'CORONA_E_DISK')
    if check ne -1 then data_choice[0] = 1
    check = where(base_tags eq 'CORONA_E_LIMB')
    if check ne -1 then data_choice[1] = 1
    check = where(base_tags eq 'CORONA_E_HIGH')
    if check ne -1 then data_choice[2] = 1
    check = where(base_tags eq 'CORONA_LO_DISK')
    if check ne -1 then data_choice[3] = 1
    check = where(base_tags eq 'CORONA_LO_LIMB')
    if check ne -1 then data_choice[4] = 1
    check = where(base_tags eq 'CORONA_LO_HIGH')
    if check ne -1 then data_choice[5] = 1
  ;SET CHOICES BASED ON KEYWORDS
    disp_check = data_choice
    if (keyword_set(echelle) and keyword_set(lores)) then begin
        if keyword_set(disk) or keyword_set(limb) or keyword_set(high) then begin
          disp_check[0:5] = 0
          if keyword_set(disk) then begin
            disp_check[0] = 1  
            disp_check[3] = 1
          endif
          if keyword_set(limb) then begin
            disp_check[1] = 1 
            disp_check[4] = 1
          endif
          if keyword_set(high) then begin
            disp_check[2] = 1 
            disp_check[5] = 1
          endif
        endif
    endif else begin
      if keyword_set(echelle) then begin
        disp_check[3:5] = 0
        if keyword_set(disk) or keyword_set(limb) or keyword_set(high) then begin
          disp_check[0:2] = 0
          if keyword_set(disk) then disp_check[0] = 1
          if keyword_set(limb) then disp_check[1] = 1
          if keyword_set(high) then disp_check[2] = 1
        endif
      endif
      
      if keyword_set(lores) then begin
        disp_check[0:2] = 0
        if keyword_set(disk) or keyword_set(limb) or keyword_set(high) then begin
          disp_check[3:5] = 0
          if keyword_set(disk) then disp_check[3] = 1
          if keyword_set(limb) then disp_check[4] = 1
          if keyword_set(high) then disp_check[5] = 1
        endif       
      endif
    endelse 

  if (keyword_set(echelle) eq 0) and (keyword_set(lores) eq 0) then begin
    if keyword_set(disk) or keyword_set(limb) or keyword_set(high) then begin
          disp_check[0:5] = 0
          if keyword_set(disk) then begin
            disp_check[0] = 1  
            disp_check[3] = 1
          endif
          if keyword_set(limb) then begin
            disp_check[1] = 1 
            disp_check[4] = 1
          endif
          if keyword_set(high) then begin
            disp_check[2] = 1 
            disp_check[5] = 1
          endif
    endif
  endif


  if error eq 1 then begin
    print,'The data structure does not include the necessary data. Check your structure and try again.'
    goto, kill
  endif
   
  
;SET DEFAULT COLORS
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    if keyword_set(colortable) then begin
      loadct,colortable
    endif else begin
      loadct,39,/silent
    endelse
    
;SET WINDOW NUMBERS
    if keyword_set(window) then begin
      plot_window = !window + 1
      legend_window = plot_window + 1
    endif else begin
      plot_window = 1
      legend_window = 2
    endelse
    
;CHECK DATE RANGES
    if keyword_set(range) then begin
      print,'The data structure contains data that spans the time range of '+strtrim(string(kp_data[0].periapse[0].time_start),2)+' to '+$
          strtrim(string(kp_data[n_elements(kp_data)-1].periapse[2].time_stop),2)
      print,'Equivalently, this includes the orbits of '+strtrim(string(kp_data[0].orbit),2)+' to '+strtrim(string(kp_data[n_elements(kp_data)-1].orbit),2)
      goto, kill
    endif
;

;INDIVIDUAL PLOT FLAGS
  if disp_check[0] eq 1 then begin
    e_d_r = 1     ;echelle disk radiacne
  endif else begin
    e_d_r = 0
  endelse
  if disp_check[1] eq 1 then begin
    e_l_r = 1     ;echelle limb radiance
    e_l_h = 1     ;echelle limb half int dist
  endif else begin
    e_l_r = 0
    e_l_h = 0
  endelse
  if disp_check[2] eq 1 then begin
    e_h_r = 1     ;echelle high radiance
    e_h_h = 1     ;echelle high half int dist
  endif else begin
    e_h_r = 0
    e_h_h = 0
  endelse 
  
  if disp_check[3] eq 1 then begin
    l_d_r = 1     ;lowres disk radiance
    l_d_d = 1     ;lowres disk dust
    l_d_a = 1     ;lowres disk aurora
    l_d_o = 1     ;lowres disk ozone
  endif else begin
    l_d_r = 0
    l_d_d = 0
    l_d_a = 0
    l_d_o = 0
  endelse
  if disp_check[4] eq 1 then begin 
    l_l_r = 1     ;lowres limb radiance
    l_l_d = 1     ;lowres limb density
    l_l_s = 1     ;lowres limb scale height
  endif else begin
    l_l_r = 0
    l_l_d = 0
    l_l_s = 0
  endelse
  if disp_check[5] eq 1 then begin  
    l_h_r = 1     ;lowres high radiance
    l_h_d = 1     ;lowres high density
    l_h_h = 1     ;lowres high half int dist
  endif else begin
    l_h_r = 0
    l_h_d = 0
    l_h_h = 0
  endelse


;DETERMINE POSITIONS OF VARIOUS TITLES AND LEGENS


  legend_count = 0
  if (disp_check[0] eq 1) or (disp_check[1] eq 1) or (disp_check[2] eq 1) then begin
    e_title_pos = [0.12, 0.97, 0.0]
    if e_h_r eq 1 then begin
      e_rad_high_title = [0.07, 0.93, 0.0]
     
      legend_count = legend_count+1
    endif
    if e_h_h eq 1 then begin
      e_half_high_title = [0.16, 0.93, 0.0]
      legend_count = legend_count+1
    endif
    if e_l_r eq 1 then begin
      e_rad_limb_title = [0.07, 0.55, 0.0]
      legend_count = legend_count+1
    endif
    if e_l_h eq 1 then begin
      e_half_limb_title = [0.16, 0.55, 0.0]
      legend_count = legend_count+1
    endif
    if e_d_r eq 1 then begin
      e_rad_disk_title = [0.07, 0.15, 0.0]
      legend_count = legend_count+1
    endif
  endif
  if (disp_check[3] eq 1) or (disp_check[4] eq 1) or (disp_check[5] eq 1) then begin
    lo_title_pos = [0.4, 0.97, 0.0]
    if l_h_r eq 1 then begin
      lo_rad_high_title = [0.27, 0.93, 0.0]
      legend_count = legend_count+1
    endif
    if l_h_d eq 1 then begin
      lo_den_high_title = [0.37, 0.93, 0.0]
      legend_count = legend_count+1
    endif
    if l_h_h eq 1 then begin
      lo_half_high_title = [0.56, 0.93, 0.0]
      legend_count = legend_count+1
    endif
    if l_l_r eq 1 then begin
      lo_rad_limb_title = [0.27, 0.55, 0.0]
      legend_count = legend_count+1
    endif
    if l_d_r eq 1 then begin
      lo_rad_disk_title = [0.27, 0.15, 0.0]
      legend_count = legend_count+1
    endif
    if l_l_d eq 1 then begin
      lo_den_limb_title = [0.37, 0.55, 0.0]
      legend_count = legend_count+1
    endif
    if l_d_d eq 1 then begin
      lo_dust_disk_title = [0.38, 0.15, 0.0]
      legend_count = legend_count+1
    endif
    if l_l_s eq 1 then begin
      lo_scale_limb_title = [0.46, 0.55, 0.0]
      legend_count = legend_count+1
    endif
    if l_d_a eq 1 then begin
      lo_aurora_disk_title = [0.47, 0.15, 0.0]
      legend_count = legend_count+1
    endif
    if l_d_o eq 1 then begin
      lo_ozone_disk_title = [0.58, 0.15, 0.0]
      legend_count = legend_count+1
    endif
  endif


print,'legend',legend_count

;BUILD THE ARRAY THAT DEFINES HOW MANY PLOTS WILL BE DISPLAYED (ie the p.multi array)
  rows = 3
  columns = 6
  order = 1
  rad_plot = 0
  den_plot = 0
  half_plot = 0
  scale_plot = 0
  

  !p.multi = [0,columns,rows,0,order]
  
  
;EXTRACT THE ECHELLE DATA TO A PLOTTING ARRAY
  if disp_check[0] eq 1 then begin          ;extract echelle disk data    
    e_disk_total = 0
    for i=0, n_elements(kp_data.corona_e_disk.time_start)-1 do begin
      if kp_data[i].corona_e_disk.time_start ne '' then e_disk_total = e_disk_total+1
    endfor
    e_disk_radiance = fltarr(e_disk_total,n_elements(kp_data[0].corona_e_disk.radiance_id))
    e_disk_radiance_err = fltarr(e_disk_total,n_elements(kp_data[0].corona_e_disk.radiance_id))
    e_disk_timestamp = lonarr(e_disk_total)
    e_disk_labels = strarr(e_disk_total,n_elements(kp_data[0].corona_e_disk.radiance_id))
    e_disk_total=0
    for i=0,n_elements(kp_data.corona_e_disk.time_start)-1 do begin
      if kp_data[i].corona_e_disk.time_start ne '' then begin
        e_disk_radiance[e_disk_total,*] = kp_data[i].corona_e_disk.radiance[*]
        e_disk_radiance_err[e_disk_total,*] = kp_data[i].corona_e_disk.radiance_err[*]
        e_disk_timestamp[e_disk_total] = time_double(kp_data[i].corona_e_disk.time_start)
        e_disk_labels[e_disk_total,*] = kp_data[i].corona_e_disk.radiance_id[*]
        e_disk_total = e_disk_total+1
      endif
    endfor
  endif
  if disp_check[1] eq 1 then begin          ;extract echelle limb data
    e_limb_total = 0
    for i=0, n_elements(kp_data.corona_e_limb.time_start)-1 do begin
      if kp_data[i].corona_e_limb.time_start ne '' then e_limb_total = e_limb_total+1
    endfor
    e_limb_radiance = fltarr(e_limb_total, n_elements(kp_data[0].corona_e_limb.radiance_id), 31)
    e_limb_radiance_err = fltarr(e_limb_total, n_elements(kp_data[0].corona_e_limb.radiance_id), 31)
    e_limb_rad_labels = strarr(e_limb_total, n_elements(kp_data[0].corona_e_limb.radiance_id))
    e_limb_rad_alt = fltarr(e_limb_total,31)
    e_limb_half = fltarr(e_limb_total, n_elements(kp_data[0].corona_e_limb.half_int_distance_id))
    e_limb_half_err = fltarr(e_limb_total, n_elements(kp_data[0].corona_e_limb.half_int_distance_id))
    e_limb_half_labels = strarr(e_limb_total, n_elements(kp_data[0].corona_e_limb.half_int_distance_id))
    e_limb_timestamp = lonarr(e_limb_total)
    e_limb_total = 0
    for i=0,n_elements(kp_data.corona_e_limb.time_start)-1 do begin
      if kp_data[i].corona_e_limb.time_start ne '' then begin
        e_limb_radiance[e_limb_total,*,*] = kp_data[i].corona_e_limb.radiance
        e_limb_radiance_err[e_limb_total,*,*] = kp_data[i].corona_e_limb.radiance_err
        e_limb_rad_labels[e_limb_total,*] = kp_data[i].corona_e_limb.radiance_id
        e_limb_rad_alt[e_limb_total,*] = kp_data[i].corona_e_limb.alt
        e_limb_half[e_limb_total,*] = kp_data[i].corona_e_limb.half_int_distance
        e_limb_half_err[e_limb_total,*] = kp_data[i].corona_e_limb.half_int_distance_err
        e_limb_half_labels[e_limb_total,*] = kp_data[i].corona_e_limb.half_int_distance_id
        e_limb_timestamb =time_double(kp_data[i].corona_e_limb.time_start)
        e_limb_total = e_limb_total + 1
      endif
    endfor
  endif
  if disp_check[2] eq 1 then begin          ;extract echelle high altitude data
    e_high_total = 0
    for i=0, n_elements(kp_data.corona_e_high.time_start)-1 do begin
      if kp_data[i].corona_e_high.time_start ne '' then e_high_total = e_high_total+1
    endfor
    e_high_radiance = fltarr(e_high_total, n_elements(kp_data[0].corona_e_high.radiance_id), 77)
    e_high_radiance_err = fltarr(e_high_total, n_elements(kp_data[0].corona_e_high.radiance_id), 77)
    e_high_rad_labels = strarr(e_high_total, n_elements(kp_data[0].corona_e_high.radiance_id))
    e_high_rad_alt = fltarr(e_high_total,77)
    e_high_half = fltarr(e_high_total, n_elements(kp_data[0].corona_e_high.half_int_distance_id))
    e_high_half_err = fltarr(e_high_total, n_elements(kp_data[0].corona_e_high.half_int_distance_id))
    e_high_half_labels = strarr(e_high_total, n_elements(kp_data[0].corona_e_high.half_int_distance_id))
    e_high_timestamp = lonarr(e_high_total)
    e_high_total = 0
    for i=0,n_elements(kp_data.corona_e_high.time_start)-1 do begin
      if kp_data[i].corona_e_high.time_start ne '' then begin
        e_high_radiance[e_high_total,*,*] = kp_data[i].corona_e_high.radiance
        e_high_radiance_err[e_high_total,*,*] = kp_data[i].corona_e_high.radiance_err
        e_high_rad_labels[e_high_total,*] = kp_data[i].corona_e_high.radiance_id
        e_high_rad_alt[e_high_total,*] = kp_data[i].corona_e_high.alt
        e_high_half[e_high_total,*] = kp_data[i].corona_e_high.half_int_distance
        e_high_half_err[e_high_total,*] = kp_data[i].corona_e_high.half_int_distance_err
        e_high_half_labels[e_high_total,*] = kp_data[i].corona_e_high.half_int_distance_id
        e_high_timestamb =time_double(kp_data[i].corona_e_high.time_start)
        e_high_total = e_high_total + 1
      endif
    endfor    
  endif

;EXTRACT THE LORES DATA TO PLOTTING ARRAYS
  if disp_check[3] eq 1 then begin                  ;extract lores disk data
    lo_disk_total = 0
    for i=0, n_elements(kp_data.corona_lo_disk.time_start)-1 do begin
      if kp_data[i].corona_lo_disk.time_start ne '' then lo_disk_total = lo_disk_total+1
    endfor
    lo_disk_radiance = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.radiance_id))
    lo_disk_radiance_err = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.radiance_id))
    lo_disk_timestamp = lonarr(lo_disk_total)
    lo_disk_labels = strarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.radiance_id))
    lo_disk_dust = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.dust_depth))
    lo_disk_dust_err = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.dust_depth))
    lo_disk_ozone = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.ozone_depth))
    lo_disk_ozone_err = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.ozone_depth))
    lo_disk_auroral = fltarr(lo_disk_total,n_elements(kp_data[0].corona_lo_disk.auroral_index))
    lo_disk_total=0
    for i=0, n_elements(kp_data.corona_lo_disk.time_start)-1 do begin
      if kp_data[i].corona_lo_disk.time_start ne '' then begin
        lo_disk_radiance[lo_disk_total,*] = kp_data[i].corona_lo_disk.radiance
        lo_disk_radiance_err[lo_disk_total,*] = kp_data[i].corona_lo_disk.radiance_err
        lo_disk_labels[lo_disk_total,*] = kp_data[i].corona_lo_disk.radiance_id
        lo_disk_timestamp[lo_disk_total] = time_double(kp_data[i].corona_lo_disk.time_start)
        lo_disk_dust[lo_disk_total,*] = kp_data[i].corona_lo_disk.dust_depth
        lo_disk_dust_err[lo_disk_total,*] = kp_data[i].corona_lo_disk.dust_depth_err
        lo_disk_ozone[lo_disk_total,*] = kp_data[i].corona_lo_disk.ozone_depth
        lo_disk_ozone_err[lo_disk_total,*] = kp_data[i].corona_lo_disk.ozone_depth_err
        lo_disk_auroral[lo_disk_total,*] = kp_data[i].corona_lo_disk.auroral_index
        lo_disk_total = lo_disk_total+1
      endif
    endfor
  endif
  
  if disp_check[4] eq 1 then begin                  ;extract lores limb data
    lo_limb_total = 0
    for i=0, n_elements(kp_data.corona_lo_limb.time_start)-1 do begin
      if kp_data[i].corona_lo_limb.time_start ne '' then lo_limb_total = lo_limb_total+1
    endfor
    lo_limb_radiance = fltarr(lo_limb_total,n_elements(kp_data[0].corona_lo_limb.radiance_id),31)
    lo_limb_radiance_err = fltarr(lo_limb_total,n_elements(kp_data[0].corona_lo_limb.radiance_id),31)
    lo_limb_rad_labels = strarr(lo_limb_total,n_elements(kp_data[0].corona_lo_limb.radiance_id))
    lo_limb_rad_alt = fltarr(lo_limb_total,31)
    lo_limb_density = fltarr(lo_limb_total,n_elements(kp_data[0].corona_lo_limb.density_id),31)
    lo_limb_density_err = fltarr(lo_limb_total,n_elements(kp_data[0].corona_lo_limb.density_id),31)
    lo_limb_den_labels = strarr(lo_limb_total,n_elements(kp_data[0].corona_lo_limb.density_id))
    lo_limb_scale = fltarr(lo_limb_total,n_elements(kp_data[0].corona_lo_Limb.scale_height_id))
    lo_limb_scale_err = fltarr(lo_limb_total,n_elements(kp_data[0].corona_lo_Limb.scale_height_id))
    lo_limb_scale_labels = strarr(lo_limb_total,n_elements(kp_data[0].corona_lo_Limb.scale_height_id))
    lo_limb_timestamp = lonarr(lo_limb_total) 
    lo_limb_total = 0
    for i=0, n_elements(kp_data.corona_lo_limb.time_start)-1 do begin
      if kp_data[i].corona_lo_limb.time_start ne '' then begin   
        lo_limb_radiance[lo_limb_total,*,*] = kp_data[i].corona_lo_limb.radiance
        lo_limb_radiance_err[lo_limb_total,*,*] = kp_data[i].corona_lo_limb.radiance_err
        lo_limb_rad_labels[lo_limb_total,*] = kp_data[i].corona_lo_limb.radiance_id
        lo_limb_rad_alt[lo_limb_total] = kp_data[i].corona_lo_limb.alt
        lo_limb_density[lo_limb_total,*,*] = kp_data[i].corona_lo_limb.density
        lo_limb_density_err[lo_limb_total,*,*] = kp_data[i].corona_lo_limb.density_err
        lo_limb_den_labels[lo_limb_total,*] =kp_data[i].corona_lo_limb.density_id
        lo_limb_scale[lo_limb_total,*] = kp_data[i].corona_lo_limb.scale_height
        lo_limb_scale_err[lo_limb_total,*] = kp_data[i].corona_lo_limb.scale_height_err
        lo_limb_scale_labels[lo_limb_total,*] = kp_data[i].corona_lo_limb.scale_height_id
        lo_limb_timestamp[lo_limb_total,*] = time_double(kp_data[i].corona_lo_limb.time_start)
        lo_limb_total = lo_limb_total + 1
      endif
    endfor  
        
  endif
  
  if disp_check[5] eq 1 then begin                  ;extranct lores high data
    lo_high_total = 0
    for i=0, n_elements(kp_data.corona_lo_high.time_start)-1 do begin
      if kp_data[i].corona_lo_high.time_start ne '' then lo_high_total = lo_high_total+1
    endfor
    lo_high_radiance = fltarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.radiance_id),77)
    lo_high_radiance_err = fltarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.radiance_id),77)
    lo_high_rad_labels = strarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.radiance_id))
    lo_high_rad_alt = fltarr(lo_high_total,77)
    lo_high_density = fltarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.density_id),77)
    lo_high_density_err = fltarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.density_id),77)
    lo_high_den_labels = strarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.density_id))
    lo_high_half = fltarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.half_int_distance_id))
    lo_high_half_err = fltarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.half_int_distance_id))
    lo_high_half_labels = strarr(lo_high_total,n_elements(kp_data[0].corona_lo_high.half_int_distance_id))
    lo_high_timestamp = lonarr(lo_high_total) 
    lo_high_total = 0
    for i=0, n_elements(kp_data.corona_lo_high.time_start)-1 do begin
      if kp_data[i].corona_lo_high.time_start ne '' then begin
        lo_high_radiance[lo_high_total,*,*] = kp_data[i].corona_lo_high.radiance
        lo_high_radiance_err[lo_high_total,*,*] = kp_data[i].corona_lo_high.radiance_err
        lo_high_rad_labels[lo_high_total,*] = kp_data[i].corona_lo_high.radiance_id
        lo_high_rad_alt[lo_high_total,*] = kp_data[i].corona_lo_high.alt
        lo_high_density[lo_high_total,*,*] = kp_data[i].corona_lo_high.density
        lo_high_density_err[lo_high_total,*,*] = kp_data[i].corona_lo_high.density_err
        lo_high_den_labels[lo_high_total,*] =kp_data[i].corona_lo_high.density_id
        lo_high_half[lo_high_total,*] = kp_data[i].corona_lo_high.half_int_distance
        lo_high_half_err[lo_high_total,*] = kp_data[i].corona_lo_high.half_int_distance_err
        lo_high_half_labels[lo_high_total,*] = kp_data[i].corona_lo_high.half_int_distance_id
        lo_high_timestamp[lo_high_total,*] = time_double(kp_data[i].corona_lo_high.time_start)
        lo_high_total = lo_high_total+1
      endif
    endfor
  endif



;CREATE EACH PLOT

  ;set up the plot window
    a=get_screen_size()
    window,0,xsize=a[0],ysize=a[1]

  if e_h_r eq 1 then begin        ;echelle high radiance
    plot,e_high_radiance[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.025,.6,.1,.95],/ylog
    for i=0, e_high_total -1 do begin
      for j=0, n_elements(e_high_rad_labels[0,*])-1 do begin
        oplot,e_high_radiance[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
      endfor
    endfor
    if (keyword_set(nolabels) ne 1) then xyouts, e_rad_high_title[0],e_rad_high_title[1],'Radiance',/normal
  endif 
  if e_l_r eq 1 then begin        ;echelle limb radiance
    plot,e_limb_radiance[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.025,.2,.1,.57]
    for i=0, e_limb_total -1 do begin
      for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
        oplot,e_limb_radiance[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
      endfor
    endfor   
    if (keyword_set(nolabels) ne 1) then xyouts, e_rad_limb_title[0],e_rad_limb_title[1],'Radiance',/normal 
  endif
  if e_d_r eq 1 then begin        ;echelle disk radiance
    plot,e_disk_radiance[0,*],e_disk_timestamp,/nodata,charsize=1.5, position=[.025,.05,.1,.17]
    for i=0, e_disk_total-1 do begin
      oplot,e_disk_radiance[i,*],e_disk_timestamp,linestyle=(i mod 7),color=i*(255/e_disk_total)
    endfor
    if (keyword_set(nolabels) ne 1) then xyouts, e_rad_disk_title[0],e_rad_disk_title[1],'Radiance',/normal
  endif
  if e_h_h eq 1 then begin        ;echelle high half int dist
    plot,e_high_half[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.125,.6,.2,.95],/ylog
    for i=0, e_high_total -1 do begin
      for j=0, n_elements(e_high_half_labels[0,*])-1 do begin
        oplot,e_high_half[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
      endfor
    endfor     
    if (keyword_set(nolabels) ne 1) then xyouts, e_half_high_title[0], e_half_high_title[1], '1/2 Int Dist', /normal
  endif
  if e_l_h eq 1 then begin        ;echelle limb half int dist
    plot,e_limb_half[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.125,.2,.2,.57]
    for i=0, e_limb_total -1 do begin
      for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
        oplot,e_limb_half[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
      endfor
    endfor    
    if (keyword_set(nolabels) ne 1) then xyouts, e_half_limb_title[0],e_half_limb_title[1],'1/2 Int Dist',/normal
  endif
  if l_h_r eq 1 then begin        ;lores high radiance
    plot,lo_high_radiance[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.225,.6,.3,.95],/ylog
    for i=0, lo_high_total -1 do begin
      for j=0, n_elements(lo_high_half_labels[0,*])-1 do begin
        oplot,lo_high_half[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
      endfor
    endfor
    if (keyword_set(nolabels) ne 1) then xyouts, lo_rad_high_title[0], lo_rad_high_title[1], 'Radiance', /normal    
  endif
  if l_l_r eq 1 then begin        ;lores limb radiance
    plot,lo_limb_radiance[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.225,.2,.3,.57]
    for i=0, lo_limb_total -1 do begin
      for j=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
        oplot,lo_limb_radiance[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
      endfor
    endfor   
    if (keyword_set(nolabels) ne 1) then xyouts, lo_rad_limb_title[0], lo_rad_limb_title[1], 'Radiance', /normal  
  endif
  if l_d_r eq 1 then begin        ;lores disk radiance
    plot,lo_disk_radiance[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.225,.05,.3,.17]
    for i=0, lo_disk_total-1 do begin
      oplot,lo_disk_radiance[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
    endfor    
    if (keyword_set(nolabels) ne 1) then xyouts, lo_rad_disk_title[0], lo_rad_disk_title[1], 'Radiance', /normal
  endif
  if l_h_d eq 1 then begin        ;lores high density
    plot,lo_high_density[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.325,.6,.4,.95],/ylog
    for i=0, lo_high_total -1 do begin
      for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
        oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
      endfor
    endfor    
    if (keyword_set(nolabels) ne 1) then xyouts, lo_den_high_title[0], lo_den_high_title[1], 'Density', /normal 
  endif
  if l_l_d eq 1 then begin        ;lores limb density
    plot,lo_limb_density[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.325,.2,.4,.57]
    for i=0, lo_limb_total -1 do begin
      for j=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
        oplot,lo_limb_density[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
      endfor
    endfor 
    if (keyword_set(nolabels) ne 1) then xyouts, lo_den_limb_title[0], lo_den_limb_title[1], 'Density', /normal    
  endif
  if l_d_d eq 1 then begin        ;lores disk density
    plot,lo_disk_dust[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.325,.05,.4,.17]
    for i=0, lo_disk_total-1 do begin
      oplot,lo_disk_dust[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
    endfor       
    if (keyword_set(nolabels) ne 1) then xyouts, lo_dust_disk_title[0], lo_dust_disk_title[1], 'Dust', /normal
  endif
  if l_l_s eq 1 then begin        ;lores limb scale
    plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.425,.2,.5,.57]
    for i=0, lo_limb_total -1 do begin
      for j=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
        oplot,lo_limb_scale[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
      endfor
    endfor      
    if (keyword_set(nolabels) ne 1) then xyouts, lo_scale_limb_title[0], lo_scale_limb_title[1], 'Scale Height', /normal
  endif
  if l_d_a eq 1 then begin        ;lores disk aurora
    plot,lo_disk_auroral[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.425,.05,.5,.17]
    for i=0, lo_disk_total-1 do begin
      oplot,lo_disk_auroral[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
    endfor      
    if (keyword_set(nolabels) ne 1) then xyouts, lo_aurora_disk_title[0], lo_aurora_disk_title[1], 'Auroral', /normal
  endif
  if l_h_h eq 1 then begin        ;lores high half int
    plot,lo_high_half[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.525,.6,.6,.95],/ylog
    for i=0, lo_high_total -1 do begin
      for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
        oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
      endfor
    endfor      
    if (keyword_set(nolabels) ne 1) then xyouts, lo_half_high_title[0], lo_half_high_title[1], '1/2 Int Dist', /normal 
  endif
  if l_d_o eq 1 then begin        ;lores disk ozone
    plot,lo_disk_ozone[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.525,.05,.6,.17]
    for i=0, lo_disk_total-1 do begin
      oplot,lo_disk_ozone[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
    endfor     
    if (keyword_set(nolabels) ne 1) then xyouts, lo_ozone_disk_title[0], lo_ozone_disk_title[1], 'Ozone', /normal
  endif


;ADD IN TITLES AND PLOT LABELS

  if (disp_check[0] eq 1) or (disp_check[1] eq 1) or (disp_check[2] eq 1) then begin
    if (keyword_set(nolabels) ne 1) then xyouts, e_title_pos[0], e_title_pos[1], 'Echelle Data', alignment=0.5, charthick=2.5, charsize= 2.0, /normal
  endif
  if (disp_check[3] eq 1) or (disp_check[4] eq 1) or (disp_check[5] eq 1) then begin
    if (keyword_set(nolabels) ne 1) then xyouts, lo_title_pos[0], lo_title_pos[1], 'Lo-Res Data', alignment=0.5, charthick=2.5, charsize= 2.0, /normal
  endif
  
;ADD THE LEGEND ALONG THE RIGHTHAND SIDE
  if (keyword_set(nolegend) eq 0) then begin
    a=get_screen_size()
    window,!window+1,xsize=a[0],ysize=a[1]
     xyouts, 0.05, 0.97, 'Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

      if e_h_r eq 1 then begin
         xyouts,0.02, 0.93, 'Echelle: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
         leg_i=0.91
         for i=0, n_elements(e_high_rad_labels[0,*])-1 do begin
              xyouts,0.03,leg_i,e_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
           for j=0,e_high_total-1 do begin
              xyouts,0.1,leg_i, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
              leg_i=leg_i-0.015
          endfor 
        endfor
      endif
  
      if e_h_h eq 1 then begin
         xyouts,0.20, 0.93, 'Echelle: 1/2 Int', alignment=0, charthick=1.5, charsize=1.5, /normal
         leg_i=0.91
         for i=0, n_elements(e_high_half_labels[0,*])-1 do begin
              xyouts,0.22,leg_i,e_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
           for j=0,e_high_total-1 do begin
              xyouts,0.31,leg_i, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
              leg_i=leg_i-0.015
          endfor 
        endfor
      endif
      
  endif

  print,legend_count


kill: 
end