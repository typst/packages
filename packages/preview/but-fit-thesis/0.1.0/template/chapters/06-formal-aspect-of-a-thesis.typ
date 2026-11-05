#import "../common.typ": *

= Formal aspect of a thesis
<ch:formality>
The formal requirements for writing a bachelor's or diploma thesis are based on rector's directive no. 72/2017 @smernice and FIT guideline no. 7/2018 @smerniceFIT. Formal aspect of a thesis is an important part of reviewer's assessment and should be given some attention (it is necessary to familiarize yourself with the mentioned directives). Other instructions and recommendations are listed on faculty web pages @formalniBP, @formalniDP.

Required length of the thesis text without appendices is shown in table @tab:rozsah:

#figure(
  table(
    columns: 4,
    align: (left, center, left, left),
    table.header([], [Minimal length], [Usual length], [Length should \ not exceed]),
    [Bachelor's thesis], [40], [60--80], [100],
    [Semester project (SEP)], [20], [30--40], [50],
    [Dissertation], [50], [80--100], [120],
  ),
  caption: [Required thesis text length in standard pages],
)
<tab:rozsah>
The length of typeset pages will be roughly 1/2 of the extend in standard pages. The term #emph[standard page] applies to evaluating the volume of a thesis, not the number of printed sheets of paper. From a historical standpoint it's approximately the number of pages of handwriting, that used to be typed on a typewriter to pre-printed forms at the usual line length of 60 symbols and 30 lines per page. Considering the need for proofreading marks, the line spacing value used to be 2 (every second line). This data (number of symbols per line, number of lines and the spacing between them) are in no way related to the final printed product. Their only use is to assess the length. #strong[Therefore, one standard page means $upright(bold(60 dot.op 30 = 1800))$ symbols including whitespaces.] Images inserted in text are counted towards the length of the thesis by estimating the amount of text it replaces in the final document.

