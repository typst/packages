#import "global.typ": *

= Evaluation

#lorem(30)

#todo(
  [
    Describe (proof) how your implementation really solved the stated problem. I.e.
    accept or reject your hypotheses. Provide a range of input data sets. Run
    experiments and gather the output (of tools) to meter your prototype. For the
    analysis, collect the measurement-data, process (e.g. filter) data and interpret
    the data. Include an interpretation of the work. What do the results mean to
    you? State current limitations of your solution. Give (personal) interpretation
    where suitable. Your own opinion is relevant, but must be marked clearly as
    such.
  ],
)

#todo(
  [

  *Hints on dynamic calculation in Typst:*

  We might calculate, e.g. `#calc.max(...)`, within our document, such as max of
  three and seven times two is: #calc.max(3, 2 * 7).

  #v(1cm)
  *Hints on using logic in Typst:*

  For example, we might use *for loop* to arrange a few images in a grid box, as
  shown below.

  #box(height: 124pt, columns(2, gutter: 11pt)[
    #for x in range(1, 3) [
      #let imagename = "/figures/chart-" + str(x) + ".svg"
      #figure(image(imagename, width: 75%), caption: [
        Compared souce code by metric #(x).
      ])
    ]
  ])

  #v(1cm)

  *Hints on Charts:*

  Note: the charts (*vector*! images) shown have been created from raw data using
  the tool *gnuplot* on the command line. With `gnuplot` you can create charts by
  use of a textual command language. This is great for automation and it is also
  great for managing the source code in `git`. ],
)

#todo(
  [

  *Hints on using tables in Typst:*

  Somewhere in the normal text of the thesis the interpretation of data and
  information shown in a table must be discussed. Explain to the readers which
  numbers are important. Possibly, highlight unexpected or special data points.

  #figure(
    table(
      columns: (auto, 4em, 4em, 4em, 4em), inset: 10pt, fill: (x, y) =>
      if y == 0 { luma(240) }, stroke: gray, align: center, [], [*Min*], [*Max*], [*$diameter$*], [*$sigma$*], [Network roundtrip time], [34.6s], [42.5s], [38.1s], [2.3s], [Time for single request], [2.4s], [13.5s], [*7.1s*], [4.3s],
    ), caption: flex-caption(
      [The numbers in the table above show the minumum, maximum, average $diameter$ ,
        and standard deviation $sigma$ of the 273 measured network times in seconds.], [Roundtrip and request times.],
    ),
  ) <nwperf>

  For example: ... @nwperf shows some calculated results on the roundtrip and
  request times measured in the experiment. The average, the minium, the maximum
  and the standard deviations hint to a dramatic increase (> 13%) in performance
  in comparison to the old solution of 2003.

  #v(1cm)
  *Hints on dynamically reading in external data for tables in Typst:*

  Using the custom macro `fhjtable` it is possible to include data dynamically for
  table generation. The data has to be specified in comma seperated values (csv)
  as shown below:

  #figure(
    fhjtable(tabledata: csv("/data/recordings.csv"), columns: 3), caption: flex-caption(
      [Professional experience of the test users with databases.], [DB expertise in years.],
    ),
  ) <users>

  Find in @users the years a user has worked with different relational or nosql
  databases in a professional context.

  ],
)
