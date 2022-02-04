# Common problems

## The `DEM` chunk fails

The `DEM` chunk is one of the weakest links in the whole pipeline. Our experience is that the remote database often behaves in unexpected way. If no obvious error message appears, we suggest you to try again.

One common problem, though, is that the authentication file for NASA's Earth Data service, the `.netrc` file, is missing or incorrect. This error will pop-up a prompt asking for the username and password (corresponding to [earthdata.nasa.gov](https://urs.earthdata.nasa.gov/)).

### How to check if my `.netrc` file is ok

Browse to the `.netrc` file desired location (`~/.netrc` by default). Its contents should look like:

```
machine urs.earthdata.nasa.gov
login <your username>
password <your password>
```

If you don't have one, you can create an account and find your password at [urs.earthdata.nasa.gov](https://urs.earthdata.nasa.gov/).

## The `Landsat` chunk fails

The most common error is:

```
Error: gsutil config file was not found in .
```

This is easily solved by executing:

```
gsutil config
```

and following interactivelly the instructions.

This operation generates a `.boto` file (typically at `~`). This file can be copy-pasted in another machine, for instance a cluster, in order to use the proper gsutil configuration.

## The `WVP` chunk fails

Most likely you are missing the `.laads` authentication file. It is usually located at `~` , and it contains the App Key for LAADS Data (an hexadecimal string).

More information about how to get it [here](https://ladsweb.modaps.eosdis.nasa.gov/tools-and-services/data-download-scripts/#requesting).

## The `level2` chunk fails

Sometimes the `level2` chunk seems to have done nothing. This happens when a previous, data-retrieving step has failed without an error. Check the output of the previous steps, because most likely the problem is there (`DEM`, I'm looking at you).