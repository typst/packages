# Articulate by Coders' Compass

## Introduction

This is a demonstration of the template that supports combining markdown with Typst through cmarker. The integration allows for seamless academic writing with proper citations and cross-references. Sample reference [@texbook].

You can reference headings using their auto-generated labels. For example, see [Introduction](#introduction). Generally, it is the heading in lowercase with the words joined together with dashes. A longer example in [Citations and Bibliography](#citations-and-bibliography).

## Headings and Cross-References

## Citations and Bibliography

### Academic Citations

The concept of literate programming was introduced by Knuth [@knuth:1984]. This revolutionary approach changed how we think about code documentation. The foundational work on TeX [@texbook] laid the groundwork for modern typesetting systems.

For comprehensive LaTeX documentation, see [@latex:companion] and [@latex2e]. Early work on computer typesetting can be found in [@lesk:1977].

### Multiple Citations

Several authors have contributed to this field [@texbook] [@latex:companion] [@knuth:1984].

> **Note**: You need to have spaces betwen consecutive citations:
>
> `[@texbook] [@latex:companion] [@knuth:1984]`

# H1 Heading
## H2 Heading
### H3 Heading
#### H4 Heading
##### H5 Heading
###### H6 Heading

## Paragraphs and Text Styles

This is a normal paragraph with various text formatting options.
This is **bold text**, this is *italic text*, and this is ***bold italic***.
You can also use `inline code` in a sentence, and even ~strikethrough text~.

Hard line break example:
This line has two spaces at the end
So this appears on a new line without a paragraph break.

## Lists with References

### Unordered List
- Item one referencing [@texbook]
- Item two with a footnote[^important-note]
  - Subitem two-point-one[^sub-note]
  - Subitem two-point-two
- Item three citing multiple sources [@latex:companion] [@knuth:1984]

[^important-note]: This footnote references [@latex2e] to demonstrate footnotes with citations.
[^sub-note]: A simple footnote without citations.

### Ordered List with Cross-References
1. First item - see [Introduction](#introduction)
2. Second item - refer to
   1. Subitem 2.1 citing [@lesk:1977]
   2. Subitem 2.2
3. A third item

## Links and References

- [Coders' Compass](https://coderscompass.org) - External link
- [Typst Documentation](https://typst.app/docs) - Another external link
- [Go to Introduction](#introduction) - Internal link to section

## Enhanced Blockquotes

> This is a standard blockquote citing [@texbook].
> It can span multiple lines and include citations.
>
> **Note:** This is important information from [@knuth:1984].

> **Tip:** For best results with LaTeX, consult [@latex:companion].

## Code Blocks with Enhanced Features

### Python Example
```python
# Python example
def greet(name: str) -> str:
    """
    A simple greeting function
    """
    return f"Hello, {name}! Welcome to Python."

# Usage
print(greet("Typst"))
```

### Rust Example with Syntax Highlighting
```rust
// Rust implementation
fn fibonacci(n: usize) -> usize {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

fn main() {
    println!("The 10th Fibonacci number is: {}", fibonacci(10));
}
```

### Bash Example
```bash
#!/bin/bash
echo "Processing document with modern tools..."
typst compile document.typ
echo "Document compiled successfully!"
```

---

## Horizontal Rules and Separators

Above and below this line are horizontal rules.

---

## Tables Section

### Basic Table
| Author | Work | Year | Citation |
| ------ | ---- | ---- | -------- |
| Donald Knuth | The TeXbook | 1986 | [@texbook] |
| Leslie Lamport | LaTeX Manual | 1994 | [@latex2e] |
| Mittelbach et al. | LaTeX Companion | 2004 | [@latex:companion] |

### Advanced Table with References
| Concept | Description | Reference |
| ------- | ----------- | --------- |
| Literate Programming | Code as literature | [@knuth:1984] |
| Computer Typesetting | Early digital publishing | [@lesk:1977] |
| Document Preparation | Systematic approach | [@latex2e] |

As shown in the [Tables Section](#tables-section), we can reference tables and their content.

## Footnotes with Citations

Here is a sentence with a regular footnote[^regular] and another with a citation footnote[^citation-note].

Complex footnotes can contain multiple citations[^complex-footnote].

[^regular]: This is a simple footnote without citations.
[^citation-note]: This footnote references the fundamental work by [@texbook].
[^complex-footnote]: This footnote discusses multiple works [@knuth:1984] [@latex:companion] and their impact on modern typesetting.

## Mathematics Integration

### Inline Math
The famous equation $E = mc^2$ demonstrates mass-energy equivalence. Integration can be expressed as $\int_{0}^{\infty} e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$.

### Block Math
Mathematical typesetting, as described in [@texbook], allows for complex expressions:

$$
\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}
$$

The Fibonacci sequence can be expressed mathematically as:

$$
F_n = \begin{cases}
0 & \text{if } n = 0 \\
1 & \text{if } n = 1 \\
F_{n-1} + F_{n-2} & \text{if } n > 1
\end{cases}
$$

## HTML Elements and Styling

### Text Styling with HTML
This text contains <sub>subscript</sub> and <sup>superscript</sup> elements.
You can also <mark>highlight important text</mark> using HTML tags.

### Definition Lists
<dl>
<dt>Literate Programming</dt>
<dd>A programming paradigm introduced by Donald Knuth</dd>

<dt>TeX</dt>
<dd>A typesetting system created by Knuth</dd>

<dt>LaTeX</dt>
<dd>A document preparation system built on TeX</dd>
</dl>


## Combined References and Citations
The work presented in [Introduction](#introduction) builds upon foundational research [@texbook] [@knuth:1984].


## Summary and Conclusions

This document has demonstrated the comprehensive integration of Markdown with Typst through cmarker, showcasing:

1. **Citations**: Proper academic citations using [@texbook] [@latex:companion] [@knuth:1984] [@latex2e] [@lesk:1977]
2. **Cross-references**: Internal linking to sections like [Introduction](#introduction).
3. **Advanced formatting**: Tables, footnotes, and mathematical expressions
4. **Code integration**: Syntax-highlighted code blocks in multiple languages
5. **HTML support**: Enhanced styling with HTML elements

The combination of Markdown's simplicity with Typst's power, enhanced by proper citation management, provides an excellent foundation for academic and technical writing [@knuth:1984].

For the complete bibliography of sources referenced in this document, see the Bibliography section below.
