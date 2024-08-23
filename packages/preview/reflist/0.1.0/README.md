# Typst reflist
A simple referenceable list library for Typst. If you ever wanted to reference elements in a list by a key, this library is for you.

## Example

```typst

#import "@preview/reflist:0.1.0" as reflist
#show ref: reflist.show-rule

#reflist.reflist(
  [My cool constraint A],<c:a>,
  [My also cool constraint B],<c:b>,
  [My non-refernceable constraint C],
  list_style: "C1)",
  ref_style: "C1",
  name: "Constraint"
)

See how my @c:a is better than @c:b.
```

This generates the following output:

![Example of the typst output. The last sentence reads "See how my Constraint C1 is better than Constraint C2"](img/image.png)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### 0.1.0

- Initial release



