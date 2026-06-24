#import "../lib.typ": labs



#show: labs.init

// #let header(class, number: none, title) = {
// #labs.header("CS-1181", "2", "Comparable Golfers")

#labs.header("CS-1181", "Comparable Golfers", number: 3)
#labs.purpose[
  To review interfaces and ArrayList usage.
]

#labs.part-a[
Your task is to write a class called `Golfer`. Your class should have the following fields and methods:

```java
private String firstName;
private String lastName;
private int score; // golfer’s score so far this round, more negative is better
private int holesCompleted; // number of holes golfer has completed so far this round

// constructor that takes in four parameters to initialize the fields of this object
public Golfer() {}

// returns a String of the form:
// `lastName`, `firstName`: `score` with `holesCompleted` holes completed
public String toString() {}
```

You also need to create a class called `Driver.java` with a main method. 
In main:
- Create three Golfer objects
- Put the golfer objects into an ArrayList
- Print out the ArrayList
]

#labs.example((
  "[Smith, Jay: -13 with 17 holes completed,",
  "Smith, DeShaun: -11 with 16 holes completed,",
  "Taylor, DeShaun: -11 with 2 holes completed]",
))[]


#labs.part-b[
  Revise your `Golfer` class so that it also implements the `Comparable` interface.  
  Golfers should be sorted first by score (more negative comes first), then by the number of holes completed (higher comes first), then lexicographically by last name (ignoring case) and finally lexicographically by first name (ignoring case).

  Augment the main method in your `Driver.java` class so that it does all of the following:
  - Create three `Golfer` objects
  - Put the golfer objects into an ArrayList
  - Print out the ArrayList
  - Sort the ArrayList
  - Print out the ArrayList a second time

  #v(5pt)
  *Sorting table*
  #v(-5pt)
  #table(
    columns: (25%, 15%, 20%, 40%),
    inset: 5pt,
    align: horizon,
    table.header(
      [*Golfer*], [*Score*], [*holesCompleted*], [*Reason for Placement*],
    ),

    ["Brooks, Michael"], "-12", "15", "Most negative score (-12), highest holesCompleted (15)",
    ["Daniels, Amy"], "-12", "14", "Tied on score (-12), but lower holesCompleted",
    ["Adams, Sarah"], "-10", "15", "Less negative score than above (-10)",
    ["Adams, Abby"], "-8", "16", "Least negative score (-8)",
    ["Collins, Peter"], "-8", "16", "Lexicographically after Adams, with same least negative score",
  )

  For full credit, ensure that your program is well commented and follows JavaDoc standards for your method(s). Comments are only required for the Part B segment of the lab.
]

#labs.example((
  "[Adams, Sarah: -10 with 15 holes completed,",
  "Brooks, Michael: -12 with 15 holes completed,",
  "Collins, Peter: -8 with 16 holes completed,",
  "Daniels, Amy: -12 with 14 holes completed,",
  "Adams, Abby: -8 with 16 holes completed]",
  " ",
  "[Brooks, Michael: -12 with 15 holes completed,",
  "Daniels, Amy: -12 with 14 holes completed,",
  "Adams, Sarah: -10 with 15 holes completed,",
  "Adams, Abby: -8 with 16 holes completed,",
  "Collins, Peter: -8 with 16 holes completed]",
))[]
#labs.labAB-rubric[]

#pagebreak()

#labs.lab-rubric()

#labs.uml(
  "Vehicle",
  (
    "-model: String",
    "-wheels: int",
    "-color: String",
    "-offroad: boolean",
    "-speed: double",
    "-seats: int"
  ),

  (
    "+Vehicle()",
  "+setModel(model: String)",
  "+getModel(): String",
  "+setWheels(num: int)",
  "+getWheels(): int",
  "...",
  "+drive(distance: int)",
  "+toString(): String"
  )
)


