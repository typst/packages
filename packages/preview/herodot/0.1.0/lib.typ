#import "@preview/cetz:0.3.4"
#import "src/primitives.typ": event, eventspan
#import "src/functions.typ": eventspanlocation, eventlocation


#let timeline(
  // core elements
  startyear: 0,
  endyear: 10,
  interval: 2,
  events: (
    // event(
    //   title: "Genesis",
    //   year: 2025,
    //   month: 7,
    //   day: 26)
    ),
  eventspans: (
    // eventspan(
    //   title:"Depression",
    //   color: blue,
    //   start-point: 400,
    //   end-point: 600,
    //   )
    ),

  // optional styling elements
  length-of-timeline: 14,
  linestroke: 0.3pt + black, 
  spanheight: 0.5,
  spanheight-positive-y: 0,
  spanheight-negative-y: 0,
  ) = {


  cetz.canvas(
    // the canvas draw surface
    {
      import cetz.draw: *

      // position of main timeline begining and line end
      let timeline-startpoint = (0,0)
      let timeline-endpoint = (length-of-timeline,0)
      line(
         timeline-startpoint,
         timeline-endpoint,
         name: "Timespan",
         mark: (end: ">"),
         stroke: linestroke
      )

      // content labels for the beginning and final year

      let startyear-distance-timeline = 0.5

      // if the startyear is more than 3 characters to display increase
      // the distance between the timeline and the content to make room
      // for it to render it

      if startyear > 99 or startyear < -9 { 
        startyear-distance-timeline = 0.7
      }
      content(
        (timeline-startpoint.first() - startyear-distance-timeline, 0),
        // anchor: "east",
        padding: (
         rest: .1,
         // right: .6, 
        ),
        [ #startyear ]
      )

      let endyear-distance-timeline = 0.5

      if endyear > 99 or endyear < -9 { 
        endyear-distance-timeline = 0.7
      }
      content(
        (timeline-endpoint.first() + endyear-distance-timeline, 0),
        [ #endyear ]
      )


      
      // make the vertical marks for the interval markings
      let interval-year = startyear

      while interval-year < endyear {
        let posx = timeline-endpoint.first() * eventspanlocation(
          start-year: startyear,
          end-year: endyear,
          eventyear: interval-year,
        ) 

        // the line marking itself
        line(
          (posx,-0.1),
          (posx, 0.1),
          stroke: linestroke
        )

        // year description marking
        if interval-year != startyear {
            if startyear <= 0{
              content(
                (posx, -0.3),
                [#interval-year]
              )
            }

            if startyear > 0 {
              content(
                (posx, -0.3),
                [#interval-year]
              )
            }
          }
        interval-year = interval-year + interval
      }
      
      // draw singular events on the timeline
      if events.len() != 0 {
        for x in events {
          let event-pos = (
            timeline-endpoint.first() * eventlocation(
                start-year: startyear,
                end-year:  endyear,
                event: x,
              ),
              0
            )

          // line for vertical marking
          let line-pos1 = (event-pos.first(), 0.4)
          line(
            event-pos,
            line-pos1,
            stroke: linestroke
          )

          // content descriptions for the year
          content(
            (event-pos.first(),0.7),
            [ #x.year ]
          )
          // content descriptions for event
          
          content(
            (event-pos.first(), line-pos1.last() + 0.7),
            angle: 45deg,
            anchor: "base-west",
            [ #x.title ]
          )
 
        }
      }
  
      // drawing the events that span across time (eventspan)
      if eventspans.len() != 0 {
        for x in eventspans {
            let event-pos-x-0 = timeline-endpoint.first()*eventspanlocation(
              start-year: startyear,
              end-year:  endyear,
              eventyear: x.start-point
            )
            let event-pos-x-1 = timeline-endpoint.first()*eventspanlocation(
              start-year: startyear,
              end-year:  endyear,
              eventyear: x.end-point
            )

            let span-y-offset = spanheight
            if spanheight-negative-y == 0 and spanheight-positive-y == 0{
              span-y-offset = spanheight

              // block of the event span
              rect(
                 (event-pos-x-0,
                 span-y-offset),
                 (event-pos-x-1,
                 -span-y-offset),
                 fill: x.color.transparentize(60%),
                 stroke: x.color.transparentize(60%),
                 radius: 5pt
              ) 
            }

            
            if spanheight-negative-y != 0 or spanheight-positive-y != 0{

              // block of the event span
              rect(
                 (
                  event-pos-x-0,
                  spanheight-positive-y),
                 (
                  event-pos-x-1,
                  -spanheight-negative-y),
                 fill: x.color.transparentize(60%),
                 stroke: x.color.transparentize(60%),
                 radius: 5pt
              ) 
            }

            // content for event span
            content(
              // position , also pulls in the eventspans timeline offset variable (x.last)
              ((event-pos-x-1 + event-pos-x-0)/2 , -span-y-offset - x.timeline-offset),
              anchor: "mid",
              box(width: 1cm, )[ #align(center, x.title ) ]
            )
          }
        }
      }
    )
}

