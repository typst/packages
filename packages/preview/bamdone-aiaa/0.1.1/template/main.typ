//***************************************************************
// AIAA TYPST TEMPLATE
// 
// The author of this work hereby waives all claim of copyright
// (economic and moral) in this work and immediately places it 
// in the public domain; it may be used, distorted or 
// in any manner whatsoever without further attribution or notice
// to the creator. The author is not responsible for any liability 
// from the usage or dissemination of this code.
//
// Author: Isaac Weintraub, Alexander Von Moll
// Date: 22 MAR 2024
// BAMDONE!
//***************************************************************

#import "@preview/bamdone-aiaa:0.1.0": aiaa, b-equation, nomenclature
// #import "../lib.typ": aiaa, b-equation, nomenclature
#import "@preview/droplet:0.2.0": dropcap

#show: aiaa.with(
    title: "Preparation of Papers for AIAA Technical Conferences",
    bibliography: bibliography("refs.bib"),
    authors-and-affiliations: (
      (
        name:"First A. Author",
        job:"Insert Job Title",
        department:"Department Name",
        aiaa:"and AIAA Member Grade (if any) for first author"
      ),
      (
        name:"Second B. Author Jr.",
        job:"Insert Job Title",
        department:"Department Name",
        aiaa:"and AIAA Member Grade (if any) for second author"
      ),
      (
        institution:"Business or Academic Affiliation's Full Name 1",
        city:"City",
        state:"State",
        zip:"Zip Code",
        country:"Country"
      ),
      (
        name:"Third C. Author",
        job:"Insert Job Title",
        department:"Department Name",
        aiaa:"and AIAA grade (if any) for third author"
      ),
      (
        institution:"Business or Academic Affiliation's Full Name 2",
        city:"City",
        state:"State",
        zip:"Zip Code",
        country:"Country"
      ),
      (
        name:"Fourth D. Author",
        job:"Insert Job Title",
        department:"Department Name",
        aiaa:"and AIAA grade (if any) for fourth author"
      ),
      (
        institution:"Business or Academic Affiliation's Full Name 3",
        city:"City",
        state:"State",
        zip:"Zip Code",
        country:"Country"
      )
    ),
    abstract: [These instructions give you guidelines for preparing papers for AIAA Technical Papers. Use this document as a template if you are using Typst. Otherwise, use this document as an instruction set. Define all symbols used in the abstract. Do not cite references in the abstract. The footnote on the first page should list the Job Title and AIAA Member Grade for each author, if known. Authors do not have to be AIAA members.]
)

#nomenclature(
  ([$A$], [amplitude of oscillation]),
  ([$a$], [cylinder diameter]),
  ($C_p$, "coefficient of pressure"),
  ($C_x$, "force coefficient in the x direction"),
  ($C_y$, "force coefficient in the y direction"),
  ($c$, "chord"),
  ($d t$, "time stamp"),
  ($F_x$, [$X$ component of the resultant pressure force acting on the vehicle]),
  ($F_y$, [$Y$ component of the resultant pressure force acting on the vehicle]),
  ($f, g$, "generic functions"),
  ($h$, "height"),
  ($i$, "time index during navigation"),
  ($j$, "waypoint index"),
  ($K$, "trailing-edge (TE) nondimensional angular deflection rate")
)

= Introduction <sec:intro>

