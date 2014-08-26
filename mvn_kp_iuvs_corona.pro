;+
; 
; :Name: mvn_kp_iuvs_corona
; 
; :Author: Kristopher Larsen
; 
; :Description:
;   This routine plots all the coronal scan data held within the IUVS KP structure in a variety of ways.
;   By default, calling this routine with just the data structure defined will plot ALL the coronal data.
;   
; :Params:
;   kp_data: in, required, type=structure
;     This is the MAVEN IUVS KP data structure. It should contain at least some Coronal Scan observations to plot.
;   colortable, in, optional, type=integer
;     This variable is the integer index of a pre-defined IDL color table. By default, the routine will use #39.
; 
; :Keywords:
;   echelle: in, optional, type=boolean
;     Used to plot the Echelle coronal data. Can be used in conjunction with /lores, but that is equivalent to using neither.
;   lores: in, optional, type=boolean
;     Used to plot the LoRes coronal data. Can be used in conjunction with /echelle, but that is equivalent to using niether.
;   disk: in, optional, type=boolean
;     Used to plot all the Disk Coronal data within the structure.
;     This keyword may be used in conjunction with /limb and /high, as well as /echelle and /lores, to show the desired subset of IUVS data.
;   limb: in, optional, type=boolean
;     Used to plot all the Limb Coronal Scan data within the input structure.
;     This keyword may be used in conjunction with /disk and /high, as well as /echelle and /lores, to show the desired subset of IUVS data.
;   high: in, optional, type=boolean
;     Used to plot all the High Altitude Coronal Scan data within the input structure
;     This keyword may be used in conjunction with /disk and /limb, as well as /echelle and /lores, to show the desired subset of IUVS data.
;   range: in, optional, type=boolean
;     Used to print the beginning and end times/orbits contained within the input data structure. 
;     Using this keyword will result in no plot. 
;   nolabels: in, optional, type=boolean
;     Used to suppress the labels on each plot.
;   nolegend: in, optional, type=boolean
;     Used to suppress the additional legend windows created by the routine. 
;   save_window: in, optional, type=boolean
;     If this keyword is used, the currently displayed idl direct graphic plot windows are retained.
;     Useful for making multiple plots to compare different coronal scans. 
;   
; :Version:   1.0   July 8, 2014
;-
pro MVN_KP_IUVS_CORONA, kp_data, echelle=echelle, lores=lores, disk=disk, limb=limb, high=high, $
                        range=range, colortable=colortable, nolabels=nolabels, nolegend=nolegend, $
                        save_window=save_window, help=help


  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    print,'MVN_KP_IUVS_CORONA'
    print,'  This routine plots all the coronal scan data held within the IUVS KP structure in a variety of ways.'
    print,'  By default, calling this routine with just the data structure defined will plot ALL the coronal data.' 
    print,''
    print,'mvn_kp_iuvs_corona, kp_data, echelle=echelle, lores=lores, disk=disk, limb=limb, high=high, $'
    print,'                    range=range, colortable=colortable, nolabels=nolabels, nolegend=nolegend, $'
    print,'                    save_window=save_window, help=help'
    print,''
    print,'REQUIRED FIELDS'
    print,'**************'
    print,'  kp_data: IUVS Key Parameter Data Structure'
    print,''
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'     echelle:  Used to plot the Echelle coronal data. Can be used in conjunction with /lores, but that is equivalent to using neither.'
    print,'     lores: Used to plot the LoRes coronal data. Can be used in conjunction with /echelle, but that is equivalent to using niether.'
    print,'     disk: Used to plot all the Disk Coronal data within the structure.'
    print,'           This keyword may be used in conjunction with /limb and /high, as well as /echelle and /lores, to show the desired subset of IUVS data.'
    print,'     limb: Used to plot all the Limb Coronal Scan data within the input structure.'
    print,'           This keyword may be used in conjunction with /disk and /high, as well as /echelle and /lores, to show the desired subset of IUVS data.'
    print,'     high: Used to plot all the High Altitude Coronal Scan data within the input structure'
    print,'           This keyword may be used in conjunction with /disk and /limb, as well as /echelle and /lores, to show the desired subset of IUVS data.'
    print,'     range: Used to print the beginning and end times/orbits contained within the input data structure. '
    print,'            Using this keyword will result in no plot. '
    print,'     colortable: This variable is the integer index of a pre-defined IDL color table. By default, the routine will use #39.'
    print,'     nolabels: Used to suppress the labels on each plot.'
    print,'     nolegend: Used to suppress the additional legend windows created by the routine. '
    print,'     save_window: If this keyword is used, the currently displayed idl direct graphic plot windows are retained.'
    print,'                  Useful for making multiple plots to compare different coronal scans.'
    print,'     help: Invokes this list.'
    return
  endif


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
    return
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
;    if keyword_set(window) then begin
;      plot_window = !window + 1
;      legend_window = plot_window + 1
;    endif else begin
;      plot_window = 1
;      legend_window = 2
;    endelse
    
