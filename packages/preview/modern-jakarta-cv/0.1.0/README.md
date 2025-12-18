# Modern Jakarta CV Template

A high-performance CV template for Typst designed for Marketing, Business, and Growth professionals. This template prioritizes information density and modern aesthetics through advanced vertical spacing and clean typography.

## Technical Features

### Layout Optimization
The template utilizes a specialized `project_entry` function with a negative vertical offset of -0.45em. This allows for high information density, enabling users to fit extensive professional backgrounds into a single-page document without compromising readability.

### Typography and Visual Identity
- **Font Family**: Built using the Inter font family, optimized for both digital viewing and high-quality print.
- **Color Palette**: Features a professional burgundy accent (#802020) for section headers and horizontal separators.

### Interactive Elements
All header information, including GitHub, LinkedIn, and Portfolio links, are configured as active hyperlinks, ensuring a seamless experience for recruiters reviewing the PDF digitally.

## Getting Started

### Official Import
To use this template officially via the Typst Universe, include the following snippet at the beginning of your file:

```typst
#import "@preview/modern-jakarta-cv:0.1.0": *
#show: project
