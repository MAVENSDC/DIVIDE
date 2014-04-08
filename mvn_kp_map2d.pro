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
@mvn_kp_map2d_iuvs_plot
@mvn_kp_3d_optimize
@mvn_kp_time_find
@mvn_kp_plotimage


pro MVN_KP_MAP2D, kp_data, iuvs=iuvs, time=time, orbit=orbit, parameter=parameter, list=list, basemap=basemap, $
                  colors=colors, range=range, subsolar=subsolar,alpha = alpha, mso=mso, nopath=nopath, $
                  periapse_temp=periapse_temp, optimize=optimize, direct=direct, log=log, i_colortable=i_colortable, $
                  corona_lo_dust=corona_lo_dust,corona_lo_ozone=corona_lo_ozone, corona_lo_aurora=corona_lo_aurora, $
                  corona_lo_h_rad=corona_lo_h_rad, corona_lo_co_rad=corona_lo_co_rad, corona_lo_no_rad=corona_lo_no_rad, $
                  corona_lo_o_rad=corona_lo_o_rad, corona_e_h_rad=corona_e_h_rad, corona_e_d_rad=corona_e_d_rad, corona_e_o_rad=corona_e_o_rad
           
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
    
    
;CHECK THE IDL VERSION NUMBER FOR FUNCTION GRAPHICS
 if keyword_set(direct) eq 0 then begin
   if Float(!Version.Release) GE 8.0 THEN directgraphic = 0    ;USE DIRECT GRAPHICS IF USER HAS OLD VERSION OF IDL
  endif    
    
;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET

  if keyword_set(list) then begin
    MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
    return
  endif

  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    return
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
  
  kp_data = kp_data[begin_index:end_index]

  ;CHECK THAT THE TIME RANGES FALL WITHIN THAT COVERED BY KP_DATA
  
  if begin_time lt kp_data[0].time then begin
    print,'ERROR: Requested start time is before the range covered by the data'
    return
  endif
  if end_time gt kp_data[n_elements(kp_data.time)-1].time then begin
    print,'ERROR: Requested end time is after the range covered by the data'
    return
  endif
  
  ;CHECK THAT THE REQUESTED FIELD IS INCLUDED IN THE DATA
  
  if keyword_set(parameter) then begin
    MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
     
    if check eq 1 then begin
      print,'Whoops, ',strupcase(parameter),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
      return
   endif       
     
  endif
  
  ;DOWNSCALE THE INPUT DATA SO IT CAN ALL BE PLOTTED CORRECTLY
  
  if keyword_set(optimize) eq 0 then begin
    optimizer = round(n_elements(kp_data)/5000.) 
    MVN_KP_3D_OPTIMIZE, kp_data, kp_data1, optimizer
  endif else begin
    kp_data1 = kp_data
  endelse
  

  ;CREATE THE EMPTY MAP
  if keyword_set(mso) eq 0 then begin       ;only bother if plotting geo coordinates
    mso = 0
      ;DETERMINE IF THE BASEMAP IS TO BE MADE PARTIALLY TRANSPARENT
    if keyword_set(alpha) eq 0 then alpha=0
    ;IF THE BASEMAP HAS BEEN SELECTED, LOAD IT FIRST
    if keyword_set(basemap) then begin
     if basemap eq 'mdim' then begin
       mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)  
       read_jpeg,mapimage,mapimage
       map_limit = [-90,-180,90,180]
       map_location = [-180,-90]
     endif
     if basemap eq 'mola' then begin
       mapimage = FILEPATH('MOLA_color_2500x1250.jpg',root_dir=install_directory)  
       read_jpeg,mapimage,mapimage
       map_limit = [-90,-180,90,180]
       map_location = [-180,-90]
     endif 
     if basemap eq 'mola_bw' then begin
       mapimage = FILEPATH('MOLA_BW_2500x1250.jpg',root_dir=install_directory) 
       read_jpeg,mapimage,mapimage 
       map_limit = [-90,-180,90,180]
       map_location = [-180,-90]
     endif 
     if basemap eq 'mag' then begin
       mapimage = FILEPATH('Mars_Crustal_Magnetism_MGS.jpg',root_dir=install_directory)
       read_jpeg,mapimage,mapimage
       map_limit = [-90,0,90,360]
       map_location = [0,-90]      
     endif
     if basemap eq 'user' then begin
        input_file = dialog_pickfile(path=install_directory,filter='*.jpg')
        read_jpeg,input_file,mapimage
        map_limit = [-90,-180,90,180]
        map_location = [-180,-90]
     endif
      if keyword_set(direct) eq 0 then begin
        i = image(mapimage, axis_style=2,LIMIT=map_limit, GRID_UNITS=2, IMAGE_LOCATION=map_location, IMAGE_DIMENSIONS=[360,180],$
                  MAP_PROJECTION='Cylindrical Equal Area',margin=0,window_title="MAVEN Orbital Path",transparency=alpha)
        plot_color = "White"
      endif
    endif else begin
      mapimage = FILEPATH('MarsMap_2500x1250.jpg',root_dir=install_directory)  
      if keyword_set(direct) eq 0 then begin
        i = image(mapimage, axis_style=2,LIMIT=[-90,-180,90,180], GRID_UNITS=2, IMAGE_LOCATION=[-180,-90], IMAGE_DIMENSIONS=[360,180],$
                  MAP_PROJECTION='Cylindrical Equal Area',margin=0,window_title="MAVEN Orbital Path",/nodata)
        plot_color = "Black"
      endif    
     endelse
  endif else begin      ;blank canvas for the MSO plot
    mapimage = FILEPATH('MarsMap_2500x1250.jpg',root_dir=install_directory)  
    if keyword_set(direct) eq 0 then begin
      i = image(mapimage, axis_style=2,LIMIT=[-90,-180,90,180], GRID_UNITS=2, IMAGE_LOCATION=[-180,-90], IMAGE_DIMENSIONS=[360,180],$
                MAP_PROJECTION='Cylindrical Equal Area',margin=0,window_title="MAVEN Orbital Path",/nodata)
      plot_color = "Black"
    endif
  endelse 

  
