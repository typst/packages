# Quick Sip - Typst QRH Template

Creates aviation style checklists like Quick Reference Handbooks.

<img src="thumbnail.png" width="300">

### Features:

- Index
- Section
- Conditions
- Objective
- Step (When/If)
- Sub Step
- Caution
- Note
- Choose One
- Go to step
- End section now

## Start with

```typst
#import "@preview/quick-sip:0.1.2": *
#show: QRH.with(title: "Cup of Tea")
```

Then add a section:

```typst
#section("Cup of Tea preparation")[
  #step("KETTLE", "Filled to 1 CUP")
  #step([*When* KETTLE boiled:], "")
  #step([*If* sugar required], "")
    //.. Rest of section goes here
]
```

#### Index

An index with an entry for each section in the document.

```typst
#index()
```

#### Section

A section title, forces capitalisation.

```typst
#section("Cup of Tea preparation")[
    //.. Rest of section goes here
]
```

#### Conditions

Conditionals for this section.

```typst
#condition[
    - Dehydration
    - Fatigue
    - Inability to Concentrate
]
```

#### Objective

An objective for this section (optional).

```typst
#objective[To replenish fluids.]
```

#### Step

A numbered step in the checklist. The first parameter is to the left of the dotted line, the second is to the right. If the second parameter is omitted then there is no dotted line. Can be followed by a tag which is referenced by `goto()`.

```typst
#step("KETTLE", "Filled to 1 CUP") <fillKettle>
#step([*When* KETTLE boiled:])
#step([*If* sugar required])
```

#### Substep

A non-numbered step with a left indentation. Similarly to a step, the first parameter is to the left of the dotted line, the second is to the right.

```typst
#substep("MUG", "Fill")
#substep([Sugar (one #linebreak() teaspoon at a time)], "Add to MUG")
```

#### Tab

Indents contents by one tab.

```typst
#tab(goto("9"))
#tab(tab("Large mugs may require more water."))
```

#### Caution

Adds a caution element.

```typst
#caution([HOT WATER #linebreak()Adult supervision required.])
```

#### Note

Adds a note.

```typst
#note("Stir after each step")
```

#### Choose One

A numbered step with options.

```typst
 #choose-one[
    #option[Black tea *required:*]
    #option[Tea with MILK *required:*]
  ]
```

#### Go to step

Two right facing arrow heads followed by Go to step `step number`. Links to step in pdf. The parameter is the name of a tag next to a step.

```typst
#step("KETTLE", "Filled to 1 CUP") <fillKettle>
#goto("fillKettle")
```

#### End

Ends the section here with 4 dots.

```typst
#end()
```

#### Wait

Long small dotted line for waiting for a task to complete.

```typst
#wait()
```
