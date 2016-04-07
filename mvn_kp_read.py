import os
from mvn_kp_utilities import param_list_sav
from mvn_kp_utilities import param_list
from mvn_kp_utilities import param_range
from mvn_kp_utilities import range_select
from mvn_kp_utilities import insufficient_input_range_select
from mvn_kp_utilities import make_time_labels
from mvn_kp_utilities import get_inst_obs_labels
from mvn_kp_utilities import find_param_from_index
from mvn_kp_utilities import remove_inst_tag
from mvn_kp_utilities import kp_regex
from mvn_kp_utilities import get_latest_file_from_date
import mvn_kp_download_files_utilities as utils


def mvn_kp_read(input_time, instruments = None):
    '''
    Read in a given filename in situ file into a dictionary object
    Optional keywords maybe used to downselect instruments returned
     and the time windows.

    Input:
        filename: Name of the in situ KP file to read in.
        time (Not Yet Implemeted): 
            Set a time bounds/filter on the data
            (this will be necessary when this is called by a wrapper that
             seeks to ingest all data within a range of dates that may
             be allowed to span multiple days (files) ).
        Instruments: (Not Yet Implemented)
            Optional keyword listing the instruments to include 
            in the returned dictionary/structure.
    Output:
        A dictionary (data structure) containing up to all of the columns
            included in a MAVEN in-situ Key parameter data file.

    ToDo: Implement Instrument selection ability
          Some repetition of effort here; maybe modularize parts of this?
    '''
    import pandas as pd
    import re
    import time
    from datetime import datetime

    # Get the file name from the date
    year, month, day = input_time.split('-')
    filename = get_latest_file_from_date(year, month, day)
    
    
    # Determine number of header lines    
    nheader = 0
    for line in open(filename):
        if line.startswith('#'):
            nheader = nheader+1

    #
    # Parse the header (still needs special case work)
    #
    ReadParamList = False
    index_list = []
    fin = open(filename)
    icol = -2 # Counting header lines detailing column names
    iname = 1 # for counting seven lines with name info
    ncol = -1 # Dummy value to allow reading of early headerlines?
    col_regex = '#\s(.{16}){%3d}' % ncol # needed for column names
    for iline in range(nheader):
        line = fin.readline()
        if re.search('Number of parameter columns',line): 
            ncol = int(re.split("\s{3}",line)[1])
            col_regex = '#\s(.{16}){%3d}' % ncol # needed for column names
        elif re.search('Line on which data begins',line): 
            nhead_test = int(re.split("\s{3}",line)[1])-1
        elif re.search('Number of lines',line): 
            ndata = int(re.split("\s{3}",line)[1])
        elif re.search('PARAMETER',line):
            ReadParamList = True
            ParamHead = iline
        elif ReadParamList:
            icol = icol + 1
            if icol > ncol: ReadParamList = False
        elif re.match(col_regex,line):
            # OK, verified match now get the values
            temp = re.findall('(.{16})',line[3:])
            if iname == 1: index = temp
            elif iname == 2: obs1 = temp
            elif iname == 3: obs2 = temp
            elif iname == 4: obs3 = temp
            elif iname == 5: inst = temp
            elif iname == 6: unit = temp
            elif iname == 7: FormatCode = temp
            else: 
                print 'More lines in data descriptor than expected.'
                print 'Line %d' % iline
            iname = iname + 1
        else:
            pass

    #
    # Generate the names list.
    # NB, there are special case redundancies in there
    # (e.g., LPW: Electron Density Quality (min and max))
    # ****SWEA FLUX electron QUALITY *****
    #
    First = True
    Parallel = None
    names = []
    for h,i,j,k in zip(inst,obs1,obs2,obs3):
        combo_name = (' '.join([i.strip(),j.strip(),k.strip()])).strip()
        if re.match('^LPW$',h.strip()):
        # Max and min error bars use same name in column
        # SIS says first entry is min and second is max
            if re.match('(Electron|Spacecraft)(.+)Quality', combo_name):
                if First:
                    combo_name = combo_name + ' Min'
                    First = False
                else:
                    combo_name = combo_name + ' Max'
                    First = True
        elif re.match('^SWEA$',h.strip()):
        # electron flux qual flags do not indicate whether parallel or anti
        # From context it is clear; but we need to specify in name
            if re.match('.+Parallel.+',combo_name): Parallel = True
            elif re.match('.+Anti-par',combo_name): Parallel = False
            else: pass
            if re.match('Flux, e-(.+)Quality', combo_name ):
                if Parallel: 
                    p = re.compile( 'Flux, e- ' )
                    combo_name = p.sub('Flux, e- Parallel ',combo_name)
                else:
                    p = re.compile( 'Flux, e- ' )
                    combo_name = p.sub('Flux, e- Anti-par ',combo_name)
        # Add inst to names to avoid ambiguity
        # Will need to remove these after splitting
        names.append('.'.join([h.strip(),combo_name]))
        names[0] = 'Time'

    #
    # Now close the file and read the data section into a temporary DataFrame
    #
    fin.close()
    temp = pd.read_fwf(filename, skiprows=nheader, index_col=False, 
                       widths=[19]+ncol*[16], names = names)

    #
    # Assign the first-level only tags
    #
    Time = temp['Time']
    TimeUnix = [time.mktime(datetime.strptime(i,'%Y-%m-%dT%H:%M:%S')
                                             .timetuple()) 
                for i in temp['Time']]
    TimeUnix = pd.Series(TimeUnix) # convert into Series for consistency
    Orbit = temp['SPICE.Orbit Number']
    IOflag = temp['SPICE.Inbound Outbound Flag']

    #
    # Break up dictionary into instrument groups
    #
    LPWgroup, EUVgroup, SWEgroup, SWIgroup, STAgroup, SEPgroup, MAGgroup, \
    NGIgroup, APPgroup, SCgroup = [],[],[],[],[],[],[],[],[],[]
    First = True
    for i,j in zip(inst,names):
        if re.match('^LPW$',i.strip()):
            LPWgroup.append(j)
        elif re.match('^LPW-EUV$',i.strip()):
            EUVgroup.append(j)
        elif re.match('^SWEA$',i.strip()):
            SWEgroup.append(j)
        elif re.match('^SWIA$',i.strip()):
            SWIgroup.append(j)
        elif re.match('^STATIC$',i.strip()):
            STAgroup.append(j)
        elif re.match('^SEP$',i.strip()):
            SEPgroup.append(j)
        elif re.match('^MAG$',i.strip()):
            MAGgroup.append(j)
        elif re.match('^NGIMS$',i.strip()):
            NGIgroup.append(j)
        elif re.match('^SPICE$',i.strip()):
            # NB Need to split into APP and SPACECRAFT
            if re.match('(.+)APP(.+)',j): 
                APPgroup.append(j)
            else: # Everything not APP is SC in SPICE
                # But do not include Orbit Num, or IO Flag
                # Could probably stand to clean this line up a bit
                if not re.match('(.+)(Orbit Number|Inbound Outbound Flag)',j):
                    SCgroup.append(j)
        else:
            pass

    #
    # Build the sub-level DataFrames for the larger dictionary/structure
    #
    LPW=temp[LPWgroup]
    EUV=temp[EUVgroup]
    SWEA=temp[SWEgroup]
    SWIA=temp[SWIgroup]
    STATIC=temp[STAgroup]
    SEP=temp[SEPgroup]
    MAG=temp[MAGgroup]
    NGIMS=temp[NGIgroup]
    APP=temp[APPgroup]
    SPACECRAFT=temp[SCgroup]

    #
    # Strip out the duplicated instrument part of the column names
    # (this is a bit hardwired and can be improved)
    #
    for i in [LPW,EUV,SWEA,SWIA,SEP,STATIC,NGIMS,MAG,APP,SPACECRAFT]:
        i.columns = remove_inst_tag(i)

    #
    # Clean up SPACECRAFT column names
    #
    newcol = []
    for oldcol in SPACECRAFT.columns:
        if oldcol.startswith('Spacecraft'):
            newcol.append(oldcol[len('Spacecraft '):])
        elif oldcol.startswith('Rot matrix MARS'):
            a,b = re.findall('\d{1}',oldcol)
            newcol.append('T%s%s' % (a,b))
        elif oldcol.startswith('Rot matrix SPC'):
            a,b = re.findall('\d{1}', oldcol)
            newcol.append('SPACECRAFT_T%s%s' % (a,b))
        else:
            newcol.append(oldcol)
    SPACECRAFT.columns = newcol

    # Do not forget to save units
    # Define the list of first level tag names
    tag_names = ['TimeString','Time','Orbit','IOflag',
                 'LPW','EUV','SWEA','SWIA','STATIC',
                 'SEP','MAG','NGIMS','APP','SPACECRAFT']
    # Define list of first level data structures
    data_tags = [Time, TimeUnix, Orbit, IOflag, 
                 LPW, EUV, SWEA, SWIA, STATIC, 
                 SEP, MAG, NGIMS, APP, SPACECRAFT]
    # return a dictionary made from tag_names and data_tags
    return ( dict( zip( tag_names, data_tags ) ) )#, 
             #dict( zip( tag_names, unit ) ) )
