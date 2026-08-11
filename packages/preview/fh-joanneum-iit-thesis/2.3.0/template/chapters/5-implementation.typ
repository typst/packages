#import "global.typ": *

= Implementation <implementation>

#lorem(35)#v(0.3cm)

#todo(
  [ Describe what is relevant and special about your working prototype. State how
  single features help to solve problem(s) at hand. You might implement only the
  most relevant features. Features you select from your prioritised feature list
  assembled in Chapter 4. Focus novel, difficult, or innovative aspects of your
  prototype. Add visuals such as architectures, diagrams, flows, tables,
  screenshots to illustrate your work. Select interesting code snippets, e.g. of
  somewhat complicated algorithms, to present them as source code listings.

  #v(1.4cm)
  *For example*, you might explain your overall system, then the details of
  the backend and frontend development in subsections as shown here:

  == Overall System <architecture>

  #lorem(35)#v(0.5cm)

  *Hints for images in Typst*

  Use vector graphic formats such as #gls("svg") for drawings and png for screenshots.
  Using jpeg is only ok, if you need to show photographic images, such as a picture of a sunset.

  For example, the following shows how an #gls("svg") image is references using the `image` Typst macro.
  The image is furthermore embedded in a `figure` macro. The `flex-caption` allows to
  include a full sentence as caption below the image and a short caption for the list of figures.
  Also note the use of a label `<fig:companylogo>` which is later referenced with `@fig:companylogo`:

])


#figure(
    box(stroke: gray, inset: 1em,
      image("/figures/logo.svg", width: 25%)
    ),
    caption: flex-caption(
        [The logo of the FH JOANNEUM, the University of Applied Sciences.],
        [Company icon provides _Home_ navigation]
    )
  )<fig:companylogo>

#todo([
  The application uses the logo of the company, see @fig:companylogo, in
  the navigation bar to provide _home_ functionality.
])

#todo([
  == Backend <backend>

  #lorem(35)#v(1.3cm)

    *Hints for code listings in Typst*:

  The way to include source code in your document is
  discussed and shown in #link("https://typst.app/docs/reference/text/raw/").
  For this template we provide a custom macro/function _fhjcode_ to support listings with
  code pulled in from external files and with line numbering. For example:

  *For example:* We implemented a minimal #emph[script] in Python to manage a secure `Message`s
  in object oriented ways. See @lst:Message and @lst:SecureMessage for a minimal `SecureMessage` class.
  ])

  #figure(
    align(
      left,
      // we use a custom template (style), defined in fh.typ
      // the files are expected in subfolder "source"
      // optionally, specify firstline/lastline
      fhjcode(code: read("/code-snippets/msg.py"), lastline: 5),
    ),
    // we use a custom flex-caption), to allow long and short captions
    // (the short one appears in the outline List of Figures).
    // This is defined in `lib.typ`.
    caption: flex-caption(
      [Defining a base class in Python. Here, the base class is named _Message_.], [Base class _Message_.],
    ),
  ) <lst:Message>


  #figure(
    align(
      left, fhjcode(code: read("/code-snippets/msg.py"), firstline: 7, lastline: 9),
    ), caption: flex-caption(
      [For inheritance we might define a specialised class based on another class.
        Here, the specialised class _SecureMessage_ is based on the class _Message_.],
      [Specialised class _SecureMessage_.],
    ),
  ) <lst:SecureMessage>


#let console_code="# python3 -m venv .venv
The virtual environment was not created successfully because ensurepip is not
available.  On Debian/Ubuntu systems, you need to install the python3-venv
package using the following command.
"

#figure(
  align(
    left, fhjcode(code: console_code, language:"console"),
  ), caption: flex-caption(
    [Create a virtual environment to later add locally installed libraries using `pip`.],
    [Python virtual environment.],
  ),
)


#todo([
  *For example:* As shown in @lst:SecureMessage the secure version of the class
  (which can be found in file #filename("./src/SecureMesssage.py")) just a
  stub where further improvements and extensions have to be applied.
  The statistics on the souce of the project can be created by executing
  command #command("cloc .") in the base directory.
  _Cloc_ stands for count lines of code.
])


#todo([

  == Frontend <frontend>

  #lorem(35)#v(1.3cm)


  *Hints for abbreviations and glossary entries _gls(key)_ in Typst*:

  Abbreviations should be written in full length on the first occurrence. Later
  the short version can be used. Therefore, define glossary entries with a _key_ and
  a _short_ as well as a _long_ description first (see file _glossary.typ_). In
  the text you might use `#gls(<key>)` (and `#glspl(<key>)` for plural) usage of
  an abbreviation. For example:

  The system is using #gls("cow") for optimisation. The implementation of #gls("cow") can
  be changed by ... Note the usage of the special configured #gls("gc"). We
  compared many #glspl("gc") to find out .. ],
)
