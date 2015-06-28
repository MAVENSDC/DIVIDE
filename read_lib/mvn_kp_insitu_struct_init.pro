pro mvn_kp_insitu_struct_init, filename, output, col_map, formats, $
                               nparam, nrec, instruments=instruments
;+
; :Name:
;  mvn_kp_read_insitu_ascii_header
;  (will replace mvn_kp_insitu_struct_init)
;  
; :Description:
;  This code will read the header of an insitu KP ASCII file in order
;  to determine the shape that the data strcture ought to take.
;  
; :Version:
;  2.0
;  
; :History:
;  v1.0 (FIll in info for old mvn_kp_insitu_struct_init here)
;
; :Params:
;  filename: in, string, required
;   - the name of the ASCII file to be read
;   
;  output: out, type=struct
;   - the variable to contain the output structure.  First, just the 
;     template, later, the actual data structure for input data record.
;
;  col_map: in, required, structure
;   - map of instrument and observation names to column numbers
;
;  nrec: in, integer, required
;   - number of records in data file
;
; :Keywords:
;  instruments: in, optional , structure
;   list of the instrument modes to be read and stored in a structure
;   Default is to read all.
;
; :Author:
;  McGouldrick
;
;-
Version = 2 ; HACK until I read it in from the data file
  ;
  ;  Default to filling all instruments if not specified
  ;
  if not keyword_set(instruments) then begin
    instruments = {lpw:1, euv:1, static:1, swia:1, swea:1, mag:1, sep:1, $
                   ngims:1, periapse:1, c_e_disk:1, c_e_limb:1, c_e_high:1, $
                   c_l_disk:1, c_l_limb:1, c_l_high:1, $
                   apoapse:1, stellarocc:1}
  endif  
  lpw_names = [] & euv_names = [] & static_names = [] & swia_names = []
  swea_names = [] & mag_names = [] & sep_names = [] & ngims_names = []
  app_names = [] & sc_names = []
  lpw_vals = [] & euv_vals = [] & static_vals = [] & swia_vals = []
  swea_vals = [] & mag_vals = [] & sep_vals = [] & ngims_vals = []
  app_vals = [] & sc_vals = []
  ;
  ; Open the given filename
  ;
  openr,luni,filename,/get_lun
  line = '' & iline=0 ; initialize read string and line number
  ;
  ;  Read through the Info part of the header, looking for the lines that 
  ;  tell us how many columns and records are in this file, and on which
  ;  line the data begin.  Written in this manner, it does not assume the
  ;  order in which they will appear.  But it does assume the manner in 
  ;  which the information is signaled.
  ;
  repeat begin
    readf, luni, line & iline++
    ;
    ;  Get the number of parmaeter columns
    ;  NB, this assumes no more than 999 columns and no fewer than 100
    ;
    if strmatch(line,'*Number of parameter columns*') then $
      nparam = fix( strmid( line, $
                            stregex( line,'[0123456789]{3}',length=len ), $
                            len), $
                    type=2)
    ;
    ;  Get the line numnber of the start of data
    ;  NB, this assumes no more than 999 header lines and no fewer than 100
    ;
    if strmatch(line,'*Line on which data begins*') then $
      nstart = fix( strmid( line, $
      stregex( line,'[0123456789]{3}',length=len ), $
      len), $
      type=2)
    ;
    ;  Get the number of data records.  This should be allowed to vary over
    ;  four orders of magnitude.  Can we assume it is always ~10,000?
    ;  For now, assume at least 10000 lines and fewer than 99999.
    ;
    if strmatch(line,'*Number of lines*') then $
      nrec = fix( strmid( line, $
      stregex( line,'[0123456789]{5}',length=len ), $
      len), $
      type=2)
    ;
    ;  Read any other lines blindly, just counting them
    ;
  endrep until strmatch(line,'*PARAMETER*INSTRUMENT*UNITS*COLUMN*FORMAT*')
  ;
  ; Read the next blank header line (dangerous: may change)
  ;
  readf,luni,line & iline++
  ;
  ;  Read the time info line.  It is PDS defined and will never change
  ;
  readf, luni, line & iline++
  formats = ['yyyy-mm-ddThh:mm:ss']
  ;
  ;  Next <nparam> lines detail the structure of the data table
  ;
;  for iparam = 1,5 do begin
  for iparam = 1, nparam-1 do begin
    readf, luni, line & iline++
