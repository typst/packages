# ***Scriptie***

*Scriptie* formats your movie or tv script to the standard layout.
It has title pages, scene loglines, action, dialogue (with automatic _cont'd_ over page breaks!), parentheticals, transitions and more.

In addition, Scriptie optionally features a hackish abuse of Typst's syntax for a very efficient screenwriting experience.

# Demo
```typst
#import "@preview/scriptie:0.1.0":*
#show: qscript

#titlepage(
  title:[Your script],
  author:("You", "Your Cowriter"),
  version:"First draft",
  contact:"contact info",
  subtitle:"subtitle"
)

== INT. TYPST UNIVERSE - RIGHT NOW.

A curious Typst user is checking out the Scriptie package.

/ USER: (amazed) Wow! This is really great!

The user writes the best screenplay the world has ever seen.

/ PRODUCER: Ahh... but I don't want to produce good films.

/ USER (V.O.): Well, at least it was a joy to write.

- CUT TO

#lorem(30)

== EXT. The land of Lorem - DAY

#lorem(20)#parbreak()#lorem(35) 
/ #lorem(1): #lorem(10)
#lorem(15)
- THE END.
```
<img src="demo1.svg"/>
<img src="demo2.svg"/>

There's a demo showcasing all the functionalities [with the quick syntax](https://github.com/KauriP/scriptie/blob/main/demo-quick.typ)
and [without the quick syntax](https://github.com/KauriP/scriptie/blob/main/demo.typ).

# Possible issues

The preferred font to use with this package is [Courier Prime](https://quoteunquoteapps.com/courierprime/) or Courier.
For the web app, you should drop the `.ttf` files (unzipped from the linked download) into `Files`.

