## Term List as a Table

The [_term list_](https://typst.app/docs/reference/model/terms/) is the following syntax in typst:

<table>

<tr>

<td>

_Input_
</td>
<td>

_Document Result_
</td>

</tr>
<tr>

<td>

`/ term: description`
</td>
<td>

**term**&nbsp;
&nbsp;
description
</td>

</tr>

</table>

This package allows laying out the term list as a regular table. By default, the terms form the first column and the descriptions are in the second column, but it can also be transposed. As an extension, additional columns can be added.

### Example

<table>

<tr>

<td>

_Input_
</td>
<td>

_Document Result_
</td>

</tr>
<tr>

<td>


```typ
#import "@preview/tabbyterms:0.1.0" as tabbyterms: terms-table

#show: tabbyterms.style.default-styles
#terms-table[
  / Package: PACKAGENAME
  / Technology: Typst
  / Subject: General, Mathematics, Linguistics
  / Category: Layout, Components
]
```

</td>
<td>


<table>

<tr>

<td>

**Package**
</td>
<td>

PACKAGENAME
</td>

</tr>
<tr>

<td>

**Technology**
</td>
<td>

Typst
</td>

</tr>
<tr>

<td>

**Subject**
</td>
<td>

General, Mathematics, Linguistics
</td>

</tr>
<tr>

<td>

**Category**
</td>
<td>

Layout, Components
</td>

</tr>

</table>

</td>

</tr>

</table>

As an extension, additional columns can be added by using lists in the description:

<table>

<tr>

<td>

_Input_
</td>
<td>

_Document Result_
</td>

</tr>
<tr>

<td>


```typ
#import "@preview/tabbyterms:0.1.0" as tabbyterms: terms-table

#show: tabbyterms.style.default-styles
#terms-table[
  / Term: - Explanation
          - Assumptions
  / X: - Explanatory variables
       - Non-random
  / Y: - Y1, ..., Yn observations
       - Pairwise independent
  / β: - Model parameters
       - Non-random
]
```

</td>
<td>


<table>

<tr>

<td>

**Term**
</td>
<td>

Explanation
</td>
<td>

Assumptions
</td>

</tr>
<tr>

<td>

**X**
</td>
<td>

Explanatory variables
</td>
<td>

Non-random
</td>

</tr>
<tr>

<td>

**Y**
</td>
<td>

Y1, …, Yn observations
</td>
<td>

Pairwise independent
</td>

</tr>
<tr>

<td>

**β**
</td>
<td>

Model parameters
</td>
<td>

Non-random
</td>

</tr>

</table>

</td>

</tr>

</table>

### Function Documentation and Manual

Please [_see the manual_](docs/tabbyterms-manual.pdf) for more explanations, examples and function documentation.

### License

The package is distributed under the terms of the European Union Public License v1.2 or any later version, which is an OSI-approved weakly copyleft license. The License is distributed with the package.

😼
