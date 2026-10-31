# statutely

Typst template for statutes / bylaws (vedtægter), Danish/English.

## Example

```typ
#import "@preview/statutely:0.1.0": *
#show: statutes.with(organisation: "The Empire", updated: "April 2026", lang: "en")

= Name                        // §1 Name
The association is called The Empire.

= Board                       // §2 Board
==                            // 2.1
The board consists of 5 members.
#sub[The board is elected for one year.]   // (2)
#sub[Members may run in absentia.]         // (3)
```
<p align="center">
  <img width="564" height="354" alt="Rendered statutes page titled Statutes of The Empire, with numbered § sections, a 5.1 subsection and numbered paragraphs" src="https://github.com/user-attachments/assets/41c7e7f4-bc12-42c5-9150-66d7ad93d890" />
  <br>
  <em>Rendered output of the code above: a centred title generated from <code>organisation</code> ("Statutes of The Empire") with the <code>updated</code> date beneath it. Each <code>=</code> heading becomes a numbered § section, <code>==</code> becomes a numbered subsection (5.1), and each <code>#sub</code> starts a new numbered paragraph ("(2)", "(3)").</em>
</p>



## `statutes` parameters

| Parameter | Default | Description |
|---|---|---|
| `organisation` | `none` | Organisation name, used in the generated title ("Statutes of …"). |
| `title` | `none` | Override the generated title. |
| `updated` | `none` | Shown as "Last updated …" under the title. |
| `logo` | `none` | Content, e.g. `image("logo.png", width: 2.3cm)`. Must be passed from your own document, not a path string. |
| `lang` | `"en"` | `"da"` or `"en"`. Language setting. |

## Markup

| Syntax | Renders as | Description |
|---|---|---|
| `= Title` | §N Title | Section. |
| `==` | N.M | Numbered sub-clause (heading text optional). |
| `#sub[…]` | (2) … | Auto-numbered subsection paragraph within a clause. |
| `#stk[…]` | _Stk. 2._ …| Danish alternative to `#sub` (stykke). |