;CHECK DATE RANGES
    if keyword_set(range) then begin
      print,'The data structure contains data that spans the time range of '+strtrim(string(kp_data[0].periapse[0].time_start),2)+' to '+$
          strtrim(string(kp_data[n_elements(kp_data)-1].periapse[2].time_stop),2)
      print,'Equivalently, this includes the orbits of '+strtrim(string(kp_data[0].orbit),2)+' to '+strtrim(string(kp_data[n_elements(kp_data)-1].orbit),2)
     return
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
        e_disk_timestamp[e_disk_total] = time_double(kp_data[i].corona_e_disk.time_start, tformat="YYYY-MM-DDThh:mm:ss")
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
        e_limb_timestamb =time_double(kp_data[i].corona_e_limb.time_start, tformat="YYYY-MM-DDThh:mm:ss")
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
        lo_disk_timestamp[lo_disk_total] = time_double(kp_data[i].corona_lo_disk.time_start, tformat="YYYY-MM-DDThh:mm:ss")
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
        lo_limb_rad_alt[lo_limb_total,*] = kp_data[i].corona_lo_limb.alt
        lo_limb_density[lo_limb_total,*,*] = kp_data[i].corona_lo_limb.density
        lo_limb_density_err[lo_limb_total,*,*] = kp_data[i].corona_lo_limb.density_err
        lo_limb_den_labels[lo_limb_total,*] =kp_data[i].corona_lo_limb.density_id
        lo_limb_scale[lo_limb_total,*] = kp_data[i].corona_lo_limb.scale_height
        lo_limb_scale_err[lo_limb_total,*] = kp_data[i].corona_lo_limb.scale_height_err
        lo_limb_scale_labels[lo_limb_total,*] = kp_data[i].corona_lo_limb.scale_height_id
        lo_limb_timestamp[lo_limb_total,*] = time_double(kp_data[i].corona_lo_limb.time_start, tformat="YYYY-MM-DDThh:mm:ss")
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
        lo_high_timestamp[lo_high_total,*] = time_double(kp_data[i].corona_lo_high.time_start, tformat="YYYY-MM-DDThh:mm:ss")
        lo_high_total = lo_high_total+1
      endif
    endfor
  endif

;**********************************
;    START THE PLOTTING ROUTINES HERE
;**********************************

