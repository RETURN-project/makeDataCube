def dllLandsat(queuefolder, queuefile, tmpfolder, logfile, ext, starttime, endtime, sensors, tiers, cld):
    from pylandsat import Catalog, Product
    from datetime import datetime
    from shapely.geometry import Point
    from shapely.geometry import Polygon
    import re
    import os

    # Search scenes of interest over the study area
    # define area of interest
    xmin = ext[0]
    xmax = ext[1]
    ymin = ext[2]
    ymax = ext[3]
    pol = Polygon([[xmin,ymin],[xmax,ymin],[xmax,ymax],[xmin,ymax],[xmin,ymin]])
    # define time period of interest
    begin = datetime(int(starttime[0]), int(starttime[1]), int(starttime[2]))
    end = datetime(int(endtime[0]), int(endtime[1]), int(endtime[2]))
    # search scenes in catalog that fulfill requirements
    catalog = Catalog()
    scenes = catalog.search(
        begin=begin,
        end=end,
        geom=pol,
        sensors=sensors,
        tiers=tiers,
        maxcloud=cld
    )

    # check which scenes are not downloaded yet
    scenesid = [item['product_id'] for item in scenes]# product id of scenes that match the query
    queue_file = open(os.path.join(queuefolder, queuefile), "r")
    lines = re.findall(r'(\/.*?\.[\w:]+)', queue_file.read())
    queue = [os.path.splitext(os.path.basename(x))[0] for x in lines]# list of scenes that are already in the queue

    dllList = [s for s in scenesid if all(xs not in s for xs in queue)] # items that match the query but are not in     queue

    # Download scenes
    # dllFiles = [Product(x).download(out_dir= tmpfolder) for x in dllList]#Downloaded files
    dllFiles = [checkdll(x, tmpfolder, logfile) for x in dllList]#Downloaded files
    return scenesid

def checkdll(x, out_dir, logfile):
    from pylandsat import Product
    try:
        Product(x).download(out_dir= out_dir)
    except IOError:
        with open(logfile, 'a') as file:
            file.write('cannot download '+ x + ' to ' + out_dir)
