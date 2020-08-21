def makeParFile(paramfolder, filename, FILE_QUEUE = 'NULL', DIR_LEVEL2 = 'NULL', DIR_LOG = 'NULL', DIR_TEMP = 'NULL', FILE_DEM = 'NULL',
DEM_NODATA= '-32767', DO_REPROJ = 'TRUE', DO_TILE = 'TRUE',FILE_TILE = 'NULL',TILE_SIZE = '30000',BLOCK_SIZE = '3000', RESOLUTION_LANDSAT = '30', RESOLUTION_SENTINEL2 = '10', ORIGIN_LON = '-25', ORIGIN_LAT = '60', PROJECTION = 'GLANCE7', RESAMPLING = 'CC', DO_ATMO = 'TRUE', DO_TOPO = 'TRUE', DO_BRDF = 'TRUE', ADJACENCY_EFFECT = 'TRUE', MULTI_SCATTERING = 'TRUE', DIR_WVPLUT = 'NULL', WATER_VAPOR = 'NULL', DO_AOD = 'TRUE', DIR_AOD = 'NULL', MAX_CLOUD_COVER_FRAME = '75', MAX_CLOUD_COVER_TILE = '75', CLOUD_THRESHOLD = '0.225', SHADOW_THRESHOLD = '0.02', RES_MERGE = 'IMPROPHE', DIR_MASTER = 'NULL', MASTER_NODATA = '-32767', IMPULSE_NOISE = 'TRUE', BUFFER_NODATA = 'FALSE', TIER = '1', NPROC = '32', NTHREAD = '2', PARALLEL_READS = 'FALSE', DELAY = '3', TIMEOUT_ZIP = '30', OUTPUT_FORMAT = 'GTiff', OUTPUT_DST = 'FALSE', OUTPUT_AOD = 'FALSE', OUTPUT_WVP = 'FALSE', OUTPUT_VZN = 'FALSE', OUTPUT_HOT = 'FALSE', OUTPUT_OVV = 'FALSE'):
    import fileinput
    import os.path
    import os
    # check if the parameter file exists
    if(not os.path.isfile(filename)):
        # generate an empty parameter file
        os.system("force-parameter " + paramfolder + " LEVEL2 0")
        # rename
        os.system("mv " + os.path.join(paramfolder,'LEVEL2-skeleton.prm')+" "+filename)
        # modify the file
        with fileinput.FileInput(filename, inplace=True, backup='.bak') as file:
            for line in file:
                print(line.replace('FILE_QUEUE = NULL', 'FILE_QUEUE = ' + FILE_QUEUE)
                .replace('DIR_LEVEL2 = NULL', 'DIR_LEVEL2 = ' + DIR_LEVEL2)
                .replace('DIR_LOG = NULL', 'DIR_LOG = ' + DIR_LOG)
                .replace('DIR_TEMP = NULL', 'DIR_TEMP = ' + DIR_TEMP)
                .replace('FILE_DEM = NULL', 'FILE_DEM = ' + FILE_DEM)
                .replace('DEM_NODATA = -32767', 'DEM_NODATA = ' + DEM_NODATA)
                .replace('DO_REPROJ = TRUE', 'DO_REPROJ = ' + DO_REPROJ)
                .replace('DO_TILE = TRUE', 'DO_TILE = ' + DO_TILE)
                .replace('FILE_TILE = NULL', 'FILE_TILE = ' + FILE_TILE)
                .replace('TILE_SIZE = 30000', 'TILE_SIZE = ' + TILE_SIZE)
                .replace('BLOCK_SIZE = 3000', 'BLOCK_SIZE = ' + BLOCK_SIZE)
                .replace('RESOLUTION_LANDSAT = 30', 'RESOLUTION_LANDSAT = ' + RESOLUTION_LANDSAT)
                .replace('RESOLUTION_SENTINEL2 = 10', 'RESOLUTION_SENTINEL2 = ' + RESOLUTION_SENTINEL2)
                .replace('ORIGIN_LON = -25', 'ORIGIN_LON = ' + ORIGIN_LON)
                .replace('ORIGIN_LAT = 60', 'ORIGIN_LAT = ' + ORIGIN_LAT)
                .replace('PROJECTION = GLANCE7', 'PROJECTION = ' + PROJECTION)
                .replace('RESAMPLING = CC', 'RESAMPLING = ' + RESAMPLING)
                .replace('DO_ATMO = TRUE', 'DO_ATMO = ' + DO_ATMO)
                .replace('DO_TOPO = TRUE', 'DO_TOPO = ' + DO_TOPO)
                .replace('DO_BRDF = TRUE', 'DO_BRDF = ' + DO_BRDF)
                .replace('ADJACENCY_EFFECT = TRUE', 'ADJACENCY_EFFECT = ' + ADJACENCY_EFFECT)
                .replace('MULTI_SCATTERING = TRUE', 'MULTI_SCATTERING = ' + MULTI_SCATTERING)
                .replace('DIR_WVPLUT = NULL', 'DIR_WVPLUT = ' + DIR_WVPLUT)
                .replace('WATER_VAPOR = NULL', 'WATER_VAPOR = ' + WATER_VAPOR)
                .replace('DO_AOD = TRUE', 'DO_AOD = ' + DO_AOD)
                .replace('DIR_AOD = NULL', 'DIR_AOD = ' + DIR_AOD)
                .replace('MAX_CLOUD_COVER_FRAME = 75', 'MAX_CLOUD_COVER_FRAME = ' + MAX_CLOUD_COVER_FRAME)
                .replace('MAX_CLOUD_COVER_TILE = 75', 'MAX_CLOUD_COVER_TILE = ' + MAX_CLOUD_COVER_TILE)
                .replace('CLOUD_THRESHOLD = 0.225', 'CLOUD_THRESHOLD = ' + CLOUD_THRESHOLD)
                .replace('SHADOW_THRESHOLD = 0.02', 'SHADOW_THRESHOLD = ' + SHADOW_THRESHOLD)
                .replace('RES_MERGE = IMPROPHE', 'RES_MERGE = ' + RES_MERGE)
                .replace('DIR_MASTER = NULL', 'DIR_MASTER = ' + DIR_MASTER)
                .replace('MASTER_NODATA = -32767', 'MASTER_NODATA = ' + MASTER_NODATA)
                .replace('IMPULSE_NOISE = TRUE', 'IMPULSE_NOISE = ' + IMPULSE_NOISE)
                .replace('BUFFER_NODATA = FALSE', 'BUFFER_NODATA = ' + BUFFER_NODATA)
                .replace('TIER = 1', 'TIER = ' + TIER)
                .replace('NPROC = 32', 'NPROC = ' + NPROC)
                .replace('NTHREAD = 2', 'NTHREAD = ' + NTHREAD)
                .replace('PARALLEL_READS = FALSE', 'PARALLEL_READS = ' + PARALLEL_READS)
                .replace('DELAY = 3', 'DELAY = ' + DELAY)
                .replace('TIMEOUT_ZIP = 30', 'TIMEOUT_ZIP = ' + TIMEOUT_ZIP)
                .replace('OUTPUT_FORMAT = GTiff', 'OUTPUT_FORMAT = ' + OUTPUT_FORMAT)
                .replace('OUTPUT_DST = FALSE', 'OUTPUT_DST = ' + OUTPUT_DST)
                .replace('OUTPUT_AOD = FALSE', 'OUTPUT_AOD = ' + OUTPUT_AOD)
                .replace('OUTPUT_WVP = FALSE', 'OUTPUT_WVP = ' + OUTPUT_WVP)
                .replace('OUTPUT_VZN = FALSE', 'OUTPUT_VZN = ' + OUTPUT_VZN)
                .replace('OUTPUT_HOT = FALSE', 'OUTPUT_HOT = ' + OUTPUT_HOT)
                .replace('OUTPUT_OVV = FALSE', 'OUTPUT_OVV = ' + OUTPUT_OVV), end='')
        return;

