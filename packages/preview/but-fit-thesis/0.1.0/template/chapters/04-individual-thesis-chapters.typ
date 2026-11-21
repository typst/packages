#import "../common.typ": *

= Individual thesis chapters
<ch:kapitoly>
In this chapter, We're going to talk about the meaning and recommended content of individual chapters a thesis. We have also included the recommendations from experienced supervisors.

Structure of a thesis changes depending on it's aim, progress made over time and achieved results. It's likely that you won't put all the things mentioned in this chapter in your technical report or that you will add an extra chapter that is not mentioned here. It's never a bad idea to plan the structure of your text in advance and consult your supervisor about it.

Individual chapters should be in a logical order. #strong[Use references.] #emph[In function XYZ, we implement mathematical formula, that we have derived in section 3.2, equation~7.] If you reference things further in the work, describe what you're referencing in roughly two sentences. The reader should not get lost in your work, don't make them flip pages. #strong[Each chapter should (within reason) make sense on it's own.] If some important terms, abbreviations or thoughts are integral to the whole thesis and appear time and time again, always explain them (as soon as you use them in a chapter). If the reader opens your work in the middle (for example chapter 4), they should not immediately drown in abbreviations and technical terms. @rady

Unless specified otherwise, the rest of this chapter is taken from professor Zemčík's personal web pages @Zemcik, blogs of professor Herout @Herout and assistant professor Szöke @rady, and web pages of professor Černocký @Cernocky and associate professor Beran @Beran.

== Table of contents
<sec:obsah>
Long text -- such as a thesis -- comes with automatically created table of contents. It MUST fit a single page in a thesis. I can see how it could be difficult to fit table of contents in a~single page when it comes to a book seven hundred pages long, but not in a thesis.

In a thesis, table of contant should only have first and second level headings, third level headings are not present as they are a bit too specific. Fourth level -- although it wouldn't be included in table of contents and only used in some chapters -- is just wrong in itself.

If the chapter headings are good, just by looking at the table of contents (no further information, without reading the abstract) any reader that somewhat understands the field must be able to recognize what the thesis is about. They can gauge the goal of the thesis. They know what modules the solution consists of and what the purpose of each module is. They can tell which and how many experiments were carried out during the research. They can also tell who the target reader of the thesis is -- who and what is it useful for. If they can't tell just by looking at the table of contents, the chapter headings are probably wrong and it's up to the author to fix that, or have a poorly written thesis. There is no third option.

== Introduction
<sec:uvod>
The first chapter is titled Introduction. It's purpose is to provide broader context of a~problem and define structure of the thesis in the form of an eptiome.

The length of an introduction should be roughly 1--2 pages of text. It is expected that the introduction is readable even by someone just "passing by", who is literate, lives in our time, on our earth and that's about it. They don't have to be an expert in the field. They should still be able to understand the introduction. It should be written in a way that makes it work as a standalone figure of literature and if anyone reads the it, they should understand what the thesis is about. It's also common that people only read the introduction.

=== Advice on thesis introduction from professor Zemčík
It is not appropriate to split introduction in subchaptes or include references in it -- it should be a figure of literature that is readable and "feasible", and it should be easy to read. When it comes to the inner structure of an introduction, it should be as follows:

- Roughly 5 lines long general introduction for a topic, based on well known words without any scientific terminology if possible (example given "computer, video" yes, "tree structure" no),

- short text explaining why the thesis is important in the given field, the importance for world and for us, what the relationship with studied field is and other important facts,

- short text about the past advances in the field, about it's current state, and even about things to look forward to in the future,

- you should write about "why I am interested in this" too, what lead you to choosing this topic and do you find interesting about it -- truthfully and honestly if possible,

- it's also a pretty good idea to write about the goals of the thesis (in your own words, not word for word from the specification),

- and finally, it is important to describe the structure of your thesis to make sure the reader knows where to look for things (example given "the following chapter contains..., described in chapter "xxx", in chapter 3 ..." etc.) --- don't forget that the introduction should be a manual to your thesis.

=== Advice on thesis introduction from professor Herout
It is not supposed to be "an introduction to the problem", but "an introduction to a small book" (technical report). After reading it, the reader should

+ have a pretty good idea what the book is about,

+ look forward to reading it.

