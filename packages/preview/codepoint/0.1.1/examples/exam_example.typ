#import "../lib.typ": exams as e


#show: e.init

#e.setup("CS-1181 Quiz #1")

#set page(header: [
  #context e.title-state.get()
])
#e.header(out-of: 60)


#e.multiple-choice([Which of the following is *NOT* true about `ActionListener`?], points: 2,
  [`ActionListener` is an interface in Java],
  [`ActionListener` must be defined in an anonymous inner class], // X
  [`ActionListener` can be implemented in a lambda expression],
  [`ActionListener` can be used to add functionality to buttons],
)
#e.spacer()



#e.multiple-choice([Which layout manager allows the user to add a component to a cardinal direction?], points: 2, cols: 2,
  [`FlowLayout`],
  [`GridLayout`],
  [`BorderLayout`], // X
  [`BoxLayout`],
)
#e.spacer()

#e.multiple-choice([Which of the following is *NOT* true about exceptions?], points: 2,
  [`Exception` is the base class for all exceptions in Java],
  [Custom exceptions should inherit from an existing exception class],
  [Exceptions often include a message string associated with them],
  [Runtime exceptions must be handled with a try/catch or explicitly thrown], // X
)
#e.spacer()

#e.multiple-choice([Which of the following is used for defining natural object sorting?], points: 2,
  [`Comparable`],
  [`Comparator`],
  [`ActionListener`],
  [None of the above]
)
#e.spacer()


#e.multiple-choice([Which of the following is not a function of the `super` keyword?], points: 2,
  [To call the parent class constructor],
  [To reference the child of the parent class],
  [To reference a method of the parent class],
  [To reference a field of the parent class],
)

#pagebreak()

#e.spacer()

 Use the code block to answer the following question:
 #e.code-block(
```java
public static void doThing() {
    boolean b = true;
    try {
        System.out.print("Apple");
        if (b) {
            throw new Exception();
        }
        throw new IllegalArgumentException();
    } catch (IllegalArgumentException iae) {
        System.out.print("Banana");
    } catch (Exception e) {
        System.out.print("Pear");
        return;
    } finally {
        System.out.print("Orange");
    }
}
```
)
#e.spacer()

#e.short-answer([Write the output of the `doThing()` method when it is called], lines: 3, points: 1)
#e.spacer()
#e.spacer()

// #e.matching(
//   [Match the following to their definitions], points: 7,
//   (
//     `implements`,
//     "Abstract class",
//     "Casting",
//     `extends`,
//     "Interface",
//     `throw`,
//     `JPanel`,
//   ),
//   (
//     "Passes an exception to the methods caller",
//     "Denotes a class inherits from another",
//     "A way of converting between types",
//     "Common Swing component",
//     "A class that cannot be directly instantiated",
//     "Denotes that a class is using an interface",
//     "Contract requiring a class to implement select methods",
//   )
// )


#e.matching([Match the following to their definitions], points: 7, seed: 3,
  (
    (`implements`, "Denotes that a class is using an interface"),
    (`extends`, "Denotes that a class inherits from another"),
    ("JPanel", "Common Swing Component"),
    ("Abstract Class", "A class sthat cannot be directly instantiated"),
    ("hello", "world")
  )
)

#pagebreak()

Use the diagram to answer the following question:
(Lines denote inheritance)

// compile times for this library are literally awful.
// This is a 3 line diagram
// adds like 16 seconds to the compile time wtf?
// #align(center)[
//   #show raw.where(lang: "pintora"): it => pintorita.render(it.text)
//   ```pintora
//   mindmap
//   @param layoutDirection TB
//   + abstract class Animal
//   ++ class Dog
//   ++ class Cat
//   ```
// ]

#e.multiple-choice([*Circle all* of the following that are valid statements according to the diagram:], points: 2,
  [```java Animal a = new Animal();```],
  [```java Dog d = new Dog();```],  // X
  [```java Cat c = new Animal();```],
  [```java Cat c = new Dog();```],
  [```java Animal a = new Cat();```], // X
)
#e.spacer()

#e.multiple-choice([#"Abstract classes, interfaces, and multi-layered applications are all examples of" ], points: 2,
  [Separation of Concern],
  [Dynamic Dispatch],
  [Inheritance],
  [`ActionListener` Interfaces]
)
#e.spacer()

#e.multiple-choice([Which of the following will *always* cause a ClassCastException to occur?], points: 2,
  [Casting a child class to a parent class],
  [Casting a parent class to a child class],
  [Casting between unrelated classes], // X
  [Casting between primitive types]
)


#e.multiple-choice([Select all that are true about using ```java Runnable``` interface:], points: 4,
  [It can be implemented via a lambda expression], // X
  [It allows for a class to extend another class and be multi-threaded], // X
  [It requires the ```java start()``` method to be overridden],
  [It must be used with a class that extends ```java Thread```],
)


#pagebreak()
Use the `Student` class to answer the following questions:

#e.code-block(
```java
class Student {
    private String name;

    public Student(String name){
        this.name = name;
    }
    public void setName(String newName){
        this.name = newName;
    }

    public String toString(){
        return this.name;
    }
}
```
)

