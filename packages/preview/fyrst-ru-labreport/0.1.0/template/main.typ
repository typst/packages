#import "@preview/fyrst-ru-labreport:0.1.0":*

#import "@preview/unify:0.7.0":*

#import "@preview/cetz:0.3.1" as cetz: *

#import "@preview/cetz-plot:0.1.0"

#show: project.with(
  title: [Paper Title],
  course-name: [Course Name],
  course-abrev: [COURSE],
  organization: [Reykjavík University],
  logo:image("Graphics/ru-logo.svg",width:40%),
  authors:(
    (
      name:"Jack Jones",
      email:"jackj@org.com",
      phone:none
    ),
    (
      name:"Jill Jones",
      email:"jillj@org.com",
      phone:none
    ),
    (
      name:"Jane Jones",
      email:"janej@org.com",
      phone:none
    ),
    (
      name:"Joe Jones",
      email:"joej@org.com"
    ),
    (
      name:"Juan Jones",
      email:"juanj@org.com"
    )
  ),
  author-columns:3,
  supervisors:(
    (
      name:"Big Man",
      title:"Incharge",
      email:"important@org.com",
      phone:"+001-123-4567"
    ),
    (
      name:"Less Man",
      title:"Middle",
      email:"lessm@org.com",
      phone:none
    ),
  ),
  supervisors-columns:2,
  bibliography:bibliography("bibliography.bib"),
  paper-size:"a4",
  lang:"is",
)


= Introduction

In this section of the report you explain the basic physical phenomenon, the principle(s), and the basic equations.
All notations or symbols used in the equations will be explained.
Using one or two figures to make the explanations clear is highly recommended.
You also state briefly what you want to do or test in this lab/experiment @anarticle@thesis@report@conv@unpub@notpub.
Do not copy-paste from the written documentation created for you.
Use your own understanding.
Imagine you are an expert working in a professional lab and you write a report for your clients or for your collaborators who are asking you to do measurements on their samples or materials.
So you explain to them the basics of the experiment and the measurements.
It is assumed that they already have some general knowledge, but they are not necessarily experts in your field.
The recommended size of this section is about one page including figures.

$
  e^(pi i) + 1 = 0
$<eu_eqn>

The beautiful equation @eu_eqn is known as the Euler equation @collection

= Methods


Here you explain methods used in the experiment @bookseries.
Statistical methods, measurement methods...


== Equipment and setup


Here you explain the equipment you used and the experimental setup.
Mention the instruments or the accessories used.
Do not list up all the tools, but only the most important.
Pictures might be very helpful.


// Sadly there isn't a good  way to make circuits in typst *_yet_*
#figure(
  image("Graphics/circuit.png",width:50%),
  caption: [(Example caption) Some description about the diagram.e]
)<fig:Circuit_diag>

// There are better ways to do this with packs like fletcher, but this is a better way to show the functionality of CeTZ.
#figure(
  canvas({
    import cetz.draw:*
    content((0,0),image("Graphics/vac_chamber.jpg", width:10cm))

    circle((-0.1,0), radius: 0.6, stroke: white)
    content((rel:(-1,1)), highlight(fill:white)[Sample stage])
    line((rel:(0,-0.1)),(rel:(0.5,-0.6)), stroke:white, mark:(end:">"))

    circle((3.2,2.3), radius: 0.8, stroke: white)
    content((rel:(-1,1)), highlight(fill: white)[Ion gauge])
    line((rel:(0,-0.15)),(rel:(0.5,-0.6)), stroke:white, mark:(end:">"))

    rect((-1.3,-2.7),(rel:(2.4,-0.9)), stroke: white)
    content((rel:(-3.7,0.5)), highlight(fill: white)[Vacuum pump])
    
  }),
  caption: [Spherical Vacuum chamber, the white box in the center is one of the custom built measurement stages, in the center (golden spot) is a UV-LED. Vacuum pump can be seen below the chamber, the Pirani gauge is on the far side.]
)


= Procedure


Describe the most important steps of the work.
Do not go into too many details, like: “we opened the Capstone software and clicked Start”, or “we turned on the power source”. @abook //<-- heimild
Such information is irrelevant for your clients or collaborators.
Again, do not copy-paste from the description of the teacher.
Explain your work such that the readers will understand what you did and will trust you.
In general half a page should be sufficient here, but you can write more, depending on the complexity.
You can include more technical details like limitations of the equipment, or improvements that you made, or other methodological aspects.

= Results and Discussion


