#import "lib.typ": cover-page, achraf-code-block


// ────────────────────────────────────────────────────────────────
// Cover Page
// ────────────────────────────────────────────────────────────────

#cover-page(
  title: "Design and Implementation of a Scalable DevOps CI/CD Pipeline for Modern Microservices Architectures",

  subject-image: "devops_5266248.png",

  module: "Architecture microservice et DevOps",

  field: "Computer Science and Emerging Technologies",

  degree: "State Engineer Diploma",

  contributors: [
    SAADALI ACHRAF \
    Student Engineer
  ],

  jury: [
    Prof. X \
    Prof. Y
  ],

  code: "ABCDE-1234",

  dep: "Prof. Z",
)


// ────────────────────────────────────────────────────────────────
// Report Structure
// ────────────────────────────────────────────────────────────────

= Introduction

= Literature Review

= Methodology

= Results and Discussion

= Conclusion


// ────────────────────────────────────────────────────────────────
// Code Blocks
// ────────────────────────────────────────────────────────────────

#achraf-code-block(
  "public class CodeFragment {

    public static void main(String[] args) {

        System.out.println(\"This is Achraf , Greeting you  << Hi >> \");

        System.out.println(\"Use chatgpt-like code Blocks in your Report \");

    }

}",
  "JAVA",
)


#achraf-code-block(
  "SELECT * FROM ENSAJ WHERE NAME =\"SAADALI ACHRAF\";",
  "SQL",
)