;DEFAULT PLOT EVERYTHING IN ONE WINDOW

  if total(disp_check) eq 6 then begin
                
              ;set up the plot window
                a=get_screen_size()*0.8
                if keyword_set(save_window) then begin
                  window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.8
                endif else begin
                  window,0,xsize=a[0]*0.5,ysize=a[1]*0.8
                endelse
                device, decomposed=0
            
              if e_h_r eq 1 then begin        ;echelle high radiance
                plot,e_high_radiance[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.025,.6,.165,.95],/ylog,ystyle=1
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                    oplot,e_high_radiance[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor
                if (keyword_set(nolabels) ne 1) then xyouts, .03,.93,'High: Radiance',/normal
              endif 
              if e_l_r eq 1 then begin        ;echelle limb radiance
                plot,e_limb_radiance[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.025,.2,.165,.57],ystyle=1
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_radiance[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor   
                if (keyword_set(nolabels) ne 1) then xyouts, 0.03,.55,'Limb: Radiance',/normal 
              endif
              if e_d_r eq 1 then begin        ;echelle disk radiance
                plot,e_disk_radiance[0,*],e_disk_timestamp,/nodata,charsize=1.5, position=[.025,.05,.165,.17],ystyle=1
                for i=0, e_disk_total-1 do begin
                  oplot,e_disk_radiance[i,*],e_disk_timestamp,linestyle=(i mod 7),color=i*(255/e_disk_total)
                endfor
                if (keyword_set(nolabels) ne 1) then xyouts, 0.03, 0.15,'Disk: Radiance',/normal
              endif
              if e_h_h eq 1 then begin        ;echelle high half int dist
                plot,e_high_half[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.190,.6,.33,.95],/ylog,ystyle=1
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_half_labels[0,*])-1 do begin
                    oplot,e_high_half[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor     
                if (keyword_set(nolabels) ne 1) then xyouts, 0.195, 0.93, 'High: 1/2 Int Dist', /normal
              endif
              if e_l_h eq 1 then begin        ;echelle limb half int dist
                plot,e_limb_half[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.190,.2,.33,.57],ystyle=1
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_half[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor    
                if (keyword_set(nolabels) ne 1) then xyouts, 0.195, 0.55,'Limb: 1/2 Int Dist',/normal
              endif
              if l_h_r eq 1 then begin        ;lores high radiance
                plot,lo_high_radiance[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.355,.6,.495,.95],/ylog,ystyle=1
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                    oplot,lo_high_half[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor
                if (keyword_set(nolabels) ne 1) then xyouts, 0.36, 0.93,'High: Radiance', /normal    
              endif
              if l_l_r eq 1 then begin        ;lores limb radiance
                plot,lo_limb_radiance[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.355,.2,.495,.57],ystyle=1
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                    oplot,lo_limb_radiance[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor   
                if (keyword_set(nolabels) ne 1) then xyouts, 0.36, 0.55, 'Limb: Radiance', /normal  
              endif
              if l_d_r eq 1 then begin        ;lores disk radiance
                plot,lo_disk_radiance[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.355,.05,.495,.17],ystyle=1
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_radiance[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor    
                if (keyword_set(nolabels) ne 1) then xyouts, 0.36, 0.15, 'Disk: Radiance', /normal
              endif
              if l_h_d eq 1 then begin        ;lores high density
                plot,lo_high_density[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.52,.6,.66,.95],/ylog,ystyle=1
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor    
                if (keyword_set(nolabels) ne 1) then xyouts, 0.525, 0.93, 'High: Density', /normal 
              endif
              if l_l_d eq 1 then begin        ;lores limb density
                plot,lo_limb_density[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.52,.2,.66,.57],ystyle=1
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                    oplot,lo_limb_density[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor 
                if (keyword_set(nolabels) ne 1) then xyouts, 0.525, 0.55, 'Limb: Density', /normal  
              endif
              if l_d_d eq 1 then begin        ;lores disk density
                plot,lo_disk_dust[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.52,.05,.66,.17],ystyle=1
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_dust[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor       
                if (keyword_set(nolabels) ne 1) then xyouts, 0.525, 0.15, 'Disk: Dust', /normal
              endif
              if l_l_s eq 1 then begin        ;lores limb scale
                plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,position=[.685,.2,.825,.57],ystyle=1
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                    oplot,lo_limb_scale[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor      
                if (keyword_set(nolabels) ne 1) then xyouts, 0.69, 0.55, 'Limb: Scale Height', /normal
              endif
              if l_d_a eq 1 then begin        ;lores disk aurora
                plot,lo_disk_auroral[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.685,.05,.825,.17],ystyle=1
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_auroral[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor      
                if (keyword_set(nolabels) ne 1) then xyouts, 0.69, 0.15, 'Disk: Auroral', /normal
              endif
              if l_h_h eq 1 then begin        ;lores high half int
                plot,lo_high_half[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,position=[.85,.6,.99,.95],/ylog,ystyle=1
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor      
                if (keyword_set(nolabels) ne 1) then xyouts, 0.855, 0.93, 'High: 1/2 Int Dist', /normal 
              endif
              if l_d_o eq 1 then begin        ;lores disk ozone
                plot,lo_disk_ozone[0,*],lo_disk_timestamp,/nodata,charsize=1.5, position=[.85,.05,.99,.17],ystyle=1
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_ozone[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor     
                if (keyword_set(nolabels) ne 1) then xyouts, 0.855, 0.15, 'Disk: Ozone', /normal
              endif
            
            
            ;ADD IN TITLES AND PLOT LABELS
            
              if (disp_check[0] eq 1) or (disp_check[1] eq 1) or (disp_check[2] eq 1) then begin
                if (keyword_set(nolabels) ne 1) then xyouts, 0.1775, 0.97, 'Echelle Data', alignment=0.5, charthick=2.5, charsize= 2.0, /normal
              endif
              if (disp_check[3] eq 1) or (disp_check[4] eq 1) or (disp_check[5] eq 1) then begin
                if (keyword_set(nolabels) ne 1) then xyouts, 0.6725,0.97, 'Lo-Res Data', alignment=0.5, charthick=2.5, charsize= 2.0, /normal
              endif
              
            ;ADD THE LEGEND ALONG THE RIGHTHAND SIDE
 
              if keyword_set(nolegend) eq 0 then begin
                a=get_screen_size()
                if keyword_set(save_window) then begin
                  window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.9
                endif else begin
                  window,1,xsize=a[0]*0.5,ysize=a[1]*0.9
                endelse
                device, decompose=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                ;CREATE THE LO-RES LEGEND
                xyouts, 0.5, 0.97, 'Lo-Res  Legend', alignment=0.5, charthick=2.5, charsize=1.5, /normal
  
                  xyouts, 0.15, 0.94, 'High: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.5, 0.94, 'High: Density', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.8, 0.94, 'High: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.15, 0.65, 'Limb: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.5, 0.65, 'Limb: Density', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.8, 0.65, 'Limb: Scale Height', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.10, 0.25, 'Disk: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.35, 0.25, 'Disk: Dust Depth', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.60, 0.25, 'Disk: Auroral Index', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.85, 0.25, 'Disk: Ozone Depth', alignment=0.5, charthick=2.0, charsize=1.5, /normal
               

                      if l_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.88
                          xyouts,0.10,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,lo_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.88
                          xyouts,0.25,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.19,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif 

                      if l_h_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.88
                          xyouts,0.4,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,lo_high_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.88
                          xyouts,0.55,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.49,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.88
                          xyouts,0.7,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_half_labels[0,*])-1 do begin
                              xyouts,0.69,leg_i,lo_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.67,0.72],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.88
                          xyouts,0.85,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.59
                          xyouts,0.10,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,lo_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.59
                          xyouts,0.25,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.19,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif 

                      if l_l_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.59
                          xyouts,0.4,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,lo_limb_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.59
                          xyouts,0.55,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.49,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_l_s eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.59
                          xyouts,0.7,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                              xyouts,0.69,leg_i,lo_limb_scale_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.67,0.72],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.59
                          xyouts,0.85,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif

                      if l_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.20
                          xyouts,0.05,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_disk_labels[0,*])-1 do begin
                              xyouts,0.04,leg_i,lo_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.02,0.07],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.20
                          xyouts,0.15,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_disk_total-1 do begin
                              xyouts,0.10,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif 
                      
                      if l_d_d eq 1 then begin
                         ;xyouts,0.4, 0.93, 'Lo-Res: Dust Depth', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.2
                         xyouts,0.35,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.29,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                       if l_d_a eq 1 then begin
                        ; xyouts,0.6, 0.93, 'Lo-Res: Auroral Index', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.2
                         xyouts,0.60,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.55,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_d_o eq 1 then begin
                        ; xyouts,0.8, 0.93, 'Lo-Res: Ozone', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.2
                         xyouts,0.85,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif   
                
                ;SEPARATE WINDOW, CREATE THE ECHELLE LEGEND
                 if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,2,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                 device, decompose=0
                 plot,[0,0],[1,1], color=255, background=255, /nodata
                 
                  xyouts, 0.5, 0.97, 'Echelle  Legend', alignment=0.5, charthick=2.5, charsize=1.5, /normal

                xyouts, 0.08, 0.9, 'High: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.28, 0.9, 'High: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.48, 0.9, 'Limb: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.68, 0.9, 'Limb: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.88, 0.9, 'Disk: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                
                      if e_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.03,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                              xyouts,0.01,leg_i,e_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.01,0.05],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.12,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.05,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.23,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_high_half_labels[0,*])-1 do begin
                              xyouts,0.21,leg_i,e_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.21,0.25],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.32,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.25,leg_i-0.02, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if e_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.43,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.41,leg_i,e_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.41,0.45],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.52,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.45,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_l_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.63,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_limb_half_labels[0,*])-1 do begin
                              xyouts,0.61,leg_i,e_limb_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.61,0.65],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.72,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.65,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if e_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.83,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_disk_labels[0,*])-1 do begin
                              xyouts,0.81,leg_i,e_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.81,0.85],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.92,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_disk_total-1 do begin
                              xyouts,0.85,leg_i, time_string(e_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 
     
              endif

endif                       ;*****END THE ALL INCLUSIVE PLOT******


;*****PLOT ECHELLE DATA ONLY******

if (disp_check[0] eq 1) and (disp_check[1] eq 1) and (disp_check[2] eq 1) and $
  (disp_check[3] eq 0) and (disp_check[4] eq 0) and (disp_check[5] eq 0) then begin
       a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,2,3,0,1]
    
    
              if e_h_r eq 1 then begin        ;echelle high radiance
                plot,e_high_radiance[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(e_high_rad_alt[0,*]),max(e_high_rad_alt[0,*])], $
                    title='Echelle High: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                    oplot,e_high_radiance[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor
              endif
              
              if e_l_r eq 1 then begin        ;echelle limb radiance
                plot,e_limb_radiance[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1, yrange=[min(e_limb_rad_alt[0,*]),max(e_limb_rad_alt[0,*])],$
                    title='Echelle Limb: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_radiance[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor   
              endif
              
              if e_d_r eq 1 then begin        ;echelle disk radiance
                plot,e_disk_radiance[0,*],e_disk_timestamp,/nodata,charsize=1.5 ,ystyle=1, title='Echelle Disk: Radiance',xtitle='Time', ytitle='Radiance'
                for i=0, e_disk_total-1 do begin
                  oplot,e_disk_radiance[i,*],e_disk_timestamp,linestyle=(i mod 7),color=i*(255/e_disk_total)
                endfor
              endif
              
              if e_h_h eq 1 then begin        ;echelle high half int dist
                plot,e_high_half[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(e_high_rad_alt[0,*]),max(e_high_rad_alt[0,*])], $
                    title='Echelle High: 1/2 Int Dist',xtitle='1/2 Distance', ytitle='Altitude, km'
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_half_labels[0,*])-1 do begin
                    oplot,e_high_half[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor     
              endif
              
              if e_l_h eq 1 then begin        ;echelle limb half int dist
                plot,e_limb_half[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1, yrange=[min(e_limb_rad_alt[0,*]),max(e_limb_rad_alt[0,*])], $
                    title='Echelle Limb: 1/2 Int Dist',xtitle='1/2 Distance', ytitle='Altitude, km'
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_half[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor    
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                xyouts, 0.5, 0.97, 'Echelle  Legend', alignment=0.5, charthick=2.5, charsize=1.5, /normal

                xyouts, 0.08, 0.9, 'High: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.28, 0.9, 'High: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.48, 0.9, 'Limb: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.68, 0.9, 'Limb: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                xyouts, 0.88, 0.9, 'Disk: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                
                      if e_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.03,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                              xyouts,0.01,leg_i,e_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.01,0.05],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.12,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.05,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.23,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_high_half_labels[0,*])-1 do begin
                              xyouts,0.21,leg_i,e_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.21,0.25],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.32,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.25,leg_i-0.02, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if e_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.43,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.41,leg_i,e_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.41,0.45],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.52,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.45,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_l_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.63,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_limb_half_labels[0,*])-1 do begin
                              xyouts,0.61,leg_i,e_limb_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.61,0.65],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.72,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.65,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if e_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.83,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_disk_labels[0,*])-1 do begin
                              xyouts,0.81,leg_i,e_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.81,0.85],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.92,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_disk_total-1 do begin
                              xyouts,0.85,leg_i, time_string(e_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 
                      
                      if l_l_s eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.83,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                              xyouts,0.81,leg_i,lo_limb_scale_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.81,0.85],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.92,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.85,leg_i-0.02, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
              endif
