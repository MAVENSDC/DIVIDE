;+
;
; :Name: mvn_kp_iuvs_limb
; 
; :Author: McGouldrick
; 
; :Description:
;   This routine is the wrapper for the IUVS Periapse Limb scan 
;   plotting routines.  It sets the relevant information needed 
;   by the plotting tools, and then calles either the direct
;   graphics (DG) or Object-Oriented graphics (OO) plotting routine.
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
;    density : in, optional, type=byte
;       if selected, the density KP data will be plotted
;    radiance : in, optional, type=byte
;       if selected, the radiance KP data will be plotted
;    profiles : in, optional, type=intarr(ndims)
;       an array listing the orbits to be plotted 
;    den_species : in, optional, type=intarr(ndims)
;       an array listing the density measurements of particular 
;       species to be plotted 
;    rad_species : in, optional, type=intarr(ndims)
;       an array listing the radiance measurements of particular 
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
; :History:   1.0   June 8, 2015
; 
;-
pro MVN_KP_IUVS_LIMB_NEW, kp_data, density=density, radiance=radiance, $
                      profiles=profiles, den_species=den_species, $
                      rad_species=rad_species, nolegend=nolegend, $
                      linear=linear, log=log, $
                      oo=oo, leg=leg, directgraphics=directgraphics, $
                      species_expand=species_expand, $
                      profile_expand=profile_expand,$
                      range=range,colortable=colortable,window=window, $
                      winX=winX, winY=winY, help=help, _extra=e

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_iuvs_limb'
    return
  endif

  ;CHECK THE DATA RANGE
  if keyword_set(range) then begin
    print,'The data structure contains data that spans the time range of '$
      +strtrim(string(kp_data[0].periapse[0].time_start),2)+' to '$
      +strtrim(string(kp_data[n_elements(kp_data)-1].periapse[2].time_stop),2)
    print,'Equivalently, this includes the orbits of '$
      +strtrim(string(kp_data[0].orbit),2)+' to '$
      +strtrim(string(kp_data[n_elements(kp_data)-1].orbit),2)
    return
  endif

  ; Check that either radiance, or density, or a list of species 
  ;  has been requested by the user.  If not, exit.
  if( ~keyword_set(radiance) and ~keyword_set(density) and $
      ~keyword_set(rad_species) and ~keyword_set(den_species) )then begin
    print,"****ERROR****"
    print,"At least one of '/radiance' or '/density', or a selection of "
    print,"   'rad_species' or 'den_species' must be provided."
    print,"See users guide, and/or use the keyword '/help' " $
          + "for more information."
    return
  endif
    
  ;CHECK FIRST THAT THE SUPPLIED DATA STRUCTURE INCLUDES PERIAPSE DATA
  base_tags = tag_names(kp_data)
  data_check = where(base_tags eq 'PERIAPSE')
  if data_check eq -1 then begin
    print,'The data structure appears to not have any PERIAPSE data.'
    print,'Try again with a different KP data structure.'
    return
  endif
    
  ;DEFINE THE SPECIES NAME STRINGS FOR DENSITY AND RADIANCE
  density_names = kp_data[0].periapse[0].density_id
  radiance_names = kp_data[0].periapse[0].radiance_id

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
    print,'The following Periapse Limb Scan Profiles are included in ' $
         +'the loaded data structure.'
    print,'Use the numerical index to downselect which profiles to display'
    print,''
    profile_index = 1
    for i=0,n_elements(kp_data)-1 do begin
      for j=0,2 do begin
        if kp_data[i].periapse[j].time_start ne '' then begin
          print,strtrim(string(profile_index),2)+': Orbit #'$
               +strtrim(string(kp_data[i].orbit),2)+', Profile start time '$
               +strtrim(string(kp_data[i].periapse[j].time_start),2)
          profile_index = profile_index+1
        endif
      endfor
    endfor
  endif
    
  ;INFORM THE USER ABOUT THE CHOICE OF SPECIES TO PLOT
  if keyword_set(den_species) ne 1 then begin
    print,'By default, all species will be plotted.'
    print,'Use the SPECIES keyword to select a subset of plotted species.'
    if keyword_set(density) then begin
      print,'Valid species are:'
      for i=0,n_elements(density_names)-1 do begin
        print,string(i+1)+':'+density_names[i]
      endfor
    endif
  endif
  if keyword_set(rad_species) ne 1 then begin 
    if keyword_set(radiance) then begin
      print,'Valid species are:'
      for i=0,n_elements(radiance_names)-1 do begin
        print,string(i+1)+':'+radiance_names[i]
      endfor
    endif 
  endif    

  ;IF USER HAS DOWNSELECTED SPECIES, CHANGE VARIOUS PARAMTERS TO MATCH
  
  if keyword_set(den_species) then begin
    density_dimensions = n_elements(den_species)
    density_labels = '$\rho$: '+density_names(den_species-1)
    density = keyword_set(1B)
  endif else begin
    if( keyword_Set(density) )then begin
      density_dimensions = n_elements(density_names)
      density_labels = '$\rho$: '+density_names
      den_species = indgen(density_dimensions)+1 ; same hack as above
    endif else begin
      density_dimensions = 0
    endelse
  endelse
  if keyword_set(rad_species) then begin
    radiance_dimensions = n_elements(rad_species)
    radiance_labels = 'I: '+radiance_names(rad_species-1)
    radiance = keyword_set(1B)
  endif else begin
    if( keyword_set(radiance) )then begin
      radiance_dimensions = n_elements(radiance_names)
      radiance_labels = 'I: '+radiance_names
      rad_species = indgen(radiance_dimensions)+1
    endif else begin
      radiance_dimensions = 0
    endelse
  endelse
  species_dimensions = radiance_dimensions + density_dimensions
  if radiance_dimensions gt 0 then begin
    if density_dimensions gt 0 then begin
      species_label = [radiance_labels, density_labels]
    endif else begin
      species_label = radiance_labels
    endelse
  endif else begin
    species_label = density_labels
  endelse

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

  ;DEFINE THE ALTITUDE RANGE FOR THE KP DATA
  altitude = kp_data[0].periapse[0].alt
  nalt = n_elements(altitude) 

  ;EXTRACT THE DATA FROM THE STRUCTURE INTO TEMPORARY ARRAYS 
  ; TO FACILITATE THE PLOT PROCEDURE/FUNCTIN CALLS   
  if( keyword_set(radiance) )then begin
    radiance_data = fltarr((n_elements(kp_data)),3,radiance_dimensions,nalt)
    radiance_error = fltarr((n_elements(kp_data)),3,radiance_dimensions,nalt)
  endif
  if( keyword_set(density) )then begin
    density_data = fltarr((n_elements(kp_data)),3,density_dimensions,nalt)
    density_error = fltarr((n_elements(kp_data)),3,density_dimensions,nalt)
  endif
