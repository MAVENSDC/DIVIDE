#
#  Place whatever relevant header info is needed here
#  Including import statements
#
# Author: McGouldrick
#
# Version 0.1 (2015-Nov-30)
#
# This will be a library of the DIVIDE IDL toolkit translated into python
#
#-------------------------------------------------------------------
#
import numpy as np
import sys

def param_list( insitu ):
    '''
    Return a listing of all parameters present in the given 
    insitu data dictionary/structure.  At present, this does
    not include the fancy formatting that can more easily 
    distinguish one instrument form another.
    '''
    index = 1
    ParamList = []
    for base_tag in insitu.dtype.names:
        try:
            first_level_tags = insitu[base_tag][0].dtype.names
            for first_level_tag in first_level_tags:
                ParamList.append("#%3d %s.%s" % 
                                 (index,base_tag,first_level_tag) )
                index = index + 1
        except:
            pass
    return ParamList

#---------------------------------------------------------------------
def param_range( kp, iuvs=None ):
    '''
    Print the range of times and orbits for the provided insitu data.
    If iuvs data are also provided, return orbit numbers for IUVS data.
    At present, not configured to handle IUVS data.
    '''
#
# First, the case where insitu data are provided
#
    if kp.dtype.names[0] == 'TIME_STRING':
        print "The loaded insitu KP data set contains data between"
        print( "   %s and %s" % (kp[0].time_string, kp[-1].time_string) )
        print "Equivalently, this corresponds to orbits"
        print ( "   %6d and %6d." % (kp[0].orbit, kp[-1].orbit) )
#
#  Next, the case where IUVS data are provided
#
    iuvs_data = False
    iuvs_tags = ['CORONA_LO_HIGH','CORONA_LO_LIMB','CORONA_LO_DISK',
                 'CORONA_E_HIGH','CORONA_E_LIMB','CORONA_E_DISK',
                 'APOAPSE','PERIAPSE','STELLAR_OCC']
    if kp.dtype.names[0] in iuvs_tags:
        print "The loaded IUVS KP data set contains data between orbits"
        print "   %6d and %6d." % (kp[0].orbit, kp[-1].orbit)
#
#  Finally, the case where both insitu and IUVS are provided
#
    if iuvs is not None: 
        print "The loaded IUVS KP data set contains data between orbits"
        print "   %6d and %6d." % (iuvs[0].orbit, iuvs[-1].orbit)
        insitu_min, insitu_max = np.nanmin(kp.orbit), np.nanmax(kp.orbit)
        if ( np.nanmax(iuvs.orbit) < insitu_min or 
             np.nanmin(iuvs.orbit) > insitu_max ): 
            print "*** WARNING ***"
            print "There is NO overlap between the supplied insitu and IUVS"
            print "  data structures.  We cannot guarantee your safety "
            print "  should you attempt to display these IUVS data against"
            print "  these insitu-supplied emphemeris data."
    return # No information to return

#--------------------------------------------------------------------------

def range_select( kp, time ):
    '''
    Given an insitu KP data set and time information in the form of 
    either an array of times or orbits, return the starting and ending
    indices of the provided dataset for the requested range.
    '''
    import bisect # can I import htis here only?
    from datetime import datetime
    # First, define the time strings if needed
    dt = [datetime.strptime(i, '%Y-%m-%dT%H:%M:%S') for i in kp.time_string]
    # Now check the input time values
    try:
        orbit = int(time) # time given as single integer orbit number
        mask = np.where( orbit == kp.orbit )
        return kp[mask]
    except:
        if np.count_nonzero(time) == 1:
            # time given as single date-time string
            # First convert it to a date-time object
            dt_in = datetime.strptime(time, '%Y-%m-%dT%H:%M:%S')
            # select 24 hours of data following given time
            # for debugging purposes, use 3 hr
            dt_delta = [(i-dt_in).total_seconds() for i in dt]
            mask = np.all([np.array(dt_delta) < 10800., 
                              np.array(dt_delta) > 0], axis=0 )
            return kp[mask]
        else:
            # Either we have two ints or two strings
            try: 
                # If successful, we have two ints
                int(time[0])
                orbit = np.array(time)
                mask = np.all([np.min(orbit) <= kp.orbit, 
                                  np.max(orbit) >= kp.orbit], axis=0 )
                return kp[mask]
            except:
                # Check for data times between given times
                dt_in = [datetime.strptime(i, '%Y-%m-%dT%H:%M:%S') 
                         for i in time]
                lower = bisect.bisect_left(dt,min(dt_in))
                upper = bisect.bisect_right(dt,max(dt_in))
                return kp[lower:upper]

#--------------------------------------------------------------------------

def time_plot( kp, parameter=None, time=None, errors=None ):
    '''
    *** Just a place holder: Not yet functional ***
    Plot the provided data as a time series.
    For now, just accept a single parameter.
    For now, do not accept any error bar information.
    If time is not provided plot entire data set.
    '''
    # No need for get help routine: embedded in python
    # No need for tag parsing: python does this
    # No need for list call: that attribute has been provided
    # No need for range call: already provided

    # Check validity of parameter
    if parameter == None: 
        print "Must provide an index (or name) for param to be plotted."
        return

    # Check the time variable
    if time == None:
        istart, iend = 0,np.count_nonzero(kp.orbit)-1
    else:
        istart,iend = kp.range_select(time)

