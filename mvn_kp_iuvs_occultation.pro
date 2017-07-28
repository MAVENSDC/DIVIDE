;+
;
; :Name: mvn_kp_iuvs_occultation
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Harter
;
; :Description:
;   This routine is the wrapper for the IUVS occultation
;   plotting routines. 
;
; :Params:
;    kp_data : in, required, type=structure
;       the IUVS data structure read into memory by the MVN_KP_READ routine
;
; :Keywords:
;    profiles : in, optional, type=intarr(ndims)
;       an array listing the orbits to be plotted
;    ret_species : in, optional, type=intarr(ndims)
;       an array listing the retrieval measurements of particular
;       species to be plotted
;    nolegend : in, optional, type=strarr(1)
;       either 'vertical' or 'horizontal',
;       defining the orientation of the legend.
;    linear : in, optional, type=byte
;       optional keyword to make plots on a linear scale, instead of the
;       logarithmic default
;    oo: out, optional, object
;       Variable to which plot object may be passed to $MAIN$.
;    leg: out, optional, object
;       Variable to which legend object may be passed to $MAIN$.
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
; :History:   1.0   July 28, 2017
;
;-
pro MVN_KP_IUVS_OCCULTATION, kp_data, $
  profiles=profiles, ret_species=ret_species, $
  nolegend=nolegend, $
  linear=linear, log=log, info=info, $
  oo=oo, leg=leg, directgraphics=directgraphics, $
  species_expand=species_expand, $
  profile_expand=profile_expand,$
  range=range,color_table=color_table,window=window, $
  winX=winX, winY=winY, help=help, _extra=e

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_iuvs_occultation'
    return
  endif

  ;  Trim the structure in case one of the end members exists only because
  ;  one of the other modes was in use during the provided time window.
  ;  Array index -1 means 'last'; -2 means 'penultimate'
  begin_index = kp_data[0].stellar_occ[0].time_start eq '' ? 1 : 0
  end_index = kp_data[-1].stellar_occ[0].time_start eq ''? -2 : -1
  kp_data = kp_data[begin_index:end_index]

  ;CHECK THE DATA RANGE
  if keyword_set(range) then begin
    print,'The data structure contains data that spans the time range of '$
      +strtrim(string(kp_data[0].stellar_occ[0].time_start),2)+' to '$
      +strtrim(string(kp_data[n_elements(kp_data)-1].stellar_occ[2].time_stop),2)
    print,'Equivalently, this includes the orbits of '$
      +strtrim(string(kp_data[0].orbit),2)+' to '$
      +strtrim(string(kp_data[n_elements(kp_data)-1].orbit),2)
    return
  endif

  ;DEFINE THE SPECIES NAME STRINGS FOR RETRIEVAL
  retrieval_names = kp_data[0].stellar_occ[0].retrieval_id

  ;INFORM THE USER ABOUT THE CHOICE OF SPECIES TO PLOT
  if keyword_set(info) then begin
    print,'The following Occultation Profiles are included in ' $
      +'the loaded data structure.'
    print,'Use the numerical index to downselect which profiles to display'
    print,''
    profile_index = 1
    for i=0,n_elements(kp_data)-1 do begin
      for j=0,2 do begin
        if kp_data[i].stellar_occ[j].time_start ne '' then begin
          print,strtrim(string(profile_index),2)+': Orbit #'$
            +strtrim(string(kp_data[i].orbit),2)+', Profile start time '$
            +strtrim(string(kp_data[i].stellar_occ[j].time_start),2)
          profile_index = profile_index+1
        endif
      endfor
    endfor
    print,'Valid retrieval species are:'
    for i=0,n_elements(retrieval_names)-1 do begin
      print,string(i+1)+':'+retrieval_names[i]
    endfor
    return
  endif



  ;CHECK FIRST THAT THE SUPPLIED DATA STRUCTURE INCLUDES PERIAPSE DATA
  base_tags = tag_names(kp_data)
  data_check = where(base_tags eq 'STELLAR_OCC')
  if data_check eq -1 then begin
    print,'The data structure appears to not have any OCCULTATION data.'
    print,'Try again with a different KP data structure.'
    return
  endif

  ;INFORM THE USER THAT ALL ORBITS MAY BE PLOTTED
  if keyword_set(profile_expand) eq 1 then begin
    print,'By default, all periapse data will be plotted.'
    print,'This includes orbits ',strtrim(string(kp_data[0].orbit)),$
      ' to ',strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit))
    print,'Use the PROFILES keyword to choose a subset of orbits ' $
      +'to be plotted.'
    print,'***Warning*** If all profiles are plotted at once, ' $
      +'the plot may be unintelligible. Consider down-selection'
    print,''
  endif

  ;INFORM THE USER ABOUT THE PROFILES INCLUDED IN THE DATA SET
  if keyword_set(profiles) ne 1 then begin
    print,'The following Occultation  Profiles are included in ' $
      +'the loaded data structure.'
    print,'Use the numerical index to downselect which profiles to display'
    print,''
    profile_index = 1
    for i=0,n_elements(kp_data)-1 do begin
      for j=0,2 do begin
        if kp_data[i].stellar_occ[j].time_start ne '' then begin
          print,strtrim(string(profile_index),2)+': Orbit #'$
            +strtrim(string(kp_data[i].orbit),2)+', Profile start time '$
            +strtrim(string(kp_data[i].stellar_occ[j].time_start),2)
          profile_index = profile_index+1
        endif
      endfor
    endfor
  endif

  if keyword_set(ret_species) ne 1 then begin
    print,'By default, all species will be plotted.'
    print,'Use the RET_SPECIES keyword to select a subset of plotted species.'
    print,'Valid species are:'
    for i=0,n_elements(retrieval_names)-1 do begin
      print,string(i+1)+':'+retrieval_names[i]
    endfor
  endif

  ;IF USER HAS DOWNSELECTED SPECIES, CHANGE VARIOUS PARAMTERS TO MATCH

  if keyword_set(ret_species) then begin
    retrieval_dimensions = n_elements(ret_species)
    retrieval_labels = retrieval_names(ret_species-1)
    retrieval = keyword_set(1B)
  endif else begin
    retrieval_dimensions = n_elements(retrieval_names)
    retrieval_labels = retrieval_names
    ret_species = indgen(retrieval_dimensions)+1 ; same hack as above
  endelse

  species_dimensions = retrieval_dimensions
  species_label = retrieval_labels

  ;IF USER HAS DOWNSELECTED PROFILES, CHANGE VARIOUS PARAMETERS TO MATCH
  profile_inclusion = intarr(n_elements(kp_data.orbit)*3)
  profile_labels = strarr(n_elements(kp_data.orbit)*3)
  if keyword_set(profiles) then begin
    profile_dimensions = n_elements(profiles)
    profile_inclusion[profiles-1] = 1
  endif else begin
    profile_dimensions = profile_index-1
    profile_inclusion[*] = 1
  endelse

  ; may want to call this numplots or something more descriptive...
  tot_species = profile_dimensions * species_dimensions


  ;EXTRACT THE DATA FROM THE STRUCTURE INTO TEMPORARY ARRAYS
  ; TO FACILITATE THE PLOT PROCEDURE/FUNCTIN CALLS
  altitude = kp_data[0].stellar_occ[0].alt
  nalt = n_elements(altitude)
  retrieval_data = fltarr((n_elements(kp_data)),3,retrieval_dimensions,nalt)
  retrieval_error = fltarr((n_elements(kp_data)),3,retrieval_dimensions,nalt)
  ;
  ;  NB, this code does not yet take into account systematic uncertainty
  ;
  index=0
  for i=0,n_elements(kp_data) -1 do begin
    for j=0,2 do begin
      iprof = 3*i+j
      if kp_data[i].stellar_occ[j].time_start ne '' then begin
        retrieval_data[i,j,*,*] = kp_data[i].stellar_occ[j]$
          .retrieval[(ret_species-1),*]
        retrieval_error[i,j,*,*] = kp_data[i].stellar_occ[j]$
          .retrieval_unc[(ret_species-1),*]

        if profile_inclusion[iprof] eq 1 then begin
          profile_labels[index] = 'Orbit ' $
            + strtrim(string(kp_data[i].orbit),2) $
            + ', Profile ' + strtrim(string(j+1),2)
          index=index+1
        endif
      endif ; data existence check
    endfor  ; loop over orbit profiles
  endfor    ; loop over orbits

  species_data = fltarr(n_elements(kp_data), 3, species_dimensions, nalt)
  species_error = fltarr(n_elements(kp_data), 3, species_dimensions, nalt)
  for i = 0,retrieval_dimensions-1 do begin
    j = i
    species_data[*,*,j,*] = retrieval_data[*,*,i,*]
    species_error[*,*,j,*] = retrieval_error[*,*,i,*]
  endfor

  ;DETERMINE HOW MANY PANELS ARE GOING TO BE NEEDED
  ; BASED ON EXPANSION OPTIONS

  ret_plot = 1

  rows = keyword_set(profile_expand) ? profile_dimensions : 1
  columns = 0
  if keyword_set(species_expand) then begin
    columns = columns + retrieval_dimensions
  endif else begin
    columns = 1
  endelse

  ;DEFINE THE LINESTYLES AND COLORS FOR EACH SPECIES OR PROFILE
  ret_linestyle = intarr(retrieval_dimensions)
  ret_thick = replicate(1,retrieval_dimensions)
  if keyword_set(species_expand) ne 1 then begin
    for i=0, n_elements(ret_species)-1 do ret_linestyle[i] = i
  endif
 
  species_linestyle=ret_linestyle
  species_thick=ret_thick

  ;
  ;  Define the colors of the plots and
  ;  other graphics-specific parameters
  ;
  ;  Load supplied color table, or use RAINBOW+BLACK as default
  ;
  if keyword_set(color_table) then begin
    loadct, color_table, /silent
  endif else begin
    loadct, 40, /silent
  endelse

  if keyword_set(directgraphics) then begin
    device, decomposed=0, retain=2
    !p.background='FFFFFF'x
    !p.color=0
    profile_colors = intarr(profile_dimensions)
    ;
    ; SET DEFAULT WINDOW SIZES
    ;
    if ~arg_present(winX) then winX=1000
    if ~arg_present(winY) then winY=800
    !p.multi=[0,columns, rows, 0, 1]
  endif else begin
    if ~arg_present(winX) then winX=640
    if ~arg_present(winY) then winY=512
    color_vector = bytarr(3,profile_dimensions)
    tvlct,r,g,b,/get
  endelse

  ; Define colors for individula profiles; but only if they are
  ; to be plotted in the same window.  Otherwise, set all to black
  for i=0,profile_dimensions-1 do begin
    color_index = i*(255/profile_dimensions)
    if keyword_set(directgraphics) then begin
      profile_colors[i] = keyword_set(profile_expand) ? 0 : color_index
    endif else begin
      color_vector[*,i] = keyword_set(profile_expand) $
        ? [r[0], g[0], b[0]] $
        : [r[color_index], $
        g[color_index], $
        b[color_index]]
    endelse
  endfor
  ;
  ;  define the layout vector
  ;  This is a three element vector: column, row, index
  ;  Column and row defined above
  ;  index pulled from existing codes
  ;
  mvn_kp_iuvs_occ_layout, species_expand=species_expand, $
    profile_expand=profile_expand, $
    species_dim=species_dimensions, $
    profile_dim=profile_dimensions, $
    layout_vector=layout_vector, $
    oplot_vector=oplot_vector, $
    hide_vector=hide_vector

  layout_vector = [[replicate(columns,tot_species)],$
    [replicate(rows,tot_species)],$
    [layout_vector]]

  ;
  ;  Determine names for the plots: species + profile
  ;
  plot_name = strarr(species_dimensions,profile_dimensions)
  for iprof = 0,profile_dimensions-1 do $
    for ispec = 0,species_dimensions-1 do $
    plot_name[ispec,iprof] = species_label[ispec] + '!c' $
    + profile_labels[iprof]

  ;--------------------------------------------------------------------
  ;NEEDS WORK
  ;
  ;DETERMINE APPROPRIATE MARGINS
  ;MARGINS
  ; Should these go into the appropriate plotting routines?

  p_margin = replicate(0.1,4) ; Set Default for OO graphics
  if keyword_set(species_expand) then begin
    if keyword_set(directgraphics) then begin
      y_label_margin = [5,10]
    endif else begin
      p_margin[3] = 0.125 ; top margin
      ;              p_margin[1] = 0.1 ; bot margin
    endelse
  endif
  if keyword_set(profile_expand) then begin
    if keyword_set(directgraphics) then begin
      x_label_margin = [15,5]
    endif else begin
      ;              p_margin[0] = 0.1; left margin
      ;              p_margin[2] = 0.1; right margin
    endelse
  endif
  ;
  ;-----------------------------------------------------------------------

  ;
  ;  If log plotting requested, set the appropriate keyword
  ;
  if keyword_set(log) then xlog=keyword_set(1B)
  if keyword_set(linear) then xlog=keyword_set(0B)
  ;
  ;  Check for linear versus log conflicts
  ;
  if keyword_set(log) eq keyword_set(linear) then begin
    print,'*****WARNING*****'
    print,'Keyword /LINEAR and keyword /LOG '
    print,'have either both been provided, or neither was provided.'
    print,'Default will be to choose /LOG plotting.'
    linear = keyword_set(0B) & log = keyword_set(1B)
  endif
  ;
  ; Call the appropriate plotting routine
  ;
  if keyword_set(directgraphics) then begin
    ;  Call DG plotting routine
    mvn_kp_iuvs_occ_dg, kp_data, $
      retrieval_data=retrieval_data, $
      altitude_retrieval=altitude_retrieval, $
      ret_species=ret_species,$
      nolegend=nolegend, linear=linear, $
      species_expand=species_expand, $
      profile_expand=profile_expand,$
      ret_linestyle=ret_linestyle, $
      ret_thick=ret_thick, $
      profile_dimensions=profile_dimensions, $
      profile_inclusion=profile_inclusion, $
      profile_colors=profile_colors, window=window, $
      winX=winX, winY=winY, $
      retrieval_labels=retrieval_labels, $
      profile_labels=profile_labels, $
      species_expand=species_expand, $
      profile_expand=profile_expand
  endif else begin
    ; call OO plotting routine
    mvn_kp_iuvs_occ_oo, kp_data=kp_data, species_data=species_data, $
      altitude=altitude, $
      layout_vector=layout_vector, $
      plot_name=plot_name, oplot_vector=oplot_vector, $
      species_linestyle=species_linestyle, $
      species_thick=species_thick, xlog=xlog, $
      hide_vector=hide_vector, color_vector=color_vector, $
      species_dimensions=species_dimensions, $
      profile_dimensions=profile_dimensions, $
      profile_inclusion=profile_inclusion, $
      oo=oo, leg=leg, winx=winx, winy=winy, $
      nolegend=nolegend, _extra=e, $
      retrieval_labels=retrieval_labels, $
      profile_labels=profile_labels, $
      species_expand=species_expand, $
      profile_expand=profile_expand
  endelse

end
