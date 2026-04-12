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
  #v(2.3cm)
  *Hints for footnotes in Typst*:

  Footnotes are also suitable for not that important references. References should not be listed in the bibliogrpahy.
  For example: As shown at the typst app homepage#footnote[Visit https://typst.app/docs for more details on formatting the document using
    Typst. Note, _typst_ is written in the _Rust_ programming language.] we might
  style the layout, figures, and text in different ways.
])


  #todo([
    *Citation hints when writing in Typst:*

    A single citation is possible with the \@Eco:2010 (i.e. using the _at_ sign),
    such as @Eco:2010. Find in #cite(<acm:diglibrary>) and/or #cite(<ieee:xplore>) the
    latest scientific findings. For citing multiple references, just name them one
    by one, such as #cite(<Alley:1998>) #cite(<Booth:2008>) and they will be listed within the _(_ _)_ round brackets separated by a _;_ semicolon.

    #fhjrevisionmark([ // during revising the thesis, we might mark parts (here: modified text)
    About different types of references

    - *Article:* In general articles published in *Journals* are of high quality
      @Shaw:2002 @Chen:2023
      . But note there is no guarantee for high quality. It always depends on the journal editors
      and the work of the peer reviewers.

    - *Paper:* Papers published in *Conference Proceedings*
      (the _book_, which includes all the research presented at a conference)
      are well suited to be cited
      @Batina:2011  @Chen:2021 @Fernandez-Mir:2011 @Li:2008
      .

    - *Preprint*: On preprint servers one might find not yet published research results
      @Wei:2025
      .

    - *Book:* It means much effort to write books.
      Books are typically checked by co-authors and/or editors
      @Alley:1998 @Booth:2008 @Brooks:1975  @Eco:2010  @Field:2003 @Gamma:1994 @Strunk:2000 @Yin:2013 @Zobel:2004
      .

    - *Online:* Electronic, online references can be in some cases also very suiting.
      Do not forget to note the timestamp of last retrieving an URL it as online sources might change over time.
      @Wisconsin:2004 @Google:2016a @Google:2017a
      .

    - *Norms:* Feel free to add as many norms @iso9241-11, whitepapers @Nakamoto:2008,
      and RFCs (can be generated#footnote(
      link("https://notesofaprogrammer.blogspot.com/2014/11/bibtex-entries-for-ietf-rfcs-and.html"))
      @rfc:2045
      as you like.

    - *Others:* Use other sources — such as simple blog entries — should be used only sporadic.
      Urls to git repositories or software tools might be not cited in the bibliography but
      just stated in footnotes, for example if you reference
      GitLab and GitHub#footnote[Manage your code ind GitLab #link("https://gitlab.com") or GitHub #link("https://github.com").].

    - References are often found in scientific databases @acm:diglibrary @ieee:xplore.

    ]) // end of revision mark for added text

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
