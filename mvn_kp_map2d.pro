;+
;
; :Name: mvn_kp_map2d
; 
; :Author: Kristopher Larsen
; 
; :Description:
;   This routine will produce a 2d map of Mars, either in planetocentric or the MSO coordinate system, with the 
;   MAVEN orbital projection and a variety of basemaps (including IUVS Apoapse images). The spacecraft's orbital path may be colored by a given
;   insitu Key Parameter data valuu. Additionally, IUVS single point observations may be displayed as well. 
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data.
;    iuvs: in, optional, type=structure
;       optional IUVS data structure for overplotting of relevant parameters.
;    parameter: in, optional, type=integer/string
;       the name or index of the insitu parameter to be plotted (if not selected, only orbital track shown).
;    time: in, optional, type=strarr(2)
;       an array that defines the start and end times to be plotted.
;    orbit: in, optional, type=intarr(2)
;       an array that defines the start and end orbit indices to be plotted.
;    basemap: in, optional, type=string
;       the name of the basemap to display. If not included, then lat/long grid is shown .
;         'MDIM': The Mars Digital Image Model.
;         'MOLA': Mars Topography in color.
;         'MOLA_BW': Mars topography in black and white.
;         'MAG':  Mars crustal magnetism.
;         'DUST': IUVS Apopase Dust index image.
;         'OZONE': IUVS Apopase Ozone index image.
;         'RAD_H': IUVS Apopase H Radiance image.
;         'RAD_O': IUVS Apopase O Radiance image.
;         'RAD_CO': IUVS Apopase CO Radiance image.
;         'RAD_NO': IUVS Apopase NO Radiance image.
;         'USER': User definied basemap. Will open a file dialog window to select the image. 
;    colors: in, optional, type=string/integer
;       the name (bw, red) or index of the color table to use when plotting the selected parameter.
;    i_colortable:  in, optiona, type=integer
;       The index of the IDL colortable by which to plot the IUVS data values.
;    alpha: in, optional, type=integer
;       the transparency of the basemap between 0(opaque) and 100(transparent), defaults to 0 (opaque)     .  
;    map_limit: in, optional, type=fltarr
;       An array that defines the limits of the user selected basemap. It is defined as follows:
;         [lower left corner latitude, lower left corner longitude, upper right corner latitude, upper right corner longitude] 
;    map_location: in, optional, type=fltarr
;       An array that defines the location of the user selected basemap.
;         [lower left corner latitude, lower left corner longitude]
;    map_projection: in, optional, type=string
;       The name of one of IDL's given map projections
;    apopase_time:  in, optional, either a string or long integer 
;       The time of the aopapse image to display. If not defined, the middle image is selected (unless apoapse_blend is included)
;       
;       
;       
; :Keywords:
;    list: in, optional, type=boolean
;       if selected, will list the KP data fields included in kp_data.
;    range: in, optional, type=boolean
;       if selected, will list the beginning and end times of kp_data.
;    nopath:  in, optional, type=boolean
;       This will suppress the display of the spacecraft orbital track projection.
;    periapse_temp: in, optional, type=boolean
;       If included, the IUVS periapse temperature measurements will be plotted on the map along with the spacecraft track.
;    optimize: in, optional, type=boolean
;       For large data structures, the plotting of the orbital track can get very slow. This keyword decimates the track to a managable size.
;    direct: in, optional, type=boolean
;       Forces the use of direct graphics instead of function.
;    log: in, optional, type=boolean
;       Colors the spacecraft track with a logarithmic stretch instead of linear.
;    subsolar: in, optional, type=boolean
;       in selected, will plot the subsolar track.
;    mso: in, optional, type=boolean 
;       switch between GEO and MSO map projections.
;       Basemaps are not projected into MSO coordinate systems so will display only as lat/long grids.
;    corona_lo_dust: in, optional, type=boolean
;       Plots the IUVS Lo-Res coronal dust depth measurements. 
;    corona_lo_ozone: in, optional, type=boolean
;       Plots the IUVS Lo-Res coronal ozone depth measurements. 
;    corona_lo_aurora: in, optional, type=boolean
;       Plots the IUVS Lo-Res coronal auroral index measurements. 
;    corona_lo_h_rad: in, optional, type=boolean
;       Plots the IUVS Lo-Res coronal H radiance measurements.   
;    corona_lo_co_rad: in, optional, type=boolean
;       Plots the IUVS Lo-Res coronalCO radiance measurements. 
;    corona_lo_no_rad: in, optional, type=boolean
;       Plots the IUVS Lo-Res coronal NO radiance measurements. 
;    corona_lo_o_rad: in, optional, type=boolean 
;       Plots the IUVS Lo-Res coronal O radiance measurements. 
;    corona_e_h_rad: in, optional, type=boolean 
;       Plots the IUVS Echelle coronal H Radiance measurements. 
;    corona_e_d_rad: in, optional, type=boolean
;       Plots the IUVS Echelle coronal D Radiance measurements. 
;    corona_e_o_rad: in, optional, type=boolean
;       Plots the IUVS Echelle coronal O Radiance measurements. 
;    apoapse_blend: in, optional, type=boolean
;       If an IUVS apaopase image is selected as the basemap, this keyword will average all images into a
;       single basemap, instead of plotting only a single image. 
;    apoapse_time:  in, optional, type=string
;       Time of an IUVS Apoapse image to display
;    minimum: in, optional, type=float
;       Minimum value to display 
;    maximum: in, optional, type=float
;       Maximum value to display
;    help: in, optiona, type=byte
;       Invoke the help listing
;    
;  :Version:  1.0   July 8, 2014
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
@mvn_kp_oplotimage

