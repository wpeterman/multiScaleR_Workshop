## =============================================================================
## 00_setup.R: shared setup for every block of the multiScaleR workshop
##
## Each notebook starts with source("00_setup.R"). The script loads the
## packages, checks the multiScaleR version, reads the camera data and the two
## landscape rasters, and defines three small helpers for saving and loading
## checkpoints between blocks. Running it takes a few seconds.
## =============================================================================

## Packages ---------------------------------------------------------------------
pkgs <- c("multiScaleR", "terra", "sf", "readxl", "MASS", "unmarked")
missing_pkgs <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Install these packages first:\n  install.packages(c(\"",
       paste(missing_pkgs, collapse = "\", \""), "\"))", call. = FALSE)
}
suppressPackageStartupMessages(
  invisible(lapply(pkgs, library, character.only = TRUE))
)
## The notebooks were built on the 0.7.2 CRAN release. Builds older than 0.7.1
## lack `kernel_dist(dimension = "2d")`. From 0.7.4 the default reporting
## distance switches to 2D; the notebooks pass `dimension` explicitly, so
## they read the same on either side of that change.
if (packageVersion("multiScaleR") < "0.7.2" ||
    !"dimension" %in% names(formals(multiScaleR::kernel_dist))) {
  stop("This workshop needs multiScaleR 0.7.2 or later (on CRAN). Restart R ",
       "(RStudio: Session > Restart R), then run:\n",
       "  install.packages(\"multiScaleR\")", call. = FALSE)
}

## Paths ------------------------------------------------------------------------
## The notebooks expect R's working directory to be the workshop folder (the one
## holding this script and workshop.Rproj). If this script was sourced from
## another folder, move to the script's own folder so the relative paths below
## resolve; otherwise stop with directions.
if (!file.exists(file.path("data", "urb_pca.tif"))) {
  script_dir <- local({
    f <- NULL
    for (i in rev(seq_len(sys.nframe()))) {
      f <- sys.frame(i)$ofile
      if (!is.null(f)) break
    }
    if (is.null(f)) NULL else dirname(normalizePath(f))
  })
  if (!is.null(script_dir) &&
      file.exists(file.path(script_dir, "data", "urb_pca.tif"))) {
    setwd(script_dir)
    message("Working directory set to the workshop folder: ", script_dir)
  } else {
    stop("Cannot find data/urb_pca.tif from the working directory
  ", getwd(),
         "
Open workshop.Rproj (the folder holding 00_setup.R), or setwd() to ",
         "that folder, then source this script again.", call. = FALSE)
  }
  rm(script_dir)
}
DATA_DIR       <- "data"
CHECKPOINT_DIR <- "checkpoints"
dir.create(CHECKPOINT_DIR, showWarnings = FALSE)

## Landscape rasters (terra SpatRaster objects, 30 m cells, Albers equal area) --
## urb_pca: first principal component of NLCD 2016 developed, forest, and
##          impervious-surface layers (Moll et al. 2020). High values = developed,
##          low values = forest. Lake Erie is NA.
## landcover: six-class reclassification of the 2016 Annual NLCD land cover,
##          masked to the same extent as urb_pca.
urb       <- rast(file.path(DATA_DIR, "urb_pca.tif"))
landcover <- rast(file.path(DATA_DIR, "landcover6.tif"))

landcover_classes <- data.frame(
  value = 1:6,
  class = c("Water", "Developed, open space", "Developed, low to high intensity",
            "Forest", "Open and agricultural", "Wetland"),
  nlcd  = c("11", "21", "22, 23, 24", "41, 42, 43", "31, 52, 71, 81, 82", "90, 95")
)
landcover_colors <- c("#4f79a7", "#c7c7c7", "#b04a3b", "#2e6b34", "#d9c27a", "#7fb3a8")

## Binary developed layer (open space plus low to high intensity), used in Block 3
developed <- mask(as.int(landcover %in% c(2, 3)), landcover)
names(developed) <- "developed"

