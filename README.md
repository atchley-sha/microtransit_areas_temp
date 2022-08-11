
# microtransit_areas

<!-- badges: start -->
<!-- badges: end -->

### Abstract
A number of regions have begun operating microtransit systems to support first
and last mile transit access.  In this paper, we modify the ridehailing request
handling algorithm in the BEAM microscopic simulation engine to accomodate
geographically resetricted microstransit operations. We then examine the
ridership operating characteristics for one existing and three proposed
geofenced service regions in Salt Lake County, Utah. We find that the simulation
generates realistic ridership statistics and wait times, subject to errors
likely to be corrected with more thorough choice model calibration. We also
found that expanding microtransit services to Sandy or West Jordan might be
effective, but might be less so for the area near SLC International Airport.

## Reprodution

This repository uses the Git Large File System (`git-lfs`) to store large BEAM
simulation results. To clone this repository with these resources, ensure that
you have `git-lfs` installed on your system. Then, execute the following shell 
commands

```sh
git clone https://atchley-sha/microtransit_areas
cd microtransit_areas
git lfs install
git lfs pull
```