;
;  NEXT FEW LINES HSOULD PROBABLY BE SET INTO SEPARATE ROUTINE AS THEY
;  WILL BE REPEATED ENDLESSLY
;
    ;
    ;  After character 2 ('# '), break the line at all double-sapces
    ;
    temp = strsplit(strmid(line,2),'  ',/regex,/extract)
    name = strtrim(temp[0],2)    ; parameter name
    inst = strtrim(temp[1],2)    ; instrument name/ID
    units = strtrim(temp[2],2)   ; units (not saved)
    column = fix(temp[3],type=2) ; column number (not saved?)
    format_string = strtrim(temp[4],2) ; data format descriptor (e.g. E16.2)
    formats = [formats, format_string]
    notes = temp[5] ; add'l notes on param, needed to break degeneracy on 
                    ; some of the error parameters
    ;
    ;  Now for the conditionals
    ;  EUV is listed as LPW-EUV, change that
    ;
    if inst eq 'LPW-EUV' then inst = 'EUV'
    ;
    ;  SPACECRAFT is lsited as SPICE, change it
    ;  But make it APP if defining articulating platform
    ;
    if inst eq 'SPICE' then $
      inst = strmatch( name, '*APP*' ) ? 'APP' : 'SPACECRAFT'
    ;
    ;  LPW has max/min quality/error flags for some params
    ;
    if inst eq 'LPW' and name eq 'Quality' then begin
      if strmatch(notes,'*minimum*',/fold_case) then $
        name = strupcase(strjoin([name,'min'],'_'))
      if strmatch(notes,'*maximum*',/fold_case) then $
        name = strupcase(strjoin([name,'max'],'_'))
    endif
    ;
    ;  NGIMS has quality flags and precision estimates
    ;
    if inst eq 'NGIMS' and name eq 'Quality' and Version ge 2 then $
      ; Need to read in version number at top
      format = 'a16'
    ;
    ;  Now, assemble the names of the structure variables
    ;  First, connect words with underscores
    ;  ***Convert this into case statement syntax
    ;
    if inst eq 'LPW' then begin
      if strmatch( name, '*(2 - 100 Hz)*') then name = 'ewave_low_freq'
      if strmatch( name, '*(100 - 800 Hz)*') then name = 'ewave_mid_freq'
      if strmatch( name, '*(800 - 1000 Hz)*') then name = 'ewave_high_freq'
      name = idl_validname(name,/convert_all)
    endif
    
    if inst eq 'EUV' then begin
      if strmatch( name, '*(0.1 - 7.0 nm)*') then name = 'irradiance_low'
      if strmatch( name, '*(17 - 22 nm)*') then name = 'irradiance_mid'
      if strmatch( name, '*(Lyman-alpha)*') then name = 'irradiance_lyman'
      name = idl_validname( name, /convert_all )
    endif

    if inst eq 'SWEA' then begin
      if ~strmatch( name, '*flux*' ) then begin
        name = idl_validname(name,/convert_all)
      endif else begin
        name = strjoin(strsplit(name,'-',/extract),'_')
        str_end_index = strpos(name,'(')
        if strmatch( name, '*(5*100 eV)*') then $
          name = idl_validname(strmid(name,0,str_end_index)+'low',$
                               /convert_all)
        if strmatch( name, '*(100*500 eV)*') then $
          name = idl_validname(strmid(name,0,str_end_index)+'mid',$
                               /convert_all)
        if strmatch( name, '*(500*1000 eV)*') then $
          name = idl_validname(strmid(name,0,str_end_index)+'high',$
                               /convert_all)
        if strmatch( name, '*(5*100 eV)*') then $
          name = idl_validname(strmid(name,0,str_end_index)+'low',$
                               /convert_all)
        if strmatch( name, '*(100*500 eV)*') then $
          name = idl_validname(strmid(name,0,str_end_index)+'mid',$
                               /convert_all)
        if strmatch( name, '*(500*1000 eV)*') then $
          name = idl_validname(strmid(name,0,str_end_index)+'high',$
                               /convert_all)
      endelse
    endif

    if inst eq 'SWIA' then $
      name = idl_validname( strjoin( strsplit(name,'+',/extract),'plus' ), $
                            /convert_all )

    if inst eq 'STATIC' then begin
      name = strjoin( strsplit( name, '+', /extract ), 'plus' )
      name = strjoin( strsplit( name, '-', /extract ), '_' )
      name = idl_validname( name, /convert_all )
    endif

    if inst eq 'SEP' then begin
      if strmatch( name, '*Flux*' ) then begin
        strpos1 = strpos( name, '(' )
        strpos2 = strpos( name, ')' )
        if strmatch( name, '*(30-1000 keV)*' ) then begin
          name = strmid(name,0,strpos1-1)+strmid(name,strpos2+1)
        endif
        if strmatch( name, '*(30 keV - 300 keV)*' ) then begin
          name = strmid(name,0,strpos1-1)+strmid(name,strpos2+1)
        endif
      endif
      name = idl_validname(strjoin(strsplit(name,'-',/extract),'_'), $
                           /convert_all)
    endif
    
    if inst eq 'MAG' then $
      if strmatch( name, 'Magnetic Field*' )then $
         name = idl_validname( strmid(name,15), /convert_all )

    if inst eq 'NGIMS' then begin
      if strmatch( name, '*Ion*' ) then begin
        if strmatch( name, '*32+*' ) then name = 'o2plus_density'
        if strmatch( name, '*44+*' ) then name = 'co2plus_density'
        if strmatch( name, '*30+*' ) then name = 'noplus_density'
        if strmatch( name, '*16+*' ) then name = 'oplus_density'
        if strmatch( name, '*28+*' ) then name = 'co2plus_n2plus_density'
        if strmatch( name, '*12+*' ) then name = 'cplus_density'
        if strmatch( name, '*17+*' ) then name = 'ohplus_density'
        if strmatch( name, '*14+*' ) then name = 'nplus_density'
      endif else begin
        name = idl_validname(name,/convert_all)
      endelse
    endif

    if inst eq 'APP' then begin
      if strmatch( name, 'APP*' )then $
        name = idl_validname( strmid(name, 4), /convert_all )
    endif

    if inst eq 'SPACECRAFT' then begin
      ;
      ; S/C tricky only because we only grab *some* of the parameters
      ; And, some of these go to the head rather than spacecraft-sub
      ; Make default: inclusion in sc-sub; non-inclusion in head
      ;
      sc_include = keyword_set(1B) & head_include = keyword_set(0B)
      ;
      ; First, strip 'spacecraft' from head of many params
      ;
      if strmatch( name, 'spacecraft*', /fold_case ) then $
        name = strmid( name, 11 )
      ;
      ; Other conditionals 
      ;
      if strmatch( name, '*solar zenith angle*', /fold_case ) then $
         name = 'sza'
      if strmatch( name, '*altitude*aeroid*', /fold_case ) then $
         name = 'altitude'
      if strmatch( name, 'Mars season*', /fold_case ) then $
         name = 'Mars_season'
      if strmatch( name, 'Sub-Mars*Sun*', /fold_case) then $
         name = 'submars_point_solar_'+strmid(name,27)
      if strmatch( name, '*Rotation*SPACECRAFT*', /fold_case ) then $
         name = 't'+strmid(name,50,1)+strmid(name,52,1)
      if strmatch( name, '*Rotation*IAU*', /fold_case ) then $
         sc_include = keyword_set(0B)
      if strmatch( name, '*Orbit Number*', /fold_case ) or $
         strmatch( name, '*Inbound/Outbound*', /fold_case ) then begin
         sc_include = keyword_set(0B) & head_include = keyword_set(1B)
      endif
      ;
      ;  Construct subnames
      ;
      name = idl_validname( strjoin( strsplit( name, '-', /extract), '_' ), $
                            /convert_all )
    endif
    ;
    ;  Now, append the quality or precision flags
    ;
    case inst of
      'LPW' : begin
              if ~strmatch( name, '*quality*', /fold_case ) then $
                     obs_name = name
              if strmatch( name, '*quality*', /fold_case ) then begin
                if strmatch( name, '*m[(in)(ax)]*', /fold_case )then begin
                  if strmatch( name, '*min*', /fold_case ) then $
                     name = obs_name + '_qual_min'
                  if strmatch( name, '*max*', /fold_case ) then $
                     name = obs_name + '_qual_max'
                endif else begin
                     name = obs_name + '_qual'
                endelse
              endif
              end
      'NGIMS' : begin
                if ~strmatch( name, 'quality', /fold_case ) and $
                   ~strmatch( name, 'precision', /fold_case )then  $
                      obs_name = name
                if strmatch( name, 'quality', /fold_case ) then $
                      name = obs_name + '_qual'
                if strmatch( name, 'precision', /fold_case ) then $
                      name = obs_name + '_precision'
                end
      else: begin
            if ~strmatch( name, 'quality', /fold_case ) then $
                   obs_name = name
            if strmatch( name, 'quality', /fold_case ) then $
                   name = obs_name + '_qual'
            end
    endcase
    ;
    ; Now, create the arrays of names and initial values for building the 
    ;   inital data structure
    ;
    case inst of
      'LPW' : begin
