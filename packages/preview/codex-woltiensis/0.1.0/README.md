# Codex Woltientis
⚠️ Warning : This package is quite young and will probably undergo some big changes in the future. 
Yet it is already usable and can be used to create a student songbook. Feel free to use it and give feedbacks.

## Introduction

This package is a collection of functions that can help creating a student song books like the Codex Woltiensis and other student songbooks.
It define 3 main function : 
```typst
chant(...) // main function that define song layout
chapter(...) // function that define chapter layout
index(...)  // function that define index layout
```

## Define a song

To define a song, you can use the `chant` function. This function take multiple arguments :

```typst
#let chant(
  title,
  body-list,
  body-list-format,
  layout,
  layout-info,
  header,
  img,
  sub-content,
  new-page,
  type,
)
```


### Mandatory arguments :

- `title` : The title of the song, of type `str`
- `body-list` : The list of the verse and chorus of type `list`
- `body-list-format` : The format of the list of the verse and chorus of type `list`. The format are predefined as :
  - `"c"`: define verse
  - `"rf"` : define french chorus
  - `"rfs"` : define simple french chorus
  - `"rfl"` : define last french chorus
  - `"rn"` : define dutch chorus
  - `"rns"` : define simple dutch chorus
  - `"rnl"` : define last dutch chorus

A simple example of a song definition is :

```typst
#let couplet1 = [...]
#let couplet2 = [...]
#let couplet3 = [...]    

#let Brabançonne = chant(
  "Brabançonne 🇧🇪",
  (couplet1,couplet2,couplet3),
  ("c","c","c"),
)
```

### Optional arguments :
- `layout` : The layout of the song, of type `str`. The layout are predefined as :
  - `"default"` -> default : linear layout
  - `"column"` : set 2 column layout
- `layout-info` : Additional information the layout could need, of type `list`
  -  `col1` : define the number of element in the first column
- `header` : The header of the song, of type `list` :
  - `tune` : the tune of the song
  - `author` : the author of the tune
  - `lyrics` : the author of the lyrics
  - `pseudo` : the pseudo of the author of the lyrics
- `img` : image associated to the song, of type `list` :
  - `path` : name of the image located in a folder named `image` in the root of the project
  - `position` : position of the image in the song, could be `top` (on top of the title) or `bottom` (on bottom of the song)
  - `height` : height of the image
  - `width` : width of the image
  - `alignment` : alignment of the image on the horizontal and vertical axis
- `sub-content` : Additional content of the song, generally implies another song of type `chant`
- `new-page` -> default true : Boolean that define if the song start on a new page or not
- `type` : The type of the song, of type `str`. The type are predefined as :
  - `"officiel"` : define a official student song
  - `"leekes"` -> default : define a classic song
  - `"groupe_folklorique"` : define a folk song
  - `"andere_ziever"` : define a other song

An example of a song definition is :
```typst

#let WoltjeKreet = chant(
  "Woltje Kreet",
  (kreet,),
  ("c",),
  new-page : false
)

#let CridesPres = chant(
  "Cris des Présidents",
  (couplet1,couplet2, couplet3, couplet4, couplet5,couplet6,couplet7,couplet8, couplet9, couplet10, couplet11, couplet12,couplet13,couplet14,couplet15,couplet16,couplet17),
  ("c","c","c","c","c","c","c","c","c","c","c","c","c","c","c","c","c",),
  layout : "column",
  layout-info : (col1 : 12),
  sub-content : WoltjeKreet,
  type : "officiel"
)


```

## Define a chapter
To define a chapter page, you can use the `chapter` function. This function take multiple arguments :

```typst
#let chapter(
  title,
  title_color,
  subtitle,
  alignment,
  img,
  margin,
  numbering,
  defaut_page,
)
```
Note that none of the arguments are mandatory. This will lead to a chapter page being blank.

### Optional arguments :
- `title` : The title of the chapter, of type `str`
- `title_color` : The color of the title of the chapter
- `subtitle` : The subtitle of the chapter, of type `str`
- `alignment` -> default center+horizon : The alignment of the page content of the chapter.
- `img` : same as the `img` argument of the `chant` [function](#optional-arguments-)
- `margin` -> default constant.margin : The margin of the page, of type `dict`
- `numbering` -> default false: Boolean that define if the page is numbered or not
- `defaut_page` -> default true : Boolean that define if the page follow default layout or not (generally used for cover page)

Here's a simple example of a chapter page definition :
```typst
 #chapter(
  subtitle : subtitle,
  numbering : false,
  img : (
    path : "Woltje_Blason.png", position : top, width : 5cm 
  )
)
```

## Define an index
To define an index page, you can use the `index` function. It doest not take any argument and will create and idex automatically based on the songs defined in the package.

```typst
#index()
```