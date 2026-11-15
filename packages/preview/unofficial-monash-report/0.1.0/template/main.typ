#import "@preview/unofficial-monash-report:0.1.0": *

#show: assignment.with(
  // Opt into the preferred stacks; missing font families produce warnings.
  // ..monash-fonts, // optional
  title: [Assignment Title], // required
  author: [\[Your Name\]], // optional
  student-id: [\[Student ID\]], // optional
  unit: "UNIT0000 Example Unit", // optional
  // Obtain an authorised logo, put it in assets/, then uncomment this line:
  // logo: image("assets/logo.svg"), // optional
)

// Marks are optional; omit marks: or set show-marks: false to hide them.
#question(marks: 10)[Replace this with the question statement.]

+ Write the first part of your answer here.
+ Write the second part here.

#lemma[Example result][State a result you need.]
#proof[Give its proof.]
