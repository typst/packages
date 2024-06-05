#import "@preview/fervojo:0.1.0": *

= The rendered svg

#render(```
{[`select-stmt` ["WITH" <!, "RECURSIVE"> 'common-table-expression'*","]?#`Common table expressions`],
 <{[["SELECT" <!, "DISTINCT", "ALL"> 'result-column'*","]#`Projection clause` ["FROM" <'table-or-subquery'*",", 'join-clause'>]?#`From clause`],
   [["WHERE" 'expr']?#`Where clause` ["GROUP" "BY" 'expr'*"," ["HAVING" 'expr']?]?#`Grouping`]
  }#`Single SELECT`,
  ["VALUES" ["(" 'expr'*"," ")"]*","]#`Literal values`
 >*['compound-operator'#[`E.g. "SELECT` "UNION" `SELECT"`]]#`Compounded SELECT`,
 [["ORDER" "BY" 'ordering-item'*","]?#`Ordering` ["LIMIT" 'expr' <!, ["OFFSET"? 'expr']>]?#`Limiting`]
}
```)


= The default.css


#text(str(default-css()))

