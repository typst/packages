= Methodology <methodology>

== Template Structure

This template follows a modular approach to document organization, separating content from formatting. The key components include:

=== Main Template File
The `template/main.typ` file contains all formatting definitions, including:
- Page layout and margins (3.5cm on all sides)
- Header and footer configuration
- Chapter and section styling
- Custom commands and environments
You can access all functionality provided by this file by importing it directly from the typst template repository: (adjust the version number as needed)
```typ
#import "@preview/unibas-thesis:0.1.0": *
```

=== Configuration
The template is configured through parameters passed to the `thesis` function in your main document:
```typ
#show: thesis.with(
  title: "Your Title",
  author: "Your Name",
  // ... other parameters
)
```

This approach ensures consistency across all theses while allowing customization where needed. The template automatically handles language-specific elements (English/German) based on your language setting.
