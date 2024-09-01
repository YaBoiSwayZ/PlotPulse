library(ggplot2)
library(plotly)
library(randomForest)
library(e1071)
library(rpart)
library(pdp)

# Helper function to log messages
log_message <- function(message, verbose = TRUE) {
  if (verbose) {
    cat(sprintf("[%s] %s\n", Sys.time(), message))
  }
}

# Helper function to save the plot
save_plot <- function(save_path, create_dir, figsize) {
  dir_name <- dirname(save_path)
  if (!dir.exists(dir_name)) {
    if (create_dir) {
      dir.create(dir_name, recursive = TRUE)
      log_message(sprintf("Directory created: %s", dir_name))
    } else {
      warning("The directory specified in save_path does not exist. The plot will not be saved.")
      log_message("Failed to save plot - directory does not exist")
      return(FALSE)
    }
  }
  dev.copy2pdf(file = save_path, width = figsize[1], height = figsize[2])
  dev.off()
  log_message(sprintf("Plot saved to %s", save_path))
  return(TRUE)
}

# Helper function for decision boundary plot
plot_decision_boundary <- function(model, X, y, color = "blue", plot_params = list()) {
  grid_range <- apply(X, 2, range)
  grid <- expand.grid(
    X1 = seq(grid_range[1, 1], grid_range[2, 1], length.out = 200),
    X2 = seq(grid_range[1, 2], grid_range[2, 2], length.out = 200)
  )
  grid$Prediction <- predict(model, grid)

  p <- ggplot(grid, aes(x = X1, y = X2)) +
    geom_tile(aes(fill = Prediction), alpha = 0.3) +
    geom_point(data = as.data.frame(X), aes(x = X[, 1], y = X[, 2], color = y)) +
    scale_color_manual(values = plot_params$boundary_colors) +
    ggtitle("Decision Boundary") +
    labs(x = plot_params$xlab, y = plot_params$ylab) +
    plot_params$theme

  if (plot_params$contour) {
    p <- p + geom_contour(aes(z = as.numeric(Prediction)), color = "black")
  }

  return(p)
}

# Main plotting function
plot_model <- function(
  model, 
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
  ...
) {
  log_message("Starting plot_model function", verbose)
  
  if (!inherits(model, c("lm", "glm", "lme4", "randomForest", "svm", "rpart"))) {
    stop("This function supports objects of class 'lm', 'glm', 'lme4', 'randomForest', 'svm', and 'rpart'. Please provide a valid model object.")
  }
  
  valid_plot_types <- c("residual", "qq", "scale_location", "cooks", "residual_leverage", "cooks_leverage", "partial_dependence", "decision_boundary")
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
    theme = theme_minimal(),
    boundary_colors = c("red", "blue"),
    contour = TRUE
  )
  
  plot_params <- modifyList(default_params, plot_params)
  
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  
  tryCatch({
    plot_data <- data.frame(
      Fitted = if (inherits(model, "randomForest")) predict(model, X) else fitted(model),
      Residuals = if (inherits(model, "randomForest")) y - predict(model, X) else residuals(model),
      StdResiduals = if (inherits(model, c("lm", "glm", "lme4"))) rstandard(model) else NULL,
      Leverage = if (inherits(model, c("lm", "glm", "lme4"))) hatvalues(model) else NULL,
      CookD = if (inherits(model, c("lm", "glm", "lme4"))) cooks.distance(model) else NULL
    )
    
    if (!interactive) {
      par(mfrow = c(2, 2), oma = c(0, 0, 2, 0))
      
      if (plot_type == "partial_dependence" && inherits(model, "randomForest")) {
        pd <- partial(model, pred.var = names(X), grid.resolution = 50, plot = TRUE)
        if (!is.null(save_path) && save_plot(save_path, create_dir, figsize)) {
          log_message("Returning plot object", verbose)
          return(invisible(recordPlot()))
        }
        
      } else if (plot_type == "decision_boundary" && inherits(model, "svm")) {
        plot(model, X, y)
        if (!is.null(save_path) && save_plot(save_path, create_dir, figsize)) {
          log_message("Returning plot object", verbose)
          return(invisible(recordPlot()))
        }
        
      } else {
        plot_number <- switch(
          plot_type,
          "residual" = 1,
          "qq" = 2,
          "scale_location" = 3,
          "cooks" = 4,
          "residual_leverage" = 5,
          "cooks_leverage" = 6
        )
        
        plot(
          model, 
          which = plot_number,
          main = plot_params$main, 
          xlab = plot_params$xlab,
          ylab = plot_params$ylab,
          ...
        )
        
        if (!is.null(save_path) && save_plot(save_path, create_dir, figsize)) {
          log_message("Returning plot object", verbose)
          return(invisible(recordPlot()))
        }
      }
      
    } else {
      log_message("Creating interactive plot", verbose)
      
      interactive_plot <- switch(
        plot_type,
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
          plot_params$theme,
        "partial_dependence" = if (inherits(model, "randomForest")) {
          pd <- partial(model, pred.var = names(X), grid.resolution = 50)
          ggplot(pd, aes(x = X, y = yhat)) + 
            geom_line(color = color, ...) + 
            ggtitle("Partial Dependence Plot") + 
            labs(x = plot_params$xlab, y = plot_params$ylab) + 
            plot_params$theme
        } else {
          stop("Partial dependence plots are only supported for 'randomForest' models.")
        },
        "decision_boundary" = if (inherits(model, "svm")) {
          plot_decision_boundary(model, X, y, color = color, plot_params = plot_params, ...)
        } else {
          stop("Decision boundary plots are only supported for 'svm' models.")
        }
      )
      
      interactive_plot <- ggplotly(interactive_plot, tooltip = c("x", "y", "text"))
      log_message("Returning interactive plot object", verbose)
      return(interactive_plot)
    }
  }, error = function(e) {
    log_message(sprintf("An error occurred: %s", e$message), verbose)
    stop(e)
  })
  
  log_message("plot_model function completed", verbose)
}