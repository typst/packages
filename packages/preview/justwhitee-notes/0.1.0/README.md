# 📚 justwhitee-notes: university Notes Typst Template

A clean, minimal Typst template designed for university lecture notes and course handouts. Features a styled cover page, automatic table of contents, disclaimer page, and a rich set of callout components.

---

## 🚀 Getting Started

### 1. Import the template

```typst
#import "@preview/justwhitee-notes:0.1.0": *
```

You can initialize a new project with this template using the Typst CLI:
```bash
typst init @preview/justwhitee-notes
```

### 2. Initialize the document

Wrap your content with the `project` function:

```typst
#show: project.with(
  title: "Operating Systems",
  subject: "CS301",
  professor: "Prof. John Smith",
  author: "Your Name",
  logo-subject: image("imgs/course-logo.png"),       // optional
  logo-personal: image("imgs/my-logo.png"),          // optional
  year: "2024/2025",                          // optional, auto-generated if omitted
  bento-url: "https://bento.me/yourprofile",  // a page/website you would like to add (like bento, linktree, ...)
  paypal-url: "https://paypal.me/yourname",
  contact-url: "https://t.me/username",       // or a whatsapp/any message app link
  lang: "en",
)

// Your content goes here
= First Chapter
...
```

### Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `title` | string | ✅ | Document/notes title |
| `subject` | string | ✅ | Course code or subject name |
| `professor` | string | ✅ | Professor's name |
| `author` | string | ✅ | Your name |
| `logo-subject` | path | ❌ | Path to course/university logo image |
| `logo-personal` | path | ❌ | Path to your personal logo/avatar |
| `year` | string | ❌ | Academic year (e.g. `"2024/2025"`). Auto-generated if omitted |
| `bento-url` | string | ❌ | Your bento page URL |
| `paypal-url` | string | ❌ | PayPal link (shown on disclaimer page) |
| `contact-url` | string | ❌ | Link to report errors or contribute |
| `lang` | string | ❌ | The language of the document (default is English). |

---

## 🧩 Components

### Callout Boxes

Three pre-built callout styles for structuring your notes:

```typst
// Definition box (teal accent)
#def("Kernel")[
  The kernel is the core of an operating system...
]

// Important/Warning box (yellow accent)
#important("Key Concept")[
  This will definitely appear in the exam.
]

// Example box (gray accent)
#example("Scheduling Example")[
  Given processes P1, P2, P3...
]
```

You can also use the base `callout` function for full customization:

```typst
#callout(title: "Custom", icon: "🔥", color: rgb("#e74c3c"))[
  Custom callout content.
]
```

---

### Inline Annotations

Quick inline markers for annotating your notes:

```typst
#note[Pay attention to this detail.]        // 👉 Note: (yellow highlight)
#tip[This is a useful shortcut.]            // ✅ Tip: (teal highlight)
#problem[This approach has a flaw.]        // ❗️ Problem: (red highlight)
#why(title: "use threads")[Because...]     // 🤔 Why use threads? (purple highlight)
#how(title: "it works")[Step by step...]   // 👨🏻‍🏫 How it works? (blue highlight)
#extra[Side note or additional context.]    // Italic muted text, smaller size, margin notes, or for extra clarifications
```

---

### Inline Text Styles

```typst
#kw("keyword")              // Bold monospace keyword (accent color - teal by default)
#kw("error", color: danger) // With custom color

#hl("highlighted text")              // Highlighted monospace span (accent color - teal)
#hl("warning text", color: warning)  // With custom color
```

---

### Symbols

```typst
#so       // => (implication arrow)
#arrow    // -> (simple right arrow)
```

---

### Side Note Block

A left-bordered block for notes or asides:

```typst
#side-note[
  This is a side note or an important remark set apart from the body.
]
```

---

### Code Blocks

Code blocks are automatically styled — just use standard Typst raw blocks:

````typst
```python
def hello():
    print("Hello, world!")
```
````

Inline code is also styled automatically:

```typst
The `fork()` system call creates a new process.
```

---

### Image Cropping

Utility to crop images by hiding edges (not all sides are mandatory):

```typst
#crop(image("diagram.png"), top: 20pt, bottom: 10pt, left: 10pt, right: 50pt)
```

---

## 📄 Document Structure

The template automatically generates:

1. **Cover page** — title, subject, professor, author, logos, academic year
2. **Disclaimer page** — a standard disclaimer with contact/support links
3. **Table of Contents** — auto-generated up to heading depth 3
4. **Header** — appears from page 3 onwards, shows title (course/subject) and logos (course/subject on left and personal on right)
5. **Footer** — centered page number on all pages after the cover

---

## 🎨 Color Reference

| Variable | Color | Usage |
|---|---|---|
| `accent` | Teal `#008b8b` | Headings (h2), links, highlights, default callout |
| `warning` | Amber `#e19b19` | Important callouts, `#note` |
| `danger` | Red `#d32f2f` | Error callouts, `#problem`, disclaimer |
| `zdb-color` | Blue `#1976d2` | `#how` annotations |
| `night-color` | Purple `#7b1fa2` | `#why` annotations |
| `example-color` | Gray `#777777` | Example callouts |

---

## 🔤 Fonts

The template uses the following font stacks:

- **Monospace** (body text): `JetBrains Mono`, `Fira Code`, `Roboto Mono`, `Consolas`
- **Sans-serif** (headings, UI): `Syne`, `Montserrat`, `Segoe UI`

> If using the Typst Web App, import them in `template/fonts/` folder.\
> Must be installed for best results locally

---

## 📝 Full Example

````typst
#import "@preview/justwhitee-notes:0.1.0": *

#show: project.with(
  title: "Operating Systems",
  subject: "Master of Computer Engineering",
  professor: "Prof. John Doe",
  author: "Matteo Fontolan",
  logo-subject: image("default/logo.svg"),
  logo-personal: image("assets/course-logo.png"),
  bento-url: "https://itsjustwhitee.github.io/bento/",
  paypal-url: "https://paypal.me/justwhitee",
  contact-url: "https://github.com/itsjustwhitee/packages/issues",
  lang: "en",
)

= Processes

#def("Process")[
  A #kw[process] is a program in execution, including its current state, memory, and resources.
]

#note[A #hl[process is different from a program]: a program is static, a process is dynamic.]

== Process States

Processes can be in one of these states: ready, running, or blocked.

#example("State Transition")[
  A process moves from _ready_ to _running_ when the scheduler picks it.
]

== System Calls

Use `fork()` to create a child process #so the parent and child run concurrently.

```c
pid_t pid = fork();
if (pid == 0) {
    // child process
}
```

#tip[Always check the return value of `fork()` to distinguish parent from child.]
````
