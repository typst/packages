# KTH Thesis Proposal Template

[![Typst Package](https://img.shields.io/badge/typst-package-239dad)](https://typst.app/universe/package/kth-thesis-proposal)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

A clean, professional Typst template for KTH degree project proposals with the official KTH logo and all required sections.

## Features

- ✨ Clean, professional layout matching official KTH requirements
- 📋 All 13 required proposal sections pre-structured
- 🎨 Official KTH logo on cover page
- 📝 Easy to customize with clear placeholder text
- 🚀 Simple API - just import and fill in your content

## Preview

The template generates a professional proposal with:
- **Page 1**: Clean cover page with KTH logo and "DEGREE PROJECT PROPOSAL" title
- **Page 2+**: All required sections with clear labels and proper formatting

## Quick Start

### Using Typst CLI

```bash
# Initialize a new project with this template
typst init @preview/kth-thesis-proposal my-proposal
cd my-proposal

# Compile your proposal
typst compile main.typ
```

### Using Typst Web App

1. Go to [Typst Universe](https://typst.app/universe/package/kth-thesis-proposal)
2. Click "Create project in app"
3. Start editing!

### Manual Setup

Create a new `.typ` file:

```typst
#import "@preview/kth-thesis-proposal:0.1.0": proposal, section

#show: proposal

#section("Name and e-mail address of the student")[
  Your Name \
  your.email\@kth.se
]

#section("Thesis title")[
  Your preliminary thesis title here
]

#section("Background")[
  Describe the research area, how the project connects to current research,
  why it's interesting, and the organization's interest in it.
]

// ... continue with other sections
```

## Required Sections

The template includes all 13 official KTH degree project proposal sections:

1. **Name and e-mail address of the student**
2. **Thesis title** - Preliminary title indicating the project scope
3. **Background** - Research area, connections, and interest
4. **Research question** - Specific research/technical question to investigate
5. **Hypothesis** - Expected outcome of the investigation
6. **Research method** - Method for answering the research question
7. **Background of the student** - Relevant knowledge and experience
8. **Supervisor at the company/external organization** *(if applicable)*
9. **Suggested examiner at KTH**
10. **Suggested supervisor at KTH**
11. **Resources** - Available resources at the host institution
12. **Eligibility** - Verification of eligibility requirements
13. **Study planning** - Remaining courses and completion plan

## Usage Example

```typst
#import "@preview/kth-thesis-proposal:0.1.0": proposal, section

#show: proposal

#section("Name and e-mail address of the student")[
  Jane Doe \
  jane.doe\@kth.se
]

#section("Thesis title")[
  Machine Learning Approaches for Sustainable Energy Optimization
]

#section("Background")[
  This project is carried out within the field of sustainable energy systems,
  focusing on the application of machine learning to optimize energy consumption
  in smart buildings. The project connects to current research in both AI and
  sustainability, addressing the growing need for energy-efficient solutions.
  
  The project is of interest to both the academic community and industry
  partners working on smart city initiatives. Company X is particularly
  interested in this research as it aligns with their sustainability goals.
]

#section("Research question")[
  Can machine learning models accurately predict and optimize energy consumption
  patterns in commercial buildings to reduce overall energy usage by at least 20%?
]

// ... continue with remaining sections
```

## Development

Want to contribute or modify the template locally?

```bash
# Clone the repository
git clone https://github.com/cseas002/kth-thesis-proposal.git
cd kth-thesis-proposal

# Install locally for testing
# (if you have MacOS), otherwise change the script to use your package directory
./install-local.sh

# Compile the example
typst compile example/main.typ
```

## File Structure

```text
kth-thesis-proposal/
├── src/
│   ├── lib.typ          # Main template file
│   └── assets/          # KTH logo and other assets
├── example/
│   └── main.typ         # Complete example with all sections
├── typst.toml           # Package metadata
├── README.md            # This file
└── LICENSE              # MIT License
```

## License

This template is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute it.

## Acknowledgments

- Inspired by KTH's official degree project proposal requirements
- Built with [Typst](https://typst.app/)

## Support

- **Issues**: [GitHub Issues](https://github.com/cseas002/kth-thesis-proposal/issues)
- **Discussions**: [GitHub Discussions](https://github.com/cseas002/kth-thesis-proposal/discussions)
- **Typst Universe**: [Package Page](https://typst.app/universe/package/kth-thesis-proposal)

---