endif


;****PLOT LORES DATA ONLY****

if (disp_check[3] eq 1) and (disp_check[4] eq 1) and (disp_check[5] eq 1) and $
  (disp_check[0] eq 0) and (disp_check[1] eq 0) and (disp_check[2] eq 0) then begin
  a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.9
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.9
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,4,3,0,1]
    
              if l_h_r eq 1 then begin        ;lores high radiance
                plot,lo_high_radiance[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo-Res High: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                    oplot,lo_high_half[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor 
              endif 
              
              if l_l_r eq 1 then begin        ;lores limb radiance
                plot,lo_limb_radiance[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                    oplot,lo_limb_radiance[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor    
              endif
    
              if l_d_r eq 1 then begin        ;lores disk radiance
                plot,lo_disk_radiance[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Radiance',xtitle='Time', ytitle='Radiance'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_radiance[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor    
              endif
           
              if l_h_d eq 1 then begin        ;lores high density
                plot,lo_high_density[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo-Res High: Density',xtitle='Density', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor    
              endif
              
              if l_l_d eq 1 then begin        ;lores limb density
                plot,lo_limb_density[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Density',xtitle='Density', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                    oplot,lo_limb_density[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor 
              endif
              
               if l_d_d eq 1 then begin        ;lores disk density
                plot,lo_disk_dust[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Dust Depth',xtitle='Time', ytitle='Dust Depth'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_dust[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor       
              endif
              ;*break here*
              plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])],color=255
              
              if l_l_s eq 1 then begin        ;lores limb scale
                plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Scale Height',xtitle='Scale Height', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                    oplot,lo_limb_scale[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor 
                  
              if l_d_a eq 1 then begin        ;lores disk aurora
                plot,lo_disk_auroral[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Auroral Index',xtitle='Time', ytitle='Auroral Index'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_auroral[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor      
              endif
              
              endif
              
              if l_h_h eq 1 then begin        ;lores high half int
                plot,lo_high_half[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo_Res High: 1/2 Int Dist',xtitle='1/2 Dist', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor      
              endif
              ;**Break here
              plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])],color=255
              if l_d_o eq 1 then begin        ;lores disk ozone
                plot,lo_disk_ozone[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Ozone Depth',xtitle='Time', ytitle='Ozone Depth'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_ozone[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor     
              endif
              
                if keyword_set(nolegend) eq 0 then begin
                  if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.9
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.9
                 endelse
                  device,decomposed=0
                  plot,[0,0],[1,1], color=255, background=255, /nodata
                  
                  xyouts, 0.5, 0.97, 'Lo-Res  Legend', alignment=0.5, charthick=2.5, charsize=1.5, /normal
  
                  xyouts, 0.15, 0.94, 'High: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.5, 0.94, 'High: Density', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.8, 0.94, 'High: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.15, 0.65, 'Limb: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.5, 0.65, 'Limb: Density', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.8, 0.65, 'Limb: Scale Height', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.10, 0.25, 'Disk: Radiance', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.35, 0.25, 'Disk: Dust Depth', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.60, 0.25, 'Disk: Auroral Index', alignment=0.5, charthick=2.0, charsize=1.5, /normal
                  xyouts, 0.85, 0.25, 'Disk: Ozone Depth', alignment=0.5, charthick=2.0, charsize=1.5, /normal
               

                      if l_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.88
                          xyouts,0.10,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,lo_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.88
                          xyouts,0.25,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.19,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif 

                      if l_h_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.88
                          xyouts,0.4,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,lo_high_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.88
                          xyouts,0.55,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.49,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.88
                          xyouts,0.7,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_half_labels[0,*])-1 do begin
                              xyouts,0.69,leg_i,lo_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.67,0.72],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.88
                          xyouts,0.85,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.59
                          xyouts,0.10,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,lo_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.59
                          xyouts,0.25,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.19,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif 

                      if l_l_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.59
                          xyouts,0.4,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,lo_limb_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.59
                          xyouts,0.55,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.49,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_l_s eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.59
                          xyouts,0.7,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                              xyouts,0.69,leg_i,lo_limb_scale_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.67,0.72],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.59
                          xyouts,0.85,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif

                      if l_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.20
                          xyouts,0.05,leg_i+0.03,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_disk_labels[0,*])-1 do begin
                              xyouts,0.04,leg_i,lo_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.02,0.07],[leg_i-0.01,leg_i-0.01], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.03
                        endfor
                          leg_i=0.20
                          xyouts,0.15,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_disk_total-1 do begin
                              xyouts,0.10,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif 
                      
                      if l_d_d eq 1 then begin
                         ;xyouts,0.4, 0.93, 'Lo-Res: Dust Depth', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.2
                         xyouts,0.35,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.29,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                       if l_d_a eq 1 then begin
                        ; xyouts,0.6, 0.93, 'Lo-Res: Auroral Index', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.2
                         xyouts,0.60,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.55,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif
                      
                      if l_d_o eq 1 then begin
                        ; xyouts,0.8, 0.93, 'Lo-Res: Ozone', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.2
                         xyouts,0.85,leg_i+.03,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.03
                          endfor 
                      endif   
                endif
