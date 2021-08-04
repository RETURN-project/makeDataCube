# Status report

## Current status

- `makeDataCube` is now working properly on `Spider`.
- GitHub actions manages to install a minimal version of `makeDataCube`.
  - What do I mean with minimal? A version with the minimal amount of external dependencies in order to be installable and testable.
- I've increased the test coverage a bit.
- I've rewritten the parameter generator function from `Python` into `R`.
  - And now we can use lists instead of long lines of parameters.

## Things that can still be improved

### Functionality

- At the moment, the output of `makeDataCube` is not transferred to `dCache`. This should be relatively quick to implement:
  - Minimum: copy contents without overwriting.
  - Better: minimum + concatenate queue files.
  - Optimum: better + summarize log files.
- Some processes can be further optimized.
  - For instance, the metadata `csv` files could be downloaded only once instead of once per process. Anyways, this download is really fast.
- Some functions still use several parameters instead of lists.

### Usability

- The installation cannot be fully automated.
  - `gsutil` requires interactive installation. Or at least, we didn't find an automated / scripted alternative.
  - The `.netrc` file, which contains credentials for accessing different services, has to be generated interactively. Luckily, this has to be only once.
  - The same is true for the `.boto` and `.laads` files, but I am not sure if they are really needed.
- The package is heavy. A minimal installation takes around 45 minutes.
  - Most of the time is invested in installing `R` dependencies. Probably we do not need all of them.
- Some of the functions can be further simplified.
- The workflow is intrinsically very complex. The main danger I see is that it depends on a lot of external services that cannot be frozen into a `Singularity` image. I am afraid this package could be challenging to maintain in the long term.
