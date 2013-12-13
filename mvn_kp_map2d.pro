;+
; THIS ROUTINE PLOTS THE ORBITAL TRACK OF MAVEN ON VARIOUS BASEMAPS, COLORED BY THE SELECTED DATA PARAMETER
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data
;    
; :Keywords:
;    iuvs: in, optional, type=structure
;       optional IUVS data structure for overplotting of relevant parameters
;    time: in, optional, type=strarr(2)
;       an array that defines the start and end times to be plotted
;    orbit: in, optional, type=intarr(2)
;       an array that defines the start and end orbit indices to be plotted
;    parameter: in, optional, type=integer/string
;       the name or index of the insitu parameter to be plotted (if not selected, only orbital track shown)
;    list: in, optional, type=boolean
;       if selected, will list the KP data fields included in kp_data
;    range: in, optional, type=boolean
;       if selected, will list the beginning and end times of kp_data
;    basemap: in, optional, type=string
;       the name of the basemap to display (MDIM, MOLA, MOLA_BW, MAG). If not included, then lat/long grid is shown   
;    colors: in, optional, type=string/integer
;       the name (bw, red) or index of the color table to use when plotting the selected parameter
;    subsolar: in, optional, type=boolean
;       in selected, will plot the subsolar track 
;    alpha: in, optional, type=integer
;       the transparency of the basemap between 0(opaque) and 100(transparent), defaults to 0 (opaque)
;    mso: in, optional, type=boolean 
;       switch between GEO and MSO map projections
;    
;-

@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_range_select
@mvn_kp_tag_verify

pro MVN_KP_MAP2D, kp_data, iuvs=iuvs, time=time, orbit=orbit, parameter=parameter, list=list, basemap=basemap, $
                  colors=colors, range=range, subsolar=subsolar,alpha = alpha, mso=mso, nopath=nopath, $
                  periapse_temp=periapse_temp, $
                  corona_lo_dust=corona_lo_dust,corona_lo_ozone=corona_lo_ozone, corona_lo_aurora=corona_lo_aurora
           
   common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr        
                
;DETERMINE THE INSTALL DIRECTORY SO THE BASEMAPS CAN BE FOUND
     install_result = routine_info('mvn_kp_map2d',/source)
     install_directory = strsplit(install_result.path,'mvn_kp_map2d.pro',/extract,/regex)          
                
;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  ;for the insitu data
    MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags
  ;for the iuvs data
    if keyword_set(iuvs) then begin
      MVN_KP_TAG_PARSER, iuvs, iuvs_base_tag_count, iuvs_first_level_count, iuvs_second_level_count, iuvs_base_tags,  iuvs_first_level_tags, iuvs_second_level_tags
    endif
    