endif

;****** PLOT ALL THE CORONAL DISK PLOTS ******
if (disp_check[0] eq 1) and (disp_check[3] eq 1) and $
   (disp_check[1] eq 0) and (disp_check[2] eq 0) and (disp_check[4] eq 0) and (disp_check[5] eq 0) then begin
   a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,5,1,0,1]
    
              if e_d_r eq 1 then begin        ;echelle disk radiance
                plot,e_disk_radiance[0,*],e_disk_timestamp,/nodata,charsize=1.5 ,ystyle=1, title='Echelle Disk: Radiance',xtitle='Time', ytitle='Radiance'
                for i=0, e_disk_total-1 do begin
                  oplot,e_disk_radiance[i,*],e_disk_timestamp,linestyle=(i mod 7),color=i*(255/e_disk_total)
                endfor
              endif
              
              if l_d_r eq 1 then begin        ;lores disk radiance
                plot,lo_disk_radiance[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Radiance',xtitle='Time', ytitle='Radiance'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_radiance[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor    
              endif
              
              if l_d_d eq 1 then begin        ;lores disk density
                plot,lo_disk_dust[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Dust Depth',xtitle='Time', ytitle='Dust Depth'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_dust[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor       
              endif
              
              if l_d_a eq 1 then begin        ;lores disk aurora
                plot,lo_disk_auroral[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Auroral Index',xtitle='Time', ytitle='Auroral Index'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_auroral[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor      
              endif
              
              if l_d_o eq 1 then begin        ;lores disk ozone
                plot,lo_disk_ozone[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Ozone Depth',xtitle='Time', ytitle='Ozone Depth'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_ozone[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor     
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                xyouts, 0.5, 0.97, 'Echelle/Lo-Res Disk Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.10, 0.9, 'E: Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.30, 0.9, 'Lo: Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.50, 0.9, 'Lo: Dust Depth', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.70, 0.9, 'Lo: Auroral Index', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.90, 0.9, 'Lo: Ozone Index', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                
                      if e_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.05,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_disk_labels[0,*])-1 do begin
                              xyouts,0.04,leg_i,e_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.02,0.07],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.15,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_disk_total-1 do begin
                              xyouts,0.10,leg_i, time_string(e_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if l_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.25,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_disk_labels[0,*])-1 do begin
                              xyouts,0.24,leg_i,lo_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.22,0.27],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.35,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_disk_total-1 do begin
                              xyouts,0.30,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 
                      
                      if l_d_d eq 1 then begin
                         ;xyouts,0.4, 0.93, 'Lo-Res: Dust Depth', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                         xyouts,0.5,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.44,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                       if l_d_a eq 1 then begin
                        ; xyouts,0.6, 0.93, 'Lo-Res: Auroral Index', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                         xyouts,0.70,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.64,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_d_o eq 1 then begin
                        ; xyouts,0.8, 0.93, 'Lo-Res: Ozone', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                         xyouts,0.9,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.84,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif   

              endif
endif

;****** PLOT ALL THE CORONAL LIMB PLOTS ******
if (disp_check[1] eq 1) and (disp_check[4] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[2] eq 0) and (disp_check[3] eq 0) and (disp_check[5] eq 0) then begin
   a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,5,1,0,1]
    
              if e_l_r eq 1 then begin        ;echelle limb radiance
                plot,e_limb_radiance[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1, yrange=[min(e_limb_rad_alt[0,*]),max(e_limb_rad_alt[0,*])],$
                    title='Echelle Limb: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_radiance[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor   
              endif
              
              if e_l_h eq 1 then begin        ;echelle limb half int dist
                plot,e_limb_half[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1, yrange=[min(e_limb_rad_alt[0,*]),max(e_limb_rad_alt[0,*])], $
                    title='Echelle Limb: 1/2 Int Dist',xtitle='1/2 Distance', ytitle='Altitude, km'
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_half[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor    
              endif
              
              if l_l_r eq 1 then begin        ;lores limb radiance
                plot,lo_limb_radiance[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                    oplot,lo_limb_radiance[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor    
              endif
    
              if l_l_d eq 1 then begin        ;lores limb density
                plot,lo_limb_density[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Density',xtitle='Density', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                    oplot,lo_limb_density[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor 
              endif
              
              if l_l_s eq 1 then begin        ;lores limb scale
                plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Scale Height',xtitle='Scale Height', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                    oplot,lo_limb_scale[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor      
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                xyouts, 0.5, 0.97, 'Echelle/Lo-Res High Altitude Legend', alignment=0.5, charthick=2.5, charsize=1.5, /normal

                xyouts, 0.08, 0.9, 'E: Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.28, 0.9, 'E: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.48, 0.9, 'Lo: Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.68, 0.9, 'Lo: Density', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.88, 0.9, 'Lo: Scale Height', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                
                      if e_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.03,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.01,leg_i,e_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.01,0.05],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.12,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.05,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_l_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.23,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_limb_half_labels[0,*])-1 do begin
                              xyouts,0.21,leg_i,e_limb_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.21,0.25],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.32,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.25,leg_i-0.02, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.43,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.41,leg_i,lo_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.41,0.45],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.52,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.45,leg_i-0.02, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if l_l_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.63,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                              xyouts,0.61,leg_i,lo_limb_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.61,0.65],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.72,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.65,leg_i-0.02, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_l_s eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.83,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                              xyouts,0.81,leg_i,lo_limb_scale_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.81,0.85],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.92,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.85,leg_i-0.02, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
              endif
