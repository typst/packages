// This file contains exhaustive documentation and examples of all features.

#import "@preview/answering-sheets:0.1.0": *

// Uncomment to show any specified solutions.
//#show-solutions()

#show: answer-sheet.with(
  // Paper size. Default `us-letter`.
  paper-size: "us-letter",
  
  // Font to display the document in. Default New Computer Modern.
  fonts: "New Computer Modern",
  
  // Language of document. Only used in metadata. Default "EN".
  language: "EN",
  
  // Name of the institution / location, placed in double chevron brackets.
  institute: "CMU Science Olympiad",
  
  // Name(s) of the author(s). Displayed in the footer, placed in filled diamonds.
  author: "Name here",
  
  // Name of the exam / document.
  exam-name: "Astronomy Answer Sheet",
  
  // Date of the exam
  date: [20 Feb 2027],
  
  // Message placed on the first page after the instructions. Default is shown. Vertical spacing is to better vertically align the first page, edit to your liking.
  good-luck: [Best of luck!#v(3em)],
  
  // Message placed after the final question. Default is shown.
  end-of-exam: [End of exam.],
  
  // Insert placed in the top-left of every page after the first. Here, used to identify the team even if pages are separated.
  upper-left-label: [*Team Number \_\_\_\_\_\_*],
  
  // Whether the total number of points is shown on the first page. Default true.
  show-total-points: true,
  
  // Whether there is a per-page score count to assist grading. Also adds a total score box on the first page. Default true.
  show-per-page-points: true,
  
  // Message in the first row of the box containing per-page score counts for graders. Default is shown.
  per-page-point-label: [Scorers only],
  
  // Whether to show the current page in the bottom right of every page after the first. Default true.
  show-page-count: true,
  
  // Formatting for page count. Default is shown.
  page-count-label: "Pg. 1 of 1",
  
  // Instructions for test-takers on first page. Default is empty.
  instructions: [It may be beneficial to use pencil, in the case you must edit any answers. Extra scrap paper is available, however it will not be graded and your final answers must be marked here.
    #v(0.7em)
    Please make sure to clearly mark your final answer by, for example, boxing it.],
  
  // Any fields that the test-taker must fill out, for example for identification. Default empty.
  student-fields: [
    *Competitor Names* #box(stroke: (bottom: 0.4pt), width: 1fr)
    #v(1em)
    *Team Name* #box(stroke: (bottom: 0.4pt), width: 1fr)
    #v(1em)
    *Team Number* #box(stroke: (bottom: 0.4pt), width: (20%))
  ],
)

// Creates a bolded, H1-style header with the number of points in this section. To remove that sum, set `show-total-points` to false.
// All score counts, in headers and in the top right (if enabled), are generated automatically. Just about killed me, but they're generated automatically.
#header([MCQ, Subquestions, Repeats], show-total-points: true)

// Multiple choice question.
// First argument gives number of available choices.
// Second argument gives point value. Displays point value, if the question is worth anything. Only integers are allowed.
#mcq(5, 2)

// Number of options is really just limited by space. Don't go more than about eight, for best formatting. If you have more than eight choices for an MCQ, I beg that you reconsider.
#mcq(13, 4)

// Set the solution. Capital letters from A to J are defined as solutions. Hidden unless deliberately shown with `#show-solutions()`.
#mcq(5, 3, solution: C)

// Custom spacings are of course always in order
#v(1em)

// Enables a subquestion display in the question.
#mcq(5, 2, is-sub-question: true)

// Consecutive calls with `is-sub-question` will increment the sub-question count, but not the main count.
#mcq(5, 2, is-sub-question: true)
#mcq(5, 2, is-sub-question: true)

// If two questions next to each other both have subquestions, call `#newsubquestion()` to move on.
#newsubquestion()
#mcq(5, 2, is-sub-question: true)
#mcq(5, 2, is-sub-question: true)
#mcq(5, 2, is-sub-question: true)

#v(1em)

// If you have many consecutive questions with the same format, you may use `#repeat()`:
// The first argument is the number of times to repeat.
// The second argument is the content to repeat.
// The index of repetition is not available to the content.
#repeat(5, [
  #mcq(4, 2)
])

#v(1em)

// If you have many multiple choices of the same config (number options, point value), you may use `#mcqs()` to construct them all at one. The third parameter is an array of answers.
#mcqs(4, 3, (A, B, C, A, D, C))

// Page breaks must be included manually.
#pagebreak()

// Headers may be done formatted like this if you don't need any options.
// Also note that question count resets on a new header.
#header([Open-Ended Questions], show-total-points: true)
Open-ended questions leave room for anything from short phrasal answers to long, full-sentence responses to computations.

// Generic open-ended question.
// First argument specifies the height of the answer box.
// Second argument specifies the point value.
#openended(5em, 5)

// If a question calls for single-line answers, pass `sameline: true`
// sameline forces the box height to be 2em.
#openended(3em, 4, sameline: true)

// Open-endeds can also have / be sub-parts
#openended(3em, 3, is-sub-question: true)
#openended(3em, 3, is-sub-question: true)

#newsubquestion()
#openended(3em, 3, is-sub-question: true)
#openended(3em, 3, is-sub-question: true)

// Full-page questions, in us-letter, are generally about 50em tall.
#openended(50em, 5)

// Solutions may be specified, as content, with the same `solution` argument.
#openended(5em, 5, solution: [This is the solution!])

// As can be shown on the last page, all fields are vertically centered.
