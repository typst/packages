#import "global.typ": *

= Implementation <implementation>

#lorem(35)


#todo([ Describe what is relevant and special about your working prototype. State how single features help to solve problem(s) at hand. You might implement only the most relevant features. Features you select from your prioritised feature list assembled in Chapter 4. Focus novel, difficult, or innovative aspects of your prototype. Add visuals such as architectures, diagrams, flows, tables, screenshots to illustrate your work. Select interesting code snippets, e.g. of somewhat complicated algorithms, to present them as source code listings.
])

#todo([
*For example*, you might explain your backand and your frontend development in subsections as shown here:

== Backend <backend>

We implemented a minimal #emph[script] in Python to manage a secure `Message`s in object oriented ways. The way to include source code in your document is discussed and shown in #link("https://typst.app/docs/reference/text/raw/").

See @lst:Message and @lst:SecureMessage for a minimal `SecureMessage` class.

#figure(
	align(left,

		// we use a custom template (style), defined in fh.typ
		// the files are expected in subfolder "source"
		// optionally, specify firstline/lastline
		fhjcode(code: read("/code-snippets/msg.py"), lastline:5)

	),
	// we use a custom flex-caption), to allow long and short captions
	// (the short one appears in the outline List of Figures).
	// This is defined in `lib.typ`.
	caption: flex-caption(
			[Defining a base class in Python. Here, the base class is named _Message_.],
			[Base class _Message_.]
			),
) <lst:Message>


#figure(
	align(left,
		fhjcode(code:read("/code-snippets/msg.py"), firstline:7, lastline:17)
	),
	caption: flex-caption(
			[For inheritance we might define a specialised class based on another class. Here, the specialised class _SecureMessage_ is based on the class _Message_.],
			[Specialised class _SecureMessage_.]
			),
) <lst:SecureMessage>

== Frontend <frontend>
	...

 ])
