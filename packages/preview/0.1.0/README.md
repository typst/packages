# ocean-report-crs
This is the official Typst template for Cyclone RoboSub (CRS) @ UC Davis. The organization and logo name found at the bottom right of the document can be modified to fit other organizations.

## Usage
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `ocean-waves`.

Alternatively, you can use the CLI to kick this project off using the command
```shell
typst init @preview/ocean-report-crs:0.1.0
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
- `title`: The title of your document. 
- `subtitle`: The subtitle of your document. Can be used to put authors
- `org`: Your organization. Affects the document author and text in bottom-right corner. 
    - By default, this is set to "Cyclone RoboSub @ UC Davis". Simply type in your own organization's name to change it. 
- `logo`: Path to logo image file. 
    - By default, this is set to the Cyclone RoboSub logo. Simply type in the path to your own logo image to change it. 

## Example
```typst
#import "@preview/ocean-report-crs:0.1.0": *

#show: report.with(
  title: "This is the Title",
  subtitle: "This is the Subtitle",
  // org: "Add your own ord here!",
  // logo: "Add the path to your own logo file here!",
)

// Add your content below to get started!

= Heading

#lorem(100)

== Sub Heading
#lorem(50)
```

## Future Works
- Adjust logo placement so that it scales with paper size and margin
- Add unique table settings