=== Advice on thesis introduction from professor Černocký
Introduction is basically an "extension of specification". It contains:

- Why was it researched -- what is Your motivation?

- Project background -- is it a part of a research project? describe. Any industrial cooperation? describe.

- If a thesis is a collective effort, be clear about who is responsible for what

- What are the specific things you would like to share ("claims").

- What can the reader read about and where.

=== Advice on thesis introduction from associate professor Beran
Introduction should be brief (1 page). It should contain:

- Introduction to the problem (we're in the IT field, for example: image processing and not chip manufacturing),

- goal of the thesis -- one clear goal of a thesis and steps leading to it (there is only one goal, but there are many steps to reaching it (e.g. function library, creating a dataset))

- a brief summary of the entire thesis (an overview of existing solutions, introduce a~draft of my solution based on the existing ones, testing, evaluation, ...).

== Summary of the current state
<sec:stav>
This should be about 40--50 % of the length of your thesis. The purpose of the part is to familiarize the reader with the current state of technological field that is the subject of your thesis and introduce the apparatus used in thesis (mathematical, electronic, IT etc.) to them. It's not expected that the summary of current state will contain everything directly related to the thesis, but it should contain all the necessary information to make sure that a reader who is at least somewhat familiar with the field of your thesis can understands it. This part should be split in chapters, especially if it is a "multifield topic". This part should also "heavily" reference literature. The length depends on the type of your thesis, if it's theoretical this part will be much longer than in a practice-oriented thesis.

=== Advice on summary of the current state from professor Zemčík
It is appropriate to state at the beginning of this part what it contains and why, and that it is not "encyclopedic dictionary" of said field -- to make sure that reader doesn't get the impression that "something is missing". You should write the text in your own words, but you can essentially copy the cited literature. If you have to take a whole section of text longer than one sentence, it's necessary to distinguish it properly from the rest and cite the source. A thesis should only have as many of these as necessary and the maximum length of such text is (roughly) half a page.

It is best that you don't express your opinions about the technical content in this part -- the current state needs to be described, but not evaluated. Essentially, if someone wrote something in literature, you can use it in this section. The reason for this is that if an expert in field reads the thesis, they should have the option to skip this part (they're an expert, I'm sure they're familiar with it) and not lose out on anything important in the thesis itself. It is advised to write this part as you make progress, while the literature is still in your brain -- so you don't have to read it again.

=== Advice on summary of the current state from professor Herout
Chapter describing what needed to be studied should take about 45 % of the thesis.

I intentionally avoid the word "theory" that would fit this part of a thesis well. It's because the word theory has this magical property to trigger the urge to write purposeless text on various topics more or less relevant to the topic of a thesis, but also topics that are very distant.

You should ask yourself "Is this information necessary to understand what I designed and implemented?" whenever you're about to write a paragraph. If the answer is no, don't bother.

This part of the thesis text can often be comprised of two chapters. If you're developing a web-based accounting system, one chapter should be about accounting and the other one about safe web systems. Here's a typical example: lots and lots of IT solutions need to be studied as a field of work (where can the system help) and as a tool (process of developing such systems).

=== Advice on summary of the current state from assistant professor Szöke
This chapter (there can be more of them) is where you show that you understand the problem. You've studied the usual solutions to your problem, state why your solution is different from the others and why is it better. Theory is a great source of entries for the bibliography. Your grandmother does not need to fully understand this chapter, but it's a good idea to leave the mathematics for a second and summarize what your calculations and derivatives actually mean. It is especially useful should the reader lose themselves in the text, this will help them find their way back.

=== Advice on summary of the current state from professor Černocký
Theoretical part should be about 10 pages long, perhaps a bit longer when it comes to more theoretical theses. You should only write about the theory necessary for your thesis.

- Only describe what you actually need, we're not interested in contents of a script, book, wikipedia ...

- If you use formulas, you need to provide an explanation for every single symbol and it needs to be clear what the purpose of each formula in your thesis is. Don't use formulas "just to illustrate" or "to make it look more scientific".

- If a theoretical part is too complicated (for example HMM & co.), don't write about all of it, write about the basics instead and cite a good source to "pinpoint" what is absolutely necessary for your thesis.

=== Advice on summary of the current state from associate professor Beran
Theoretical part should contain:

- existing solutions from the perspective of your specification,

