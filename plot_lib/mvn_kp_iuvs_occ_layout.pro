;+
; :Name:
;  mvn_kp_iuvs_occ_layout
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
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author:
;  McGouldrick (2015-Jun-06)
;
;-
pro mvn_kp_iuvs_occ_layout, species_dim=species_dim, $
  profile_dim=profile_dim, $
  species_expand=species_expand, $
  profile_expand=profile_expand, $
  layout_vector=layout_vector, $
  oplot_vector=oplot_vector, $
  hide_vector=hide_vector
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
    oplot_vector=indgen(tot_dim)-1
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
      layout_vector[i] = iprof*2 + 1
      oplot_vector[i] = i - profile_dim
      if ispec eq 0 then oplot_vector[i] = -1
    endfor
  endif

  if species_expand and profile_expand then begin
    ;
    ; Expand everything onto its own set of axes (easiest)
    ;
    layout_vector = indgen(tot_dim)+1
    oplot_vector = intarr(tot_dim)-1
  endif

  ;
  ; determine which legend items to hide
  ; (AND, ToDO, the titles of the plots
  ;
  ; Default is to expand nothing, and then print ALL legend info
  ;
  hide_vector = bytarr(tot_dim)
  index = indgen(tot_dim)
  ;
  ;  If expanding species, do not include species in legend
  ;
  if keyword_set(profile_expand) and $
    ~keyword_set(species_expand) then begin
    show = where( ( index mod profile_dim ) eq 0, nshow, $
      complement = hide, ncomplement = nhide )
    if nhide gt 0 then hide_vector[hide] = 1
  endif
  ;
  ;  If expanding profiles, do not include profiles in legend
  ;
  if ~keyword_set(profile_expand) and $
    keyword_set(species_expand) then begin
    show = where( index lt profile_dim, nshow, $
      complement = hide, ncomplement = nhide )
    if nhide gt 0 then hide_vector[hide] = 1
  endif
  ;
  ; If expanding both species and profile, hide all
  ;
  if keyword_set(species_expand) and $
    keyword_set(profile_expand) then begin
    hide_vector = replicate(1B,tot_dim)
  endif
  ;
  ;  NB, now we need to place titles on plots
  ;

end