Describe the data collection briefly and put the data tables and figures in context.
In experiments when an electric circuit is studied the circuit and the meters used should be shown in the report.
Data tables.
Show the data tables.
All tables should be numbered (like Table n), have a title and include a brief description.
This description should be on top of the table. Of course, if you have thousands of numbers do not show all, but only the most important.
Always mention the physical units used.


#figure(
  table(
    align: (left,)*2 + (right,),
    columns: 3,
    table.hline(),
    table.cell(colspan: 2, align(center)[Item]),[],
    table.hline(end:2),
    [Animal]    , [Description] , [Weight (#unit("g"))] ,
    [Gnat     ] , [per gram]    , [#qty("13.65", "g")]      ,
    [         ] , [each    ]    , [#qty("0.01" , "g")]       , 
    [Gnu      ] , [stuffed ]    , [#qty("92.50", "g")]      ,
    [Emu      ] , [stuffed ]    , [#qty("33.33", "g")]      ,
    [Armadillo] , [frozen  ]    , [#qty("8.99" , "g")]       ,
    table.hline(),
  ),
  caption: [Results of measuring different types of frozen perishables.
    The description tells how each item is prepared.]
)<tab:data>

*_Graphs._*
Often the graphs are the most important information of the work.
Whether you do a graph with the computer or by hand, do it with great care.
A graph contains a lot of information in a few cm2.
Graphs should be numbered (like Graph n), have a title and include a brief description.
This description should be below the graph itself. Label the axes the quantities shown and the units.
Some software (like Excel) do not have convenient default options for graphs:
grid-lines may be shown in one direction only, the displayed intervals might be much larger than the relevant intervals, etc. 
Find the convenient settings, do not accept the default if it is not good enough.
Use the whole graph area to show your data. Often you have to create either a straight line or another curve through the data points.
If you cannot do it with the computer, just print the graph and do it by hand.
Make sure that individual data points stand out clearly, they are your measurements.

#figure(
  canvas({
    import cetz-plot:*
    plot.plot(size: (12,6), x-tick-step: 2, y-tick-step: 20, title:[press],
      legend: auto, 
      x-label:[Distance [#unit("km")]],
      y-label:[Force [#unit("mN")]],
      {
      plot.add(domain: (-10,10), label:$x^2 + 2x + 1$,
        x=>calc.pow(x,2) + 2*x +1)
      plot.add(domain: (-10,10), label:$x^2 - 2x - 1$,
        x=>calc.pow(x,2) - 2*x -1)
      }
    )
  }),
  caption: [(Example caption) Figure shows how the system pressure in [Pressure(#unit("m N"))]changes with time for two cases.
  Blue is the first and red is the second case.]
)<fig:merkimiði_myndar>

*_Calculations._*

Show your calculations.
Show clearly the units you used for all physical quantities.
Here you show the error/uncertainty analysis.
Pay attention to the significant digits of the final results:
as a rule the uncertainty will be shown with only one significant digit and the main result with the last significant digit corresponding to the uncertainty.\
Examples: $2.41 plus.minus 0.03$ or $6.5 plus.minus 0.2$ and not $2.412367 plus.minus 0.02698$ nor $6.4 plus.minus 0.16$.
*_Discussion._*
Discuss briefly your results, how well they fit some model, theory or other data.


= Summary and Conclusions


It is very important to have a clear, short, and informative summary of all the important results.
It can be a short table or a list, and possibly one or two short comments or explanations.
You have to understand that your clients or collaborators may not have time to read the whole report as soon as they see it, but they need the results or the conclusions immediately.
This is a typical situation in real life.
Some readers will look only at the last section first, and only later to the whole report.
That’s why in this final section you answer the initial question(s) or respond to what you wanted to do, as stated in the Introduction @abook.

*_Final recommendations:_*
The length of the report is not fixed.
In general it should be between 4 and 6 pages, but it may vary depending on the number of graphs and tables included.
Language can be English or Icelandic, at your choice.
This description is an addition and clarification to “Skýrslur og ritgerðir” as published by the School of Science and Engineering, and is specific to physics lab reports.


#figure(
  image("Graphics/Classical_laboratory_methods_in_microbiology.jpg", width:60%),
  caption: [
    Ef myndir eru teknar frá öðrum þá verður að geta heimilda - einnig, svona myndir eiga ekki heima í tæknilegum skýrslum, bara tæknilegar myndir. \
    Source: 
    #link("https://commons.wikimedia.org/wiki/File:Classical_laboratory_methods_in_microbiology.jpg")[Photo] by Dariusz Bartosik 
    #link("https://creativecommons.org/licenses/by/2.0/")[CC BY]
  ]
)