#dropcap(
  height: 2, 
  hanging-indent: 0em, 
  justify: true,
  overhang: 0em,
  gap: 0pt,
)[T #smallcaps([his]) document is a template for Typst. If you are reading a hard-copy or .pdf version of this document, download the  AIAA Meeting Papers Template from the Meeting Paper Author page at www.aiaa.org or from the Technical Presenter Resources page for the appropriate AIAA forum, and use it to prepare your manuscript.]

Authors using Microsoft Word will first need to save the AIAA Meeting PapersTemplate.dotx file in the “Templates” directory of their hard drive. To do so, simply open the AIAA Meeting Papers Template.dotx file and then click “File>Save As:” to save the template. \[Note: Windows users will need to indicate “Save as Type>Document\]

Authors using Microsoft Word will first need to save the AIAA Meeting PapersTemplate.dotx file in the “Templates” directory of their hard drive. To do so, simply open the AIAA Meeting Papers Template.dotx file and then click “File>Save As:” to save the template. [Note: Windows users will need to indicate “Save as Type>Document Template (\*.dot)” when asked in the dialogue box; Mac users should save the file in the “My Templates” directory.] To create a new document using this template, use the command “File>New>From Template” (Windows) or “File>Project Gallery>My Templates” (Mac). To create your formatted manuscript, type your own text over sections of the Template, or cut and paste from another document and then use the available markup styles. Note that special formatting such as subscripts, superscripts, and italics may be lost when you copy your text into the template. See Section @sec:formatting for more detailed formatting guidelines. 

= Procedure for Paper Submission <sec:procedure>
All manuscripts are to be submitted electronically to the ScholarOne Abstracts site created for each conference. The manuscript upload will be enabled several weeks after acceptance notices have been sent.  Presenting authors of accepted papers will receive an email with instructions when manuscript submission opens. It is important that presenting authors keep their email addresses up-to-date so they do not miss this notice.

Before completing manuscript submission, submitters must also select the copyright statement that will appear on the paper, and complete other acknowledgments.  It is also necessary to click both the “Accept” and “Save” buttons to complete a submission. All completed manuscript submissions will be confirmed by email. Completed submissions will also have a status of “Accepted” at the top of your manuscript submission page. All files must be in pdf format.  Please be sure that all security settings are removed from the pdf file before uploading to ensure proper processing of your manuscript file.

= General Guidelines <sec:guidelines>
The following section outlines general (nonformatting) guidelines to follow. These guidelines are applicable to all authors (except as noted), and include information on the policies and practices relevant to the publication of your manuscript.
== Publication by AIAA
Your manuscript cannot be published by AIAA if:
+	It has been published previously or
+	The work contains copyright-infringing material or
+ An appropriate copyright statement has not yet been selected.

== Paper Review and Visa Considerations
It is the responsibility of the author to obtain any required government or company reviews for their papers in advance of publication. Start early to determine if the reviews are required; this process can take several weeks.

If you plan to attend an AIAA Forum, technical conference or professional development course held in the United States and you require a visa for travel, it is incumbent upon you to apply for a visa with the U.S. embassy (consular division) or consulate with ample time for processing.  To avoid bureaucratic problems, AIAA strongly suggests that you submit your formal application to U.S. authorities a minimum of 120 days in advance of the date of anticipated travel.

Prospective conference and course attendees requiring a visa to travel to the United States should first contact AIAA to request an official letter of invitation. This letter and a copy of the conference call for papers should be presented along with the required documentation to the U.S. consular officials as part of the formal application process.  AIAA cannot directly intervene with the U.S. Department of State, consular offices, or embassies on behalf of individuals applying for visas. A letter of invitation can be requested by completing the Visa Invitation Letter Request Form at https://www.aiaa.org/events-learning/Forums or you may contact the Event Registrar at invitation\@aiaa.org for more information.

== Control ID Number vs Paper 
Your paper was assigned a control ID number at the time you submitted your abstract. It is critical that you reference the tracking number and conference name when contacting AIAA regarding your submission. The control ID number is not the final AIAA paper number. The paper number, which appears in the format AIAA-20XX-XXXX, will be used to refer to your paper in the program and in any publication format. It will not be assigned until shortly before the conference.  *Do not include a paper number anywhere on your paper, as this number will be stamped automatically in the top right corner of your paper at the time of processing.*

== Copyright
Before AIAA can print or publish any paper, the copyright information must be completed in the submission system. Failure to complete the electronic form correctly could result in your paper not being published. The following fields must be completed:
+	Clearance Statement
+	Non-Infringement Statement
+	Publication Status Statement
+	One Copyright Assignment Statement (Select either A, B, C, or D)

Be sure to read the copyright statements carefully. AIAA requires a copyright transfer from the author(s) to AIAA or a license to publish and distribute your material; government authors can assert that the work is in the public domain. If you are not sure which copyright statement to use, contact your legal department. Refer to AIAA’s Rights and Permissions page at www.aiaa.org for more information; AIAA cannot help you determine which statement to use. Do not include a copyright statement anywhere on your paper. The correct statement will be stamped automatically at the time of processing.

== Submission Deadlines
Manuscripts will be accepted for upload to the system from the receipt of the email invitation until the deadline set for the conference. You will be notified of the specific manuscript submission deadline in your acceptance letter, and the deadline will also be listed on the conference web page at AIAA.  Do not upload a draft version of your manuscript with the intent to upload a final version later. *Please review your manuscript very carefully before completing your submission to ensure that your paper is complete and final in all respects. Once the manuscript deadline has passed, you will be locked out of the manuscript site, so it is critical that you upload a final, carefully proofed document.*

Online conference proceedings will be made accessible to attendees who have registered for the “full conference” when the conference opens. Once the proceedings are published online, the conference papers will be considered the version of record and may not be removed or replaced. Changes to published papers can be made available through the Crossmark feature, where corrections and updates are accessed by clicking the Crossmark icon available on every paper published in Aerospace Research Central.

The opportunity to submit Crossmark updates will be provided to presenting authors starting the first day of the conference through 2000 hrs/8 pm Eastern Time, seven business days after the last day of the conference.  The proceedings will be updated with Crossmark updates shortly after that date.  AIAA will NOT accept changes and/or change requests that solely correct grammatical errors, spelling errors, or errors in formatting.  All corrections should be for editorially significant changes where the change affects interpretation or crediting of the work.

To ensure conference quality, session chairs will enforce a "no paper, no podium" rule. This policy is intended to eliminate no-shows, to improve the quality of the conference for all participants, and to ensure that the published proceedings accurately represent the presentations made at a conference. 

= Detailed Formatting Instructions <sec:formatting>

The styles and formats for the AIAA Papers Template have been incorporated into the structure of this document. If you are using Microsoft Word 2001 or later, please use this template to prepare your manuscript. For authors that prefer using LaTeX, AIAA has partnered with Overleaf to provide an online editor to create your manuscript in LaTeX. Please visit the AIAA LaTeX site for instructions. Regardless of which program you use to prepare your manuscript, please use the formatting instructions contained in this document as a guide. For authors that prefer Typst, please consider using this template.

If you are using the AIAA Meeting Papers template from Typst to prepare your manuscript, you can simply type your own text over sections of this document or cut and paste from another document and use the available markup styles. If you choose to cut and paste, select the text from your original Word document and choose Edit>Copy. (Do not select your title and author information, since the document spacing may be affected. It is a simple task to reenter your title and author information in the template.) Open the template file. Place your cursor in the text area of the template and select Edit>Paste Special. When the Paste Special box opens, choose “unformatted text” or “keep source formatting.” Please note that special formatting (e.g., subscripts, superscripts, italics) may be lost when you copy your text into the template. Use italics for emphasis; do not underline. Use the “Print Layout” feature from the “View” menu bar (View>Print Layout) to see the most accurate representation of how your final paper will appear.

== Document Text
The default font for AIAA papers is Times New Roman, 10-point size. In the electronic template, use the “Text” or “Normal” style from the pull-down menu to format all primary text for your manuscript. The first line of every paragraph should be indented, and all lines should be single-spaced. Default margins are 1” on all sides. In the electronic version of this template, all margins and other formatting is preset. There should be no additional lines between paragraphs.

Extended quotes, such as this example, are to be used when material being cited is longer than a few sentences, or the standard quotation format is not practical. In this Word template, the appropriate style is “Extended Quote” from the drop-down menu. Extended quotes are to be in Times New Roman, 9-point font, indented 0.4” and full justified.

NOTE: If you are using the electronic template to format your manuscript, the required spacing and formatting will be applied automatically, simply by using the appropriate style designation from the pull-down menu.

== Headings
The title of your paper should be typed in bold, 24-point type, with capital and lower-case letters, and centered at the top of the page. The names of the authors, business or academic affiliation, city, and state/province should follow on separate lines below the title. The names of authors with the same affiliation can be listed on the same line above their collective affiliation information. Author names are centered, and affiliations are centered and in italic type immediately below the author names. The affiliation line for each author is to include that author’s city, state, and zip/postal code (or city, province, zip/postal code and country, as appropriate). The first-page footnotes (lower left-hand side) contain the job title and department name, street address/mail stop, and AIAA member grade for each author. Author email addresses may be included also.

Major headings (“Heading 1” in the template style list) are bold 11-point font, centered, and numbered with Roman numerals. 

Subheadings (“Heading 2” in the template style list) are bold, flush left, and numbered with capital letters. Sub-Subheadings (“Heading 3” in the template style list) are italic, flush left, and numbered (1. 2. 3. etc.)

== Abstract
The abstract should appear at the beginning of your paper. It should be one paragraph long (not an introduction) and complete in itself (no reference numbers). It should indicate subjects dealt with in the paper and state the objectives of the investigation. Newly observed facts and conclusions of the experiment or argument discussed in the paper must be stated in summary form; readers should not have to read the paper to understand the abstract. The abstract should be bold, indented 3 picas (1/2”) on each side, and separated from the rest of the document by - blank lines above and below the abstract text.

== Nomenclatures
Papers with many symbols may benefit from a nomenclature list that defines all symbols with units, inserted between the abstract and the introduction. If one is used, it must contain all the symbology used in the manuscript, and the definitions should not be repeated in the text. In all cases, identify the symbols used if they are not widely recognized in the profession. Define acronyms in the text, not in the nomenclature. 

== Footnotes and References
Footnotes, where they appear, should be placed above the 1” margin at the bottom of the page. To insert footnotes into the template, use the Insert>Footnote feature from the main menu as necessary. Numbered footnotes as formatted automatically in the template are acceptable, but superscript symbols are the preferred AIAA style, in the sequence, \*, \†, \‡, \§, \¶, \#, \*\*. \†\†, \‡\‡, \§\§, etc.

List and number all references at the end of the paper. Corresponding bracketed numbers are used to cite references in the text [1], unless the citation is an integral part of the sentence (e.g., “It is shown in Ref. [2] that…”) or follows a mathematical expression: "$A + B = C$ (Ref. [3])." For multiple citations, separate reference numbers with commas [4, 5], or use a dash to show a range [6-8]. Reference citations in the text should be in numerical order.
In the reference list, give all authors’ names; do not use “et al.” unless there are more than 10 authors. Papers that have not been published should be cited as “unpublished”; papers that have been submitted or accepted for publication should be cited as “submitted for publication.” Private communications and personal website should appear as footnotes rather than in the reference list.
References should be cited according to the standard publication reference style (for examples, see the “References” section of this template). Never edit titles in references to conform to AIAA style of spellings, abbreviations, etc. Names and locations of publishers should be listed; month and year should be included for reports and papers. For papers published in translation journals, please give the English citation first, followed by the original foreign language citation.

== Images, Figures, and Tables
All artwork, captions, figures, graphs, and tables will be reproduced exactly as submitted. Be sure to position any figures, tables, graphs, or pictures as you want them printed. AIAA will not be responsible for incorporating your figures, tables, etc. (Company logos and identification numbers are not permitted on your illustrations.)
Do not insert your tables and figures in text boxes. Figures should have no background, borders, or outlines. In the electronic template, use the “Figure” style from the pull-down formatting menu to type caption text. You may also insert the caption by going to the References menu and choosing Insert Caption. Make sure the label is “Fig.,” and type your caption text in the box provided. Captions are bold with a single tab (no hyphen or other character) between the figure number and figure description.

#figure(
  // image("Picture1.png", width:50%),
  rect(height: 80pt, width: 150pt,[YOUR FIGURE HERE]),
  caption: [
    Caption of the figure should go below the figure.
  ],
)<a-figure>

