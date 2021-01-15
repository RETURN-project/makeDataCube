# ==================== Import auxiliary functions ====================
from auxs import makeParFile

# ==================== Inputs ====================

# Extent of the area of interest, vector with xmin, xmax, ymin, ymax in degrees
ext = [-43.38238361637443, -43.27938679020256, -4.555765244985907, -4.451717415449725]

# Maximum cloud cover of the Landsat images (images with higher cloud cover will not be downloaded)
cld = 50 

# Start date of the study period: year, month, day
starttime = [2000, 11, 1]

# End date of the study period: year, month, day
endtime = [2001, 5, 28]

# Tier level of Landsat data (gives information about the quality of the data)
tiers = 'T1'

# Landsat sensors of interest
sensors = ('LC08', 'LE07', 'LT05', 'LT04') #sensors, 'LM05', 'LM04'

# ==================== Snakemake rules ====================
rule all:
    input:
        'data/.gitkeep', # TODO: use a dictionary
        'data/level1/queue.txt',
        'data/level1/landsat/.gitkeep', 
        'data/level1/sentinel/.gitkeep',
        'data/level2/.gitkeep',
        'data/log/DEM.txt',
        'data/log/fire.txt',
        'data/log/Landsat.txt',
        'data/log/LC.txt',
        'data/log/Smission.txt',
        'data/log/Sother.txt',
        'data/log/Sskip.txt',
        'data/log/Ssuccess.txt',
        'data/log/tc.txt',
        'data/log/WVP.txt',
        'data/misc/dem/.gitkeep',
        'data/misc/fire/.gitkeep',
        'data/misc/lc/.gitkeep',
        'data/misc/S2/S2grid.kml',
        'data/misc/tc/.gitkeep',
        'data/misc/wvp/.gitkeep',
        'data/param/.gitkeep',
        'data/temp/.gitkeep',
        'data/param/l2param.prm',
        'data/misc/dem/S04W043.hgt', # TODO: use wildcard here
        'data/misc/dem/S04W044.hgt', # TODO: use wildcard here
        'data/misc/dem/S05W043.hgt', # TODO: use wildcard here
        'data/misc/dem/S05W044.hgt', # TODO: use wildcard here
        'data/misc/dem/srtm.txt',
        'data/misc/dem/srtm.vrt',
        'misc/wvp/wrs-2-land.coo'
    shell:
        '''
        echo "Finished"
        '''

# Create the folder tree structure
rule tree:
    output:
        'data/.gitkeep',
        'data/level1/queue.txt',
        'data/level1/landsat/.gitkeep',
        'data/level1/sentinel/.gitkeep',
        'data/level2/.gitkeep',
        'data/log/DEM.txt',
        'data/log/fire.txt',
        'data/log/Landsat.txt',
        'data/log/LC.txt',
        'data/log/Smission.txt',
        'data/log/Sother.txt',
        'data/log/Sskip.txt',
        'data/log/Ssuccess.txt',
        'data/log/tc.txt',
        'data/log/WVP.txt',
        'data/misc/dem/.gitkeep',
        'data/misc/fire/.gitkeep',
        'data/misc/lc/.gitkeep',
        'data/misc/S2/.gitkeep',
        'data/misc/tc/.gitkeep',
        'data/misc/wvp/.gitkeep',
        'data/param/.gitkeep',
        'data/temp/.gitkeep'
    shell:
        '''
        # Create the folders
        # Reference for doing it in a single line:
        # https://unix.stackexchange.com/questions/305844/how-to-create-a-file-and-parent-directories-in-one-command 
        mkdir -p $(dirname {output})

        # Add the list of empty files
        touch {output}
        '''

