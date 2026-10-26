# multiScaleR Workshop: Multiscale Ecological Modeling in R

**Bill Peterman and Joseph Drake**, The Ohio State University
The Wildlife Society Annual Conference, Wednesday, November 4, 2026, 8:00 to 12:00

A half-day, hands-on workshop on estimating species-specific scales of effect with the [`multiScaleR`](https://github.com/wpeterman/multiScaleR) R package. The worked example uses camera-trap data from 207 sites across the Cleveland Metroparks (Moll et al. 2020). Participants estimate scales of effect with kernel-weighted covariates, diagnose results they should not trust, extend the analysis to landscape metrics (categorical land cover) and surface metrics (continuous rasters), map the fitted models, and start on their own data.

---

## Schedule

| Time | Block | Notebook | Topics |
|------|-------|----------|--------|
| 8:00 to 8:45 | 1. Scale, kernels, and landscape pattern | `01_background_setup.qmd` | Lecture; the data; kernels vs buffers |
| 8:45 to 9:00 | Break | | |
| 9:00 to 9:45 | 2. The core workflow | `02_core_workflow.qmd` | Cat, chipmunk, and deer; profiles; screened starts |
| 9:45 to 10:00 | Break | | |
| 10:00 to 10:45 | 3. Beyond the mean | `03_landscape_pattern.qmd` | `msr_vars()`; landscape metrics (opossum); surface metrics (deer) |
| 10:45 to 11:00 | Break | | |
| 11:00 to 11:45 | 4. Maps, other models, your data | `04_maps_models_your_data.qmd` | Projection and clamping; occupancy; open work |
| 11:45 to 12:00 | Open discussion | | Questions and one-on-one help |

---

## Before the workshop

1. **Install R 4.5 or later** and a recent RStudio.
2. **Install the packages** (all on CRAN; no Rtools or GitHub install needed):

   ```r
   install.packages(c("multiScaleR", "terra", "sf", "readxl", "MASS", "unmarked"))
   ```

   `multiScaleR` 0.7.2 or later is required (0.7.2 is the current CRAN release).
3. **Download this repository**: the green **Code > Download ZIP** button, then unzip. Everything, including the data, is in the ZIP.
4. **Open `workshop.Rproj`** in RStudio, then run:

   ```r
   source("check_install.R")
   ```

   It installs anything missing, runs a one-second test optimization, and ends with "Ready for the workshop." If it does not, email the instructors the error message.

**Hardware:** 8 GB of RAM is enough for every step if you restart R at the start of each block (see below); R then stays under about 3 GB. Close web browsers and other large programs during the workshop.

---

## Using the notebooks

Open a notebook and run its chunks in order (`Ctrl+Enter`, or `Cmd+Enter` on a Mac). Each notebook starts with `source("00_setup.R")`, which loads the packages, data, and helpers in a few seconds. The notebooks set `eval: false`, so clicking Render will not rerun the analyses; run them chunk by chunk instead.

**Start each block in a fresh R session.** Before opening the next notebook, restart R (RStudio: **Session > Restart R**). R holds on to memory it has used. In our tests, running all four blocks in one session peaked near 4 GB, and restarting before each block kept every block under 3 GB.

**Checkpoints.** Blocks 2 and 3 end by saving their fitted models to `checkpoints/`, and the setup chunk of the next block loads them automatically after a restart. If R crashes, or you join late, restart R and run the setup chunk of the block you are on. The repository ships with our checkpoints, so any block can be started from scratch.

**Rendered versions.** `html/` holds two versions of each notebook, viewable in any browser without R:

- `Full_Eval__*.html`: every chunk run, with all output and figures
- `Code_Only__*.html`: code and text only, a clean reference while you work

---

## Repository contents

```
multiScaleR_Workshop/
├── README.md
├── workshop.Rproj
├── check_install.R                  # run before the workshop
├── 00_setup.R                       # sourced by every notebook
├── 01_background_setup.qmd          # Block 1
├── 02_core_workflow.qmd             # Block 2
├── 03_landscape_pattern.qmd         # Block 3
├── 04_maps_models_your_data.qmd     # Block 4
├── Moll_et_al_2020_Ecography.pdf    # source paper (open access)
├── data/
│   ├── camera_locations.xlsx        # camera coordinates (summer and winter sheets)
│   ├── summer_counts.rds            # 207 cameras x 18 weeks x 14 species
│   ├── winter_counts.rds            # 104 cameras x 22 weeks x 14 species
│   ├── urb_pca.tif                  # PCA urbanization index, 30 m, cropped to the study area
│   └── landcover6.tif               # six-class land cover from the 2016 Annual NLCD
├── checkpoints/
│   ├── block2.rds                   # fitted models saved at the end of Block 2
│   └── block3.rds                   # fitted models saved at the end of Block 3
├── html/                            # rendered notebooks (full output and code only)
└── images/
```

---

## Data

The detections, camera locations, and PCA urbanization raster come from the Dryad archive of Moll et al. (2020), <https://doi.org/10.5061/dryad.brv15dv5j>. `urb_pca.tif` is the published raster cropped to the camera footprint plus 15 km, with its layer renamed `urb_pca`. `landcover6.tif` reclassifies the 2016 Annual NLCD land cover into water, developed open space, developed low to high intensity, forest, open and agricultural, and wetland, masked to the same extent; Block 1 documents the reclassification.

The 14 species, in the order of the third dimension of the count arrays, are domestic cat, eastern chipmunk, coyote, white-tailed deer, fox squirrel, eastern gray squirrel, mustelid sp., Virginia opossum, eastern cottontail, raccoon, red fox, red squirrel, striped skunk, and woodchuck.

---

## References

Moll, R. J., J. D. Cepek, P. D. Lorch, P. M. Dennis, T. Robison, and R. A. Montgomery. 2020. At what spatial scale(s) do mammals respond to urbanization? *Ecography* 43:171-183. <https://doi.org/10.1111/ecog.04762>

Peterman, W. E. 2026. multiScaleR: a generalizable approach for multiscale ecological modeling and scale of effect estimation. *Landscape Ecology* 41:8. <https://doi.org/10.1007/s10980-025-02267-x>
