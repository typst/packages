# Business Report 

This is a business report template in Typst. In can be included in your project with  `#import "@preview/biz-report:0.3.0"`
            
## Components

There are currently four components, although requests are welcome:

- report: the main template of a front and back page, table of contents and page headers. Tables are alternating rows of theme coloured cells.
- authorwrap: Allows you to put an author image to the right of a paragraph. The image is clipped into a theme coloured circlet.
- dropcappara: a paragraph style where the first sentence is in theme colour, and first character is a dropped capital.
- infobox: a full width pull out box with a default caution marker that can be over-riden with other font awesome characters. Uses a lighten tint of the theme colour.

## Dependencies

Typst must of course be installed (https://typst.app/open-source#download).There is also a web app available to at the same website. 

The template makes use of font awsome which must be installed on the local machine if you use infoboxes. Font Awesome (free version): https://fontawesome.com/download

## Helping develop the template

If you want to obtain the source code of this package or contribute to its development, clone the following Git repository: 
https://github.com/garethwebber/business-report

It is recommended to use Visual Studio code to edit the library. It can manage the connection to
the git repository and if you install _Tintmist Typst_ as a module you will get auto complete, syntax highlighting, and best of all, 
live preview. https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist

![Screenshot of welcome page](thumbnail.png)