#e.code-block(```java
public static void main(String[] args) {
    Student s1 = new Student("Alice");
    Student s2 = s1;
    s2.setName("Bob");
    System.out.println(s1);
    System.out.println(s2);
}
```, include-line-numbers: true)


#e.multiple-choice([What is the output of the code?], points: 2,
  [`Alice
           Bob`],
  [`Alice
           Alice`],
  [`Bob
           Alice`],
  [`Bob
           Bob`], // X
)

#e.multiple-choice([Why does this issue occur?], points: 2,
  [Because a deep copy is performed],
  [Because inheritance is used],
  [Because a shallow copy is performed],
  [None of the above],
)
#e.spacer()

#e.short-answer([Write one line of code to create a deep copy of `s1`:
], lines: 4, points: 1)
#pagebreak()


// #short-answer([
//   Describe the layout managers and components you would use to make the following GUI:
//   #spacer()
//   #align(center)[
//     #image("layouts.png", width: 60%)
//   ]
// ], 5,  3)
// #spacer()


#e.multiple-choice([`BoxLayout` is the default component layout manager], points: 2,
  [True],
  [False], // X
)
#e.spacer()

#e.short-answer([Briefly describe the purpose of the `JPanel` class in Swing?], lines: 4, points: 1)
#e.spacer()

#pagebreak()


Use the code block to answer the following question:
#e.code-block(
```java
public class CustomFrame extends JFrame {

    public CustomFrame() {
        this.setSize(500, 500);

        JButton btn1 = new JButton("Submit");
        this.add(btn1);

        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JLabel label = new JLabel("This is some text");

        JButton btn2 = new JButton("Next");
        this.add(btn2);

        this.setVisible(true);
    }
}
```, include-line-numbers: false)

#e.multiple-choice([What will render when an instance of `CustomFrame` is created?], points: 2,
  [A frame containing only the "Submit" button],
  [A frame containg the "Submit" button, "Next" button, and a JLabel],
  [A frame containing only the "Next" button], // X
  [The frame will not render],
)
#e.spacer()

#e.short-answer([Briefly explain why you chose that answer:], lines: 4, points: 2)

#e.spacer()

#e.multiple-choice([Which of the following is *NOT* true about interfaces?], points: 2,
  [A class in Java can only inherit a single interface], // X
  [An interface ensures a class must implement select methods],
  [You can pass interfaces into methods as data types],
  [You can declare the left side of variables as an interface],
)
#pagebreak()


Use the code block to answer the following questions:
#e.code-block(

  ```java
  public abstract class Worker {
      public abstract void goToWork();

      public void performTask(){
          System.out.println("Performs task...");
      }
  }

  public interface TimeTrackable {
      public void clockIn(String time);

      public void clockOut(String time);
  }

  public class Intern extends Worker implements TimeTrackable {
      //...
  }

  public class Driver {

      public static void main(String[] args) {
          Intern i = new Intern();
          performHourlyLabor(i);
      }

      public static void performHourlyLabor(TimeTrackable t){
          t.clockIn("9am");
          t.clockOut("5pm");
      }

  }
  ```
)
#e.spacer()

#e.multiple-choice([*Circle all* of the following that are true about the class Intern?], points: 2,
  [Intern *must* write the body for the clockOut method], // X
  [Intern *must* write the body for the performTask method],
  [Intern *must* override the body for the goToWork method], // X
  [Intern *must* override the toString method],
)
#e.spacer()
#e.spacer()

#e.multiple-choice([The call to the method `performHourlyLabor` is an example of: ], points: 2,
  [Dynamic Dispatch],
  [Inheritance],
  [Multi-Layered Application],
  [Type Casting]
)

#e.multiple-choice([Which method is used for defining custom graphics in Swing?], points: 2,
  [`setGraphics(Graphics g)`],
  [`draw()`],
  [`addActionListener()`],
  [`paintComponent(Graphics g)`], // X
)

#e.spacer()

#e.multiple-choice([What does the `throws` keyword do?], points: 2,
  [Indicates that a method could cause an error], // X
  [Creates and instantiates an exception],
  [Creates a custom exception type],
  [Catches and handles an exception],
)
#e.spacer()

#e.multiple-choice([Which of the following is *NOT* true about abstract classes?], points: 2,
  [If a class has one abstract method, the class must be marked as abstract],
  [Abstract classes can be directly instantiated], // X
  [Abstract methods must be implemented in a child class],
  [Abstract classes can contain methods with no bodies],
)
#e.spacer()
#e.spacer()

#e.short-answer([Write the header for a class that inherits from `Number` and can be sorted in a list:], lines: 4, points: 1)
#e.spacer()

#e.multiple-choice([All Java Swing events are handled on the Main Thread], points: 1,
  [True],
  [False],
)
#e.spacer()

#e.multiple-choice([*Circle all* of the following that are concerns when programming GUIs in Swing?], points: 2,
  [Doing lots of work on one component may block the EDT],
  [Avoiding `OutOfFrameException` when animating components],
  [Adding more than ten components to a JPanel will cause a crash],
  [Adding multiple components *directly* to a Jframe],
))


#pagebreak()


#e.free-response([In the space below, write a generic bubble sort method. At a minimum, the method should:
  #linebreak() #h(20pt)- Take in an ```java ArrayList``` (or similar) of generic elements that are comparable to themselves
  #linebreak() #h(20pt)- Sort the elements using the bubble sort algorithm
  #linebreak() #h(20pt)- You are welcome to either modify the list passed in or return a sorted version of the list
  #linebreak() #h(20pt)- Please ensure that the method can sort an ```java ArrayList``` of any length], points: 8, lines: 12)


#e.tf-block([Mark the following statements as either True (T) of False (F):], points: 5,
  [```java LinkedList``` utilizes nodes and next pointers to store information], // T
  [```java ArrayList``` is always faster than ```java LinkedList```], // F
  [```java ArrayList``` has more flexible memory usage than ```java LinkedList```], // F
  [```java ArrayList``` and ```java LinkedList``` implement the same ADT], // T
  [```java ArrayList```s are faster than ```java LinkedList```s at retrieval operations], // T
)
