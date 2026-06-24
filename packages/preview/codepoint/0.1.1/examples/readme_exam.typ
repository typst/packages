#import "../lib.typ": exams 

#show: exams.init

#set page(header: [
  #context exams.title-state.get()
])
#exams.header(out-of: 10)


#exams.free-response([What is the difference between a class and an object?], points: 5, lines: 3)

#exams.code-block(
  include-line-numbers: true,
  ```java
  public class Main {
      public static void main(String[] args) {
          System.out.println("Exam block");
      }
  }
```)

#exams.short-answer([What is the purpose of a constructor?], lines: 3, points: 4)

#exams.multiple-choice(
  [Which of the following is a primitive type in Java?],
  points: 1,
  cols: 2, // Spreads choices across 2 columns
  [String],
  [int],
  [ArrayList],
  [Scanner]
)

#exams.matching(
  [Match the OOP concept to its definition.],
  seed: 4, // shuffle both sides,
  points: 2,
  (
    ("Encapsulation", "Data hiding via private fields."),
    ("Inheritance", "Subclassing a parent type."),
  )
)