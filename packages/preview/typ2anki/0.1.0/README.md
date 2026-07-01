# Typ2Anki

**Typ2Anki** is a Typst package designed to create flashcards seamlessly within Typst-based notes. This package enables users to structure flashcards directly in their documents for easy integration with study and review workflows.

- Create customizable flashcards using Typst syntax.
- Supports structured note-taking with consistent flashcard styling.
- Ideal for educational and professional use.

---

## Table of Contents

1. **[Installation and Configuration](#installation-and-configuration)**

   - [Installing the Typst Package](#installing-the-typst-package)

2. **[Usage](#usage)**

   - [Basic Workflow](#basic-workflow)
   - [Customizing Cards](#customizing-cards)

3. **[Troubleshooting](#troubleshooting)**

   - [Common Issues](#common-issues)

4. **[Roadmap](#roadmap)**

5. **[Future Plans](#future-plans)**

6. **[Contributing](#contributing)**

7. **[License](#license)**

---

## Installation and Configuration

### Complete Integration

To fully utilize Typ2Anki, ensure you follow the installation instructions for the Python package available at [https://github.com/sgomezsal/typ2anki](https://github.com/sgomezsal/typ2anki).

### Installing the Typst Package

1. Add the Typ2Anki package to your Typst document:

   ```typst
   #import "@preview/typ2anki:0.1.0"
   ```

2. Place your custom configuration file (`ankiconf.typ`) in the project directory for consistent flashcard rendering.

   ```typst
   // Custom imports for flashcards
   #import "@preview/pkgs"

   #let conf(
     doc,
   ) = {
     // Custom configurations
     doc
   }
   ```

---

## Usage

### Examples

For detailed examples, visit the [examples folder](https://github.com/sgomezsal/typ2anki/tree/main/examples) in the original repository.

### Important Note

For full functionality, this Typst package requires the complementary Python package. Installation and usage instructions can be found at [https://github.com/sgomezsal/typ2anki](https://github.com/sgomezsal/typ2anki).

### Basic Workflow

1. Create a Typst file with flashcards:

   ```typst
   #card(
     id: "001",
     target-deck: "Typst",
     q: "What is Typst?",
     a: "A modern typesetting system."
   )
   ```

2. Create your `ankiconf.typ` file with basic configurations:

   ```typst
   // Custom imports for flashcards
   #import "@preview/pkgs"

   #let conf(
     doc,
   ) = {
     // Custom configurations
     doc
   }
   ```

3. Compile your Typst document using Typst's built-in commands to render the flashcards.

---

### Customizing Cards

To modify card appearance, you can define custom card logic:

```typst
#let custom-card(
  id: "",
  Q: "",
  A: "",
  ..args
) = {
  card(
    id: id,
    Q: Q,
    A: A,
    container: true,
    show-labels: true
  )
}
```

---

## Troubleshooting

### Common Issues

- **Typst file compilation errors**:
  - Check for syntax issues in your Typst file.
  - Ensure your `ankiconf.typ` contains the necessary imports and configurations.

---

## Roadmap

1. **Support for Advanced Flashcard Formats**: Add enhanced support for multi-part and hierarchical flashcards.
2. **Efficiency Improvements**: Optimize rendering for large Typst projects with numerous flashcards.
3. **Integration Enhancements**: Explore integration with additional Typst features for more dynamic output.

---

## Future Plans

- Expand compatibility to support more flashcard types.
- Introduce configuration options for easier customization of flashcard styles.

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests for bug fixes, feature enhancements, or documentation improvements.

---

## License

This project is licensed under the [MIT License](LICENSE).

### Icon License

This project uses the "cards" icon from [Phosphor Icons](https://phosphoricons.com/), which is licensed under the [MIT License](https://opensource.org/licenses/MIT).
Phosphor Icons is an open-source and flexible icon library, allowing free use, modification, and distribution in personal and commercial projects.

---

Developed with ❤️ by [sgomezsal](https://github.com/sgomezsal). Let’s make learning efficient and enjoyable!
