# Ornacover

A Typst package designed to create professional, ornamental covers for educational documents and booklets, especially tailored for mathematics teachers and academic use.

## Prerequisites (Important)
This package relies on the **"CornPop"** font for the ornamental graphics to function correctly. 

- **Download Link:** [Click here to download the CornPop font](https://www.dafont.com/cornpop.font)
- **Installation:** After downloading, please install the font on your system, or place the font file in your project directory and use it via the `font-family` parameter.

## Examples & Usage

### 1. Portrait Layout
To set up your page with an ornamental background in Portrait orientation, use the following code:

```typst
#import "@preview/ornacover:0.1.0": ornacover-portrait, ornacover-landscape

#set page(
  paper: "a4",
  background: ornacover-portrait(
  )
)
```
### 2. Landscape Layout
```typst
#import "@preview/ornacover:0.1.0": ornacover-portrait, ornacover-landscape

#set page(
  paper: "a4",
  flipped: true,
  background: ornacover-landscape(
  )
)

```
#### Features
#### 1. Dual Layout Support: Includes specific functions for both Portrait and Landscape documents.

#### 2. Highly Customizable: Easily adjust colors, decorative characters, and font families to match your specific style.

#### 3. High-Quality Graphics: Built on top of the powerful cetz library for precise, crisp vector artwork.
