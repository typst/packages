# Modern WKU Thesis Templates

A Typst template for graduate thesis at Wenzhou-Kean University Computer Science and Mathematics department.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `modern-wku-thesis`.

Alternatively, you can use the CLI to kick this project off using the command:

```bash
typst init @preview/modern-wku-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `graduate-thesis` function with the following named arguments:

- **title**: The title of the thesis
- **author**: Author name (e.g., "John Doe" or "John Doe, Jane Smith" for multiple authors)
- **degree**: Degree type (default: `MS of Computer Information Systems`)
- **department**: Department name (default: `Department of Computer Science and Technology`)
- **university**: University name (default: `Wenzhou-Kean University`)
- **supervisor**: Supervisor name (e.g., "Dr. John Doe" or "Dr. John Doe, Dr. Jane Smith" for multiple supervisors)
- **month**: Graduation month (default: `December`)
- **year**: Graduation year (default: `2023`)
- **degree_year**: Year of degree completion (default: `2023`)
- **program_type**: Program type (default: `Master of Science`)
- **degree_type**: Degree type (default: `Master`)
- **degree_department**: Department for degree (default: `Computer Science and Technology`)
- **abstract**: The abstract content (use empty lines for paragraph breaks)
- **keywords**: Keywords separated by semicolons (e.g., "keyword1; keyword2; keyword3")
- **acknowledgments**: Acknowledgments content (use empty lines for paragraph breaks)
- **acronyms**: Dictionary of acronyms (e.g., `("TMS": "Traceability Management System")`)
- **bibliography**: Bibliography using IEEE style (e.g., `bibliography("refs.bib")`)

The function also accepts a single, positional argument for the body of the thesis.

## Example

```typ
#import "@preview/modern-wku-thesis:0.1.0": graduate-thesis

#show: graduate-thesis.with(
  title: [Automatic Visualization of Traceability Information],
  author: "Cheng Bao",
  degree: [MS of Computer Information Systems],
  department: [Department of Computer Science and Technology],
  university: [Wenzhou-Kean University],
  supervisor: [Dr. Nasser Mustafa],
  month: [December],
  year: [2025],
  degree-year: [2025],
  program-type: [Master of Science],
  abstract: [
    Classical Traceability Management Systems (TMS) help track links between software parts like requirements, designs, code, and test cases.

    This study proposes an improved Traceability Management System for software engineering processes.
  ],
  keywords: [Traceability; Automatic; Regular Expression; Visualization; TMS.],
  acknowledgments: [
    I would like to express my sincere gratitude to my supervisor for their invaluable guidance.

    Special thanks to my family and friends for their unwavering support.
  ],
  bibliography: bibliography("refs.bib"),
  acronyms: (
    "TMS": "Traceability Management System",
    "RE": "Regular Expression",
    "CSV": "Comma-Separated Values",
  ),
)

= Introduction

Your thesis content goes here...

= Literature Review

More content...

= Methodology

Even more content...
```

## Features

- Compliant with Wenzhou-Kean University thesis formatting requirements
- Automatic generation of cover page, abstract, acknowledgments, and acronyms list
- IEEE bibliography style
- Proper heading numbering and formatting
- Table and figure caption styling
- Professional layout and typography

## Requirements

- Typst 0.11.0 or later
- A `.bib` file for references (if using bibliography)

## License

This template is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve this template.

## Acknowledgments

This template was created for students at Wenzhou-Kean University's Computer Science and Mathematics department to help streamline the thesis writing process.
