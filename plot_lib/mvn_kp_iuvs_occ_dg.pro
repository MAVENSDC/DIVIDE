;+
;
; :Name: mvn_kp_iuvs_occ_dg
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Harter
;
; :Description:
;   This routine plots the IUVS PERIAPSE limb-scan KP data for DG.
;   (DG = Direct Graphics)
;   This code is written to be called by mvn_kp_iuvs_limb.
;   All three limb-scans from each orbit are included in each plot,
;   with keywords allowing a choice of orbits and species.
;   By default, all limb scan data, both radiance and
;   density profiles, are displayed.
;
; :Params:
;    kp_data : in, required, type=structure
;       the IUVS data structure read into memory by the MVN_KP_READ routine
;
; :Keywords:
;    profiles : in, optional, type=intarr(ndims)
;       an array listing the orbits to be plotted
;    ret_species : in, optional, type=intarr(ndims)
;       an array listing the density measurements of particular
;       species to be plotted
;    nolegend : in, optional, type=strarr(1)
;       either 'vertical' or 'horizontal',
;       defining the orientation of the legend.
;    linear : in, optional, type=byte
;       optional keyword to make plots on a linear scale, instead of the
;       logarithmic default
;    oo: out, optional, object
;       Variable to which plot object may be passed to $MAIN$.
;    species_expand: in, optional, byte
;       if this keyword is selected, then all the species for a given orbit
;       will be plotted on a single graph
;    profile_expand: in, optional, byte
;       if this keyword is selected, then all the orbits will be combined
;       into a single plot for comparison purposes
;    range: in, optional, byte
;       if selected, this will return the temporal range of the data set
;       without plotting anything
;    colortable: in, optional, type=integer
;       an option to override the default colortable with any other
;       IDL colortable
;    window: in, optional, type=byte
;       if invoked, will create a new window instead of reusing the previous.
;    winX: in, optional, type=integer
;       sets the X size of the window, in pixels.
;    winY: in, optional, type=integer
;       sets the Y size of the window, in pixels.
;
; :Version:   1.0   July 8, 2014
;-
pro MVN_KP_IUVS_OCC_DG, kp_data, $
  retrieval_data=retrieval_data, $
  altitude_retrieval=altitude_retrieval, $
  ret_species=ret_species, $
  nolegend=nolegend, linear=linear, $
  species_expand=species_expand, $
  profile_expand=profile_expand,$
  ret_linestyle=ret_linestyle, $
  ret_thick=ret_thick, $
  profile_dimensions=profile_dimensions, $
  profile_inclusion=profile_inclusion, $
  profile_colors=profile_colors, window=window, $
  winX=winX, winY=winY, $
  retrieval_label=retrieval_labels, $
  profile_labels=profile_labels

  ;SET WINDOW NUMBERS FOR PLOTS, IF FLAG IS SET
  if keyword_set(window) then begin
    plot_window = !window + 1
    legend_window = plot_window + 1
  endif else begin
    plot_window = 1
    legend_window = 2
  endelse

  ;SET DEFAULT WINDOW SIZES
  if keyword_set(winX) ne 1 then begin
    winX=1000
  endif
  if keyword_set(winY) ne 1 then begin
    winY=800
  endif

  profile_colors = intarr(n_elements(kp_data.orbit)*3)

  ;PLOT
  ;DETERMINE APPROPRIATE MARGINS
  ;MARGINS
  if keyword_set(species_expand) then y_label_margin = [5,10]
  if keyword_set(profile_expand) then x_label_margin = [15,5]

  ;CREATE THE PLOT WINDOW, SAVING THE OLD ONE IF REQUESTED
  if keyword_set(window) then begin
    window, plot_window, xsize=winX, ysize=winY
  endif else begin
    if !window eq -1 then begin
      window,plot_window,xsize=winX, ysize=winY
    endif else begin
      wset,plot_window
    endelse
  endelse


  if (keyword_set(species_expand) eq 0) and $
    (keyword_set(profile_expand) eq 0) then begin
    ;DEFAULT PLOTTING OF ALL PERIAPSE SCANS, SPECIES,
    ;AND PROFILES ON ONE PLOT
    plot,retrieval_data[0,0,0,*],altitude_retrieval,thick=2,xlog=log_option,$
      charsize=2,yrange=[100,200],$
      ytitle='Altitude,km',/nodata,ymargin =y_label_margin
    check_index = 0
    for i=0,n_elements(kp_data)-1 do begin
      for j=0,2 do begin
        if kp_data[i].stellar_occ[j].time_start ne '' then begin
          if profile_inclusion[check_index] eq 1 then begin
            for k=0,n_elements(ret_species)-1 do begin
              oplot,retrieval_data[i,j,k,*],altitude_retrieval,thick=2,$
                linestyle=ret_linestyle[k],$
                color=profile_colors[(i*3)+j]
            endfor
          endif
          check_index = check_index+1
        endif ; existence of data check
      endfor  ; loop over profiles
    endfor    ; loop over orbits
  endif ; do not expand on species nor profiles

  if keyword_set(species_expand) and $
    (keyword_set(profile_expand) eq 0) then begin
    ;
    ; DENSITY PLOT EXPANDING TO INVIDUALLY PLOT ALL SPECIES
    ;
    for i=0,n_elements(ret_species)-1 do begin
      check_index = 0
      plot,retrieval_data[0,0,i,*],altitude_retrieval,title=retrieval_labels[i],$
        thick=2,xlog=log_option,charsize=1.5,yrange=[100,220],$
        ytitle='Altitude, km',/nodata,ymargin=y_label_margin
      for j=0,n_elements(kp_data)-1 do begin
        for k=0,2 do begin
          if kp_data[j].stellar_occ[k].time_start ne '' then begin
            if profile_inclusion[check_index] eq 1 then begin
              oplot,retrieval_data[j,k,i,*],altitude_retrieval,thick=2,$
                color=profile_colors[(j*3)+k]
            endif
            check_index = check_index + 1
          endif
        endfor  ; loop profiles
      endfor    ; loop times
    endfor      ; loop den_species
  endif           ; if only expand species

  if keyword_set(profile_expand) and $
    (keyword_set(species_expand) eq 0) then begin
    ;
    ; DENSITY PLOT EXPANDING TO INDIVIDUALLY PLOT EACH PROFILE
    ;
    check_index = 0
    label_index = 0
    for i=0,n_elements(kp_data)-1 do begin
      for j=0,2 do begin
        if kp_data[i].stellar_occ[j].time_start ne '' then begin
          if profile_inclusion[check_index] eq 1 then begin
            plot,retrieval_data[i,j,0,*],altitude_retrieval,thick=2,$
              xlog=log_option,charsize=1.5,yrange=[100,220],$
              ytitle='Altitude, km',/nodata,ymargin=y_label_margin, $
              title=profile_labels[check_index]
            label_index = label_index + 1
            for k=0,n_elements(ret_species)-1 do begin
              oplot,retrieval_data[i,j,k,*],altitude_retrieval,thick=2,$
                linestyle=ret_linestyle[k]
            endfor
          endif
          ;   xyouts,.48,0.9-((1./rows)*label_index),profile_labels[check_index],/normal,charsize=1.5
          check_index = check_index + 1
        endif ; data verification check
      endfor  ; profiles loop
    endfor    ; time loop
  endif         ; expand profiles but not species


  if keyword_set(profile_expand) and $
    keyword_set(species_expand) then begin
    ;
    ; DENSITY PLOTS THAT EXPAND BOTH SPECIES AND PROFILES
    ;
    for i=0,n_elements(ret_species)-1 do begin
      check_index = 0
      label_index = 0
      for j=0,n_elements(kp_data)-1 do begin
        for k=0,2 do begin
          if kp_data[j].stellar_occ[k].time_start ne '' then begin
            if profile_inclusion[check_index] eq 1 then begin
              plot,retrieval_data[j,k,i,*],altitude_retrieval,thick=2,$
                xlog=log_option,charsize=1.5,yrange=[100,220],$
                ytitle='Altitude, km',ymargin=y_label_margin,$
                title= retrieval_labels[i] +':  '$
                + profile_labels[check_index]
              label_index = label_index+1
            endif
            ; xyouts,.48,0.94-((1./rows)*label_index),$
            ; profile_labels[check_index],/normal,charsize=1.5
            check_index = check_index+1
          endif ; data existence check
        endfor  ; profile loop
      endfor    ; time loop
    endfor      ; den_species loop
  endif           ; expand all


  ;IF BOTH RADIANCE AND DENSITY ARE BEING PLOTTED,
  ;DRAW A VERTICAL LINE TO SEPARATE THE TWO SIDES OF THE PLOT

  ;MID-PLOT LINE IF BOTH RADIANCE AND DENSITY IS INCLUDED
  if keyword_set(species_expand) then begin
    line_marker = float(n_elements(rad_species))$
      / float((n_elements(rad_species)$
      +n_elements(ret_species)))
  endif

  ;ADD OVERALL LABELS
  ret_label = 0.7

  if keyword_set(species_expand) then begin
    if den_plot eq 1 then begin
      ret_label = 0.48
    endif
  endif

  if (ret_plot eq 1) then $
    xyouts, ret_label,.965,'Retrieval',/normal,charsize=3

  ;START A SECOND WINDOW FOR THE PLOT LEGENDS
  if keyword_set(nolegend) eq 0  then begin
    legend_xsize=400
    ret_lab = 0.1

    window,plot_window+1, xsize=legend_xsize,ysize=400,title='Occultation Plot Legend'
    device, decompose=0
    plot,[0,0],[1,1], color=255, background=255, /nodata

    if den_plot eq 1 then $
      xyouts, den_lab,0.9,'Occultation',charsize=2,charthick=2,/normal
    xyouts, 0.75,0.9,'Profiles',charsize=2,charthick=2,/normal

    ;species labels

    for i=0,n_elements(ret_species) - 1 do begin
      plots,[(ret_lab-0.02),(ret_lab+0.08)],[.8-(0.08 * i),.8-(0.08*i)],$
        linestyle=ret_linestyle[i],thick=2,/normal
      xyouts,(ret_lab+0.1),[0.79-(0.08*i)],retrieval_labels[i],charsize=1.5,$
        charthick=1.5,/normal
    endfor



    ;orbit labels

    check_index = 0
    label_index = 0
    for i=0,n_elements(kp_data.orbit) -1 do begin
      for j=0,2 do begin
        if kp_data[i].stellar_occ[j].time_start ne '' then begin
          if profile_inclusion[check_index] eq 1 then begin
            plots,[0.7,0.9],[0.8-((.8/profile_dimensions)*label_index),$
              0.8-((.8/profile_dimensions)*label_index)],$
              thick=2,color=profile_colors[(i*3)+j],/normal
            xyouts,0.7,(0.78-((.8/profile_dimensions)*label_index)),$
              profile_labels[check_index],/normal
            label_index = label_index + 1
          endif
          check_index = check_index+1
        endif
      endfor
    endfor

  endif ; create legend y/n?

end
