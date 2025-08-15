# About
This is a small template for writing reports tailored to the most common needs at NTNU in Norway.
Note that many subjects have their own requirements for styling, this template is compatible with the requirements for TTK4101 in 2025.

# Future plans
- It would be neat to add an appendix system at some point.
- I do not plan to expand the template to handle a full thesis, the "nifty-ntnu-thesis" seems to solve this already.

# Configuration
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
- bibfile: Optional parsed bibfile on the form bibliography("path"), required for bibliography.
- bibstyle: Optional string, defaults to "institute-of-electrical-and-electronics-engineers". Many subjects require "american-psychological-association"
- language: Optional string, defaults to "bokmål". One of english, bokmål or nynorsk.
- column-number: Optional int, default 1.
- show-toc: Optional bool, default true. Determines if table of content is printed, only relevant for long reports
- show-figure-index: Optional bool, default false. Determines if list of figures is printed, only relevant for long reports
- show-table-index: Optional bool, default false. Determines if list of indices is printed, only relevant for long reports


# Quality of life
The package supplies `<nonumber>`tag, headings tagged with this will not get a number. They still appear in the table of content.

The package allso localizes number formats correctly, use the `num` function from the `zero` pacage imported wiht `#import "@preview/zero:0.3.3": num`.

# License
The boiler plate template located in the template folder is licensed under the MIT No Attribution license, the rest of this project is licensed under the GNU Affero General Public License v3.0 or later.
The logo of NTNU (located at template/figures/NTNU.svg) is owned by NTNU, guidelines for usage is located at https://i.ntnu.no/wiki/-/wiki/Norsk/Bruksregler+for+NTNU-logoen.