## Camera locations (sf points, reprojected from WGS84 to the raster CRS) --------
cams   <- read_excel(file.path(DATA_DIR, "camera_locations.xlsx"), sheet = "summer")
cam_sf <- st_transform(
  st_as_sf(cams, coords = c("longitude", "latitude"), crs = 4326),
  crs(urb)
)

## Detections: 207 cameras x 18 weeks x 14 species (summer 2016) ---------------
summer <- readRDS(file.path(DATA_DIR, "summer_counts.rds"))

species <- data.frame(
  code = c("cat", "chipmunk", "coyote", "deer", "fox_squirrel", "gray_squirrel",
           "mustelid", "opossum", "cottontail", "raccoon", "red_fox",
           "red_squirrel", "skunk", "woodchuck"),
  name = c("Domestic cat", "Eastern chipmunk", "Coyote", "White-tailed deer",
           "Fox squirrel", "Eastern gray squirrel", "Mustelid sp.",
           "Virginia opossum", "Eastern cottontail", "Raccoon", "Red fox",
           "Red squirrel", "Striped skunk", "Woodchuck")
)

## Site-level data: total visits per species and weeks of effort per camera.
## A week counts only if the camera ran the whole week (NA otherwise).
visits <- sapply(seq_len(nrow(species)),
                 function(i) rowSums(summer[, , i], na.rm = TRUE))
colnames(visits) <- species$code
n_weeks <- apply(summer[, , 1], 1, function(r) sum(!is.na(r)))

site_data <- data.frame(camera = cams$camera_id, n_weeks = n_weeks, visits)

## Prediction extent: the camera footprint plus 2.5 km (keeps maps light) ------
pred_ext <- ext(vect(cam_sf)) + 2500

## Checkpoint helpers ------------------------------------------------------------
## save_checkpoint("block2", opt_cat, opt_deer) writes checkpoints/block2.rds.
## Name an argument to store it under that name: save_checkpoint("b", fit = lighten_fit(fit)).
## load_checkpoint("block2") restores those objects into your session.
save_checkpoint <- function(name, ...) {
  objs <- list(...)
  arg_names <- vapply(as.list(substitute(list(...)))[-1], deparse, character(1))
  given <- names(objs)
  names(objs) <- if (is.null(given)) arg_names else ifelse(nzchar(given), given, arg_names)
  saveRDS(objs, file.path(CHECKPOINT_DIR, paste0(name, ".rds")))
  message("Saved checkpoint '", name, "': ", paste(names(objs), collapse = ", "))
  invisible(names(objs))
}

load_checkpoint <- function(name) {
  f <- file.path(CHECKPOINT_DIR, paste0(name, ".rds"))
  if (!file.exists(f)) stop("No checkpoint named '", name, "' in ", CHECKPOINT_DIR, call. = FALSE)
  objs <- readRDS(f)
  list2env(objs, envir = globalenv())
  message("Loaded from checkpoint '", name, "': ", paste(names(objs), collapse = ", "))
  invisible(names(objs))
}

## Slow fits. Block 3 has two joint fits that take about 1.5 minutes each. By
## default the notebook loads our saved fits from checkpoints/block3.rds. Run
## `run_slow_fits <- TRUE` after sourcing this script to refit them live; the
## render script sets the environment variable MSR_RUN_SLOW_FITS=TRUE instead.
run_slow_fits <- isTRUE(as.logical(Sys.getenv("MSR_RUN_SLOW_FITS", "FALSE")))

## Landscape and surface-metric fits keep every extracted cell (tens of MB).
## lighten_fit() drops those cells but keeps what summary(), aic_tab(), and
## kernel_scale.raster() need. profile_sigma() and refitting need the full fit.
lighten_fit <- function(fit) {
  fit$kernel_inputs$d_list  <- NULL
  fit$kernel_inputs$raw_cov <- NULL
  fit
}

message("Setup complete: multiScaleR ", packageVersion("multiScaleR"), ", ",
        nrow(site_data), " cameras, ", nrow(species), " species.")
