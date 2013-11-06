;+
; THIS ROUTINE PLOTS ONE OR MORE ALITUDE PROFILES FROM THE INSITU KP DATA STRUCTURE
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data
;    parameter: in, required, type=strarr,intarr
;       the INSITU kp data fields to plot, maybe an integer or string array for multiple choices
;
; :Keywords:
;    time: in, optional, type=
;       if selected, plots only the given times from the data set
;    list: in, optional, type=boolean
;       if selected, will list the KP data fields included in kp_data
;    range: in, optional, type=boolean
;       if selected, will list the beginning and end times of kp_data
;    title:in, optional, type=string
;       a optional title string for the plot
;    thick: in, optional, type=integer
;       the thickness of the altitude profile lines
;    symbol: in, optional, type=integer
;       the idl symbol to be used in plotting
;    linestyle: in, optional, type=integer
;       the idl linestyle to be used in plotting
;    directgraphic: in, optional, type=boolean
;       if selected, will override teh default Graphics plot procedure and use direct graphics instead
;    log: in, optional, type=boolean
;       if selected, will plot the altitude profiles in log/linear format
;-
@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_range_select
@mvn_kp_tag_verify

pro MVN_KP_ALTPLOT, kp_data, parameter, time=time, list=list, range=range, $
                    title=title,thick=thick,linestyle=linestyle,symbol=symbol,$
                    directgraphic=directgraphic, log=log   

  ;CHECK THAT THE INPUT PARAMETERS ARE VALID
  ;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

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
  
  ;SET THE VARIOUS PLOT OPTIONS, SHOULD THEY REQUIRE IT
  if keyword_set(title) eq 0 then begin
   if n_elements(parameter) eq 1 then title=''
   if n_elements(parameter) ne 1 then title=strarr(n_elements(parameter))
  endif
  
  if keyword_set(thick) eq 0 then thick=1                     ;SET DEFAULT PLOT LINE THICKNESS
  if keyword_set(linestyle) eq 0 then linestyle=0             ;SET DEFAULT PLOT LINE STYLE
  if keyword_set(symbol) eq 0 then symbol="None"              ;SET DEFAULT PLOT SYMBOL
  if keyword_set(log) eq 1 then xaxis_log = 1
  if keyword_set(log) eq 0 then xaxis_log = 0
  if keyword_set(directgraphic) eq 0 then begin
   if Float(!Version.Release) GE 8.0 THEN directgraphic = 0    ;USE DIRECT GRAPHICS IF USER HAS OLD VERSION OF IDL
  endif
  
  ;IF THE USER SUPPLIES A TIME RANGE, SET THE BEGINNING AND END INDICES
  
  if keyword_set(time) then begin     ;determine the start and end indices to plot
    MVN_KP_RANGE_SELECT, kp_data, time, kp_start_index, kp_end_index
  endif else begin                    ;otherwise plot all data within structure
   kp_start_index = 0
   kp_end_index = n_elements(kp_data.orbit)-1
  endelse
  
  
  ;CREATE THE PLOT VECTORS
  
  if n_elements(parameter) eq 1 then begin        ;only going to plot a single altitude plot
    if size(parameter,/type) eq 2 then begin      ;INTEGER PARAMETER INDEX
          MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
       if check eq 0 then begin            ;CHECK THAT THE REQUESTED PARAMETER EXISTS

         x = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
         y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude
        
       endif else begin
         print,'Requested plot parameter is not included in the data. Try /LIST to confirm your parameter choice.'
         goto,finish
       endelse
    endif ;end of integer parameter loop
    if size(parameter,/type) eq 7 then begin      ;STRING PARAMETER NAME  
          MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array

       if check eq 1 then begin
         print,'Whoops, ',strupcase(parameter),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
         goto,finish
       endif else begin
            

         x = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
         y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude    
       endelse  
    endif ;end of string parameter loop
  endif ;end of single altitude plot loop
  
  ;CREATE SINGLE ALTITUDE PLOT
  
  if directgraphic eq 0 then begin                                    ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
    if n_elements(parameter) eq 1 then begin
     plot1 = plot(x,y,ytitle='Spacecraft Altitude, km',xtitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                   title=title,thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log)
    endif
  endif
  if directgraphic ne 0 then begin                                    ;USE THE OLD DIRECT GRAPHICS PLOT PROCEDURES
    if n_elements(parameter) eq 1 then begin
      device,decomposed=0
      !P.MULTI = [0, n_elements(parameter), 1]
      plot,x,y,ytitle='Spacecraft Altitude, km',xtitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                   title=title,thick=thick,linestyle=linestyle,xlog=xaxis_log,background=255, color=0
    endif
  endif
  
  ;CREATE MULTIPLE ALITIUDE PLOT VECTORS

  if n_elements(parameter) gt 1 then begin
    if size(parameter,/type) eq 2 then begin                                  ;INTEGER ARRAY PARAMETER LOOP
      x = fltarr(n_elements(parameter),n_elements(kp_data[kp_start_index:kp_end_index].spacecraft.altitude))
      y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude
      x_axis_title = strarr(n_elements(parameter))
      for i=0,n_elements(parameter)-1 do begin
          MVN_KP_TAG_VERIFY, kp_data, parameter[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
       if check eq 0 then begin
         x[i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
         x_axis_title[i] = strupcase(string(tag_array[0]+'.'+tag_array[1]))
       endif else begin
         print,'Requested plot parameter is not included in the data. Try /LIST to confirm your parameter choice.'
         goto,finish
       endelse
      endfor
    endif                                                                 ;END OF THE INTEGER ARRAY PARAMETER LOOP
    if size(parameter,/type) eq 7 then begin
     for i=0, n_elements(parameter) -1 do begin
      pos = strpos(parameter[i],',')
      if pos ne -1 then goto,overplots
     endfor
      x = fltarr(n_elements(parameter),n_elements(kp_data[kp_start_index:kp_end_index].spacecraft.altitude))
      y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude
      x_axis_title = strarr(n_elements(parameter))
      for i=0,n_elements(parameter)-1 do begin
          MVN_KP_TAG_VERIFY, kp_data, parameter[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
       if check eq 1 then begin
           print,'Whoops, ',strupcase(parameter[i]),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
           goto,finish
         endif else begin            
           
           x[i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
           y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude   
           x_axis_title[i] = strupcase(string(tag_array[0]+'.'+tag_array[1]))   
         endelse  
       endfor   
    endif
  endif 

  ;CREATE THE MULTPLE ALTITUDE PLOT
  
  if directgraphic eq 0 then begin                                    ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
    if n_elements(parameter) gt 1 then begin
      plot1 = plot(x[0,*],y, ytitle='Spacecraft Altitude, km',xtitle=x_axis_title[0], layout=[n_elements(parameter),1,1],nodata=1,$
                   title=title[0],xlog=xaxis_log)
      for i = 0, n_elements(parameter) -1 do begin
       plot1 = plot(x[i,*], y, ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[i], layout=[n_elements(parameter),1,i+1],/current,$
                    title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log)
      endfor
    endif
  endif
  if directgraphic ne 0 then begin                                    ;PLOT USING THE OLD IDL DIRECT GRAPHICS
          device,decomposed=0
    if n_elements(parameter) gt 1 then begin
      !P.MULTI = [0, n_elements(parameter), 1]
      plot,x[0,*],y,ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[0],$
                    title=title[0],thick=thick,linestyle=linestyle,xlog=xaxis_log,background=255,color=0,charsize=2,font=-1
      for i=1,n_elements(parameter)-1 do begin
       plot,x[i,*],y,ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[i],$
                    title=title[i],thick=thick,linestyle=linestyle,xlog=xaxis_log,color=0,charsize=2,font=-1
      endfor 
    endif
  endif
  goto,finish       ;SKIP OVER THE OVERPLOT OPTIONS
  
  
overplots: ;BEGIN SEPARATE ROUTINES IF ANY OVERPLOTTING IS REQUIRED.

  ;ANALYZE TEH INPUT STRINGS TO DETERMINE PARAMETERS AND SIZES
    
    plot_count =intarr(n_elements(parameter))
    total_lines = 0
    true_index = intarr(50)
    
    for i=0,n_elements(parameter)-1 do begin
      check = strmatch(parameter[i],'*,*')
      if check eq 1 then begin
          pos = 0
          pos1=0
        total_lines = total_lines+1
        while pos1 ne -1 do begin
          pos1 = strpos(parameter[i],',',pos)
          if pos1 ne -1 then begin
            true_index[total_lines-1] = fix(strmid(parameter[i],pos,(pos1-pos)))
            total_lines = total_lines+1
            pos=pos1+1
            plot_count[i]=plot_count[i]+1
          endif
        endwhile
        true_index[total_lines-1] = fix(strmid(parameter[i],pos,(strlen(parameter[i])-pos)))
        plot_count[i]=plot_count[i]+1
      endif else begin
        true_index[total_lines] = fix(parameter[i])
        total_lines = total_lines+1
        plot_count[i] = 1
      endelse
    endfor
 
    true_index = true_index[0:total_lines-1]

  ;CHECK PARAMETER VALIDITY AND EXTRACT DATA
  
      x = fltarr(n_elements(true_index),n_elements(kp_data[kp_start_index:kp_end_index].spacecraft.altitude))
      y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude
      x_axis_title = strarr(n_elements(true_index))
      for i=0,n_elements(true_index)-1 do begin
          MVN_KP_TAG_VERIFY, kp_data, true_index[i],base_tag_count, first_level_count, base_tags,  $
                      first_level_tags, check, level0_index, level1_index, tag_array
       if check eq 1 then begin
           print,'Whoops, ',strupcase(true_index[i]),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
           goto,finish
         endif else begin            
           
           x[i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
           y = kp_data[kp_start_index:kp_end_index].spacecraft.altitude   
           x_axis_title[i] = strupcase(string(tag_array[0]+'.'+tag_array[1]))   
         endelse  
       endfor   
  
  ;CREATE THE PLOTS
  
  if directgraphic eq 0 then begin
     if n_elements(parameter) gt 1 then begin
      oplot_index = 0
 ;     plot1 = plot(x[0,*],y, ytitle='Spacecraft Altitude, km',xtitle=x_axis_title[0], layout=[n_elements(parameter),1,1],nodata=1,$
 ;                  title=title[0],xlog=xaxis_log)
       w = window(window_title='Altitude Plots',dimensions=[800,600])
      for i = 0, n_elements(parameter) -1 do begin
        if plot_count[i] eq 1 then begin
          plot1 = plot(x[oplot_index,*], y, ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[oplot_index], layout=[n_elements(parameter),1,i+1],/current,$
                    title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log)
          oplot_index= oplot_index+1
        endif else begin
          xmin = min(x[oplot_index:(oplot_index+plot_count[i]-1)])
          xmax = max(x[oplot_index:(oplot_index+plot_count[i]-1)])
          plot1 = plot(x[oplot_index,*], y, ytitle='Spacecraft Altitude, km', layout=[n_elements(parameter),1,i+1],/current,$
                    title=title[i],thick=thick,linestyle=0,symbol=symbol,xlog=xaxis_log,xrange=[xmin,xmax])
          l = legend(target=plot1,/auto_text_color,label=x_axis_title[oplot_index],position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85],$
                    /normal,linestyle=0,font_size=8)
          oplot_index = oplot_index+1
          for j=1,plot_count[i]-1 do begin      
            plot1 = plot(x[oplot_index,*], y, ytitle='Spacecraft Altitude, km', layout=[n_elements(parameter),1,i+1],/current,$
                    title=title[i],thick=thick,linestyle=j,symbol=symbol,xlog=xaxis_log,xrange=[xmin,xmax])
             l = legend(target=plot1,/auto_text_color,label=x_axis_title[oplot_index],position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85+(j*0.05)],$
                    /normal,linestyle=j,font_size=8)
            oplot_index=oplot_index+1
          endfor    
        endelse
      endfor
    endif
  endif 
  if directgraphic eq 1 then begin
    device,decomposed=1
    if n_elements(parameter) gt 1 then begin
      !P.MULTI = [0, n_elements(parameter), 1]
      oplot_index = 0 
      for i = 0, n_elements(parameter) -1 do begin
        if plot_count[i] eq 1 then begin
          plot,x[oplot_index,*],y,ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[oplot_index],$
               title=title[i],thick=thick,linestyle=linestyle,xlog=xaxis_log,background='FFFFFF'x,color=0,$
               charsize=4,font=-1
          oplot_index = oplot_index+1
        endif else begin 
          xmin = min(x[oplot_index:(oplot_index+plot_count[i]-1)])
          xmax = max(x[oplot_index:(oplot_index+plot_count[i]-1)])
          plot,x[oplot_index,*],y,ytitle='Spacecraft Altitude, km',$
                title=title[oplot_index],thick=thick,linestyle=linestyle,xlog=xaxis_log,background='FFFFFF'x,$
                xrange=[xmin,xmax],color=0,charsize=4.
          plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),(i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],[.81,.81],linestyle=0,color=0,/normal
          xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.8,x_axis_title[oplot_index],color=0,/normal
          oplot_index = oplot_index+1
          for j=1,plot_count[i]-1 do begin      
            oplot,x[oplot_index,*],y,linestyle=j,thick=thick,color=0
            plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),(i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],[.81+(j*0.03),.81+(j*0.03)],linestyle=j,color=0,/normal
            xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.8+(j*.03),x_axis_title[oplot_index],color=0,/normal
            oplot_index=oplot_index+1
          endfor        
        endelse 
      endfor 

     
    endif
  endif
  
finish:
end