Place figure captions below all figures; place table titles above the tables. If your figure has multiple parts, include the labels “a),” “b),” etc. below and to the left of each part, above the figure caption. Please verify that the figures and tables you mention in the text actually exist. Please do not include captions as part of the figures, and do not put captions in separate text boxes linked to the figures. When citing a figure in the text, use the abbreviation “Fig.” except at the beginning of a sentence. Do not abbreviate “Table.” Number each different type of illustration (i.e., figures, tables, images) sequentially with relation to other illustrations of the same type.

Figure axis labels are often a source of confusion. Use words rather than symbols. As in the example to the right, write the quantity “Magnetization” rather than just “M.” Do not enclose units in parenthesis, but rather separate them from the preceding text by commas. Do not label axes only with units. As in Fig. 1, for example, write “Magnetization, kA/m”  not just “kA/m.” Do not label axes with a ratio of quantities and units. For example, write “Temperature, K,” not “Temperature/K.”

Multipliers can be especially confusing. Write “Magnetization, kA/m” or “Magnetization, 103 A/m.” Do not write “Magnetization (A/m) x 1000” because the reader would not then know whether the top axis label in Fig. 1 meant 16000 A/m or 0.016 A/m. Figure labels must be legible, and all text within figures should be uniform in style and size, no smaller than 8-point type.