;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET

  if keyword_set(list) then begin
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    goto,finish
  endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    goto,finish
  endif

  ;SET THE BEGINNING AND END TIME RANGES TO BE PLOTTED
  if keyword_set(time) then begin
   if size(time,/dimension) eq 0 then begin         ;IF ONLY A SINGLE TIME IS ENTERED, PLOT ONLY 1 ORBIT
    MVN_KP_TIME_FIND, kp_data.time_string, kp_data.orbit, time, time_out, begin_index,/min
    begin_time = kp_data[time_out].time
    end_index = max(where(kp_data.orbit eq (kp_data[begin_index].orbit + 1)))
    end_time = kp_data[end_index].time
   endif 
   if size(time,/dimension) eq 2 then begin         ;IF 2 TIMES ARE ENTERED, USE THEM AS START/STOP TIMES
    MVN_KP_TIME_FIND, kp_data.time_string, kp_data.orbit, time[0], time_out, begin_index,/min
    begin_time = kp_data[time_out].time
    MVN_KP_TIME_FIND, kp_data.time_string, kp_data.orbit, time[1], time_out, end_index,/max
    end_time = kp_data[time_out].time    
    end_index = time_out
   endif  
  endif else begin                                  ;IF NO TIME SET, THEN PLOT THE ENTIRE SPAN OF KP_DATA
    begin_time = kp_data[0].time
    end_time = kp_data[n_elements(kp_data.time)-1].time
    begin_index = 0
    end_index = n_elements(kp_data.time)-1
  endelse
  
  ;SET THE BEGINNING AND END TIMES IF THE USER SELECTED ORBIT BASED PLOTTING
  if keyword_set(orbit) then begin
    if size(orbit, /dimension) eq 0 then begin      ;IF ONLY A SINGLE ORBIT IS ENTERED, ASSUME 1 ORBIT TO BE PLOTTED
      begin_index = min(where(kp_data.orbit eq orbit))
      end_index = max(where(kp_data.orbit eq (orbit+1)))
      begin_time = kp_data[begin_index].time
      end_time = kp_data[end_index].time
    endif 
    if size(orbit, /dimension) eq 2 then begin      ;IF TWO ORBITS ARE ENTERED, PLOT BETWEEN THEM
      begin_index = min(where(kp_data.orbit eq orbit[0]))
      end_index = max(where(kp_data.orbit eq (orbit[1])))
      begin_time = kp_data[begin_index].time
      end_time = kp_data[end_index].time    
    endif
  endif 

  ;CHECK THAT THE TIME RANGES FALL WITHIN THAT COVERED BY KP_DATA
  
  if begin_time lt kp_data[0].time then begin
    print,'ERROR: Requested start time is before the range covered by the data'
    goto, finish
  endif
  if end_time gt kp_data[n_elements(kp_data.time)-1].time then begin
    print,'ERROR: Requested end time is after the range covered by the data'
    goto,finish
  endif
  
  ;CHECK THAT THE REQUESTED FIELD IS INCLUDED IN THE DATA
  
  if keyword_set(parameter) then begin
    MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
     
    if check eq 1 then begin
      print,'Whoops, ',strupcase(parameter),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
      goto,finish
   endif       
     
  endif
  
  ;CREATE THE EMPTY MAP
    ;DETERMINE IF THE BASEMAP IS TO BE MADE PARTIALLY TRANSPARENT
  if keyword_set(alpha) eq 0 then alpha=0
  ;IF THE BASEMAP HAS BEEN SELECTED, LOAD IT FIRST
  if keyword_set(basemap) then begin
   if basemap eq 'mdim' then begin
     mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)  
     map_limit = [-90,-180,90,180]
     map_location = [-180,-90]
   endif
   if basemap eq 'mola' then begin
     mapimage = FILEPATH('MOLA_color_2500x1250.jpg',root_dir=install_directory)  
     map_limit = [-90,-180,90,180]
     map_location = [-180,-90]
   endif 
   if basemap eq 'mola_bw' then begin
     mapimage = FILEPATH('MOLA_BW_2500x1250.jpg',root_dir=install_directory)  
     map_limit = [-90,-180,90,180]
     map_location = [-180,-90]
   endif 
   if basemap eq 'mag' then begin
     mapimage = FILEPATH('Mars_Crustal_Magnetism_MGS.jpg',root_dir=install_directory)
     map_limit = [-90,0,90,360]
     map_location = [0,-90]      
   endif
   if basemap eq 'user' then begin
      input_file = dialog_pickfile(path=install_directory,filter='*.jpg')
      read_jpeg,input_file,mapimage
      map_limit = [-90,-180,90,180]
      map_location = [-180,-90]
   endif
    i = image(mapimage, axis_style=2,LIMIT=map_limit, GRID_UNITS=2, IMAGE_LOCATION=map_location, IMAGE_DIMENSIONS=[360,180],$
              MAP_PROJECTION='Cylindrical Equal Area',margin=0,window_title="MAVEN Orbital Path",transparency=alpha)
    plot_color = "White"
  endif else begin
    mapimage = FILEPATH('MarsMap_2500x1250.jpg',root_dir=install_directory)  
    i = image(mapimage, axis_style=2,LIMIT=[-90,-180,90,180], GRID_UNITS=2, IMAGE_LOCATION=[-180,-90], IMAGE_DIMENSIONS=[360,180],$
              MAP_PROJECTION='Cylindrical Equal Area',margin=0,window_title="MAVEN Orbital Path",/nodata)
    plot_color = "Black"
  endelse

  ;REWORK THE MAPS IF SOLAR COORDINATES ARE REQUESTED.
  

  
  ;PLOT THE SPACECRAFT PATH 
  color_default = 11
  if keyword_set(parameter) eq 1 then begin     ;PLOT THE PARAMETER WITH COLORS ALONG THE ORBITAL PATH
   if keyword_set(colors) eq 0 then begin       ;IF NO COLOR TABLE SELECTED, ASSUME BLUE/RED PROGRESSION 
    loadct,11,/silent
    TVLCT, R, G, B, /GET
     color_levels = intarr(3,n_elements(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude))
     parameter_minimum = min(kp_data[begin_index:end_index].(level0_index).(level1_index))
     parameter_maximum = max(kp_data[begin_index:end_index].(level0_index).(level1_index))    
     color_levels[0,*] = R(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
     color_levels[1,*] = G(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
     color_levels[2,*] = B(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
     p = plot(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,/overplot,margin=0,color=plot_color,symbol="D",linestyle=6)   
     symbols = symbol(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,"thin_diamond",/data,sym_color=color_levels,sym_filled=1) 
        c = COLORBAR(TITLE=strupcase(string(tag_array[0]+'.'+tag_array[1])),rgb_table=11,ORIENTATION=0, position=[0.3,0.1,0.7,0.15],TEXTPOS=0,$
            /border,range=[parameter_minimum,parameter_maximum])
   endif else begin
    if size(colors,/type) eq 7 then begin         ;ALLOW USER TO CALL COLOR TABLES WITH ASCII NAME
      if colors eq 'bw' then begin
        color_default = 0
       color_levels = intarr(3,n_elements(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude))
       parameter_minimum = min(kp_data[begin_index:end_index].(level0_index).(level1_index))
       parameter_maximum = max(kp_data[begin_index:end_index].(level0_index).(level1_index))     
       for i=0,n_elements(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude)-1 do begin
         color_levels[*,i] = fix(((kp_data[i].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255.)
       endfor
        p = plot(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,/overplot,margin=0,color=plot_color,symbol="D",linestyle=6)   
        symbols = symbol(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,"thin_diamond",/data,sym_color=color_levels,sym_filled=1) 
        c = COLORBAR(TITLE=strupcase(string(tag_array[0]+'.'+tag_array[1])),rgb_table=0,ORIENTATION=0, position=[0.3,0.1,0.7,0.15],TEXTPOS=0,$
            /border,range=[parameter_minimum,parameter_maximum])
      endif 
     if colors eq 'red' then begin
      color_default = 3
      loadct,3,/silent
      TVLCT, R, G, B, /GET
       color_levels = intarr(3,n_elements(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude))
       parameter_minimum = min(kp_data[begin_index:end_index].(level0_index).(level1_index))
       parameter_maximum = max(kp_data[begin_index:end_index].(level0_index).(level1_index))     
       color_levels[0,*] = R(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
       color_levels[1,*] = G(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
       color_levels[2,*] = B(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
        p = plot(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,/overplot,margin=0,color=plot_color,symbol="D",linestyle=6)   
        symbols = symbol(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,"thin_diamond",/data,sym_color=color_levels,sym_filled=1)
        c = COLORBAR(TITLE=strupcase(string(tag_array[0]+'.'+tag_array[1])),rgb_table=3,ORIENTATION=0, position=[0.3,0.1,0.7,0.15],TEXTPOS=0,$
            /border,range=[parameter_minimum,parameter_maximum])     
     endif
   endif
   if size(colors,/type) eq 2 then begin          ;ALLOW USER TO CALL ANY PRE-DEFINED IDL COLOR TABLE
    color_default = colors
   loadct,colors,/silent
      TVLCT, R, G, B, /GET
       color_levels = intarr(3,n_elements(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude))
       parameter_minimum = min(kp_data[begin_index:end_index].(level0_index).(level1_index))
       parameter_maximum = max(kp_data[begin_index:end_index].(level0_index).(level1_index))     
       color_levels[0,*] = R(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
       color_levels[1,*] = G(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
       color_levels[2,*] = B(fix(((kp_data[begin_index:end_index].(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255) )
        p = plot(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,/overplot,margin=0,color=plot_color,symbol="D",linestyle=6)   
        symbols = symbol(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,"thin_diamond",/data,sym_color=color_levels,sym_filled=1)     
        c = COLORBAR(TITLE=strupcase(string(tag_array[0]+'.'+tag_array[1])),rgb_table=colors,ORIENTATION=0, position=[0.3,0.1,0.7,0.15],TEXTPOS=0,$
            /border,range=[parameter_minimum,parameter_maximum])
   endif
  endelse      
  endif else begin                          ;IF NO PARAMETER REQUESTED, PLOT SIMPLY THE ORBITAL PATH
    if keyword_set(nopath) eq 0 then begin
      p = plot(kp_data[begin_index:end_index].spacecraft.sub_sc_longitude,kp_data[begin_index:end_index].spacecraft.sub_sc_latitude,/overplot,margin=0,color=plot_color,symbol="D",linestyle=6)
    endif
  endelse

  if keyword_set(subsolar) then begin
    p = symbol(kp_data[begin_index:end_index].spacecraft.subsolar_point_geo_longitude, kp_data[begin_index:end_index].spacecraft.subsolar_point_geo_latitude, 'circle',/data,sym_color="YELLOW",sym_filled=1)
  endif


  ;ADD ON THE IUVS PLOT PARAMETERS, IF REQUESTED
  colorbar_position = [0.1,0.22,0.3,0.27]
  colorbar_index = 0
    ;PERIAPSE LIMB SCAN TEMPERATURE MEASUREMENTS
    if keyword_set(periapse_temp) then begin
      if keyword_set(iuvs) then begin
        check = where(iuvs_base_tags eq 'PERIAPSE')
        if check eq 0 then begin
          print, 'IUVS DATA STRUCTURE DOES NOT CONTAIN PERIAPSE DATA TO PLOT.'
        endif else begin
          temperature = fltarr(n_elements(iuvs.periapse.temperature))
          t_lat = fltarr(n_elements(iuvs.periapse.lat))
          t_lon = fltarr(n_elements(iuvs.periapse.lon))
          t_ind=0
          for i=0,n_elements(iuvs)-1 do begin
            for j=0,2 do begin
              temperature[t_ind] = iuvs[i].periapse[j].temperature
              t_lat[t_ind] = iuvs[i].periapse[j].lat
              t_lon[t_ind] = iuvs[i].periapse[j].lon
              t_ind++
            endfor
          endfor
          fill_color = intarr(3,n_elements(iuvs.periapse.temperature))
 
          MVN_KP_MAP2D_SYMBOL_FILL, temperature, fill_color, color_default, colorbars
          for i=0,n_elements(temperature)-1 do begin
            s1 = symbol(t_lon[i], t_lat[i], /overplot, margin=0, symbol="circle",sym_filled=1,sym_fill_color=fill_color[*,i],/data)
          endfor
            c = COLORBAR(TITLE='IUVS Periapse Limb Scan Temperature',rgb_table=colorbars, ORIENTATION=0, position=colorbar_position,TEXTPOS=0,$
            /border,range=[min(temperature),max(temperature)])
            if colorbar_index eq 2 then begin
              colorbar_position = colorbar_position + [0.3,0,0.3,0]
            endif else begin
              colorbar_position = colorbar_position + [-0.6,-.1,-0.6,-0.1]
              colorbar_index = 0
            endelse
            colorbar_index++
        endelse 
      endif else begin
        print,'NO IUVS DATA STRUCTURE LOADED, CAN NOT PLOT PERIAPSE DATA'
      endelse
    endif

  ;CORONA LORES DUST DEPTH MEASUREMENT
    if keyword_set(corona_lo_dust) then begin
      if keyword_set(iuvs) then begin
        check = where(iuvs_base_tags eq 'CORONA_LO_DISK')
        if check eq 0 then begin
          print, 'IUVS DATA STRUCTURE DOES NOT CONTAIN CORONA LO-RES DISK DATA TO PLOT.'
        endif else begin
          data = fltarr(n_elements(iuvs.corona_lo_disk.dust_depth))
          t_lat = fltarr(n_elements(iuvs.corona_lo_disk.lat))
          t_lon = fltarr(n_elements(iuvs.corona_lo_disk.lon))
          t_ind=0
          for i=0,n_elements(iuvs)-1 do begin
           data[i] = iuvs[i].corona_lo_disk.dust_depth
           t_lat[i] = iuvs[i].corona_lo_disk.lat
           t_lon[i] = iuvs[i].corona_lo_disk.lon
          endfor
          fill_color = intarr(3,n_elements(iuvs.corona_lo_disk.dust_depth))
 
          MVN_KP_MAP2D_SYMBOL_FILL, data, fill_color, color_default, colorbars
          for i=0,n_elements(data)-1 do begin
            s1 = symbol(t_lon[i], t_lat[i], /overplot, margin=0, symbol="circle",sym_filled=1,sym_fill_color=fill_color[*,i],/data)
          endfor
            c = COLORBAR(TITLE='IUVS Corona Lo-Res Disk Dust Depth',rgb_table=colorbars, ORIENTATION=0, position=colorbar_position,TEXTPOS=0,$
            /border,range=[min(data),max(data)])
            if colorbar_index eq 2 then begin
              colorbar_position = colorbar_position + [0.3,0,0.3,0]
            endif else begin
              colorbar_position = colorbar_position + [-0.6,-.1,-0.6,-0.1]
              colorbar_index = 0
            endelse
            colorbar_index++
        endelse 
      endif else begin
        print,'NO IUVS DATA STRUCTURE LOADED, CAN NOT PLOT CORONA LO-RES DISK DATA'
      endelse
    endif
    
  ;CORONA LORES OZONE MEASUREMENT
    if keyword_set(corona_lo_ozone) then begin
      if keyword_set(iuvs) then begin
        check = where(iuvs_base_tags eq 'CORONA_LO_DISK')
        if check eq 0 then begin
          print, 'IUVS DATA STRUCTURE DOES NOT CONTAIN CORONA LO-RES DISK DATA TO PLOT.'
        endif else begin
                   
          data = fltarr(n_elements(iuvs.corona_lo_disk.ozone_depth))
          t_lat = fltarr(n_elements(iuvs.corona_lo_disk.lat))
          t_lon = fltarr(n_elements(iuvs.corona_lo_disk.lon))
          t_ind=0
          for i=0,n_elements(iuvs)-1 do begin
           data[i] = iuvs[i].corona_lo_disk.ozone_depth
           t_lat[i] = iuvs[i].corona_lo_disk.lat
           t_lon[i] = iuvs[i].corona_lo_disk.lon
          endfor
          fill_color = intarr(3,n_elements(iuvs.corona_lo_disk.ozone_depth))
 
          MVN_KP_MAP2D_SYMBOL_FILL, data, fill_color, color_default, colorbars
          for i=0,n_elements(data)-1 do begin
            s1 = symbol(t_lon[i], t_lat[i], /overplot, margin=0, symbol="circle",sym_filled=1,sym_fill_color=fill_color[*,i],/data)
          endfor
            c = COLORBAR(TITLE='IUVS Corona Lo-Res Disk Ozone Depth',rgb_table=colorbars, ORIENTATION=0, position=colorbar_position,TEXTPOS=0,$
            /border,range=[min(data),max(data)])
            if colorbar_index eq 2 then begin
              colorbar_position = colorbar_position + [0.3,0,0.3,0]
            endif else begin
              colorbar_position = colorbar_position + [-0.6,-.1,-0.6,-0.1]
              colorbar_index = 0
            endelse
            colorbar_index++
        endelse 
      endif else begin
        print,'NO IUVS DATA STRUCTURE LOADED, CAN NOT PLOT CORONA LO-RES DISK DATA'
      endelse
    endif
  
  ;CORONA LORES AURORAL INDEX 
    if keyword_set(corona_lo_aurora) then begin
      if keyword_set(iuvs) then begin
        check = where(iuvs_base_tags eq 'CORONA_LO_DISK')
        if check eq 0 then begin
          print, 'IUVS DATA STRUCTURE DOES NOT CONTAIN CORONA LO-RES DISK DATA TO PLOT.'
        endif else begin
                   
          data = fltarr(n_elements(iuvs.corona_lo_disk.auroral_index))
          t_lat = fltarr(n_elements(iuvs.corona_lo_disk.lat))
          t_lon = fltarr(n_elements(iuvs.corona_lo_disk.lon))
          t_ind=0
          for i=0,n_elements(iuvs)-1 do begin
           data[i] = iuvs[i].corona_lo_disk.auroral_index
           t_lat[i] = iuvs[i].corona_lo_disk.lat
           t_lon[i] = iuvs[i].corona_lo_disk.lon
          endfor
          fill_color = intarr(3,n_elements(iuvs.corona_lo_disk.auroral_index))
 
          MVN_KP_MAP2D_SYMBOL_FILL, data, fill_color, color_default, colorbars
          for i=0,n_elements(data)-1 do begin
            s1 = symbol(t_lon[i], t_lat[i], /overplot, margin=0, symbol="circle",sym_filled=1,sym_fill_color=fill_color[*,i],/data)
          endfor
            c = COLORBAR(TITLE='IUVS Corona Lo-Res Disk Auroral Index',rgb_table=colorbars, ORIENTATION=0, position=colorbar_position,TEXTPOS=0,$
            /border,range=[min(data),max(data)])
            if colorbar_index eq 2 then begin
              colorbar_position = colorbar_position + [0.3,0,0.3,0]
              print,'asdfa ',colorbar_position,colorbar_index
            endif else begin
              colorbar_position = colorbar_position + [-0.6,-.1,-0.6,-0.1]
              print,colorbar_position,colorbar_index
              colorbar_index = 0
            endelse
            colorbar_index++
        endelse 
      endif else begin
        print,'NO IUVS DATA STRUCTURE LOADED, CAN NOT PLOT CORONA LO-RES DISK DATA'
      endelse
    endif  
  
  
  
  
  
finish:
end