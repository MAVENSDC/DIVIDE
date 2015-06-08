;+
;
; :Name: mvn_kp_iuvs_plot_peri
; 
; :Author: Kristopher Larsen
; 
; :Description:
;   This routine plots the IUVS PERIAPSE limb-scan KP data. 
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
; :History:   1.0   July 8, 2014
; 
; :Version: 1.0 (McGouldrick) 2015-Jun-04
;-
pro MVN_KP_IUVS_PLOT_PERI, kp_data, density=density, radiance=radiance, $
                           profiles=profiles, den_species=den_species, $
                           rad_species=rad_species, nolegend=nolegend, $
                           linear=linear, $
                           oo=oo, leg=leg, directgraphics=directgraphics, $
                           species_expand=species_expand, $
                           profile_expand=profile_expand,$
                           range=range,colortable=colortable,window=window, $
                           winX=winX, winY=winY, help=help

  ;provide help for those who don't have IDLDOC installed
  if keyword_set(help) then begin
    mvn_kp_get_help,'mvn_kp_iuvs_plot_peri'
    return
  endif

   ;set the default colors
    device,decompose=0
    device,retain=2
    !p.background='FFFFFF'x
    !p.color=0
    if keyword_set(colortable) then begin
      loadct,colortable,/silent
    endif else begin
      loadct,39,/silent
    endelse

  ;SET FLAGS IF THE USER WANTS LINEAR SCALES INSTEAD OF LOGARITHMIC
    if keyword_set(linear) then begin
      log_option = 0
    endif else begin
      log_option = 1
    endelse
    
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

    
  ;CHECK THE DATA RANGE
    if keyword_set(range) then begin
      print,'The data structure contains data that spans the time range of '$
       +strtrim(string(kp_data[0].periapse[0].time_start),2)+' to '+$
       strtrim(string(kp_data[n_elements(kp_data)-1].periapse[2].time_stop),2)
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
    ;old    density_names = ['CO2/CO2+','CO','H','O','C','N','N2']
    ;old    radiance_names = ['CO2/CO2+','CO','H','O_1304','O_1306',$
    ;old                      '0_2972','C','N','N2','NO']
    density_names = kp_data[0].periapse[0].density_id
    radiance_names = kp_data[0].periapse[0].radiance_id

  ;INFORM THE USER THAT ALL ORBITS MAY BE PLOTTED
    if keyword_set(profile_expand) eq 1 then begin
      print,'By default, all periapse data will be plotted.'
      print,'This includes orbits ',strtrim(string(kp_data[0].orbit)),$
            ' to ',strtrim(string(kp_data[n_elements(kp_data.orbit)-1].orbit))
      print,'Use the PROFILES keyword to choose a subset of orbits to be plotted.'
      print,'***Warning*** If all profiles are plotted at once, the plot may be unintelligible. Consider down-selection'
      print,''
    endif
    if keyword_set(profiles) ne 1 then begin
      print,'The following Periapse Limb Scan Profiles are included in the loaded data structure.'
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

  ;INFORM THE USER ABOUT THE PROFILES INCLUDED IN THE DATA SET
    

  ;IF USER HAS DOWNSELECTED SPECIES, CHANGE VARIOUS PARAMTERS TO MATCH
  
    if keyword_set(den_species) then begin
      density_dimensions = n_elements(den_species)
      density_labels = '$\rho$: '+density_names(den_species-1) ;-km hack to go from 
                                                    ; 1-start to 0-start
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
;-km need to get rid of this hard-coding.  Never mind that it is wrong....
;    altitude = intarr(30)
;    for i=0,29 do begin
;      altitude[i] = 100 + (4*i)
;    endfor
  altitude = kp_data[0].periapse[0].alt
  nalt = n_elements(altitude) 
  ;EXTRACT THE DATA FROM THE STRUCTURE INTO TEMPORARY ARRAYS
    
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
;-km make these species_data and species_error?
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
  
    ;DETERMINE HOW MANY PANELS ARE GOING TO BE NEEDED BASED ON EXPANSION OPTIONS
         
      rows = 1
      columns = 2
      order = 1
      rad_plot = 0
      den_plot = 0
      
      if keyword_set(profile_expand) then begin
        rows = index
        if keyword_set(profiles) then rows = n_elements(profiles)
      endif
      
      columns = 0
      if keyword_set(species_expand) then begin
        if keyword_set(density) then columns = columns + density_dimensions
        if keyword_set(radiance) then columns = columns + radiance_dimensions
      endif else begin
        columns = keyword_set(density) + keyword_set(radiance)
      endelse

      if keyword_set(radiance) then rad_plot = 1
      if keyword_set(density) then den_plot = 1

      !p.multi = [0,columns,rows,0,order]
    ;DEFINE THE LINESTYLES AND COLORS FOR EACH SPECIES OR PROFILE
    
     if keyword_set(density) then $
       den_linestyle = intarr(n_elements(den_species))
       den_thick = replicate(1,n_elements(den_species))
     if keyword_set(radiance) then begin
       rad_linestyle = intarr(n_elements(rad_species))
       rad_thick = intarr(n_elements(rad_species))
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
     ;  Combine the raiance and density line styles and thickness
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
     ;  Define the colors of the plots
     ;
     if keyword_set(directgraphics) then begin
       profile_colors = intarr(n_elements(kp_data.orbit)*3) ; direct
     endif else begin
       color_vector = bytarr(3,n_elements(kp_data.orbit)*3) ; OO
       if arg_present(color_table) then begin
         loadct,color_table,/silent
       endif else begin
         loadct,40,/silent
       endelse
       tvlct,r,g,b,/get
     endelse
     
     for i=0, (n_elements(kp_data.orbit)*3)-1 do begin
       color_index = i*(255/(n_elements(kp_data.orbit)*3))
       if keyword_set(directgraphics) then begin
         profile_colors[i] = color_index ; direct
       endif else begin
         color_vector[*,i] = [r[color_index], $
                              g[color_index], $
                              b[color_index]]
       endelse
     endfor

     ;
     ;  define the layout vector
     ;  This is a three element vector: column, row, index
     ;  Colunm and row defined above
     ;  index pulled from existing codes
     ;
     mvn_kp_iuvs_limb_layout, species_expand=species_expand, $
                              profile_expand=profile_expand, $
                              species_dim=species_dimensions, $
                              profile_dim=profile_dimensions, $
                              radiance_dim=radiance_dimensions, $
                              layout_vector=layout_vector, $
                              oplot_vector=oplot_vector

     layout_vector = [[replicate(columns,tot_species)],$
                      [replicate(rows,tot_species)],$
                      [layout_vector]]

     ;PLOT
     ; is there a more eloquent way of doing this instead of all the 
     ; possible different options?
     ;-km no, but there may be a more elegant way.
     ;
     ;DETERMINE APPROPRIATE MARGINS    
         ;MARGINS 
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