== Equations, Numbers, Symbols, and Abbreviations

$ integral_0^r_2 &F(r,phi) upright(d) r upright(d) phi = [sigma r_2 \/ 2(mu_0)] \ dot&  integral_0^infinity  exp(-lambda | z_j - z_i | ) lambda^-1 J_1 (lambda r_2) J_0 (lambda e_i) upright(d) lambda $ <equation1>

Be sure that the symbols in your equation are defined before the equation appears, or immediately following. Italicize symbols (T might refer to temperature, but T is the unit tesla). Refer to “Eq. (1),” not “(1)” or “equation (1)” except at the beginning of a sentence: “Equation (1) is…” Equations can be labeled other than “Eq.” should they represent inequalities, matrices, or boundary conditions. If what is represented is really more than one equation, the abbreviation “Eqs.” can be used. 

An example of using Equations can be used as follows: It can be referred to as @equation1. Note that this will work when it's an in-sentence equation. However, when a sentence begins with Equation, you will need to use the following to make it work:

#b-equation([@equation1]) when it starts at the beginning of a sentence.

Define abbreviations and acronyms the first time they are used in the text, even after they have already been defined in the abstract. Very common abbreviations such as AIAA, SI, ac, and dc do not have to be defined. Abbreviations that incorporate periods should not have spaces: write “P.R.,” not “P. R.” Delete periods between initials if the abbreviation has three or more initials; e.g., U.N. but ESA. Do not use abbreviations in the title unless they are unavoidable (for instance, “AIAA” in the title of this article).

