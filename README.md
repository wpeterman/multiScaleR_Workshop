# multiScaleR Workshop: Multiscale Ecological Modeling in R

**Bill Peterman & Joseph Drake**

A half-day hands-on tutorial for identifying species-specific scales of effect using camera trap data and the [`multiScaleR`](https://github.com/wpeterman/multiScaleR) R package. The workshop uses real data from Moll et al. (2019, *Ecography*) — 207 camera trap sites across the Cleveland Metroparks urban park system — and three focal mammal species that illustrate contrasting patterns of habitat response.

---

## Workshop Overview

| Section | Topic | Time |
|---------|-------|------|
| 1 | Setup and prerequisites | 15 min |
| 2 | What is a scale of effect? | 20 min |
| 3 | Data loading and exploration | 25 min |
| 4 | Domestic cat: the full workflow | 40 min |
| 5 | Eastern chipmunk: a boundary case | 25 min |
| — | Break | 15 min |
| 6 | White-tailed deer: landscape-scale response | 30 min |
| 7 | Beyond the PCA: development and forest cover | 35 min |
| 8 | Spatial prediction | 25 min |
| 9 | Summary and next steps | 10 min |

### Focal Species

- **Domestic cat** — small-scale positive response to urbanization
- **Eastern chipmunk** — a boundary case that teaches diagnostic interpretation
- **White-tailed deer** — broad landscape-scale positive response to urbanization

By the end of the workshop, participants will be able to prepare spatial data for scale-of-effect analysis, optimize kernel scale parameters with `multiScaleR`, interpret results and diagnostic profiles (including boundary cases), extend analyses to individual NLCD land cover types, and project predictions across a landscape.

---

## Repository Contents

```
multiScaleR_Workshop/
├── multiScaleR_workshop.qmd          # Main tutorial file (Quarto)
├── Full_Eval__multiScaleR_workshop.html      # Rendered HTML — all code evaluated
├── TextCode_Only__multiScaleR_workshop.html  # Rendered HTML — code shown but not evaluated
├── Moll_et_al._2019--Ecography.pdf   # Source paper
├── workshop.Rproj                    # RStudio project file
├── data/
│   ├── camera_locations.xlsx         # Site coordinates (summer & winter sheets)
│   ├── summer_counts.rds             # 207 sites × 18 weeks × 14 species detection array
│   ├── urb_pca_na16.tif              # Composite urbanization PCA raster (NLCD 2016)
│   ├── developed_binary.tif          # Binary developed land cover raster
│   └── forested_binary.tif           # Binary forested land cover raster
├── precomputed/
│   ├── opt_cat_pca.rds               # Pre-optimized cat model (PCA covariate)
│   ├── opt_chipmunk_pca.rds          # Pre-optimized chipmunk model (PCA covariate)
│   ├── opt_chipmunk_nlcd.rds         # Pre-optimized chipmunk model (NLCD covariates)
│   ├── opt_deer_pca.rds              # Pre-optimized deer model (PCA covariate)
│   ├── opt_deer_nlcd.rds             # Pre-optimized deer model (NLCD covariates)
│   └── opt_deer_nlcd_seeded.rds      # Pre-optimized deer NLCD model (seeded starting values)
└── images/
    ├── cat.jpg
    ├── chipmunk.jpg
    └── deer.jpg
```

---

## Rendered HTML Files

Two pre-rendered HTML files are provided so you can follow along or review results without running any R code:

| File | Description |
|------|-------------|
| `Full_Eval__multiScaleR_workshop.html` | All code chunks evaluated — shows full outputs, figures, and model results |
| `TextCode_Only__multiScaleR_workshop.html` | Code is displayed but not evaluated — useful as a clean reference while working interactively |

Open either file in any web browser. No R installation is required to view them.

---

## Working Through the Tutorial Interactively

The tutorial is designed to be run chunk-by-chunk in RStudio using `multiScaleR_workshop.qmd`.

### Setup

1. Install required packages if you have not already:

```r
install.packages(c("terra", "sf", "readxl", "MASS", "ggplot2", "dplyr"))
remotes::install_github("wpeterman/multiScaleR")
```

`multiScaleR` >= 0.6.11 is required. **Minimum 8 GB RAM is recommended** — the deer analysis (Section 6) uses approximately 1.5 GB.

2. Open `workshop.Rproj` in RStudio. This sets the working directory correctly so all relative file paths resolve without modification.

3. Open `multiScaleR_workshop.qmd`. The `DATA_DIR` and `PRECOMP_DIR` variables at the top of the setup chunk point to `data/` and `precomputed/` respectively; update these only if you move files.

### Running Code

- Execute individual chunks with the green **Run** button or `Ctrl+Enter` / `Cmd+Enter` (Mac).
- Work through sections **in order** — later sections depend on objects created earlier.
- The tutorial document has `eval: false` set globally, so rendering the `.qmd` file will not re-run the analysis. Run chunks interactively instead.

### Pre-computed Results

Scale optimization can take several minutes. Each section that runs an optimization includes a **Pre-computed Fallback** block:

```r
opt_cat_pca <- readRDS(file.path(PRECOMP_DIR, "opt_cat_pca.rds"))
```

Load the pre-computed result and continue if you want to skip the optimization step or if it runs longer than expected.

---

## Reference

Moll, R. J., Cepek, J. D., Lorch, P. D., Dennis, P. M., Robison, T., Millspaugh, J. J., & Montgomery, R. A. (2019). What does urbanization actually mean? A framework for urban metrics in wildlife research. *Ecography*, 42(4), 816–829. https://doi.org/10.1111/ecog.03881