endif


;****** PLOT ALL THE CORONAL HIGH ALT PLOTS ******
if (disp_check[2] eq 1) and (disp_check[5] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[1] eq 0) and (disp_check[3] eq 0) and (disp_check[4] eq 0) then begin
   a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,5,1,0,1]
    
              if e_h_r eq 1 then begin        ;echelle high radiance
                plot,e_high_radiance[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(e_high_rad_alt[0,*]),max(e_high_rad_alt[0,*])], $
                    title='Echelle High: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                    oplot,e_high_radiance[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor
              endif
              
              if e_h_h eq 1 then begin        ;echelle high half int dist
                plot,e_high_half[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(e_high_rad_alt[0,*]),max(e_high_rad_alt[0,*])], $
                    title='Echelle High: 1/2 Int Dist',xtitle='1/2 Distance', ytitle='Altitude, km'
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_half_labels[0,*])-1 do begin
                    oplot,e_high_half[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor     
              endif
              
              if l_h_r eq 1 then begin        ;lores high radiance
                plot,lo_high_radiance[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo-Res High: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                    oplot,lo_high_half[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor 
              endif
    
              if l_h_d eq 1 then begin        ;lores high density
                plot,lo_high_density[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo-Res High: Density',xtitle='Density', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor    
              endif
              
              if l_h_h eq 1 then begin        ;lores high half int
                plot,lo_high_half[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo_Res High: 1/2 Int Dist',xtitle='1/2 Dist', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor      
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                xyouts, 0.5, 0.97, 'Echelle/Lo-Res High Altitude Legend', alignment=0.5, charthick=2.5, charsize=1.5, /normal

                xyouts, 0.08, 0.9, 'E: Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.28, 0.9, 'E: 1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.48, 0.9, 'Lo: Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.68, 0.9, 'Lo: Density', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.88, 0.9, 'Lo: Scale Height', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                
                      if e_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.03,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                              xyouts,0.01,leg_i,e_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.01,0.05],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.12,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.05,leg_i-0.02, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.23,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(e_high_half_labels[0,*])-1 do begin
                              xyouts,0.21,leg_i,e_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.21,0.25],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.32,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.25,leg_i-0.02, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.43,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                              xyouts,0.41,leg_i,lo_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.41,0.45],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.52,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.45,leg_i-0.02, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if l_h_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.63,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                              xyouts,0.61,leg_i,lo_high_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.61,0.65],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.72,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.65,leg_i-0.02, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.83,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_high_half_labels[0,*])-1 do begin
                              xyouts,0.81,leg_i,lo_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.81,0.85],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.92,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.85,leg_i-0.02, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
              endif 
              
endif