pro MVN_KP_MAP2D, kp_data, parameter=parameter, iuvs=iuvs, time=time, orbit=orbit, list=list, basemap=basemap, $
                  colors=colors, range=range, subsolar=subsolar,alpha = alpha, mso=mso, nopath=nopath, $
                  periapse_temp=periapse_temp, optimize=optimize, direct=direct, log=log, i_colortable=i_colortable, $
                  corona_lo_dust=corona_lo_dust,corona_lo_ozone=corona_lo_ozone, corona_lo_aurora=corona_lo_aurora, $
                  corona_lo_h_rad=corona_lo_h_rad, corona_lo_co_rad=corona_lo_co_rad, corona_lo_no_rad=corona_lo_no_rad, $
                  corona_lo_o_rad=corona_lo_o_rad, corona_e_h_rad=corona_e_h_rad, corona_e_d_rad=corona_e_d_rad, corona_e_o_rad=corona_e_o_rad, $
                  map_limit=map_limit, map_location=map_location, map_projection=map_projection, apoapse_blend=apoapse_blend, apoapse_time=apoapse_time, $
                  minimum=minimum, maximum=maximum, help=help
           
   common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr        
   !p.multi=0             

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    print,'MVN_KP_MAP2D'
    print,'    This routine will produce a 2d map of Mars, either in planetocentric or the MSO coordinate system, with the '
    print,'    MAVEN orbital projection and a variety of basemaps (including IUVS Apoapse images). The spacecraft orbital path may be colored by a given'
    print,'    insitu Key Parameter data valuu. Additionally, IUVS single point observations may be displayed as well. '
    print,''
    print,'mvn_kp_map2d, kp_data, parameter=parameter, iuvs=iuvs, time=time, orbit=orbit, list=list, basemap=basemap, $;
    print,'              colors=colors, range=range, subsolar=subsolar,alpha = alpha, mso=mso, nopath=nopath, $;
    print,'              periapse_temp=periapse_temp, optimize=optimize, direct=direct, log=log, i_colortable=i_colortable, $;
    print,'              corona_lo_dust=corona_lo_dust,corona_lo_ozone=corona_lo_ozone, corona_lo_aurora=corona_lo_aurora, $;
    print,'              corona_lo_h_rad=corona_lo_h_rad, corona_lo_co_rad=corona_lo_co_rad, corona_lo_no_rad=corona_lo_no_rad, $;
    print,'              corona_lo_o_rad=corona_lo_o_rad, corona_e_h_rad=corona_e_h_rad, corona_e_d_rad=corona_e_d_rad, corona_e_o_rad=corona_e_o_rad, $;
    print,'              map_limit=map_limit, map_location=map_location, apoapse_blend=apoapse_blend, apoapse_time=apoapse_time, $;
    print,'              minimum=minimum, maximum=maximum, help=help;
    print,''
    print,'REQUIRED FIELDS'
    print,'**************'
    print,'  kp_data: In-situ Key Parameter Data Structure'
    print,''
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'  Parameter: IN-situ Key Parameter by which to color the spacecraft trajectory. 
    print,'  iuvs: The IUVS data structure, needed if the user wishes to plot IUVS data.'
    print,'  time:
    print,'  orbit
    print,'  list: if selected, will list the KP data fields included in kp_data.
    print,'  range: if selected, will list the beginning and end times of kp_data.
    print,'  nopath:  This will suppress the display of the spacecraft orbital track projection.
    print,'  periapse_temp: If included, the IUVS periapse temperature measurements will be plotted on the map along with the spacecraft track.
    print,'  optimize: For large data structures, the plotting of the orbital track can get very slow. This keyword decimates the track to a managable size.
    print,'  direct: Forces the use of direct graphics instead of function.
    print,'  log: Colors the spacecraft track with a logarithmic stretch instead of linear.
    print,'  subsolar: in selected, will plot the subsolar track.
    print,'  mso: switch between GEO and MSO map projections. Basemaps are not projected into MSO coordinate systems so will display only as lat/long grids.
    print,'  corona_lo_dust: Plots the IUVS Lo-Res coronal dust depth measurements. 
    print,'  corona_lo_ozone: Plots the IUVS Lo-Res coronal ozone depth measurements. 
    print,'  corona_lo_aurora: Plots the IUVS Lo-Res coronal auroral index measurements. 
    print,'  corona_lo_h_rad: Plots the IUVS Lo-Res coronal H radiance measurements.   
    print,'  corona_lo_co_rad: Plots the IUVS Lo-Res coronalCO radiance measurements. 
    print,'  corona_lo_no_rad: Plots the IUVS Lo-Res coronal NO radiance measurements. 
    print,'  corona_lo_o_rad: Plots the IUVS Lo-Res coronal O radiance measurements. 
    print,'  corona_e_h_rad: Plots the IUVS Echelle coronal H Radiance measurements. 
    print,'  corona_e_d_rad: Plots the IUVS Echelle coronal D Radiance measurements. 
    print,'  corona_e_o_rad: Plots the IUVS Echelle coronal O Radiance measurements. 
    print,'  apoapse_blend: If an IUVS apaopase image is selected as the basemap, this keyword will average all images into a single basemap, instead of plotting only a single image. 
    print,'  apoapse_time:  Time of an IUVS Apoapse image to display
    print,'  minimum: Minimum value to display 
    print,'  maximum: Maximum value to display
    print,'  help: Invoke this list.'
    return
  endif

                
