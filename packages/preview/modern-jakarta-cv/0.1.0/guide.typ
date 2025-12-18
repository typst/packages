#import "template.typ": *
#show: project

#align(center)[
  #text(22pt, weight: "bold")[Template User Guide] \
  #text(11pt, style: "italic", fill: gray)[How to fully customize your professional CV]
]

#section("1. Project Architecture")
The template is divided into two distinct files:
- *template.typ*: The **Engine**. It defines fonts, margins, colors, and reusable components.
- *main.typ*: The **Content**. This is the file you edit to input your personal information.

#section("2. Customizing Global Styles")
- **Changing Colors**: Open *template.typ*, find the `section` function, and replace `#802020` in the `rgb()` function with your preferred Hex code.
- **Font Settings**: The template defaults to *Inter*. You can change the `font` parameter in the `project` function within *template.typ*.

#section("3. Understanding Components")
- **`entry()`**: Use this for Work, Education, and Organizations. It handles dates and locations automatically aligned to the right.
- **`project_entry()`**: Use this for projects. It features "Ultra-Tight" vertical spacing to fit more content.

#section("4. Handling Header Links")
To make your Github, LinkedIn, or Portfolio clickable, use the following syntax in *main.typ*:
```typst
#link("URL_HERE")[TEXT_TO_DISPLAY]