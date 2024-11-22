Tests
=====

This document contains a bunch of tests that should be manually checked.

(This should be on the same line) (as this)

(This should be above)  
(this)

Basic styling: *italics*, _italics_, **bold**, __bold__, ~strikethrough~

Unlike Typst, bare links are not clickable: https://example.org.  
Angle-bracket links are clickable: <https://example.org>.  
We can also use links with text: [example.org](https://example.org).  
Unlike Typst, we cannot do references with an at sign: @reference.

## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

    code block defined through indentation (no syntax highlighting)
	We can put triple-backticks in indented code blocks:
	```rust
	let x = 5;
	```

```rust
// Code block defined through backticks, with syntax highlighting
```

Some `inline code`.

A horizontal rule:

---

- an
- unordered
- list

Inline math: $\int_1^2 x \mathrm{d} x$

Display math:

$$
\int_1^2 x \mathrm{d} x
$$

	with this paragraph nested in the last list element

We can escape things with backslashes:
\*asterisks\*,
\`backticks\`,
\_underscores\_,
\# hashes,
\~tildes\~,
\- minus signs,
\+ plus signs,
\<angle brackets\>.

== Putting equals signs at the start of the line does not make this line into a heading.  

/ Unlike Typst, this line is plain text: and not a term and definition  
Similarly, math mode does not work: $ x = 5 $  
A backslash on its own does not produce a line break: a\b.  
Typst commands do not work: #rect(width: 1cm)  
Neither do Typst comments: /* A comment */ // Line comment  
Neither does tildes: foo~bar  
Neither do Unicode escapes: \u{1f600}

Smart quotes: 'smart quote' "smart quote"  
We can escape them to make not-smart quotes: \'not smart quote\' \"not smart quote\"  
We have Markdown smart punctuation, such as en dashes (-- and –) and em dashes (--- and —).


> Quoted text
>
> > Nested
>
> Unnnested

<!--typst-begin-exclude-->
This should not appear.<!--typst-end-exclude-->

Raw Typst code:

<!--raw-typst $ 2 + 2 = #(2 + 2) $-->
