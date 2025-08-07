library(fs)

images <- dir_ls("media", type = "file")

files <- dir_ls(".", recurse = FALSE, regexp = "qmd$")

in_file <- function(file, image) {
  any(stringr::str_detect(readr::read_lines(file), image))
}

in_files <- function(image, files) {
  any(purrr::map_lgl(files, in_file, image = image))
}

purrr::map_lgl(images, in_files, files) |>
  purrr::keep(isFALSE)
