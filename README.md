# PlotPulse - R Edition

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage](#usage)
   - [Basic Example](#basic-example)
   - [Supported Plot Types](#supported-plot-types)
   - [Customizing Plots](#customizing-plots)
   - [Interactive Plots](#interactive-plots)
   - [Handling Complex Models](#handling-complex-models)
5. [Logging](#logging)
6. [Contributing](#contributing)
7. [License](#license)
8. [Acknowledgments](#acknowledgments)

---

## Overview

**PlotPulse** is an R package designed to streamline the process of visualizing regression diagnostics for various model types, including linear models, generalized linear models, random forests, and support vector machines. It provides a collection of functions that generate common diagnostic plots such as residual plots, QQ plots, scale-location plots, Cook's distance plots, and more. PlotPulse also supports the visualization of decision boundaries and partial dependence plots for machine learning models, enhancing the interpretability of complex models.

## Features

- **Support for Multiple Model Types**: `lm`, `glm`, `randomForest`, `svm`, and `rpart` models are supported.
- **Comprehensive Plotting Options**: Generate a variety of diagnostic plots such as:
  - Residual Plot
  - QQ Plot
  - Scale-Location Plot
  - Cook's Distance Plot
  - Residuals vs. Leverage Plot
  - Partial Dependence Plot (for random forests)
  - Decision Boundary Plot (for SVMs)
- **Interactive Plots**: Create interactive visualizations using `plotly`.
- **Customizable**: Fine-tune the appearance and behavior of plots with extensive customization options.
- **Plot Saving Functionality**: Save your plots directly to a file with the ability to create directories as needed.

## Installation

To install and load PlotPulse, use the following commands:

```r
# Install from GitHub (example)
# install.packages("devtools")
# devtools::install_github("yourusername/PlotPulse")

# Load the library
library(ggplot2)
library(plotly)
library(randomForest)
library(e1071)
library(rpart)
library(pdp)
```

## Usage

### Basic Example

To get started, fit a model and pass it to the `plot_model` function:

```r
# Example with linear model
model <- lm(mpg ~ wt, data = mtcars)
plot_model(model, plot_type = "residual")
```

### Supported Plot Types

- **Residual Plot**: Visualizes residuals vs fitted values.
- **QQ Plot**: Compares the distribution of standardized residuals with a normal distribution.
- **Scale-Location Plot**: Checks the homoscedasticity assumption.
- **Cook's Distance Plot**: Identifies influential observations.
- **Residuals vs. Leverage Plot**: Examines influential data points.
- **Partial Dependence Plot**: Shows the effect of a variable on the prediction (for random forests).
- **Decision Boundary Plot**: Visualizes the decision boundary of SVM models.

### Customizing Plots

You can customize the appearance and save the plots:

```r
plot_model(
  model, 
  plot_type = "residual", 
  color = "darkred", 
  plot_params = list(
    main = "Customized Residual Plot",
    xlab = "Fitted Values",
    ylab = "Residuals",
    theme = theme_classic()
  ),
  save_path = "plots/residual_plot.pdf",
  create_dir = TRUE
)
```

### Interactive Plots

Enable interactive plots with `interactive = TRUE`:

```r
interactive_plot <- plot_model(model, plot_type = "qq", interactive = TRUE)
interactive_plot
```

### Handling Complex Models

For more complex models like random forests and SVMs, you can specify additional parameters:

```r
# Random Forest Partial Dependence Plot
model_rf <- randomForest(mpg ~ wt + hp, data = mtcars)
plot_model(model_rf, X = mtcars[, c("wt", "hp")], plot_type = "partial_dependence")

# SVM Decision Boundary Plot
model_svm <- svm(Species ~ ., data = iris)
plot_model(model_svm, X = iris[, -5], y = iris$Species, plot_type = "decision_boundary")
```

## Logging

PlotPulse includes a logging utility that provides detailed messages about the process. This can be enabled or disabled through the `verbose` parameter:

```r
plot_model(model, plot_type = "residual", verbose = TRUE)
```

## Contributing

Contributions to PlotPulse are welcome! If you have ideas for improvements or have found bugs, feel free to create an issue or submit a pull request on GitHub.

## License

PlotPulse is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

PlotPulse uses several powerful R packages under the hood, including `ggplot2`, `plotly`, `randomForest`, and `e1071`. Thanks to the authors and contributors of these packages for their excellent work.
