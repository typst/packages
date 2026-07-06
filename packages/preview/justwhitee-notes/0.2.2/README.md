# 📚 justwhitee-notes: university Notes Typst Template

A clean, minimal Typst template designed for university lecture notes and course handouts. Features a styled cover page, automatic table of contents, disclaimer page, and a rich set of callout components.

---

## 🚀 Getting Started

### 1. Import the template

```typst
#import "@preview/justwhitee-notes:0.2.2": *
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
  logo-subject: image("imgs/course-logo.png"),        // optional
  logo-personal: image("imgs/my-logo.png"),           // optional
  year: "2024/2025",                                  // optional, auto-generated if omitted
  bento-url: "https://bento.me/yourprofile",          // optional
  paypal-url: "https://paypal.me/yourname",           // optional
  contact-url: "https://t.me/username",               // optional
  show-disclaimer: true,                              // optional, default true
  lang: "en",                                         // optional, default 'en'
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
| `bento-url` | string | ❌ | Your bento/linktree page URL. Omit (or leave unset) to hide the button. |
| `paypal-url` | string | ❌ | PayPal/support link on the disclaimer page. Omit to hide. |
| `contact-url` | string | ❌ | Link to report errors or contribute. Omit to hide. |
| `lang` | string | ❌ | The language of the document (default is English). |
| `show-disclaimer` | bool | ❌ | Show the disclaimer page (default: `true`). Set to `false` to omit it entirely. |

---

## 🧩 Components

### Callout Boxes

Pre-built callout styles for structuring your notes:

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

// Property/Statement box (purple accent)
#prop("Atomicity")[
  An operation is atomic if it behaves as a single, indivisible unit of work. 
]

// Proof box (red accent)
#proof("Proof: SJF")[
  We want to prove that $"TWT"(sigma)$ is minimized if and only...
]
```

You can also use the base `callout` function for full customization:

```typst
#callout(title: "Custom", icon: "🔥", color: rgb("#e74c3c"), endpoint: true)[
  Custom callout content.
]
```
>[!INFO]
> You can always customize your own callout, where you can have custom `title`, `icon` (on left-upper corner), `color` and right-bottom dot, `endpoint`, presence (useful for multi-page callouts, expecially for proofs).

---

### Inline Annotations

Quick inline markers for annotating your notes:

```typst
#note[Pay attention to this detail.]                // 👉 Note: (yellow highlight)
#tip[This is a useful shortcut.]                    // ✅ Tip: (teal highlight)
#problem[This approach has a flaw.]                 // ❗️ Problem: (red highlight)
#why("use threads")[Because...]                     // 🤔 Why use threads? (purple highlight)
#how("it works")[Step by step...]                   // 👨🏻‍🏫 How it works? (blue highlight)
#analogy("Processes vs Threads")[Processes are...]  // Analogy: (#extra styled, gray side-note)
#extra[Side note or additional context.]            // Italic muted text, smaller size, "margin" notes, or for extra clarifications
```
> These are useful for further details of your notes (like point outs, explanations, ...).\
> *Note*: to use those annotations without "title" (when needed) just pass "" or `none`.

---

### Inline Text Styles

```typst
#kw("keyword")                        // Bold monospace keyword (accent color is teal by default)
#kw("error", color: danger)           // With custom color

#hl("highlighted text")              // Highlighted monospace span (accent color - teal)
#hl("warning text", color: warning)  // With custom color
```
> [!INFO]
> `#hl` should be used on the same line, so if you want to highlight more lines you have to manually add more `#hl` wisely. Otherwise you can use typst's `#highlight`.

---

### Symbols

```typst
#so       // => (implication arrow)
#arrow    // -> (simple right arrow)
#swarrow  // ~> (curvy right arrow)
```

---

### Side Note Block

A left-bordered block for notes or asides:

```typst
#side-note[
  This is a side note or an important remark set apart from the body.
]
```
Like callouts, `side-note`s are customizable with `color`.

---

### Code Blocks

Code blocks are automatically styled, just use standard Typst raw blocks:

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

1. **Cover page** - title, subject, professor, author, logos, academic year
2. **Disclaimer page** - a standard disclaimer with contact/support links (omit with `show-disclaimer: false`)
3. **Table of Contents** - auto-generated up to heading depth 3
4. **Header** - appears from page 3 onwards, shows title (course/subject) and logos (course/subject on left and personal on right)
5. **Footer** - centered page number on all pages after the cover

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