;
;  NB, this code does not yet take into account systematic uncertainty
;
  index=0
  for i=0,n_elements(kp_data) -1 do begin
    for j=0,2 do begin
      if kp_data[i].periapse[j].time_start ne '' then begin
        if( keyword_set(radiance) )then begin
          radiance_data[i,j,*,*] = kp_data[i].periapse[j]$
                                   .radiance[(rad_species-1),*]
          radiance_error[i,j,*,*] = kp_data[i].periapse[j]$
                                    .radiance_unc[(rad_species-1),*]
        endif
        if( keyword_set(density) )then begin
;
;  HACK HACK HACK To test density plotting
;  Just fill the arrays with radiance info
;  This only works because Nden lt Nrad
;
          density_data[i,j,*,*] = 1e3*kp_data[i].periapse[j]$
                                  .radiance[(den_species-1),*]
          density_error[i,j,*,*] = 1e3*kp_data[i].periapse[j]$
                                   .radiance_unc[(den_species-1),*]
;-orig
;          density_data[i,j,*,*] = kp_data[i].periapse[j]$
;                                  .density[(den_species-1),*]
;          density_error[i,j,*,*] = kp_data[i].periapse[j]$
;                                   .density_unc[(den_species-1),*]
;-/orig
        endif
        profile_labels[index] = 'Orbit '+strtrim(string(kp_data[i].orbit),2)$
                              + ', Profile '+strtrim(string(j+1),2)
        index=index+1
      endif
    endfor
  endfor
  ;
  ;  combine the density and radiance data into a single array
  ;
  species_data = fltarr(n_elements(kp_data), 3, species_dimensions, nalt)
  species_error = fltarr(n_elements(kp_data), 3, species_dimensions, nalt)
  for i = 0,radiance_dimensions-1 do begin
    species_data[*,*,i,*] = radiance_data[*,*,i,*]
    species_error[*,*,i,*] = radiance_error[*,*,i,*]
  endfor
  for i = 0,density_dimensions-1 do begin
    j = radiance_dimensions+i
    species_data[*,*,j,*] = density_data[*,*,i,*]
    species_error[*,*,j,*] = density_error[*,*,i,*]
  endfor
  
  ;DETERMINE HOW MANY PANELS ARE GOING TO BE NEEDED 
  ; BASED ON EXPANSION OPTIONS
         
  rad_plot = 0
  den_plot = 0
  if keyword_set(radiance) then rad_plot = 1
  if keyword_set(density) then den_plot = 1
      
  rows = keyword_set(profile_expand) ? profile_dimensions : 1      
  columns = 0
  if keyword_set(species_expand) then begin
    if keyword_set(density) then columns = columns + density_dimensions
    if keyword_set(radiance) then columns = columns + radiance_dimensions
  endif else begin
    columns = keyword_set(density) + keyword_set(radiance)
  endelse

  ;DEFINE THE LINESTYLES AND COLORS FOR EACH SPECIES OR PROFILE
  if keyword_set(density) then begin
    den_linestyle = intarr(density_dimensions)
    den_thick = replicate(1,density_dimensions)
  endif
  if keyword_set(radiance) then begin
    rad_linestyle = intarr(radiance_dimensions)
    rad_thick = intarr(radiance_dimensions)
  endif
  if keyword_set(species_expand) ne 1 then begin
    for i=0, n_elements(den_species)-1 do den_linestyle[i] = i
    for i=0, n_elements(rad_species)-1 do rad_linestyle[i] = i mod 6
    if n_elements(rad_species) gt 7 then begin
      rad_thick[0:6] = 1
      rad_thick[7:*] = 2
    endif else begin
      ; only define if we are doing radiance plots
      if( keyword_set(radiance) )then rad_thick[*] = 1
    endelse
  endif
  ;
  ;  Combine the radiance and density line styles and thickness
  ;
  if keyword_set(radiance) then begin
    if keyword_set(density) then begin
      species_linestyle=[rad_linestyle,den_linestyle]
      species_thick = [rad_thick,den_thick]
    endif else begin
      species_linestyle=rad_linestyle
      species_thick=rad_thick
    endelse
  endif else begin
    if keyword_set(density) then begin
      species_linestyle=den_linestyle
      species_thick=den_thick
    endif
  endelse
  ;
  ;  Define the colors of the plots and
  ;  other graphics-specific parameters
  ;
  ;  Load supplied color table, or use RAINBOW+BLACK as default
  ;
  if arg_present(color_table) then begin
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
    color_vector = bytarr(3,profile_dimensions)
    tvlct,r,g,b,/get
  endelse
     
  ; Define colors for individula profiles; but only if they are
  ; to be plotted in the same window.  Otherwise, set all to black
  for i=0,profile_dimensions-1 do begin
    color_index = i*(255/profile_dimensions)
    print,color_index
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
  mvn_kp_iuvs_limb_layout, species_expand=species_expand, $
                           profile_expand=profile_expand, $
                           species_dim=species_dimensions, $
                           profile_dim=profile_dimensions, $
                           radiance_dim=radiance_dimensions, $
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
  ;  If log plotting requested, set the appropriate keyword
  ;
  if keyword_set(log) then xlog=keyword_set(1B)
  ;
  ; Call the appropriate plotting routine
  ;
  if keyword_set(directgraphics) then begin
    ;  Call DG plotting routine
    mvn_kp_iuvs_limb_dg, kp_data, radiance_data=radiance_data, $
                         density_data=density_data, altitude=altitude, $
                         den_species=den_species, rad_species=rad_species, $
                         nolegend=nolegend, linear=linear, $
                         species_expand=species_expand, $
                         profile_expand=profile_expand,$
                         rad_linestyle=rad_linestyle, $
                         den_linestyle=den_linestyle, $
                         rad_thick=rad_thick, den_thick=den_thick, $
                         profile_inclusion=profile_inclusion, $
                         profile_colors=profile_colors, window=window, $
                         winX=winX, winY=winY, help=help, _extra=e
  endif else begin
    ; call OO plotting routine
    mvn_kp_iuvs_limb_oo, kp_data=kp_data, species_data=species_data, $
                         altitude=altitude, layout_vector=layout_vector, $
                         plot_name=plot_name, oplot_vector=oplot_vector, $
                         species_linestyle=species_linestyle, $
                         species_thick=species_thick, $
                         hide_vector=hide_vector, color_vector=color_vector, $
                         species_dimensions=species_dimensions, $
                         profile_dimensions=profile_dimensions, $
                         oo=oo, leg=leg, _extra=e
  endelse

end
