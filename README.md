# Example Quarto website

<!-- badges: start -->
<!-- badges: end -->

This repository provides an example Quarto website for a small-scale Digital Humanities project. It is meant to be used as an example for [History 5444: Digital History Methods (Spring 20026)](https://jessesadler.github.io/vt5444s26/).

## Set up files
- `geo-data.R`: Creates the data used for the website.
  - Shows download and projection of raster data using [terra](https://rspatial.github.io/terra/index.html) and [elevatr](https://github.com/USEPA/elevatr) and vector data with [sf](https://r-spatial.github.io/sf/index.html) and [rnaturalearth](https://docs.ropensci.org/rnaturalearth/index.html).
- `_quarto.yml`: Configuration file for the website. It outlines the [structure of the website](https://quarto.org/docs/websites/website-navigation.html). The two main options are sidebars or a top navbar. Quarto documents are placed in order on one or the other to define the location of webpages on the site. The configuration file can also set website-wide options for the webpages.
  - Structure of website with navbar.
  - Options for all pages and theme.
  - Setting up [citations and bibliography](https://quarto.org/docs/authoring/citations.html).
- `styles.scss`: Styling sheet to provide some [customized styling options](https://quarto.org/docs/output-formats/html-themes.html#sass-variables) for the website.
  - Add a font from Google fonts: <https://fonts.google.com>
  - Use the font for headings.
  - Change colors for headings, the navbar, and links.
  - Make the base text larger.

## Website content
- `index.qmd`: Homepage for the website.
- Menu of pages with bios of the women discussed on the site.
- Historical context page.
- Visualizing the movements page. Visualizes movements using a tidygraph network in a geospatial setting.
- About page
  - Includes bibliography

