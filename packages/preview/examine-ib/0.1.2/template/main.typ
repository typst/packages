#import "@preview/examine-ib:0.1.2": *

#show: conf.with(exam-id: [0000-0001])

#title-page(
  subject: [General Knowledge],
  level: [Higher Level],
  paper: [Paper 3],
  date: [19 May 2028],
  time-limit: [55 minutes],
)

#mcq(
  [What is the capital of Canada?],
  [Toronto],
  [Ottawa],
  [Vancouver],
  [Montreal],
)

#mcq(
  [Which planet is known as the Red Planet?],
  [Earth],
  [Mars],
  [Jupiter],
  [Venus],
)

#mcq(
  [What is the main function of red blood cells?],
  [Fight infection],
  [Carry oxygen],
  [Clot blood],
  [Produce hormones],
)

#mcq(
  [Which Shakespeare play features the characters Rosencrantz and Guildenstern?],
  [Macbeth],
  [Hamlet],
  [King Lear],
  [Othello],
)

#mcq([What is the chemical symbol for gold?], [Gd], [Ag], [Au], [Go])

#mcq([In what year did World War II end?], [1944], [1945], [1946], [1947])

#mcq(
  [Which of the following is a renewable source of energy?],
  [Coal],
  [Wind],
  [Natural Gas],
  [Nuclear],
)

#mcq(
  [What programming language is primarily used for web development alongside HTML and CSS?],
  [Python],
  [Java],
  [JavaScript],
  [C++],
)

#mcq(
  [Who painted the Mona Lisa?],
  [Vincent van Gogh],
  [Pablo Picasso],
  [Leonardo da Vinci],
  [Claude Monet],
)

#mcq(
  [What is the boiling point of water at sea level in Celsius?],
  [90°C],
  [95°C],
  [100°C],
  [105°C],
)

#saq(
  [A city has recently implemented a smart traffic management system that uses real-time data from sensors and cameras to optimize traffic flow. The system also collects and stores driver movement data to improve future predictions.],
  (
    question: [What are two potential benefits of using real-time data in traffic systems?],
    points: 2,
    lines: 3,
  ),
  (
    question: [Explain one concern related to collecting and storing driver movement data.],
    points: 4,
    lines: 5,
  ),
)

#saq(
  [A company is using AI-powered recruitment software to filter job applications. The software ranks candidates based on qualifications, but some users have raised concerns about bias in the algorithm.],
  (
    question: [How might AI improve the efficiency of the hiring process?],
    points: 4,
    lines: 6,
  ),
  (
    question: [Why could the use of AI in hiring lead to biased outcomes?],
    points: 4,
    lines: 6,
  ),
)

#saq(
  [A school has adopted a bring-your-own-device (BYOD) policy that encourages students to use their personal laptops and tablets during class. This has led to debates among teachers and parents.],
  (
    question: [Describe one advantage and one disadvantage of the BYOD policy for students.],
    points: 2,
    lines: 5,
  ),
  (
    question: [What measures could the school take to ensure equal access for all students?],
    points: 4,
    lines: 8,
  ),
)