- what already exists in the field of my thesis, what other solutions of my specification exist,

- what existing tools and procedures could be used as a part of the solution,

- any and all theory should be #strong[emphasized] (state why it is important that the reader is familizarized with it and how it relates to the solution your thesis offers).

== Data
Data is the key feature of any project that deals with recognition and this chapter should not be missing. Recommended length is single digit of pages. Describe:

- where did you get the data (producer, catalogue number, etc.),

- technical description -- e.g. Fs, bit width, number of speakers, audio length, etc.,

- dividing data in subsets -- training, development, testing, evaluation -- who did what (it's best to use existing subsets).

This chapter will probably not be a part of your thesis, unless you work on for example sound processing for real-time play.

This chapter will be a part of theses, that work with data sets, that are processed daily on different workplaces and allow for comparison of results, or theses that were given data sets for testing purposes.

== Assessment of the current state and work plan (draft)
<sec:navrh>
The main goal of this part is to write an evaluation of the current state and draft of your innovative solution.

=== Advice on assessment of the current state and work plan from professor Zemčík
It is advised to include this part of thesis. It's length should be "as long as you need it to be". The purpose of this part is to set a goal of your thesis based on the assessment of the current state and create your own "detailed specification", alternatively set the expected parameters of a solution, but not the the actual solution. This part should contain:

- Critical assessment of the current state (what is correct, what is wrong, what is not researched at all and possibly cost paramateres, availability of solution, necessary computing performance etc.),

- draft, what should be researched and solved based on the knowledge of the current state and personal preferences, specification, requirements etc.,

- given options even a specification of thesis, as in "what should it do", "what should the parameters be", "what tools will be used", "how is it going to be evaluated", "how do you know that you were successful".

It is advised to write a truthful deliberation in this part, especially when it comes to "draft" so that the rest of the thesis is credible and to convince the reader that all necessary steps were taken, after reading this chapter and the rest of the text.

=== Advice on draft of a solution from professor Herout
This part should contain ideas that the thesis brings:

- I decided to.

- I devised.

- I laid out.

- I calculated.

- I derived.

- I simplified.

- I improved.

- I designed.

- I found out.

- I researched.

Sometimes it's difficult to separate new ideas and implementation. Programmer confuses "designed" with "programmed". It's also easy to confuse "I improved" with "The results are". But separating these chapters is correct.

Theses in many non-IT fields are structured as research theses called "scientific methods". In our environemnt (lets assume engineer's decree IT study), theses don't follow this structure. Our theses (not entirely wrong in my opinion) are more similar to project documentation. It still is the correct way to separate hypothesis from a draft, how to validate them, and from their actual validation or assessment.

=== Advice on draft and description of your algorithm from associate professor Černocký
If the purpose of your thesis is "science", this part will probably be the longest one and it's advised to split it into multiple chapters -- for example "Basis", "Innovation, ...", "Results and discussion". On the other hand, if the purpose of your thesis is to try something existing/new, this chapter can be very brief. The length of this chapter should be roughly 10 pages and contain:

- what specifically did you do with the theory described above -- block scheme, setting constants, technical simplification of complicated theory etc.,

- draft -- can be a simple block scheme or a full object draft, but it should be clear that your SW has structure.

- choice of OS, programming language and libraries. The point of thesis is not to write everything on your own, you can use any and all free and commercial programs, libraries, modules, etc -- essentially anything -- it's a standard engineer's decree thesis -- the goal is to #strong[make it], not to #strong[write everything alone]. You do, however, need to describe everything in detail and cite sources, not plagiarize work of others!. Libraries have a good, accurate specification -- where from, which version, if it needed to be paid for, how much did it cost.

=== Advice on draft of a solution from associate professor Beran
What it comes drafting a solution, it depends on the specification -- the following points are not general. The length of this part should be about a third of the pages.

- Write from the perspective of a well paid expert on thoughts, that drafts a solution to problem, innovative solution, solution full of interesting thoughts.

- The "draft" part can be perceived as a procedure/tutorial to a solution, this draft is then passed to a team of programmers and testers, that realise and test the draft.

- If possible, it should be a general draft, without considering implementation on iOS or Android, Linux or Windows, MySQL or Postgres, HTML5 or Flash.

- Detailed specification analysis, detailed specification and formulation of goal and it's parts.

- Description of solution application, situations and problems that the project solves.

- Work procedure or steps leading to the goal, split the whole project into parts.

- Draft of the entire solution as well as it's parts, including references to theoretical part.

- Analysis of the results over time (measuring, observing, testing).

- Draft development and updates.

- If you update the draft based on the results of tests -- include references to tests and their results.

== User interface
This chapter is only useful in some theses and it should only be a handful of pages long. In some theses, it just doesn't fit at all. If it's necessary, it should be included (even prior to a draft) and contain: @Cernocky:

- UI concept -- what was the inspiration (existing programs, classic mechanical device...) -- write about it,

- mockup -- if you made any hand drawings, don't hesitate to include them!

- how did you choose the final version,

- if a UI went through more development, for example you weren't quite happy with the first version and made changes based on user reviews, write about it!

== Implementation
<sec:implementace>
This part of a thesis should be about the work itself. It should contain information about "what you actually did" and it should be about 40 % of the entire thesis. It should be clear what the basis of the thesis is, how was it made, what tools were used and what results were achieved.

=== Advice on describing your own work from professor Zemčík
When writing this part of thesis, it is necessary to avoid technical details that could distract the reader or even worse, bore them. Important things are concept of thesis, outlines of solution and what lead you to that solution. Another important aspect of this part is that it must describe how the solution is used, while not being a manual. Any and all technical details, that are not vital to understanding the thesis (and disrupt the "flow of the text") belong in the appendixes part and not the text itself. This mostly applies to long snippets of source code, instructions, tables of results etc. If you include snippets of your code in this part, keep them short and well distinguished from the text. A typical issue with this part is that it just isn't "feasible" for the reader due to a high number and depth of the solved details and the attempts to reflect how tough some thing were to deal with, in the text (usually in a way that emphasizes how much effort the author had to put in to finally overcome an obstacle), but the reader just doesn't care. On the other hand, images, photos or even screenshots are welcome. This part can be split in multiple chapters or it can exist as a whole. It is advised to split this part in multiple chapters if the realisation consists of vastly different parts (e.g. server programmed in C++ and a client in HTML etc.). The outline heavily depends on the individual in this case, although the basics can still be identified and should be in an order specified below.

Typical outline:

- What is the basic concept of the work,

- How does it work as a whole (and what is it good for), description of the functionality of individual parts of the solution (there's no need to emphasize everything equally -- some things are more important than others, the "routine" can be reduced to a~minimum),

- How do you use it including a good example, "case study" approach, "screenshots", procedures (instructions are not desired).

=== Advice on implementation from assistant professor Szöke
This chapter (there can be more of them) is where you describe your problem from implementation perspective. Which development environment have you chosen, which libraries, class design, communication design, protocol etc. Don't bother with the details. Instead of explaining how a button is implemented, explain how you have implemented artificial intelligence, communication or an interesting function, that's what the reader is interested in. #strong[There has to be a clear reason for every single decision you've made.] Again, your grandmother does not need to fully understand this chapter, but it's good to have multiple levels. Someone who is not completely lost in IT should understand what and why you have implemented, experienced programmer should understand even the details (how exactly have you implemented it).

=== Advice on implementation from professor Černocký
If the goal of your thesis is to create a "production" SW, describe it here. This part should contain:

- implementation comments -- for example list of classes and what they represent, you don't have to describe minor things in detail (command line parameters), focus on the key functionality. Don't include full source codes here, those belong to the CD appendix. If a snippet of your code is vital here, you should include it and explain it's importance,

- if your program is supposed to communicate with the outside world in real time, write about the time sync, conflicts and how you deal with them. It's not expected that you make a 100 % "foolproof" SW, but you should know about the commonly occurring issues,

- if you implemented something in Matlab for example, write about it,

- what were the results -- preferably comparison with existing results from someone else,

- if the goal was to build on something pre-existing and explore new options, here's the place to write about it in detail.

=== Advice on implementation from associate professor Beran
This chapter should be separated from testing, especially if the nature of the thesis is implementation heavy. The recommended length is about a third of the thesis.

Write from the perspective of a poorly paid programmer, that got specification of a~prototype (your draft) and they're supposed to implement it. The chapter should contain:

- target platform and technology specifications,

- tools used for implementation of the solution prototype.

== Testing
<sec:testovani>
This text should provide a clear picture of how the functionality of the software was verified. Through mathematical or experimental means, or a study conducted on users etc. What were the results of verification? The length should be roughly 10 pages.

This part can have a single or multiple chapters. It's advised to split this part into multiple chapters if an extensive testing and evaluation was conducted. The outline depends heavily on the individual, but the basics can still be identified @Zemcik:

- Methods and results of verification, that can contain mathematical proofs, testing procedures, testing procedudes involving humans,

- interpretation of results and possible application in practice (TODO things included).

=== Advice on testing from professor Černocký
This chapter chapter can be wildly different -- only use things that are useful @Cernocky.

- Offline data testing -- same or better results as the published ones? If not, why? Worse results don't necessarily mean that the thesis is wrong (access to less data, worse algorithm developed over the course of one semester, etc.), but you should know why.

- Offline data testing -- are results from implementation in C/C++ and from the original Matlab algorithm the same?

- How demanding is it when it comes to HW? -- CPU, memory, parallel behaviour, behaviour when using GP-GPU, etc.

=== Advice on experimentation from associate professor Beran
This chapter contains experiments and evaluation -- if the nature of thesis is not implementation heavy, it can be included in the implementation chapter.

Write from the perspective of a poorly paid tester, that got prototype specification (your draft) and it's implementation and they have to test it. This chapter should contain:

- specifications on the platform used,

- experimental data used for the prototype -- description of data, source, conditions under which the data were obtained, what are the data like,

- data annotation -- annotation format, source and usage,

- description of measurements, description of experiments/tests and their conditions,

- measured data,

- results -- discussion and interpretation of measured data.

=== User testing
Again, only relevant at times, but in some cases it is vital @Cernocky.

- Testing subject selection process (naive, experienced).

- "Testing protocol" -- what did they actually test, what did you ask them -- questions, evaluation, …

- Testing results -- answers subject by subject and summary.

- Conclusions -- Were the users satisfied? What were/weren't they satisfied with? Is it good? Is it bad? Can it be improved? Did you make any improvements during your thesis or is it a matter of future?

=== Advice on experimentation and testing from assistant professor Szöke
In this chapter, your results should be subjected to extensive testing. Not just you, let independent users test your solution. The most important thing is to collect all the feedback and formulate a relevant conclusion. For example improve GUI, make some sections of code faster or choose a completely different approach. If you have enough time, you can even try an addition iteration and work on the biggest shortcomings of your work.

== Conclusion
<sec:zaverPrace>
The final chapter -- Conclusion contains evaluation of achieved results with extra emphasis on student's contribution. A mandatory part of conclusion is also evaluation from the perspective of further advancement of the project. Student states ideas and suggestions based on experience with the project and also states how it relates to other finished projects (other bachelor's theses that year or projects at external workplaces).

The conclusion of a thesis should contain facts summarizing the thesis and give the reader (even without reading other parts of the thesis) information about what the subject of this thesis was and it's success. The conclusion should contain your personal opinions and impressions, and even better a summary of options going forward. Conclusion should be at most one page of text long. Don't include references to thesis text or literature in the conclusion.

Make sure there are no new breakthroughs, new numbers or a new chart in the conclusion.

=== Advice on conclusion from professor Zemčík
I highly recommend the following outline:

- Brief summary of the conclusion (for example "The goal of this thesis was …".),

- Stating that the goal was achieved (preferably without self-criticism, save it for the reviewer),

- Summary of all satisfied requirements of the formal specification of your thesis, either directly as a "reaction to the specification" or "hidden reaction"\; either way, state one sentence summarizing the answer to the question "How did you meet the requirement X of specification?",

- Healthy balance of qualitative and quantitative summary of the thesis, e.g 3--5 most notable information (numbers, data, etc.) about the thesis (recommended length is 5--10 lines),

- your observations ("I learned …"),

- What are your future plans, preferably split in parts "I would like to continue my work and …" and "My work could be expanded on …" -- different parts based on what you would like to try and what could be done, but you won't be the one to do it.

Please, keep in mind that that conclusion is a part of thesis, that people will read the most. If anyone reads your thesis in the future, they'll only read introduction, conclusion, or introduction and then conclusion, introduction, description of the work and conclusion, but it is very rare that people read the whole thesis. Each of the possibilities mentioned should be "feasible" for the reader.

=== Advice on conclusion from professor Herout
The functionality of a conclusion:

- Author looks back at their work: "The main accomplishments are. The important results are. I managed to."

- Author states ideas they did not have time to realise as a way to continue their work: "There are things that can still be done. If I knew then what I know now, I would."

- Author summarizes steps taken to satisfying the requirements of specification.

Two things.

- First: "Discussing ways to continue your work" sounds easy and safe. I would not take this brief statement lightly. Things like "It would be a good idea to increase the speed and precision" show, that the author does not really bother thinking about their work and that they don't really have any ideas. Other "ways to continue your work" can leave the reviewer thinking that you should have done it to meet the requirements of the specification, which means worse evaluation results.

- Second: Conclusion is the very last thing the reviewer reads just a few moments before they start writing their evaluation. Therefore the conclusion should put them in the right mood to write the best evaluation possible. It's a good idea to leave impression such as "I'm a good student, that met any and all requirements of the specification and did a good job." There's a thin line between that and "I'm a bad student, that can't think and program, so I have to scream that I'm the best out loud."

=== Advice on conclusion from professor Černocký
The conclusion contains:

- Summary of work -- I did this and this, this didn't work, this worked, i didn't have time to finish this because …

- Future work

  - "short term" -- things that you are certain you could do alone or with the help of 1--2 people within a couple weeks -- months and that it would help.

  - "long term" -- this is entirely a thing of your imagination.

#heading(level: 3, numbering: none, outlined: false)[Advice on conclusion from associate professor Beran]
Conclusion should only be one page long and contain:

- what was the goal of the thesis,

- what steps did you take to get to your solution (see "brief content of the thesis" in introduction),

- what did you manage to create,

- evaluation of the solution based on results,

- other possible solutions, future possibilities,

- I do not recommend self evaluation and things like "I chose a specification, learned to program and achieved the goals of thesis".

== Appendices
This section should contain descriptive parts of the thesis (e.g. user manual, snippets of source code, detailed schemes, descriptions of designed solutions etc). All appendices need to be numbered. If there are more appendices, there needs to be a list of them at the end of the thesis. @fitWeb

There is no limit to number of appendices pages. However, it is necessary to keep it purposeful, concise and consider the significance of an appendix for the review of the thesis and for follow-up theses in the future. Needlessly large volume of appendices (i.e. not well justified) can negatively affect the assessment from at least environmental and economic perspective. @fitWeb

Appendices are the right place to include instructions, detailed descriptions of designed protocols and formats, tables, most images and other elements that would disrupt the "flow of the text" of thesis. The length of appendices does not count towards the length of the entire thesis. The number of pages should not be too high -- it is important that all the appendices in paper form serve their purpose.

=== Advice on appendices from associate professor Černocký
===== Appendix one -- The cookbook
Instructions for those who would like to redo your work, less than 10 pages

- What needs to be downloaded, compiled, how to "hack the OS" to make everything run smoothly …

- directories, scripts, launch order, where to look for the results,

- etc.

===== Other appendices
Anything that would disrupt the flow of the text of thesis -- a perfect example is a two pages long derivation of something, three pages long table of specifications, etc. …

The included data medium should contain:

- All the source codes -- Matlab, C, the thesis sources, etc.,

- All the parameters of a model -- HMM, neural network, transformation, basically everything,

- Everything necessary to be able to launch your software -- external libraries, modules, etc.,

- All the data -- unless they're under some sort of license,

- Detailed results -- table summarizing the results belongs in a thesis, but you can include multiple MB of automatically generated tables in the appendices

=== Advice on appendices from assistant professor Beran
Assistant professor Beran recommends you include:

- all used libraries, source codes and build instructions,

- Your application (including binaries), ie. solution executable directly from the CD,

- Video -- a decent presentation of your software, you can even include a clip of a~working final version of your software,

=== Poster
- Burn it to CD and print it too (PDF is probably your best bet),

- A2 paper size,

- print it in the library or have it printed by a commercial printing company,

- A healthy balance of the contents:

  - preferably eye-catching and clear format (what is it, what can it do, what is it good for, why is it good),

  - a bit of technical description (procedures and methods used).

- A poster should have:

  - student's first and last name

  - student's email

  - supervisor's first and last name

  - academic year
