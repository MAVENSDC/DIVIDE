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


@mvn_kp_range
@mvn_kp_range_select

pro MVN_KP_STANDARDS, kp_data, $
                      time = time, $
                      range = range, $
                      all = all, $
                      euv = euv, $
                      mag_mso = mag_mso, $
                      mag_geo = mag_geo, $
                      mag_cone = mag_cone, $
                      mag_dir = mag_dir, $
                      ngims_neutral = ngims_neutral, $
                      ngims_ions = ngims_ions, $
                      eph_angle = eph_angle, $
                      eph_geo = eph_geo, $
                      eph_mso = eph_mso, $
                      swea = swea, $
                      sep_ion = sep_ion, $
                      sep_electron = sep_electron, $
                      wave = wave, $
                      plasma_den = plasma_den, $
                      plasma_temp = plasma_temp, $
                      swia_h_vel = swia_h_vel, $
                      static_h_vel = static_h_vel, $
                      static_o2_vel = static_o2_vel, $
                      static_flux = static_flux, $
                      static_energy = static_energy, $
                      sun_bar = sun_bar, $
                      solar_wind = solar_wind, $
                      ionosphere = ionosphere, $
                      sc_pot = sc_pot, $
                      altitude = altitude, $
                      title = title,$
                      colortable = colortable

  ;IF /ALL IS CALLED, SET EVERY KEYWORD TO ACTIVE SO ALL PLOTS ARE CREATED

  if keyword_set(all) then begin
    euv = 1
    mag_mso = 1
    mag_geo = 1
    mag_cone = 1
    mag_dir = 1
    ngims_neutral = 1
    ngims_ions = 1
    eph_angle = 1
    eph_geo = 1
    eph_mso = 1
    swea = 1
    sep_ion = 1
    sep_electron = 1
    wave = 1
    plasma_den = 1
    plasma_temp = 1
    swia_h_vel = 1
    static_h_vel = 1
    static_o2_vel = 1
    static_flux = 1
    static_energy = 1
    sun_bar = 1
    solar_wind = 1
    ionosphere = 1
    sc_pot = 1
  endif

  ;PULL OUT THE INCLUDED TAGS
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    return
  endif                      
                      
   ;set the default colors
    device,decompose=0
    !p.background='FFFFFF'x
    !p.color=0
    if keyword_set(colortable) then begin
      loadct,colortable,/silent
    endif else begin
      loadct,39,/silent
    endelse

  if keyword_set(title) then begin
    overall_title=title
  endif else begin
    overall_title=''
  endelse


  ;IF THE USER SUPPLIES A TIME RANGE, SET THE BEGINNING AND END INDICES
  
  if keyword_set(time) then begin     ;determine the start and end indices to plot
    MVN_KP_RANGE_SELECT, kp_data, time, kp_start_index, kp_end_index
  endif else begin                    ;otherwise plot all data within structure
   kp_start_index = 0
   kp_end_index = n_elements(kp_data.orbit)-1
  endelse


  plot_count = 0
  tplot_2plot = strarr(26)
  lin_log = intarr(26)          ;0=Linear, 1 =Log
  
  if keyword_set(euv) then begin
    euv_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 3)
    euv_v= findgen(3)*(255./3.)
    euv_labels = ['Low','Mid','Lyman-Alpha']
    
    t1 = where(base_tags eq 'LPW')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'EUV_IRRADIANCE_LOW')
        if t2 ne -1 then euv_data[*,0] = kp_data[kp_start_index:kp_end_index].lpw.euv_irradiance_low
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'EUV_IRRADIANCE_MID')
        if t2 ne -1 then euv_data[*,1] = kp_data[kp_start_index:kp_end_index].lpw.euv_irradiance_mid
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'EUV_IRRADIANCE_LYMAN')
        if t2 ne -1 then euv_data[*,2] = kp_data[kp_start_index:kp_end_index].lpw.euv_irradiance_lyman
      store_data,'EUV',data={x:kp_data[kp_start_index:kp_end_index].time, y:euv_data, v:euv_v}, dlim={labels:euv_labels},verbose=0
      options,'EUV','labflag',-1
      
      
      tplot_2plot[plot_count] = 'EUV'
      lin_log[plot_count] = 0
      plot_count = plot_count+1
    endif
  endif

  if keyword_set(mag_mso) then begin
    mag_mso_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    mag_mso_v= findgen(4)*(255./3.)
    mag_mso_labels = ['X','Y','Z','Magnitude']
    
    t1 = where(base_tags eq 'MAG')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_X')
        if t2 ne -1 then mag_mso_data[*,0] = kp_data[kp_start_index:kp_end_index].mag.mso_x
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Y')
        if t2 ne -1 then mag_mso_data[*,1] = kp_data[kp_start_index:kp_end_index].mag.mso_y
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Z')
        if t2 ne -1 then mag_mso_data[*,2] = kp_data[kp_start_index:kp_end_index].mag.mso_z
      mag_mso_data[*,3] = sqrt((kp_data[kp_start_index:kp_end_index].mag.mso_x^2)+(kp_data[kp_start_index:kp_end_index].mag.mso_y^2)+(kp_data[kp_start_index:kp_end_index].mag.mso_z^2))
      store_data,'MAG_MSO',data={x:kp_data[kp_start_index:kp_end_index].time, y:mag_mso_data, v:mag_mso_v}, dlim={labels:mag_mso_labels},verbose=0
      options,'MAG_MSO','labflag',0
      
      tplot_2plot[plot_count] = 'MAG_MSO'
      lin_log[plot_count] = 0
      plot_count = plot_count+1
    endif
  endif

  if keyword_set(mag_geo) then begin
    mag_geo_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    mag_geo_v= findgen(4)*(255./3.)
    mag_geo_labels = ['X','Y','Z','Magnitude']
    
    t1 = where(base_tags eq 'MAG')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_X')
        if t2 ne -1 then mag_geo_data[*,0] = kp_data[kp_start_index:kp_end_index].mag.geo_x
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_Y')
        if t2 ne -1 then mag_geo_data[*,1] = kp_data[kp_start_index:kp_end_index].mag.geo_y
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_Z')
        if t2 ne -1 then mag_geo_data[*,2] = kp_data[kp_start_index:kp_end_index].mag.geo_z
      mag_geo_data[*,3] = sqrt((kp_data[kp_start_index:kp_end_index].mag.geo_x^2)+(kp_data[kp_start_index:kp_end_index].mag.geo_y^2)+(kp_data[kp_start_index:kp_end_index].mag.geo_z^2))
      store_data,'MAG_GEO',data={x:kp_data[kp_start_index:kp_end_index].time, y:mag_geo_data, v:mag_geo_v}, dlim={labels:mag_geo_labels},verbose=0
      options,'MAG_GEO','labflag',-1
      
      tplot_2plot[plot_count] = 'MAG_GEO'
      lin_log[plot_count] = 0
      plot_count = plot_count+1
    endif
  endif

  if keyword_set(mag_cone) then begin
    mag_cone_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time),2)
    mag_cone_v = findgen(2)*(255./2.)
    mag_cone_labels = ['Clock Angle','Cone Angle']
    
    t1 = where(base_tags eq 'MAG')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_X')
      if t2 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Y')
          if t2 ne 01 then mag_cone_data[*,0] = atan(kp_data[kp_start_index:kp_end_index].mag.mso_x, kp_data[kp_start_index:kp_end_index].mag.mso_y) * !radeg
      endif
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_X')
      if t2 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Y')
        if t2 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Z')
            if t2 ne -1 then mag_cone_data[*,1] = acos((abs(kp_data[kp_start_index:kp_end_index].mag.mso_x)/(sqrt((kp_data[kp_start_index:kp_end_index].mag.mso_x^2)+$
                                                  (kp_data[kp_start_index:kp_end_index].mag.mso_y^2)+(kp_data[kp_start_index:kp_end_index].mag.mso_z^2))))) * !radeg
        endif
      endif
      store_data,'MAG_CONE',data={x:kp_data[kp_start_index:kp_end_index].time, y: mag_cone_data, v:mag_cone_v}, dlim={labels:mag_cone_labels}, verbose=0
      options, 'MAG_CONE','labflag',-1
      
      tplot_2plot[plot_count] = 'MAG_CONE'
      lin_log[plot_count] = 0
      plot_count = plot_count+1                  
    endif                         
  endif

  if keyword_set(mag_dir) then begin         
       mag_dir_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time),3)
       mag_dir_v = findgen(3)*(255./2.)
       mag_dir_labels = ['Radial', 'Eastward', 'Northward']
       
    t1 = where(base_tags eq 'SPACECRAFT')
    if t1 ne -1 then begin
 
    ;ROUTINE TO CALCULATE RADIAL, HORIZONTAL, EASTWARD, AND NORTHWARD COMPONENTS ADAPTED FROM DAVE BRAIN
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SUB_SC_LONGITUDE')
       if t2 ne -1 then begin
         clon = cos( kp_data[kp_start_index:kp_end_index].spacecraft.SUB_SC_LONGITUDE *(!pi/180.))
         slon = sin( kp_data[kp_start_index:kp_end_index].spacecraft.SUB_SC_LONGITUDE *(!pi/180.))
       endif else begin
        clon = 0.0
        slon = 0.0
       endelse
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SUB_SC_LATITUDE')
        if t2 ne -1 then begin
         clat = cos( kp_data[kp_start_index:kp_end_index].spacecraft.SUB_SC_LATITUDE *(!pi/180.))
         slat = sin( kp_data[kp_start_index:kp_end_index].spacecraft.SUB_SC_LATITUDE *(!pi/180.))
       endif else begin
         clat = 0.0
         slat = 0.0
       endelse
         
       ;;;;;; Transformation Matrix ;;;;;;;
       ;                                  ;
       ;   clon*clat    slon*clat   slat  ;
       ;                                  ;
       ;       -slon         clon      0  ;
       ;                                  ;
       ;  -clon*slat   -slon*slat   clat  ;
       ;                                  ;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       t1 = where(base_tags eq 'MAG')
       if t1 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_X')
        if t2 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_Y')
          if t2 ne -1 then begin
            t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_Z')
            if t2 ne -1 then begin
             mag_dir_data[*,0] = kp_data[kp_start_index:kp_end_index].mag.geo_x * clon*clat  +  $
                  kp_data[kp_start_index:kp_end_index].mag.geo_y * slon*clat  +  $
                  kp_data[kp_start_index:kp_end_index].mag.geo_z * slat
             mag_dir_data[*,1] = kp_data[kp_start_index:kp_end_index].mag.geo_y * clon       -  $
                  kp_data[kp_start_index:kp_end_index].mag.geo_x * slon 
             mag_dir_data[*,2] = kp_data[kp_start_index:kp_end_index].mag.geo_z * clat       -  $
                  kp_data[kp_start_index:kp_end_index].mag.geo_x * clon*slat  -  $
                  kp_data[kp_start_index:kp_end_index].mag.geo_y * slon*slat
             store_data,'MAG_DIR',data={x:kp_data[kp_start_index:kp_end_index].time, y:mag_dir_data, v:mag_dir_v}, dlim={labels:mag_dir_labels, ylog:0}, verbose=0
             options,'MAG_DIR','labflag',-1
             
             tplot_2plot[plot_count] = 'MAG_DIR'
             lin_log[plot_count] = 1
             plot_count = plot_count + 1  
            endif
          endif
        endif
       endif
    endif       ;T1
  endif

  if keyword_set(ngims_neutral) then begin
    ngims_neutral_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 7)
    ngims_neutral_v= findgen(7)*(255./6.)
    ngims_neutral_labels = ['He','O','CO','N2','NO','AR','CO2']
    
    t1 = where(base_tags eq 'NGIMS')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HE_DENSITY')
        if t2 ne -1 then ngims_neutral_data[*,0] = kp_data[kp_start_index:kp_end_index].ngims.he_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O_DENSITY')
        if t2 ne -1 then ngims_neutral_data[*,1] = kp_data[kp_start_index:kp_end_index].ngims.o_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CO_DENSITY')
        if t2 ne -1 then ngims_neutral_data[*,2] = kp_data[kp_start_index:kp_end_index].ngims.co_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'N2_DENSITY')
        if t2 ne -1 then ngims_neutral_data[*,3] = kp_data[kp_start_index:kp_end_index].ngims.n2_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'NO_DENSITY')  
        if t2 ne -1 then ngims_neutral_data[*,4] = kp_data[kp_start_index:kp_end_index].ngims.no_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'AR_DENSITY')
        if t2 ne -1 then ngims_neutral_data[*,5] = kp_data[kp_start_index:kp_end_index].ngims.ar_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CO2_DENSITY')
        if t2 ne -1 then ngims_neutral_data[*,6] = kp_data[kp_start_index:kp_end_index].ngims.co2_density
      store_data,'NGIMS_NEUTRAL',data={x:kp_data[kp_start_index:kp_end_index].time, y:ngims_neutral_data, v:ngims_neutral_v}, dlim={labels:ngims_neutral_labels, ylog:1, ytitle:'Density'},verbose=0
      options,'NGIMS_NEUTRAL','labflag',-1                                  
                                       
      tplot_2plot[plot_count] = 'NGIMS_NEUTRAL'
      lin_log[plot_count] = 1
      plot_count = plot_count + 1           
    endif                       
  endif

  if keyword_set(ngims_ions) then begin                                     
    ngims_ions_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 8)
    ngims_ions_v= findgen(8)*(255./7.)
    ngims_ions_labels = ['O2+','CO2+','NO+','O+','CO+/N2+','C+','OH+','N+']
    
    t1 = where(base_tags eq 'NGIMS')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,0] = kp_data[kp_start_index:kp_end_index].ngims.o2plus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CO2PLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,1] = kp_data[kp_start_index:kp_end_index].ngims.co2plus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'NOPLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,2] = kp_data[kp_start_index:kp_end_index].ngims.noplus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'OPLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,3] = kp_data[kp_start_index:kp_end_index].ngims.oplus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CONPLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,4] = kp_data[kp_start_index:kp_end_index].ngims.conplus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CPLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,5] = kp_data[kp_start_index:kp_end_index].ngims.cplus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'OHPLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,6] = kp_data[kp_start_index:kp_end_index].ngims.ohplus_density
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'NPLUS_DENSITY')
        if t2 ne -1 then ngims_ions_data[*,7] = kp_data[kp_start_index:kp_end_index].ngims.nplus_density
      store_data,'NGIMS_IONS',data={x:kp_data[kp_start_index:kp_end_index].time, y:ngims_ions_data, v:ngims_ions_v}, dlim={labels:ngims_ions_labels, ylog:1, ytitle:'Density'},verbose=0
      options,'NGIMS_IONS','labflag',-1                                 
                                       
      tplot_2plot[plot_count] = 'NGIMS_IONS'
      lin_log[plot_count] = 1
      plot_count = plot_count + 1  
    endif                                
  endif

  if keyword_set(eph_angle) then begin
    eph_angle_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 7)
    eph_v= findgen(7)*(255./6.)
    eph_labels = ['Sub-SC Long','Sub-SC Lat','SZA','Local Time','Mars Season','Sub-Solar Long','Sub-Solar Lat']
    
    t1 = where(base_tags eq 'SPACECRAFT')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SUB_SC_LONGITUDE')
        if t2 ne -1 then eph_angle_data[*,0] = kp_data[kp_start_index:kp_end_index].spacecraft.sub_sc_longitude
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SUB_SC_LATITUDE')
        if t2 ne -1 then eph_angle_data[*,1] = kp_data[kp_start_index:kp_end_index].spacecraft.sub_sc_latitude
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SZA')
        if t2 ne -1 then eph_angle_data[*,2] = kp_data[kp_start_index:kp_end_index].spacecraft.sza
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'LOCAL_TIME')  
        if t2 ne -1 then eph_angle_data[*,3] = kp_data[kp_start_index:kp_end_index].spacecraft.local_time
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MARS_SEASON')  
        if t2 ne -1 then eph_angle_data[*,4] = kp_data[kp_start_index:kp_end_index].spacecraft.mars_season
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SUBSOLAR_POINT_GEO_LONGITUDE')
        if t2 ne -1 then eph_angle_data[*,5] = kp_data[kp_start_index:kp_end_index].spacecraft.subsolar_point_GEO_longitude
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SUBSOLAR_POINT_GEO_LATITUDE')
        if t2 ne -1 then eph_angle_data[*,6] = kp_data[kp_start_index:kp_end_index].spacecraft.subsolar_point_GEO_latitude
      store_data,'EPH_ANGLE',data={x:kp_data[kp_start_index:kp_end_index].time, y:eph_angle_data, v:eph_v}, dlim={labels:eph_labels},verbose=0
      options,'EPH_ANGLE','labflag',-1                                 
  
      tplot_2plot[plot_count] = 'EPH_ANGLE'
      lin_log[plot_count] = 0
      plot_count = plot_count + 1       
    endif                          
  endif

  if keyword_set(eph_geo) then begin
    eph_geo_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    eph_geo_v= findgen(4)*(255./3.)
    eph_geo_labels = ['GEO_X','GEO_Y','GEO_Z','Altitude']
    
    t1 = where(base_tags eq 'SPACECRAFT')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_X')
        if t2 ne -1 then eph_geo_data[*,0] = kp_data[kp_start_index:kp_end_index].spacecraft.geo_x
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_Y')
        if t2 ne -1 then eph_geo_data[*,1] = kp_data[kp_start_index:kp_end_index].spacecraft.geo_y
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'GEO_Z')
        if t2 ne -1 then eph_geo_data[*,2] = kp_data[kp_start_index:kp_end_index].spacecraft.geo_z
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ALTITUDE')
        if t2 ne -1 then eph_geo_data[*,3] = kp_data[kp_start_index:kp_end_index].spacecraft.altitude
      store_data,'EPH_GEO',data={x:kp_data[kp_start_index:kp_end_index].time, y:eph_geo_data, v:eph_geo_v}, dlim={labels:eph_geo_labels},verbose=0
      options,'EPH_GEO','labflag',-1                                 
      
      tplot_2plot[plot_count] = 'EPH_GEO'
      lin_log[plot_count] = 0
      plot_count = plot_count + 1
    endif                                  
  endif

  if keyword_set(eph_mso) then begin 
    eph_mso_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    eph_mso_v= findgen(4)*(255./3.)
    eph_mso_labels = ['MSO_X','MSO_Y','MSO_Z','Altitude']
    
    t1 = where(base_tags eq 'SPACECRAFT')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_X')
        if t2 ne -1 then eph_mso_data[*,0] = kp_data[kp_start_index:kp_end_index].spacecraft.mso_x
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Y')
        if t2 ne -1 then eph_mso_data[*,1] = kp_data[kp_start_index:kp_end_index].spacecraft.mso_y  
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Z')
        if t2 ne -1 then eph_mso_data[*,2] = kp_data[kp_start_index:kp_end_index].spacecraft.mso_z
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ALTITUDE')
        if t2 ne -1 then eph_mso_data[*,3] = kp_data[kp_start_index:kp_end_index].spacecraft.altitude
      store_data,'EPH_MSO',data={x:kp_data[kp_start_index:kp_end_index].time, y:eph_mso_data, v:eph_mso_v}, dlim={labels:eph_mso_labels},verbose=0
      options,'EPH_MSO','labflag',-1      
      
      tplot_2plot[plot_count] = 'EPH_MSO'
      lin_log[plot_count] = 0
      plot_count = plot_count + 1  
    endif                                
  endif

  if keyword_set(swea) then begin
    swea_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 7)
    swea_v= findgen(7)*(255./6.)
    swea_labels = ['Parallel Low','Parallel Mid','Parallel High','AntiParallel Low','AntiParallel Mid','AntiParallel High','Spectrum Shape']
    
    t1 = where(base_tags eq 'SWEA')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_PARALLEL_FLUX_LOW')
        if t2 ne -1 then swea_data[*,0] = kp_data[kp_start_index:kp_end_index].swea.electron_parallel_flux_low
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_PARALLEL_FLUX_MID')
        if t2 ne -1 then swea_data[*,1] = kp_data[kp_start_index:kp_end_index].swea.electron_parallel_flux_mid
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_PARALLEL_FLUX_HIGH')
        if t2 ne -1 then swea_data[*,2] = kp_data[kp_start_index:kp_end_index].swea.electron_parallel_flux_high
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ANTIPARALLEL_FLUX_LOW')
        if t2 ne -1 then swea_data[*,3] = kp_data[kp_start_index:kp_end_index].swea.electron_antiparallel_flux_low
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ANTIPARALLEL_FLUX_MID')
        if t2 ne -1 then swea_data[*,4] = kp_data[kp_start_index:kp_end_index].swea.electron_antiparallel_flux_mid
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ANTIPARALLEL_FLUX_HIGH')
        if t2 ne -1 then swea_data[*,5] = kp_data[kp_start_index:kp_end_index].swea.electron_antiparallel_flux_high
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_SPECTRUM_SHAPE')
        if t2 ne -1 then swea_data[*,6] = kp_data[kp_start_index:kp_end_index].swea.electron_spectrum_shape
      store_data,'SWEA',data={x:kp_data[kp_start_index:kp_end_index].time, y:swea_data, v:swea_v}, dlim={labels:swea_labels},verbose=0
      options,'SWEA','labflag',-1                                          
                                       
      tplot_2plot[plot_count] = 'SWEA'
      lin_log[plot_count] = 0
      plot_count = plot_count + 1
    endif                                  
  endif


  if keyword_set(sep_ion) then begin
    sep_ion_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 5)
    sep_ion_v= findgen(5)*(255./4.)
    sep_ion_labels = ['1 Front','1 Back','2 Front','2 Back','Sum']
    
    t1 = where(base_tags eq 'SEP')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ION_ENERGY_FLUX_1_FRONT')
        if t2 ne -1 then sep_ion_data[*,0] = kp_data[kp_start_index:kp_end_index].sep.ion_energy_flux_1_front
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ION_ENERGY_FLUX_1_BACK')
        if t2 ne -1 then sep_ion_data[*,1] = kp_data[kp_start_index:kp_end_index].sep.ion_energy_flux_1_back
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ION_ENERGY_FLUX_2_FRONT')
        if t2 ne -1 then sep_ion_data[*,2] = kp_data[kp_start_index:kp_end_index].sep.ion_energy_flux_2_front
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ION_ENERGY_FLUX_2_BACK')
        if t2 ne -1 then sep_ion_data[*,3] = kp_data[kp_start_index:kp_end_index].sep.ion_energy_flux_2_back
      sep_ion_data[*,4] = total(sep_ion_data[*,0:3])
      store_data,'SEP_ION',data={x:kp_data[kp_start_index:kp_end_index].time, y:sep_ion_data, v:sep_ion_v}, dlim={labels:sep_ion_labels, ytitle:'Ion Energy Flux'},verbose=0
      options,'SEP_ION','labflag',-1        
      
      tplot_2plot[plot_count] = 'SEP_ION'
      lin_log[plot_count] = 0
      plot_count = plot_count + 1
    endif                                  
  endif

  if keyword_set(sep_electron) then begin
    sep_electron_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 5)
    sep_electron_v= findgen(5)*(255./4.)
    sep_electron_labels = ['1 Front','1 Back','2 Front','2 Back','Sum']
    
    t1 = where(base_tags eq 'SEP')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ENERGY_FLUX_1_FRONT')
        if t2 ne -1 then sep_electron_data[*,0] = kp_data[kp_start_index:kp_end_index].sep.electron_energy_flux_1_front
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ENERGY_FLUX_1_BACK')
        if t2 ne -1 then sep_electron_data[*,1] = kp_data[kp_start_index:kp_end_index].sep.electron_energy_flux_1_back
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ENERGY_FLUX_2_FRONT')
        if t2 ne -1 then sep_electron_data[*,2] = kp_data[kp_start_index:kp_end_index].sep.electron_energy_flux_2_front
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_ENERGY_FLUX_2_BACK')    
        if t2 ne -1 then sep_electron_data[*,3] = kp_data[kp_start_index:kp_end_index].sep.electron_energy_flux_2_back
      sep_electron_data[*,4] = total(sep_electron_data[*,0:3])
      store_data,'SEP_ELECTRON',data={x:kp_data[kp_start_index:kp_end_index].time, y:sep_electron_data, v:sep_electron_v}, dlim={labels:sep_electron_labels, ytitle:'Electron Energy Flux'},verbose=0
      options,'SEP_ELECTRON','labflag',-1   
      
      tplot_2plot[plot_count] = 'SEP_ELECTRON'
      lin_log[plot_count] = 0
      plot_count = plot_count + 1  
    endif                                
  endif

  if keyword_set(wave) then begin
    wave_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    wave_v= findgen(4)*(255./3.)
    wave_labels = ['Low','Mid','High','MAG RMS']
    
    t1 = where(base_tags eq 'LPW')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'EWAVE_LOW')
        if t2 ne -1 then wave_data[*,0] = kp_data[kp_start_index:kp_end_index].lpw.ewave_low
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'EWAVE_MID')
        if t2 ne -1 then wave_data[*,1] = kp_data[kp_start_index:kp_end_index].lpw.ewave_mid
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'EWAVE_HIGH')
        if t2 ne -1 then wave_data[*,2] = kp_data[kp_start_index:kp_end_index].lpw.ewave_high
      t1 = where(base_tags eq 'MAG')
        if t1 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'RMS')
          if t2 ne -1 then wave_data[*,3] = kp_data[kp_start_index:kp_end_index].mag.rms
        endif
      store_data,'WAVE',data={x:kp_data[kp_start_index:kp_end_index].time, y:wave_data, v:wave_v}, dlim={labels:wave_labels, ylog:1},verbose=0
      options,'WAVE','labflag',-1       
      
      tplot_2plot[plot_count] = 'WAVE'
      lin_log[plot_count] = 1
      plot_count = plot_count + 1     
    endif                             
  endif

  if keyword_set(plasma_den) then begin
    plasma_den_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 6)
    plasma_den_v= findgen(6)*(255./5.)
    plasma_den_labels = ['Electron','Solarwind Electron','SWIA H+','STATIC CO2+','O+','O2+']
    
    t1 = where(base_tags eq 'LPW')
      if t1 ne -1 then begin 
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_DENSITY')
        if t2 ne -1 then plasma_den_data[*,0] = kp_data[kp_start_index:kp_end_index].lpw.electron_density
      endif
    t1 = where(base_tags eq 'SWEA')
      if t1 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SOLARWIND_E_DENSITY')
        if t2 ne -1 then plasma_den_data[*,1] = kp_data[kp_start_index:kp_end_index].swea.solarwind_e_density
      endif
    t1 = where(base_tags eq 'SWIA')
      if t1 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_DENSITY')
        if t2 ne -1 then plasma_den_data[*,2] = kp_data[kp_start_index:kp_end_index].swia.hplus_density
      endif
    t1 = where(base_tags eq 'STATIC')
      if t1 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CO2PLUS_DENSITY')
          if t2 ne -1 then plasma_den_data[*,3] = kp_data[kp_start_index:kp_end_index].static.co2plus_density
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'OPLUS_DENSITY')
          if t2 ne -1 then plasma_den_data[*,4] = kp_data[kp_start_index:kp_end_index].static.oplus_density
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_DENSITY')
          if t2 ne -1 then plasma_den_data[*,5] = kp_data[kp_start_index:kp_end_index].static.o2plus_density
       endif
    store_data,'PLASMA_DEN',data={x:kp_data[kp_start_index:kp_end_index].time, y:plasma_den_data, v:plasma_den_v}, dlim={labels:plasma_den_labels, ytitle:'Density', ylog:1},verbose=0
    options,'PLASMA_DEN','labflag',-1        
    
    tplot_2plot[plot_count] = 'PLASMA_DEN'
    lin_log[plot_count] = 1
    plot_count = plot_count + 1                                  
  endif

  if keyword_set(plasma_temp) then begin
    plasma_temp_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 6)
    plasma_temp_v= findgen(6)*(255./5.)
    plasma_temp_labels = ['Electron','Solarwind Electron','SWIA H+','STATIC CO2+','O+','O2+']
    
    t1 = where(base_tags eq 'LPW')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'ELECTRON_TEMPERATURE')
        if t2 ne -1 then plasma_temp_data[*,0] = kp_data[kp_start_index:kp_end_index].lpw.electron_temperature
    endif
    t1 = where(base_tags eq 'SWEA')
    if t1 ne -1 then begin
       t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SOLARWIND_E_TEMPERATURE')
       if t2 ne -1 then plasma_temp_data[*,1] = kp_data[kp_start_index:kp_end_index].swea.solarwind_e_temperature
    endif
    t1 = where(base_tags eq 'SWIA')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_TEMPERATURE')
      if t2 ne -1 then plasma_temp_data[*,2] = kp_data[kp_start_index:kp_end_index].swia.hplus_temperature
    endif
    t1 = where(base_tags eq 'STATIC')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'CO2PLUS_TEMPERATURE')
        if t2 ne -1 then plasma_temp_data[*,3] = kp_data[kp_start_index:kp_end_index].static.CO2plus_temperature
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'OPLUS_TEMPERATURE')
        if t2 ne -1 then plasma_temp_data[*,4] = kp_data[kp_start_index:kp_end_index].static.oplus_temperature
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_TEMPERATURE')
        if t2 ne -1 then plasma_temp_data[*,5] = kp_data[kp_start_index:kp_end_index].static.o2plus_temperature
    endif
    store_data,'PLASMA_TEMP',data={x:kp_data[kp_start_index:kp_end_index].time, y:plasma_temp_data, v:plasma_temp_v}, dlim={labels:plasma_temp_labels, ytitle:'Temperature', ylog:1},verbose=0
    options,'PLASMA_TEMP','labflag',-1     
    
    tplot_2plot[plot_count] = 'PLASMA_TEMP'
    lin_log[plot_count] = 1
    plot_count = plot_count + 1                                  
  endif

  if keyword_set(swia_h_vel) then begin
    swia_h_vel_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    swia_h_vel_v= findgen(4)*(255./3.)
    swia_h_vel_labels = ['X','Y','Z','Magnitude']
    
    t1 = where(base_tags eq 'SWIA')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_FLOW_V_MSOX')
        if t2 ne -1 then swia_h_vel_data[*,0] = kp_data[kp_start_index:kp_end_index].swia.hplus_flow_v_msox
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_FLOW_V_MSOY')
        if t2 ne -1 then swia_h_vel_data[*,1] = kp_data[kp_start_index:kp_end_index].swia.hplus_flow_v_msoy
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_FLOW_V_MSOZ')
        if t2 ne -1 then swia_h_vel_data[*,2] = kp_data[kp_start_index:kp_end_index].swia.hplus_flow_v_msoz
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_FLOW_V_MSOX')
      if t2 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_FLOW_V_MSOY')
        if t2 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_FLOW_V_MSOZ')
          if t2 ne -1 then swia_h_vel_data[*,3] = sqrt((kp_data[kp_start_index:kp_end_index].swia.hplus_flow_v_msox^2)+(kp_data[kp_start_index:kp_end_index].swia.hplus_flow_v_msoy^2)+(kp_data[kp_start_index:kp_end_index].swia.hplus_flow_v_msoz^2))
        endif
      endif
      store_data,'SWIA_H_VEL',data={x:kp_data[kp_start_index:kp_end_index].time, y:swia_h_vel_data, v:swia_h_vel_v}, dlim={labels:swia_h_vel_labels,ytitle:'SWIA H+ Flow Velocity, MSO'},verbose=0
      options,'SWIA_H_VEL','labflag',-1         
      
      tplot_2plot[plot_count] = 'SWIA_H_VEL'
      lin_log[plot_count] = 0
      plot_count = plot_count+1
    endif
  endif

  if keyword_set(static_h_vel) then begin
    static_h_vel_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    static_h_vel_v= findgen(4)*(255./3.)
    static_h_vel_labels = ['X','Y','Z','Magnitude']
    
    t1 = where(base_tags eq 'STATIC')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_DIR_MSOX')
        if t2 ne -1 then static_h_vel_data[*,0] = kp_data[kp_start_index:kp_end_index].static.hplus_char_dir_msox
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_DIR_MSOY')
        if t2 ne 1 then static_h_vel_data[*,1] = kp_data[kp_start_index:kp_end_index].static.hplus_char_dir_msoy
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_DIR_MSOZ')
        if t2 ne -1 then static_h_vel_data[*,2] = kp_data[kp_start_index:kp_end_index].static.hplus_char_dir_msoz
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_DIR_MSOX')
        if t2 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_DIR_MSOY')
          if t2 ne -1 then begin
            t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_DIR_MSOZ')
              if t2 ne -1 then static_h_vel_data[*,3] = sqrt((kp_data[kp_start_index:kp_end_index].static.hplus_char_dir_msox^2)+(kp_data[kp_start_index:kp_end_index].static.hplus_char_dir_msoy^2)+(kp_data[kp_start_index:kp_end_index].static.hplus_char_dir_msoz^2))
          endif
        endif
        
      store_data,'STATIC_H_VEL',data={x:kp_data[kp_start_index:kp_end_index].time, y:static_h_vel_data, v:static_h_vel_v}, dlim={labels:static_h_vel_labels,ytitle:'STATIC H+ Flow Velocity, MSO'},verbose=0
      options,'STATIC_H_VEL','labflag',-1     
      
      tplot_2plot[plot_count] = 'STATIC_H_VEL'
      lin_log[plot_count] = 0
      plot_count = plot_count+1
    endif
  endif

  
  if keyword_set(static_o2_vel) then begin
    static_o2_vel_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    static_o2_vel_v= findgen(4)*(255./3.)
    static_o2_vel_labels = ['X','Y','Z','Magnitude']
    
    t1 = where(base_tags eq 'STATIC')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOX')
        if t2 ne -1 then static_o2_vel_data[*,0] = kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msox
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOY')
        if t2 ne -1 then static_o2_vel_data[*,1] = kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msoy
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOZ')
        if t2 ne -1 then static_o2_vel_data[*,2] = kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msoz
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOX')
        if t2 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOY')
          if t2 ne -1 then begin
            t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOZ')
              if t2 ne -1 then static_o2_vel_data[*,3] = sqrt((kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msox^2)+(kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msoy^2)+(kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msoz^2))
          endif
        endif
  
      store_data,'STATIC_O2_VEL',data={x:kp_data[kp_start_index:kp_end_index].time, y:static_o2_vel_data, v:static_o2_vel_v}, dlim={labels:static_o2_vel_labels,ytitle:'STATIC O2+ Flow Velocity, MSO'},verbose=0
      options,'STATIC_O2_VEL','labflag',-1     
      
      tplot_2plot[plot_count] = 'STATIC_O2_VEL'
      lin_log[plot_count] = 0
      plot_count = plot_count+1
    endif
  endif

  if keyword_set(static_flux) then begin
    static_flux_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 2)
    static_flux_v= findgen(2)*(255./1.)
    static_flux_labels = ['H/HE','Pickup Ion']
    
    t1 = where(base_tags eq 'STATIC')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOX')
        if t2 ne -1 then static_flux_data[*,0] = kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msox
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_FLOW_V_MSOY')
        if t2 ne -1 then static_flux_data[*,1] = kp_data[kp_start_index:kp_end_index].static.o2plus_flow_v_msoy
  
      store_data,'STATIC_FLUX',data={x:kp_data[kp_start_index:kp_end_index].time, y:static_flux_data, v:static_flux_v}, dlim={labels:static_flux_labels, ytitle:'Omni-Directional Flux', ylog:1},verbose=0
      options,'STATIC_FLUX','labflag',-1     
      
      tplot_2plot[plot_count] = 'STATIC_FLUX'
      lin_log[plot_count] = 1
      plot_count = plot_count + 1  
    endif                                
  endif

  if keyword_set(static_energy) then begin
    static_energy_data = fltarr(n_elements(kp_data[kp_start_index:kp_end_index].time), 4)
    static_energy_v= findgen(4)*(255./3.)
    static_energy_labels = ['H+','H++','O+','O2+']
    
    t1 = where(base_tags eq 'STATIC')
    if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HPLUS_CHAR_ENERGY')
        if t2 ne -1 then static_energy_data[*,0] = kp_data[kp_start_index:kp_end_index].static.hplus_char_energy
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'HEPLUS_CHAR_ENERGY')  
        if t2 ne -1 then static_energy_data[*,1] = kp_data[kp_start_index:kp_end_index].static.heplus_char_energy
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'OPLUS_CHAR_ENERGY')
        if t2 ne -1 then static_energy_data[*,2] = kp_data[kp_start_index:kp_end_index].static.oplus_char_energy
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'O2PLUS_CHAR_ENERGY')
        if t2 ne -1 then static_energy_data[*,3] = kp_data[kp_start_index:kp_end_index].static.o2plus_char_energy
  
      store_data,'STATIC_ENERGY',data={x:kp_data[kp_start_index:kp_end_index].time, y:static_energy_data, v:static_energy_v}, dlim={labels:static_energy_labels, ytitle:'Characteristic Energy', ylog:1},verbose=0
      options,'STATIC_ENERGY','labflag',-1     
      
      tplot_2plot[plot_count] = 'STATIC_ENERGY'
      lin_log[plot_count] = 1
      plot_count = plot_count + 1 
    endif                                 
  endif
  
  if keyword_set(sun_bar) then begin
     sun_bar_data = intarr(n_elements(kp_data[kp_start_index:kp_end_index].time))
     sun_bar_labels = ['Sunlit/Eclipsed']

    t1 = where(base_tags eq 'SPACECRAFT')
     if t1 ne -1 then begin
       t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_X')
       if t2 ne -1 then begin
        t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Y')
        if t2 ne -1 then begin
          t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'MSO_Z')
          if t2 ne -1 then begin
           r_mars = 3396.0
           for i=kp_start_index, kp_end_index do begin
            if (kp_data[i].spacecraft.mso_x lt 0) and $
                  (sqrt((kp_data[i].spacecraft.mso_y)^2 + (kp_data[i].spacecraft.mso_z)^2) lt r_mars) then begin
                sun_bar_data[i] = 0
            endif else begin
              sun_bar_data[i] = 1
            endelse
           endfor
          endif
        endif
      endif
       
       store_data,'SUN_BAR',data={x:kp_data[kp_start_index:kp_end_index].time, y:sun_bar_data}, dlim={labels:sun_bar_labels, ytitle:'Sunbar', ylog:0},verbose=0
       options, 'SUN_BAR','labflag',-1
       ylim, 'SUN_BAR', -0.1,1.1,0
       
       tplot_2plot[plot_count] = 'SUN_BAR'
       lin_log[plot_count] = 1
       plot_count = plot_count+ 1
     endif
  endif
  
  if keyword_set(solar_wind) then begin
     solar_wind_labels = ['Solarwind Pressure']
     
     t1 = where(base_tags eq 'SWIA')
     if t1 ne -1 then begin
      
       t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SOLARWIND_DYNAMIC_PRESSURE')
       if t2 ne -1 then begin
         store_data,'SOLAR_WIND',data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].swia.solarwind_dynamic_pressure}, dlim={labels:solar_wind_labels, ylog:1},verbose=0
         tplot_2plot[plot_count] = 'SOLAR_WIND'
         lin_log[plot_count] = 1
         plot_count = plot_count + 1 
       endif
     endif
  endif

  if keyword_set(ionosphere) then begin
     ionosphere_labels =['Electron Shape']
     store_data,'IONOSPHERE',data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].swea.electron_spectrum_shape}, dlim={labels:ionosphere_labels, ylog:1},verbose=0
     tplot_2plot[plot_count] = 'IONOSPHERE'
     lin_log[plot_count] = 1
     plot_count = plot_count + 1 
  endif

  if keyword_set(sc_pot) then begin
     sc_pot_labels = ['Spacecraft Potential']
     
     t1 = where(base_tags eq 'LPW')
     if t1 ne -1 then begin
      t2 = where(first_level_tags[total(first_level_count[0:t1-1]):total(first_level_count[0:t1])] eq 'SPACECRAFT_POTENTIAL')
      if t2 ne -1 then begin
       store_data,'SC_POTENTIAL',data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].lpw.spacecraft_potential}, dlim={labels:sc_pot_labels},verbose=0
       tplot_2plot[plot_count] = 'SC_POTENTIAL'
       lin_log[plot_count] = 0
       plot_count = plot_count + 1 
      endif
     endif
  endif




  if plot_count ne 0 then begin

    print,'Plotting:'
    for i=0,plot_count-1 do print,string(i+1),' ',tplot_2plot[i]
    tplot,tplot_2plot,title=overall_title,verbose=0
  
    if keyword_set(altitude) then begin
     store_data,'alt',data={x:kp_data[kp_start_index:kp_end_index].time, y:kp_data[kp_start_index:kp_end_index].spacecraft.altitude},verbose=0
     tplot,var_label=['alt'],verbose=0
     options,'alt','ytitle','Alt (km)'
     options,'alt','format','(f8.0)'
     tplot,verbose=0
    endif else begin
     tplot,var_label=[''],verbose=0
    endelse
    
  endif else begin
   print,'NO IN-SITU STANDARDIZED PLOTS REQUESTED'
   print,'The following keywords may be used to plot any combination of standardized plots.'
   print,''
   print,'/EUV --- EUV Irradiance'
   print,'/MAG_MSO --- Magnetic Field, MSO Coordinates'
   print,'/MAG_GEO --- Magnetic Field, Geographic Coordinates'
   print,'/MAG_CONE --- Magnetic Clock and Cone Angles, MSO Coordinates'
   print,'/MAG_DIR --- Magnetic Field: Radial, Horizontal, Northward, and Eastward Components'
   print,'/NGIMS_NEUTRAL --- Neutral atmospheric component densities'
   print,'/NGIMS_IONS --- Ionized atmospheric component densities'
   print,'/EPH_ANGLE --- Spacecraft Ephemeris Information'
   print,'/EPH_GEO --- Spacecraft Position in Geographic Coordinates'
   print,'/EPH_MSO --- Spacecraft Position in MSO Coordinates'
   print,'/SWEA --- Electron Parallel/Anti-Parallel Fluxes'
   print,'/SEP_ION --- Ion Energy Fluxes'
   print,'/SEP_Electon --- Electron Energy Fluxes'
   print,'/WAVE --- E-Field Wave Power'
   print,'/PLASMA_DEN --- Plasma Densities'
   print,'/PLASMA_TEMP --- Plasma Temperatures'
   print,'/SWIA_H_VEL --- H+ Flow Velocity in MSO Coordinates from SWIA'
   print,'/STATIC_H_VEL --- H+ Flow Velocity in MSO Coordinates from STATIC'
   print,'/STATIC_O_VEL --- O+ Flow Velocity in MSO Coordinates from STATIC'
   print,'/STATIC_O2_VEL --- O2+ Flow Velocity in MSO Coordinates from STATIC'
   print,'/STATIC_FLUX --- H+/He++ and Pick-up Ion Omni-Directional Fluxes'
   print,'/STATIC_ENERGY --- H+/He++ and Pick-up Ion Characteristic Energies'
   print,'/SUN_BAR --- Indication of if MAVEN is in sunlight or not.'
   print,'/SOLAR_WIND --- Solar Wind Dynamic Pressure'
   print,'/IONOSPHERE --- Electron Spectrum Shape Parameter'
  endelse



end