;****** PLOT ALL THE CORONAL ECHELLE DISK PLOTS ******
if (disp_check[0] eq 1) and $
   (disp_check[1] eq 0) and (disp_check[2] eq 0) and (disp_check[3] eq 0) and (disp_check[4] eq 0) and (disp_check[5] eq 0) then begin
   a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,1,1,0,1]
      if e_d_r eq 1 then begin        ;echelle disk radiance
        plot,e_disk_radiance[0,*],e_disk_timestamp,/nodata,charsize=1.5 ,ystyle=1, title='Echelle Disk: Radiance',xtitle='Time', ytitle='Radiance'
        for i=0, e_disk_total-1 do begin
          oplot,e_disk_radiance[i,*],e_disk_timestamp,linestyle=(i mod 7),color=i*(255/e_disk_total)
        endfor
      endif
      
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                xyouts, 0.5, 0.97, 'Echelle Disk Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.15, 0.9, 'Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal

                      if e_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.10,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(e_disk_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,e_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.25,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,e_disk_total-1 do begin
                              xyouts,0.19,leg_i, time_string(e_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

              endif 
      
endif

;****** PLOT ALL THE CORONAL ECHELLE LIMB PLOTS ******
if (disp_check[1] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[2] eq 0) and (disp_check[3] eq 0) and (disp_check[4] eq 0) and (disp_check[5] eq 0) then begin
    a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,2,1,0,1]
              if e_l_r eq 1 then begin        ;echelle limb radiance
                plot,e_limb_radiance[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1, yrange=[min(e_limb_rad_alt[0,*]),max(e_limb_rad_alt[0,*])],$
                    title='Echelle Limb: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_radiance[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor   
              endif
              
              if e_l_h eq 1 then begin        ;echelle limb half int dist
                plot,e_limb_half[0,0,*],e_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1, yrange=[min(e_limb_rad_alt[0,*]),max(e_limb_rad_alt[0,*])], $
                    title='Echelle Limb: 1/2 Int Dist',xtitle='1/2 Distance', ytitle='Altitude, km'
                for i=0, e_limb_total -1 do begin
                  for j=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                    oplot,e_limb_half[i,j,*],e_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_limb_total)
                  endfor
                endfor    
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                xyouts, 0.5, 0.97, 'Echelle Limb Profile Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.15, 0.9, 'Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.5, 0.9, '1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=2.0, /normal

                      if e_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.10,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(e_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,e_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.25,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.19,leg_i, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_l_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.4,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(e_limb_half_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,e_limb_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.55,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,e_limb_total-1 do begin
                              xyouts,0.49,leg_i, time_string(e_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
              endif 
endif

;****** PLOT ALL THE CORONAL ECHELLE HIGH ALT PLOTS ******
if (disp_check[2] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[1] eq 0) and (disp_check[3] eq 0) and (disp_check[4] eq 0) and (disp_check[5] eq 0) then begin
    a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,2,1,0,1]
     
              if e_h_r eq 1 then begin        ;echelle high radiance
                plot,e_high_radiance[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(e_high_rad_alt[0,*]),max(e_high_rad_alt[0,*])], $
                    title='Echelle High: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                    oplot,e_high_radiance[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor
              endif
              
              if e_h_h eq 1 then begin        ;echelle high half int dist
                plot,e_high_half[0,0,*],e_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(e_high_rad_alt[0,*]),max(e_high_rad_alt[0,*])], $
                    title='Echelle High: 1/2 Int Dist',xtitle='1/2 Distance', ytitle='Altitude, km'
                for i=0, e_high_total -1 do begin
                  for j=0, n_elements(e_high_half_labels[0,*])-1 do begin
                    oplot,e_high_half[i,j,*],e_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/e_high_total)
                  endfor
                endfor     
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata

                xyouts, 0.5, 0.97, 'Echelle High Altitude Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.15, 0.9, 'Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.5, 0.9, '1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=2.0, /normal

                      if e_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.10,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(e_high_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,e_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.25,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.19,leg_i, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if e_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.4,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(e_high_half_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,e_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.55,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,e_high_total-1 do begin
                              xyouts,0.49,leg_i, time_string(e_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/e_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
              endif 
endif

;****** PLOT ALL THE CORONAL LORES DISK PLOTS ******
if (disp_check[3] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[1] eq 0) and (disp_check[2] eq 0) and (disp_check[4] eq 0) and (disp_check[5] eq 0) then begin
    a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,4,1,0,1]
    
              if l_d_r eq 1 then begin        ;lores disk radiance
                plot,lo_disk_radiance[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Radiance',xtitle='Time', ytitle='Radiance'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_radiance[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor    
              endif
              
              if l_d_d eq 1 then begin        ;lores disk density
                plot,lo_disk_dust[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Dust Depth',xtitle='Time', ytitle='Dust Depth'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_dust[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor       
              endif
              
              if l_d_a eq 1 then begin        ;lores disk aurora
                plot,lo_disk_auroral[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Auroral Index',xtitle='Time', ytitle='Auroral Index'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_auroral[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor      
              endif
              
              if l_d_o eq 1 then begin        ;lores disk ozone
                plot,lo_disk_ozone[0,*],lo_disk_timestamp,/nodata,charsize=1.5,ystyle=1,title='Lo_Res Disk: Ozone Depth',xtitle='Time', ytitle='Ozone Depth'
                for i=0, lo_disk_total-1 do begin
                  oplot,lo_disk_ozone[i,*],lo_disk_timestamp,linestyle=(i mod 7),color=i*(255/lo_disk_total)
                endfor     
              endif
              
              if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata
                
                xyouts, 0.5, 0.97, 'Lo-Res Disk Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.10, 0.9, 'Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.35, 0.9, 'Dust Depth', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.60, 0.9, 'Auroral Index', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.85, 0.9, 'Ozone Index', alignment=0.5, charthick=2.0, charsize=2.0, /normal


                      if l_d_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.05,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for i=0, n_elements(lo_disk_labels[0,*])-1 do begin
                              xyouts,0.04,leg_i,lo_disk_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.02,0.07],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.15,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                         for j=0,lo_disk_total-1 do begin
                              xyouts,0.10,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 
                      
                      if l_d_d eq 1 then begin
                         ;xyouts,0.4, 0.93, 'Lo-Res: Dust Depth', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                         xyouts,0.35,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.29,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                       if l_d_a eq 1 then begin
                        ; xyouts,0.6, 0.93, 'Lo-Res: Auroral Index', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                         xyouts,0.60,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.55,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_d_o eq 1 then begin
                        ; xyouts,0.8, 0.93, 'Lo-Res: Ozone', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                         xyouts,0.85,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=1.5,/normal
                           for j=0,lo_disk_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_disk_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_disk_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif   


              endif
              
endif

;****** PLOT ALL THE CORONAL LORES LIMB PLOTS ******
if (disp_check[4] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[1] eq 0) and (disp_check[2] eq 0) and (disp_check[3] eq 0) and (disp_check[5] eq 0) then begin
    a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,3,1,0,1]
    
              if l_l_r eq 1 then begin        ;lores limb radiance
                plot,lo_limb_radiance[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                    oplot,lo_limb_radiance[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor    
              endif
    
              if l_l_d eq 1 then begin        ;lores limb density
                plot,lo_limb_density[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Density',xtitle='Density', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                    oplot,lo_limb_density[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor 
              endif
              
              if l_l_s eq 1 then begin        ;lores limb scale
                plot,lo_limb_scale[0,0,*],lo_limb_rad_alt[0,*],/nodata,charsize=1.5,ystyle=1,yrange=[min(lo_limb_rad_alt[0,*]),max(lo_limb_rad_alt[0,*])], $
                    title='Lo_Res Limb: Scale Height',xtitle='Scale Height', ytitle='Altitude, km'
                for i=0, lo_limb_total -1 do begin
                  for j=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                    oplot,lo_limb_scale[i,j,*],lo_limb_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_limb_total)
                  endfor
                endfor      
              endif
              
             if keyword_set(nolegend) eq 0 then begin
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata

                xyouts, 0.5, 0.97, 'Lo-Res Limb Profile Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.15, 0.9, 'Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.5, 0.9, 'Density', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.8, 0.9, 'Scale Height', alignment=0.5, charthick=2.0, charsize=2.0, /normal

                      if l_l_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.10,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,lo_limb_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.25,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.19,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if l_l_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.4,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_den_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,lo_limb_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.55,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.49,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_l_s eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.7,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_limb_scale_labels[0,*])-1 do begin
                              xyouts,0.69,leg_i,lo_limb_scale_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.67,0.72],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.85,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_limb_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_limb_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_limb_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif

              endif              
endif

;****** PLOT ALL THE CORONAL LROES HIGH ALT PLOTS ******
if (disp_check[5] eq 1) and $
   (disp_check[0] eq 0) and (disp_check[1] eq 0) and (disp_check[2] eq 0) and (disp_check[3] eq 0) and (disp_check[4] eq 0) then begin
    a=get_screen_size()
       if keyword_set(save_window) then begin
          window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
       endif else begin
          window,0,xsize=a[0]*0.5,ysize=a[1]*0.5
       endelse
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    !p.multi=[0,3,1,0,1]
    
              if l_h_r eq 1 then begin        ;lores high radiance
                plot,lo_high_radiance[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo-Res High: Radiance',xtitle='Radiance', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                    oplot,lo_high_half[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor 
              endif
    
              if l_h_d eq 1 then begin        ;lores high density
                plot,lo_high_density[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo-Res High: Density',xtitle='Density', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor    
              endif
              
              if l_h_h eq 1 then begin        ;lores high half int
                plot,lo_high_half[0,0,*],lo_high_rad_alt[0,*],/nodata,charsize=1.5,/ylog,ystyle=1,yrange=[min(lo_high_rad_alt[0,*]),max(lo_high_rad_alt[0,*])], $
                    title='Lo_Res High: 1/2 Int Dist',xtitle='1/2 Dist', ytitle='Altitude, km'
                for i=0, lo_high_total -1 do begin
                  for j=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                    oplot,lo_high_density[i,j,*],lo_high_rad_alt[i,*],linestyle=(i mod 7),color=i*(255/lo_high_total)
                  endfor
                endfor      
              endif
              
              if keyword_set(nolegend) eq 0 then begin              
                if keyword_set(save_window) then begin
                    window,!window+1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endif else begin
                    window,1,xsize=a[0]*0.5,ysize=a[1]*0.5
                 endelse
                device,decomposed=0
                plot,[0,0],[1,1], color=255, background=255, /nodata

                xyouts, 0.5, 0.97, 'Lo-Res High Altitude Legend', alignment=0.5, charthick=2.5, charsize=2.0, /normal

                xyouts, 0.15, 0.9, 'Radiance', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.5, 0.9, 'Density', alignment=0.5, charthick=2.0, charsize=2.0, /normal
                xyouts, 0.8, 0.9, '1/2 Int Dist', alignment=0.5, charthick=2.0, charsize=2.0, /normal

                      if l_h_r eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.10,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_rad_labels[0,*])-1 do begin
                              xyouts,0.09,leg_i,lo_high_rad_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.07,0.12],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.25,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.19,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif 

                      if l_h_d eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.4,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_den_labels[0,*])-1 do begin
                              xyouts,0.39,leg_i,lo_high_den_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.37,0.42],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.55,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.49,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif
                      
                      if l_h_h eq 1 then begin
                       ;  xyouts,0.4, 0.93, 'Lo-Res: Radiance', alignment=0, charthick=1.5, charsize=1.5, /normal
                         leg_i=0.8
                          xyouts,0.7,leg_i+0.05,'Species', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for i=0, n_elements(lo_high_half_labels[0,*])-1 do begin
                              xyouts,0.69,leg_i,lo_high_half_labels[0,i],alignment=0, charthick=1.5, charsize=1.5, /normal
                              plots,[0.67,0.72],[leg_i-0.02,leg_i-0.02], linestyle=(i mod 7), thick=2, /normal
                            leg_i=leg_i-0.07
                        endfor
                          leg_i=0.8
                          xyouts,0.85,leg_i+.05,'Observation', alignment=0.5, charthick=1.5, charsize=2.0,/normal
                         for j=0,lo_high_total-1 do begin
                              xyouts,0.79,leg_i, time_string(lo_high_timestamp[j]), alignment=0, charthick=1, charsize=1, /normal,color=j*(255/lo_high_total)
                              leg_i=leg_i-0.07
                          endfor 
                      endif

              endif
    
endif

end