To estimate the number of standard pages, you can extract the plain text from a PDF (e.g. use cut-and-paste or #emph[Save as Text...]) and divide it's size by 1800.

In Microsoft Word the approximate length of the thesis in standard pages can be computed using the #emph[Word Count] function in #emph[Tools] menu if you divide #emph[Symbols (spaces included)] by 1800. Only the core of the thesis is counted towards it's length. Parts such as abstract, keywords, declaration, table of contents, references or appendices do not count towards the length of the thesis. It is necessary to select the core of the thesis first and then have the software count the number of symbols. Assess the length of images manually. The same procedure can be applied when using OpenOffice or LibreOffice.

Original text dealing with the assignment, where the solution is core of the thesis, must be at least a third of the entire thesis text. A mere compilation of available sources is unacceptable.

The subject of reviewer's assessment is primarily the text and final product. Needlessly large number of pages is the evidence of poorly processed topic and a burden for the reviewer. Theses, where the length of text report is equal to amount of work done can be longer and enriched with explanatory text. The explanation of the essence of solved problem and the procedures used to solve it does not have to increase at a linear rate with the amount of work. Well structured and comprehensive text report can be of relatively small length. Detailed descriptions of significant parts of project, that are more of a documentary (rather than explanation), can be included in appendices and referenced from the main text.

If the length of a text report is close to the minimal required length, reviewer will focus heavily on whether or not individual parts of the report for understanding the thesis are really necessary. The inclusion of foreign texts, that only vaguely relate to the topic of the thesis or ones that are questionable, in attempts to reach at least the minimal required length (for example not enough time just before the submission deadline), can lead to a~much worse overall review of the thesis.

When you insert an image, choose the dimensions carefully so that they do not overlap the are for text printing area (i.e. text margins on all sides). Put large images on a~separate page. Images or tables that are larger than A4 dimensions can be folded (so-called Engineering fold, similar to Z-fold but doesn't make issues with binding) and included in the main text (if it is crucial for the thesis), appendices or fold it and put to the pocket on the back side of the binding.

Images and tables use their own, independent numerical series. This means that references in the text must state if it is an image or a table as well as the number (for example "... #emph[see table 2.7] ..."). It's rather natural to comply with this principle.

When it comes to references to pages, chapter and subchapter numbers, image and table numbers and many other examples, we use special tools provided by the desktop publishing program, that can generate the correct numbers even if the text moves due to changes made to the text itself or changes to typesetting parameters.

Equations referenced in the text will be provided with serial numbers on the right side of their respective line. These ordered numbers are surrounded by round brackets. Equations numbering can be in order within the whole text or within individual chapters.

There is no space between a number and letters that form a single word or a symbol -- for example #emph[25x]. In a paragraph, it is better to spell both out though -- for example #emph[ten times].

Punctuation symbols such as a dot, comma, semicolon, colon, question mark and exclamation mark, and even closing brackets and quotation marks are adjacent to the preceeding word, without a space. The space comes after the punctuation symbol itself. This, however, does not apply to decimal point. Opening brackets and quotation marks are adjacent to the following word and the space in front of them is excluded -- (like this) and "this".

We do not use the same symbol for connecting and separating dash, and a regular dash. There is a special (longer) character for a dash. The connecting dash (hyphen) is used in compound words (e.g. "Brno-center"), the en dash for intervals or pairs, opponents and others (e.g. "price 23--25 crowns", "match England -- Belgium"), and the em dash to separate a section of a sentence, an inserted sentence expressing unspoken thoughts and in other situations (see orthography) (e.g. "Another term --- no matter how pointless it seems --- will be defined informally in the following paragraph."). A~mathematical minus symbol is yet another character, typeset in math mode.

Rules for the use of abbreviations in different languages are listed in their respective orthography books (e.g. Pravidla českého pravopisu @Pravidla). There are other reasons to always have one of these close.

== Common errors
<sec:chyby>
This chapter contains a selection of the most common errors as well as advice on how to avoid them, taken from professor Herout's blog @Herout and from the list of common errors that assistant professor Szöke posted on their blog @chyby.

#heading(level: 3, numbering: none, outlined: false)[Minor things that notoriously ruin reading]
- #strong[Using hyphens instead of dashes] \
  A dash is long and there should be whitespace surrounding it. Dash is very often used instead of a dot in sentences: "This book -- published before the war -- is amazing." It is also used for ranges: "page 23--26" or "success rate of 3--5 %." More examples can be found in the language handbook @prirucka.

  Hyphens occur in our IT theses very rarely (at least they should). A good example would be phrases or joining subjects "Rh-factor", "real-time", "propane-butane".

-  #strong[Brackets surrounded by whitespaces] \
  There always is a whitespace in front of the opening parenthesis or brace (when referencing literature). There is no space after the closing parenthesis or brace, if they're immediately followed by a dot, comma, exclamation mark or question mark. There are no whitespaces inside the brackets.

Here's a brief overview of common stylistic and language sins.

- Correct in english:

  - "by using the OpenGL library"

  - "in the MVC model"

  - "all UI elements"

  - "from the JSON string"

  - "call it from C\# code"

  Incorrect in czech:

  - "s použitím OpenGL knihovny"

  - "v MVC modelu"

  - "všechny UI prvky"

  - "z JSON řetězce"

  - "volat ji z C\# kódu"

  Correct in czech:

  - "s použitím knihovny OpenGL"

  - "v modelu MVC"

  - "všechny prvky UI" -- nebo ještě radši "všechny prvky uživatelského rozhraní"

  - "z řetězce ve formátu JSON"

  - "volat ji z kódu v jazyce C\#"

-  #strong[Sentences without verbs] \
  Every single sentence needs a verb. Sentences without verbs are sometimes used for artistic purposes in poetry. Over the course of the last two weeks, I have read countless sentences without verbs in them and it never quite worked, always lead to a negative outcome. Make sure every sentence of your thesis has a verb in it.

#heading(level: 3, numbering: none, outlined: false)[Figures (almost) without captions]
Figure (similar with a table) consists of the image itself and it's caption. The caption of a figure or a table is there to make sure the final object works as a~standalone object -- reader checks the figure often even before reading the surrounding text and therefore it is expected that they can understand the figure even without reading the text.

I wouldn't worry about five to seven lines long figure captions. Two lines will do just fine at times. Sometimes -- not very often -- captions consisting of just three words are the best ones. If all the captions in a thesis consist of only three to four words, the reader will most likely be frustrated, because the figures make no sense whatsoever.

If a figure contains a colorful code (some objects are red, some are blue and others thick green), proper explanation of code must be a part of the caption. If a figure consits of parts (for example top right, top left and bottom), naming and explanation for each part belongs in the caption.

Whenever I tell my students this, they get anxious about the whole thing: "But that means I have to move entire sentences from text to the captions!" Yes, move them, there's nothing wrong with that. The basic explanation will be a part of the figure and that's how it should be. More detailed explanation, reasoning and interpretation should remain in the text itself. Twenty lines long caption for a figure or table is too long, but five lines long caption is a standard.

#heading(level: 3, numbering: none, outlined: false)[Grammatical person]
Using #strong[second-person] (addressing the reader with "You/you") is almost always wrong and it gets annoying very quickly.

Incorrect:

- "If you look at figure 5, you'll see ..."

- "If you work with library X, I'm sure you'll stumble upon ..."

- "If you want to switch to settings, select the respective option in menu."

Correct:

- "Figure 5 shows ..."

- "A commonly occuring thing when using library X is ..."

- "Settings can be accessed by selecting the respective option in menu."

Using #strong[first-person plural] ("we") is not always wrong either and "classic" literature about writing technical text sometimes even recommends it as so called "author's plural":

- "We found out ...",

- "We focused on ...",

- "We designed a solution, that ...".

Less experienced writers often switch from author's plural to some weird and incorrect language mode, that has a common occurence in kindergarten. This is how teachers in kindergarten speak (nothing against them otherwise): "Alright kids, let's glue a bead right in the middle of the flower. Now we push out a bit of glue, yeees, and we push the bead into it with a finger, juuust like that."

It's not funny and cute, if diploma student uses this language to describe their life's work: "First we need to link library X. Then we create objects of selected classes and send them to a server one by one. When the server responds with an error code, we must reset the connection." Do not use this language mode if you wish for your thesis to be perceived as a work of someone who is not on the mental level of a child in kindergarten.

Using #strong[first-person singular] (“I“) is correct, when it comes to a matter of subjectivity:

- "I focused on ...",

- "I created ...",

- "I measured ...",

- "I addressed several respondents ..."

It is incorrect (and unfortunately quite common) to use first-person in the description of procedures and phenomena:

- "In the first step of the algorithm, I reset counters."

- "If the pointer points to null, I allocate new object."

- "It's clear from the graph that the cache size I used is too small."

#heading(level: 3, numbering: none, outlined: false)[Other errors]
#strong[Don't cite stupid things:] Information in introduction about the fact that internet is available even on Mount Everest can seem like a thing, that needs to be confirmed. Nevertheless, this pointlessly inflates Literature with a lot of irrelevant sources (not within the scope of your thesis) -- that can be a bad thing for you. Just don't write anything like that in your thesis, or don't cite it at least.

#strong[Abbreviations (and notes) in footnotes should make sense on their own. If your text contains an abbreviation, specify what it stands for when you first use it:] If an abbreviation occurs two chapters later, you need to specify what it stands for again when you first use it there, alternatively write a footnote addressing the abbreviation. It is important that the footnote contains the abbreviation too. If it's an abbreviation of a~phrase, feel free to translate it to the desired language.

Incorrect:

+ large-vocabulary continuous speech recognition

Correct:

+ LVCSR -- large-vocabulary continuous speech recognition

#strong[Don't leave text between a section and subsection out:] There should be a text between the titles of chapters and subchapter. This calls for 1 -- 2 paragraphs, where you explain what the chapter is about and what can the reader learn here.

#strong[Hand drawn sketches and images:] It's easier to quickly draw something, take a~picture of it and continue writing, especially when it comes to a work draft. Usually the initial sketch of a scheme is wrong and re-doing it takes precious time. I'd be careful with "hand work" in the final text. Some reviewers could see it as a false indication, that you did not have enough time, and so you decided to save time by doing some quick hand drawing.

#strong[Introduction and conclustion:] Typos, nonsensical sentences, errors, ungrammatical words, …Neither one of these belong in a thesis. An evasive typo can hopefully get lost deep in a thesis. Everyone reads the introduction and conclusion though. Making errors here is shameful. When you try to convince the committee members, that you did a big chunk of work, how is the fact that you can't read a single page of text going to affect the thesis review?

#strong[Cite figures:] If you "borrow" an image from a source, don't cite it and it is later discovered, you receive an F. Citation referring to literature at the end of the figure description is (probably) OK. Nonetheless, many reviewers prefer stating the source explicitly in brackets: (taken from literature \[xy\]).

#strong[Don't overdo it with chapters:] If a chapter has 1 -- 2 paragraphs in individual subchapters, try to think of a better way of doing it, like bullet points.

#strong[Notes in images:] Don't describe complicated images with "A is on the left side, B is at the top, C is in the middle, D is under that and next to it is XY." This results in a half of a page worth of text. And if the figure is not on the same side, the reader has to flip the pages til they die. Add captions to figures and it becomes a standalone figure.

#strong[Details belong to appendices:] Don't try to describe a complete class diagram, table diagram, object diagram, ... at any cost. Include one complete scheme and describe the basic components. Then you can focus on the core of the system (for example the three highlighted objects). Those are the key and they're the basis of your thesis. Description of other "supporting" objects (e.g. data loading and rendering) can be a part of an appendix. You can simply reference the appendix by writing: #emph[Detailed description of all classes and their methods can be found in Appendix 1.]

#strong[Avoid compound sentences that are too long:] If your sentence is the length of a paragraph (6.5 lines), by the time the reader reads third line, they already forgot the beginning of the sentence. Don't be afraid to split the compound sentence into smaller parts. Fire short sentences at the reader rather than suffocating them with loads of words. Alternatively, you can present information as a bulleted list.

#strong[Unbreakable spaces:] A typographical error such as leaving "s" at the end of a line as early as the title of your thesis is extremely shameful. There is something called non-breaking space, in other words a space, that prevents breaking the end of a line.
