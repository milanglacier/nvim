# %%

dump.pkg <- function(pkg.name, is.appended = T) {
    library(pkg.name, character.only = TRUE)
    ls(paste0("package:", pkg.name)) %>%
        write(file = "r.dict", sep = "\n", append = is.appended)
}



# %%


# %%

dump.pkg("dplyr", F)
# %%

# %%

dump.pkg("ggplot2")
dump.pkg("base")
dump.pkg("stats")
dump.pkg("tidyr")
dump.pkg("purrr")
# %%

a <- 5
