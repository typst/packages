# Typst2Anki

![Demo Video](assets/typst2anki.gif)

**Typst2Anki** is a tool designed to integrate flashcard creation seamlessly into your Typst-based notes. By utilizing a custom Typst package, you can create cards directly in your notes and sync them effortlessly to a selected Anki deck. This enables you to transform study material into flashcards without disrupting your Typst workflow.

- Create flashcards directly within your Typst documents.
- Sync these flashcards to a chosen Anki deck effortlessly.
- Streamlined workflow for note-taking and spaced repetition learning.

---

## Table of Contents

1. **[Installation and Configuration](#installation-and-configuration)**
   - [Installing AnkiConnect](#installing-ankiconnect)
   - [Installing the Python Package](#installing-the-python-package)
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

### Installing AnkiConnect

1. Open Anki and navigate to **Tools > Add-ons**.
2. Click **Get Add-ons** and enter the following code to install AnkiConnect:
   ```
   2055492159
   ```
   Alternatively, visit the [AnkiConnect Add-on page](https://ankiweb.net/shared/info/2055492159) to learn more.
3. Restart Anki to activate the add-on.
4. Verify that AnkiConnect is running by visiting [http://localhost:8765](http://localhost:8765) in your browser. If it loads, the add-on is properly installed and functioning.

---

### Installing the Python Package

1. Make sure Python 3.8+ is installed on your system.
2. Install the Typst2Anki package using pip:

   ```bash
   pip install typst2anki
   ```

3. Verify the installation:

   ```bash
   typst2anki --help
   ```

---

### Installing the Typst Package

1. Add the Typst2Anki package to your Typst document:

   ```typst
   #import "@preview/typst2anki:0.1.0"
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

### Basic Workflow

1. Create a Typst file with flashcards:

   ```typst
   #card(
     id: "001",
     target_deck: "Typst",
     Q: "What is Typst?",
     A: "A modern typesetting system."
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

3. Use Typst2Anki to compile all files in the project directory:

   ```bash
   typst2anki ./path/to/your/project
   ```

4. Open your Anki deck to check the newly added flashcards.

---

### Customizing Cards

To modify card appearance, you can define custom card logic:

   ```typst
   #let custom_card(
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
       show_labels: true
     )
   }
   ```

---

## Troubleshooting
### Common Issues

- **AnkiConnect not responding**:
  - Ensure Anki is running and AnkiConnect is installed correctly.

- **Typst file compilation errors**:
  - Check for syntax issues in your Typst file.
  - Ensure your `ankiconf.typ` contains the necessary imports and configurations.

---

## Roadmap

1. **Command to Delete Cards**: Implement a feature to remove specific cards from Anki.
2. **Efficiency Improvements**: Optimize the syncing process for speed and reliability.
3. **Support for Other Card Types**: Expand compatibility to include more complex card formats.

---

## Future Plans

- Enhance user experience with more robust error handling and syncing options.
- Broaden integration with Typst to support various output formats.

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests for bug fixes, feature enhancements, or documentation improvements.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

Developed with ❤️ by [sgomezsal](https://github.com/sgomezsal). Let’s make learning efficient and enjoyable!
