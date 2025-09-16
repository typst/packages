# tud-letter

A Typst template that (more or less) replicates the [TUDelft letter](https://www.tudelft.nl/huisstijl/) (only available in Word).
It also makes it more beautiful IMO, but hey I guess it's subjective...

By default it's in English and the faculty name is my faculty... but you can modify it, see the example. 
You can also put `lang: "nl"` so that the fields top-left are in Dutch.

## How to use it?

You can compile the example letter with this command:

`typst compile --root . template/letter.typ`

Notice that you can also install the package manually to your local Typst, see instruction there:
<https://github.com/typst/packages?tab=readme-ov-file#local-packages>


## Example

```typst
#import "../src/lib.typ": *

#show: tud-letter.with(
  from: (
    name: "Jan Smit",
    phone: "+31 (0)15 27 12345",
    email: "j.smit@tudelft.nl",
  ),
  to: [
    Gerard Joling \
    Singer of the year \  
  ],
  date: datetime.today().display(),
  subject: "A very important letter",
)

Dear Gerard, 

#lorem(60)

#lorem(100)

#v(1cm)
Best regards, 
#v(3mm)
Dr Jan Smit \
Head of an important department
```
