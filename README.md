# PlotPulse - R Edition

## Regression Diagnostics Visualizer

**PlotPulse** is a comprehensive R package designed to simplify and enhance the visualization of regression diagnostics for linear, generalized linear, and mixed-effects models. With easy-to-use functions and support for both static and interactive plots, PlotPulse enables users to quickly assess model performance and identify potential issues in their regression analyses.

### Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Interactive Plots](#interactive-plots)
  - [Saving Plots](#saving-plots)
- [Plot Types](#plot-types)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)

### Features

- **Supports multiple model types**: Works with `lm`, `glm`, and `lme4` models.
- **Multiple diagnostic plots**: Generate residual plots, QQ plots, scale-location plots, Cook's distance plots, and more.
- **Interactive plotting**: Leverage `ggplot2` and `plotly` to create interactive diagnostic plots.
- **Customizable**: Fine-tune your plots with various parameters and theme options.
- **Save plots**: Save your diagnostic plots directly to a file with customizable dimensions and formats.

### Installation

To install PlotPulse, simply clone this repository and source the `plot_model` function directly:

```
# Clone the repository
git clone https://github.com/yourusername/PlotPulse-R.git

# Source the function
source("path_to_your_file/plot_model.R")
```

### Usage

#### Basic Usage

You can easily generate a variety of diagnostic plots using the `plot_model` function. Here are some examples:

```
# Load required libraries
library(ggplot2)
library(plotly)

# Create a linear model
model <- lm(mpg ~ wt, data = mtcars)

# Generate a residual plot
plot_model(model, plot_type = "residual")

# Generate a QQ plot
plot_model(model, plot_type = "qq")
```

#### Interactive Plots

For more dynamic analysis, you can generate interactive plots using the `interactive` parameter:

```
# Generate an interactive Cook's distance plot
plot_model(model, plot_type = "cooks", interactive = TRUE)
```

#### Saving Plots

Save your plots for reporting or further analysis with the `save_path` parameter:

```
# Save a residual plot to a file
plot_model(model, plot_type = "residual", save_path = "plots/residual_plot.pdf", create_dir = TRUE)
```

### Plot Types

PlotPulse supports the following diagnostic plots:

- **Residual Plot**: Visualizes the residuals against fitted values.
- **QQ Plot**: Assesses the normality of residuals.
- **Scale-Location Plot**: Checks the spread of residuals against fitted values.
- **Cook's Distance Plot**: Identifies influential data points.
- **Residuals vs Leverage Plot**: Detects potential outliers.
- **Cook's Distance vs Leverage Plot**: Combines Cook's distance with leverage.

### Customization

PlotPulse allows you to customize various aspects of the plots. You can modify plot titles, axis labels, themes, and more:

```
plot_params <- list(
  main = "Custom Title",
  xlab = "Custom X-axis Label",
  ylab = "Custom Y-axis Label",
  theme = theme_light()
)

plot_model(model, plot_type = "residual", plot_params = plot_params, color = "red")
```

### License

PlotPulse is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
