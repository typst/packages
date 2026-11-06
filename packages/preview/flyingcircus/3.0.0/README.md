# The `flyingcircus` Package
<div align="center">Version 3.0.0</div>

Do you want your homebrew to have the same fancy style as the Flying Circus book? Do you want a simple command to generate a whole aircraft stat page, vehicle, or even ship?  I'll bet you do! Take a look at the Flying Circus Aircraft Catalog Template. 

## Acknowledgments and Useful Links

Download the fonts from [HERE](https://github.com/Tetragramm/flying-circus-typst-template/archive/refs/heads/Fonts.zip).  Install them on your computer, upload them to the Typst web-app (anywhere in the project is fine) or use the Typst command line option --font-path to include them.

Based on the style and work (with the permission of) Erika Chappell for the [Flying Circus RPG](https://opensketch.itch.io/flying-circus).

Integrates with the [Plane Builder](https://tetragramm.github.io/PlaneBuilder/index.html). Just click the Catalog JSON button at the bottom to save what you need for this template.

Same with the [Vehicle Builder](https://tetragramm.github.io/VehicleBuilder/).

Or check out the [Discord server](https://discord.gg/HKdyUuvmcb).

## Getting Started

These instructions will get you a copy of the project up and running on the typst web app. 

```typ
#import "@preview/flyingcircus:3.0.0": *

#show: FlyingCircus.with(
  Title: title,
  Author: author,
  CoverImg: image("images/cover.png"),
  Dedication: [It's Alive!!! MUAHAHAHA!],
)

#FCPlane(read("My Plane_stats.json"), Nickname:"My First Plane")
```

## Usage

The first thing is the FlyingCircus style.

```typ
#import "@preview/flyingcircus:3.0.0": *

/// Defines the FlyingCircus template
///
/// - Title (str): Title of the document. Goes in metadata and on title page.
/// - Author (str): Author(s) of the document. Goes in metadata and on title page.
/// - CoverImg (image): Image to make the first page of the document.
/// - Description (str): Text to go with the title on the title page.
/// - Dedication (str): Dedication to go down below the title on the title page.
/// - body (content)
/// -> content

// Example
#show: FlyingCircus.with(
  Title: title,
  Author: author,
  CoverImg: image("images/cover.png"),
  Dedication: [It's Alive!!! MUAHAHAHA!],
)
```

Next is the FCPlane function for making plane pages.
```typ
/// Defines the FlyingCircus Plane page.  Always on a new page. Image optional.
///
/// - Plane (str | dictionary): JSON string or dictionary representing the plane stats.
/// - Nickname (str): Nickname to go under the aircraft name.
/// - Img (image | none): Image to go at the top of the page. Set to none to remove.
/// - BoxText (dictionary): Pairs of values to go in the box over the image. Does nothing if no Img provided.
/// - BoxAnchor (str): Which anchor of the image to put the box in?  Sample values are "north", "south-west", "center".
/// - DescriptiveText (content)
/// -> content


// Example
#FCPlane(
  read("Basic Biplane_stats.json"),
  Nickname: "Bring home the bacon!",
  Img: image("images/Bergziegel_image.png"),
  BoxText: ("Role": "Fast Bomber", "First Flight": "1601", "Strengths": "Fastest Bomber"),
  BoxAnchor: "north-east",
)[
#lorem(100)
]
```

The FCVehicleSimple is for when you want to put multiple vehicles on a page.
```typ
/// Defines the FlyingCircus Simple Vehicle.  Not always a full page. Image optional.
///
/// - Vehicle (str | dictionary): JSON string or dictionary representing the Vehicle stats.
/// - Img (image): Image to go above the vehicle. (optional)
/// - DescriptiveText (content)
/// -> content
#FCVehicleSimple(read("Sample Vehicle_stats.json"))[#lorem(120)]
```

FCVehicleFancy is a one or two page vehicle that looks nicer but takes up more space.
```typ
/// Defines the FlyingCircus Vehicle page.  Always on a new page. Image optional.
/// If the Img is provided, it will take up two facing pages, otherwise only one, but a full page, unlike the Simple.
///
/// - Vehicle (str | dictionary): JSON string or dictionary representing the Vehicle stats.
/// - Img (image | none): Image to go at the top of the first page. Set to none to remove.
/// - TextVOffset (length): How far to push the text down the page. Want to do that inset text thing the book does? You can, the text can overlap with thte image.  Does nothing if no Img provided.
/// - BoxText (dictionary): Pairs of values to go in the box over the image. Does nothing if no Img provided.
/// - BoxAnchor (str): Which anchor of the image to put the box in?  Sample values are "north", "south-west", "center".
/// - FirstPageContent (content): Goes on the first page. If no image is provided, it is not present.
/// - AfterContent (content): Goes after the stat block. Always present.
/// -> content

// Example 
#FCVehicleFancy(
  read("Sample Vehicle_stats.json"),
  Img: image("images/Wandelburg.png"),
  TextVOffset: 6.2in,
  BoxText: ("Role": "Fast Bomber", "First Flight": "1601", "Strengths": "Fastest Bomber"),
  BoxAnchor: "north-east",
)[
#lorem(100)
][
#lorem(100)
]
```

Last of the vehicles, FCShip is for boats like Into the Drink.
```typ
/// Defines the FlyingCircus Ship page.  Always on a new page. Image optional.
///
/// - Ship (str | dictionary): JSON string or dictionary representing the Ship stats.
/// - Img (image | none): Image to go at the top of the page. Set to none to remove.
/// - DescriptiveText (content): Goes below the name and above the stats table.
/// - notes (content): Goes in the notes section.
/// -> content

// Example: No builder for Ships, so you'll have to put it in your own JSON, or just a dict, like this.
#let ship_stats = (
  Name: "Macchi Frigate",
  Speed: 5,
  Handling: 15,
  Hardness: 9,
  Soak: 0,
  Strengths: "-",
  Weaknesses: "-",
  Weapons: (
    (Name: "x2 Light Howitzer", Fore: "x1", Left: "x2", Right: "x2", Rear: "x1"),
    (Name: "x6 Pom-Pom Gun", Fore: "x2", Left: "x3", Right: "x3", Rear: "x2", Up: "x6"),
    (Name: "x2 WMG", Left: "x1", Right: "x1"),
  ),
  DamageStates: ("", "-1 Speed", "-3 Guns", "-1 Speed", "-3 Guns", "Sinking"),
)

#FCShip(
  Img: image("images/Macchi Frigate.png"),
  Ship: ship_stats,
)[
  #lorem(100)
][
  #lorem(5)
]
```

Additional functions include FCWeapon
```typ
/// Defines the FlyingCircus Weapon card. Image optional.
///
/// - Weapon (str | dictionary): JSON string or dictionary representing the Weapon stats.
/// - Img (image | none): Image to go above the card. Set to none to remove.
/// - DescriptiveText (content): Goes below the name and above the stats table.
/// -> content

//Example 
#FCWeapon(
  (Name: "Rifle/Carbine", Cells: (Hits: 1, Damage: 2, AP: 1, Range: "Extreme"), Price: "Scrip", Tags: "Manual"),
  Img: image("images/Rifle.png"),
)[
Note that you can set the text in the cell boxes to whatever you want.
]
```

KochFont:
```typ
/// Sets the tex to the Koch Fette FC font for people who don't want to remember the font name.
///
/// - body (content)
/// - ..args: Any valid argument to the text function
/// -> content

// Example 
#KochFont(size: 18pt)[Vehicles]
```

and HiddenHeading, which is for adding to the table of contents without actually putting words on the page.
```typ
//If we don't want all our planes at the top level of the table of contents.  EX: if we want
// - Intro
// - Story
// - Planes 
//   - First Plane
// We break the page, and create a HiddenHeading, that doesn't show up in the document (Or a normal heading, if that's what you need)
//Then we set the heading offset to one so everything after that is indented one level in the table of contents.
#pagebreak()
#HiddenHeading[= Vehicles]
#set heading(offset: 1)
```
