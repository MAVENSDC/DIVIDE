;+
; :Name:
;   mvn_kp_3d_event_basemap
; 
; :Description:
;   Procedure to respond to widget events selecting the basemap
;   to be displayed
;
; :Author:
;   Kevin McGouldrick (2015-May-21)
;
; :Parameters:
;   event: in, required
;     widget event
;     
; :Version:
;  1.0
;
;-
pro mvn_kp_3d_event_basemap,event
;
;  This is required to be able to update pstate
;
  widget_control, event.top, get_uvalue=pstate
  mag_index = widget_info(event.id, /droplist_select)
;
;  This captures the current widget event
;
  widget_control, event.id, get_value=newval
  insitu_spec = (*pstate).insitu
          
;
;  Parse the given requested parameter, verify its existence, and
;  set some useful variables
;
  case newval of
    'BLANK': $
      begin
        ;START WITH A WHITE GLOBE
        image = bytarr(3,2048,1024)
        image[*,*,*] = 255
        oImage = OBJ_NEW('IDLgrImage', image )
        (*pstate).mars_base_map = 'blank'
        (*pstate).opolygons -> setproperty, texture_map=oimage
        (*pstate).gridlines -> setProperty, hide=0
        (*pstate).window ->draw,(*pstate).view
      end
    'MDIM': $
      begin
        read_jpeg,(*pstate).bm_install_directory+'MDIM_2500x1250.jpg',image
        oImage = OBJ_NEW('IDLgrImage', image )
        (*pstate).mars_base_map = 'mdim'
        (*pstate).opolygons -> setproperty, texture_map=oimage
        (*pstate).window->draw, (*pstate).view
      end
    'MOLA': $
      begin
        read_jpeg,(*pstate).bm_install_directory+'MOLA_color_2500x1250.jpg',$
                  image
        oImage = OBJ_NEW('IDLgrImage', image )
        (*pstate).mars_base_map = 'mola'
        (*pstate).opolygons -> setproperty, texture_map=oimage
        (*pstate).window->draw, (*pstate).view
      end
    'MOLA_BW': $
      begin
        read_jpeg,(*pstate).bm_install_directory+'MOLA_BW_2500x1250.jpg',$
                  image
        oImage = OBJ_NEW('IDLgrImage', image )
        (*pstate).mars_base_map = 'mola_bw'
        (*pstate).opolygons -> setproperty, texture_map=oimage
        (*pstate).window->draw, (*pstate).view
      end
    'CRUSTAL MAG': $
      begin
        read_jpeg,(*pstate).bm_install_directory+'MAG_Connerny_2005.jpg',$
                  image
        oImage = OBJ_NEW('IDLgrImage', image )
        (*pstate).mars_base_map = 'mag'
        (*pstate).opolygons -> setproperty, texture_map=oimage
        (*pstate).window->draw, (*pstate).view
      end
    'User Defined': $
      begin
        input_file = dialog_pickfile(path=(*pstate).install_directory,$
                                     filter='*.jpg')
        if input_file ne '' then begin
          read_jpeg,input_file,image
          oImage = OBJ_NEW('IDLgrImage', image )
          (*pstate).mars_base_map = 'user'
          (*pstate).opolygons -> setproperty, texture_map=oimage
          (*pstate).window->draw, (*pstate).view
        endif
      end

  endcase

  return
end
