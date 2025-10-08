# University Assignment Template

A flexible Typst template for university assignments, lab reports, and homework with a clean, professional layout.

## Features

- **Clean, Professional Layout**: Modern design perfect for academic submissions
- **Customizable Assignment Details**: Support for course info, instructors, due dates, hardware/software used, and more
- **Automatic Table of Contents**: Generated from your document structure
- **Styled Elements**: Beautiful code blocks, headings, quotes, and lists
- **Flexible Configuration**: Choose which details to include based on your assignment type

## Installation

### From Typst Package Registry
```typst
#import "@preview/academic-alt:0.1.0": *
```

### Local Usage
For users who want to edit the template source:
1. Download or clone this repository
2. Copy `lib.typ` to your project directory
3. Import in your Typst file:
```typst
#import "lib.typ": *
```

## Usage

```typst
#import "@preview/academic-alt:0.1.0": *

#show: university-assignment.with(
  title: "Lab 3: GPIO Control",
  subtitle: "Embedded Systems Programming",
  author: "Your Name",
  details: (
    course: "ECSE 303",
    instructor: "Prof. Smith",
    due-date: "September 19, 2025",
    hardware: "Raspberry Pi, LED, 220Ω resistor",
    software: "Python (RPi.GPIO), C (WiringPi)",
    duration: "~3 hours",
  )
)

= Introduction
Your content here...

= Methodology
Describe your approach here.

= Results
Present your findings.

= Conclusion
Summarize your work.
```

## Available Detail Fields

The `details` dictionary accepts any combination of these optional fields:

| Field | Description | Example |
|-------|-------------|---------|
| `course` | Course code or name | `"ECSE 303"` |
| `supervisor` | Lab supervisor name | `"Dr. Johnson"` |
| `instructor` | Course instructor | `"Prof. Smith"` |
| `professor` | Professor name | `"Dr. Williams"` |
| `due-date` | Assignment deadline | `"September 19, 2025"` |
| `hardware` | Hardware components used | `"Arduino Uno, sensors"` |
| `software` | Software/languages used | `"Python, MATLAB"` |
| `duration` | Estimated completion time | `"~2 hours"` |
| `lab-number` | Lab or assignment number | `"Lab 3"` |
| `partner` | Lab partner name | `"Jane Doe"` |
| `section` | Course section | `"Section A"` |

## Examples

### Lab Report
```typst
#show: university-assignment.with(
  title: "Digital Logic Design Lab",
  subtitle: "Combinational Circuits",
  author: "John Doe",
  details: (
    course: "EE 241",
    instructor: "Prof. Anderson",
    lab-number: "Lab 2",
    due-date: "March 15, 2025",
    hardware: "Logic gates, breadboard, LEDs",
    software: "Logisim",
    duration: "4 hours",
    partner: "Jane Smith",
  )
)
```

### Homework Assignment
```typst
#show: university-assignment.with(
  title: "Problem Set 5",
  subtitle: "Linear Algebra",
  author: "Alice Johnson",
  details: (
    course: "MATH 240",
    professor: "Dr. Brown",
    due-date: "February 28, 2025",
    software: "MATLAB, Python",
    section: "Section 2",
  )
)
```

### Research Project
```typst
#show: university-assignment.with(
  title: "Machine Learning Applications",
  subtitle: "Computer Vision Research",
  author: "Bob Wilson",
  details: (
    course: "CS 7641",
    supervisor: "Dr. Garcia",
    due-date: "April 30, 2025",
    software: "Python, TensorFlow, OpenCV",
    duration: "2 weeks",
  )
)
```

## Customization

The template uses Typst's theming system, so you can customize colors and styling by overriding the theme variables:

```typst
#set text(fill: rgb("#2c3e50"))
#set par(justify: true)
#set heading(numbering: "1.")
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Typst](https://typst.app/)
- Inspired by academic document standards
- Community feedback and suggestions