# Create the parameter file
rule parameters:
    input:
        paramFolder = 'data/param/.gitkeep', # TODO: use rules.tree.output
        queueFile = 'data/level1/queue.txt',
        l2Folder = 'data/level2/.gitkeep',
        logFolder = 'data/log/DEM.txt',
        tmpFolder = 'data/temp/.gitkeep',
        demFolder = 'data/misc/dem/.gitkeep',
        wvpFolder = 'data/misc/wvp/.gitkeep'
    output:
        paramFile = 'data/param/l2param.prm',
        paramFileBak = 'data/param/l2param.prm.bak'
    run:
        # Use os.path.dirname to translate .gitkeep filenames into directory names
        from os.path import dirname
        makeParFile(paramfolder = dirname(input.paramFolder),
                    filename = output.paramFile,
                    FILE_QUEUE = input.queueFile,
                    DIR_LEVEL2 = dirname(input.l2Folder),
                    DIR_LOG = dirname(input.logFolder),
                    DIR_TEMP = dirname(input.tmpFolder),
                    FILE_DEM = 'data/misc/dem/srtm.vrt', # TODO : ask Wanda about this file
                    ORIGIN_LON = '-90',
                    ORIGIN_LAT = '60',
                    RESAMPLING = 'NN',
                    DIR_WVPLUT = dirname(input.wvpFolder),
                    RES_MERGE = 'REGRESSION',
                    NPROC = '1',
                    NTHREAD = '1',
                    DELAY = '10',
                    OUTPUT_DST = 'TRUE',
                    OUTPUT_VZN = 'TRUE',
                    OUTPUT_HOT = 'TRUE',
                    OUTPUT_OVV = 'TRUE',
                    DEM_NODATA = '-32768',
                    TILE_SIZE = '3000',
                    BLOCK_SIZE = '300')

rule Sentinel:
    input:
        dataFolder = 'data/.gitkeep',
        miscFolder = 'data/misc/S2/.gitkeep',
        queueFile = 'data/level1/queue.txt'
    output:
        'data/misc/S2/S2grid.kml' #TODO: what about `level1/sentinel/T23MPQ and T23MPR`?
    params:
        ext = ext,
        starttime = starttime,
        endtime = endtime
    script:
        'sentinel_script.R'

rule DEM:
    input:
        demFolder = 'data/misc/dem/.gitkeep',
        demlogfile = 'data/log/DEM.txt'
    output:
        'data/misc/dem/S04W043.hgt', # TODO: use wildcard here
        'data/misc/dem/S04W044.hgt',
        'data/misc/dem/S05W043.hgt',
        'data/misc/dem/S05W044.hgt'
    params:
        ext = ext
    script:
        'DEM_script.R' #TODO: this script can probably be parallelized

rule VRT:
    input:
        'data/misc/dem/S04W043.hgt', # Although this input not explicitly used, the files have to be there for this chunk to work # TODO: wildcards here
        demFolder = 'data/misc/dem/.gitkeep'
    output:
        srtmTxtFile = 'data/misc/dem/srtm.txt', # TODO: read path from demFolder?
        srtmVrtFile = 'data/misc/dem/srtm.vrt' # TODO: read path from demFolder?
    shell:
        '''
        # Create the srtm file (a list of hgt files)
        find $(dirname {input.demFolder}) -name '*.hgt' > {output.srtmTxtFile}

        # Build the VRT file
        gdalbuildvrt -input_file_list {output.srtmTxtFile} {output.srtmVrtFile}
        '''

rule WVP:
    input:
        srtmVrtFile = 'data/misc/dem/srtm.vrt', # Force rule to happen after VRT
        wvpFolder = 'data/misc/wvp/.gitkeep',
        wvplogFile = 'data/log/WVP.txt'
    params:
        endtime = endtime
    output:
        'misc/wvp/wrs-2-land.coo' #TODO: account for the several WVP_0000_01_00.txt
    script:
        'WVP_script.R'

# ==================== Independent rules ====================
# Clean the folder
rule clean:
    shell:
        '''
        # Remove folder tree
        rm -rf data/*
        '''