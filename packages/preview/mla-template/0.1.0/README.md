# mla-template
A typst template for use in MLA formats.

## Usage

### Method 1: Using typst init (Recommended)

Initialize a new project using this template:

```bash
typst init @preview/mla-template
```

Or specify a custom directory name:

```bash
typst init @preview/mla-template my-paper
```

### Method 2: Manual import

Import the template in your Typst document:

```typst
#import "@preview/mla-template:0.1.0": *

#show: mla.with(
  title: "Your Paper Title",
  author: "Your Name",
  professor: "Professor Name",
  course: "Course Name",
  date: datetime.today(),
)

// Your content here
```

