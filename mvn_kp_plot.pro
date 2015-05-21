;+
;
; :Name: mvn_kp_plot
; 
; :Author: Kristopher Larsen
; 
; :Description:
;   This is a very basic routine to plot time series data from a MAVEN 
;   in-situ Key Parameter data structure.
;
; :Params:
;    kp_data: in, required, type=structure
;       the INSITU KP data structure from which to plot data.
;    parameter: in, required, type=strarr,intarr
;       the INSITU kp data fields to plot, may be an integer or string 
;       array for multiple choices.
;       use ['name1, name2', 'name3, name4] to create two plots with two 
;       data parameters on each.
;
; :Keywords:
;    time: in, required, can be a scalar or a two item array of type:
;         long(s)        orbit number
;         string(s)      format:  YYYY-MM-DD/hh:mm:ss
;       A start or start & stop time (or orbit #) range for reading kp data.
;    list: in, optional, type=boolean or variable
;       if selected, will list the KP data fields included in kp_data.
;       If /list, the output will be printed to the screen.
;       If list=list then the structure indices and tag names will be a
;       string array.
;    range: in, optional, type=boolean
;       if selected, will list the beginning and end times of kp_data.
;    directgraphic: in, optional, type=boolean
;       if selected, will override the default Graphics plot procedure and
;       use direct graphics instead.
;    oo: out, optional
;       if provided, the name of the variable to which the plot created
;       will be assigned.  Ignored if /directgraphic is also set.
;    error: in, optional, type=strarr, intarr
;       If included, these are the KP data fields that are the error
;       measurements on each parameter to be plotted.       
;       
;       
; :Version:   1.0    July 8, 2014
;-
@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_range
@mvn_kp_range_select
@mvn_kp_tag_verify

pro MVN_KP_PLOT, kp_data, parameter, error=error, time=time, list=list, $
                 range=range, directgraphic=directgraphic, $
                 oo=oo, y_labels=y_labels, _extra = e, help=help

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_plot'
    return
  endif


  ;CHECK THAT THE INPUT PARAMETERS ARE VALID
  ;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
  
  MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, $
                     second_level_count, base_tags,  first_level_tags, $
                     second_level_tags

  ;LIST OF ALL POSSIBLE PLOTABLE PARAMETERS IF /LIST IS SET

  if keyword_set(list) then begin
    if arg_present(list) then begin
      ; return the KP list to the provided variable
      mvn_kp_get_list, kp_data, list=list
    endif else begin
      ; print the KP list to screen
      mvn_kp_get_list, kp_data, /list
    endelse
    return
  endif
  
  ;PROVIDE THE TEMPORAL RANGE OF THE DATA SET IN BOTH DATE/TIME AND 
  ;ORBITS IF REQUESTED.
  if keyword_set(range) then begin
    MVN_KP_RANGE, kp_data
    return
  endif
  
  ;SET THE VARIOUS PLOT OPTIONS, SHOULD THEY REQUIRE IT
  if keyword_set(title) eq 0 then begin
    if n_elements(parameter) eq 1 then title=''
    if n_elements(parameter) ne 1 then title=strarr(n_elements(parameter))
  endif
  
  if keyword_set(directgraphic) eq 0 then begin
   if Float(!Version.Release) GE 8.0 THEN directgraphic = 0    
   ;USE DIRECT GRAPHICS IF USER HAS OLD VERSION OF IDL
  endif
  
  ;IF USER HAS SET YRANGE, CHECK THAT THEY MATCH THE NUMBER OF PLOTS
;  if keyword_set(yrange) then begin
;    if (n_elements(yrange)/n_elements(parameter)) ne 2 then begin
;      print,'When using the YRANGE keyword, ranges must be set for each plot'
;      return    
;    endif
;  endif
  
  
  ;IF THE USER SUPPLIES A TIME RANGE, SET THE BEGINNING AND END INDICES
  
  if keyword_set(time) then begin ;determine the start and end indices to plot
    MVN_KP_RANGE_SELECT, kp_data, time, kp_start_index, kp_end_index
  endif else begin                ;otherwise plot all data within structure
   kp_start_index = 0
   kp_end_index = n_elements(kp_data.orbit)-1
  endelse
  
  if kp_start_index eq -1 or kp_end_index eq -1 then begin
    print,'Sorry, the times you requested are not contained within the data.'
    print,'Check your time range and try again.'
    return
  endif
  if kp_start_index eq kp_end_index then begin
    print,'Sorry, start and end times are the same. Nothing to plot!'
    return
  endif
  if( kp_start_index gt kp_end_index )then begin
    print,'WARNING: Start time provided is later than end time.'
    print,'         Start time = ',time[0]
    print,'           End time = ',time[1]
    do_swap = ''
    while( do_swap ne 's' and do_swap ne 'S' and $
           do_swap ne 'q' and do_swap ne 'Q' )do begin
      read,prompt="Please press 's' to swap, or 'q' to exit and try again: ",$
           do_swap
    endwhile
    if( do_swap eq 's' or do_swap eq 'q' )then begin
      temp = kp_start_index
      kp_start_index = kp_end_index
      kp_end_index = temp
    endif
    if( do_swap eq 'q' or do_swap eq 'Q' )then $
        message,'Exiting as per user request to re-enter time range'
  endif
  
  ;CREATE THE PLOT VECTORS
  
  overplot_check=0
  for i=0,n_elements(parameter)-1 do begin
    pos = strpos(parameter[i],',')
    if pos ne -1 then overplot_check = 1
  endfor

  if overplot_check ne 1 then begin  

    if n_elements(parameter) eq 1 then begin
      ;only going to plot a single altitude plot
                                              
      MVN_KP_TAG_VERIFY, kp_data, parameter,base_tag_count, $
                         first_level_count, base_tags, first_level_tags, $
                         check, level0_index, level1_index, tag_array
      if check eq 0 then begin  ;CHECK THAT THE REQUESTED PARAMETER EXISTS

        x = kp_data[kp_start_index:kp_end_index].time
        y = kp_data[kp_start_index:kp_end_index].(level0_index).(level1_index)
              
        if keyword_set(error) then begin
          mvn_kp_tag_verify, kp_data, error, base_tag_count, $
                             first_level_count, base_tags, first_level_tags, $
                             err_check, err_level0, err_level1, temp_tag
          if err_check eq 0 then begin
            y_error $
              = dblarr(2,$
                       n_elements(kp_data[kp_start_index:kp_end_index].time))
            y_error[0,*] $
              = kp_data[kp_start_index:kp_end_index]$
                .(level0_index).(level1_index)$ 
              - kp_data[kp_start_index:kp_end_index]$
                .(err_level0).(err_level1)               
            y_error[1,*] $
              = kp_data[kp_start_index:kp_end_index]$
                .(level0_index).(level1_index)$
              + kp_data[kp_start_index:kp_end_index]$
                .(err_level0).(err_level1)   
          endif else begin
            print,'Requested error parameter is not included in the data.'
            print,'Try /LIST to check for it.'
            print,'Creating requested plot WITHOUT error bars'
          endelse            
        endif else err_check = 1

        ;SET THE YLABELS
        if keyword_set(y_labels) ne 1 then begin
          y_labels = strupcase(string(tag_array[0]+'.'+tag_array[1]))
        endif
              
      endif else begin
        print,'Requested plot parameter is not included in the data.'
        print,'Try /LIST to confirm your parameter choice.'
        return
      endelse
    endif ;end of single altitude variable creation loop
        
        
    ;CREATE SINGLE  PLOT
              
    if directgraphic eq 0 then begin
      ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
          
      if n_elements(parameter) eq 1 then begin
        ;define realistic x axis time labels
        x_labels = [time_string(x[0]),$
                    time_string(x[(n_elements(x)-1)*.25]), $
                    time_string(x[(n_elements(x)-1)/2]),$
                    time_string(x[(n_elements(x)-1)*.75]), $
                    time_string(x[n_elements(x)-1])]
        if err_check eq 0 then begin
          err_plot = errorplot(x,y,y_error,xtitle='Time',ytitle=y_labels,$
                               color='black',margin=0.1,xmajor=5,$
                               xtickname=x_labels,xstyle=1,_extra=e)
        endif else begin
          plot1 = plot(x,y,xtitle='Time',ytitle=y_labels,color='black',$
                       margin=0.1,xmajor=5,xtickname=x_labels,xstyle=1,$
                       _extra=e)
        endelse 
      endif
    endif

    if directgraphic ne 0 then begin
      ;USE THE OLD DIRECT GRAPHICS PLOT PROCEDURES
      if n_elements(parameter) eq 1 then begin
        ;define realistic x axis time labels
        x_labels = [time_string(x[0]),$
                    time_string(x[(n_elements(x)-1)*.25]),$
                    time_string(x[(n_elements(x)-1)/2]),$
                    time_string(x[(n_elements(x)-1)*.75]),$
                    time_string(x[n_elements(x)-1])]
        device,decomposed=0
        loadct,0,/silent
        !P.MULTI = [0, n_elements(parameter), 1]
        plot,x,y,xtitle='Time',ytitle=y_labels,background=255, color=0, $
             yrange=yrange, _extra=e
        if err_check eq 0 then begin
          errplot,x, y_error[0,*], y_error[1,*],color=0,_extra=e
        endif
      endif
    endif
   
    ;CREATE MULTIPLE  PLOT VECTORS
    
    if n_elements(parameter) gt 1 then begin
      mvn_kp_create_multi_vectors, kp_data[kp_start_index:kp_end_index], $
                                   parameter, y, y_error, y_axis_title, $
                                   error=error, y_labels=y_labels, $
                                   err_check=err_check
      x = kp_data[kp_start_index:kp_end_index].time
    endif
  
    ;CREATE DUMMY YRANGE IF NOT DEFINED
    temp_yrange = dblarr(2,n_elements(parameter))
    if n_elements(yrange) ne 0 then begin
      temp_yrange = yrange
    endif else begin
      for i=0,n_elements(parameter)-1 do begin
        temp_yrange[0,i] = min(y[i,*],/NaN)
        temp_yrange[1,i] = max(y[i,*],/NaN)
      endfor
    endelse
        
    ;CREATE THE MULTIPLE  PLOT    
    if directgraphic eq 0 then begin
      ;PLOT USING THE NEW IDL GRAPHICS PLOT FUNCTION
      x_labels = [time_string(x[0]),$
                  time_string(x[(n_elements(x)-1)*.25]),$
                  time_string(x[(n_elements(x)-1)/2]),$
                  time_string(x[(n_elements(x)-1)*.75]),$
                  time_string(x[n_elements(x)-1])]
      if n_elements(parameter) gt 1 then begin
;
; use of nodata keyword is causing problems.  Trying this instead.
; Define current as keyword of i.  Therefore, if i=0, we make a new
;  window; but if i ge 1, we draw next plot in same window
;
        for i = 0,n_elements(parameter)-1 do begin
          if err_check[i] ne 0 then begin
            plot1=plot(x, y[i,*], xtitle='Time', ytitle=y_axis_title[i], $
                       layout=[1,n_elements(parameter),i+1], $
                       yrange=temp_yrange[*,i], color='black', $
                       title=title[i], xmajor=5, $
                       xtickname=x_labels, xstyle=1, margin=0.1, $
                       current=keyword_set(i),_extra=e )
          endif else begin
            plot1=errorplot(x, y[i,*], reform(y_error[*,i,*]), $
                            xtitle='Time', ytitle=y_axis_title[i], $
                            layout=[1,n_elements(parameter),i+1], $
                            yrange=temp_yrange[*,i], color='black', $
                            title=title[i], xmajor=5, $
                            xtickname=x_labels, xstyle=1, margin=0.1, $
                            current=keyword_set(i),_extra=e )
          endelse
        endfor
;
; Until I am satisfied I did not break anything.  I will keep old code here
;
;        plot1 = plot(x,y[0,*], xtitle='Time',ytitle=y_axis_title[0], $
;                     layout=[1,n_elements(parameter),1],nodata=1,$
;                     color='black',title=title[0],xmajor=5,$
;                     axis_style=0,xtickname=x_labels,xstyle=1,$
;                     margin=0.1,_extra=e)
;        for i = 0, n_elements(parameter) -1 do begin
;          if err_check[i] ne 0 then begin
;            plot1 = plot(x, y[i,*], xtitle='Time', ytitle=y_axis_title[i], $
;                         layout=[1,n_elements(parameter),i+1],/current,$
;                         yrange=temp_yrange[*,i],color='black',$
;                         title=title[i],xmajor=5,$
;                         xtickname=x_labels,xstyle=1,margin=0.1,_extra=e)
;          endif else begin
;            plot1 = errorplot(x, y[i,*],reform(y_error[*,i,*]), $
;                              xtitle='Time', ytitle=y_axis_title[i], $
;                              layout=[1,n_elements(parameter),i+1],/current,$
;                              color='black',title=title[i],xmajor=5,$
;                              xtickname=x_labels,$
;                              xstyle=1,yrange=temp_yrange[*,i],$
;                              margin=0.1,_extra=e)
;          endelse 
;        endfor
;
;-end-preserve-old-code

      endif ; number of provided parameters exceeds 1
    endif   ; direct graphics eq 0

    if directgraphic ne 0 then begin 
      ;PLOT USING THE OLD IDL DIRECT GRAPHICS
      device,decomposed=0
      loadct,0,/silent
      !P.MULTI = [0, 1, n_elements(parameter)]
      if n_elements(parameter) gt 1 then begin
        plot,x,y[0,*],xtitle='Time', ytitle=y_axis_title[0],$
             yrange=temp_yrange[*,0],title=title[0],background=255,color=0,$
             charsize=2,font=-1,_extra=e
        if err_check[0] eq 0 then begin
          errplot,x, y_error[0,0,*], y_error[1,0,*],color=0,_extra=e
        endif              
        for i=1,n_elements(parameter)-1 do begin
          plot,x,y[i,*],xtitle='Time', ytitle=y_axis_title[i],$
               yrange=temp_yrange[*,i],title=title[i],color=0,charsize=2,$
               font=-1,_extra=e
          if err_check[i] eq 0 then begin
            errplot,x, y_error[0,i,*], y_error[1,i,*],color=0,_extra=e
          endif
        endfor 
      endif ; number of parameters exceeds 1
    endif   ; plot using direct graphics
        
  endif else begin ; Not doing multiple plots, doing overplots
        
    ;BEGIN SEPARATE ROUTINES IF ANY OVERPLOTTING IS REQUIRED.
      
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
          if strmatch(extract[j],'[0123456789]') eq 1 then begin        
            ;structure index call
            true_index[total_lines] = fix(new_param[j])
          endif else begin                     ;call based on structure names
            mvn_kp_structure_index, kp_data, new_param[j], new_index, $
                                    first_level_tags
            true_index[total_lines] = new_index            
          endelse
          total_lines = total_lines+1
          plot_count[i] = plot_count[i]+1
        endfor    
      endif else begin                              ;single plots
        extract = strmid(parameter[i],0,1)
        new_param = strsplit(parameter[i],',',/extract)
        if strmatch(extract,'[0123456789]') eq 1 then begin
          ;structure index call
          true_index[total_lines] = fix(parameter[i])
        endif else begin                        ;structure name call
          mvn_kp_structure_index, kp_data, new_param, new_index, $
                                  first_level_tags
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
            if strmatch(extract[j],'[0123456789]') eq 1 then begin
              ;structure index call
              true_err_index[total_lines] = fix(new_param[j])
            endif else begin                  ;call based on structure names
              mvn_kp_structure_index, kp_data, new_param[j], new_err_index, $
                                      first_level_tags
              true_err_index[total_lines] = new_err_index            
            endelse
            total_lines = total_lines+1
          endfor    
        endif else begin                              ;single plots
          extract = strmid(error[i],0,1)
          new_param = strsplit(error[i],',',/extract)
          if strmatch(extract,'[0123456789]') eq 1 then begin
            ;structure index call
            true_err_index[total_lines] = fix(error[i])
          endif else begin                        ;structure name call
            mvn_kp_structure_index, kp_data, new_param, new_err_index, $
                                    first_level_tags
            true_err_index[total_lines] = new_err_index
          endelse
          total_lines = total_lines + 1
        endelse
      endfor
    endif
    true_err_index = true_err_index[0:total_lines-1]
            
;
; Now, use the create_multi_vector code with true_index in place 
;  of parameter to fill the data, error, and label vectors
;
    x = kp_data[kp_start_index:kp_end_index].time
    mvn_kp_create_multi_vectors, kp_data[kp_start_index:kp_end_index], $
                                 true_index, y, y_error, y_axis_title, $
                                 error=error, y_labels=y_labels, $
                                 err_check=err_check
;
;  Still have to define the y_titles
;
    title_index = 0
    if keyword_set(y_labels) then begin
      y_titles = strarr(n_elements(parameter))
      for i=0,n_elements(parameter)-1 do begin
        y_titles[i] = y_labels[i]
      endfor
      title_index = title_index + 1
    endif else begin
      y_titles=strarr(n_elements(parameter))
      for i=0,n_elements(parameter)-1 do begin
        if plot_count[i] eq 1 then begin
          y_titles[i] = y_axis_title[title_index]
          title_index = title_index + 1
        endif else begin
          y_titles[i] = strjoin(y_axis_title[title_index:$
                                             title_index+plot_count[i]-1],', ')
          title_index = title_index + plot_count[i] 
        endelse  
      endfor
    endelse ; end of multiple plots, one window block

    ;CREATE THE PLOTS
        
    if directgraphic eq 0 then begin
      x_labels = [time_string(x[0]),$
                  time_string(x[(n_elements(x)-1)*.25]),$
                  time_string(x[(n_elements(x)-1)/2]),$
                  time_string(x[(n_elements(x)-1)*.75]),$
                  time_string(x[n_elements(x)-1])]
      oplot_index = 0
      w = window(window_title='MAVEN Plots')

      for i = 0, n_elements(parameter) -1 do begin
        if plot_count[i] eq 1 then begin
;
;  ToDo: NB if all vals are NaN, this produces warning and useless plot
;        I.e., should have a quality check for all-Nans
;
          if keyword_set(yrange) then begin
            temp_yrange = yrange[*,i]
          endif else begin
            temp_yrange = [min(y[oplot_index,*],/NaN),$
                           max(y[oplot_index,*],/NaN)]
          endelse

          if err_check[i] eq 0 then begin
            plot1 = errorplot(x, y[oplot_index,*], reform(y_error[*,i,*]), $
                              xtitle='Time', ytitle=y_titles[oplot_index], $
                              layout=[1,n_elements(parameter),i+1],$
                              /current, title=title[i], xmajor=5,$
                              xtickname=x_labels,$
                              xstyle=1,yrange=temp_yrange,color='black',$
                              margin=0.1,_extra=e)
          endif else begin
            plot1 = plot(x, y[oplot_index,*], xtitle='Time', $
                         ytitle=y_titles[i], $
                         layout=[1,n_elements(parameter),i+1],/current,$
                         title=title[i],xmajor=5,$
                         xtickname=x_labels,xstyle=1,yrange=temp_yrange,$
                         color='black',margin=0.1,_extra=e)
          endelse ; err_check          
          oplot_index= oplot_index+1

        endif else begin

          if keyword_set(yrange) then begin
            temp_yrange = yrange[*,i]
          endif else begin
            temp_yrange = [min(y[oplot_index,*],/NaN),$
                           max(y[oplot_index,*],/NaN)]
          endelse
          if keyword_set(error) then begin
            plot1 = errorplot(x, y[oplot_index,*], reform(y_error[*,i,*]),$
                              xtitle='Time',ytitle=y_titles[oplot_index], $
                              layout=[1,n_elements(parameter),i+1],$
                              /current,yrange=temp_yrange,title=title[i],$
                              linestyle=0,xmajor=5,xtickname=x_labels,$
                              xstyle=1,color='black',$
                              name=y_axis_title[oplot_index],$
                              margin=0.1,_extra=e)
            l = legend(target=plot1,position=[0.2,0.95],/normal,linestyle=0,$
                       font_size=8)
            oplot_index = oplot_index+1
            for j=1,plot_count[i]-1 do begin      
              plot1 = errorplot(x, y[oplot_index,*], reform(y_error[*,i,*]), $
                                xtitle='Time', $
                                layout=[1,n_elements(parameter),i+1],$
                                /current, yrange=temp_yrange, title=title[i],$
                                linestyle=j, overplot=1, xmajor=5, $
                                xtickname=x_labels,xstyle=1, color='black',$
                                name=y_axis_title[oplot_index],$
                                margin=0.1,_extra=e)
              l = legend(target=plot1,position=[0.2,0.95-(j*0.15)],$
                         /normal,linestyle=j,font_size=8)
              oplot_index=oplot_index+1
            endfor
          endif else begin
            plot1 = plot(x, y[oplot_index,*], xtitle='Time', $
                         ytitle=y_titles[i], $
                         layout=[1,n_elements(parameter),i+1],$
                         yrange=temp_yrange,/current,color='black',$
                         title=title[i],linestyle=0, xmajor=5, $
                         xtickname=x_labels,xstyle=1,$
                         name=y_axis_title[oplot_index],margin=0.1,_extra=e)
            l = legend(target=plot1,position=[0.2,0.95],/normal,linestyle=0,$
                       font_size=8)
            oplot_index = oplot_index+1
            for j=1,plot_count[i]-1 do begin      
              plot1 = plot(x, y[oplot_index,*], xtitle='Time', $
                           layout=[1,n_elements(parameter),i+1],$
                           yrange=temp_yrange,/current,color='black',$
                           title=title[i],linestyle=j,$
                           xmajor=5,overplot=1,$
                           xstyle=1,name=y_axis_title[oplot_index],$
                           margin=0.1,_extra=e)
              l = legend(target=plot1,position=[0.2,0.95-(j*0.15)],/normal,$
                         linestyle=j,font_size=8)
              oplot_index=oplot_index+1
            endfor 
          endelse ; keyword_set(error) test   
        endelse   ; do first plot diff than later overplots
      endfor      ; loop over number of requested plots
    endif         ; if using oo graphics

    if directgraphic eq 1 then begin
      device,decomposed=1
      loadct,0,/silent
      !P.MULTI = [0, 1, n_elements(parameter)]
      oplot_index = 0 
      for i = 0, n_elements(parameter) -1 do begin
        if plot_count[i] eq 1 then begin
          ; Need to do dirst plot in usual way
          if keyword_set(yrange) then begin
            temp_yrange = yrange[*,i]
          endif else begin
            temp_yrange = [min(y[oplot_index,*]),max(y[oplot_index,*])]
          endelse
          plot,x,y[oplot_index,*],xtitle='Time', ytitle=y_titles[i],$
               yrange=temp_yrange,title=title[i],background='FFFFFF'x,$
               color=0,charsize=2,font=-1,_extra=e
          if err_check[i] eq 0 then begin
            errplot,x, y_error[0,i,*], y_error[1,i,*],color=0,_extra=e
          endif
          oplot_index = oplot_index+1
        endif else begin 
          ; subsequent plots are overplotted
          if keyword_set(yrange) then begin
            temp_yrange = yrange[*,i]
          endif else begin
            temp_yrange = [min(y[oplot_index,*]),max(y[oplot_index,*])]
          endelse
          plot,x,y[oplot_index,*],xtitle='Time',ytitle=y_titles[i],$
               title=title[i],background='FFFFFF'x,$
               yrange=temp_yrange,color=0,charsize=2.,_extra=e
          if err_check[i] eq 0 then begin
            errplot,x, y_error[0,i,*], y_error[1,i,*],color=0,_extra=e
          endif
          plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),$
                 (i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],$
                [.81,.81],$
                linestyle=0,color=0,/normal
          xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),$
                 .8,y_axis_title[oplot_index],color=0,/normal
          oplot_index = oplot_index+1
          for j=1,plot_count[i]-1 do begin      
            oplot,x,y[oplot_index,*],linestyle=j,thick=thick,color=0,_extra=e
            plots,[(i*(1./n_elements(parameter)))+(.25/(n_elements(parameter))),$
                   (i*(1./n_elements(parameter)))+(.48/(n_elements(parameter)))],$
                   [.81+(j*0.03),.81+(j*0.03)],$
                   linestyle=j,color=0,/normal
            xyouts,(i*(1./n_elements(parameter)))+(.5/(n_elements(parameter))),$
                   .8+(j*.03),y_axis_title[oplot_index],color=0,/normal
            oplot_index=oplot_index+1
          endfor        
        endelse ; end of overpolots 
      endfor    ; loop over parameters provided
    endif       ; If direct graphics requested
  endelse       ; Not single plot; also do overplots
;
;  If using oo graphics and a variable was provided, return plot to that var
;
  if( ~keyword_set(directgraphics) and arg_present(oo) )then oo=plot1

end
