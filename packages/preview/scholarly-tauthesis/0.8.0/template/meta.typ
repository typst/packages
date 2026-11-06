/** meta.typ
 *
 * Defines document metadata. Fill in the information regarding
 * your thesis into the commands specified here.
 *
***/

//// Common metadata.

#let author = "Firstname Lastname"
#let date = datetime.today()
#let examiners = (
	(
		title : "Professor",
		firstname : "Firstname",
		lastname : "Lastname",
	),
	(
		title : "University lecturer",
		firstname : "Firstname",
		lastname : "Lastname",
	),
)

/**
 * One of "fi" or "en".
***/

#let language = "fi"

/**
 * This allows you to choose a citation style. See
 * <https://typst.app/docs/reference/model/bibliography/#parameters-style>
 * for possible options.
***/

#let citationstyle = "ieee"

/**
 * Set this to false if you are an international student and do
 * not need a Finnish abstract.
***/

#let include-finnish-abstract = true

/**
 * Set this to true before compiling your document, if you intend
 * to print a physical copy of it.
***/

#let physically-printed = false

//// Finnish metadata.

#let alaotsikko = [Alaotsikko] // or none
#let avainsanat = ("avainsana1", "avainsana2")
#let koulu = [Tampereen Yliopisto]
#let tiedekunta = [Tiedekunta]
#let otsikko = [Opinnäytetyöpohja]
#let työntyyppi = [Diplomityö]
#let sijainti = [Tampereella]

//// English metadata.

#let faculty = "Faculty"
#let keywords = ("keyword1", "keyword2")
#let university = [Tampere University]
#let subtitle = [Subtitle] // or none
#let thesistype = "Master's thesis"
#let title = "Thesis template"
#let location = "Tampere"
