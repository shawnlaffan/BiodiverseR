    gp_lb <- c(
        "50:50" = c(label1 = 1, label2 = 1),
       "150:150" = c(label1 = 1, label2 = 1)
   )

    oneshot_data <- c(
        bd = c(
            params = c(name = "ironman", cellsizes = c(100, 100)),
            data = gp_lb
        ),
        analysis_config = c(
            calculations = c("calc_endemism_central")
        )
    )