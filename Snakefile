# ==================== Import auxiliary functions ====================
from auxs import makeParFile

# ==================== Snakemake rules ====================
rule all:
    input:
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
        'data/temp/.gitkeep',
        'data/param/l2param.prm'
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
rule parfile:
    input:
        paramFolder = 'data/param/.gitkeep',
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

# ==================== Independent rules ====================
# Clean the folder
rule clean:
    shell:
        '''
        # Remove folder tree
        rm -rf data/
        '''
