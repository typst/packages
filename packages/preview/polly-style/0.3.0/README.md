# polly-style

This is a Typst package that adds a new align block format for the Principles of Functional Programming class at CMU.

## Quick start

Put this at the top of your Typst document but after show rules which affect raw blocks (right before your first task is probably a good place):

````typ
#import "@preview/polly-style:0.3.0": polly-style-rule

// polly-style-rule show rule to display polly blocks correctly
#show: polly-style-rule
````

Then, use the `polly` block format to write your proofs:

````typ
```polly
(*example proof*)
fact 0 ~= 1 #[clause 1 of `fact`]
```
````

The following symbols have special meanings inside a `polly` block, and will be rendered as their corresponding math mode symbols:

- `~=` is the symbol for extensional equivalence
- `!~=` is the symbol for not extensionally equivalent
- `==>` is the symbol for steps to
- `<==` is the symbol for steps from
- `==` is the symbol for equals
- `!==` is the symbol for not equals

The following symbols are used for custom behavior:

- `#[...]` is used to insert a right aligned note explaining a step in the proof. (This is where "clause 1 of `f`" would go.) The text inside (e.g. `...`) is evaluated as standard Typst markup.
- `#$...$` is used to insert a math block. The text inside (e.g. `...`) is evaluated as standard Typst math and added inline. (This is likely unneeded for most uses, but using this you can insert almost anything you want into the proof.)
- `\` when followed by whitespace adds a line break
- `&` is adds a new alignment point like in math mode
- `\` followed by non-whitespace acts as an escape character

All other written text is treated as code and is rendered as such. By default the language is set to SML. You can change this by creating your own show rule using the `polly-style-raw` function like so:

````typ
#import "@preview/polly-style:0.3.0": polly-style-raw
#show raw.where(lang: "custom-polly") : it => polly-style-raw(it, lang: "python")

```custom-polly
print("Hello World!") #[prints out "hello world"]
```
````

Note, the special symbols were chosen to never show up in SML (at least not how we are supposed to use them in proofs), so they will not conflict with your proofs. If you use a different language, you may run into conflicts.

## Example

````typ
#import "@preview/polly-style:0.3.0": polly-style-rule
#show: polly-style-rule

LHS:
```polly
sort (inorder Empty) &~= sort([]) #[clause 1 of `inorder`]\
 & ~= [] #[clause 1 of `sort`]
```

RHS:
```polly
        sortTree Empty &~= [] #[clause `sortTree`] \
         &~= 5
```
````
