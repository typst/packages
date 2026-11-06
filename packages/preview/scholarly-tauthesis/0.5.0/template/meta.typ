/** meta.typ
 *
 * Defines document metadata. Fill in the information regarding
 * you thesis into the commands specified here.
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

#let language = "fi"

#let citationstyle = "ieee"

#let include-finnish-abstract = true

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