== General Grammar and Preferred Usage

Use only one space after periods or colons. Hyphenate complex modifiers: “zero-field-cooled magnetization.” Avoid dangling participles, such as, “Using Eq. (1), the potential was calculated.” [It is not clear who or what used Eq. (1).] Write instead “The potential was calculated using Eq. (1),” or “Using Eq. (1), we calculated the potential.”

Use a zero before decimal points: “0.25,” not “.25.” Use “cm2,” not “cc.” Indicate sample dimensions as “0.1 cm x 0.2 cm,” not “0.1 x 0.2 cm2.” The preferred abbreviation for “seconds” is “s,” not “sec.” Do not mix complete spellings and abbreviations of units: use “Wb/m2” or “webers per square meter,” not “webers/m2.” When expressing a range of values, write “7 to 9” or “7-9,” not “7~9.”
A parenthetical statement at the end of a sentence is punctuated outside of the closing parenthesis (like this). (A parenthetical sentence is punctuated within parenthesis.) In American English, periods and commas are placed within quotation marks, like “this period.” Other punctuation is “outside”! Avoid contractions; for example, write “do not” instead of “don’t.” The serial comma is preferred: “A, B, and C” instead of “A, B and C.”

If you wish, you may write in the first person singular or plural and use the active voice (“I observed that…” or “We observed that…” instead of “It was observed that…”). Remember to check spelling. If your native language is not English, please ask a native English-speaking colleague to proofread your paper.
The word “data” is plural, not singular (i.e., “data are,” not “data is”). The subscript for the permeability of vacuum µ0 is zero, not a lowercase letter “o.” The term for residual magnetization is “remanence”; the adjective is “remanent”; do not write “remnance” or “remnant.” The word “micrometer” is preferred over “micron” when spelling out this unit of measure. A graph within a graph is an “inset,” not an “insert.” The word “alternatively” is preferred to the word “alternately” (unless you really mean something that alternates). Use the word “whereas” instead of “while” (unless you are referring to simultaneous events). Do not use the word “essentially” to mean “approximately” or “effectively.” Do not use the word “issue” as a euphemism for “problem.” When compositions are not specified, separate chemical symbols by en-dashes; for example, “NiMn” indicates the intermetallic compound Ni0.5Mn0.5 whereas “Ni–Mn” indicates an alloy of some composition NixMn1-x.

Be aware of the different meanings of the homophones “affect” (usually a verb) and “effect” (usually a noun), “complement” and “compliment,” “discreet” and “discrete,” “principal” (e.g., “principal investigator”) and “principle” (e.g., “principle of measurement”). Do not confuse “imply” and “infer.”
Prefixes such as “non,” “sub,” “micro,” “multi,” and "ultra" are not independent words; they should be joined to the words they modify, usually without a hyphen. There is no period after the “et” in the abbreviation “et al.” The abbreviation “i.e.,” means “that is,” and the abbreviation “e.g.,” means “for example” (these abbreviations are not italicized). 

= Conclusions <sec:conclusions>
A conclusion section is not required, though it is preferred. Although a conclusion may review the main points of the paper, do not replicate the abstract as the conclusion. A conclusion might elaborate on the importance of the work or suggest applications and extensions. Note that the conclusion section is the last section of the paper that should be numbered. The appendix (if present), acknowledgment, and references should be listed without numbers.

= Appendix <sec:appendix>
An appendix, if needed, should appear before the acknowledgments.

= Acknowledgments <sec:ackn>
An Acknowledgments section, if used, immediately precedes the References. Sponsorship information and funding data are included here. The preferred spelling of the word “acknowledgment” in American English is without the “e” after the “g.” Avoid expressions such as “One of us (S.B.A.) would like to thank…” Instead, write “F. A. Author thanks…” 

= References <sec:refs>
The following pages are intended to provide examples of the different reference types. All references should be in 9-point font, with the first line flush left and reference numbers inserted in brackets. You are not required to indicate the type of reference; different types are shown here for illustrative purposes only. The DOI (digital object identifier) should be incorporated in every reference for which it is available (see Ref. 1 sample); for more information on DOIs, visit www.doi.org or www.crossref.org. @example