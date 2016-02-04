#Functions used by mvn_kp_download_files

uname = ''
pword = ''

def get_filenames(query, public):
    import urllib
    import urllib2
    
    public_url = 'https://lasp.colorado.edu/maven/sdc/public/files/api/v1/search/science/fn_metadata/file_names'+'?'+query
    private_url = 'https://lasp.colorado.edu/maven/sdc/service/files/api/v1/search/science/fn_metadata/file_names'+'?'+query
    
    if (public==False):
       username = uname
       password = pword
       p = urllib2.HTTPPasswordMgrWithDefaultRealm()
       p.add_password(None, private_url, username, password)
       handler = urllib2.HTTPBasicAuthHandler(p)
       opener = urllib2.build_opener(handler)
       urllib2.install_opener(opener)
       page=urllib2.urlopen(private_url)
    else:
       page=urllib2.urlopen(public_url)
    
    return page.read()

def get_file_from_site(filename, public, data_dir):
    import os
    import urllib
    import urllib2
    
    public_url = 'https://lasp.colorado.edu/maven/sdc/public/files/api/v1/search/science/fn_metadata/download'+'?file='+filename
    private_url = 'https://lasp.colorado.edu/maven/sdc/service/files/api/v1/search/science/fn_metadata/download'+'?file='+filename
    
    if (public==False):
        username = uname
        password = pword
        p = urllib2.HTTPPasswordMgrWithDefaultRealm()
        p.add_password(None, private_url, username, password)
        handler = urllib2.HTTPBasicAuthHandler(p)
        opener = urllib2.build_opener(handler)
        urllib2.install_opener(opener)
        page = urllib2.urlopen(private_url)
    else:
        page = urllib2.urlopen(public_url)
        
    with open(os.path.join(data_dir,filename), "wb") as code:
            code.write(page.read())
    
    return

def get_orbit_files():
    import os
    import urllib
    import urllib2
    
    orbit_files_url = "http://naif.jpl.nasa.gov/pub/naif/MAVEN/kernels/spk/"
    orbit_file_names = ["maven_orb_rec_140922_150101_v1.orb",
                        "maven_orb_rec_150101_150401_v1.orb",
                        "maven_orb_rec_150401_150701_v1.orb",
                        "maven_orb_rec_150701_151001_v1.orb", 
                        "maven_orb_rec.orb"]
    
    full_path=os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    
    orbit_files_path = os.path.join(path, "orbitfiles")
    
    for o_file in orbit_file_names:
        page = urllib2.urlopen(orbit_files_url+o_file)
        with open(os.path.join(orbit_files_path,o_file), "wb") as code:
            code.write(page.read())
    
    
    return


def get_access():
    import os
    full_path=os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    f = open(os.path.join(path, 'access.txt'), 'r')
    f.readline()
    s = f.readline().rstrip()
    s = s.split(' ')
    if s[1]=='1':
        return False
    else:
        return True

def get_root_data_dir():
    import os
    full_path=os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    if (not os.path.exists(os.path.join(path, 'mvn_toolkit_prefs.txt'))):
        set_root_data_dir()
    f = open(os.path.join(path, 'mvn_toolkit_prefs.txt'), 'r')
    f.readline()
    s = f.readline().rstrip()
    s = s.split(' ')
    return s[1]

        
def set_root_data_dir():
    import tkFileDialog
    import Tkinter
    import os 
    
    root = Tkinter.Tk()
    download_path = tkFileDialog.askdirectory()
    root.destroy()
    
    #Put path into preferences file
    full_path=os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    f = open(os.path.join(path, 'mvn_toolkit_prefs.txt'), 'w')
    f.write("'; IDL Toolkit Data Preferences File'\n")
    f.write('mvn_root_data_dir: ' + download_path)
    
    return

def get_new_files(files_on_site, data_dir, instrument, level):
    import os
    import re
    
    fos = files_on_site
    files_on_hd = []
    for (dir, _, files) in os.walk(data_dir):
        for f in files:
            if re.match('mvn_'+instrument+'_'+level+'_*', f):
                files_on_hd.append(f)
    
    x = set(files_on_hd).intersection(files_on_site)
    for matched_file in x:
        fos.remove(matched_file)
    
    return fos

def create_dir_if_needed(f, data_dir, level):
    import os
    
    if (level == 'insitu'):
        year, month, _ = get_year_month_day_from_kp_file(f)
    else:
        year, month, _ = get_year_month_day_from_sci_file(f)
    
    if not os.path.exists(os.path.join(data_dir, year, month)):
        os.makedirs(os.path.join(data_dir, year, month))

    return

def get_year_month_day_from_kp_file(f):
    
    date_string = f.split('_')[3]
    year = date_string[0:4]
    month = date_string[4:6]
    day = date_string[6:8]
    
    return year, month, day

def get_year_month_day_from_sci_file(f):
    
    date_string = f.split('_')[4]
    year = date_string[0:4]
    month = date_string[4:6]
    day = date_string[6:8]
    
    return year, month, day

def display_progress(x,y):
    num_stars=int(round(float(x)/y * 70))
    print "||"+"*"*num_stars+"-"*(70-num_stars)+"||" + " ( "+ str(round(100*float(x)/y)) +"% )"
    return

def get_uname_and_password():
    global uname
    global pword
    import getpass
    
    uname=raw_input("Enter user name to access the team website: ")
    pword=getpass.getpass("Enter your password: ")
    return