;              if instruments.lpw then begin
                lpw_names = [lpw_names, name]
                if n_elements(lpw_names) eq 1 then begin
                  lpw = strmatch( format_string, '*A*' ) $
                      ? create_struct( name, '' ) $
                      : create_struct( name, !VALUES.D_NAN )
                  lpw_col = create_struct( name, column )
                endif else begin
                  lpw = strmatch( format_string, '*A*' ) $
                      ? create_struct( lpw, name, '' ) $
                      : create_struct( lpw, name, !VALUES.D_NAN )
                  lpw_col = create_struct( lpw_col, name, column )
                endelse
;              endif
              end
      'EUV' : begin
              euv_names = [euv_names, name]
              if n_elements(euv_names) eq 1 then begin
                euv = strmatch( format_string, '*A*' ) $
                    ? create_struct( name, '' ) $
                    : create_struct( name, !VALUES.D_NAN )
                euv_col = create_struct( name, column )
              endif else begin
                euv = strmatch( format_string, '*A*' ) $
                    ? create_struct( euv, name, '' ) $
                    : create_struct( euv, name, !VALUES.D_NAN )
                euv_col = create_struct( euv_col, name, column )
              endelse
              end
      'SWEA' : begin
               swea_names = [swea_names, name]
               if n_elements(swea_names) eq 1 then begin
                 swea = strmatch( format_string, '*A*' ) $
                      ? create_struct( name, '' ) $
                      : create_struct( name, !VALUES.D_NAN )
                 swea_col = create_struct( name, column )
               endif else begin
                 swea = strmatch( format_string, '*A*' ) $
                      ? create_struct( swea, name, '' ) $
                      : create_struct( swea, name, !VALUES.D_NAN )
                swea_col = create_struct( swea_col, name, column )
               endelse
               end
      'SWIA' : begin
               swia_names = [swia_names, name]
               if n_elements(swia_names) eq 1 then begin
                 swia = strmatch( format_string, '*A*' ) $
                     ? create_struct( name, '' ) $
                     : create_struct( name, !VALUES.D_NAN )
                 swia_col = create_struct( name, column )
               endif else begin
                 swia = strmatch( format_string, '*A*' ) $
                     ? create_struct( swia, name, '' ) $
                     : create_struct( swia, name, !VALUES.D_NAN )
                 swia_col = create_struct( swia_col, name, column )
               endelse
               end
      'STATIC' : begin
                 static_names = [static_names, name]
                 if n_elements(static_names) eq 1 then begin
                   static = strmatch( format_string, '*A*' ) $
                       ? create_struct( name, '' ) $
                       : create_struct( name, !VALUES.D_NAN )
                   static_col = create_struct( name, column )
                 endif else begin
                   static = strmatch( format_string, '*A*' ) $
                       ? create_struct( static, name, '' ) $
                       : create_struct( static, name, !VALUES.D_NAN )
                   static_col = create_struct( static_col, name, column )
                 endelse
                 end
      'SEP' : begin
              sep_names = [sep_names, name]
              if n_elements(sep_names) eq 1 then begin
                sep = strmatch( format_string, '*A*' ) $
                    ? create_struct( name, '' ) $
                    : create_struct( name, !VALUES.D_NAN )
                sep_col = create_struct( name, column )
              endif else begin
                sep = strmatch( format_string, '*A*' ) $
                    ? create_struct( sep, name, '' ) $
                    : create_struct( sep, name, !VALUES.D_NAN )
                sep_col = create_struct( sep_col, name, column )
              endelse
              end
      'MAG' : begin
              mag_names = [mag_names, name]
               if n_elements(mag_names) eq 1 then begin
                 mag = strmatch( format_string, '*A*' ) $
                     ? create_struct( name, '' ) $
                     : create_struct( name, !VALUES.D_NAN )
                 mag_col = create_struct( name, column )
               endif else begin
                 mag = strmatch( format_string, '*A*' ) $
                     ? create_struct( mag, name, '' ) $
                     : create_struct( mag, name, !VALUES.D_NAN )
                 mag_col = create_struct( mag_col, name, column )
               endelse
               end
      'NGIMS' : begin
                ngims_names = [ngims_names, name]
                if n_elements(ngims_names) eq 1 then begin
                  ngims = strmatch( format_string, '*A*' ) $
                      ? create_struct( name, '' ) $
                      : create_struct( name, !VALUES.D_NAN )
                  ngims_col = create_struct( name, column )
                endif else begin
                  ngims = strmatch( format_string, '*A*' ) $
                      ? create_struct( ngims, name, '' ) $
                      : create_struct( ngims, name, !VALUES.D_NAN )
                  ngims_col = create_struct( ngims_col, name, column )
                endelse
                end
      'APP' : begin
              app_names = [app_names, name]
              if n_elements(app_names) eq 1 then begin
                app = strmatch( format_string, '*A*' ) $
                    ? create_struct( name, '' ) $
                    : create_struct( name, !VALUES.D_NAN )
                app_col = create_struct( name, column )
              endif else begin
                app = strmatch( format_string, '*A*' ) $
                    ? create_struct( app, name, '' ) $
                    : create_struct( app, name, !VALUES.D_NAN )
                app_col = create_struct( app_col, name, column )
              endelse
              end
      'SPACECRAFT':$
            begin
              sc_names = [sc_names, name]
              if sc_include then begin
                if n_elements(sc_names) eq 1 then begin
                  sc = strmatch( format_string, '*A*' ) $
                     ? create_struct( name, '' ) $
                     : create_struct( name, !VALUES.D_NAN )
                  sc_col = create_struct( name, column )
                endif else begin
                  sc = strmatch( format_string, '*A*' ) $
                     ? create_struct( sc, name, '' ) $
                     : create_struct( sc, name, !VALUES.D_NAN )
                  sc_col = create_struct( sc_col, name, column )
                endelse
              endif
            end
    endcase
    ;
    ; Get column numbers for orbit number and I/O Bound flag
    ;
    if strmatch( name, '*Orbit_Number*', /fold_case ) then $
       orbit_col = column
    if strmatch( name, '*Inbound_Outbound*', /fold_case ) then $
      ioflag_col = column

  endfor ; cycle through all iparams
  ;
  ;  All substrcutes have been built; now choose which ones to put 
  ;  into the main output structure requested
  ;
  ;  First, the head of the structure required elemenets
  ;
  output = create_struct( ['time_string','time','orbit','io_bound'], $
                          '', !VALUES.D_NAN, -1, '' )
  col_map = create_struct( ['time_string','orbit','io_bound'], $
                           1, orbit_col, ioflag_col )
  ;
  ;  Next, the instruments
  ;
  if instruments.lpw then output = create_struct( output, 'lpw', lpw )
  if instruments.lpw then col_map = create_struct( col_map, 'lpw', lpw_col )
  if instruments.euv then output = create_struct( output, 'euv', euv )
  if instruments.euv then col_map = create_struct( col_map, 'euv', euv_col )
  if instruments.swia then output = create_struct( output, 'swia', swia )
  if instruments.swia then col_map = create_struct( col_map, 'swia', swia_col )
  if instruments.swea then output = create_struct( output, 'swea', swea )
  if instruments.swea then col_map = create_struct( col_map, 'swea', swea_col )
  if instruments.static then output = create_struct( output, 'static', static )
  if instruments.static then col_map = create_struct( col_map, 'static', static_col )
  if instruments.sep then output = create_struct( output, 'sep', sep )
  if instruments.sep then col_map = create_struct( col_map, 'sep', sep_col )
  if instruments.mag then output = create_struct( output, 'mag', mag )
  if instruments.mag then col_map = create_struct( col_map, 'mag', mag_col )
  if instruments.ngims then output = create_struct( output, 'ngims', ngims )
  if instruments.ngims then col_map = create_struct( col_map, 'ngims', ngims_col )
  ;
  ;  Finally  the required APP and SPACECRAFT sub-structures
  ;
  output = create_struct( output, 'app', app )
  col_map = create_struct( col_map, 'app', app_col )
  output = create_struct( output, 'spacecraft', sc )
  col_map = create_struct( col_map, 'spacecraft', sc_col )
  free_lun,luni
end
