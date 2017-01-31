;+
;
; :Name:
;  mvn_kp_read_mgitm_ascii_header
;
; :Description:
;  Reads the header of MGITM ASCII data file.  Stores metadata and
;  dimensions in appropriate structures.  Also returns the header
;
; :Author:
;  McGouldrick (2015-May-22)
;
; :Version:
;  1.0
;
; :Params:
;  filename: in,string, required
;   - the name of the file to be read
;
; :Keywords:
;  meta: structure
;   - the structure containing all of the metadata
;  dims: structure
;   - the structure containing the dimensional information
;
; :Returns:
;  header: out, array, string
;   - the full text of the header
;
;-
function mvn_kp_read_mgitm_ascii_header, filename, meta=meta, dims=dims, data=data
;
; Temp hack: fill meta vars with dummies
;
LS = !VALUES.F_NAN
longsubsol = !VALUES.F_NAN
dec = !values.f_nan
mars_radius = !values.f_nan
coord_sys = 'UNK'
altitude_from = 'UNK'
  ;
  ; Open the file
  ;
  openr,luni,filename,/get_lun
  ;
  ; Determine the number of header lines
  ;
  line = 'junk'
  nlines = 0
  repeat begin
    readf,luni,line
    nlines++
  endrep until ~strmatch(line,'#*')
  nlines-- ; last line read is first of the data
  close,luni & free_lun,luni ; close and free the file
  ;
  ; Now, go and collect the header
  ;
  header = strarr(nlines)
  openr,luni,filename,/get_lun
  for i = 0,nlines-1 do begin
    readf,luni,line
    header[i] = line
  endfor
  close,luni & free_lun,luni ; close and free the file
  ;
  ;  Now, parse the header for the needed information
  ;
  for iline = 0,nlines-1 do begin
    line = header[iline] ; to shorten later lines of code
    ;
    ;  SHould ask for a label/indicator for the date
    ;
    if strmatch( line, '*MGITM Results*' ) then begin
      date = (strsplit(line,' ', /extract))[4]
      time = (strsplit(line,' ', /extract))[6]
      year = fix( (strsplit( date,'-', /extract ))[0] )
      month = fix( (strsplit( date,'-', /extract ))[1] )
      day = fix( (strsplit( date,'-', /extract ))[2] )
      hour = fix( (strsplit( time,':', /extract ))[0] )
      minute = fix( (strsplit( time,':', /extract ))[1] )
      second = fix( (strsplit( time,':', /extract ))[2] )
      ;
      ;  Add date/time to meta?
      ;
    endif
    if strmatch( line, '*longitude points*' ) then begin
      nlons = fix((strsplit( line,':', /extract ))[1])
      lon = fltarr(nlons)
    endif
    if strmatch( line, '*latitude points*' ) then begin
      nlats = fix((strsplit( line,':', /extract ))[1])
      lat = fltarr(nlats)
    endif
    if strmatch( line, '*altitude points*' ) then begin
      nalts = fix((strsplit( line,':', /extract ))[1])
      alt = fltarr(nalts)
    endif
    if strmatch( line, '*LS*' ) then $
      LS = fix((strsplit( line,':', /extract ))[1])
    if strmatch( line, '*coord_sys*' ) then $
      coord_sys = (strsplit( line,':', /extract ))[1]
    if strmatch( line, '*altitude_from*' ) then $
      altitude_from = (strsplit( line,':', /extract ))[1]
    if strmatch( line, '*subsolar longitude*' ) then $
      longsubsol = fix((strsplit( line,':', /extract ))[1],type=4) ; float
    if strmatch( line, '*mars_radius*' ) then $
      mars_radius = fix((strsplit( line,':', /extract ))[1],type=4); float
    ;
    ; Punt on units for now
    ;
    if strmatch( line, '*Units*' ) then units = line
    ;
    ; I do not like the assumption I make here that Longitude is 
    ; first and that there will be no space between the index and name
    ;
    if strmatch( line, '*1.Longitude*' ) then begin
      ;
      ;  First, split them according to the spaces
      ;
      temp = strsplit( line, ' ', /extract )
      ;
      ;  Now, to be consistent with existing code, I need to work out
      ;  how to deal with pointers in IDL
      ;
      ; Check which elements of temp have dots
      ;
      ;data_name = []
      data = []
      dim_order = strarr(3)
      idim = 0
      for itracer = 0,n_elements(temp)-1 do begin
        if strmatch( temp[itracer], '*.*' ) then begin
          ;
          ; Get the name of the variable
          ;
          data_name = (strsplit(temp[itracer],'.',/extract))[1]
          ;
          ; Build the array of pointers to the structures
          ;
          if strmatch(data_name,'*tude*',/fold_case) then begin
            ;
            ;  These are the dimension parameters
            ;
            dim_order[idim] = data_name
            idim++
          endif else begin
            ;
            ;  These are the data parameters
            ;
            ;
            ;  HACK: the definition of the data array dims is hardwired
            ;
;            var_ptr = ptr_new( create_struct( $
;                               'name', data_name, $
;                               'data', dblarr(nlons,nlats,nalts), $
;                               'dim_order', 'lon,lat,alt' ) )
            var_ptr = ptr_new( { name:data_name, $
                                 data:dblarr(nlons,nlats,nalts), $
                                 dim_order:dim_order} )
            data = [data, var_ptr]
          endelse
        endif ; an indexed parameter column is found
      endfor  ; loop over columns in tracer identifier line
    endif     ; if we are in the tracer idensifier line
    ;
    ;  Any other deets go here
    ;
  endfor ; loop over lines of header
;
;  Verify selected header quntities against filename
;  First, parse the file name (to get rid of path)
;  the shorter filename is called fname
;
  fname = (strsplit( filename, path_sep(), /extract ))[-1]
  bits = strsplit( fname, '[._]', /extract, /regex )
  ;
  ; LS can be gleaned from the filename
  ;
  temp = bits[where(strmatch(bits,'*ls*',/fold_case))]
  ls_fname = STRMID(temp, STREGEX(temp, "[0123456789]{1,3}", length=len), len)
  if( ls_fname ne ls )then begin
    print,'LS mismatch'
    print,'LS from filename = ',ls_fname
    print,'LS from file header = ',LS
  endif
  ;
  ;  Solar activity can be gleaned from filename
  ;  But not until I have a mapping from Steve
  ;
  
  ;
  ;  Date/Time can be gleaned from filename
  ;
  
  ;
  ;  Create the metadata structure
  ;
  meta = {LS:LS, LONGSUBSOL: longsubsol, DECLINATION: dec, $
          MARS_RADIUS:mars_radius, COORD_SYS:coord_sys, $
          ALTITUDE_FROM: altitude_from }
  ;
  ;  Create the empty (all zeros) dims structure
  ;
  dims = {lon:lon, lat:lat, alt:alt}
  return, header
end