- **Monospace** (body text): [`JetBrains Mono`](https://fonts.google.com/specimen/JetBrains+Mono), `Fira Code`, `Roboto Mono`, `Consolas`
- **Sans-serif** (headings, UI): [`Syne`](https://fonts.google.com/specimen/Syne), `Montserrat`, `Segoe UI`

> If using the Typst Web App, import them in `template/fonts/` folder (or anywhere).\
> Must be installed (static version) for best results locally.

I advise to use `JetBrains Mono` and `Syne`.

---

## 📝 Full Example

````typst
#import "@preview/justwhitee-notes:0.2.2": *


#show: project.with(
  title: "Cryptography & Security",
  subject: "Master of Computer Engineering",
  professor: "Prof. Alice Smith",
  author: "Matteo Fontolan",
  logo-personal: image("default/logo.svg"),
  logo-subject: image("assets/icon.jpg"),
  bento-url: "https://itsjustwhitee.github.io/bento/",
  paypal-url: "https://www.paypal.com/paypalme/justwhitee",
  contact-url: "https://t.me/justwhitee",
  show-disclaimer: true,
  lang: "en",
)

= Public-Key Cryptography: RSA

#extra[RSA is named after its creators: Ron Rivest, Adi Shamir, and Leonard Adleman, who publicly described the algorithm in 1977.]

#def("RSA Algorithm")[
  #kw[RSA] is an *asymmetric cryptographic algorithm* based on the practical difficulty of the factorization of the product of two large *#underline[prime] numbers*.
]

#important("Security Foundation")[
  The entire security of RSA relies on the #kw[Integer Factorization Problem]. If a fast polynomial-time algorithm for factorization is found, RSA becomes completely insecure.
]

== Key Generation

#how(title: "generate an RSA keypair")[
  + Choose two distinct #underline[prime] numbers, $p$ and $q$.
  + Compute $n = p times q$. This $n$ is the modulus for both keys.
  + Compute Euler's totient function: $phi(n) = (p-1)(q-1)$.
  + Choose an integer $e$ such that $1 < e < phi(n)$ and $gcd(e, phi(n)) = 1$.
  + Determine $d$ as $d equiv e^(-1) (mod phi(n))$.
]
#v(-1em)
#note[The public key is the tuple $(n, e)$ and the private key is the tuple $(n, d)$.]
#v(-1em)
#tip[In practice, the public exponent $e$ is often chosen to be $65537$ ($2^16 + 1$) because it has a short binary representation, making encryption significantly faster.]

== Encryption and Decryption

Let $M$ be the plaintext message and $C$ be the ciphertext. The process flows as follows:

- *Encryption*: Plaintext $M$ #arrow Ciphertext $C = M^e (mod n)$
- *Decryption*: Ciphertext $C$ #arrow Plaintext $M = C^d (mod n)$

#problem[Raw RSA (Textbook RSA) is #underline[*deterministic*]. If you encrypt the exact same message twice, it produces the same ciphertext. This makes it highly vulnerable to chosen-plaintext attacks.]

#why(title: "we use padding schemes")[
  To introduce randomness into the plaintext before encryption (e.g., using OAEP padding). This ensures that $M_1 = M_2$ does #hl(color: danger)[*#underline[not]*] imply $C_1 = C_2$.
]

== Mathematical Proof of Correctness

We need to prove that decrypting the ciphertext yields the original message: $C^d equiv M (mod n)$.

#proof("Proof: Correctness of RSA", endpoint: true)[
  Given $C = M^e (mod n)$, we want to find $C^d (mod n)$.
  Substitute $C$:
  $C^d equiv (M^e)^d equiv M^(e d) (mod n)$
  
  By definition of the private exponent $d$, we have $e d equiv 1 (mod phi(n))$.
  #so $e d = 1 + k phi(n)$ for some integer $k$.

  Substituting this back into the exponent:
  $M^(e d) equiv M^(1 + k phi(n)) equiv M times (M^phi(n))^k (mod n)$

  By Euler's Theorem, if $gcd(M, n) = 1$, then $M^phi(n) equiv 1 (mod n)$.
  $M times (1)^k equiv M times 1 equiv M (mod n)$
  
  Thus, decryption works correctly and returns the original message.
]

== Implementation Details

Here is a simple Python snippet to demonstrate modular exponentiation, which is the core operation in the RSA algorithm:

```python
def encrypt(m, e, n):
    # Computes (m^e) % n efficiently
    return pow(m, e, n)
```
#side-note(color: zdb-color)[
Always use #hl[stablished libraries] like `Cryptography` in Python #hl[for production environments] instead of implementing custom crypto algorithms from scratch.
]
````