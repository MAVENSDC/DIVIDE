;+
;
; :Name: mvn_kp_altplot
; 
; :Author: Kristopher Larsen
;   
; :Description:
;   This simple routine plots one or more altitude profiles from the insitu KP data structure.
;   Any data fields may be plotted together, on individual or single plots, using both direct and function graphics. 
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data
;    parameter: in, required, type=strarr,intarr
;       the INSITU kp data fields to plot, maybe an integer or string array for multiple choices
;    time: in, optional, can be a scalar or a two item array of type:
;         long(s)        orbit number
;         string(s)      format:  YYYY-MM-DD/hh:mm:ss       
;       A start or start & stop time (or orbit #) range for reading kp data. 
;    xrange: in, optional, type=fltarr
;       Minimum and maximum range for the x-axis. If multiple plots are included, the number of xrange arrays must match.
;    yrange: in, optional, type=fltarr
;       Minimum and maximum range for the y-axis. If multiple plots are included, the number of yrange arrays must match.
;
; 
; :Keywords:
;    list: in, optional, type=boolean
;       Used to print out the contents of the input data structure.
;           If set as a keyword, /list, this is printed to the screen.
;           If set as a variable, list=list, a string array is returned containing the structure index and tag names.
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
;    xlog: in, optional, type=boolean
;       if selected, will force the x-axis to logarithmic scale
;    ylog: in, optional, type=boolean
;       if selected, will force the y-axis to logarithmic scale
;    davin: in, optional, type=boolean
;       As requested by Davin Larson, this keyword will flip the X and Y axis of each plot.
;       
; :Version:   1.0     July 8, 2014
;-
@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_range_select
@mvn_kp_tag_verify

pro MVN_KP_ALTPLOT, kp_data, parameter, time=time, list=list, range=range, $
                    title=title,thick=thick,linestyle=linestyle,symbol=symbol,$
                    directgraphic=directgraphic, xlog=xlog, ylog=ylog, xrange=xrange, yrange=yrange,$
                    davin=davin, y_labels=y_labels, _extra = e, help=help


  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    print,'MVN_KP_ALTPLOT'
    print,'  This simple routine plots one or more altitude profiles from the insitu KP data structure.
    print,'  Any data fields may be plotted together, on individual or single plots, using both direct and function graphics.
    print,''
    print,'mvn_kp_altplot, kp_data, parameter, time=time, list=list, range=range, $'
    print,'              title=title,thick=thick,linestyle=linestyle,symbol=symbol,$'
    print,'              directgraphic=directgraphic, xlog=xlog, ylog=ylog, xrange=xrange, yrange=yrange,$'
    print,'              davin=davin, y_labels=y_labels, _extra = e, help=help'
    print,''
    print,'REQUIRED FIELDS'
    print,'**************'
    print,'  kp_data: In-situ Key Parameter Data Structure'
    print,'  parameter: Key Parameter value to be plotted. Either name or index. Single or multiple. See User Guide for more details.'
    print,''
    print,'OPTIONAL FIELDS'
    print,'***************'
    print,'  time: Range of times to plot.'
    print,'  list: Display list of parameters in the data structure.'
    print,'  range: Display the beginning and end times of the data structure.'
    print,'  title: Optional overall plot title.'
    print,'  thick: Set the thickness of the plotted line.'
    print,'  linestyle: Use the IDL linestyles for plotting.'
    print,'  symbol: Use IDL symbols for plotting.'
    print,'  directgraphic: Override the default Function Graphics and use direct graphics.'
    print,'  xlog: Plot on a logarthmic axis (X).'
    print,'  ylog: Plot on a logarthmix axis (Y).'
    print,'  xrange: Set the displayed x-axis range.'
    print,'  yrange: Set the displayed y-axis range.'
    print,'  davin: Swap the X and Y axes so that altitude is shown as the dependent variable.'
    print,'  x_labels: Change the displayed X-axis labels.'
    print,'  y_labels: Change the displayed Y-axis labels.'
    print,'  _extra: Use any of the other IDL graphics options. '
    print,'  help: Invoke this list.'
    return
  endif


  ;CHECK THAT THE INPUT PARAMETERS ARE VALID
  ;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

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
  if keyword_set(xlog) eq 1 then xaxis_log = 1
  if keyword_set(xlog) eq 0 then xaxis_log = 0
  if keyword_set(ylog) eq 1 then yaxis_log = 1
  if keyword_set(ylog) eq 0 then yaxis_log = 0
  if keyword_set(directgraphic) eq 0 then begin
   if Float(!Version.Release) GE 8.0 THEN directgraphic = 0    ;USE DIRECT GRAPHICS IF USER HAS OLD VERSION OF IDL
  endif
  
  ;CHECK THAT, IF INCLUDED, XRANGE AND YRANGE CONTAIN SUFFICIENT DATA
  if keyword_set(yrange) then begin
    if (n_elements(yrange)/n_elements(parameter)) ne 2 then begin
      print,'When using the YRANGE keyword, ranges must be set for each plot'
      return    
    endif
  endif
  if keyword_set(xrange) then begin
    if (n_elements(xrange)/n_elements(parameter)) ne 2 then begin
      print,'When using the XRANGE keyword, ranges must be set for each plot'
      return    
    endif
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
      pos = strpos(parameter,',')      ;check if there's more than one parameter being overplot
      if pos ne -1 then goto,overplots      
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
      w = window(window_title='Maven KP Data Altitude Plots')
      if keyword_set(davin) then begin
        plot1 = plot(y,x,xtitle='Spacecraft Altitude, km',ytitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
             title=title,thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, /current,xrange=yrange, yrange=xrange,$
             xstyle=1, ystyle=1, _extra = e)
      endif else begin
        plot1 = plot(x,y,ytitle='Spacecraft Altitude, km',xtitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                     title=title,thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, /current,xrange=xrange, yrange=yrange,$
                     xstyle=1, ystyle=1, _extra = e)
      endelse
    endif
  endif
  if directgraphic ne 0 then begin                                    ;USE THE OLD DIRECT GRAPHICS PLOT PROCEDURES
    if n_elements(parameter) eq 1 then begin
      device,decomposed=0
      loadct,0,/silent
      !P.MULTI = [0, n_elements(parameter), 1]
      if keyword_set(davin) then begin
        plot,y,x,xtitle='Spacecraft Altitude, km', ytitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                     title=title,thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background=255, color=0,$
                     xrange=yrange,yrange=xrange,xstyle=1,ystyle=1, _extra = e
      endif else begin
        plot,x,y,ytitle='Spacecraft Altitude, km', xtitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                     title=title,thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background=255, color=0,$
                     xrange=xrange,yrange=yrange,xstyle=1,ystyle=1, _extra = e
      endelse
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


          ;CREATE DUMMY YRANGE IF NOT DEFINED
          temp_yrange = dblarr(2,n_elements(parameter))
          if n_elements(yrange) ne 0 then begin
            temp_yrange = yrange
          endif else begin
            for i=0,n_elements(parameter)-1 do begin
              temp_yrange[0,i] = min(y[*])
              temp_yrange[1,i] = max(y[*])
            endfor
          endelse
          ;CREATE DUMMY XRANGE IF NOT DEFINED
          temp_xrange = dblarr(2,n_elements(parameter))
          if n_elements(xrange) ne 0 then begin
            temp_xrange = xrange
          endif else begin
            for i=0,n_elements(parameter)-1 do begin
              temp_xrange[0,i] = min(x[i,*])
              temp_xrange[1,i] = max(x[i,*])
            endfor
          endelse
         
          
  ;CREATE THE MULTPLE ALTITUDE PLOT  
  if directgraphic eq 0 then begin                                    ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
    if n_elements(parameter) gt 1 then begin
      w = window(window_title='Maven KP Data Altitude Plots')
      for i = 0, n_elements(parameter) -1 do begin
        if keyword_set(davin) then begin
         plot1 = plot(y,x[i,*], xtitle='Spacecraft Altitude, km', ytitle=x_axis_title[i], layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xstyle=1,ystyle=1,xrange=temp_yrange[*,i],$
                      yrange=temp_xrange[*,i], _extra = e) 
        endif else begin
         plot1 = plot(x[i,*], y, ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[i], layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xstyle=1,ystyle=1,yrange=temp_yrange[*,i],$
                      xrange=temp_xrange[*,i], _extra = e)
        endelse
      endfor
    endif
  endif
  if directgraphic ne 0 then begin                                    ;PLOT USING THE OLD IDL DIRECT GRAPHICS
          device,decomposed=0
          loadct,0,/silent
    if n_elements(parameter) gt 1 then begin
      !P.MULTI = [0, n_elements(parameter), 1]
      if keyword_set(davin) then begin
         plot,y,x[0,*],xtitle='Spacecraft Altitude, km', ytitle=x_axis_title[0],xstyle=1,ystyle=1,$
                      title=title[0],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background=255,color=0,charsize=2,font=-1,$
                      xrange=temp_yrange[*,0],yrange=temp_xrange[*,0], _extra = e
        for i=1,n_elements(parameter)-1 do begin
         plot,y,x[i,*],xtitle='Spacecraft Altitude, km', ytitle=x_axis_title[i],xstyle=1,ystyle=1,$
                      title=title[i],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, color=0,charsize=2,font=-1,$
                      xrange=temp_yrange[*,i],yrange=temp_xrange[*,i], _extra = e
        endfor 
      endif else begin
        plot,x[0,*],y,ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[0],xstyle=1,ystyle=1,$
                      title=title[0],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background=255,color=0,charsize=2,font=-1,$
                      yrange=temp_yrange[*,0],xrange=temp_xrange[*,0], _extra = e
        for i=1,n_elements(parameter)-1 do begin
         plot,x[i,*],y,ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[i],xstyle=1,ystyle=1,$
                      title=title[i],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, color=0,charsize=2,font=-1,$
                      yrange=temp_yrange[*,i],xrange=temp_xrange[*,i], _extra = e
        endfor 
      endelse
    endif
  endif
  return       ;SKIP OVER THE OVERPLOT OPTIONS
  
  
overplots: ;BEGIN SEPARATE ROUTINES IF ANY OVERPLOTTING IS REQUIRED.

  ;ANALYZE TEH INPUT STRINGS TO DETERMINE PARAMETERS AND SIZES
    
    plot_count =intarr(n_elements(parameter))
    total_lines = 0
    true_index = intarr(50)
    
    
    for i=0, n_elements(parameter)-1 do begin
      check = strmatch(parameter[i],'*,*')
      if check eq 1 then begin                      ;over plots 
        extract = strmid(strsplit(parameter[i],',',/extract) ,0,1)
        new_param = strsplit(parameter[i],',',/extract)
        for j=0,n_elements(extract)-1 do begin
          if strmatch(extract[j],'[0123456789]') eq 1 then begin        ;structure index call
            true_index[total_lines] = fix(new_param[j])
          endif else begin                      ;call based on structure names
            mvn_kp_structure_index, kp_data, new_param[j], new_index, first_level_tags
            true_index[total_lines] = new_index            
          endelse
          total_lines = total_lines+1
          plot_count[i] = plot_count[i]+1
        endfor    
      endif else begin                              ;single plots
        extract = strmid(parameter[i],0,1)
        new_param = strsplit(parameter[i],',',/extract)
        if strmatch(extract,'[0123456789]') eq 1 then begin       ;structure index call
          true_index[total_lines] = fix(parameter[i])
        endif else begin                        ;structure name call
          mvn_kp_structure_index, kp_data, new_param, new_index, first_level_tags
          true_index[total_lines] = new_index
        endelse
        total_lines = total_lines + 1
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
  

       ;CREATE DUMMY YRANGE IF NOT DEFINED
          temp_yrange = dblarr(2,n_elements(true_index))
          if n_elements(yrange) ne 0 then begin
            temp_yrange = yrange
          endif else begin
            for i=0,n_elements(true_index)-1 do begin
              temp_yrange[0,i] = min(y)
              temp_yrange[1,i] = max(y)
            endfor
          endelse
       ;CREATE DUMMY XRANGE IF NOT DEFINED
          temp_xrange = dblarr(2,n_elements(true_index))
          if n_elements(xrange) ne 0 then begin
            temp_xrange = xrange
          endif else begin
            for i=0,n_elements(true_index)-1 do begin
              temp_xrange[0,i] = min(x[i,*])
              temp_xrange[1,i] = max(x[i,*])
            endfor
          endelse  
  


  ;CREATE THE PLOTS
  
  if directgraphic eq 0 then begin
  ;   if n_elements(parameter) gt 1 then begin
      oplot_index = 0
       w = window(window_title='Maven KP Data Altitude Plots')
      for i = 0, n_elements(parameter) -1 do begin
        if keyword_set(davin) then begin
          if plot_count[i] eq 1 then begin
            plot1 = plot(y,x[oplot_index,*], xtitle='Spacecraft Altitude, km', ytitle=x_axis_title[oplot_index], layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xstyle=1,ystyle=1,yrange=temp_xrange[*,oplot_index],$
                      xrange=temp_yrange[*,oplot_index], _extra = e)
            oplot_index= oplot_index+1
          endif else begin
            plot1 = plot(y,x[oplot_index,*], xtitle='Spacecraft Altitude, km', layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=0,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, yrange=temp_xrange[*,oplot_index],xstyle=1,ystyle=1,$
                      xrange=temp_yrange[*,oplot_index],name=x_axis_title[oplot_index], _extra = e)
            l = legend(target=plot1,position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85],$
                      /normal,linestyle=0,font_size=8)
            oplot_index = oplot_index+1
            hold_index = oplot_index-1
            for j=1,plot_count[i]-1 do begin      
              plot1 = plot(y,x[oplot_index,*], xtitle='Spacecraft Altitude, km', layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=j,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xstyle=1,ystyle=1,yrange=temp_xrange[*,hold_index],$
                      name=x_axis_title[oplot_index], xrange=temp_yrange[*,hold_index], _extra = e)
               l = legend(target=plot1,position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85+(j*0.05)],$
                      /normal,linestyle=j,font_size=8)
              oplot_index=oplot_index+1
            endfor    
          endelse
        endif else begin
          if plot_count[i] eq 1 then begin
            plot1 = plot(x[oplot_index,*], y, ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[oplot_index], layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xstyle=1,ystyle=1,xrange=temp_xrange[*,oplot_index],$
                      yrange=temp_yrange[*,oplot_index], _extra = e)
            oplot_index= oplot_index+1
          endif else begin
            plot1 = plot(x[oplot_index,*], y, ytitle='Spacecraft Altitude, km', layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=0,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xrange=temp_xrange[*,oplot_index],xstyle=1,ystyle=1,$
                      yrange=temp_yrange[*,oplot_index],name=x_axis_title[oplot_index], _extra = e)
            l = legend(target=plot1,position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85],$
                      /normal,linestyle=0,font_size=8)
            oplot_index = oplot_index+1
            hold_index = oplot_index-1
            for j=1,plot_count[i]-1 do begin      
              plot1 = plot(x[oplot_index,*], y, ytitle='Spacecraft Altitude, km', layout=[n_elements(parameter),1,i+1],/current,$
                      title=title[i],thick=thick,linestyle=j,symbol=symbol,xlog=xaxis_log,ylog=yaxis_log, xstyle=1,ystyle=1,xrange=temp_xrange[*,hold_index],$
                      name=x_axis_title[oplot_index], yrange=temp_yrange[*,hold_index], _extra = e)
               l = legend(target=plot1,position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85+(j*0.05)],$
                      /normal,linestyle=j,font_size=8)
              oplot_index=oplot_index+1
            endfor    
          endelse
        endelse 
      endfor
  ;  endif
  endif 
  if directgraphic eq 1 then begin
    device,decomposed=1
  ;  if n_elements(parameter) gt 1 then begin
      !P.MULTI = [0, n_elements(parameter), 1]
      oplot_index = 0 
      if keyword_set(davin) then begin
        for i = 0, n_elements(parameter) -1 do begin
          if plot_count[i] eq 1 then begin
            plot,y,x[oplot_index,*],xtitle='Spacecraft Altitude, km', xtitle=x_axis_title[oplot_index],$
                 title=title[i],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background='FFFFFF'x,color=0,$
                 font=-1,xstyle=1,ystyle=1,yrange=temp_xrange[*,oplot_index],xrange=temp_yrange[*,oplot_index], _extra = e
            oplot_index = oplot_index+1
          endif else begin 
            plot,y,x[oplot_index,*],xtitle='Spacecraft Altitude, km',$
                  title=title[oplot_index],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background='FFFFFF'x,$
                  color=0,xstyle=1,ystyle=1  ,yrange=temp_xrange[*,oplot_index],xrange=temp_yrange[*,oplot_index], _extra = e
            plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),(i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],[.81,.81],linestyle=0,color=0,/normal
            xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.8,x_axis_title[oplot_index],color=0,/normal
            oplot_index = oplot_index+1
            for j=1,plot_count[i]-1 do begin      
              oplot,y,x[oplot_index,*],linestyle=j,thick=thick,color=0
              plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),(i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],[.81+(j*0.03),.81+(j*0.03)],linestyle=j,color=0,/normal
              xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.8+(j*.03),x_axis_title[oplot_index],color=0,/normal
              oplot_index=oplot_index+1
            endfor        
          endelse 
         endfor         
      endif else begin
        for i = 0, n_elements(parameter) -1 do begin
          if plot_count[i] eq 1 then begin
            plot,x[oplot_index,*],y,ytitle='Spacecraft Altitude, km', xtitle=x_axis_title[oplot_index],$
                 title=title[i],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background='FFFFFF'x,color=0,$
                 font=-1,xstyle=1,ystyle=1,xrange=temp_xrange[*,oplot_index],yrange=temp_yrange[*,oplot_index], _extra = e
            oplot_index = oplot_index+1
          endif else begin 
            plot,x[oplot_index,*],y,ytitle='Spacecraft Altitude, km',$
                  title=title[oplot_index],thick=thick,linestyle=linestyle,xlog=xaxis_log,ylog=yaxis_log, background='FFFFFF'x,$
                  color=0,xstyle=1,ystyle=1  ,xrange=temp_xrange[*,oplot_index],yrange=temp_yrange[*,oplot_index], _extra = e
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
      endelse
     
   ; endif
  endif
  
finish:
end