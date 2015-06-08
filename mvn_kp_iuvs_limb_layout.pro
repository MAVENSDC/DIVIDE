;+
; :Name:
;  mvn_kp_iuvs_limb_layout
;  
; :Description:
;  Generate vectors that will dictate to plot() how the various 
;  plots created by mvn_kp_iuvs_limb are to be arranged.
;  
; :Params:
;  species_dim: in, required, integer
;   Number of distinct species to be plotted
;  profile_dim: in, required, integer
;   Number of distinct profiles to be plotted.
;  radiance_dim: in, required, integer
;   Number of distinct radiance species to be plotted.
;  layout_vector: out, required, integer array
;   index of the species,profile plot.  Only considered by plot()
;   if overplot is equal to zero.
;  oplot_vector: out, required, integer array
;   array to indicate whether current species,profile plot is to be
;   drawn on a new set of axes.  If "-1", then the plotting code, 
;   mvn_kp_iuvs_limb, will call plot() with overplot=0; if any other
;   integer, plot() wil be called with overplot=plot[oplot_vector[i]].
;
; :Keywords:
;  species_expand: in, required, boolean
;   Flag to determine whether to place each species on separate plot
;  profile_expand: in,required, boolean
;   Flag to determine whether to place each profile on separate plot.
;
; :Author:
;  McGouldrick (2015-Jun-06)
;
;-
pro mvn_kp_iuvs_limb_layout, species_dim=species_dim, $
                             profile_dim=profile_dim, $
                             radiance_dim=radiance_dim, $
                             species_expand=species_expand, $
                             profile_expand=profile_expand, $
                             layout_vector=layout_vector, $
                             oplot_vector=oplot_vector
  ;
  ; Create the boolean keywords and total dimensions value
  ;
  species_expand = keyword_set(species_expand)
  profile_expand = keyword_set(profile_expand)
  tot_dim = species_dim * profile_dim
  ;
  ; Cycle through the four possibilities
  ;
  if ~species_expand and ~profile_expand then begin
    ;
    ; No expansion all species and profiles on single rad/den plots
    ;
    layout_vector = intarr(tot_dim)
    layout_vector[0] = 1 ; radiance plot is in first location (not req'd)
    layout_vector[profile_dim*radiance_dim] = 2 ; density plot is 2nd
    oplot_vector=indgen(tot_dim)-1
    oplot_vector[profile_dim*radiance_dim] = -1 ; 1st den plot not overplot
  endif

  if species_expand and ~profile_expand then begin
    ;
    ; Expand species onto separate plots
    ;
    index = indgen(tot_dim)
    layout_vector = (index / profile_dim) + 1 ; integer division
    oplot_vector = indgen(tot_dim)-1
    oplot_vector[where(index mod profile_dim eq 0)] = -1
  endif

  if ~species_expand and profile_expand then begin
    ;
    ; Expand profiles onto separate plots, if den and rad both are
    ;  requested, they go on separate plots, too
    ;
    index = indgen(tot_dim)
    layout_vector = intarr(tot_dim)
    oplot_vector = intarr(tot_dim)
    for i = 0,tot_dim-1 do begin
      iprof = (array_indices(intarr(profile_dim,species_dim),i))[0]
      ispec = (array_indices(intarr(profile_dim,species_dim),i))[1]
      if ispec ge radiance_dim and species_dim gt radiance_dim then begin
        layout_vector[i] = iprof*2 + 2
      endif else begin
        layout_vector[i] = iprof*2 + 1
      endelse
      oplot_vector[i] = i - profile_dim
      if ispec eq 0 or ispec eq radiance_dim then oplot_vector[i] = -1
    endfor
;    if species_dim gt radiance_dim then begin
;      ;
;      ;  Then we have density plots and a second column to consider
;      ;
;      layout_vector[where(index ge radiance_dim)] $
;        = (index[where(index ge radiance_dim)] / profile_dim) + 2
;    endif 
;    ;
;    ; Because this one is cimplicated, I will do it long hand
;    ;
;    oplot_vector = intarr(tot_dim)
;    for i = 1,tot_dim-1 do begin
;      oplot_vector[i] = index[i] $
;                      - profile_dim * ( ( index[i] mod profile_dim ) + 1 )
;    endfor
;    oplot_vector[0] = -1 ; 1st is always a new plot
;    ;  And the 1st density plot if radiance plots also exist is new plot:
;    if species_dim gt radiance_dim then oplot_vector[radiance_dim] = -1
  endif

  if species_expand and profile_expand then begin
    ;
    ; Expand everything onto its own set of axes (easiest)
    ;
    layout_vector = indgen(tot_dim)+1
    oplot_vector = intarr(tot_dim)-1
  endif
end

