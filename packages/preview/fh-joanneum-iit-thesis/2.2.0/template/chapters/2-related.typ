#import "global.typ": *

= Related Work

#lorem(37)

#todo(
  [
    Describe the work of other research teams and noteworthy approaches related to
    your work. State what is different to your solution.

    + Related literature might/should contain: theoretical foundations,
      - definitions of key terms,
      - technologies, techniques,
      - and/or a literature review

    + Note on the size and quality of your bibliography:
      - BA about 30-40 references
      - MA about 60-100 references

    Furthermore, check: Are the reference (too) old? Did you include papers from
    scientific databases, such as ACM or IEEE? Can the reader find your sources?
    (e.g. check if you named the publisher for books, or specified DOIs for
    scientific papers)
    #v(2cm)
  ])


  #todo([
    *Citation hints when writing in Typst:*

    A single citation is possible with the \@Eco:2010 (i.e. using the _at_ sign),
    such as @Eco:2010. Find in #cite(<acm:diglibrary>) and/or #cite(<ieee:xplore>) the
    latest scientific findings. For citing multiple references, just name them one
    by one, such as #cite(<Alley:1998>) #cite(<Booth:2008>)
    @Batina:2011
    @Brooks:1975
    @Chen:2021
    @Chen:2023
    @Eco:2010
    @Fernandez-Mir:2011
    @Field:2003
    @Gamma:1994
    @Google:2016a @Google:2017a
    @Li:2008
    @Shaw:2002
    @Strunk:2000
    @Wisconsin:2004
    @Yin:2013
    @Chen:2023
    @Zobel:2004
    and they will be listed within the _(_ _)_ round brackets separated by a _;_ semicolon.

    The usage is typically as following:
    #sym.dots.h.c #cite(<Gamma:1994>, form: "prose") found that #sym.dots.h.c
    #sym.dots.h.c #cite(<Eco:2010>, form: "prose") argues that #sym.dots.h.c
    #sym.dots.h.c #cite(<Field:2003>, form: "prose") have stated that #sym.dots.h.c
    #sym.dots.h.c caching can increase the system load @Yin:2013,
    but the overall memory consumption limits the maximum cache size @Wisconsin:2004[pg~12].
    If we know where a text of relevance is presented inside an article, we might
    specify the page number also, see @Yin:2013[p.~7]. If you want to cite without
    parantheses, you specify _form_ as _prose_, as shown here with #cite(<Shaw:2002>, form: "prose").

    Shaw discusses different research strategies.
    #directquote([The most common research strategy in software engineering
      solves some aspect of a software development problem by producing a new procedure
      or technique and validating it by analysis or by discussing an example of
      its use; examples of use in actual practice are#sym.dots],
      bibkey: <Shaw:2002>, supplement: [p3]).
    It can be seen, that prototype implementation is a central part of you scientific work.
  ],
)

#todo([
  #v(2.3cm)
  *Hints for footnotes in Typst*:

  As shown in #footnote[Visit https://typst.app/docs for more details on formatting the document using
    typst. Note, _typst_ is written in the *Rust* programming language.] we might
  discuss the alternatives.
])
