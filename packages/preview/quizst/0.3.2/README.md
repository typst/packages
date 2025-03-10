# Quizst

**Quizst** is a Typst template for creating beautiful Multiple Choice Question (MCQ) exam papers. It supports both standalone quizzes and structured educational content, with full compatibility with [ZagazogaWebApp](https://muhammadaly11.github.io/ZagazogaWebApp/).

## Features

- **Multiple Quiz Formats**:
  - Lesson Mode: Structured format for educational content with module, subject, and lesson organization
  - Custom Mode: Flexible format for standalone quizzes with optional categorization
- **Professional Layout**:
  - Clean, academic design
  - Automatic answer grid generation
  - Optional answer highlighting
  - Support for up to 7 options per question
- **ZagazogaWebApp Integration**:
  - Direct compatibility with ZagazogaWebApp's JSON output
  - Seamless workflow from quiz creation to PDF generation
- **Flexible Configuration**:
  - Customizable paper size
  - Author information with links
  - Source attribution for questions

## Quiz Formats

### Lesson Mode
Perfect for educational content with structured organization:

```json
{
  "type": "lesson",
  "module": "Medical Sciences",
  "subject": "Cardiology",
  "lesson": "Heart Anatomy",
  "questions": [
    {
      "sn": "1",
      "source": "Basic Anatomy",
      "question": "Which chamber of the heart receives deoxygenated blood?",
      "answer": "b",
      "a": "Left Atrium",
      "b": "Right Atrium",
      "c": "Left Ventricle",
      "d": "Right Ventricle"
    }
  ]
}
```

### Custom Mode
Flexible format for standalone quizzes:

```json
{
  "type": "custom",
  "title": "Programming Basics",
  "module": "Computer Science",
  "tags": ["programming", "beginners"],
  "questions": [
    {
      "sn": "1",
      "source": "Variables",
      "question": "What is a variable?",
      "answer": "b",
      "a": "A fixed value",
      "b": "A container for data",
      "c": "A function",
      "d": "A language"
    }
  ]
}
```

## Usage

### Using the Template

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for Quizst.

Alternatively, use the CLI:

```sh
typst init @preview/Quizst
```

### Basic Example

```typst
#import "@preview/Quizst:0.1.0": quiz

#let json_data = json("quiz.json")

#show: quiz.with(
  highlight-answer: true,
  json_data: json_data,
)
```

### With ZagazogaWebApp

1. Create your quiz using [ZagazogaWebApp](https://muhammadaly11.github.io/ZagazogaWebApp/)
2. Export to JSON
3. Use the JSON with Quizst to generate a PDF

## Configuration

The `quiz` function accepts:

- `json_data`: Quiz data in ZagazogaWebApp-compatible format
- `highlight-answer`: Boolean to show/hide correct answers
- `paper-size`: Page format (default: "a4")
- `authors`: Optional array of author information

## Examples

Check the `template/input/` directory for example quizzes in both Lesson and Custom modes.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! Please fork and submit pull requests.

## Acknowledgements

- Thanks to the Typst community
- Special thanks to [ZagazogaWebApp](https://muhammadaly11.github.io/ZagazogaWebApp/) ([GitHub](https://github.com/MuhammadAly11/ZagazogaWebApp)) for quiz creation integration