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

pro MVN_KP_PLOT, kp_data, parameter, error=error, time=time, list=list, range=range, $
                    title=title,thick=thick,linestyle=linestyle,symbol=symbol,$
                    directgraphic=directgraphic, log=log   

  ;CHECK THAT THE INPUT PARAMETERS ARE VALID
  ;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

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
  
  ;SET THE VARIOUS PLOT OPTIONS, SHOULD THEY REQUIRE IT
  if keyword_set(title) eq 0 then begin
   if n_elements(parameter) eq 1 then title=''
   if n_elements(parameter) ne 1 then title=strarr(n_elements(parameter))
  endif
  
  if keyword_set(thick) eq 0 then thick=1                     ;SET DEFAULT PLOT LINE THICKNESS
  if keyword_set(linestyle) eq 0 then linestyle=0             ;SET DEFAULT PLOT LINE STYLE
  if keyword_set(symbol) eq 0 then symbol="None"              ;SET DEFAULT PLOT SYMBOL
  if keyword_set(log) eq 1 then yaxis_log = 1
  if keyword_set(log) eq 0 then yaxis_log = 0
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
  
  if kp_start_index eq -1 or kp_end_index eq -1 then begin
    print,'Sorry, the times you requested are not contained within the data structure.'
    print,'Check your time range and try again.'
    return
  endif
  if kp_start_index eq kp_end_index then begin
    print,'Sorry, start and end times are the same. Nothing to plot!'
    return
  endif
 
  
  ;CREATE THE PLOT VECTORS
  
  overplot_check=0
  for i=0,n_elements(parameter)-1 do begin
    pos = strpos(parameter[i],',')
    if pos ne -1 then overplot_check = 1
  endfor

  if overplot_check ne 1 then begin  

        if n_elements(parameter) eq 1 then begin        ;only going to plot a single altitude plot
                                              
                MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, first_level_count, base_tags,  $
                            first_level_tags, check, level0_index, level1_index, tag_array
             if check eq 0 then begin            ;CHECK THAT THE REQUESTED PARAMETER EXISTS
      
               x = kp_data[kp_start_index:kp_end_index].time
               y = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
              
              if keyword_set(error) then begin
                mvn_kp_tag_verify, kp_data, error, base_tag_count, first_level_count, base_tags, $
                                   first_level_tags, err_check, err_level0, err_level1, temp_tag
                   if err_check eq 0 then begin
                     y_error = dblarr(2,n_elements(kp_data[kp_start_index:kp_end_index].time))      
                     y_error[0,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)-kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)               
                     y_error[1,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)+kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)   
                   endif else begin
                    print,'Requested error parameter is not included in the data structure. Try /LIST to check for it.'
                    print,'Creating requested plot WITHOUT error bars'
                   endelse            
              endif else err_check = 1
              
             endif else begin
               print,'Requested plot parameter is not included in the data. Try /LIST to confirm your parameter choice.'
               return
             endelse
        endif ;end of single altitude plot loop
        
        
        ;CREATE SINGLE  PLOT
              
        if directgraphic eq 0 then begin                                    ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
          
          if n_elements(parameter) eq 1 then begin
          ;define realistic x axis time labels
          x_labels = [time_string(x[0]),time_string(x[(n_elements(x)-1)*.25]), time_string(x[(n_elements(x)-1)/2]),time_string(x[(n_elements(x)-1)*.75]), time_string(x[n_elements(x)-1])]
           if err_check eq 0 then begin
             err_plot = errorplot(x,y,y_error,xtitle='Time',ytitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                         title=title,thick=thick,linestyle=linestyle,symbol=symbol,ylog=yaxis_log,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
           endif else begin
                 plot1 = plot(x,y,xtitle='Time',ytitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                         title=title,thick=thick,linestyle=linestyle,symbol=symbol,ylog=yaxis_log,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
    
           endelse 
          endif
        endif
        if directgraphic ne 0 then begin                                    ;USE THE OLD DIRECT GRAPHICS PLOT PROCEDURES
          if n_elements(parameter) eq 1 then begin
              ;define realistic x axis time labels
          x_labels = [time_string(x[0]),time_string(x[(n_elements(x)-1)*.25]), time_string(x[(n_elements(x)-1)/2]),time_string(x[(n_elements(x)-1)*.75]), time_string(x[n_elements(x)-1])]
            device,decomposed=0
            loadct,0,/silent
            !P.MULTI = [0, n_elements(parameter), 1]
              plot,x,y,xtitle='Time',ytitle=strupcase(string(tag_array[0]+'.'+tag_array[1])),$
                         title=title,thick=thick,linestyle=linestyle,ylog=yaxis_log,background=255, color=0
            if err_check eq 0 then begin
              errplot,x, y_error[0,*], y_error[1,*]
            endif
          endif
        endif
        
        ;CREATE MULTIPLE  PLOT VECTORS
    
        if n_elements(parameter) gt 1 then begin
          if size(parameter,/type) eq 2 then begin                                  ;INTEGER ARRAY PARAMETER LOOP
            y = fltarr(n_elements(parameter),n_elements(kp_data[kp_start_index:kp_end_index].time))
            x = kp_data[kp_start_index:kp_end_index].time
            y_axis_title = strarr(n_elements(parameter))
            if keyword_set(error) then begin
              y_error = dblarr(2,n_elements(parameter),n_elements(kp_data[kp_start_index:kp_end_index].time)) 
            endif
              err_check = intarr(n_elements(parameter))
            for i=0,n_elements(parameter)-1 do begin
                MVN_KP_TAG_VERIFY, kp_data, parameter[i],base_tag_count, first_level_count, base_tags,  $
                            first_level_tags, check, level0_index, level1_index, tag_array
             if check eq 0 then begin
               y[i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
               y_axis_title[i] = strupcase(string(tag_array[0]+'.'+tag_array[1]))
               if keyword_set(error) then begin
                   mvn_kp_tag_verify, kp_data, error[i], base_tag_count, first_level_count, base_tags, $
                                   first_level_tags, err_check[i], err_level0, err_level1, temp_tag
                   if err_check[i] eq 0 then begin                
                     y_error[0,i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)-kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)               
                     y_error[1,i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)+kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)  
                   endif else begin
                       print,'Requested error parameter is not included in the data structure. Try /LIST to check for it.'
                    print,'Creating requested plot WITHOUT error bars'
                   endelse
               endif else err_check[i]=1
             endif else begin
               print,'Requested plot parameter is not included in the data. Try /LIST to confirm your parameter choice.'
               return
             endelse
            endfor
          endif                                                                 ;END OF THE INTEGER ARRAY PARAMETER LOOP
          if size(parameter,/type) eq 7 then begin

            y = fltarr(n_elements(parameter),n_elements(kp_data[kp_start_index:kp_end_index].time))
            x = kp_data[kp_start_index:kp_end_index].time
            y_axis_title = strarr(n_elements(parameter))
            if keyword_set(error) then begin
              y_error = dblarr(2,n_elements(parameter),n_elements(kp_data[kp_start_index:kp_end_index].time)) 
            endif
              err_check = intarr(n_elements(parameter))
            for i=0,n_elements(parameter)-1 do begin
                MVN_KP_TAG_VERIFY, kp_data, parameter[i],base_tag_count, first_level_count, base_tags,  $
                            first_level_tags, check, level0_index, level1_index, tag_array
             if check eq 1 then begin
                 print,'Whoops, ',strupcase(parameter[i]),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
                 return
               endif else begin            
                 
                 y[i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
                 x = kp_data[kp_start_index:kp_end_index].time  
                 y_axis_title[i] = strupcase(string(tag_array[0]+'.'+tag_array[1]))   
                 if keyword_set(error) then begin
                   mvn_kp_tag_verify, kp_data, error[i], base_tag_count, first_level_count, base_tags, $
                                   first_level_tags, err_check[i], err_level0, err_level1, temp_tag
                   if err_check[i] eq 0 then begin                
                     y_error[0,i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)-kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)               
                     y_error[1,i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)+kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)  
                   endif else begin
                    print,'Requested error parameter is not included in the data structure. Try /LIST to check for it.'
                    print,'Creating requested plot WITHOUT error bars'
                   endelse
                 endif else err_check[i] = 1
               endelse  
             endfor   
          endif
        endif 
      
        ;CREATE THE MULTPLE  PLOT
        
      
        if directgraphic eq 0 then begin                                    ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
          x_labels = [time_string(x[0]),time_string(x[(n_elements(x)-1)*.25]), time_string(x[(n_elements(x)-1)/2]),time_string(x[(n_elements(x)-1)*.75]), time_string(x[n_elements(x)-1])]
          if n_elements(parameter) gt 1 then begin
            
            plot1 = plot(x,y[0,*], xtitle='Time',ytitle=y_axis_title[0], layout=[1,n_elements(parameter),1],nodata=1,$
                         title=title[0],ylog=yaxis_log,xmajor=5,axis_style=0,xtickname=x_labels,xtext_orientation=0,xstyle=1)
            for i = 0, n_elements(parameter) -1 do begin
              if err_check[i] ne 0 then begin
               plot1 = plot(x, y[i,*], xtitle='Time', ytitle=y_axis_title[i], layout=[1,n_elements(parameter),i+1],/current,$
                            title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,ylog=yaxis_log,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
              endif else begin
                 plot1 = errorplot(x, y[i,*],reform(y_error[*,i,*]), xtitle='Time', ytitle=y_axis_title[i], layout=[1,n_elements(parameter),i+1],/current,$
                            title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,ylog=yaxis_log,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
              endelse 
            endfor
          endif
        endif
        if directgraphic ne 0 then begin                                    ;PLOT USING THE OLD IDL DIRECT GRAPHICS
          device,decomposed=0
          !P.MULTI = [0, 1, n_elements(parameter)]
          if n_elements(parameter) gt 1 then begin
            plot,x,y[0,*],xtitle='Time', ytitle=y_axis_title[0],$
                          title=title[0],thick=thick,linestyle=linestyle,ylog=yaxis_log,background=255,color=0,charsize=2,font=-1
            if err_check[0] eq 0 then begin
              errplot,x, y_error[0,0,*], y_error[1,0,*]
            endif              
            for i=1,n_elements(parameter)-1 do begin
             plot,x,y[i,*],xtitle='Time', ytitle=y_axis_title[i],$
                          title=title[i],thick=thick,linestyle=linestyle,ylog=yaxis_log,color=0,charsize=2,font=-1
             if err_check[i] eq 0 then begin
              errplot,x, y_error[0,i,*], y_error[1,i,*]
            endif
            endfor 
          endif
        endif
        
    endif else begin
  
        
      ;overplots: ;BEGIN SEPARATE ROUTINES IF ANY OVERPLOTTING IS REQUIRED.
      
        ;ANALYZE THE INPUT STRINGS TO DETERMINE PARAMETERS AND SIZES
          
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
      
        ;same thing as above, but for the error bar options
          total_lines = 0
          true_err_index = intarr(50)
        
          if keyword_set(error) then begin
           for i=0, n_elements(error)-1 do begin
            check1 = strmatch(error[i],'*,*')
            if check1 eq 1 then begin                      ;over plots 
              extract = strmid(strsplit(error[i],',',/extract) ,0,1)
              new_param = strsplit(error[i],',',/extract)
              for j=0,n_elements(extract)-1 do begin
                if strmatch(extract[j],'[0123456789]') eq 1 then begin        ;structure index call
                  true_err_index[total_lines] = fix(new_param[j])
                endif else begin                      ;call based on structure names
                  mvn_kp_structure_index, kp_data, new_param[j], new_err_index, first_level_tags
                  true_err_index[total_lines] = new_err_index            
                endelse
                total_lines = total_lines+1
              endfor    
            endif else begin                              ;single plots
              extract = strmid(error[i],0,1)
              new_param = strsplit(error[i],',',/extract)
              if strmatch(extract,'[0123456789]') eq 1 then begin       ;structure index call
                true_err_index[total_lines] = fix(error[i])
              endif else begin                        ;structure name call
                mvn_kp_structure_index, kp_data, new_param, new_err_index, first_level_tags
                true_err_index[total_lines] = new_err_index
              endelse
              total_lines = total_lines + 1
            endelse
          endfor
          endif
          true_err_index = true_err_index[0:total_lines-1]
          
      
        ;CHECK PARAMETER VALIDITY AND EXTRACT DATA
        
            x = kp_data[kp_start_index:kp_end_index].time
            y = fltarr(n_elements(true_index),n_elements(kp_data[kp_start_index:kp_end_index].time))
            y_axis_title = strarr(n_elements(true_index))
            err_check = intarr(n_elements(true_index))
            if keyword_set(error) then begin
              y_error = dblarr(2, n_elements(true_index), n_elements(kp_data.time))
            endif
            for i=0,n_elements(true_index)-1 do begin
                MVN_KP_TAG_VERIFY, kp_data, true_index[i],base_tag_count, first_level_count, base_tags,  $
                            first_level_tags, check, level0_index, level1_index, tag_array
             if check eq 1 then begin
                 print,'Whoops, ',strupcase(true_index[i]),' is not part of the KP data structure. Check the spelling, or the structure tags with the /LIST keyword.'
                 return
               endif else begin            
                 y[i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
                 x = kp_data[kp_start_index:kp_end_index].time 
                 y_axis_title[i] = strupcase(string(tag_array[0]+'.'+tag_array[1]))
                 if keyword_set(error) then begin
                  mvn_kp_tag_verify, kp_data, true_err_index[i], base_tag_count, first_level_count, base_tags, $
                                   first_level_tags, err_check[i], err_level0, err_level1, temp_tag
                   if err_check[i] eq 0 then begin                
                     y_error[0,i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)-kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)               
                     y_error[1,i,*] = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)+kp_data[kp_start_index:kp_end_index].(err_level0).(err_level1)  
                   endif else begin
                    print,'Requested error parameter is not included in the data structure. Try /LIST to check for it.'
                    print,'Creating requested plot WITHOUT error bars'
                   endelse
                 endif else err_check[i] = 1
                    
               endelse  
             endfor   
        
        ;CREATE THE PLOTS
        
        if directgraphic eq 0 then begin
          x_labels = [time_string(x[0]),time_string(x[(n_elements(x)-1)*.25]), time_string(x[(n_elements(x)-1)/2]),time_string(x[(n_elements(x)-1)*.75]), time_string(x[n_elements(x)-1])]
            oplot_index = 0
             w = window(window_title='MAVEN Plots',dimensions=[800,600])
            for i = 0, n_elements(parameter) -1 do begin
              if plot_count[i] eq 1 then begin
                if err_check[i] eq 0 then begin
                  plot1 = errorplot(x, y[oplot_index,*], reform(y_error[*,i,*]), xtitle='Time', ytitle=y_axis_title[oplot_index], layout=[1,n_elements(parameter),i+1],/current,$
                          title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,ylog=yaxis_log,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
                endif else begin
                  plot1 = plot(x, y[oplot_index,*], xtitle='Time', ytitle=y_axis_title[oplot_index], layout=[1,n_elements(parameter),i+1],/current,$
                          title=title[i],thick=thick,linestyle=linestyle,symbol=symbol,ylog=yaxis_log,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
                endelse          
                oplot_index= oplot_index+1
              endif else begin
                ymin = min(y[oplot_index:(oplot_index+plot_count[i]-1)])
                ymax = max(y[oplot_index:(oplot_index+plot_count[i]-1)])
                if keyword_set(error) then begin
                  plot1 = errorplot(x, y[oplot_index,*], reform(y_error[*,i,*]),xtitle='Time', layout=[1,n_elements(parameter),i+1],/current,$
                            title=title[i],thick=thick,linestyle=0,symbol=symbol,ylog=yaxis_log,yrange=[ymin,ymax],xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
                  l = legend(target=plot1,/auto_text_color,label=y_axis_title[oplot_index],position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85],$
                            /normal,linestyle=0,font_size=8)
                  oplot_index = oplot_index+1
                  for j=1,plot_count[i]-1 do begin      
                    plot1 = errorplot(x, y[oplot_index,*], reform(y_error[*,i,*]), xtitle='Time', layout=[1,n_elements(parameter),i+1],/current,$
                            title=title[i],thick=thick,linestyle=j,symbol=symbol,xlog=xaxis_log,yrange=[ymin,ymax],overplot=1,xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
                     l = legend(target=plot1,/auto_text_color,label=y_axis_title[oplot_index],position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85+(j*0.05)],$
                            /normal,linestyle=j,font_size=8)
                    oplot_index=oplot_index+1
                  endfor
                endif else begin
                  plot1 = plot(x, y[oplot_index,*], xtitle='Time', layout=[1,n_elements(parameter),i+1],/current,$
                            title=title[i],thick=thick,linestyle=0,symbol=symbol,ylog=yaxis_log,yrange=[ymin,ymax],xmajor=5,xtickname=x_labels,xtext_orientation=0,xstyle=1)
                  l = legend(target=plot1,/auto_text_color,label=y_axis_title[oplot_index],position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85],$
                            /normal,linestyle=0,font_size=8)
                  oplot_index = oplot_index+1
                  for j=1,plot_count[i]-1 do begin      
                    plot1 = plot(x, y[oplot_index,*], xtitle='Time', layout=[1,n_elements(parameter),i+1],/current,$
                            title=title[i],thick=thick,linestyle=j,symbol=symbol,xlog=xaxis_log,xmajor=5,yrange=[ymin,ymax],overplot=1,xstyle=1)
                     l = legend(target=plot1,/auto_text_color,label=y_axis_title[oplot_index],position=[(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.85+(j*0.05)],$
                            /normal,linestyle=j,font_size=8)
                    oplot_index=oplot_index+1
                  endfor 
                endelse   
              endelse
            endfor
        endif 
        if directgraphic eq 1 then begin
          device,decomposed=1
            !P.MULTI = [0, 1, n_elements(parameter)]
            oplot_index = 0 
            for i = 0, n_elements(parameter) -1 do begin
              if plot_count[i] eq 1 then begin
                plot,x,y[oplot_index,*],xtitle='Time', ytitle=y_axis_title[oplot_index],$
                     title=title[i],thick=thick,linestyle=linestyle,ylog=yaxis_log,background='FFFFFF'x,color=0,$
                     charsize=2,font=-1
                if err_check[i] eq 0 then begin
                  errplot,x, y_error[0,i,*], y_error[1,i,*]
                endif
                oplot_index = oplot_index+1
              endif else begin 
                ymin = min(y[oplot_index:(oplot_index+plot_count[i]-1)])
                ymax = max(y[oplot_index:(oplot_index+plot_count[i]-1)])
                plot,x,y[oplot_index,*],xtitle='Time',$
                      title=title[oplot_index],thick=thick,linestyle=linestyle,ylog=yaxis_log,background='FFFFFF'x,$
                      yrange=[ymin,ymax],color=0,charsize=2.
                if err_check[i] eq 0 then begin
                  errplot,x, y_error[0,i,*], y_error[1,i,*]
                endif
                plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),(i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],[.81,.81],linestyle=0,color=0,/normal
                xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.8,y_axis_title[oplot_index],color=0,/normal
                oplot_index = oplot_index+1
                for j=1,plot_count[i]-1 do begin      
                  oplot,x,y[oplot_index,*],linestyle=j,thick=thick,color=0
                  plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),(i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],[.81+(j*0.03),.81+(j*0.03)],linestyle=j,color=0,/normal
                  xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),.8+(j*.03),y_axis_title[oplot_index],color=0,/normal
                  oplot_index=oplot_index+1
                endfor        
              endelse 
            endfor 
      
           
        endif
  
  endelse

end