;DETERMINE THE INSTALL DIRECTORY SO THE BASEMAPS CAN BE FOUND
     install_result = routine_info('mvn_kp_map2d',/source)
     install_directory = strsplit(install_result.path,'mvn_kp_map2d.pro',/extract,/regex)
     if !version.os_family eq 'unix' then begin
      install_directory = install_directory+'basemaps/'          
     endif else begin
      install_directory = install_directory+'basemaps\'
     endelse        
     
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
  
  if Float(!Version.Release) ge 8.2 then begin
    version_check = 1
  endif else begin
    version_check = 0
  endelse  
    
;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET

    if arg_present(list)  then begin  
      list = strarr(250)
      index2=0
      for i=0,base_tag_count-1 do begin
          if first_level_count[i] ne 0 then begin
              for j=0,first_level_count[i]-1 do begin
                if first_level_count[i] ne 0 then begin 
                    list[index2] = '#'+strtrim(string(index2+1),2)+' '+base_tags[i]+'.'+strtrim(string(first_level_tags[index2-1]),2)
                    index2 = index2+1
                endif 
              endfor
          endif
        endfor
      list = list[0:index2-1]
      return
    endif else begin
      if keyword_set(list) then begin
        MVN_KP_TAG_LIST, kp_data, base_tag_count, first_level_count, base_tags,  first_level_tags
        return
      endif
    endelse

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
  
  ;IF APOAPSE TIMES NOT SELECTED, CALCULATE MIDPOINTS
  if keyword_set(apoapse_time) then begin
    apoapse_time_index = time_double(apoapse_time, tformat='YYYY-MM-DDThh:mm:ss')
    if (apoapse_time_index le begin_time) or (apoapse_time_index ge end_time) then begin
      print,'Selected Apopapse image time falls outside the included data range.'
      apoapse_time_index = (end_time - begin_time)/2l
    endif
  endif else begin
    apoapse_time_index = (end_time - begin_time)/2l
  endelse
  
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
  
  if keyword_set(optimize) eq 1 then begin
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
       map_limit = [-90,0,90,360]
       map_location = [0,-90]
       map_projection  = 'Equirectangular'
     endif
     if basemap eq 'mola' then begin
       mapimage = FILEPATH('MOLA_color_2500x1250.jpg',root_dir=install_directory)  
       read_jpeg,mapimage,mapimage
       map_limit = [-90,-0,90,360]
       map_location = [-180,-90]
       map_projection  = 'Equirectangular'
     endif 
     if basemap eq 'mola_bw' then begin
       mapimage = FILEPATH('MOLA_BW_2500x1250.jpg',root_dir=install_directory) 
       read_jpeg,mapimage,mapimage 
       map_limit = [-90,0,90,360]
       map_location = [-180,-90]
       map_projection  = 'Equirectangular'
     endif 
     if basemap eq 'mag' then begin
       mapimage = FILEPATH('MAG_Connerny_2005.jpg',root_dir=install_directory)
       read_jpeg,mapimage,mapimage
       map_limit = [-90,0,90,360]
       map_location = [0,-90]      
       map_projection  = 'Equirectangular'
     endif
     if basemap eq 'dust' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'DUST_DEPTH')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory) 
          read_jpeg,mapimage,mapimage
          map_limit = [-90,0,90,360]
          map_location = [0,-90] 
        endif else begin
            mapimage = bytarr(3,90,45)
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.dust_depth, mapimage, 1, time, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.dust_depth, mapimage, 0, apoapse_time_index, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endelse
            map_limit = [-90,-180,90,180]
            map_location = [-180,-90]
        endelse
       endif
     endif
     if basemap eq 'ozone' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'OZONE_DEPTH')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory) 
          read_jpeg,mapimage,mapimage
          map_limit = [-90,0,90,360]
          map_location = [0,-90] 
        endif else begin
          mapimage = bytarr(3,90,45)
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.ozone_depth, mapimage, 1, time, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, iuvs.apoapse.ozone_depth, mapimage, 0, apoapse_time_index, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endelse
            map_limit = [-90,-180,90,180]
            map_location = [-180,-90]
        endelse      
      endif
     endif
     if basemap eq 'rad_h' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory) 
          read_jpeg,mapimage,mapimage
          map_limit = [-90,0,90,360]
          map_location = [0,-90] 
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[0,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, apoapse_time_index, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endelse
            map_limit = [-90,-180,90,180]
            map_location = [-180,-90]
        endelse      
      endif
     endif
     if basemap eq 'rad_o' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory) 
          read_jpeg,mapimage,mapimage
          map_limit = [-90,0,90,360]
          map_location = [0,-90] 
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[1,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, apoapse_time_index, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endelse
            map_limit = [-90,-180,90,180]
            map_location = [-180,-90]
        endelse      
      endif
     endif
     if basemap eq 'rad_co' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory) 
          read_jpeg,mapimage,mapimage
          map_limit = [-90,0,90,360]
          map_location = [0,-90] 
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[2,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, apoapse_time_index, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endelse
            map_limit = [-90,-180,90,180]
            map_location = [-180,-90]
        endelse      
      endif
     endif
     if basemap eq 'rad_no' then begin
      tag_check = tag_names(iuvs.apoapse)
      t1 = where(tag_check eq 'RADIANCE')
      if t1 ne -1 then begin
        if keyword_set(iuvs) ne 1 then begin
          print,'No IUVS data selected, skipping the basemap.'
          mapimage = FILEPATH('empty.jpg',root_dir=install_directory) 
          read_jpeg,mapimage,mapimage
          map_limit = [-90,0,90,360]
          map_location = [0,-90] 
        endif else begin
          mapimage = bytarr(3,90,45)
          rad_data = reform(iuvs.apoapse.radiance[3,*,*])
          if keyword_set(apoapse_blend) then begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 1, time, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endif else begin
            MVN_KP_3D_APOAPSE_IMAGES, rad_data, mapimage, 0, apoapse_time_index, iuvs.apoapse.time_start, iuvs.apoapse.time_stop, 1
          endelse
            map_limit = [-90,-180,90,180]
            map_location = [-180,-90]
        endelse      
      endif
     endif
     if basemap eq 'user' then begin
        input_file = dialog_pickfile(path=install_directory,filter='*.jpg')
        if input_file ne '' then read_jpeg,input_file,mapimage
        if keyword_set(map_limit) eq 0 then begin
          map_limit = [-90,-180,90,180]
        endif
        if keyword_set(map_location) eq 0 then begin
          map_location = [-180,-90]
        endif
        if keyword_set(map_projection) eq 0 then begin
          map_projection  = 'Equirectangular'
        endif
     endif
      if keyword_set(direct) eq 0 then begin
        i = image(mapimage, position=[.15,.1,.85,.9],image_dimensions=[360,180])
        mp = map(map_projection, limit = map_limit, /box_axes, position=[.15,.1,.85,.9],/current)
        mp.limit = map_limit
        plot_color = "White"
      endif
    endif else begin
      mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)  
      if keyword_set(direct) eq 0 then begin
        i = image(mapimage, axis_style=2,LIMIT=[-90,-180,90,180], GRID_UNITS=2, IMAGE_LOCATION=[-180,-90], IMAGE_DIMENSIONS=[360,180],$
                  map_projection  = 'Equirectangular',margin=0,window_title="MAVEN Orbital Path",/nodata,transparency=alpha)
        plot_color = "Black"
      endif    
     endelse
  endif else begin      ;blank canvas for the MSO plot
    if keyword_set(basemap) then begin
      if basemap eq 'user' then begin
        input_file = dialog_pickfile(path=install_directory,filter='*.jpg')
        read_jpeg,input_file,mapimage
        if keyword_set(map_limit) eq 0 then begin
          map_limit = [-90,-180,90,180]
        endif
        if keyword_set(map_location) eq 0 then begin
          map_location = [-180,-90]
        endif
     endif
    endif else begin
      mapimage = FILEPATH('MDIM_2500x1250.jpg',root_dir=install_directory)  
      if keyword_set(direct) eq 0 then begin
        i = image(mapimage, position=[.15,.1,.85,.9],image_dimensions=[360,180],window_title="MAVEN Orbital Path",/nodata,transparency=alpha)
        mp = map('Equirectangular', limit = map_limit, /box_axes, position=[.15,.1,.85,.9],/current)
        mp.limit = [-90,-180,90,180]
        plot_color = "Black"
      endif
    endelse
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
  if keyword_set(minimum) then begin
    parameter_minimum = minimum
  endif else begin
    parameter_minimum = min(kp_data1.(level0_index).(level1_index))
  endelse
  if keyword_set(maximum) then begin
    parameter_maximum = maximum
  endif else begin  
    parameter_maximum = max(kp_data1.(level0_index).(level1_index))
  endelse 
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
          p = plot(longitude, latitude, /overplot, margin=0, linestyle=6, color=plot_color, name='track')
          if keyword_set(nopath) eq 0 then begin
            p_symbols = symbol(longitude,latitude, "thin_diamond", /data, sym_color=color_levels, sym_filled=1,name='track_colors')
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
            if version_check eq 1 then begin
              MVN_KP_MAP2D_COLORBAR_POS, total_colorbars, positions
              color_bar_index = 0
              if keyword_set(nopath) eq 0 then begin
                ;CHECK FOR ALL NAN VALUE DEGENERATE CASE
                            nan_error_check = 0
                            for i=0,n_elements(kp_data1.(level0_index).(level1_index))-1 do begin
                              var1 = finite(kp_data1[i].(level0_index).(level1_index))
                              if var1 eq 1 then nan_error_check=1 
                            endfor
                            if nan_error_check eq 1 then begin
                              var1 = finite(kp_data1.(level0_index).(level1_index))
                              if min(kp_data1[where(var1 ne 0)].(level0_index).(level1_index)) ne max(kp_data1[where(var1 ne 0)].(level0_index).(level1_index)) then begin
                                c = COLORBAR(TITLE=strupcase(string(tag_array[0]+'.'+tag_array[1])),rgb_table=11,ORIENTATION=0, position=positions[color_bar_index,*],TEXTPOS=0,$
                                    /border,range=[parameter_minimum,parameter_maximum])
                              endif
                            endif
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
               charthick=2, xthick=2, ythick=2,color='000000'xL,background='FFFFFF'xL,xrange=[0,360]
          if keyword_set(mso) eq 0 then begin
           if keyword_set(basemap) then begin
            mvn_kp_oplotimage,mapimage,imgxrange=[0,360],imgyrange=[-90,90]
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