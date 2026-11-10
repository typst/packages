# codegds

GDscript syntax highlighting for [Typst](https://typst.app/).

## Installation

````typst
#import "@preview/codegds:0.1.0": gdscript-syntax
#set raw(syntaxes: gdscript-syntax)

```gdscript
func process_items(items: Array) -> void:
	# Check if the array is empty
	if items.is_empty():
		print("No items to process")
		return
	
	# Process each item
	for item in items:
		print("Processing: ", item)
```
````

## Credits

- Syntax patterns informed by [dementive/SublimeGodot](https://github.com/dementive/SublimeGodot)