;LOAD THE REQUESTED COLOR TABLE
  color_default = 11
  if keyword_set(colors) eq 0 then begin
    loadct,color_default, /silent
  endif else begin
    if size(colors, /type) eq 7 then begin
      if colors eq 'bw' then color_default = 0
      if colors eq 'red' then color_default = 3
    endif
    if size(colors, /type) eq 2 then begin
      color_default = colors
    endif
    loadct, color_default, /silent
  endelse
  

;CREATE EASILY PLOTTED DATA VALUES independent of coordinate frame
  if keyword_set(mso) eq 0 then begin
    latitude = kp_data1.spacecraft.sub_sc_latitude
    longitude = kp_data1.spacecraft.sub_sc_longitude
  endif else begin
    x = kp_data1.spacecraft.mso_x
    y = kp_data1.spacecraft.mso_y
    z = kp_data1.spacecraft.mso_z
    r = sqrt(x^2 + y^2 + z^2)
    
    latitude = 90.-(acos(z/r)*(180./!pi))
    longitude = atan(y,x)*(180./!pi)
  endelse
  
;DEFINE THE SYMBOL COLOR LEVELS
  color_levels = intarr(3,n_elements(latitude))
  tvlct, r, g, b, /get
  parameter_minimum = min(kp_data1.(level0_index).(level1_index))
  parameter_maximum = max(kp_data1.(level0_index).(level1_index))
  if keyword_set(log) eq 0 then begin         ;LINEAR COLOR STRETCH
    color_levels[0,*] =  R(fix(((kp_data1.(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255))
    color_levels[1,*] =  G(fix(((kp_data1.(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255))
    color_levels[2,*] =  B(fix(((kp_data1.(level0_index).(level1_index)-parameter_minimum)/(parameter_maximum-parameter_minimum))*255))
  endif else begin                            ;log color stretch
    exponent = 2
    data_mean = mean(kp_data1.(level0_index).(level1_index))
    color_levels[0,*] = R(fix(255./(1.+(data_mean/kp_data1.(level0_index).(level1_index))^exponent)))
    color_levels[1,*] = G(fix(255./(1.+(data_mean/kp_data1.(level0_index).(level1_index))^exponent)))
    color_levels[2,*] = B(fix(255./(1.+(data_mean/kp_data1.(level0_index).(level1_index))^exponent)))
  endelse 
  
if keyword_set(i_colortable) eq 0 then i_colortable = 11
   
;PLOT THE SPACECRAFT PATH

  total_colorbars = 0
  if keyword_set(direct) eq 0 then begin
    ;BUILD THE BASE PLOT
          p = plot(longitude, latitude, /overplot, margin=0, linestyle=6, color=plot_color)
          if keyword_set(nopath) eq 0 then begin
            symbols = symbol(longitude,latitude, "thin_diamond", /data, sym_color=color_levels, sym_filled=1)
          endif else begin
            p.symbol = "d"
            p.thick=2
          endelse
          
          ;ADD THE SUBSOLAR TRACK
            if keyword_set(subsolar) and (keyword_set(mso) eq 0) then begin
              p = symbol(kp_data1.spacecraft.subsolar_point_geo_longitude, kp_data1.spacecraft.subsolar_point_geo_latitude, 'circle',/data,sym_color="YELLOW",sym_filled=1)
            endif
        
          ;ADD THE COLORBAR
          if keyword_set(nopath) eq 0 then begin
            total_colorbars = total_colorbars + 1
          endif
    
    ;ADD IUVS PARAMETERS, IF SELECTED.
       ;PERIAPSE TEMPERATURE
          if keyword_set(periapse_temp) then begin
            if keyword_set(iuvs) then begin
              check = where(iuvs_base_tags eq 'PERIAPSE')
              if check eq -1 then begin
                print, 'IUVS DATA STRUCTURE DOES NOT CONTAIN PERIAPSE DATA TO PLOT.'
              endif else begin 
              mvn_kp_map2d_iuvs_plot, iuvs, 'PERIAPSE', mso, t_lat, t_lon, t_fill_color, i_colortable, t_colorbar, p_data_exist, t_min, t_max
              if p_data_exist eq 1 then begin
                s1 = symbol(t_lon, t_lat, "Circle", /data, sym_color=t_fill_color, sym_filled=1)
                total_colorbars = total_colorbars + 1
              endif
             endelse
            endif
          endif 
        ;CORONA LO-RES DISK OZONE
          if keyword_set(corona_lo_ozone) then begin

            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_OZONE', mso, o_lat, o_lon, o_fill_color, i_colortable, o_colorbar, o_data_exist, oz_min, oz_max
            if o_data_exist eq 1 then begin
              s1 = symbol(o_lon, o_lat, "Circle", /data, sym_color=o_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif 
            
          endif
        
        ;CORONA LO-RES DISK DUST
          if keyword_set(corona_lo_dust) then begin

            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_DUST', mso, d_lat, d_lon, d_fill_color, i_colortable, d_colorbar, d_data_exist, d_min, d_max
            if d_data_exist eq 1 then begin
              s1 = symbol(d_lon, d_lat, "Circle", /data, sym_color=d_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif 
            
          endif
         
             
        ;CORONA LO-RES DISK AURORA
          if keyword_set(corona_lo_aurora) then begin

            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_AURORA', mso, a_lat, a_lon, a_fill_color, i_colortable, a_colorbar, a_data_exist,a_min, a_max
            if a_data_exist eq 1 then begin
              s1 = symbol(a_lon, a_lat, "Circle", /data, sym_color=a_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif 
            
          endif   
        
        ;CORONA ECHELLE DISK H RADIANCE
          if keyword_set(corona_e_h_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_E_H_RAD', mso, eh_lat, eh_lon, eh_fill_color, i_colortable, eh_colorbar, eh_data_exist, eh_min, eh_max
            if eh_data_exist eq 1 then begin
              s1 = symbol(eh_lon, eh_lat, "Circle", /data, sym_color=eh_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif   
        
        ;CORONA ECHELLE DISK D RADIANCE
          if keyword_set(corona_e_d_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_E_D_RAD', mso, ed_lat, ed_lon, ed_fill_color, i_colortable, ed_colorbar, ed_data_exist, ed_min, ed_max
            if ed_data_exist eq 1 then begin
              s1 = symbol(ed_lon, ed_lat, "Circle", /data, sym_color=ed_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        ;CORONA ECHELLE DISK O1304 RADIANCE
          if keyword_set(corona_e_o_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_E_O_RAD', mso, eo_lat, eo_lon, eo_fill_color, i_colortable, eo_colorbar, eo_data_exist, eo_min, eo_max
            if eo_data_exist eq 1 then begin
              s1 = symbol(eo_lon, eo_lat, "Circle", /data, sym_color=eo_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        
        ;CORONA LO-RES DISK H RADIANCE
          if keyword_set(corona_lo_h_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_H_RAD', mso, lh_lat, lh_lon, lh_fill_color, i_colortable, lh_colorbar, lh_data_exist, lh_min, lh_max
            if lh_data_exist eq 1 then begin
              s1 = symbol(lh_lon, lh_lat, "Circle", /data, sym_color=lh_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        ;CORONA LO-RES DISK CO RADIANCE
          if keyword_set(corona_lo_co_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_CO_RAD', mso, lco_lat, lco_lon, lco_fill_color, i_colortable, lco_colorbar, lco_data_exist, lco_min, lco_max
            if lco_data_exist eq 1 then begin
              s1 = symbol(lco_lon, lco_lat, "Circle", /data, sym_color=lco_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        ;CORONA LO-RES DISK NO RADIANCE
          if keyword_set(corona_lo_no_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_NO_RAD', mso, lno_lat, lno_lon, lno_fill_color, i_colortable, lno_colorbar, lno_data_exist, lno_min, lno_max
            if lno_data_exist eq 1 then begin
              s1 = symbol(lno_lon, lno_lat, "Circle", /data, sym_color=lno_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        
        ;CORONA LO-RES DISK O1304 RADIANCE
          if keyword_set(corona_lo_o_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_O_RAD', mso, lo_lat, lo_lon, lo_fill_color, i_colortable, lo_colorbar, lo_data_exist, lo_min, lo_max
            if lo_data_exist eq 1 then begin
              s1 = symbol(lo_lon, lo_lat, "Circle", /data, sym_color=lo_fill_color, sym_filled=1)
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        ;DISPLAY THE RELEVANT COLORBARS
          if total_colorbars gt 0 then begin
            MVN_KP_MAP2D_COLORBAR_POS, total_colorbars, positions
            color_bar_index = 0
            if keyword_set(nopath) eq 0 then begin
              c = COLORBAR(TITLE=strupcase(string(tag_array[0]+'.'+tag_array[1])),rgb_table=11,ORIENTATION=0, position=positions[color_bar_index,*],TEXTPOS=0,$
                  /border,range=[parameter_minimum,parameter_maximum])
              color_bar_index++
            endif
            if keyword_set(periapse_temp) then begin
             if p_data_exist eq 1 then begin
              c = COLORBAR(TITLE='IUVS Periapse Limb Scan Temperature',rgb_table=t_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[t_min,t_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_ozone) then begin
             if o_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Ozone Depth',rgb_table=o_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[o_min,o_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_dust) then begin
             if d_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Dust Depth',rgb_table=d_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[d_min,d_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_aurora) then begin
             if a_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Auroral Index',rgb_table=a_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[a_min,a_max],position=positions[color_bar_index,*])
              color_bar_index++
               endif
            if keyword_set(corona_e_h_rad) then begin
             if eh_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Echelle Radiance: H',rgb_table=eh_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[eh_min,eh_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_e_d_rad) then begin
             if ed_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Echelle Radiance: D',rgb_table=ed_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[ed_min,ed_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_e_o_rad) then begin
             if eo_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Echelle Radiance: O-1304',rgb_table=eo_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[eo_min,eo_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_h_rad) then begin
             if lh_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Radiance: H',rgb_table=t_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[lh_min,lh_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_co_rad) then begin
             if lco_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Radiance: CO',rgb_table=lco_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[lco_min,lco_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_no_rad) then begin
             if lno_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Radiance: NO',rgb_table=lno_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[lno_min,lno_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif
            if keyword_set(corona_lo_o_rad) then begin
             if lo_data_exist eq 1 then begin
              c = COLORBAR(TITLE='Corona Lo-Res Radiance: O-1304',rgb_table=lo_colorbar, ORIENTATION=0, TEXTPOS=0, /border,range=[lo_min,lo_max],position=positions[color_bar_index,*])
              color_bar_index++
             endif
            endif   
           endif
       
            
            
          endif
          
  endif else begin   ;DIRECT GRAPHICS VERSION 
    
   DEVICE, DECOMPOSED=1
    
        ;BUILD THE BASE PLOT
        if keyword_set(mso) then begin
          ytitle = 'Latitude, MSO'
          xtitle= 'Longitude, MSO'
        endif else begin
          ytitle = 'Latitude, GEO'
          xtitle = 'Longitude, GEO'
        endelse
        
          plot,longitude,latitude,psym=3,xstyle=1,ystyle=1,yrange=[-90,90],ytitle=ytitle, xtitle=xtitle,/nodata,charsize=1.5,$
               charthick=2, xthick=2, ythick=2,color='000000'xL,background='FFFFFF'xL
          if keyword_set(mso) eq 0 then begin
           if keyword_set(basemap) then begin
            oplotimage,mapimage,imgxrange=[0,360],imgyrange=[-90,90]
           endif
          endif
          if keyword_set(nopath) eq 0 then begin
            loadct,color_default,/silent
            device,decomposed=0
            for i=0,n_elements(longitude)-1 do begin
              temp_color = color_levels(*,i)
              plots,longitude[i],latitude[i],psym=4,symsize=1,color=temp_color,thick=2
            endfor
          endif
          
          if keyword_set(subsolar) and (keyword_set(mso) eq 0) then begin
            device, decomposed=1
            plots,kp_data1.spacecraft.subsolar_point_geo_longitude,kp_data1.spacecraft.subsolar_point_geo_latitude, color='00FFFF'xl,psym=4
          endif
          
    ;ADD IUVS PARAMETERS, IF SELECTED.
       ;PERIAPSE TEMPERATURE
       device, decompose=0
          if keyword_set(periapse_temp) then begin
            if keyword_set(iuvs) then begin
              check = where(iuvs_base_tags eq 'PERIAPSE')
              if check eq -1 then begin
                print, 'IUVS DATA STRUCTURE DOES NOT CONTAIN PERIAPSE DATA TO PLOT.'
              endif else begin 
              mvn_kp_map2d_iuvs_plot, iuvs, 'PERIAPSE', mso, t_lat, t_lon, t_fill_color, i_colortable, t_colorbar, p_data_exist, t_min, t_max
              if p_data_exist eq 1 then begin
                for i=0,n_elements(t_lon)-1 do begin
                  plots,t_lon[i], t_lat[i], psym=6,symsize=2,color=t_fill_color[*,i],thick=4
                endfor
                total_colorbars = total_colorbars + 1
              endif
             endelse
            endif
          endif 
        ;CORONA LO-RES DISK OZONE
          if keyword_set(corona_lo_ozone) then begin
 
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_OZONE', mso, o_lat, o_lon, o_fill_color, i_colortable, o_colorbar, o_data_exist, oz_min, oz_max
            if o_data_exist eq 1 then begin
             for i=0,n_elements(o_lon)-1 do begin
              plots,o_lon[i], o_lat[i], psym=6,symsize=2,color=o_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif 
            
          endif
        
        ;CORONA LO-RES DISK DUS;T
          if keyword_set(corona_lo_dust) then begin;
 
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_DUST', mso, d_lat, d_lon, d_fill_color, i_colortable, d_colorbar, d_data_exist, d_min, d_max
            if d_data_exist eq 1 then begin
             for i=0,n_elements(d_lon)-1 do begin
              plots,d_lon[i], d_lat[i], psym=6,symsize=2,color=d_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif 
            
          endif
         
             
        ;CORONA LO-RES DISK AURORA
          if keyword_set(corona_lo_aurora) then begin
 
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_AURORA', mso, a_lat, a_lon, a_fill_color, i_colortable, a_colorbar, a_data_exist,a_min, a_max
            if a_data_exist eq 1 then begin
             for i=0,n_elements(a_lon)-1 do begin
              plots,a_lon[i], a_lat[i], psym=6,symsize=2,color=a_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif 
            
          endif   
        
        ;CORONA ECHELLE DISK H RADIANCE
          if keyword_set(corona_e_h_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_E_H_RAD', mso, eh_lat, eh_lon, eh_fill_color, i_colortable, eh_colorbar, eh_data_exist, eh_min, eh_max
            if eh_data_exist eq 1 then begin
             for i=0,n_elements(eh_lon)-1 do begin
              plots,eh_lon[i], eh_lat[i], psym=6,symsize=2,color=eh_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
          endif   
        
        ;CORONA ECHELLE DISK D RADIANCE
          if keyword_set(corona_e_d_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_E_D_RAD', mso, ed_lat, ed_lon, ed_fill_color, i_colortable, ed_colorbar, ed_data_exist, ed_min, ed_max
            if ed_data_exist eq 1 then begin
             for i=0,n_elements(ed_lon)-1 do begin
              plots,ed_lon[i], ed_lat[i], psym=6,symsize=2,color=ed_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        ;CORONA ECHELLE DISK O1304 RADIANCE
          if keyword_set(corona_e_o_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_E_O_RAD', mso, eo_lat, eo_lon, eo_fill_color, i_colortable, eo_colorbar, eo_data_exist, eo_min, eo_max
            if eo_data_exist eq 1 then begin
             for i=0,n_elements(eo_lon)-1 do begin
              plots,eo_lon[i], eo_lat[i], psym=6,symsize=2,color=eo_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        
        ;CORONA LO-RES DISK H RADIANCE
          if keyword_set(corona_lo_h_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_H_RAD', mso, lh_lat, lh_lon, lh_fill_color, i_colortable, lh_colorbar, lh_data_exist, lh_min, lh_max
            if lh_data_exist eq 1 then begin
             for i=0,n_elements(lh_lon)-1 do begin
              plots,lh_lon[i], lh_lat[i], psym=6,symsize=2,color=lh_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
         endif
        
        ;CORONA LO-RES DISK CO RADIANCE
          if keyword_set(corona_lo_co_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_CO_RAD', mso, lco_lat, lco_lon, lco_fill_color, i_colortable, lco_colorbar, lco_data_exist, lco_min, lco_max
            if lco_data_exist eq 1 then begin
             for i=0,n_elements(lco_lon)-1 do begin
              plots,lco_lon[i], lco_lat[i], psym=6,symsize=2,color=lco_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        ;CORONA LO-RES DISK NO RADIANCE
          if keyword_set(corona_lo_no_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_NO_RAD', mso, lno_lat, lno_lon, lno_fill_color, i_colortable, lno_colorbar, lno_data_exist, lno_min, lno_max
            if lno_data_exist eq 1 then begin
             for i=0,n_elements(lno_lon)-1 do begin
              plots,lno_lon[i], lno_lat[i], psym=6,symsize=2,color=lno_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
          endif
        
        
        ;CORONA LO-RES DISK O1304 RADIANCE
          if keyword_set(corona_lo_o_rad) then begin
            mvn_kp_map2d_iuvs_plot, iuvs, 'CORONA_LO_O_RAD', mso, lo_lat, lo_lon, lo_fill_color, i_colortable, lo_colorbar, lo_data_exist, lo_min, lo_max
            if lo_data_exist eq 1 then begin
             for i=0,n_elements(lo_lon)-1 do begin
              plots,lo_lon[i], lo_lat[i], psym=6,symsize=2,color=lo_fill_color[*,i],thick=4
             endfor
              total_colorbars = total_colorbars + 1
            endif
          endif    
    
    
    
  endelse
  

end