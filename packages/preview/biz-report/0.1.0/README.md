# Business Report 

This is a business report template in Typst

![Screenshot of welcome page](thumbnail.png)

## Location

If you want to obtain the source code of this package or contribute to its development, clone the following Git repository: 

https://github.com/garethwebber/business-report

## Editing

It is recommended to us Visual Studio code to edit the document. It can manage the connection to
the git repository and if you install _Tintmist Typst_ as a module you will get auto complete, syntax highlighting, and best of all, live preview. https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist

## Dependencies

Typst must of course be installed (https://typst.app/open-source#download).There is also a web app available to at the same website. The template makes use of two fonts which must be installed on the local machine:

- Font Awesome (free version): https://fontawesome.com/download
- Arial (I assume you have this, and you can override it)

## Supporting tools 

- Producing final output is done on the command line typst compile main.typ
- Live-edit.sh will give you live previewing providing you have zathura.
- Spell-check.sh will run ispell with a custom dictionary (dictionary.txt) over all the chapters
