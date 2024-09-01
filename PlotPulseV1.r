library(ggplot2)
library(plotly)

plot_model <- function(model, 
                       y = NULL, 
                       X = NULL, 
                       plot_type = "residual", 
                       figsize = c(10, 6), 
                       color = "blue", 
                       save_path = NULL, 
                       plot_params = list(), 
                       interactive = FALSE, 
                       verbose = TRUE, 
                       create_dir = FALSE, 
                       ...) {
  
  log_message <- function(message) {
    if (verbose) {
      cat(sprintf("[%s] %s\n", Sys.time(), message))
    }
  }
  
  log_message("Starting plot_model function")
  
  if (!inherits(model, c("lm", "glm", "lme4"))) {
    stop("This function supports objects of class 'lm', 'glm', and 'lme4'. Please provide a valid model object.")
  }
  
  valid_plot_types <- c("residual", "qq", "scale_location", "cooks", "residual_leverage", "cooks_leverage")
  if (!plot_type %in% valid_plot_types) {
    stop(paste("Unsupported plot_type. Choose from:", paste(valid_plot_types, collapse = ", ")))
  }
  
  if (!is.numeric(figsize) || length(figsize) != 2) {
    stop("figsize must be a numeric vector of length 2.")
  }
  
  if (!is.character(color) || length(color) != 1) {
    stop("color must be a single character string.")
  }
  
  default_params <- list(
    main = "", 
    xlab = "X-axis", 
    ylab = "Y-axis",
    theme = theme_minimal()
  )
  
  plot_params <- modifyList(default_params, plot_params)
  
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  
  tryCatch({
    plot_data <- data.frame(
      Fitted = fitted(model),
      Residuals = residuals(model),
      StdResiduals = rstandard(model),
      Leverage = hatvalues(model),
      CookD = cooks.distance(model)
    )
    
    if (!interactive) {
      par(mfrow = c(2, 2), oma = c(0, 0, 2, 0))
      
      plot_number <- switch(plot_type,
                            "residual" = 1,
                            "qq" = 2,
                            "scale_location" = 3,
                            "cooks" = 4,
                            "residual_leverage" = 5,
                            "cooks_leverage" = 6)
      
      plot(model, 
           which = plot_number,
           main = plot_params$main, 
           xlab = plot_params$xlab,
           ylab = plot_params$ylab,
           ...)
      
      if (!is.null(save_path)) {
        dir_name <- dirname(save_path)
        if (!dir.exists(dir_name)) {
          if (create_dir) {
            dir.create(dir_name, recursive = TRUE)
            log_message(sprintf("Directory created: %s", dir_name))
          } else {
            warning("The directory specified in save_path does not exist. The plot will not be saved.")
            log_message("Failed to save plot - directory does not exist")
            return()
          }
        }
        dev.copy2pdf(file = save_path, width = figsize[1], height = figsize[2])
        dev.off()
        log_message(sprintf("Plot saved to %s", save_path))
      }
      
      log_message("Returning plot object")
      return(invisible(recordPlot()))
      
    } else {
      log_message("Creating interactive plot")
      
      interactive_plot <- switch(plot_type,
        "residual" = ggplot(plot_data, aes(Fitted, Residuals)) +
          geom_point(color = color, ...) + 
          ggtitle("Residual Plot") + 
          labs(x = plot_params$xlab, y = plot_params$ylab) + 
          plot_params$theme,
        "qq" = ggplot(plot_data, aes(sample = StdResiduals)) +
          geom_qq(color = color, ...) + 
          geom_qq_line(color = "red") + 
          ggtitle("QQ Plot") + 
          labs(x = plot_params$xlab, y = plot_params$ylab) + 
          plot_params$theme,
        "scale_location" = ggplot(plot_data, aes(Fitted, sqrt(abs(StdResiduals)))) +
          geom_point(color = color, ...) + 
          ggtitle("Scale-Location Plot") + 
          labs(x = plot_params$xlab, y = plot_params$ylab) + 
          plot_params$theme,
        "cooks" = ggplot(plot_data, aes(seq_along(CookD), CookD)) +
          geom_bar(stat = "identity", color = color, ...) + 
          ggtitle("Cook's Distance Plot") + 
          labs(x = plot_params$xlab, y = plot_params$ylab) + 
          plot_params$theme,
        "residual_leverage" = ggplot(plot_data, aes(Leverage, StdResiduals)) +
          geom_point(color = color, ...) + 
          ggtitle("Residuals vs Leverage Plot") + 
          labs(x = plot_params$xlab, y = plot_params$ylab) + 
          plot_params$theme,
        "cooks_leverage" = ggplot(plot_data, aes(Leverage, CookD)) +
          geom_point(color = color, ...) + 
          ggtitle("Cook's Distance vs Leverage Plot") + 
          labs(x = plot_params$xlab, y = plot_params$ylab) + 
          plot_params$theme
      )
      
      interactive_plot <- ggplotly(interactive_plot, tooltip = c("x", "y", "text"))
      log_message("Returning interactive plot object")
      return(interactive_plot)
    }
  }, error = function(e) {
    log_message(sprintf("An error occurred: %s", e$message))
    stop(e)
  })
  
  log_message("plot_model function completed")
}
