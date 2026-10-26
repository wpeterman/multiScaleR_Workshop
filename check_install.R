## =============================================================================
## check_install.R: run this before the workshop (about 30 seconds)
##
## 1. Open workshop.Rproj in RStudio (this sets the working directory), and
##    start from a fresh R session (Session > Restart R).
## 2. Run: source("check_install.R")
## 3. You should see "Ready for the workshop" at the end. If you see an error,
##    copy it into an email to the instructors.
## =============================================================================

cat("R version:", R.version.string, "\n")
if (getRversion() < "4.5.0") stop("Please update R to version 4.5 or later.", call. = FALSE)

## Everything comes from CRAN. The author's r-universe repository (ready-built
## Windows and macOS binaries) is listed as a fallback in case CRAN has not yet
## updated multiScaleR; install.packages() takes the highest version available,
## and CRAN wins a tie.
repos <- c("https://cloud.r-project.org", "https://wpeterman.r-universe.dev")
pkgs  <- c("multiScaleR", "terra", "sf", "readxl", "MASS", "unmarked")

## Check what is installed without loading anything, so an update can replace it
installed <- vapply(pkgs, function(p) nzchar(system.file(package = p)), logical(1))
need <- pkgs[!installed]
if (installed[["multiScaleR"]] && packageVersion("multiScaleR") < "0.7.2") {
  need <- c(need, "multiScaleR")
}
if (length(need) > 0) {
  message("Installing: ", paste(need, collapse = ", "))
  install.packages(need, repos = repos)
}

source("00_setup.R")

ram_gb <- tryCatch({
  if (.Platform$OS.type == "windows") {
    out <- system2("powershell", c("-NoProfile", "-Command",
                   "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"),
                   stdout = TRUE)
    as.numeric(gsub("\\D", "", out[1])) / 1024^3
  } else if (file.exists("/proc/meminfo")) {
    as.numeric(gsub("\\D", "", grep("MemTotal", readLines("/proc/meminfo"), value = TRUE))) / 1024^2
  } else {
    as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1024^3
  }
}, error = function(e) NA)
if (is.finite(ram_gb)) {
  cat(sprintf("Installed RAM: %.0f GB%s\n", ram_gb,
              if (ram_gb < 7.5) "  (8 GB or more is recommended; close other programs during the workshop)" else ""))
}

## A one-second multiscale optimization on the workshop data
t0 <- Sys.time()
ki  <- kernel_prep(cam_sf, urb, max_D = 1000, kernel = "gaussian",
                   verbose = FALSE, store_cell_data = FALSE)
dat <- data.frame(visits = site_data$cat, n_weeks = site_data$n_weeks, ki$kernel_dat)
mod <- glm.nb(visits ~ urb_pca + offset(log(n_weeks)), data = dat)
opt <- multiScale_optim(mod, ki, verbose = FALSE)
sigma_hat <- summary(opt)$opt_scale$Mean[1]
cat(sprintf("Test optimization finished in %.0f s (domestic cat sigma = %.0f m; expected about 57 m).\n",
            as.numeric(difftime(Sys.time(), t0, units = "secs")), sigma_hat))

if (abs(sigma_hat - 57) < 5) {
  cat("\nReady for the workshop.\n")
} else {
  cat("\nThe test ran but returned an unexpected value. Please email the instructors.\n")
}
