;+
;
; :Name:
;  mvn_kp_create_multiplot_vectors
;
; :Description:
;  Generate vectors for plotting multiple parameters at once, for 
;  common use by both mvn_kp_plot and mvn_kp_altplot.  At present,
;  there is conconsistency between the two.  This should recitfy that.
;
; :Author:
;  McGouldrick (2015-May-20)
;
; :Params:
;  kp_data: in, structure
;   - the in situ kp data structure, already trimmed to the begin and
;     end times previously determined in the calling routine.
;  parameter: in, array of string or integer
;   - the list of parameters in the structure to be plotted.
;  error: in, boolean
;   - flag to determine whether error bars are expected to be plotted
;  p_data; out, array
;   - array containing the parameters to be plotted
;  p_error: out, array
;   - array containining the error bars to be plotted
;     - ToDo: at present this assumes a meaning of error parameter
;       which is not universally true.  Will/may need to make this
;       aware of the differences between the insturments
;       w.r.t. errors.
;  p_axis_title: out, string array
;   - array containing the labels for the data parameters
;   - may wish to move this out into the main calling routine
;
;-
;
;  I think these may be needed for tag_verify to work
;
@mvn_kp_tag_parser
@mvn_kp_tag_list
@mvn_kp_tag_verify

pro mvn_kp_create_multi_vectors, kp_data, parameter, p_data, p_error, $
                                 p_label, error=error, y_labels=y_labels, $
                                 err_check=err_check

;DETERMINE ALL THE PARAMETER NAMES THAT MAY BE USED LATER
MVN_KP_TAG_PARSER, kp_data, base_tag_count, first_level_count, $
  second_level_count, base_tags,  first_level_tags, $
  second_level_tags
;
;  Initialize data, label, and error vectors
;  These are same whether parameter is string or integer
;
p_data = fltarr(n_elements(parameter), n_elements(kp_data))
p_error = fltarr(2,n_elements(parameter), n_elements(kp_data))
p_label = strarr(n_elements(parameter))
err_check = intarr(n_elements(parameter))
;
;  Now consider the possible data type cases for parameter
;
if( size( parameter, /type ) eq 2 or $
    size( parameter, /type ) eq 7 )then begin
  ;
  ;  Loop over parameters
  ;
  for i = 0,n_elements(parameter)-1 do begin
    ;
    ; Get the indices for the current parameter
    ;
    MVN_KP_TAG_VERIFY, kp_data, parameter[i], base_tag_count, $
                       first_level_count, base_tags, first_level_tags, $
                       check, level0_index, level1_index, tag_array
    if check eq 1 then begin
      print,'Requested plot parameter, ' + parameter[i] $
            + ' is not included in the provided data structure.'
      print,'Try /LIST to confirm your parameter choice.'
      return
    endif
    ;
    ; If we get here then the parameter was found and checks out
    ; Fill the data vector
    ;
    p_data[i,*] = kp_data.(level0_index).(level1_index)
    ;
    ; assign the data axis labels: keep this inthe plot routines
    ;
    p_label[i] = keyword_set(y_labels) $
               ? y_labels[i] $
               : strupcase(string(tag_array[0]+'.'+tag_array[1]))
    ;
    ; If requested, define the error vectors
    ;
    if keyword_set(error) then begin
      ;
      ; Get the info for the error parameter
      ;
      MVN_KP_TAG_VERIFY, kp_data, error[i], base_tag_count, $
                         first_level_count, base_tags, first_level_tags, $
                         err_check[i], err_level0, err_level1, temp_tag
      if err_check[i] eq 0 then begin
         p_error[0,i,*] = kp_data.(level0_index).(level1_index) $
                        - kp_data.(err_level0).(err_level1)
         p_error[1,i,*] = kp_data.(level0_index).(level1_index) $
                        + kp_data.(err_level0).(err_level1)
      endif else begin
        print,'Requested error parameter is not included in the data.'
        print,'Try /LIST to check for it.'
        print,'Creating requested plot WITHOUT error bars'
      endelse
    endif else begin ; error key word not set
      err_check[i] = 1
    endelse
  endfor ; loop over all parameters
endif else begin
  print,'<parameter> cannot be given as data type: '+typename(parameter)
  print,'            It must be either STRING or INTEGER.'
  print,"See Users' Guide for details of usage."
  print,'Exiting.....'
  return
endelse
end