;-km In below, should move direct graphics check *into* the plotting 
;-km   loop.  I.e., only have *one* loop over plot, and that contains
;-km   an if..then..else for direct graphics.

;-km *Might* also be possible to flatten thee four cases into a single
;-km   iteration with approatiately chosen keywords and conditionals
;-km   but the changing indexing orders make this difficult to impossible

;-km- Need to build the hide_vector for legend outside of plot loops

print,profile_inclusion
;
;  Determine names for the plots: species + profile
;
plot_name = strarr(species_dimensions,profile_dimensions)
for iprof = 0,profile_dimensions-1 do $
  for ispec = 0,species_dimensions-1 do $
  plot_name[ispec,iprof] = species_label[ispec] + '!c' $
  + profile_labels[iprof]
;    endfor
;  endfor

if ~keyword_set(species_expand) and ~keyword_set(profile_expand) then begin
;
; determine which legend items to hide
;
  hide_vector = bytarr(species_dimensions*profile_dimensions)
  index = indgen(species_dimensions*profile_dimensions)
;
;  Show all species for first profile
;  and only the first for the later profiles
;
  show = where( index lt tot_species or  $
                (index mod tot_species) eq 0, nshow, $
                complement = hide, ncomplement=nhide )
  if nhide gt 0 then hide_vector[hide] = 1
  ;
  ;  
  ;
  ;  Now, need to change the names of the later profiles (that indicate)
  ;  who they are by color
  ;
  profile_only = where( index mod tot_species eq 0 and index ne 0, count )
  if count gt 0 then leg_label_profile = 1
endif
;
; Here is my new plotting loop
;
plot1=[]

