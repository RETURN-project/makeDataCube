[![Build Status](https://travis-ci.com/RETURN-project/makeDataCube.svg?branch=master&status=started)](https://travis-ci.com/github/RETURN-project/makeDataCube)
[![codecov](https://codecov.io/gh/RETURN-project/makeDataCube/graph/badge.svg)](https://codecov.io/gh/RETURN-project/makeDataCube)
[![codecov](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/)

# makeDataCube
The makeDataCube R project generates a data cube from Landsat and Sentinel-2 data using FORCE and allows to generate and add a data mask to the data cube.

You can install it via:
```
library(devtools)
install_github("RETURN-project/makeDataCube")
```
## External dependencies
- [**Python 3**](https://www.python.org/downloads/) should be installed.
  - The [**pylandsat**](https://pypi.org/project/pylandsat/) and [**shapely**](https://pypi.org/project/Shapely/) modules should be available to download data. Both can be installed installed via `pip install pylandsat` and `pip install shaoely`.
- In addition, [**FORCE**](https://github.com/davidfrantz/force) should be installed. **FORCE** allows to generate a data cube of level-2 (or higher) Landsat and Sentinel-2 imagery from level-1 inputs. Please visit the [project's website](https://github.com/davidfrantz/force) for more information and download instructions. 
- The user should have a **NASA Earthdata account** to download DEM data. The _Login_, _Username_ and _Password_ are stored in a _netrc_ file in the home directory. If no _netrc_ file is found, you will be asked to provide your _Username_ and _Password_ and a _netrc_ file will automatically be created (and stored for a next session). If you don't have an account yet, you can create one [here](https://urs.earthdata.nasa.gov).
- Finally, you need authentication to download data from the LAADS DAAC (WVP data). To that end, you need an create a _.laads_ file is in your home directory with a an **App Key**. The **App Key** can be requested from [NASA Earthdata](https://ladsweb.modaps.eosdis.nasa.gov/tools-and-services/data-download-scripts/#requesting). This key should be stored in a file _.laads_ in your home directory.
