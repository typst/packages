# Cheat Sheet

Colorful and organised cheatsheet template for [Typst](https://typst.app/) that allows you to make a overview of learning notes. Only one or few pages can cover all content about what you want to review and what you need to explore. This way make it convenient to the way of learning one technology and then getting a cheat sheet, and go on. 


![](thumbnail.png)

## Usage

To build this project via the CLI, use the command

```
typst init @preview/cheat-sheet
```

A sample project will be created with the template format.

## Configuration
### cheatsheet config
This template exports the `cheatsheet` function using the `a4` page with the following named optional
arguments:


- `title`: Title of document (Default = "")
- `homepage`: Homepage of author (Default = "")
- `authors`: Author Name (Default = "")
- `write_title`: Writes Title (Default = false)
- `title-align`: Position of titles (Default = center)
- `title-number`: Whether to numbered the title (Default = true)
- `title-delta`: Fonts delta for title scaling (Default = 1pt)
- `scaling-size`: Whether to scale the titles (Default = false)
- `font_size`: Size of font (Default = 5.5pt)
- `line_skip`: Size of line-skip (Default = 5.5pt)
- `x_margin`: Margin on x-axis (Default = 30pt)
- `y_margin`: Margin on y-axis (Default = 0pt)
- `num_columns`: Number of columns (Default = 5)
- `column_gutter`: Space between columns (Default = 4pt)
- `numbered_units`: Numbering of units (Default = false)

### cheatsheet_scaling config
In this template we add the extral parameters to adjust the page size and keep other parameters same.

- `page-w`: The width of page (Default = auto)
- `page-h`: The height of page (Default = auto)

### concept-block
This is a bounding box with automatical colors according to top level titles that can hold any text and image.

- `body`: Content to write (Required)
- `alignment`: Alignment of content (Default = start)
- `width`: Width of bounding box (Default = 100%)
- `fill_color`: Filling color of bounding box (Default = white)

### line title
This is a style placing subtitle in the middle of a colored line drawing more attention.

- `title`: Title to show (Required)

## Reference
+ [summy, Wasay Saeed @wasaysir](https://typst.app/universe/package/summy)