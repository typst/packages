# Unoficcial template for reports at NTNU

## About
This is a small template for writing reports tailored to the most common needs at NTNU in Norway, the goal is to cover everything from exercises to specialization projects.
Note that many subjects have their own requirements for styling, this template is compatible with the requirements for TTK4101 in 2025 and 2026.

## Future plans
- It would be neat to add an appendix system at some point.
- I do not plan to expand the template to handle a full master thesis, the "nifty-ntnu-thesis" seems to solve this already.

## Configuration
The template takes the following arguments:
- length: Optional string, defaults to "short", can be short or long.
- watermark: Optional string, stamps a watermark across all pages.
- title: Required string.
- subtitle: Optional string.
- authors: List of dictionaries, each requires name, each may contain department, organization, location and email.
- group: Optional string, for when group numbers are needed.
- front-image: Optional image content for front page. Only works with long length.
- date: Optional timestamp, will override the current date on the front page.
- abstract: Optional content.
- appendices: Optional content.
- bibfile: Optional parsed bibfile on the form bibliography("path"), required for bibliography.
- bibstyle: Optional string, defaults to "institute-of-electrical-and-electronics-engineers". Many subjects require "american-psychological-association".
- language: Optional string, defaults to "bokmål". One of english, bokmål or nynorsk.
- column-number: Optional int, default 1.
- number-headings: Optional bool, default true. Determines if headings are numbered.
- show-toc: Optional bool, default true. Determines if table of content is printed, only relevant for long reports.
- show-figure-index: Optional bool, default false. Determines if list of figures is printed, only relevant for long reports.
- show-table-index: Optional bool, default false. Determines if list of indices is printed, only relevant for long reports.
- show-listings-index: Optional bool, default false. Determines if list of listings is printed, only relevant for long reports.

## Quality of life
In adition to the template function, this package allso supplies the `un` function, which formats units propperly with a tiny space and no cursive in math mode.
It is intentionally much more lightweight than packages such as **unify**.

The package supplies `<nonumber>`tag, headings and equations tagged with this will not get a number. They still appear in the table of content.

The package allso localizes number formats correctly, use the `num` function from the `zero` pacage imported wiht `#import "@preview/zero:0.5.0": num`.

The codly and codly-languages packages are used to format listings in a nice and readable way.

## Recommended packages
There are a lot of useful features in other packages that are not reimplemented or preconfigured in this package, here are some recommendations that might be useful for NTNU students:
- **subpar** is good for making subfigures, and should be compatible with this template.
- **wordometer** counts words, but is not preconfigured here since the specifics often vary from subject to subject.
- **meander** seams like a good package for non-standard layout requirements.
- **cetz** is good for drawing custom graphics, and is used by packages like **alchemist**, **commute** and **finite**. Remember that many tasks are easily solved with paint.
- **frame-it** creates nice frames for theorems, examples and similar.
- **physica** and **pavemat** solves most missing features in math typesetting.


## License
The boiler plate template located in the template folder is licensed under the MIT No Attribution license, the rest of this project is licensed under the GNU Affero General Public License v3.0 or later.

The logo of NTNU (located at template/figures/NTNU.svg) is owned by NTNU, guidelines for usage is located at https://i.ntnu.no/wiki/-/wiki/Norsk/Bruksregler+for+NTNU-logoen.
The unoficcial logo for ITK at NTNU (located at template/figures/ITK_logo.svg) is owned by Trond Andresen and distributed with permission, more information can be found at https://www.ntnu.no/itk/om/historie/itk-60/jubileumsmotiv.
