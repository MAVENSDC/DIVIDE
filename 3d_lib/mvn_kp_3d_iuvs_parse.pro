;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html

pro mvn_kp_3d_iuvs_parse, iuvs, instrument_array, e_disk_list=e_disk_list, $
       e_limb_list=e_limb_list, e_high_list, lo_disk_list=lo_disk_list, $
       lo_limb_list=lo_limb_list, lo_high_list=lo_high_list

      e_disk_list = 'Echelle Disk'
      if instrument_array[11] eq 1 then begin           ;Echelle Disk
        tag_list = tag_names(iuvs.corona_e_disk)
        check = where(tag_list eq 'RADIANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_e_disk.radiance_id[0] ne '')
          e_disk_list = [e_disk_list,$
                         'Radiance:'+iuvs[min(temp, /NAN)].corona_e_disk.radiance_id]
        endif
      endif
      e_limb_list = 'Echelle Limb'
      if instrument_array[15] eq 1 then begin           ;Echelle Limb
        tag_list = tag_names(iuvs.corona_e_limb)
        check = where(tag_list eq 'RADIANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_e_limb.radiance_id[0] ne '')
          e_limb_list = [e_limb_list, $
                         'Radiance:'+iuvs[min(temp, /NAN)].corona_e_limb.radiance_id]
        endif
        check = where(tag_list eq 'HALF_INT_DISTANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_e_limb.half_int_distance_id[0] ne '')
          e_limb_list $
            = [e_limb_list, $
               'HALF_INT_DISTANCE:'+iuvs[min(temp, /NAN)]$
                                    .corona_e_limb.half_int_distance_id]
        endif
      endif
      e_high_list = 'Echelle High'
      if instrument_array[10] eq 1 then begin           ;Echelle High
        tag_list = tag_names(iuvs.corona_e_high)
        check = where(tag_list eq 'RADIANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_e_high.radiance_id[0] ne '')
          e_high_list = [e_high_list, $
                         'Radiance:'+iuvs[min(temp, /NAN)].corona_e_high.radiance_id]
        endif
        check = where(tag_list eq 'HALF_INT_DISTANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_e_high.half_int_distance_id[0] ne '')
          e_high_list $
            = [e_high_list, $
               'HALF_INT_DISTANCE:'+iuvs[min(temp, /NAN)]$
                                    .corona_e_high.half_int_distance_id]
        endif
      endif
      lo_disk_list = 'LoRes Disk'
      if instrument_array[16] eq 1 then begin           ;Low Res Disk
        tag_list = tag_names(iuvs.corona_lo_disk)
        check = where(tag_list eq 'RADIANCE')
        if check ne -1 then begin
          temp  = where(iuvs.corona_lo_disk.radiance_id[0] ne '')
          lo_disk_list = [lo_disk_list, $
                          'Radiance:'+iuvs[min(temp, /NAN)]$
                                      .corona_lo_disk.radiance_id]
        endif
        check = where(tag_list eq 'DUST_DEPTH:')
        if check ne -1 then lo_disk_list = [lo_disk_list, 'Dust Depth']
        check = where(tag_list eq 'OZONE_DEPTH:')
        if check ne -1 then lo_disk_list = [lo_disk_list, 'Ozone Depth']
        check = where(tag_list eq 'AURORAL_INDEX:')
        if check ne -1 then lo_disk_list = [lo_disk_list, 'Auroral Index']
      endif
      lo_limb_list = 'LoRes Limb'
      if instrument_array[14] eq 1 then begin           ;Low Res Limb
        tag_list = tag_names(iuvs.corona_lo_limb)
        check = where(tag_list eq 'RADIANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_lo_limb.radiance_id[0] ne '')    
          lo_limb_list = [lo_limb_list, $
                          'Radiance:'+iuvs[min(temp, /NAN)]$
                                      .corona_lo_limb.radiance_id]
        endif
        check = where(tag_list eq 'SCALE_HEIGHT')
        if check ne -1 then begin
          temp = where(iuvs.corona_lo_limb.scale_height_id[0] ne '')    
          lo_limb_list = [lo_limb_list, $
                          'Scale_Height:'+iuvs[min(temp, /NAN)]$
                                          .corona_lo_limb.scale_height_id]
        endif
        check = where(tag_list eq 'DENSITY')
        if check ne -1 then begin
          temp = where(iuvs.corona_lo_limb.density_id[0] ne '')
          lo_limb_list = [lo_limb_list, $
                          'Density:'+iuvs[min(temp, /NAN)]$
                                     .corona_lo_limb.density_id]
        endif
        check = where(tag_list eq 'TEMPERATURE')
        if check ne -1 then lo_limb_list = [lo_limb_list, 'Temperature:']
      endif
      lo_high_list = 'LoRes High'
      if instrument_array[13] eq 1 then begin           ;Row Res High
        tag_list = tag_names(iuvs.corona_lo_high)
        check = where(tag_list eq 'RADIANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_lo_high.radiance_id[0] ne '')    
          lo_high_list = [lo_high_list, $
                          'Radiance:'+iuvs[min(temp, /NAN)]$
                                      .corona_lo_high.radiance_id]
        endif
        check = where(tag_list eq 'DENSITY')
        if check ne -1 then begin
          temp = where(iuvs.corona_lo_high.density_id[0] ne '')    
          lo_high_list = [lo_high_list, $
                          'Density:'+iuvs[min(temp, /NAN)].corona_lo_high.density_id]
        endif        
        check = where(tag_list eq 'HALF_INT_DISTANCE')
        if check ne -1 then begin
          temp = where(iuvs.corona_lo_high.half_int_distance_id[0] ne '')    
          lo_high_list $
            = [lo_high_list, $
               'HALF_INT_DISTANCE:'+iuvs[min(temp, /NAN)]$
                                    .corona_lo_high.half_int_distance_id]
        endif          
     endif

end
