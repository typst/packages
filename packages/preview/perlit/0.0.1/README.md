# Perlit

Perlit is a library for rendering [Obsidian](https://obsidian.md/) graphs in [Typst](https://typst.app) with [CeTZ](https://typst.app/universe/package/cetz/)

## Usage

```typ
#import "@preview/perlit:0.0.1": draw

#draw(json("/example.canvas"))
```

<img src="gallery/simple-obsidian.png" alt="simple obsidian graph">
<img src="gallery/simple-typst.png" alt="simple graph rendered in typst">

To use this package, simply import and call the `draw` function with the loaded json of the graph you want to render. For security reasons, typst cannot read files outside of the documents' root directory. For more information, read the [typst docs](https://typst.app/docs/reference/syntax/#paths-and-packages).

<table>
	<tr>
		<td>
			<img src="gallery/group-edges-obsidian.png" alt="different graph features in obsidian">
		</td>
		<td>
			<img src="gallery/group-edges-typst.png" alt="different graph features rendered in typst">
		</td>
	</tr>
</table>

## Loading files (experimental)

Obsidian graphs can contain files like images and pdfs. As typst doesn't allow loading files from outside the project root, the loading of the files needs to be handled by the user.

*IMPORTANT: Currently files need to be directly in the root directory of the document to be available to the graph in typst*

### Images
```typ
#import "@preview/perlit:0.0.1": draw

#draw(
  json("/testgraph.canvas"),
  velocity: 0.1,
  curve: false,
  file-handlers: (
    "jpg": (path: str, length: length, ..args) => {
    	image(path, width: length)
  	},
  ),
)
```
<img src="gallery/image-obisidian.png" alt="imported image in obsidian">
<img src="gallery/image-typst.png" alt="imported image rendered in typst">

### Other Graphs

This also means that other graphs can be imported into the graph:

```typ
#import "@preview/perlit:0.0.1": draw

#draw(
  json("/testgraph.canvas"),
  velocity: 0.1,
  curve: false,
  file-handlers: (
    "canvas": (path: str, ..args) => {
    	draw(json(path), scale: 0.8, ..args)
  	},
  ),
)
```
<table>
	<tr>
		<td>
			<img src="gallery/nested-obisidian.png" alt="nested graph in obsidian">
		</td>
		<td>
			<img src="gallery/nested-typst.png" alt="nested graph rendered in typst">
		</td>
	</tr>
</table>