for ispec = 0,species_dimensions-1 do begin
  k = ispec
  for iprof = 0,profile_dimensions-1 do begin
    i = (array_indices(intarr(n_elements(kp_data),3),iprof))[0]
    j = (array_indices(intarr(n_elements(kp_data),3),iprof))[1]
    igraph = ispec * profile_dimensions + iprof
    if oplot_vector[igraph] eq -1 then begin
      plot1 = [plot1,plot( species_data[i,j,k,*], altitude, $
        xlog=log_option, ytitle='Altitude[km]', $
        linestyle=species_linestyle[k], $
        thick=species_thick[k], $
        color=color_vector[*,iprof], $
        layout=layout_vector[igraph,*], $
        overplot=0, $
        current = keyword_set(iprof+k), $
        name=plot_name[k,iprof] )]
    endif else begin
      plot1 = [plot1,plot( species_data[i,j,k,*], altitude, $
        xlog=log_option, ytitle='Altitude[km]', $
        linestyle=species_linestyle[k], $
        thick=species_thick[k], $
        color=color_vector[*,iprof], $
        ;              layout=layout_vector[igraph,*], $
        overplot=plot1[oplot_vector[igraph]], $
        current = keyword_set(iprof+k), $
        name=plot_name[k,iprof] )]
    endelse
  endfor
endfor
goto, skip_the_old

; Diff for others?
;stop
      if rad_plot eq 1 then begin ; will want to remove this
       ;
       ;  Generate the radiance plot(s)
       ;
       if (keyword_set(species_expand) eq 0) and $
          (keyword_set(profile_expand) eq 0) then begin
        ;
        ;  Generate the plot in OO graphics
        ;   (some hacks in plot command but otherwise works)
        ;
        check_index = 0
        plot1=[]
        for i = 0,n_elements(kp_data)-1 do begin
         for j = 0,2 do begin ; periapse records
          iprof = 3*i+j
          if kp_data[i].periapse[j].time_start ne '' then begin
           if profile_inclusion[check_index] then begin
            for k = 0,species_dimensions-1 do begin
             igraph = k+iprof*species_dimensions
