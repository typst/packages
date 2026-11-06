#import "/lib/lib.typ" as ucpc
#import ucpc: color
#import ucpc.presets: difficulties as lv

#show: ucpc.ucpc.with(
  title: "Contest Name",
  authors: ("Solutions Commentary Editorial", ),
  hero: ucpc.utils.make-hero(
    title: [Contest Name],
    subtitle: [Solutions Commentary Editorial],
    authors: ("Contest Taskforce", ),
  ),
)

#ucpc.utils.make-prob-overview(
  font-size: .8em,
  [A], [Problem A], lv.easy, [Author a],
  [B], [Problem B], lv.normal, [Author b],
  [C], [Problem C], lv.hard, [Author c],
  [D], [Problem D], lv.challenging, [Author b],
)

#pagebreak()

#ucpc.utils.problem(
  id: "A",
  title: "Problem A",
  tags: ("implementation", "graph_theory", ),
  difficulty: lv.easy,
  authors: ([Author a], ),
  stat-open: (
    submit-count: 10
  ),
  [
    - Magna eu tempor sunt sint laboris nulla culpa labore et quis tempor ad labore ex eiusmod aliquip culpa et incididunt consectetur nostrud velit velit eu magna excepteur ut occaecat cillum aute mollit duis tempor ea officia ex reprehenderit anim eiusmod fugiat adipisicing anim ex do exercitation est anim aliqua irure ullamco tempor irure laboris elit deserunt esse laboris magna ullamco do culpa et ut cillum magna irure Lorem aute sit anim reprehenderit nostrud incididunt officia laborum sint sint adipisicing sint mollit labore excepteur est mollit culpa aliqua duis fugiat nostrud duis sint commodo aliqua proident est incididunt fugiat et irure.
  ]
)

#ucpc.utils.problem(
  id: "B",
  title: "Problem B",
  tags: ("constructive", ),
  difficulty: lv.normal,
  authors: ([Author b], ),
  stat-open: (
    submit-count: 128,
    ac-count: 51,
    ac-ratio: 39.844,
    first-solver: "participant #3",
  ),
  i18n: ucpc.i18n.en-us.problem,
  [
    - Elit ullamco laborum sint aute deserunt laborum eiusmod dolor sint ut reprehenderit consectetur sunt et sunt in tempor esse amet excepteur deserunt ex mollit ipsum eiusmod enim mollit irure laboris proident enim non sit culpa in magna aliqua labore in ut laborum proident aliqua labore dolor velit proident dolor cupidatat pariatur amet magna magna ipsum incididunt qui dolore cupidatat incididunt in officia excepteur cupidatat irure ex mollit et proident sint amet duis minim officia anim aliqua commodo velit id ad proident consequat fugiat commodo cillum et adipisicing commodo anim est cupidatat irure ea amet dolore qui magna do incididunt ipsum.
  ]
)

#ucpc.utils.problem(
  id: "C",
  title: "Problem C",
  tags: ("ad_hoc", ),
  difficulty: lv.hard,
  authors: ([Author c], ),
  i18n: ucpc.i18n.en-us.problem,
  [
    - Magna aliqua reprehenderit amet ea Lorem cupidatat cillum esse sunt nisi magna tempor in qui proident enim aute veniam laboris amet cillum laboris magna ad laboris elit exercitation aute laborum magna Lorem cillum laborum officia veniam fugiat esse quis amet et consequat adipisicing duis ullamco occaecat quis quis ullamco Lorem sint deserunt anim tempor cillum tempor et ea fugiat pariatur qui fugiat magna sunt laboris sint sint minim incididunt ullamco quis laboris consectetur id sit aliqua sint eiusmod eiusmod esse magna duis ea irure ea laborum ex deserunt exercitation ullamco laboris est et velit sunt labore et proident officia nulla.
  ]
)

#ucpc.utils.problem(
  id: "D",
  title: "Problem D",
  tags: ("dp", "greedy", ),
  difficulty: lv.challenging,
  authors: ([Author b], ),
  stat-open: (
    submit-count: 165,
    ac-count: 41,
    ac-ratio: 24.848,
    first-solver: "participant #1" + super("@LOREM"),
    first-solve-time: 7,
  ),
  stat-onsite: (
    submit-count: 111,
    ac-count: 77,
    ac-ratio: 70.270,
    first-solver: "participant a",
    first-solve-time: 2,
  ),
  i18n: ucpc.i18n.en-us.problem,
  [
    - Ullamco non cupidatat deserunt anim dolor enim officia culpa excepteur irure aliquip sint non ipsum ea non consequat occaecat incididunt esse in ex enim duis velit consectetur dolor veniam deserunt cupidatat minim do non dolore irure et est in adipisicing commodo dolore ex culpa aute enim cupidatat irure magna minim adipisicing excepteur nostrud do nisi ea incididunt ex commodo anim sint dolore fugiat deserunt eiusmod sit adipisicing veniam eiusmod est reprehenderit non incididunt dolore nisi ad ipsum Lorem et Lorem amet nostrud incididunt irure ex commodo aliqua est fugiat in laboris aute veniam eiusmod eu in irure laboris exercitation nulla.
  ]
)