;-orig             plot1 = [plot1,plot( radiance_data[i,j,k,*], altitude, $
;-km HACK to test/fix error in layout vector
;             if keyword_set(rad_plot) then begin
;               if k lt radiance_dimensions then begin
;                layout_vector[igraph,2] = 1
;               endif else begin
;                layout_vector[igraph,2] = 2
;               endelse
;             endif else begin
;               layout_vector[igraph,2] = 1
;             endelse
;-km-/HACK
             if oplot_vector[igraph] eq -1 then begin
              ;
              ;  This is a designated new plot window
              ;
              plot1 = [plot1,plot( species_data[i,j,k,*], altitude, $
                xlog=log_option, ytitle='Altitude[km]', $
                linestyle=species_linestyle[k], $
                thick=species_thick[k], $
                color=color_vector[*,iprof], $
                layout=layout_vector[igraph,*], $
                overplot=0, $
                current = keyword_set(i+j+k), $
                name=plot_name[k,iprof] )]
             endif else begin
              ;
              ;  oplot_vector tells us which plot to draw on
              ;
              plot1 = [plot1,plot( species_data[i,j,k,*], altitude, $
                             xlog=log_option, ytitle='Altitude[km]', $
                             linestyle=species_linestyle[k], $
                             thick=species_thick[k], $
                             color=color_vector[*,iprof], $
                             layout=layout_vector[igraph,*], $
                             overplot=plot1[oplot_vector[igraph]], $
                             current = keyword_set(i+j+k), $
                             name=plot_name[k,iprof] )]
             endelse
;             junk = 's'
;             while junk eq 's' do read,junk,prompt='press (s) to stop:'
;             junk = 's'
            endfor
           endif ; profile_inclusion
          endif   ; time_start string not NULL
         endfor    ; periapse records
        endfor      ; time records
        leg1 = legend(target=plot1) ; makes one big legend
        
;       endelse      ; graphics type
      endif         ; expand species AND profiles
stop
goto, skip_the_rest

        if keyword_set(species_expand) and $
           (keyword_set(profile_expand) eq 0) then begin
          ;
          ; RADIANCE PLOT EXPANDING TO INDIVIDUALLY PLOT ALL SPECIES
          ;
          if keyword_set(directgraphics) then begin
            for i=0,n_elements(rad_species)-1 do begin
              check_index = 0
              plot,radiance_data[0,0,i,*],altitude,title=radiance_labels[i],$
                   thick=2,xlog=log_option,charsize=1.5,yrange=[100,220],$
                   ytitle='Altitude, km',/nodata,ymargin=y_label_margin
              for j=0,n_elements(kp_data)-1 do begin
                for k=0,2 do begin
                  if kp_data[j].periapse[k].time_start ne '' then begin
                    if profile_inclusion[check_index] eq 1 then begin        
                      oplot,radiance_data[j,k,i,*],altitude,$
                            thick=rad_thick[i],$
                            color=profile_colors[(j*3)+k]
                    endif
                    check_index = check_index+1
                  endif
                endfor ; k=0,2
              endfor   ; j=0,nelem(kp_data)
            endfor     ; i=0,nelem(rad_species)
          endif else begin
            ; 
            ; Produce the plot in OO graphics
            ;
            for i = 0,n_elements(rad_species)-1 do begin
              check_index=0
temp = keyword_set(i) ? '' : 'Altitude'
              for j=0,n_elements(kp_data)-1 do begin
                for k=0,2 do begin ; profiles
                  if( profile_inclusion[check_index] )then begin
                    plot1 = plot( radiance_data[j,k,i,*], altitude, $
                                  thick=rad_thick[i], $
                                  title=radiance_labels[i], xlog=log_option, $
                                  font_size=12, rgb_table=40, $
;                                  vert_colors=profile_colors[(j*3)+k], $
                                  color=color_vector[*,(j*3)+k], $
                                  ytitle='Altitude [km]', $
;                                  ytitle=temp, $;(keyword_set(i)?'':'Altitude [km]'), $
                                  layout=[columns,rows,i+1], $
                                  margin=p_margin, $
                                  overplot = keyword_set(j+k), $
                                  current = keyword_set(i+j+k) )
                  endif
                endfor ; k=0,2
              endfor   ; j=0,nelem(kp_data)
            endfor     ; i=0,nelem(rad_species)
          endelse      ; graphics type
         endif         ; expand species only
         
        if keyword_set(profile_expand) and $
           (keyword_set(species_expand) eq 0) then begin
          ;
          ; RADIANCE PLOT EXPANDING TO INDIVIDUALLY PLOT EACH PROFILE
          ;
          if keyword_set(directgraphics) then begin
            check_index = 0
            label_index = 0
            for i=0,n_elements(kp_data)-1 do begin
              for j=0,2 do begin
                if kp_data[i].periapse[j].time_start ne '' then begin
                  if profile_inclusion[check_index] eq 1 then begin
                    plot,radiance_data[i,j,0,*],altitude,thick=2,$
                         xlog=log_option,charsize=1.5,yrange=[100,220],$
                         ytitle='Altitude, km',/nodata,ymargin=y_label_margin, $
                         title=profile_labels[check_index]
                    ; xyouts,.48,0.98-((1./rows)*label_index),$
                    ; profile_labels[check_index],/normal,charsize=1.5
                    label_index = label_index + 1
                    for k=0,n_elements(rad_species)-1 do begin
                      oplot,radiance_data[i,j,k,*],altitude, $
                            thick=rad_thick[k], $
                            linestyle=rad_linestyle[k]
                    endfor
                  endif ; profile_inclusion check
                  check_index = check_index + 1
                endif ; existence of data check
              endfor  ; j=0,2 profiles
            endfor    ; time index
          endif else begin
            ;
            ;  Generate plot using OO graphics
            ;
            check_index = 0
            label_index = 0
; This still lacks a 'Radiance' title
            for i=0,n_elements(kp_data)-1 do begin
              for j=0,2 do begin
                if kp_data[i].periapse[j].time_start ne '' then begin
                  if profile_inclusion[check_index] eq 1 then begin
                    for k =0,n_elements(rad_species)-1 do begin
                      layout_vector = [columns,rows,$
                                       (i+j)*(rad_plot+den_plot)+1]
                      plot1 = plot( radiance_data[i,j,k,*], altitude, $
                                    thick=rad_thick[k], $
                                    title=profile_labels[check_index], $
                                    xlog=log_option, $
                                    font_size=12, rgb_table=40, $
                                    ;vert_colors=profile_colors[(j*3)+k], $
                                    ytitle='Altitude [km]', $
                                    layout=layout_vector, $
                                    overplot = keyword_set(k), $
                                    current = keyword_set(i+j+k) )
                      label_index = label_index + 1
                    endfor
                  endif ; profile_inclusion check
                  check_index = check_index + 1
                endif ; existence of data check
              endfor  ; j=0,2 profiles
            endfor    ; time index
          endelse     ; graphics type
        endif ; expand profiles only
        
        if keyword_set(profile_expand) and $
           keyword_set(species_expand) then begin         
          ;
          ; RADIANCE PLOTS THAT EXPAND BOTH SPECIES AND PROFILES
          ;
          if keyword_set(directgraphics) then begin
            for i=0,n_elements(rad_species)-1 do begin
              check_index = 0
              label_index = 0
              for j=0,n_elements(kp_data)-1 do begin
                for k=0,2 do begin
                  if kp_data[j].periapse[k].time_start ne '' then begin
                    if profile_inclusion[check_index] eq 1 then begin
                       plot,radiance_data[j,k,i,*],altitude,$
                            thick=rad_thick[i],$
                            xlog=log_option,charsize=1.5,yrange=[100,220],$
                            ytitle='Altitude, km',ymargin=y_label_margin,$
                            title=radiance_labels[i] + ':  '$
                                 +profile_labels[check_index]
                       label_index = label_index+1
                    endif
                 ;   xyouts,.48,0.94-((1./rows)*label_index),$
                 ;   profile_labels[check_index],/normal,charsize=1.5
                    check_index = check_index+1                
                  endif ; existence of data check
                endfor  ; k=0,2 profiles
              endfor    ; time index
            endfor      ; rad_species
          endif else begin
            ;
            ;  Generate plot using OO graphics
            ;
            for i=0,n_elements(rad_species)-1 do begin
              check_index = 0
              label_index = 0
              for j=0,n_elements(kp_data)-1 do begin
                for k=0,2 do begin
                  if kp_data[j].periapse[k].time_start ne '' then begin
                    if profile_inclusion[check_index] eq 1 then begin
                      layout_vector = [columns, rows, i+(j+k)*columns+1]
                      plot1 = plot( radiance_data[j,k,i,*], altitude, $
                                    thick=rad_thick[i], xlog=log_option, $
                                    title=radiance_labels[i]+': ' $
                                         +profile_labels[check_index], $
                                    font_size=12, rgb_table=40, $
                                    ;vert_colors=profile_colors[(j*3)+k], $
                                    ytitle='Altitude [km]', $
                                    layout=layout_vector, $
                                    overplot = 0, $ 
                                    current = keyword_set(i+j+k) )
                    endif
                    check_index = check_index+1
                  endif ; existence of data check
                endfor  ; k=0,2 profiles
              endfor    ; time index
            endfor      ; rad_species
          endelse
        endif ; expand all
skip_the_rest: wait,1e-6        
      endif ; end of plot_rad block
     
      if den_plot eq 1 then begin
        ;
        ;  Density plot(s) requested
        ;

         if (keyword_set(species_expand) eq 0) and $
            (keyword_set(profile_expand) eq 0) then begin
           ;DEFAULT PLOTTING OF ALL PERIAPSE SCANS, SPECIES,
           ;AND PROFILES ON ONE PLOT
           if keyword_set(directgraphics) then begin
             plot,density_data[0,0,0,*],altitude,thick=2,xlog=log_option,$
                  charsize=2,yrange=[100,200],$
                  ytitle='Altitude,km',/nodata,ymargin =y_label_margin
             check_index = 0
             for i=0,n_elements(kp_data)-1 do begin
               for j=0,2 do begin
                 if kp_data[i].periapse[j].time_start ne '' then begin
                   if profile_inclusion[check_index] eq 1 then begin
                     for k=0,n_elements(den_species)-1 do begin
                       oplot,density_data[i,j,k,*],altitude,thick=2,$
                             linestyle=den_linestyle[k],$
                             color=profile_colors[(i*3)+j]
                     endfor
                   endif
                   check_index = check_index+1
                 endif ; existence of data check
               endfor  ; loop over profiles
             endfor    ; loop over orbits
           endif else begin
             ;
             ; Produce the plot in OO grpahics
             ;
             check_index = 0
             ;
             ;  If both rad_plot and den_plot were requested, this will
             ;  place density plot in position 2; if no rad_plot was
             ;  requested, then density plot takes position 1.
             ;
             layout_vector = [columns,rows,rad_plot+den_plot]
             for i=0,n_elements(kp_data)-1 do begin
               for j=0,2 do begin
                 if kp_data[i].periapse[j].time_start ne '' then begin
                   if profile_inclusion[check_index] eq 1 then begin
                     for k=0,n_elements(den_species)-1 do begin
                       ;
                       ;  NB if rad_plot = 1 then window already open, 
                       ;  so plot this in current window; if rad_plot = 0
                       ;  then no window open, so draw first plot in a
                       ;  new window.
                       ;
                       plot1 = plot(density_data[i,j,k,*],altitude,thick=2,$
                                    linestyle=den_linestyle[k],$
                                    ytitle='Altitude[km]', xlog=log_option, $
                                    font_size=12, rgb_table=40, $
                                    layout=layout_vector, $
                                    vert_colors=profile_colors[(i*3)+j], $
                                    overplot=keyword_set(i+j+k), $
                                    current=keyword_set(rad_plot) )
                     endfor
                   endif
                   check_index = check_index+1
                 endif ; existence of data check
               endfor  ; loop over profiles
             endfor    ; loop over orbits
           endelse     ; graphics type
         endif ; do not expand on species nor profiles

         if keyword_set(species_expand) and $
           (keyword_set(profile_expand) eq 0) then begin
           ;
           ; DENSITY PLOT EXPANDING TO INVIDUALLY PLOT ALL SPECIES
           ;
           if keyword_set(directgraphics) then begin
             for i=0,n_elements(den_species)-1 do begin
               check_index = 0
               plot,density_data[0,0,i,*],altitude,title=density_labels[i],$
                 thick=2,xlog=log_option,charsize=1.5,yrange=[100,220],$
                 ytitle='Altitude, km',/nodata,ymargin=y_label_margin
               for j=0,n_elements(kp_data)-1 do begin
                 for k=0,2 do begin
                   if kp_data[j].periapse[k].time_start ne '' then begin
                     if profile_inclusion[check_index] eq 1 then begin
                       oplot,density_data[j,k,i,*],altitude,thick=2,$
                         color=profile_colors[(j*3)+k]
                     endif
                     check_index = check_index + 1
                   endif
                 endfor  ; loop profiles
               endfor    ; loop times
             endfor      ; loop den_species
           endif else begin
             ;
             ;  Generate plot using OO grpahics
             ;
             for i=0,n_elements(den_species)-1 do begin
               check_index = 0
               for j=0,n_elements(kp_data)-1 do begin
                 for k=0,2 do begin
                   if kp_data[j].periapse[k].time_start ne '' then begin
                     if profile_inclusion[check_index] eq 1 then begin
                       ;
                       ;  NB if rad_plot = 1 then window already open,
                       ;  so plot this in current window; if rad_plot = 0
                       ;  then no window open, so draw first plot in a
                       ;  new window.
                       ;
                       layout_vector = [columns,rows,radiance_dimensions+i+1]
                       plot1 = plot(density_data[j,k,i,*],altitude,$
                         thick=2, title=density_labels[i], $
                         linestyle=den_linestyle[k],$
                         ytitle='Altitude[km]', $
                         xlog=log_option, $
                         font_size=12, rgb_table=40, $
                         layout=layout_vector, $
                         margin=p_margin, $
                         vert_colors=profile_colors[(j*3)+k], $
                         overplot=keyword_set(j+k), $
                         current=keyword_set(rad_plot+i+j+k) )
                     endif
                     check_index = check_index + 1
                   endif ; data existence check
                 endfor  ; loop profiles
               endfor    ; loop times
             endfor      ; loop den_species
           endelse       ; graphics type
         endif           ; if only expand species
         
        if keyword_set(profile_expand) and $
           (keyword_set(species_expand) eq 0) then begin
          ;
          ; DENSITY PLOT EXPANDING TO INDIVIDUALLY PLOT EACH PROFILE
          ;
          if keyword_set(directgraphics) then begin
            check_index = 0
            label_index = 0
            for i=0,n_elements(kp_data)-1 do begin
              for j=0,2 do begin
                if kp_data[i].periapse[j].time_start ne '' then begin
                  if profile_inclusion[check_index] eq 1 then begin
                    plot,density_data[i,j,0,*],altitude,thick=2,$
                         xlog=log_option,charsize=1.5,yrange=[100,220],$
                         ytitle='Altitude, km',/nodata,ymargin=y_label_margin, $
                         title=profile_labels[check_index]
                    label_index = label_index + 1
                    for k=0,n_elements(den_species)-1 do begin
                      oplot,density_data[i,j,k,*],altitude,thick=2,$
                            linestyle=den_linestyle[k]
                    endfor
                  endif
               ;   xyouts,.48,0.9-((1./rows)*label_index),profile_labels[check_index],/normal,charsize=1.5
                  check_index = check_index + 1
                endif ; data verification check
              endfor  ; profiles loop
            endfor    ; time loop
          endif else begin
            ;
            ;  Generate plot using OO grpahics
            ;
            check_index = 0
            label_index = 0
            for i=0,n_elements(kp_data)-1 do begin
              for j=0,2 do begin
                if kp_data[i].periapse[j].time_start ne '' then begin
                  if profile_inclusion[check_index] eq 1 then begin
                    label_index = label_index + 1
                    for k=0,n_elements(den_species)-1 do begin
                       layout_vector = [columns,rows,(i+j+1)*(rad_plot+1)]
                       plot1 = plot(density_data[i,j,k,*],altitude,$
                         thick=2, title=profile_labels[check_index]+'Den', $
                         linestyle=den_linestyle[k],$
                         ytitle='Altitude[km]', xlog=log_option, $
                         font_size=12, rgb_table=40, $
                         layout=layout_vector, $
                         ;vert_colors=profile_colors[(j*3)+k], $
                         overplot=keyword_set(k), $
                         current=keyword_set(rad_plot+i+j+k) )
                    endfor
                  endif
                  check_index = check_index + 1
                endif ; data verification check
              endfor  ; profiles loop
            endfor    ; time loop
          endelse     ; grpahics type
        endif         ; expand profiles but not species
        
        
        if keyword_set(profile_expand) and $
           keyword_set(species_expand) then begin
          ;
          ; DENSITY PLOTS THAT EXPAND BOTH SPECIES AND PROFILES
          ;
          if keyword_set(directgraphics) then begin
            for i=0,n_elements(den_species)-1 do begin
              check_index = 0
              label_index = 0
              for j=0,n_elements(kp_data)-1 do begin
                for k=0,2 do begin
                  if kp_data[j].periapse[k].time_start ne '' then begin
                    if profile_inclusion[check_index] eq 1 then begin
                       plot,density_data[j,k,i,*],altitude,thick=2,$
                            xlog=log_option,charsize=1.5,yrange=[100,220],$
                            ytitle='Altitude, km',ymargin=y_label_margin,$
                            title= density_labels[i] +':  '$
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
          endif else begin
            ;
            ; Generate plot using OO graphics
            ;
            for i=0,n_elements(den_species)-1 do begin
              check_index = 0
              label_index = 0
              for j=0,n_elements(kp_data)-1 do begin
                for k=0,2 do begin
                  if kp_data[j].periapse[k].time_start ne '' then begin
                    if profile_inclusion[check_index] eq 1 then begin
                      layout_index = radiance_dimensions + i + 1 $
                                   + (j+k) * ( radiance_dimensions $
                                             + density_dimensions )
                      layout_vector = [columns,rows,layout_index]
                      plot1 = plot(density_data[j,k,i,*],altitude,$
                                   thick=2,xlog=log_option,$
                                   font_size=12, ytitle='Altitude, km',$
                                   title= density_labels[i] +':  '$
                                        + profile_labels[check_index], $
                                   layout=layout_vector, $
                                   overplot=0, $
                                   current=keyword_set(rad_plot))
                      label_index = label_index+1
                    endif
                    ; xyouts,.48,0.94-((1./rows)*label_index),$
                    ; profile_labels[check_index],/normal,charsize=1.5
                    check_index = check_index+1
                  endif ; data existence check
                endfor  ; profile loop
              endfor    ; time loop
            endfor      ; den_species loop
          endelse       ; graphics options
        endif           ; expand all

      endif  ; end of den_plot block


      ;IF BOTH RADIANCE AND DENSITY ARE BEING PLOTTED,
      ;DRAW A VERTICAL LINE TO SEPARATE THE TWO SIDES OF THE PLOT

      ;MID-PLOT LINE IF BOTH RADIANCE AND DENSITY IS INCLUDED
      if keyword_set(species_expand) then begin
        line_marker = float(n_elements(rad_species))$
          / float((n_elements(rad_species)$
          +n_elements(den_species)))
        if rad_plot eq 1 and den_plot eq 1 then begin
          if keyword_set(directgraphics) then begin
            plots,[line_marker,line_marker],[0.,1.],/normal,$
              thick=3,linestyle=1
          endif else begin
            line1 = polyline( [line_marker,line_marker], [0,1], $
              /normal, thick=3, linestyle=1, $
              target=plot1 )
          endelse
        endif
      endif

    ;ADD OVERALL LABELS 
    
      rad_label = 0.2
      den_label = 0.7
    
    if keyword_set(species_expand) then begin
      if rad_plot eq 1 then begin
        rad_label = 0.45
      endif
      if den_plot eq 1 then begin
        den_label = 0.48
      endif
      if rad_plot eq 1 and den_plot eq 1 then begin
        rad_label = ( float(n_elements(rad_species))$
                    / float(( n_elements(rad_species)$
                            + n_elements(den_species) )) )$
                  / 2.
        den_label = (float(n_elements(rad_species))$
                    /float((n_elements(rad_species)$
                           +n_elements(den_species))))*1.25
      endif
    endif

    if keyword_set(directgraphics) then begin
      if (rad_plot eq 1) then $
        xyouts, rad_label,.965,'Radiance',/normal,charsize=3
      if (den_plot eq 1) then $
        xyouts, den_label,.965,'Density',/normal,charsize=3
    endif else begin
      if keyword_set(rad_plot) then $
        text1 = text( 0.1, 0.965, 'Radiance', /normal, target = plot1 )
      if keyword_set(den_plot) then $
        text1 = text( line_marker+0.1, 0.965, 'Density', $
                      /normal, target = plot1 )
    endelse
   
   ;START A SECOND WINDOW FOR THE PLOT LEGENDS
   if keyword_set(nolegend) eq 0  then begin
    if den_plot eq 1 and rad_plot eq 1 then begin
      legend_xsize=600
      den_lab = 0.1
      rad_lab = 0.4
    endif
    if den_plot eq 1 and rad_plot eq 0 then begin
      legend_xsize=400
      den_lab = 0.1
    endif
    if rad_plot eq 1 and den_plot eq 0 then begin
      legend_xsize=400
      rad_lab = 0.1
    endif

;-km Need to make a lengend for OO graphics here

    window,plot_window+1, xsize=legend_xsize,ysize=400,title='Limb Plot Legend'
    device, decompose=0
    plot,[0,0],[1,1], color=255, background=255, /nodata
  
    if den_plot eq 1 then $
      xyouts, den_lab,0.9,'Density',charsize=2,charthick=2,/normal
    if rad_plot eq 1 then $
      xyouts, rad_lab, 0.9,'Radiance',charsize=2,charthick=2,/normal
    xyouts, 0.75,0.9,'Profiles',charsize=2,charthick=2,/normal
  
   ;species labels
    
    if den_plot eq 1 then begin
      for i=0,n_elements(den_species) - 1 do begin
        plots,[(den_lab-0.02),(den_lab+0.08)],[.8-(0.08 * i),.8-(0.08*i)],$
              linestyle=den_linestyle[i],thick=2,/normal
        xyouts,(den_lab+0.1),[0.79-(0.08*i)],density_labels[i],charsize=1.5,$
               charthick=1.5,/normal
      endfor
    endif
   
    if rad_plot eq 1 then begin
      for i=0,n_elements(rad_species) -1 do begin
        plots,[(rad_lab-0.02),(rad_lab+0.08)],[.8-(0.08 * i),.8-(0.08*i)],$
              linestyle=rad_linestyle[i],thick=rad_thick[i],/normal
        xyouts,(rad_lab+0.1),[0.79-(0.08*i)],radiance_labels[i],$
               charsize=1.5,charthick=1.5,/normal        
      endfor
    endif
   
   
goto, skip_this_too
   ;orbit labels
   
   check_index = 0
   label_index = 0
   for i=0,n_elements(kp_data.orbit) -1 do begin
    for j=0,2 do begin
      if kp_data[i].periapse[j].time_start ne '' then begin
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
skip_this_too: wait,1e-6
   endif
   skip_the_old: wait,1e-6

;
;  Pass the plot object out, if requested
;
if( arg_present(oo) and ~keyword_set(directgraphics) )then oo=plot1
;if( arg_present(oo) and arg_present(leg) and $
;    ~keyword_set(directgraphics) )then leg=leg1

end
