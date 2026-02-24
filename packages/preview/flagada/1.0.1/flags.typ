#let flag-v2(colors,height:.65em,ratio:3/5,color-width:(1/2,)*2) = {
  box(
    height:height,
    width:1/ratio*height,
    outset: 0pt,
    rect(
      inset:0pt,
      outset: 0pt,
      stroke:none,
      { 
        stack(
          dir:ltr,
          rect(width:100%*color-width.at(0), height: 100%,fill:colors.at(0),),
          rect(width:100%*color-width.at(1), height: 100%,fill:colors.at(1),),
        )
      }
    )
  )
}

#let flag-v3(colors,height:.65em,ratio:2/3,color-width:(1/3,)*3) = {
  box(
  height:height,
  width:1/ratio*height,
  outset: 0pt,
  rect(
    inset:0pt,
    outset: 0pt,
    stroke:none,
    { 
      stack(
        dir:ltr,
        rect(width:100%*color-width.at(0), height: 100%,fill:colors.at(0),),
        rect(width:100%*color-width.at(1), height: 100%,fill:colors.at(1),),
        rect(width:100%*color-width.at(2), height: 100%,fill:colors.at(2),)
        )
      }
    )
  ) 
}

#let flag-h3(colors,height:.65em,ratio:3/5,color-height:(1/3,)*3) = {
  box(
  height:height,
  width:1/ratio*height,
  outset: 0pt,
  rect(
    inset:0pt,
    outset: 0pt,
    stroke:none,
    { 
      stack(
        dir:ttb,
        rect(width:100%, height: 100%*color-height.at(0),fill:colors.at(0),stroke:none),
        rect(width:100%, height: 100%*color-height.at(1),fill:colors.at(1),stroke:none),
        rect(width:100%, height: 100%*color-height.at(2),fill:colors.at(2),stroke:none)
        )
      }
    )
  ) 
}
 
#let polygram(schlafli,size,color,paint:none) = {
  let pts_orders = ((range(schlafli.first()),)*schlafli.last())
    .flatten()
    .chunks(schlafli.last())
    .map(i=>i.first())
  let reg_poly_pts = range(schlafli.first())
    .map(i=>i*360deg/schlafli.first())
    .map(i=>(calc.cos(i),calc.sin(i)))
    .map(i=>i.map(j=>j*size))
  polygon(
    ..for i in pts_orders {
      (reg_poly_pts.at(i),)
    },
    fill: color,
    stroke: if paint != none {(paint:paint)}
  )
}

/*
//
// National flags
//
*/

// ad 
#let flag-ad(height:.65em) = {
  box(
    flag-v3(
      (rgb(16,6,159),rgb(254,221,0),rgb(213,0,50)),
      height: height,
      ratio:7/10)
    +place(
    // coat of arms
    dx:(10/7-10/8/3)/2*height,
    dy:-(1-10/8/3/2)*height,
    image("coat of arms/AD.svg", width:10/8/3*height)
  ))
}
// ae 1:2
#let flag-ae(height:.65em) = {
  box(
    rect(
      height:height,
      width:2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(0,115,47),white,black
      ).sharp(3)
    )
    + place(top,
      rect(
        width: 3/12*height*2,
        height: height,
        fill:rgb(200,16,46))
    )
  )
}
// af 1:2
#let flag-af(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*2,
      fill:white,
    )
    +place(
      horizon+center,
      image("coat of arms/AF.svg", height: height)
    )
  )
}
// ag 2:3
#let flag-ag(height:.65em) = {
  box(
    rect(width:height*3/2,height:height, fill:rgb("cf0821"))
    +place(dy:-height,
    polygon(
      (0%*height,0%*height),
      (100%*3/2*height,0%*height),
      ((69-13.5)/69*3/2*height,18/46*height),
      (13.5/69*3/2*height,18/46*height),
      //(50%*3/2*height,100%*height),
      fill:black
      )
    )
    +place(
      dx:(3/4-16/46)*height,
      dy:(-39.9/46)*height,
      text(fill:yellow,size:35/46*height,[\u{2739}]
      )
    )
    +place(
    polygon(
      (21/69*3/2*height,-18/46*height),
      ((69-21)/69*3/2*height,-18/46*height),
      (50%*3/2*height,0%*height),
      fill:white
      )
    )
    
    +place(
    polygon(
      (21/69*3/2*height,-18/46*height),
      ((69-21)/69*3/2*height,-18/46*height),
      ((69-13.5)/69*3/2*height,-28/46*height),
      (13.5/69*3/2*height,-28/46*height),
      fill:blue
      )
    )
    
  )
  }
// al 5:7
#let flag-al(height:.65em) = {
  box(
    rect(height: height, width: 7/5*height, inset:0pt, fill:red,image("coat of arms/AL.svg",width: 100%))
  )
}
// am 2:1
#let flag-am(height:.65em) = {
  flag-h3((rgb(217,0,18),rgb(0,51,160),rgb(242,168,0)), height: height, color-height: (1/3,1/3,1/3), ratio: 1/2)
}
// ao 2:3
#let flag-ao(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(204,9,47),
        black,
      ).sharp(2)
    )
    +place(
      center+horizon,
      image("coat of arms/AO.svg", height:1/2*height)
      
    )

  )
}
// aq 2:3
#let flag-aq(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb(7,43,95)
    )
    + place(
      horizon+center,
      circle(
        height:98%*height,
        stroke: (paint:white, thickness: .8%*height),
        ))
    + place(
      horizon+center,
      circle(
        height:104%*2/3*height,
        stroke: (paint:white, thickness: .8%*height),
        ))
    + place(
      horizon+center,
      circle(
        height:98%*1/3*height,
        stroke: (paint:white, thickness: .8%*height),
        ))
    + place(
        horizon,
        line(length: 3/2*height,stroke: (paint:white, thickness: .8%*height)))
    + place(
        horizon+center,
        line(
          length: height,
          angle:90deg,
          stroke: (paint:white, thickness: .8%*height)
        )
      )
    + place(
        horizon+center,
        line(
          length: 1.75*height,
          angle:30deg,
          stroke: (paint:white, thickness: .8%*height)
        )
      )
    + place(
        horizon+center,
        scale(
          x:-100%,
          line(
            length: 1.75*height,
            angle:30deg,
            stroke: (paint:white, thickness: .8%*height)
          )
        )
      )
    + place(
        horizon+center,
        line(
          length: 1.16*height,
          angle:60deg,
          stroke: (paint:white, thickness: .8%*height)
        )
      )
    + place(
        horizon+center,
        scale(
          x:-100%,
          line(
            length: 1.16*height,
            angle:60deg,
            stroke: (paint:white, thickness: .8%*height)
          )
        )
      )
    + place(
        horizon+center,
        image("coat of arms/AQ.svg", height:height)
      )
  )
}
// ar 5:8
#let flag-ar(height:.65em) = {
  box(
    flag-h3((rgb("74acdf"),white,rgb("74acdf")),ratio: 5/8, height: height)
    + place(
      dx:(3/5+1/20)*height,
      dy:(-2/3+1/60)*height,
      image("coat of arms/AR.svg", height:.9*height/3))
    /*
    // construction lines
    + place(
      line(start:(0*height,0*height),end:(100%*8/5*height,-100%*height))
    )
    + place(
      line(start:(0*height,-100%*height),end:(100%*8/5*height,0%*height))
    )
    */
  )
}
// as 1:2
#let flag-as(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(0,0,102)
    )
    +place(
      top,
      polygon(
        fill:rgb(189,16,33),
        (1*2*height,0*height),
        (0*2*height,1/2*height),
        (1*2*height,1*height),
      )
      )
    +place(
      top,
      polygon(
        fill:white,
        (1*2*height,30/500*height),
        (120/1000*2*height,1/2*height),
        (1*2*height,470/500*height),
      )
      )
    +place(
      horizon+right,
      dx:-20/1000*height*2,
      image("coat of arms/AS.svg",height: 6.5/10*height)
      )
  )
}
// at 2:3
#let flag-at(height:.65em) = {
  flag-h3((rgb(200,16,46),white,rgb(200,16,46)),height: height, ratio:2/3)
}
// aw 2:3
#let flag-aw(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill: rgb(65,143,222)
    )
    + place(
        bottom,
        dy:-3/18*height,
        rect(
          height: 3/18*height,
          width: 3/2*height,
          fill:gradient.linear(
            dir: ttb,
            rgb(255,210,0),
            rgb(65,143,222),
            rgb(255,210,0),

            ).sharp(3)
          )
    )
    + place(
      top,
      polygon(
        fill:red,
        stroke:(paint:white, thickness: height/100, ),
        (1/27*3/2*height,4/18*height),
        (3.5/27*3/2*height,3.5/18*height),
        (4/27*3/2*height,1/18*height),
        (4.5/27*3/2*height,3.5/18*height),
        (7/27*3/2*height,4/18*height),
        (4.5/27*3/2*height,4.5/18*height),
        (4/27*3/2*height,7/18*height),
        (3.5/27*3/2*height,4.5/18*height),
        )
    )
  )
}
// ax 17:26
#let flag-ax(height:.65em) = {
  box(
    rect(
      height: height,
      width: 26/17*height,
      fill:rgb(0,100,174)
    )
    + place(
        top,
        dx:160/520*26/17*height,
        rect(
          height:height,
          width: 100/520*26/17*height,
          fill: rgb(255,211,0),
        )
    )
    + place(
        horizon,
        rect(
          height:100/340*height,
          width: 26/17*height,
          fill: rgb(255,211,0),
        )
    )
    + place(
        top,
        dx:190/520*26/17*height,
        rect(
          height:height,
          width: 40/520*26/17*height,
          fill: rgb(218,14,21),
        )
    )
    + place(
        horizon,
        
        rect(
          height:40/340*height,
          width: 26/17*height,
          fill: rgb(218,14,21),
        )
    )
  )
}
// az 
#let flag-az(height:.65em) = {
  box(
    flag-h3((rgb(0,181,226),rgb(239,51,64),rgb(80,158,47)),height: height, ratio:2/3)
    + place(
        //dx:(3/2/2-1/3/2)*height,
        dx:(3/2/2-3/20-1/24)*height,
        dy:(-2/3+1/60)*height,
        //circle(fill:white, radius:1/3/2*height)
        circle(fill:white, radius:3/20*height)
        )
      + place(
        dx:(3/2/2-1/4/2+1/18-1/24)*height,
        dy:-(2/3-1/4/6)*height,
        circle(fill:rgb(239,51,64),  radius:(1/4/2)*height)
        )
      + place(
        dx:(3/2/2-1/4/2+1/6-1/24)*height,
        dy:-(2/3-1/13)*height,
        text(white, size:1/4*height)[#rotate(360deg/16,[\u{2738}])]
      )
      /*
      // supporting mid v line
      + place(
        dx: 3/2*height/2,
        dy: -height,
        line(
          start:(0%,0%),
          end:(0%,100%*height),
          )
      )
      // supporting mid h line
      + place(
        dx: 0%,
        dy: -height/2,
        line(
          length:height*3/2
          )
      )
      */

  )
}
// ba 
#let flag-ba(height:.65em) = {
  box(height: height,width: height*2, fill:rgb("002395"), inset: 0pt, clip: true,
    align(left,
        polygon(
          ((68+38)/400*height*2,0%),
          ((200+68+38)/400*height*2,0%),
          ((200+68+38)/400*height*2,height),
          fill:yellow
        )
        +place(
          dy:-height,
          dx:(68+25)/400*height*2,
          for i in range(9) {
            place(
              dx: (i * 25/400-12/200)*height*2,
              dy:((i -1) * 25/200+8/200)*height,
              text(fill:white,size:40/200*height)[\u{2605}]
              )
          })
    )
  )
}
// bb 2:3
#let flag-bb(height:.65em) = {
  box(
    flag-v3((rgb(0,38,127),rgb(255,199,38),rgb(0,38,127)), height:height, ratio: 2/3)
    + place(
        dy:-80%,
        dx:35%,
        image("coat of arms/BB.svg", height: height/2)
      )
    // construction lines
    // + place(line(start:(0%,-100%*height),end:(100%*height*3/2,0%*height)))
    //+ place(line(start:(0%,0%*height),end:(100%*height*3/2,-100%*height)))
  )

}
// bd 3:5
#let flag-bd(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*5/3,
      fill: rgb(0,106,78),
    )
    + place(
      horizon,
      dx:4.5/10*height,
      circle(
        radius: 2/6*height,
        fill:rgb(244,42,65)
        )
      )
  )
}
// be 2:3
#let flag-be(height:.65em) = {
  flag-v3((rgb(0,0,0),rgb(255,233,54),rgb(255,15,33)), height:height)
}
// bf 2:3?
#let flag-bf(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(239,43,45),rgb(0,158,73)
      ).sharp(2)
    )
    + place(
        horizon+center,
        dy:-8%*height,
        text(
          fill:rgb(252,209,22),
          size:2/3*height,
          [\u{2605}])
    )
  )
}
// bg 3:5
#let flag-bg(height:.65em) = {
  flag-h3((rgb("FFFFFF"),rgb(0,155,117),rgb(208,28,31)),height: height, ratio:3/5)
}
// bh 3:5
#let flag-bh(height:.65em) = {
  box(
    rect(
      height:height,
      width:5/3*height,
      fill: rgb(218,41,28)
    )
    +place(
      top,
      rect(
        height:height,
        width:25/100*5/3*height,
        fill:white
      )+
      for i in range(5).map(i=>i*2) {
        place(
          top,
          polygon(
            (24/100*5/3*height,((i)*6 )/60*height),
            (25/100*5/3*height,((i)*6 )/60*height),
            (40/100*5/3*height,((i+1)*6 )/60*height),
            (25/100*5/3*height,((i+2)*6 )/60*height),
            (24/100*5/3*height,((i+2)*6 )/60*height),
            fill:white
          )
        )
      }
    )
  )
}
// bi 3:5
#let flag-bi(height:.65em) = {
  box(
    rect(
      height: height,
      width: 5/3*height,
      fill: white
    )
    + place(
        top,
        polygon(
          (0*5/3*height,10/150*height),
          (110/250*5/3*height,1/2*height),
          (0*5/3*height,140/150*height),
          fill:rgb(67,176,42)
        )
    )
    + place(
        top,
        polygon(
          (1*5/3*height,10/150*height),
          (140/250*5/3*height,1/2*height),
          (1*5/3*height,140/150*height),
          fill:rgb(67,176,42)
        )
    )
    + place(
        top,
        polygon(
          (20/250*5/3*height,0*height),
          (125/250*5/3*height,65/150*height),
          (230/250*5/3*height,0*height),
          fill:rgb(200,16,46)
        )
    )
    + place(
        bottom,
        polygon(
          (20/250*5/3*height,0*height),
          (125/250*5/3*height,-65/150*height),
          (230/250*5/3*height,0*height),
          fill:rgb(200,16,46)
        )
    )
    + place(
      horizon+center,
      circle(
        radius:85/150/2*height,
        fill:white
        
        )
    )
    + place(
      horizon+center,
      dy:-20/150*height,
      text(
        fill:rgb(200,16,46),
        stroke: (paint:rgb(67,176,42), thickness: height/150),
        size:height/5,
        [\u{1f7cc}]
      )
    )
    + place(
      horizon+center,
      dy:12/150*height,
      dx:20/250*5/3*height,
      text(
        fill:rgb(200,16,46),
        stroke: (paint:rgb(67,176,42), thickness: height/150),
        size:height/5,
        [\u{1f7cc}]
      )
    )
    + place(
      horizon+center,
      dy:12/150*height,
      dx:-20/250*5/3*height,
      text(
        fill:rgb(200,16,46),
        stroke: (paint:rgb(67,176,42), thickness: height/150),
        size:height/5,
        [\u{1f7cc}]
      )
    )
    /*
    // construction lines
    + place(
      top,
      line(
        start:(0*5/3*height,0*height),
        end: (5/3*height,1*height),
      )
    )
    + place(
      top,
      line(
        start:(5/3*height,0*height),
        end: (0*5/3*height,1*height),
      )
    )
    */
  )
}
// bj 2:3?
#let flag-bj(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(252,210,15),rgb(233,9,41)
      ).sharp(2)
    )
    + place(
      top,
      rect(
        height: height,
        width: 2/5*3/2*height,
        fill:rgb(0,136,80)
      )
    )
  )
}
// bl 2:3
#let flag-bl(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:white
    )
    +place(
      horizon+center,
      image("coat of arms/BL.svg",height: 9/10*height)
      )
  )
}
// bn 1:2
#let flag-bn(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*2,
      fill:gradient.linear(
        angle:113deg,
        ..(rgb(247,224,23),)*3,
        ..(white,)*1,
        ..(black,)*1,
        ..(rgb(247,224,23),)*3,
        ).sharp(8)
      )
    + place(
        horizon+center,
        image(height:50%*height,"coat of arms/BN.svg")
      )
  )
}
// bo 15:22
#let flag-bo(height:.65em) = {
  box(
    flag-h3((rgb(213,43,30),rgb(252,209,22),rgb(0,121,52)),height: height, ratio:15/22)
    +place(
      dy:-(2/3-1/3*1/20)*height,
      dx:(22/15/2-43/240)*height,
      image("coat of arms/BO.svg",height: height/3*9/10)
      )
    /*  
    // construction lines
    +place(
      line(
        start:(0%*height,0%*height),
        end:(100%*height*22/15,-100%*height)
      )
      )
    +place(
      line(
        start:(100%*height*22/15,0%*height),
        end:(0%*height,-100%*height)
      )
      )
    */
  )
}
// br 7:10
#let flag-br(height:.65em) = {
  box(
    rect(height:height, width:10/7*height, fill:rgb("00923e"))
    + place(
      polygon(
        fill:rgb("ffcb00"),
        ((1.7/20)*height*10/7,(height/-2)),
        ((1/2)*height*10/7,-(14-1.7)/14*height),
        (((20-1.7)/20)*height*10/7,(height/-2)),
        ((1/2)*height*10/7,-1.7/14*height),
        )
    )
    + place(
        dy:-3/4*height,
        dx:(10/7/2-1/4)*height,
        image("coat of arms/BR.svg", height:height/2))
  )
}
// bs 
#let flag-bs(height:.65em) = {
  box(
    flag-h3((rgb(0,119,139),rgb(255,199,44), rgb(0,119,139)),height: height, ratio:1/2, color-height: (1/3,1/3,1/3))
    + place(
      dy:-height,
      polygon(
        (0%*height,0%*height),
        (calc.sqrt(3)/2*height,50%*height),
        (0%*height,100%*height),
        fill:black)
      )
  )
  
}
// bt 2:3
#let flag-bt(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb(255,213,32)
      )
      + place(
        polygon(
          fill:rgb(255,78,18),
          (0*height,0*height),
          (3/2*height,0*height),
          (3/2*height,-height)
      )
      +place(
        bottom+center,
        dy:-4.5/50*height,
        image("coat of arms/BT.svg",height:4/5*height)
      )
    )
  )
}
// bw 
#let flag-bw(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(blue,)*9,white,..(black,)*2,
      ).sharp(12).repeat(2,mirror: true)
    )
  )

}
// by 1:2
#let flag-by(height:.65em) = {
  box(
    flag-h3((rgb(0,151,57),rgb(210,39,48), none),height: height, ratio:1/2, color-height: (2/3,1/3,0))
    + place(
      dy:-height,
      image("coat of arms/BY.svg", height: height)
    )
    )
}
// bz coat of arms 3:5
#let flag-bz(height:.65em) = {
  box(
    flag-h3((rgb("d90f19"),rgb("171696"),rgb("d90f19")), height: height,ratio:3/5,color-height: (1/10,8/10,1/10))
    + place(
        dy:-5/6*height,
        dx:(1/2-1/5)*5/3*height,
        circle(fill:white, radius: 1/3*height)
        + place(
          dy:-97%,      
          dx:3%,
          image("coat of arms/BZ.svg", height: 1.9/3*height)
        )
      )
    /*  
    + place(
      dy:-50%*height,
      line(length:100%*5/3*height)
      )
    + place(
        line(
          start:(5/6*height,0%),
          end:(5/6*height,-100%*height)
        )
      )
    */
  )
}
// ca 1:2
#let flag-ca(height:.65em) = {
  box(
    flag-v3((rgb("ed1c24"),white,rgb("ed1c24")), height:height, color-width: (1/4,1/2,1/4), ratio: 1/2)
    + place(
      dx:(1/2+1/7)*height,
      dy:(-1+1/8)*height,
      image("coat of arms/CA.svg", height: 3/4*height)
    )
    //+ place(dy:-height/2,line(length: 2*height))
    //+ place(dy:-height/2, dx:height/2,rotate(90deg,line(length: height)))
  )
}
// cc 1:2
#let flag-cc(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(0,128,0)
    )
    +place(
      top,
      dx:40/600*height*2,
      dy:25/300*height,
      circle(
        radius:50/300*height,
        fill: rgb(255,224,0)
        )
        +place(
          center+horizon,
          image("coat of arms/CC.svg", height:1/4*height)
        )
      )
    
    +place(
      center+horizon,
      circle(
        radius:50/300*height,
        fill: rgb(255,224,0)
        )
      )
    +place(
      center+horizon,
      dx:20/600*height*2,
      circle(
        radius:40/300*height,
        fill: rgb(0,128,0)
        )
      )
    +place(
      top,
      dx:360/600*height*2,
      dy:140/300*height,
      rotate(14deg,polygram((7,3),height/12,rgb(255,224,0)))
    )
    +place(
      top,
      dx:500/600*height*2,
      dy:120/300*height,
      rotate(14deg,polygram((7,3),height/12,rgb(255,224,0)))
    )
    +place(
      top,
      dx:430/600*height*2,
      dy:60/300*height,
      rotate(14deg,polygram((7,3),height/12,rgb(255,224,0)))
    )
    +place(
      top,
      dx:430/600*height*2,
      dy:240/300*height,
      rotate(14deg,polygram((7,3),height/12,rgb(255,224,0)))
    )
    +place(
      top,
      dx:470/600*height*2,
      dy:160/300*height,
      rotate(-18deg,polygram((5,2),height/16,rgb(255,224,0)))
    )
  )
}
// cd 4:3
#let flag-cd(height:.65em) = {
  box(
    rect(
      height: height,
      width: 4/3*height,
      fill: rgb(247,214,24)
    )
    + place(
      top,
      polygon(
        (0*height,0*height),
        (15/16*4/3*height,0*height),
        (0*height,3/4*height),
        fill: rgb(0,127,255)
      )
      + place(
        top,
        dy:-1/20*height,
        text(
          fill: rgb(247,214,24),
          size: 3/4*height,
          [\u{2605}]
        )
      )
    )
    + place(
      top,
      polygon(
        (4/3*height,1*height),
        (4/3*height,1/4*height),
        (1/16*4/3*height,1*height),
        fill: rgb(0,127,255)
      )
    )
    + place(
      top,
      polygon(
        (4/3*height,0*height),
        (4/3*height,1/5*height),
        (0*height,1*height),
        (0*height,4/5*height),
        fill:rgb(206,16,33)
      )
    )
    )
    /*
    // construction line
    + place(
      line(
        start:(0*height,0*height),
        end:(1*5/4*height,-1*height),
        )
    )
    */
}
// cf 2:3
#let flag-cf(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(0,48,130),
        white,
        rgb(40,151,40),
        rgb(255,206,0)
      ).sharp(4)
    )
    + place(
        bottom+center,
        rect(
          height: height,
          width: 1/6*3/2*height,
          fill:rgb(210,16,52)
          )
    )
    + place(
        top,
        dy:-2%*height,
        dx:1/12*height,
        text(
          fill:rgb(255,206,0),
          size:1/3*height,
          [\u{2605}]
        ))
  )
}
// cg 2:3
#let flag-cg(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb(251,222,74)
    )
    + place(
      top,
      polygon(
        fill:rgb(0,149,67),
        (0*height,0*height),
        (1*height,0*height),
        (0*height,1*height),
      )
    )
    + place(
      bottom+right,
      polygon(
        fill:rgb(220,36,31),
        (0*height,0*height),
        (-1*height,0*height),
        (0*height,-1*height),
      )
    )
  )
}
// ch 1:1
#let flag-ch(height:.65em) = {
  box(
    rect(
      height: height,
      width: height,
      fill: rgb(200,16,46)
      )
    + place(
        horizon+center,
        rect(
          height: 20/32*height,
          width: 6/32*height,
          fill:white
          )
    )
    + place(
        horizon+center,
        rect(
          height: 6/32*height,
          width: 20/32*height,
          fill:white
          )
    )
  )
}
// ci 2:3
#let flag-ci(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        rgb(255,130,0),
        white,
        rgb(0,154,68)
      ).sharp(3)
    )
  )
}
// cl 2:3
#let flag-cl(height:.65em) = {
  box(
    flag-h3((white,rgb(213,43,30),none),color-height: (1/2,1/2,0),ratio:2/3, height: height)
    + place(
      dy:-height,
      rect(
        fill:rgb(0,57,166),
        width:1/3*6/4*height,
        height:height/2,)
        +place(
          dy:(-1/2+1/30)*height,
          dx:1/3*6/4*height/5,
          text(white, size:1/2*height,[\u{2605}])
          )
        /*
        +place(
          line(start:(0%,0%),end:(100%*1/3*6/4*height,-100%*height/2))
          )
        +place(
          line(start:(100%*1/3*6/4*height,0%),end:(0%,-100%*height/2))
          )
        */
      )
  )
}
// cm 2:3
#let flag-cm(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        rgb("007a5e"),rgb("ce1126"),rgb("fcd116")
      ).sharp(3)
    )
    + place(
      center+horizon,
      text(
        fill:rgb("fcd116"),
        size:height/2,
        [\u{2605}]
      )
    )
  )
}
// cn 2:3
#let flag-cn(height:.65em) = {
  box(
    rect(height: height,width: 3/2*height, fill:rgb(238,28,37))
    + place(
      dy:-height,
      dx:2/30*height,
        text(fill:yellow,size:6/15*3/2*height,[\u{2605}])
        )
    + place(
            dy:-height,
            dx:13/30*height,
        text(fill:yellow,size:2.5/15*height,rotate(20deg,[\u{2605}]))
        )  
    + place(
            dy:(-1+0.12)*height,
            dx:16/30*height,
        text(fill:yellow,size:2.5/15*height,rotate(-20deg,[\u{2605}]))
        )  
    + place(
            dy:(-1+0.27)*height,
            dx:16/30*height,
        text(fill:yellow,size:2.5/15*height,[\u{2605}])
        )  
    + place(
            dy:(-1+1.15/3)*height,
            dx:13/30*height,
        text(fill:yellow,size:2.5/15*height,rotate(20deg,[\u{2605}]))
        )
    /*
    // construction line  
    +place(line(start:(0*height,-height/2),
    end: (3/2*height,-height/2)))
    +place(line(
      start:(3/4*height,-height),
      end: (3/4*height,0*height))
      )
    */
  )
}
// co 2:3
#let flag-co(height:.65em) = {
  box(
    flag-h3((rgb("FFCD00"),rgb("003087"),rgb("C8102E")),color-height: (1/2,1/4,1/4), height: height, ratio:2/3)
  )
}
// cr 3:5
#let flag-cr(height:.65em) = {
  box(
    rect(fill:none, stroke:none,height:height,width: 5/3*height,inset: 0pt,
      stack(
        dir:ttb,
        rect(
            width:100%,
            height: 100%*1/6,
            fill: rgb("001489"),
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/6,
            fill: white,
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/3,
            fill: rgb("da291c"),
            stroke:none
          )
        + place(
            dy:-95%,
            dx: 15%,
            scale(
              x:90%,
              circle(
                fill:white,
                height:30%)
              + place(
                dy:-92%,
                dx:12%,
                image("coat of arms/CR.svg", height: height/4)
              )
            )
          ),   
        rect(
            width:100%,
            height: 100%*1/6,
            fill: white,
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/6,
            fill: rgb("001489"),
            stroke:none
          ),
        )
      )
    )
}
// cu 1/2
#let flag-cu(height:.65em) = {
  box(
    rect(fill:none, stroke:none,height:height,width: 5/3*height,inset: 0pt,
      stack(
        dir:ttb,
        rect(
            width:100%,
            height: 100%*1/5,
            fill: rgb("002590"),
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/5,
            fill: white,
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/5,
            fill: rgb("002590"),
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/5,
            fill: white,
            stroke:none
          ),
        rect(
            width:100%,
            height: 100%*1/5,
            fill: rgb("002590"),
            stroke:none
          )
        )
    )
    + place(
      dy:-100%*height,
      polygon(
        (0%*height,0%*height),
        (calc.sqrt(3)/2*height,50%*height),
        (0%*height,100%*height),
        fill:rgb("CC0d0d"))
      )
    + place(
      dy:-70%,
      dx:10%,
      text(fill:white,size:height/2,[\u{2605}])
    )
  )
  
}
// cv 10:17
#let flag-cv(height:.65em) = {
  box(
    rect(
      height: height,
      width: 17/10*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(0,56,147),)*6,
        ..(white,)*1,
        ..(rgb(207,32,39),)*1,
        ..(white,)*1,
        ..(rgb(0,56,147),)*3,
      ).sharp(12)
    )
    + for i in range(10){
      place(
        top,
        dx:(4/7+ calc.cos(i*36*1deg-18deg)/4)*height,
        dy:(4/7 + calc.sin(i*36*1deg-18deg)/4)*height,
        text(
          fill:rgb(247,209,22),
          size:1/8*height,
          [\u{2605}]
          ),
        )
    }
  )
}
// cw 2:3
#let flag-cw(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir: ttb,
        ..(
          (rgb(1,33,105),)*5,
        (rgb(252,227,0),)*1,
        (rgb(1,33,105),)*2,
        ).flatten()
        ).sharp(8)
    )
    +place(
      top,
      dx:1/2.85*height,
      dy:1/3.2*height,
      rotate(-18deg,polygram((5,2),1/9*height,white))
    )
    +place(
      top,
      dx:1/5.65*height,
      dy:1/6.3*height,
      rotate(-18deg,polygram((5,2),1/12*height,white))
    )
  )
}
// cx 1:2
#let flag-cx(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(13,176,43)
    )
    +place(
      top,
      polygon(
        fill:rgb(1,33,105),
        (0*2*height,0*height),
        (0*2*height,1*height),
        (1*2*height,1*height),
        )
      )
    +place(
      top,
      dx:100/512*height*2,
      dy:110/256*height,
      rotate(62deg,polygram((7,3),height/12,white))
      )
    +place(
      top,
      dx:120/512*height*2,
      dy:230/256*height,
      rotate(62deg,polygram((7,3),height/12,white))
      )
    +place(
      top,
      dx:160/512*height*2,
      dy:150/256*height,
      rotate(62deg,polygram((7,3),height/12,white))
      )
    +place(
      top,
      dx:50/512*height*2,
      dy:170/256*height,
      rotate(62deg,polygram((7,3),height/12,white))
      )
    +place(
      top,
      dx:150/512*height*2,
      dy:170/256*height,
      rotate(-18deg,polygram((5,2),height/15,white))
      )
    +place(
      top,
      image("coat of arms/CX.svg", height: height))
  )
}
// cy 3/5
#let flag-cy(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*5/3, 
      inset: 0pt,
      fill:white,
      align(center+horizon,
      image("coat of arms/CY.svg")
      ))
    )
}
// cz
#let flag-cz(height:.65em) = {
  box(
    flag-h3((white,cmyk(0%, 100%, 96%, 8%),none),height: height,color-height: (1/2,1/2,0), ratio:2/3)+
    place(
      dx: 0pt,
      dy:-height,
      polygon(
        fill:cmyk(97%, 73%, 8%, 19%), 
        (0%*height*3/2,0%*height),
        (50%*height*3/2,50%*height),
        (0%*height,100%*height)
      )
    )
  )
}
// de 3:5
#let flag-de(height:.65em) = {
  flag-h3((rgb("000000"),rgb("FF0000"), rgb("FFCC00")),height: height)
}
// dj 2:3?
#let flag-dj(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(106,178,231),
        rgb(18,173,43)
      ).sharp(2)
    )
    + place(
      top,
      polygon(
        (0*height,0*height),
        (calc.sqrt(3)/2*height,1/2*height),
        (0*height,1*height),
        fill:white
      )
      + place(
        horizon+center,
        dx:-10%*height,
        dy:-5%*height,
        text(
          fill:rgb(215,20,26),
          size: height/2,
          [\u{2605}]
        )
        )

    )
  )
}
// dk 28:37
#let flag-dk(height:.65em) = {
  box(
    rect(
      height: height,
      width:  37/28*height,
      fill: rgb(200,16,46)
      )
    + place(
      top,
      dx: 12/37*37/28*height,
      rect(
        height: height,
        width: 4/37*37/28*height,
        fill: white
      )
    )
    + place(
      horizon,
      rect(
        height: 4/28*height,
        width: 37/28*height,
        fill: white
      )
    )
  )
}
// dm 1:2
#let flag-dm(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill : black
    )
    +place(
      top,
      rect(
        height:275/600*height,
        width:575/1200*height*2,
        fill:rgb(255,205,0)
        )
    )
    +place(
      top,
      rect(
        height:225/600*height,
        width:525/1200*height*2,
        fill:rgb(0,136,80)
        )
    )
    +place(
      top,
      dy:(600-275)/600*height,
      dx:(1200-575)/1200*height*2,
      rect(
        height:275/600*height,
        width:575/1200*height*2,
        fill:white
        )
    )
    +place(
      top,
      dy:(600-225)/600*height,
      dx:(1200-525)/1200*height*2,
      rect(
        height:225/600*height,
        width:525/1200*height*2,
        fill:rgb(0,136,80)
        )
    )
    +place(
      top,
      dy:(600-225)/600*height,
      dx:0*height*2,
      rect(
        height:225/600*height,
        width:525/1200*height*2,
        fill:rgb(0,136,80)
        )
    )
    +place(
      top,
       dx:625/1200*height*2,
      rect(
        height:275/600*height,
        width:50/1200*height*2,
        fill:white)
      )
    +place(
      top,
      dx:675/1200*height*2,
      dy:225/600*height,
      rect(
        height: 50/600*height,
        width: (1200-675)/1200*height*2,
        fill:rgb(255,205,0)
      )
    )
    +place(
      top,
      dy:325/600*height,
      rect(
        height: 50/600*height,
        width: (1200-675)/1200*height*2,
        fill:white
      )
    +place(
      top,
       dx:525/1200*height*2,
      rect(
        height:275/600*height,
        width:50/1200*height*2,
        fill:rgb(255,205,0))
      )
    )
    +place(
      top,
      dy:0*height,
      dx:(1200-525)/1200*height*2,
      rect(
        height:225/600*height,
        width:525/1200*height*2,
        fill:rgb(0,136,80)
        )
    )
    +place(
      horizon+center,
      circle(
        radius: 150/600*height,
        fill:rgb(213,0,50)
      )
      )
    // position line
    // +place(
    //   horizon+center,
    //   circle(
    //     radius: 120/600*height,
    //     //stroke: (dash:("dot",3pt))
    //   )
    //   )
    // star 1
    +place(
      horizon+center,
      dx:16/1200*height*2,
      dy:-110/600*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 2
    +place(
      horizon+center,
      dx:72/1200*height*2,
      dy:-83/600*height,
      rotate(
        -18deg+36deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 3
    +place(
      horizon+center,
      dx:108/1200*height*2,
      dy:-23/600*height,
      rotate(
        -18deg+72deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 4
    +place(
      horizon+center,
      dx:102/1200*height*2,
      dy:42/600*height,
      rotate(
        -18deg+108deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 5
    +place(
      horizon+center,
      dx:60/1200*height*2,
      dy:92/600*height,
      rotate(
        -18deg+144deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 6
    +place(
      horizon+center,
      dx:-12/1200*height*2,
      dy:110/600*height,
      rotate(
        -18deg+180deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 7
    +place(
      horizon+center,
      dx:-79/1200*height*2,
      dy:78/600*height,
      rotate(
        -18deg+216deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 8
    +place(
      horizon+center,
      dx:-110/1200*height*2,
      dy:20/600*height,
      rotate(
        -18deg+252deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 9
    +place(
      horizon+center,
      dx:-102/1200*height*2,
      dy:-43/600*height,
      rotate(
        -18deg+288deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    // star 10
    +place(
      horizon+center,
      dx:-60/1200*height*2,
      dy:-91/600*height,
      rotate(
        -18deg+324deg,
        polygram(
          (5,2),
          20/600*height,
          rgb(0,136,80)
        )
      ), 
    )
    + place(
        horizon+center,
        image("coat of arms/DM.svg", height:height/3.5)
    )
  )

}
// do 
#let flag-do(height:.65em) = {
  box(
    rect(width:3/2*height,height:height,fill:white)
    + place(
      dy:-height,
      rect(
        width: (3/4-1/10)*height,
        height: (1/2-1/10)*height,
        fill:rgb(0,45,98))
    )
    + place(
      dx:3/2*height,
      rect(
        width: -(3/4-1/10)*height,
        height: -(1/2-1/10)*height,
        fill:rgb(0,45,98))
    )
    + place(
      rect(
        width: (3/4-1/10)*height,
        height: -(1/2-1/10)*height,
        fill:rgb(206,17,38))
    )
    + place(
      dx:3/2*height,
      dy: -height,
      rect(
        width: -(3/4-1/10)*height,
        height: (1/2-1/10)*height,
        fill:rgb(206,17,38))
    )
    + place(
        dx:(3/4-1/10)*height,
        dy:(-1+4/10)*height,
        image("coat of arms/DO.svg", width:3/10*2/3*height)
        )
  )
}
// dz 2:3
#let flag-dz(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        rgb(0,102,51),
        white
      ).sharp(2)
    )
    + place(
      horizon+center,
      circle(
        radius:5/20*height,
        fill:rgb(201,16,52),
        )
    )
    + place(
      horizon+center,
      dx:2/30*height,
      circle(
        radius:4/20*height,
        fill: gradient.linear(
          ..(rgb(0,102,51),)*1,
          ..(white,)*2
        ).sharp(3)
      )
    )
    + place(
      horizon+center,
      dy:-0.66/20*height,
      dx:2/30*height,
      rotate(-54deg,
        text(
          fill:rgb(201,16,52),
          size:height/2,
          [\u{2605}]
        )
      )
    )
    /*
    // construction line
    + place(
      horizon+center,
      line()
      )
    */
  )
}
// ec 2:3
#let flag-ec(height:.65em) = {
  box(
    flag-h3((rgb("FFDD00"),rgb("034ea2"),rgb("ed1c24")),color-height: (1/2,1/4,1/4), height: height, ratio:2/3)
    +place(
      dy:-3/4*height,
      dx:2/4*height,
      image("coat of arms/EC.svg", height: height/2))
    /*
    + place(
        line(start:(3/4*height,0*height),end:(3/4*height,-100%*height))
        )
    */
  )
}
// ee 7:11
#let flag-ee(height:.65em) = {
  flag-h3((rgb("0072ce"),rgb("000000"),white),height: height, ratio:7/11)
}
// eg 
#let flag-eg(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(dir:ttb,rgb(206,17,38),white,black).sharp(3)
    )
    +place(
      horizon+center,
      image("coat of arms/EG.svg",height:height/3)
    )
  )
}
// eh 1:2
#let flag-eh(height:.65em) = {
  box(
    rect(
      height: height,
      width:height*2,
      fill:gradient.linear(
        dir:ttb,
        black,
        white,
        rgb(0,151,54)
      ).sharp(3)
    )
    + place(
        top,
        polygon(
          (0*height,0*height),
          (1/3*2*height,1/2*height),
          (0*height,1*height),
          fill:rgb(238,42,53)
        )
      )
    + place(
      center+horizon,
      circle(
        radius: height/7,
        fill:rgb(238,42,53)
      )
      )
    + place(
      center+horizon,
      dx:3/100*height*2,
      circle(
        radius: height/7,
        fill:white        
      )
      )
    + place(
      center+horizon,
      dx:6/100*height*2,
      dy:3/100*height,
      rotate(-18deg,polygram(
        (5,2),
        height/9,
        rgb(238,42,53)
      ))
      )
  )
}
// er 1:2
#let flag-er(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        dir:ttb,
      rgb(11,172,36),
      rgb(60,139,220)
      ).sharp(2), 
    )
    + place(
      top,
      polygon(
        (0*2*height,0*height,),
        (0*2*height,1*height,),
        (1*2*height,1/2*height,),
        fill:rgb(235,4,51)
      )
    )
    + place(
      horizon,
      dx:10%*2*height,
      image("coat of arms/ER.svg", height: height/2)
      )
  )
}
// es 2:3
#let flag-es(height:.65em) = {
  box(
    flag-h3((rgb("AD1519"),rgb("FABD00"),rgb("AD1519")), height:height,color-height: (1/4,1/2,1/4),ratio:2/3)+place(
      // coat of arms
      dx:height*30%,
      dy:height*-72%,
      image("coat of arms/ES.svg", width:3/8*height)
    )
  )
}
// et 1:2
#let flag-et(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(7,137,48),
        rgb(252,221,9),
        rgb(218,18,26)
        ).sharp(3)
    )
    + place(
      horizon+center,
      circle(
        fill:rgb(15,71,175),
        radius:2/3/2*height,
        )
    )
     + place(
      horizon+center,
      rotate(180deg,
        text(
          fill:rgb(252,221,9),
          size:height/2,
          weight:10,
          [\u{1f7af}]
        )
      )
     )
     + place(
      horizon+center,
      dy:1.75%*height,
      circle(
        radius:2/3/7*height,
        fill:rgb(15,71,175),)
     )
     + place(
      horizon+center,
      text(
        fill:rgb(252,221,9),
        size:height/2,
        weight:100,
        [\u{26E4}]
        )
     )
  )
}
// eu 2:3
#let flag-eu(height:.65em) = {
  let star = text(rgb("FFCC00"), size:2/9*height)[\u{2605}]
  box(
    height:height,
    width:3/2*height,
    outset: 0pt,
    fill:rgb("003399"),
    for i in range(12){
      place(
        dx:(3/4 - 1.2/18 + calc.cos(i*30*1deg)/3)*height,
        dy:(1/2 - 1.7/18 + calc.sin(i*30*1deg)/3)*height,
        star,
        )
    }
    
  )
}
// fi 11:18
#let flag-fi(height:.65em) = {
  box(
    rect(
      height: height,
      width: 18/11*height,
      fill: white
    )
    +place(
      top,
      dx:5/18*18/11*height,
      rect(
        height: height,
        width: 3/18*18/11*height,
        fill: rgb(24,68,126)
      )
    )
    +place(
      horizon,
      rect(
        height: 3/11*height,
        width: 18/11*height,
        fill: rgb(24,68,126)
      )
    )
  )
}
// fm 10:19
#let flag-fm(height:.65em) = {
  box(
    rect(
      height: height,
      width: 19/10*height,
      fill:rgb(98,181,229)
    )
    +place(
      center+horizon,
      dx:height/3,
      dy:height/20,
      polygram((5,2),height/10,white)
    )
    +place(
      center+horizon,
      dy:-height/4,
      dx:height/15,
      rotate(-18deg,polygram((5,2),height/10,white))
    )
    +place(
      center+horizon,
      dy:height/4,
      dx:height/15,
      scale(y:-100%,rotate(-18deg,polygram((5,2),height/10,white)))
    )
    +place(
      center+horizon,
      dx:-height/3,
      dy:height/20,
      scale(x:-100%,polygram((5,2),height/10,white))
    )
  )
}
// fo 8:11
#let flag-fo(height:.65em) = {
  box(
    rect(
      height: height,
      width: 11/8*height,
      fill:white,
    )
    +place(
      top,
      dx:6/22*11/8*height,
      rect(
        height: height,
        width: 4/22*11/8*height,
        fill: rgb("005EB9")
        )
    )
    +place(
      horizon,
      rect(
        height: 4/16*height,
        width: 11/8*height,
        fill: rgb("005EB9")
        )
    )
    +place(
      top,
      dx:7/22*11/8*height,
      rect(
        height: height,
        width: 2/22*11/8*height,
        fill: rgb("EF303E")
        )
    )
    +place(
      horizon,
      rect(
        height: 2/16*height,
        width: 11/8*height,
        fill: rgb("EF303E")
        )
    )
  )
}
// fr 2:3
#let flag-fr(height:.65em) = {
  flag-v3((rgb(0,85,164),white,rgb(239,65,53)), height:height)
}
// ga 3:4
#let flag-ga(height:.65em) = {
  box(
    rect(
      height: height,
      width: 4/3*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(0,158,96),
        rgb(252,209,22),
        rgb(58,117,196),
      ).sharp(3)
    )
  )
}
// gb 1:2
#let flag-gb(height:.65em) = {
  box(
    rect(
      height:height,width:height*2, fill:white, inset: 0pt,
      // blue triangle left top top
      place(
        dx: 6/60*height*2,
        polygon(
          (0%,0%),
          (19/30*height,0%),
          (19/30*height,8/25*height),
          fill:rgb("012169")
          ),
        )+
      // blue triangle left top bottom
      place(
        dy:3/30*height,
        polygon(
          (0%,0%),
          (0%,(7/30)*height),
          (12/25*height,(7/30)*height),
          fill:rgb("012169")
          ),
        )+
      // blue triangle right top top
      place(
        dx:35/60*height*2,
        polygon(
          (0%,0%),
          (19/30*height,0%),
          (0%,8/25*height),
          fill:rgb("012169")
          )
        )+
      // blue triangle right top bottom
      place(
        //dy:-27/30*height,
        dy:3/30*height,
        dx: height*2,
        polygon(
          (0%,0%),
          (0%,(7/30)*height),
          (-12/25*height,(7/30)*height),
          fill:rgb("012169")
          )
        )+
      // blue triangle left bottom top
      place(
        dy:2/3*height,
        polygon(
          (0%,0%),
          (0%,(7/30)*height),
          (12/25*height,0%),
          fill:rgb("012169")
          )
        )+
      // blue triangle left bottom bottom
      place(
        dy:height,
        dx:6/60*height*2,
        polygon(
          (0%,0%),
          (19/30*height,0%),
          (19/30*height,-8/25*height),
          fill:rgb("012169")
          )
      )+
      // blue triangle right bottom top
      place(
        dy:2/3*height,//-1/3*height,
        dx:height*2,
        polygon(
          (0%,0%),
          (0%,(7/30)*height),
          (-12/25*height,0%),
          fill:rgb("012169")
        )
      )+
      // blue triangle right bottom bottom
      place(
        dy:height,
        dx:35/60*height*2,
        polygon(
          (0%,0%),
          (19/30*height,0%),
          (0%,-8/25*height),
          fill:rgb("012169")
        )
      )+
      // red quadrilater left top
      place(
        polygon(
          (0%,0%),
          (20/60*height*2,10/30*height),
          (16/60*height*2,10/30*height),
          (0%,2/30*height),
          fill:rgb("c8102e")
        )
      )+
      // red quadrilater right top
      place(
        dx:height*2,
        polygon(
          (0%,0%),
          (-4/60*height*2,0%),
          (-24/60*height*2,10/30*height),
          (-20/60*height*2,10/30*height),
          fill:rgb("c8102e")
        )
      )+
      // red quadrilater left bottom
      place(
        dy:height,
        polygon(
          (0%,0%),
          (4/60*height*2,0%),
          (24/60*height*2,-10/30*height),
          (20/60*height*2,-10/30*height),
          fill:rgb("c8102e")
        )
      )+
      // red quadrilater right bottom
      place(
        dy:height,
        dx:height*2,
        polygon(
          (0%,0%),
          (0%,-2/30*height),
          (-16/60*height*2,-10/30*height),
          (-20/60*height*2,-10/30*height),
          fill:rgb("c8102e")
        )
      )+
      // red cross
      place(
        dy:12/30*height,//-18/30*height,
        polygon(
          (0%,0%),
          ((27/30)*height,0%),
          (27/30*height,-12/30*height),
          (33/30*height,-12/30*height),
          (33/30*height,0%),
          (60/30*height,0%),
          (60/30*height,6/30*height),
          (33/30*height,6/30*height),
          (33/30*height,18/30*height),
          (27/30*height,18/30*height),
          (27/30*height,6/30*height),
          (0%,6/30*height),
          fill:rgb("c8102e")
          )
        ) 
      // construction support lines
      /*
      // horizontal support line
      + place(
        dy:20/30*height,
        line(length: 100%*height*2, stroke:orange)
      )
      +// vertical support line
      place(
        dx: 10/30*height,
        rotate(90deg,line(length: 100%*height*2, stroke:orange))
      )
      //diag support line
      +place(
        line(start:(0%,0%),end:(height*2,height), stroke:(dash:"dashed"))
        )
      // opposite diag support line
      +place(
        line(start:(height*2,0%),end:(0%,height), stroke:(dash:"dashed"))
        )
      */
    )
  )
}
// bm 1:2
#let flag-bm(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb("c8102e"),
    )
    +place(top+left,
      flag-gb(height:height/2)
    )
    +place(horizon,
      dx:325/500*2*height,
      image("coat of arms/BM.svg", height:height/2)
    )
  )
}
// ck 1:2
#let flag-ck(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb("012169")
    )
    +place(
      top,
      flag-gb(height:height/2))
    +place(
      horizon,
      dx:3/4*height*2,
      dy:-1/20*height,
      for i in range(15) {
        place(
          dx:calc.cos(i*24deg)*1/3*height,
          dy:calc.sin(i*24deg)*1/3*height,
          rotate(i*24deg,rotate(-i*1deg,polygram((5,2),height/15,white)), origin: left+bottom)
          )
      }
      )
  )
}
// ai 1:2
#let flag-ai(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb("012169")
    )
    +place(
      top,
      flag-gb(height: height/2)
      )
    + place(
        horizon,
        dx: 2/3*2*height,
        image("coat of arms/AI.svg",
        height:height/2)
    )
  )
}
// au 1:2
#let flag-au(height:.65em) = {
  let heptagram(size,color) = {
  let reg_poly_pts = range(7).map(i=>(calc.cos(i*360deg/7),calc.sin(i*360deg/7))).map(i=>i.map(j=>j*size))
  polygon(
        reg_poly_pts.at(0),
        reg_poly_pts.at(3),
        reg_poly_pts.at(6),
        reg_poly_pts.at(2),
        reg_poly_pts.at(5),
        reg_poly_pts.at(1),
        reg_poly_pts.at(4),
        fill:color
      )
  } 
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb("012169")
    )
    + place(
      top,
      flag-gb(height:height/2)
      + place(
        center,
        dx:height/14,
        dy:height*9/32,
        rotate(
          25.714/2*1deg,
          heptagram(height/6,white)
          )
        )
      )
    // gamma crucis
    + place(
        horizon,
        dx:height*3/4*2,
        dy:height*-6/24,
        rotate(
          25.714/2*1deg,
          heptagram(height/10,white)
          )
        )
    // alpha crucis
    + place(
        horizon,
        dx:height*3/4*2,
        dy:height*9/24,
        rotate(
          25.714/2*1deg,
          heptagram(height/10,white)
          )
        )
    // beta crucis
    + place(
        horizon+right,
        dx:height*-5/8,
        dy:height*1/24,
        rotate(
          25.714/2*1deg,
          heptagram(height/10,white)
          )
        )
    // epsilon crucis
    + place(
        horizon,
        dx:height*6/7*2,
        dy:height*-1/24,
        rotate(
          25.714/2*1deg,
          heptagram(height/10,white)
          )
        )
    // delta crucis
    + place(
      top+right,
      dx:height*-3/9,
      dy:height*12/24,
      rotate(-90deg,polygram((5,2),height/16,white)),
    )
  )
}
// fj 1:2
#let flag-fj(height:.65cm) = {
  box(
    rect(
      height: height,
      width:2*height,
      fill:rgb(98,181,229)
    )
  + place(
    top+left,
    flag-gb(height: height/2)
    )
  + place(
      horizon+center,
      dx:1/4*height*2,
      image("coat of arms/FJ.svg", height: height/2)
    )
  )  
}
// fk 1:2
#let flag-fk(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb("012169")
    )
    + place(
      top,
      flag-gb(height:height/2)
    )
    + place(horizon+center,
      dx:4/15*2*height,
      image("coat of arms/FK.svg", height: 2/3*height)
      )
  )
}
// gd 3:5
#let flag-gd(height:.65em) = {
  box(
    rect(
      height: height,
      width: 5/3*height,
      fill:rgb(206,17,38)
    )
    +place(
      top,
      polygon(
        (2/20*height*5/3,1/10*height),
        (18/20*height*5/3,1/10*height),
        (2/20*height*5/3,9/10*height),
        (18/20*height*5/3,9/10*height),
        fill:rgb(252,209,22)
        )
    )
    +place(
      top,
      polygon(
        (2/20*height*5/3,1/10*height),
        (18/20*height*5/3,9/10*height),
        (18/20*height*5/3,1/10*height),
        (2/20*height*5/3,9/10*height),
        fill:rgb(0,122,94)
        )
    )
    +place(
      center+horizon,
      circle(
        radius: height/7,
        fill:rgb(206,17,38)
      )
    )
    // star in the middle
    +place(
      center+horizon,
      dx:1/12*height,
      dy:1/45*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/7,
          rgb(252,209,22)
        )
      )
    )
    // star central at top
    +place(
      center+top,
      dx:1/32.5*height,
      dy:1/25*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/20,
          rgb(252,209,22)
        )
      )
    )
    // star central at bottom
    +place(
      center+bottom,
      dx:1/32.5*height,
      dy:-1/75*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/20,
          rgb(252,209,22)
        )
      )
    )
    // star left at top
    +place(
      center+top,
      dx:-1/3.5*height,
      dy:1/25*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/20,
          rgb(252,209,22)
        )
      )
    )
    // star left at bottom
    +place(
      center+bottom,
      dx:-1/3.5*height,
      dy:-1/75*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/20,
          rgb(252,209,22)
        )
      )
    )
    // star right at top
    +place(
      center+top,
      dx:1/3*height,
      dy:1/25*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/20,
          rgb(252,209,22)
        )
      )
    )
    // star right at bottom
    +place(
      center+bottom,
      dx:1/3*height,
      dy:-1/75*height,
      rotate(
        -18deg,
        origin:right,
        polygram(
          (5,2),
          height/20,
          rgb(252,209,22)
        )
      )
    )
    // nutmeg
    + place(
        left+horizon,
        dx:1/5*height,
        image("coat of arms/GD.svg", height:height/5)
      )
    // construction lines
    // vertical center line
    // + place(
    //   center+top,
    //   line(
    //     start:(0%*height*5/3,0%*height),
    //     end:(0%*height*5/3,100%*height))
    //   )
    // diag 1
    // +place(
    //   top,
    //   line(
    //     start:(0%*height*5/3,0%*height),
    //     end:(100%*height*5/3,100%*height),
    //     )
    //   )
    // // diag 2
    // +place(
    //   top,
    //   line(
    //     start:(100%*height*5/3,0%*height),
    //     end:(0%*height*5/3,100%*height),
    //     )
    //   )
  )
}
// ge 2:3
#let flag-ge(height:65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:white
    )
    +place(
      top,
      dx:130/300*3/2*height,
      rect(
        height:height,
        width:40/300*3/2*height,
        fill:red
      )
    )
    +place(
      horizon,
      rect(
        height:40/200*height,
        width:3/2*height,
        fill:red
      )
    )
    +place(dy:-180/200*100%, dx:10%,text(red, size: height/3,[\u{2720}]))
    +place(dy:-60/200*100%, dx:10%,text(red, size: height/3,[\u{2720}]))
    +place(dy:-180/200*100%, dx:65%,text(red, size: height/3,[\u{2720}]))
    +place(dy:-60/200*100%, dx:65%,text(red, size: height/3,[\u{2720}]))
  )
}
// gf
#let flag-gf(height:.65em) = {
  flag-fr(height:height)
}
// gg 2:3
#let flag-gg(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:white
    )
    +place(
      top+center,
      rect(
        height:height,
        width: 1/6*3/2*height,
        fill:rgb(232,17,45)
      ))
    +place(
      horizon+center,
      rect(
        height:1/4*height,
        width: 3/2*height,
        fill:rgb(232,17,45)
      ))
    +place(
      horizon+center,
      rect(
        height:450/600*height,
        width: 1/18*3/2*height,
        fill:rgb(249,221,22)
      ))
    +place(
      horizon+center,
      rect(
        height:1/18*3/2*height,
        width: 450/600*height,
        fill:rgb(249,221,22)
      ))
    +place(
      top,
      dx:225/900*height,
      polygon(
        fill:rgb(249,221,22),
        (375/900*height,74/600*height),
        (525/900*height,74/600*height),
        (450/900*height,120/600*height)
        )
      )
    +place(
      bottom,
      dx:225/900*height,
      polygon(
        fill:rgb(249,221,22),
        (375/900*height,-74/600*height),
        (525/900*height,-74/600*height),
        (450/900*height,-120/600*height)
        )
      )
    +place(
      horizon+center,
      dx:360/900*height,
      dy:-125/600*height,
      rotate(90deg,polygon(
        fill:rgb(249,221,22),
        (375/900*height,74/600*height),
        (525/900*height,74/600*height),
        (450/900*height,120/600*height)
        )
      ))
    +place(
      horizon+center,
      dx:-360/900*height,
      dy:125/600*height,
      rotate(-90deg,polygon(
        fill:rgb(249,221,22),
        (375/900*height,74/600*height),
        (525/900*height,74/600*height),
        (450/900*height,120/600*height)
        )
      ))
  )
}
// gh 2:3
#let flag-gh(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(207,9,33),
        rgb(252,210,15),
        rgb(0,107,61)
      ).sharp(3)
    )
    + place(
        horizon+center,
        dy:-5.4%*height,
        text(
          fill: black,
          size:height*.98*2/3,
          [\u{2605}])
    )
  )
}
// gi 1:2
#let flag-gi(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:gradient.linear(
        dir:ttb,
        white,white,rgb(218,0,12)
        
        ).sharp(3)
    )
    +place(
      center+horizon,
      dy:2%*height,
      image("coat of arms/GI.svg", height: 93%*height)
      )
  )
}
// gl 2:3
#let flag-gl(height:.65em) = {
  box(
    rect(
      height:height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        white,rgb(200,16,46)
        ).sharp(2)
    )
    + place(
          horizon,
          dx:2/18*3/2*height,
          circle(
            radius: 4/12*height,
            fill:gradient.linear(
            dir:btt,
            white,rgb(200,16,46)
            ).sharp(2)
          )
        )
  )
}
// gm 2:3
#let flag-gm(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(206,17,38),)*6,
        ..(white,)*1,
        ..(rgb(12,28,140),)*4,
        ..(white,)*1,
        ..(rgb(58,119,40),)*6
      ).sharp(18)
    )
  )
}
// gn 2:3
#let flag-gn(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        rgb(206,17,38),
        rgb(252,209,22),
        rgb(0,148,96),
      ).sharp(3)

    )
  )
}
// gp
#let flag-gp(height:.65em) = {
  flag-fr(height:height)
}
// gq 2:3
#let flag-gq(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(62,154,0),
        white,
        rgb(227,33,24)
      ).sharp(3)
    )
    + place(
      polygon(
        (0*height,0*height),
        (3/8*height,-1/2*height),
        (0*height,-1*height),
        fill:rgb(0,115,206),
      )
    )
    +place(
      horizon+center,
      image("coat of arms/GQ.svg", height:height*.9/3)
    )
  )
}
// gr 2:3
#let flag-gr(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir: ttb,
        ..((rgb("004C98"),white)*4+(rgb("004C98"),))
        ).sharp(9)
    )
    +place(
      top,
      rect(
        height:10/18*height,
        width:10/27*3/2*height,
        fill:rgb("004C98")
      )
      +place(
        top,
        dx:4/27*3/2*height,
        rect(
          height:10/18*height,
          width:2/27*3/2*height,
          fill:white
        )
      )
      +place(
        top,
        dy:4/27*3/2*height,
        rect(
          height:2/18*height,
          width:10/27*3/2*height,
          fill:white
        )
      )
    )
  )
}
// gs
#let flag-gs(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb("012169")
    )
    + place(
      top,
      flag-gb(height:height/2)
    )
    + place(
      horizon+center,
      dx:1/4*height*2,
      image("coat of arms/GS.svg", height: 5/6*height)
    )
  )
}
// gt 5:8
#let flag-gt(height:.65em) = {
  box(
    flag-v3((blue,white,blue), height: height, ratio: 5/8)
    + place(
        dy:-65%,
        dx:38%,
        image("coat of arms/GT.svg", height:height/3)
        )
    /*
    + place(
      line(
        start:(50%*8/5*height,0%),
        end:(50%*8/5*height,-100%*height)
        )
    +place(
      line(
        start:(0%,-50%*height),
        end:(100%*8/5*height,-50%*height)
        )
      )
    )
    */
  )
}
// gu 22:41
#let flag-gu(height:.65em) = {
  box(
    rect(
      height: height,
      width: 41/22*height,
      fill: rgb(198,33,57),
    )
    + place(
      center+horizon,
      rect(
        height: 20/22*height,
        width: 38/40*41/22*height,
        fill: rgb(0,41,123),
      )
    )
    + place(
      center+horizon,
      image("coat of arms/GU.svg", height: 24/40*height)
      )
  )
}
// gw 1:2
#let flag-gw(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(252,209,22),
        rgb(0,158,73)
      ).sharp(2)
    )
    + place(
      top,
      rect(
        height:height,
        width:height*2/3,
        fill:rgb(206,17,38)
        )
    )
    + place(
        horizon+left,
        dx: height/5.5,
        dy: -height/20,
        text(
          fill:black,
          size:height/2,
          [\u{2605}]
        )
    )
    /*
    // construction lines
    + place(
      top,
      line(
        start: (0*2*height,height/2),
        end: (height*2/3,height/2)
      )
    )
    + place(
      top,
      line(
        start: (height*2/6,0*height),
        end: (height*2/6,height)
      )
    )
    */
  )
}
// hk 2:3
#let flag-hk(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb("FF0000")
    )
    +place(
      horizon+center,
      image("coat of arms/HK.svg", height:4/7*height)
    )
  )
}
// hm
#let flag-hm(height:.65em) = {
  flag-au(height:height)
}
// hn 1:2
#let flag-hn(height:.65em) = {
  box(
    flag-h3((rgb(0, 188, 228),rgb(255,255,255),rgb(0, 188, 228)),height: height,ratio: 1/2)
    +place(
      dx:26/72*2*height -2.5%,
      dy:height*-50%+2.5%,
      text(rgb(0, 188, 228), size: 6/36*height,[\u{2605}])
    )
    +place(
      dx:26/72*2*height -2.5%,
      dy:height*-50%-16%,
      text(rgb(0, 188, 228), size: 6/36*height,[\u{2605}])
    )
    +place(
      dx:36/72*2*height -2.5%,
      dy:height*-50%-7.5%,
      text(rgb(0, 188, 228), size: 6/36*height,[\u{2605}])
    )
    +place(
      dx:46/72*2*height -2.5%,
      dy:height*-50%+2.5%,
      text(rgb(0, 188, 228), size: 6/36*height,[\u{2605}])
    )
    +place(
      dx:46/72*2*height -2.5%,
      dy:height*-50%-16%,
      text(rgb(0, 188, 228), size: 6/36*height,[\u{2605}])
    )
    /*
    // construction lines
    +place(
      line(
        start:(26/72*2*height,-2/3*height),
        end:(26/72*2*height,-1/3*height)
        )
      )
    +place(
      line(
        start:(46/72*2*height,-2/3*height),
        end:(46/72*2*height,-1/3*height)
        )
      )
    +place(
      line(
        start:(26/72*2*height,-50%*height),
        end:(46/72*2*height,-50%*height)
        )
      )
    */
  )
}
// gy 3:5
#let flag-gy(height:.65em) = {
  box(
    clip: true,
    rect(
      fill:rgb("00923e"),
      height: height,
      width: 5/3*height
      )
    + place(
        dx:-4/100*5/3*height,
        polygon(
          (0*height,0*height),
          (5/3*height,-1/2*height),
          (0*height,-height),
          fill:rgb("ffcb00"),
          stroke:(paint:white,thickness:height/30),
          )
      )
    + place(
        dx:-3/100*5/3*height,
        polygon(
          (0*height,0*height),
          (5/3*height/2,-1/2*height),
          (0*height,-height),
          fill:rgb("C8102E"),
          stroke:(paint:black,thickness:height/20),
          )
      )
    
  )
}
// hr 
#let flag-hr(height:.65em) = {
  box(flag-h3((rgb(255, 0, 0),rgb(255,255,255),rgb(23, 23, 150)),height: height,ratio: 1/2)+place(
    // coat of arms
    dx:height*80%,
    dy:height*-84.2%,
    image("coat of arms/HR.svg", width:5/24*2*height)
  )
  )
}
// ht 3:5
#let flag-ht(height:.65em) = {
  box(
    flag-h3((rgb("00209f"),rgb("d21034"),none),color-height: (1/2,1/2,0), height: height, ratio:3/5)
    +place(
      dy:-3/4*height,
      dx:5/3/3.2*height,
      rect(fill:white,inset:(top:1pt,rest:0pt),image("coat of arms/HT.svg",height: 1/2*height ))
      )
    /*
    // construction lines
    +place(
      line(
      start:(0*height,0*height), end:(100%*5/3*height,-height)
      )
    +place(
      line(
        start:(0*height,-height), end:(100%*5/3*height,0*height)
      )
      )
    )
    */
  )
}
// hu 1:2
#let flag-hu(height:.65em) = {
  flag-h3((rgb(206, 41, 57),rgb(255,255,255),rgb(71, 112, 80)),height: height,ratio: 1/2)
}
// id 2:3
#let flag-id(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(255,0,0),white
      ).sharp(2)
    )
  )
}
// ie 
#let flag-ie(height:.65em) = {
  flag-v3((rgb(22, 155, 98),rgb(255,255,255),rgb(255,136,62)), height:height, ratio:1/2)
}
// il 8:11
#let flag-il(height:.65em) = {
  box(
    rect(
      height:height,
      width:11/8*height,
      fill:gradient.linear(
        dir:ttb,
        ..(white,)*15,
        ..(rgb(0,56,184),)*25,
        ..(white,)*40,
      ).sharp(80).repeat(2,mirror: true)
    )
    +place(
      center+horizon,
      dy:-6.5/160*height,
      polygon.regular(
        stroke:(
          paint:rgb(0,56,184),
          thickness: 5.5/160*height
          ),
        size:height/3,
      )
    )
    +place(
      center+horizon,
      dy:6.5/160*height,
      rotate(
        180deg,
        polygon.regular(        
          stroke:(
            paint:rgb(0,56,184),
            thickness: 5.5/160*height
            ),
          size:height/3,
        )
      )
    )
  )

}
// im 1:2
#let flag-im(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb(207,20,43)
    )
    +place(
      center+horizon,
      image("coat of arms/IM.svg", height:height/1.5)
    )
  )
}
// in 2:3
#let flag-in(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb("FF671F"),
        white,
        rgb("046a38")
      ).sharp(3)
    )
    +place(
      horizon+center,
      image("coat of arms/IN.svg",
      height:height/3)
    )
  )
}
// io 1:2
#let flag-io(height:.65em) = {
  let pat(ch,cw) = tiling(
            box(fill:white,
            curve(
                fill:rgb("012169"),
                curve.move((0%*cw, 40%*ch)),
                curve.cubic((20%*cw, 40%*ch),(20%*cw,0%*ch),(40%*cw, 0%*ch)),
                curve.cubic((75%*cw, 0%*ch),(75%*cw,40%*ch),(100%*cw, 40%*ch)),
                curve.line((100%*cw,100%*ch)),
                curve.cubic((75%*cw, 100%*ch),(75%*cw,60%*ch),(40%*cw, 60%*ch)),
                curve.cubic((20%*cw, 60%*ch),(20%*cw,100%*ch),(0%*cw, 100%*ch)),
            )
        ))
  box(
    rect(
      height: height,
      width: 2*height,
      fill:pat(height/6,2*height/5.2)
    )
    +place(
      top,
      flag-gb(height: height/2)
      )
    +place(
      horizon+right,
      dx:-1/4*height,
      image("coat of arms/IO.svg", height: 9/10*height)
      )
  )
}
// iq 2:3
#let flag-iq(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(205,17,37),white,black
        ).sharp(3)
    )
    +place(
      horizon+center,
      image("coat of arms/IQ.svg", height: height/4)
      )
  )
}
// ir 4:7
#let flag-ir(height:.65em) = {
  box(
    rect(
      height: height,
      width: 7/4*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(35,159,64),white,rgb(218,0,0)
      ).sharp(3)
      )
    + place(
      horizon+center,
      image("coat of arms/IR.svg",height: .9/2*height)
      )
  )
}
// is 18:25
#let flag-is(height:.65em) = {
  box(
    rect(
      height:height,
      width: 25/18*height,
      fill: rgb("02529C")
    )
    +place(
      top,
      dx:7/25*25/18*height,
      rect(
        height:height,
        width:4/25*25/18*height,
        fill:white
        )
    )
    +place(
      horizon,
      rect(
        height:4/18*height,
        width:25/18*height,
        fill:white
        )
    )
    +place(
      top,
      dx:8/25*25/18*height,
      rect(
        height:height,
        width:2/25*25/18*height,
        fill:rgb("DC1E35")
        )
    )
    +place(
      horizon,
      rect(
        height:2/18*height,
        width:25/18*height,
        fill:rgb("DC1E35")
        )
    )
  )
}
// it 2:3
#let flag-it(height:.65em) = {
  flag-v3((rgb(0,146,70),rgb(241,242,241),rgb(206,43,55)), height:height)
}
// je 3:5
#let flag-je(height:.65em) = {
  box(
    rect(
      height: height,
      width: 5/3*height,
      fill:white
    )
    + place(
      top,
      polygon(
        fill: rgb("c8102e"),
        (0*5/3*height,18/300*height),
        (0*5/3*height,0*height),
        (30/500*5/3*height,0*height),
        (1*5/3*height,282/300*height),
        (1*5/3*height,300/300*height),
        (470/500*5/3*height,300/300*height),
      )
    )
    + place(
      top,
      polygon(
        fill: rgb("c8102e"),
        (0*5/3*height,282/300*height),
        (0*5/3*height,1*height),
        (30/500*5/3*height,1*height),
        (1*5/3*height,18/300*height),
        (1*5/3*height,0/300*height),
        (470/500*5/3*height,0/300*height),
      )
    )
    +place(
      top+center,
      dy:9/300*height,
      image("coat of arms/JE.svg",height: 1/2.8*height)
    )
  )
}
// jm
#let flag-jm(height:.65em) = {
  box(
    rect(height:height, width:height*2, fill:rgb("ffb81c"))
    +place(dy:-height, 
      polygon(
        (0%,90%*height),
        (0%,10%*height),
        (80%*height,50%*height),
        fill:black
        )
      )
    +place(dy:-height, 
      polygon(
        (200%*height,90%*height),
        (200%*height,10%*height),
        (120%*height,50%*height),
        fill:black
        )
      )
    +place(dy:-height, 
      polygon(
        (20%*height,0%*height),
        (90%*height*2,0%*height),
        (100%*height,40%*height),
        fill:rgb(0,119,73)
        )
      )
    
    +place(
      polygon(
        (20%*height,0%*height),
        (90%*height*2,0%*height),
        (100%*height,-40%*height),
        fill:rgb(0,119,73)
        )
      )
    /*
    // construction lines
    +place(dy:-height/2,line(length:2*height))
    +place(dy:-height,line(start:(height,height),end:(height,0*height)))
    +place(
      dy:-height,
      line(
        start:(0*height,height),
        end:(height*2,0*height)
      )
    )
    +place(
      line(
        start:(0*height,-height),
        end:(height*2,0*height)
      )
    )
    */
  )
}
// jo 1:2 (missing the 7-star)
#let flag-jo(height:.65em) = {
  box(
    rect(
      height: height,
      width:height*2,
      fill:gradient.linear(
        dir:ttb,
        black,
        white,
        rgb(0,122,61)
      ).sharp(3)
    )
    + place(
        top,
        polygon(
          (0*height,0*height),
          (1*height,1/2*height),
          (0*height,1*height),
          fill:rgb(206,17,38)
        )
      )
    + place(
        horizon+left,
        dx:(.1)*height,
        text(fill:white,[\u{1F7CE}], size:1/3*height)
      )
  )
}
// jp 2:3
#let flag-jp(height:.65em) = {
  box(
    rect(height:height, width:3/2*height,fill:white)
    +place(
      dy:-(2/3+3/20)*height,
      dx:(3/5/3/2+3.85/20)*3/2*height,
      circle(fill:rgb(188,0,45), radius:3/10*height)
    )
    /*
    // construction lines
    + place(line(start:(0*height,0*height),end:(3/2*height,-height)))
    + place(line(start:(3/2*height,0*height),end:(0*height,-height)))
    + place(line(start:(3/4*height,0*height),end:(3/4*height,-height)))
    */
  )
}
// ke 2:3
#let flag-ke(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(black,)*6,
        ..(white,)*1,
        ..(rgb("#bb0000"),)*6,
        ..(white,)*1,
        ..(rgb("#006600"),)*6,
      ).sharp(20)
    )
    + place(
        horizon+center,
        dy:-2/80*height,
        image("coat of arms/KE.svg", height: height*67%)
      )
  )
}
// kg 2:3
#let flag-kg(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:rgb(255,0,0)
    )
    +place(
      horizon+center,
      image("coat of arms/KG.svg", height: height/1.5)
    )
  )
}
// kh
#let flag-kh(height:.65em) = {
  box(
    rect(
      height: height,
      width:25/16*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(3,46,161),
        rgb(224,0,37),
        rgb(224,0,37),
        rgb(3,46,161),
        ).sharp(4)
      )
      + place(
        horizon+center,
        image("coat of arms/KH.svg", height: height*.8/2)
      )
  )
}
// ki 1:2
#let flag-ki(height:.65em) = {
  box(
    rect(
      height:height,
      width: 2*height,
      fill:gradient.linear(
            dir:ttb,
            ..(rgb(200,16,16),rgb(200,16,16),rgb(24,48,112))
        ).sharp(3)
    )
    +place(
        center+top,
        dy:22/300*height,
        image("coat of arms/KI.svg", height: height/1.7)
      )
    +place(
      top,
      curve(
        fill:white,
        curve.move((0/600*2*height, 150/300*height)),
        curve.cubic((30/600*2*height,  150/300*height),(30/600*2*height,   162/300*height),(60/600*2*height,   162/300*height)),
        curve.cubic((90/600*2*height,  162/300*height),(90/600*2*height,   150/300*height),(120/600*2*height,  150/300*height)),
        curve.cubic((150/600*2*height, 150/300*height),(150/600*2*height,  162/300*height),(180/600*2*height,  162/300*height)),
        curve.cubic((210/600*2*height, 162/300*height),(210/600*2*height,  150/300*height),(240/600*2*height,  150/300*height)),
        curve.cubic((270/600*2*height, 150/300*height),(270/600*2*height,  162/300*height),(300/600*2*height,  162/300*height)),
        curve.cubic((330/600*2*height, 162/300*height),(330/600*2*height,  150/300*height),(360/600*2*height,  150/300*height)),
        curve.cubic((390/600*2*height, 150/300*height),(390/600*2*height,  162/300*height),(420/600*2*height,  162/300*height)),
        curve.cubic((450/600*2*height, 162/300*height),(450/600*2*height,  150/300*height),(480/600*2*height,  150/300*height)),
        curve.cubic((510/600*2*height, 150/300*height),(510/600*2*height,  162/300*height),(540/600*2*height,  162/300*height)),
        curve.cubic((570/600*2*height, 162/300*height),(570/600*2*height,  150/300*height),(600/600*2*height,  150/300*height)),
        curve.line((600/600*2*height,  175/300*height)),
        curve.cubic((570/600*2*height, 175/300*height),(570/600*2*height,  187/300*height),(540/600*2*height,  187/300*height)),
        curve.cubic((510/600*2*height, 187/300*height),(510/600*2*height,  175/300*height),(480/600*2*height,  175/300*height)),
        curve.cubic((450/600*2*height, 175/300*height),(450/600*2*height,  187/300*height),(420/600*2*height,  187/300*height)),
        curve.cubic((390/600*2*height, 187/300*height),(390/600*2*height,  175/300*height),(360/600*2*height,  175/300*height)),
        curve.cubic((330/600*2*height, 175/300*height),(330/600*2*height,  187/300*height),(300/600*2*height,  187/300*height)),
        curve.cubic((270/600*2*height, 187/300*height),(270/600*2*height,  175/300*height),(240/600*2*height,  175/300*height)),
        curve.cubic((210/600*2*height, 175/300*height),(210/600*2*height,  187/300*height),(180/600*2*height,  187/300*height)),
        curve.cubic((150/600*2*height, 187/300*height),(150/600*2*height,  175/300*height),(120/600*2*height,  175/300*height)),
        curve.cubic((90/600*2*height,  175/300*height),(90/600*2*height,   187/300*height),(60/600*2*height,   187/300*height)),
        curve.cubic((30/600*2*height,  187/300*height),(30/600*2*height,   175/300*height),(000/600*2*height,  175/300*height)),
        ), 
      )
      + place(
        top,
        curve(
                fill: rgb(24,48,112),
                curve.move((0/600*2*height, 175/300*height)),
                curve.cubic((30/600*2*height,  175/300*height),(30/600*2*height,   187/300*height),(60/600*2*height,   187/300*height)),
                curve.cubic((90/600*2*height,  187/300*height),(90/600*2*height,   175/300*height),(120/600*2*height,  175/300*height)),
                curve.cubic((150/600*2*height, 175/300*height),(150/600*2*height,  187/300*height),(180/600*2*height,  187/300*height)),
                curve.cubic((210/600*2*height, 187/300*height),(210/600*2*height,  175/300*height),(240/600*2*height,  175/300*height)),
                curve.cubic((270/600*2*height, 175/300*height),(270/600*2*height,  187/300*height),(300/600*2*height,  187/300*height)),
                curve.cubic((330/600*2*height, 187/300*height),(330/600*2*height,  175/300*height),(360/600*2*height,  175/300*height)),
                curve.cubic((390/600*2*height, 175/300*height),(390/600*2*height,  187/300*height),(420/600*2*height,  187/300*height)),
                curve.cubic((450/600*2*height, 187/300*height),(450/600*2*height,  175/300*height),(480/600*2*height,  175/300*height)),
                curve.cubic((510/600*2*height, 175/300*height),(510/600*2*height,  187/300*height),(540/600*2*height,  187/300*height)),
                curve.cubic((570/600*2*height, 187/300*height),(570/600*2*height,  175/300*height),(600/600*2*height,  175/300*height)),
                curve.line((600/600*2*height,  200/300*height)),
                curve.cubic((570/600*2*height, 200/300*height),(570/600*2*height,  212/300*height),(540/600*2*height,  212/300*height)),
                curve.cubic((510/600*2*height, 212/300*height),(510/600*2*height,  200/300*height),(480/600*2*height,  200/300*height)),
                curve.cubic((450/600*2*height, 200/300*height),(450/600*2*height,  212/300*height),(420/600*2*height,  212/300*height)),
                curve.cubic((390/600*2*height, 212/300*height),(390/600*2*height,  200/300*height),(360/600*2*height,  200/300*height)),
                curve.cubic((330/600*2*height, 200/300*height),(330/600*2*height,  212/300*height),(300/600*2*height,  212/300*height)),
                curve.cubic((270/600*2*height, 212/300*height),(270/600*2*height,  200/300*height),(240/600*2*height,  200/300*height)),
                curve.cubic((210/600*2*height, 200/300*height),(210/600*2*height,  212/300*height),(180/600*2*height,  212/300*height)),
                curve.cubic((150/600*2*height, 212/300*height),(150/600*2*height,  200/300*height),(120/600*2*height,  200/300*height)),
                curve.cubic((90/600*2*height,  200/300*height),(90/600*2*height,   212/300*height),(60/600*2*height,   212/300*height)),
                curve.cubic((30/600*2*height,  212/300*height),(30/600*2*height,   200/300*height),(000/600*2*height,  200/300*height)),
            )
        )
    + place(
        top,
        curve(
                fill: white,
                curve.move((0/600*2*height, 200/300*height)),
                curve.cubic((30/600*2*height,  200/300*height),(30/600*2*height,   212/300*height),(60/600*2*height,   212/300*height)),
                curve.cubic((90/600*2*height,  212/300*height),(90/600*2*height,   200/300*height),(120/600*2*height,  200/300*height)),
                curve.cubic((150/600*2*height, 200/300*height),(150/600*2*height,  212/300*height),(180/600*2*height,  212/300*height)),
                curve.cubic((210/600*2*height, 212/300*height),(210/600*2*height,  200/300*height),(240/600*2*height,  200/300*height)),
                curve.cubic((270/600*2*height, 200/300*height),(270/600*2*height,  212/300*height),(300/600*2*height,  212/300*height)),
                curve.cubic((330/600*2*height, 212/300*height),(330/600*2*height,  200/300*height),(360/600*2*height,  200/300*height)),
                curve.cubic((390/600*2*height, 200/300*height),(390/600*2*height,  212/300*height),(420/600*2*height,  212/300*height)),
                curve.cubic((450/600*2*height, 212/300*height),(450/600*2*height,  200/300*height),(480/600*2*height,  200/300*height)),
                curve.cubic((510/600*2*height, 200/300*height),(510/600*2*height,  212/300*height),(540/600*2*height,  212/300*height)),
                curve.cubic((570/600*2*height, 212/300*height),(570/600*2*height,  200/300*height),(600/600*2*height,  200/300*height)),
                curve.line((600/600*2*height,  225/300*height)),
                curve.cubic((570/600*2*height, 225/300*height),(570/600*2*height,  237/300*height),(540/600*2*height,  237/300*height)),
                curve.cubic((510/600*2*height, 237/300*height),(510/600*2*height,  225/300*height),(480/600*2*height,  225/300*height)),
                curve.cubic((450/600*2*height, 225/300*height),(450/600*2*height,  237/300*height),(420/600*2*height,  237/300*height)),
                curve.cubic((390/600*2*height, 237/300*height),(390/600*2*height,  225/300*height),(360/600*2*height,  225/300*height)),
                curve.cubic((330/600*2*height, 225/300*height),(330/600*2*height,  237/300*height),(300/600*2*height,  237/300*height)),
                curve.cubic((270/600*2*height, 237/300*height),(270/600*2*height,  225/300*height),(240/600*2*height,  225/300*height)),
                curve.cubic((210/600*2*height, 225/300*height),(210/600*2*height,  237/300*height),(180/600*2*height,  237/300*height)),
                curve.cubic((150/600*2*height, 237/300*height),(150/600*2*height,  225/300*height),(120/600*2*height,  225/300*height)),
                curve.cubic((90/600*2*height,  225/300*height),(90/600*2*height,   237/300*height),(60/600*2*height,   237/300*height)),
                curve.cubic((30/600*2*height,  237/300*height),(30/600*2*height,   225/300*height),(000/600*2*height,  225/300*height)),
            )
        )
    + place(
        top,
        curve(
                fill: white,
                curve.move((0/600*2*height, 250/300*height)),
                curve.cubic((30/600*2*height,  250/300*height),(30/600*2*height,   262/300*height),(60/600*2*height,   262/300*height)),
                curve.cubic((90/600*2*height,  262/300*height),(90/600*2*height,   250/300*height),(120/600*2*height,  250/300*height)),
                curve.cubic((150/600*2*height, 250/300*height),(150/600*2*height,  262/300*height),(180/600*2*height,  262/300*height)),
                curve.cubic((210/600*2*height, 262/300*height),(210/600*2*height,  250/300*height),(240/600*2*height,  250/300*height)),
                curve.cubic((270/600*2*height, 250/300*height),(270/600*2*height,  262/300*height),(300/600*2*height,  262/300*height)),
                curve.cubic((330/600*2*height, 262/300*height),(330/600*2*height,  250/300*height),(360/600*2*height,  250/300*height)),
                curve.cubic((390/600*2*height, 250/300*height),(390/600*2*height,  262/300*height),(420/600*2*height,  262/300*height)),
                curve.cubic((450/600*2*height, 262/300*height),(450/600*2*height,  250/300*height),(480/600*2*height,  250/300*height)),
                curve.cubic((510/600*2*height, 250/300*height),(510/600*2*height,  262/300*height),(540/600*2*height,  262/300*height)),
                curve.cubic((570/600*2*height, 262/300*height),(570/600*2*height,  250/300*height),(600/600*2*height,  250/300*height)),
                curve.line((600/600*2*height,  275/300*height)),
                curve.cubic((570/600*2*height, 275/300*height),(570/600*2*height,  287/300*height),(540/600*2*height,  287/300*height)),
                curve.cubic((510/600*2*height, 287/300*height),(510/600*2*height,  275/300*height),(480/600*2*height,  275/300*height)),
                curve.cubic((450/600*2*height, 275/300*height),(450/600*2*height,  287/300*height),(420/600*2*height,  287/300*height)),
                curve.cubic((390/600*2*height, 287/300*height),(390/600*2*height,  275/300*height),(360/600*2*height,  275/300*height)),
                curve.cubic((330/600*2*height, 275/300*height),(330/600*2*height,  287/300*height),(300/600*2*height,  287/300*height)),
                curve.cubic((270/600*2*height, 287/300*height),(270/600*2*height,  275/300*height),(240/600*2*height,  275/300*height)),
                curve.cubic((210/600*2*height, 275/300*height),(210/600*2*height,  287/300*height),(180/600*2*height,  287/300*height)),
                curve.cubic((150/600*2*height, 287/300*height),(150/600*2*height,  275/300*height),(120/600*2*height,  275/300*height)),
                curve.cubic((90/600*2*height,  275/300*height),(90/600*2*height,   287/300*height),(60/600*2*height,   287/300*height)),
                curve.cubic((30/600*2*height,  287/300*height),(30/600*2*height,   275/300*height),(000/600*2*height,  275/300*height)),
            )
        )
  )
}
// km 3:5
#let flag-km(height:.65em) = {
  box(
    rect(
      height: height,
      width: 5/3*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(255,209,0),white,rgb(239,51,64),rgb(0,61,165)
      ).sharp(4)
    )
    + place(
        top,
        polygon(
          (0*height,0*height),
          (1/2*5/3*height,1/2*height),
          (0*height,1*height),
          fill: rgb(0,150,57)
        )
    )
    + place(
        horizon,
        dx:3%*5/3*height,
        circle(
          fill:
          gradient.linear(
            white,
            white,
            white.transparentize(100%),
          ).sharp(3),
          radius: height/4
        )
    )
    + place(
        horizon,
        dx:9%*5/3*height,
        circle(
          fill:
          gradient.linear(
            rgb(0,150,57),
            rgb(0,150,57).transparentize(100%),
            ).sharp(2),
          radius: height/4
        )
    )
    + place(
        horizon,
        dx: 18%*5/3*height,
        stack(
          dir:ttb,
          ..(
            text(
              fill:white,
              size:height/6,
              [\u{2605}]),
            )*4,
          
        )
    )
  )
}
// kn 2:3
#let flag-kn(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: black
    )
    + place(
        top,
        polygon(
          (0*3/2*height,0*height),
          (0*3/2*height,3/4*height),
          (3/4*3/2*height,0*height),
          fill:yellow
        )
      )
    + place(
        top,
        polygon(
          (0*3/2*height,0*height),
          (0*3/2*height,(3/4-5/60)*height),
          ((3/4-10/120)*3/2*height,0*height),
          fill:rgb(0,119,73)
        )
    )
    + place(
        top,
        polygon(
          (1*3/2*height,1/4*height),
          (1*3/2*height,1*height),
          (1/4*3/2*height,1*height),
          fill:yellow
        )
      )
    + place(
        top,
        polygon(
          (1*3/2*height,(1/4+5/60)*height),
          (1*3/2*height,1*height),
          ((1/4+10/120)*3/2*height,1*height),
          fill:red
        )
    )
    + place(
        horizon+center,
        dx:25/120*3/2*height,
        dy:-4/60*height,
        rotate(
          18deg,
          polygram(
            (5,2),
            height/6,
            white
            )
          )
    )
    + place(
        horizon+center,
        dx:-15/120*3/2*height,
        dy:16/60*height,
        rotate(
          18deg,
          polygram(
            (5,2),
            height/6,
            white
            )
          )
    )
  )
}
// kp
#let flag-kp(height:.65em) = {
  box(
    rect(height:height,width:height*2,fill:
    gradient.linear(..(rgb("0047A0"),)*6,white,..(rgb("CD2E3A"),)*22,white,..(rgb("0047A0"),)*6,angle:90deg).sharp(36))
    + place(
      horizon,
      dx:(24-8)/72*height*2,
      circle(fill:white,radius:8/36*height)
      )
    + place(
      horizon,
      dy:-2.9/36*height,
      dx:15.5/72*height*2,
      text(fill:rgb("CD2E3A"),size:37/48*height,[\u{2605}])
      )
  )
}
// kr 2:3
#let flag-kr(height:.65em) = {
  let width = 3/2*height
  box(
    rect(fill:white, height:height,width:width)
    +place(
      horizon+center,
      circle(
        fill:(gradient.linear(rgb("0047A0"),rgb("CD2E3A"), angle:-55deg).sharp(2)),
        radius: 1/4*height
      )
    )
    +place(
      horizon+center,
      dx:-5/48*height,
      dy:-3.14/48*height,
      circle(
        radius:6/48*height, 
        fill:rgb("CD2E3A")
        )
    )
    +place(
      horizon+center,
      dx:5/48*height,
      dy:3.14/48*height,
      circle(
        radius:6/48*height, 
        fill:rgb("0047A0")
        )
    )
    // top left
    +place(
      horizon+center,
      dx:-calc.cos(-57deg)*(36/72)*width,
      dy:calc.sin(-57deg)*(16/48)*height,
      rotate(-57deg,
        rect(
          width: 12/72*width,
          height: 8/48*height,
          fill:white,
          place(
            horizon+center,
            rect(width:12/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dy:-3/48*height,
            rect(width:12/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dy:3/48*height,
            rect(width:12/72*width,height:2/48*height,fill:black))
        )
      )
    )
    // top right
    +place(
      horizon+center,
      dx:calc.cos(-57deg)*(36/72)*width,
      dy:calc.sin(-57deg)*(16/48)*height,
      rotate(57deg,
        rect(
          width: 12/72*width,
          height: 8/48*height,
          fill:white,
          place(
            horizon+center,
            rect(width:12/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:-3.25/72*width,
            dy:-3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:-3.25/72*width,
            dy:3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:3.25/72*width,
            dy:-3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:3.25/72*width,
            dy:3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
        )
      )
    )
    // bottom right
    +place(
      horizon+center,
      dx:-calc.cos(180deg-57deg)*(36/72)*width,
      dy:calc.sin(180deg-57deg)*(16/48)*height,
      rotate(-57deg,
        rect(
          width: 12/72*width,
          height: 8/48*height,
          fill:white,
          place(
            horizon+center,
            dx:-3.25/72*width,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:-3.25/72*width,
            dy:-3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:-3.25/72*width,
            dy:3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            horizon+center,
            dx:3.25/72*width,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:3.25/72*width,
            dy:-3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dx:3.25/72*width,
            dy:3/48*height,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
        )
      )
    )
    // bottom left
    +place(
      horizon+center,
      dx:-calc.cos(57deg)*(36/72)*width,
      dy:calc.sin(57deg)*(16/48)*height,
      rotate(57deg,
        rect(
          width: 12/72*width,
          height: 8/48*height,
          fill:white,
          place(
            horizon+center,
            dx:-3.25/72*width,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            horizon+center,
            dx:3.2/72*width,
            rect(width:5.5/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dy:-3/48*height,
            rect(width:12/72*width,height:2/48*height,fill:black))
          + place(
            center,
            dy:3/48*height,
            rect(width:12/72*width,height:2/48*height,fill:black))
        )
      )
    )
    //construction lines
    /*
    +place(
      horizon+center,
      circle(radius: (24+12)/48/2*height)
    )
    +place(
      line(
        start:(0*width,0*height),
        end:(width,-height)
        )
      )
    */
    /*
    +place(
      line(
        start:(0*width,-height),
        end:(width,0*height)
      )
    )
    +place(
      line(
        start:(0*width,-1/2*height),
        end:(width,-1/2*height)
      )
    )
    
    +place(
      line(
        start:(1/2*width,-1*height),
        end:(1/2*width,0*height)
      )
    )
    */
  )
}
// kw 1:2
#let flag-kw(height:.65em) = {
   box(
    rect(
      height: height,
      width:height*2,
      fill:gradient.linear(
        dir:ttb,
        rgb(0,122,61),
        white,
        rgb(205,17,37),
      ).sharp(3)
    )
    + place(
        top,
        polygon(
          (0*2*height,0*height),
          (3/12*2*height,1/3*height),
          (3/12*2*height,2/3*height),
          (0*2*height,1*height),
          fill:black
        )
      )

   )
}
// ky 1:2
#let flag-ky(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb("012169"),
    )
    +place(
      top,
      flag-gb(height:height/2)
    )
    +place(
      horizon+right,
      dx:-100/500*height,
      image("coat of arms/KY.svg",height: height/1.5))
  )
}
// kz 1:2
#let flag-kz(height:.65em) = {
  box(
    rect(
      height:height,
      width:height*2,
      fill:rgb(0,171,194)
    )
    +place(
      horizon+center,
      image("coat of arms/KZ.svg",height: height)
    )
  )
}
// la 2:3
#let flag-la(height:.65cm) = {
  box(
    rect(
      height:height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(206,17,38),rgb(0,40,104)
      ).sharp(2).repeat(2,mirror: true)
    )
    + place(
      horizon+center,
      circle(
        fill:white,
        radius: 4/5*1/2*height/2
        )
      )
  )
}
// lb 2:3
#let flag-lb(height:.65cm) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(216,28,34),white,
      ).sharp(2).repeat(2,mirror: true)
    )
    + place(
      horizon+center,
      image("coat of arms/LB.svg", height:height/2)
    )
  )
}
// lc 1:2
#let flag-lc(height:.65cm) = {
  box(
    rect(
      height: height,
      width:2*height,
      fill:rgb(99,207,254)
    )
    +place(
      top,
      polygon(
        (1*height,3.16/36*height),
        (24/72*height*2,(36-3.16)/36*height),
        (48/72*height*2,(36-3.16)/36*height),
        fill:white,
      )
      )
    +place(
      top,
      polygon(
        (1*height,7.16/36*height),
        (26/72*height*2,(36-3.16)/36*height),
        (46/72*height*2,(36-3.16)/36*height),
        fill:black,
      )
      )
    +place(
      top,
      polygon(
        (1*height,18/36*height),
        (24/72*height*2,(36-3.16)/36*height),
        (48/72*height*2,(36-3.16)/36*height),
        fill:yellow,
      )
      )
  )
}
// li 3:5
#let flag-li(height:.65em) = {
  box(
    flag-h3((rgb(0,39,128),rgb(207,9,33),none),height: height,ratio:3/5,color-height: (1/2,1/2,0))+place(
      // coat of arms
      dx:height*40%,
      dy:height*-92%,
      image("coat of arms/LI.png", width:5/3/4*height)
    )
  )
}
// lk 1:2
#let flag-lk(height:.65em) = {
  box(
    rect(
      height:height,
      width:2*height,
      fill:rgb(247,183,24),
    )
    + place(
      horizon,
      dx: 1/10*height,
      rect(
        height: 8/10*height,
        width: 1/2*height,
        fill:gradient.linear(rgb(0,95,86),rgb(223,117,0),).sharp(2)
      )
    )
    + place(
      horizon,
      dx: 7/10*height,
      rect(
        height: 8/10*height,
        width: 12/10*height,
        fill:rgb(148,30,50)
      )
      + place(horizon+center,
      image("coat of arms/LK.svg",height:7.5/10*height)
      )
    )
  )
}
// lr 10:19
#let flag-lr(height:.65em) = {
  box(
    rect(
      height: height,
      width: 19/10*height,
      fill: gradient.linear(
        dir:ttb,
        ..(..(rgb(191,10,48),)*1,
        ..(white,)*1,)*5,
        rgb(191,10,48)
      ).sharp(11)
    )
    + place(
      top,
      rect(
        width: 50/209*19/10*height,
        height: 50/111*height,
        fill: rgb(0,40,104)
        )
        + place(
          horizon+center,
          dy:-7/111*height,
          text(
            fill:white,
            size:height/2,
            [\u{2605}]
            )
        )
      )
  )
}
// ls 2:3
#let flag-ls(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(0,20,137),)*3,
        ..(white,)*4,
        ..(rgb(0,154,68),)*3
      ).sharp(10)
    )
    + place(
      center+horizon,
      image("coat of arms/LS.svg", height:92/250*height)
    )
  )

}
// lt 7:11
#let flag-lt(height:.65em) = {
  flag-h3((rgb("fdb913"),rgb("006a44"),rgb("c1272d")),height: height,ratio:7/11)
}
// lu 3:5
#let flag-lu(height:.65em) = {
  flag-h3((rgb(199,63,74),white,rgb(0,137,182)),height: height)
}
// lv 7:11
#let flag-lv(height:.65em) = {
  flag-h3((rgb(158, 27, 52),rgb("FFFFFF"),rgb(158, 27, 52)),height: height,ratio:1/2,color-height:(2/5,1/5,2/5))
}
// ly 1:2?
#let flag-ly(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(231,0,19),)*1,
        ..(black,)*2,
        ..(rgb(35,158,70),)*1,
      ).sharp(4)
    )
    + place(
      horizon+center,
      circle(
        radius:3/24*height,
        fill:white,
        )
    )
    + place(
      horizon+center,
      dx:1/24*height,
      circle(
        radius:2.8/24*height,
        fill: black
      )
    )
    + place(
      horizon+center,
      dy:-.3/24*height,
      dx:5/48*3/2*height,
      rotate(54deg,
        text(
          fill:white,
          size:height/4,
          [\u{2605}]
        )
      )
    )
    /*
    // construction line
    + place(
      horizon+center,
      line(stroke:white)
      )
    */
  )
}
// ma 2:3
#let flag-ma(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb(193,39,45)
    )
    + place(horizon+center,
    text(
      size: height*2/3,
      fill:rgb(0,98,51),
      [\u{26E4}]
      )
    )
  )
}
// mc 
#let flag-mc(height:.65em) = {
  flag-h3((rgb("CF142B"),rgb("FFFFFF"),none), color-height: (1/2,1/2,0), height:height)
}
// md 1:2
#let flag-md(height:.65em)={
  box(
    flag-v3((rgb("0046ae"),rgb("ffd200"),rgb("cc092f")),height: height, ratio:1/2, color-width: (1/3,1/3,1/3))
    +place(dy:-76.8%*height, dx:(1-2/10)*height,image("coat of arms/MD.svg", width:2/5*height))
    //+place(dy:-50%*height,line(length:height*2))
    //+place(dy:-50%*height, dx:height/2,rotate(90deg,line(length:height)))
  )
}
// me 1:2
#let flag-me(height:.65em) = {
  box(
    rect(height: height, width: 2*height, fill:rgb("fdb913"))
    + place(
      dx:1/20*height,
      dy:-(1-1/20)*height,
      rect(width: 19/20*height*2 ,height:18/20*height,fill:rgb("d82126"))
      )
    + place(
      dx:(1-7/24)*height,
      dy:-(1-(2/3/4))*height,
      image("coat of arms/MI.svg", height: 2/3*height)
      )
    /*
    // supporting line
    + place(
      dx:height,
      dy:-height,
      line(start:(0%*height,0%*height),end:(0%*height,100%*height), stroke:(dash:"dotted"))
    )
    */
  )
}
// mf
#let flag-mf(height:.65em) = {
  flag-fr(height: height,)  
}
// mg 2:3
#let flag-mg(height:.65em) = {
  box(
    rect(
      height:height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(252,61,50),rgb(0,126,58)
      ).sharp(2)
    )
    + place(top,
      rect(
        height:height,
        width: 1/3*3/2*height,
        fill:white,
      )
    )
  )
}
// mh 10:19
#let flag-mh(height:.65em)={
  box(
    rect(
      height:height,
      width: 19/10*height,
      fill:rgb(0,56,147)
    )
    + place(
        top,
        polygon(
          (100%*height*19/10,4/250*height),
          (100%*height*19/10,(49+4)/250*height),
          (0%*height*19/10,(250-8)/250*height),
          (0%*height*19/10,(250-12)/250*height),
          fill:rgb(221,117,0)
        )
      )
    + place(
        top,
        polygon(
          (100%*height*19/10,(49+4)/250*height),
          (100%*height*19/10,(49+49+4)/250*height),
          (0%*height*19/10,(250-4)/250*height),
          (0%*height*19/10,(250-8)/250*height),
          fill:white
        )
      )

    + place(
        top,
        dx:91.27/475*19/10*height,
        dy:91.27/250*height,
        polygram(
          (24,11),
          155/250/2*height,
          gradient
            .conic(
                angle:8deg,
                center:(0%,0%),
              ..(white,rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),white,rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),white,rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),white,rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147),rgb(0,56,147)),          
              
              )
            .sharp(24)
          )
      )
      
    + place(
        top,
        dx:91.27/475*19/10*height,
        dy:91.27/250*height,
        polygram((24,11),111/250/2*height,white)
      )
  )
}
// mk 1:2
#let flag-mk(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*2,
      fill: rgb("d82126"),
      inset:0pt,
      align(left,
        none
        // the polygon top left
        + place(
          polygon(
            (0%,0%),
            (.3*height,0%),
            ((1+(2/7)/2-(2/7)/8)*height,1/2*(1+2/7/2-2/7/8)*height),
            
            fill:rgb("f8e92e")
          )
        )
        // the polygon top right
        + place(
          polygon(
            (100%,0%),
            ((2-.3)*height,0%),
            ((1-(2/7)/2+(2/7)/8)*height,1/2*(1+2/7/2-2/7/8)*height),
            fill:rgb("f8e92e")
          )
        )
        // the polygon bottom right
        + place(
          polygon(
            (100%,100%),
            ((2-.3)*height,100%),
            ((1-(2/7)/2+(2/7)/8)*height,1/2*(1-2/7/2+2/7/8)*height),
            //(height,height/2),
            fill:rgb("f8e92e")
          )
        )
        // the polygon bottom left
        + place(
          polygon(
            (0%,100%),
            (.3*height,100%),
            ((1+(2/7)/2-(2/7)/8)*height,1/2*(1-2/7/2+2/7/8)*height),
            fill:rgb("f8e92e")
          )
        )
        // the polygon left
        + place(
          polygon(
            (0%,.4*height),
            (0%,.6*height),
            (height,.5*height),
            fill:rgb("f8e92e")
            )
          )
        // the polygon right
        + place(
          polygon(
            (100%,.4*height),
            (100%,.6*height),
            (height,.5*height),
            fill:rgb("f8e92e")
            )
          )
        // the polygon central top
        + place(
          polygon(
            (.45*height*2,0%),
            (.55*height*2,0%),
            (height,(1/2-(2/14)+2/14/4)*height),
            fill:rgb("f8e92e")
            )
          )
        // the polygon central bottom
        + place(
          polygon(
            (.45*height*2,100%),
            (.55*height*2,100%),
            (height,(1/2+(2/14)-2/14/4)*height),
            fill:rgb("f8e92e")
            )
          )
        // the central yellow red (that will hide points of polygones)
        + place(
          dx: height * (1 - (2/7 + ((2/7)/8)*2)/2),
          dy: height * (1/2 - (2/7 + ((2/7)/8)*2)/2),
          circle(
            fill:rgb("d82126"), 
            radius: (2/7 + ((2/7)/8)*2)/2*height,
            )
          )
        // the central yellow circle
        + place(
          dx: height * (1 - (2/7)/2),
          dy: height * (1/2 - (2/7)/2),
          circle(fill:rgb("f8e92e"),radius: (2/7)/2*height)
          )
        /*
        // supporting lines (normally hidden)
        // almost diagonal
        + place(
            line(
              start:(.075*height*2,0%),
              end:((1-.075)*height*2,100%),
              stroke:(dash: "dotted")
            )
          )
        // almost opposite diagonal
        + place(
            line(
              start:((1-.075)*height*2,0%),
              end:(.075*height*2,100%),
              stroke:(dash: "dotted")
            )
          )
        // the central circle that touches top and bottom polygones
        + place(
          dx: height * (1 - (2/7 - ((2/7)/8)*2)/2),
          dy: height * (1/2 - (2/7 - ((2/7)/8)*2)/2),
          circle(
            fill:none, 
            radius: (2/7 - ((2/7)/8)*2)/2*height,
            stroke:(dash: "dotted")
            )
          )
        // the central yellow circle 
        + place(
          dx: height * (1 - (2/7)/2),
          dy: height * (1/2 - (2/7)/2),
          circle(
            fill:none, 
            radius: (2/7)/2*height,
            stroke:(dash: "dotted")
            )
          )
        // the central red circle (that will hide points of polygones)
        + place(
          dx: height * (1 - (2/7 + ((2/7)/8)*2)/2),
          dy: height * (1/2 - (2/7 + ((2/7)/8)*2)/2),
          circle(
            fill:none, 
            radius: (2/7 + ((2/7)/8)*2)/2*height,
            stroke:(dash: "dotted")
            )
          )
        // middle h line
        +place(
          line(
            start:(50%,0%),
            end:(50%,100%),
            stroke:(dash: "dotted")
            )
        )
        // middle v line
        +place(
          line(
            start:(0%,50%),
            end:(100%,50%),
            stroke:(dash: "dotted")
            )
        )
      */
      )
    )
  )
}
// ml 2:3
#let flag-ml(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        rgb(20,181,58),
        rgb(252,209,22),
        rgb(206,17,38)
      ).sharp(3)
    )
  )
}
// mm 2:3
#let flag-mm(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(254,203,0),
        rgb(52,178,51),
        rgb(234,40,57),
      ).sharp(3),
    )
    +place(
      center+horizon,
      dy:-1/10*height,
      text(fill:white,size:1.3*height,[\u{2605}]))
  )
}
// mn 1:2
#let flag-mn(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*2,
      fill:gradient.linear(cmyk(10%,100%,90%,0%),cmyk(100%,60%,00%,0%),cmyk(10%,100%,90%,0%)).sharp(3)
    )
    + place(horizon,
      dx:4%*height*2,
      dy:7%*height,
      text(
        fill:cmyk(0%,15%,100%,0%),
        size:2/3*height,
        // soyombo in unicode
        [\u{11A9E}]
      )
    )
  )
}
// mo 2:3
#let flag-mo(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: rgb(15,117,98)
    )
    +place(
      horizon+center,
      image("coat of arms/MO.svg", height:3/5*height)
      )
    +place(
      horizon+center,
      dx:2.5%*3/2*height,
      dy:-20%*3/2*height,
      rotate(-18deg,polygram((5,2),height/16,yellow))
    )
    +place(
      horizon+center,
      dx:12%*3/2*height,
      dy:-16%*3/2*height,
      rotate(18deg,polygram((5,2),height/20,yellow))
    )
    +place(
      horizon+center,
      dx:-10%*3/2*height,
      dy:-16%*3/2*height,
      rotate(18deg,polygram((5,2),height/20,yellow))
    )
    +place(
      horizon+center,
      dx:18%*3/2*height,
      dy:-9%*3/2*height,
      rotate(40deg,polygram((5,2),height/20,yellow))
    )
    +place(
      horizon+center,
      dx:-17%*3/2*height,
      dy:-10%*3/2*height,
      rotate(-5deg,polygram((5,2),height/20,yellow))
    )
  )
}
// mp 1:2
#let flag-mp(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(0,51,161)
    )
    + place(
        horizon+center,
        image("coat of arms/MP.svg", height:5/6*height)
    )
    + place(
        horizon+center,
        dx:55/550*height,
        dy:80/550*height,
        rotate(-18deg,polygram((5,2),height/5,black))
      )
    + place(
        horizon+center,
        dx:44/550*height,
        dy:75/550*height,
        rotate(-18deg,polygram((5,2),height/6,white))
      )
  )
}
// mq
#let flag-mq(height:.65em) = {
  box(
    flag-fr(height: height)
  )
}
// mr 2:3
#let flag-mr(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(208,28,31),)*2,
        ..(rgb(0,169,92),)*3
      ).sharp(5).repeat(2, mirror: true)
    )
    + place(
        horizon+center,
        dy:-1.5/10*height,
        circle(
          radius:1/4*3/2*height,
          fill:gradient.linear(
          dir:btt,
          ..(rgb(255,215,0),)*11,
          ..(white.transparentize(100%),)*9,
          ).sharp(20),
        )
      )
    + place(
        horizon+center,
        dy:-2.5/10*height,
        circle(
          radius:1/4*3/2*height,
          fill:gradient.linear(
          dir:btt,
          ..(rgb(0,169,92),),
          ..(white.transparentize(100%),)
          ).sharp(2),
        )
      )
    + place(
      horizon+center,
      dy:-1.5/10*height,
      text(
        fill:rgb(255,215,0),
        size: height/2,
        [\u{2605}]
      )
    )
  )
}
// ms 1:2
#let flag-ms(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb("012169"),
    )
    +place(
      top,
      flag-gb(height: height/2)
    )
    +place(
      horizon+center,
      dx:1/4*2*height,
      image("coat of arms/MS.svg",height:height/2)
    )
  )
}
// mt 2:3 coat of arms
#let flag-mt(height:.65em) = {
  box(
    flag-v2((rgb("FFFFFF"),rgb("CF142B")),height: height, ratio:2/3)+place(
    dx:(81/648-(112/648)/2)*height,
    dy:(81/432-(112/432)/2-1)*height,
    image("coat of arms/MT.svg", height:112/432*height
    ))
    )
}
// mu 2:3
#let flag-mu(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(235,36,54),
        rgb(19,26,109),
        rgb(255,214,0),
        rgb(0,166,80),
      ).sharp(4)
    )
  )
}
// mv
#let flag-mv(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb("d21034")
    )
    +place(
      horizon+center,
      rect(
        height:height/2,
        width:48/72*3/2*height,
        fill:rgb("007e3a")
      )
    )
    +place(
      horizon+center,
      dx:3/72*3/2*height,
      circle(
        fill:white,
        radius:8/48*height)
    )
    +place(
      horizon+center,
      dx:6/72*3/2*height,
      circle(
        fill:rgb("007e3a"),
        radius:8/48*height)
    )
  )
}
// mw 2:3
#let flag-mw(height:.65em) = {
  box(
    rect(
      height: height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        black,rgb(206,17,38),rgb(51,158,53)
        ).sharp(3)
    )
    + place(
      top+center,
      dy:.03*height,
      image("coat of arms/MW.svg",height: .9*1.9/3*height)
    )
  )
}
// mx coat of arms 4:7
#let flag-mx(height:.65em) = {
  box(
    flag-v3((rgb(0,104,71),white,rgb(206,17,38)), height: height, ratio:4/7)
    +place(
      dy:-2/3*height,
      dx:2/3*height,
      image("coat of arms/MX.svg", width:7/16*height)
      )
  )
}
// my 1:2
#let flag-my(height:.65em) = {
  box(
    rect(
      height:height,
      width: height*2,
      fill:gradient.linear(
        dir:ttb,
        rgb(207,9,33),white
      ).sharp(2).repeat(7)
    )
    +place(
      top+left,
      rect(
        height: 8/14*height,
        width:height*2/2,
        fill:rgb(0,39,128)
        )
        +place(
          horizon,
          dx:4/28*height,
          circle(
            fill:yellow,
            radius:3/14*height,
          )
        )
        +place(
          horizon,
          dx:6/28*height,
          circle(
            fill:rgb(0,39,128),
            radius:2.75/14*height,
          )
        )
        +place(
          horizon,
          dx:10.75/28*height,
          text(
            fill:yellow,
            size:5/14*height,
            [\u{2737}])
        )
        +place(
          horizon,
          dx:10.75/28*height,
          text(
            fill:yellow,
            size:5/14*height,
            rotate(22.5deg,[\u{2737}]))
        )
      )
  )
}
// mz 2:3
#let flag-mz(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        ..(rgb(0,113,104),)*10,
        white,
        ..(black,)*10,
        white,
        ..(rgb(252,225,0),)*10,
      ).sharp(32)
    )
    + place(
      polygon(
        (0*height,0*height),
        (393.75/900*3/2*height,-1/2*height),
        (0*height,-1*height),
        fill:rgb(210,16,52)
      )
    )
    + place(
      horizon,
      dy:-1/20*height,
      dx:12.964/900*height,
      text(
        fill:rgb(252,225,0),
        size:height*2/3,
        [\u{2605}]
      )
    )
    + place(
      horizon,
      dx:55/900*height,
      dy:-6/600*height,
      image(
        "coat of arms/MZ.svg", 
        height:8/32*height)
    )
  )
}
// na 2:3
#let flag-na(height:.65em) = {
  box(
    rect(
      height:height,
      width: 3/2*height,
      fill:white
    )
    + place(
      top,
      polygon(
        (0*3/2*height,0*height),
        (144/180*3/2*height,0*height),
        (0*3/2*height,96/120*height),
        fill:rgb(0,47,108)
        )
    )

     + place(
        top,
        dx:18/180*3/2*height,
        dy:10/120*3/2*height,
        text(
          rgb(255,205,0),
          size:35/80*height,
          [\u{1F7CB}]
        )
     )
     + place(
        top,
        dx:18/180*3/2*height,
        dy:10/120*3/2*height,
        rotate(
          30deg,
          text(
            rgb(255,205,0),
            size:35/80*height,
            [\u{1F7CB}]
          )
        )
     )
      + place(
          top,
          dx:28.75/180*3/2*height,
          dy:13.25/120*3/2*height,
          circle(
            radius: 17/80*height/2,
            fill:rgb(0,47,108) 
            )
        )
      + place(top,
          dx:31/180*3/2*height,
          dy:14.75/120*3/2*height,
          circle(
            radius: 14/80*height/2,
            fill:rgb(255,205,0)
            )
        )



    + place(
      top,
      polygon(
        ((180-30)/180*3/2*height,0*height),
        ((180)/180*3/2*height,0*height),
        ((180)/180*3/2*height,20/120*height),
        ((30)/180*3/2*height,1*height),
        ((0)/180*3/2*height,1*height),
        ((0)/180*3/2*height,100/120*height),
        fill:rgb(200,16,46)
      )
    )
    + place(
      bottom,
      polygon(
        (3/2*height,0*height),
        ((180-144)/180*3/2*height,0*height),
        (3/2*height,-96/120*height),
        fill:rgb(0,154,68)
        )
    )
    /*
    // diagonal
    + place(
      line(
        start:(0*3/2*height,0*height),
        end:(1*3/2*height,-1*height),
      )
    )
    */
  )
  
}
// nc fr + kanaky
#let flag-nc(height:.65em) = {
  box(
    stack(
      dir:ltr,
      flag-fr(height:height),
      box(
        rect(
          height: height,
          width: 5/3*height,
          fill:gradient.linear(
            dir:ttb,
            rgb(0,115,206),
            rgb(225,60,50),
            rgb(0,152,57),
          ).sharp(3)
        )
        +place(horizon,
          dx:1/6*height,
          circle(
            radius: 1/3*height,
            fill:rgb(254,220,0),
            place(center+horizon,
            image("coat of arms/NC.svg", height: height*4/7))
            ))
      )
    )
  )
}
// ne 6:7?
#let flag-ne(height:.65em) = {
  box(
    rect(
      height: height,
      width: 7/6*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(224,82,6),white,rgb(13,176,43)
        ).sharp(3)

    )
    +place(
      center+horizon,
      circle(
        radius: .9*height/6,
        fill:rgb(224,82,6)
        )
    )
  )
}
// nf 1:2
#let flag-nf(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        dir:ltr,
        ..(rgb(0,121,52),)*7,
        ..(white,)*9,
        ..(rgb(0,121,52),)*7
      ).sharp(7+9+7)
    )
    +place(horizon+center,
    image("coat of arms/NF.svg", height: 9/10*height))
  )
}
// ng 1:2?
#let flag-ng(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        rgb(0,128,0),white,rgb(0,128,0)
      ).sharp(3)
    )
  )
}
// ni 3:5
#let flag-ni(height:.65em) = {
  box(
    flag-h3((rgb("0080FF"),rgb(255,255,255),rgb("0080FF")),height: height,ratio: 3/5)
    + place(
        dy:-66%,
        dx:40%*5/3*height,
      image("coat of arms/NI.svg", height:height/3.1)
    )
  )
}
// nl 2:3
#let flag-nl(height:.65em) = {
  flag-h3((rgb(173,29,37),white,rgb(30,71,133)),height: height, ratio:2/3)
}
#let flag-bq(height:.65em) = {
  flag-nl(height: height)
}
// no 8:11
#let flag-no(height:.65em) = {
  box(
    rect(
      height:height,
      width: 11/8*height,
      fill: rgb("BA0C2F")
    )
    +place(
      top,
      dx:6/22*11/8*height,
      rect(
        height:height,
        width: 4/22*11/8*height,
        fill: white
      )
    )
    +place(
      horizon,
      rect(
        height:4/16*height,
        width: 11/8*height,
        fill: white
      )
    )
    +place(
      top,
      dx:7/22*11/8*height,
      rect(
        height:height,
        width: 2/22*11/8*height,
        fill: rgb("00205B")
      )
    )
    +place(
      horizon,
      rect(
        height:2/16*height,
        width: 11/8*height,
        fill: rgb("00205B")
      )
    )
  )
}
#let flag-bv(height:.65em) = {
  flag-no(height: height)
}
// np 4/3:1
#let flag-np(height:.65em) = {
  box(

    //clip:true,
    rect(
      height: height*1.03,
      width: 3/4*height*1.11,
      stroke:none,
      
    )
    + place(
      dx:0.018*height,
      polygon(
        fill:rgb("#dc143c"),
        stroke:(
          paint:rgb("#003893"),
          thickness: 1/30*height)
          ,
        (0%*height,0%*height),
        (3/4*height,0%*height),
        ((1-calc.sqrt(2)/2)*height,-calc.sqrt(2)/2*3/4*height),
        (3/4*height,-calc.sqrt(2)/2*3/4*height),
        (0*height,-1*height),
      )
      + place(
        center+horizon,
        dx:-1/5*3/4*height,
        dy: -calc.sqrt(2)/6*height,
        text(
          fill:white,
          size:height/2,
          [\u{1F7d3}]
        )
      )
      + place(
        center+horizon,
        dx:-1/5*3/4*height,
        
        dy:-(1-calc.sqrt(2)/4)*1.06*height,
        circle(
          fill:gradient.linear(white,white,white.transparentize(100%),angle:-60deg).sharp(3), 
          radius: height/8)
      )
      + place(
        center+horizon,
        dx:-1/5*3/4*height,
        dy: -(1-calc.sqrt(2)/4)*1.16*height,
          circle(
          fill:gradient.linear(rgb("#dc143c"),rgb("#dc143c"),rgb("#dc143c").transparentize(100%), angle:-60deg).sharp(3), 
          radius: height/7)
      )
      + place(
        center+horizon,
        dx:-1/5*3/4*height,
        dy:-(1-calc.sqrt(2)/4)*height,
        text(
          fill:white,
          size:height/4,
          [\u{1F7D0}]
        )
      )
      + place(
        center+horizon,
        dx:-1/5*3/4*height,
        dy:-(1-calc.sqrt(2)/4)*height,
        text(
          fill:white,
          size:height/4,
          rotate(360deg/16,[\u{1F7D0}])
        )
      )
      // construction lines
      /*
      +place(
        dy:-calc.sqrt(2)/6*height,
        line()
      )
      +place(
        dy:-(1-calc.sqrt(2)/4)*height,
        line()
      )
      */
    )
  )
}
// nr 1:2
#let flag-nr(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(0,47,108),
    )+ place(
      horizon,
      rect(
        height: height/12,
        width:2*height,
        fill:rgb(255,205,0)
        ), 
    )
    + place(
        top,
        dx:12/48*height*2,
        dy:17/24*height,
        polygram((12,5),height/6,white)
      )
  )
}
// nu 1:2
#let flag-nu(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: yellow,
    )
    + place(
      top,
      flag-gb(height:height/2)
      + place(top,
      dx:23/100*height,
      dy:49/200*height,
      rotate(-18deg,polygram((5,2),height/20,yellow)))
      + place(top+right,
      dx:-20/100*height,
      dy:49/200*height,
      rotate(-18deg,polygram((5,2),height/20,yellow)))
      + place(top+center,
      dx:3/100*height,
      dy:20/200*height,
      rotate(-18deg,polygram((5,2),height/20,yellow)))
      + place(top+center,
      dx:3/100*height,
      dy:80/200*height,
      rotate(-18deg,polygram((5,2),height/20,yellow)))
      + place(center+horizon,
      circle(radius: height/12,fill:rgb("012169")))
      + place(center+horizon,
      dx:5/100*height,
      dy:5/200*height,
      rotate(-18deg,polygram((5,2),height/12,yellow))
      )

    )
  )
}
// nz 1:2
#let flag-nz(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb("012169")
    )
    + place(
      top,
      flag-gb(height:height/2)
      )
    // gamma crucis
    + place(
        horizon,
        dx:height*23/32*2,
        dy:height*-8/24,
        text(
          fill:rgb("c8102e"),
          stroke:(paint:white, thickness: height/180),
          size:height/4,
          [\u{2605}]
          )
        )
        
    // alpha crucis
    + place(
        horizon,
        dx:height*23/32*2,
        dy:height*7/24,
        text(
          fill:rgb("c8102e"),
          stroke:(paint:white, thickness: height/180),
          size:height/4,
          [\u{2605}]
          )
        )
    // beta crucis
    + place(
        horizon+right,
        dx:height*-5.1/8,
        dy:height*-1/24,
        text(
          fill:rgb("c8102e"),
          stroke:(paint:white, thickness: height/180),
          size:height/4,
          [\u{2605}]
          )
        )
    // epsilon crucis
    + place(
        horizon,
        dx:height*5.9/7*2,
        dy:height*-3/24,
        text(
          fill:rgb("c8102e"),
          stroke:(paint:white, thickness: height/180),
          size:height/6,
          [\u{2605}]
          )
        )
  )
}
// om 1:2
#let flag-om(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:gradient.linear(
        dir:ttb,
        white,rgb(216,28,34),rgb(0,122,61)
      ).sharp(3)
    )
    + place(
      top,
      rect(
        height: height,
        width:2/7*2*height,
        fill: rgb(216,28,34),
      )
      + place(
        top+center,
        dy:.05*height,
        image("coat of arms/OM.svg", height:height/3.5)
      )
    )
  )
}
// pa 2:3
#let flag-pa(height:.65em) = {
  box(
    height: height,
    width: 3/2*height,
    fill:white,
    place(dx:50%,
      rect(
        fill:rgb("da121a"),
        height: 50%*height,
        width: 50%*3/2*height)
      )
    + place(
        dy:50%,
        rect(fill:rgb("072357"),
        height: 50%*height,
        width: 50%*3/2*height))
    + place(
        dy:3%,
        dx:15%,
        text(
          fill:rgb("072357"),
          size:height/2,
          [\u{2605}]
        )
    )
    + place(
        dy:53%,
        dx:65%,
        text(
          fill:rgb("da121a"),
          size:height/2,
          [\u{2605}]
        )
    )
    /*
    //construction lines
    +place(line(
      start:(0%,0%),
      end:(100%,100%)
    ))
    +place(line(
      start:(0%,25%),
      end:(50%,25%)
    ))
    +place(line(
      start:(50%,75%),
      end:(100%,75%)
    ))
    */
  )
}
// pe 2:3
#let flag-pe(height:.65em) = {
  box(
    flag-v3((rgb(217,16,35),white,rgb(217,16,35)), height:height,ratio:2/3)
  )
}
// pf 2:3
#let flag-pf(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(206,17,38),white,white,rgb(206,17,38)
      ).sharp(4)
    )
    +place(horizon+center,
    image("coat of arms/PF.svg",height:height/2)
    )
  )
}
// pg 3:4
#let flag-pg(height:.65em) = {
  box(
    rect(
      height: height,
      width: 4/3*height,
      fill: rgb(210,16,2)
    )
    +place(
      top,
      polygon(
        (-0*4/3*height,0*height),
        (-0*4/3*height,1*height,),
        (1*4/3*height,1*height),
        fill:black
        )
    )
    // south cross
    // gamma crucis (top)
    + place(
        top,
        dx:height/3,
        dy:height/3,
        rotate(
          -18deg,
          polygram((5,2),height/15,white)
          )
        )
    // alpha crucis (bottom)
    + place(
        top,
        dx:height/3,
        dy:height*6/7,
        rotate(
          -18deg,
          polygram((5,2),height/15,white)
          )
    )
    // beta crucis (left+center)
    + place(
        horizon+left,
        dx:height*1.5/8,
        dy:height*2/24,
        rotate(
          -18deg,
          polygram((5,2),height/15,white)
          )
        )
    // delta crucis (right+center)
    + place(
        horizon+left,
        dx:height*4/8,
        dy:height*1/24,
        rotate(-18deg,polygram((5,2),height/15,white)),
    )
    // epsilon crucis (smallest)
    + place(
        horizon+left,
        dx:height*2/5,
        dy:height*5/24,
        rotate(
          -18deg,
          polygram((5,2),height/25,white)
        )
    )
    // raggiana bird of paradise
    +place(
      horizon+right,
      dx:height*-1/8,
      dy:-1/6*height,
      image("coat of arms/PG.svg",height:height/2)
    )
  )
}
// ph 1:2
#let flag-ph(height:.65em) = {
  box(
    rect(
      height:height,
      width:height*2,
      fill:gradient.linear(
        dir:ttb,
        rgb(0,56,168),
        rgb(206,17,38),
        
      ).sharp(2)
    )
    +place(
      polygon(
        fill:white,
        (0*height,0*height),
        (0*height,-height),
        (calc.cos(30deg)*height,-height/2),
        )
      )
    + place(
        horizon+left,
        dx:10/180*height,
        image("coat of arms/PH.svg", height: 38/90*height)
        )
    + place(
        top+left,
        dy:7/90*height,
        dx:3/90*height,
        text(
          fill:yellow,
          size:2/9*height,
          rotate(30deg,[\u{2605}])
          )
        )
    + place(
        bottom+left,
        dy:-7/90*height,
        dx:3/90*height,
        text(
          fill:yellow,
          size:2/9*height,
          rotate(60deg,[\u{2605}]))
        )
    + place(
        horizon+left,
        dx:55/90*height,
        dy:-1/90*height,
        text(
          fill:yellow,
          size:2/9*height,
          rotate(-60deg,[\u{2605}]))
        )
  )
}
// pk 2:3
#let flag-pk(height:.65em) = {
  box(
    rect(
        height:height,
        width: 3/2*height,
        fill:white
      )
    + place(
      dy:-height,
      dx:7.5/30*3/2*height,
      rect(
        height:height,
        width:22.5/30*3/2*height,
        fill:rgb(0,64,26)
      )
      + place(
        horizon+center,
        circle(
          radius: 6/22.5*height,
          fill:white,
          )
      )
      + place(
        horizon+center,
        dx:2.05/22.5*height,
        dy:-2.05/22.5*height,
        circle(
          radius: 6/22.5*height,
          fill:rgb(0,64,26)
          )
      )
      
      + place(
        horizon+center,
        dx:(2.05+1.5)/22.5*height,
        dy:-(2.05+1.5-0.5)/22.5*height,
        text(
          fill:white,
          size:7/20*height,
          rotate(45deg,[\u{2605}])
          )
      )
      // construction lines 
      /*
      +place(
        horizon,
        line(
          start:(0*height,0*height),
          end:(22.5/30*3/2*height,0*height)
        )
      )
      +place(
        line(
          start:(0*height,0*height),
          end:(22.5/30*3/2*height,-height)
        )
      )
      */
    )
    )

}
// pl 5:8
#let flag-pl(height:.65em) = {
  flag-h3((rgb("EEEEEE"),rgb("D4213D"),none),height: height, ratio:5/8,color-height: (1/2,1/2,0))
}
// pm
#let flag-pm(height:.65em) = {
  flag-fr(height:height)
}
// pn 1:2
#let flag-pn(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb("012169"),
    )
    +place(
      top,
      flag-gb(height: height/2)
    )
    +place(
      horizon+right,
      dx:-1/16*2*height,
      image("coat of arms/PN.svg", height:3/4*height)
    )
  )
}
// pr 2:3
#let flag-pr(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(237,0,0),
        white,
        rgb(237,0,0),
        white,
        rgb(237,0,0),
      ).sharp(5)
    )
    +place(
      top,
      polygon(
        fill:rgb(8,68,255),
        (0*height*3/2,0*height),
        (25.98/45*height*3/2,0.5*height),
        (0*height*3/2,1*height),
      )+place(
        horizon+center,
        dx:-1/45*3/2*height,
        dy:1/30*height,
        rotate(-18deg,polygram((5,2),height/6,white))
      )
      )
  )
}
// ps 1:2
#let flag-ps(height:.65em) = {
  box(
    rect(
      height: height,
      width:height*2,
      fill:gradient.linear(
        dir:ttb,
        black,
        white,
        rgb(0,151,54)
      ).sharp(3)
    )
    + place(
        top,
        polygon(
          (0*height,0*height),
          (1/3*2*height,1/2*height),
          (0*height,1*height),
          fill:rgb(238,42,53)
        )
      )
  )
}
// pt 2:3
#let flag-pt(height:.65em) = {
  box(flag-v2((rgb("006600"),rgb("FF0000")),height: height, ratio:2/3, color-width: (2/5,3/5))+place(
    // coat of arms
    dx:(2/5)*height,
    dy:-2/3*height,
    image("coat of arms/PT.svg", width:7/35*2*height)
  )
  )
}
// pw 5:8
#let flag-pw(height: .65em) = {
  box(
    rect(
      height: height,
      width : 8/5*height,
      fill:rgb(74,173,214)
    )
    + place(
      left+horizon,
      dx:3.5/16*height*8/5,
      circle(
        fill:yellow,
        radius: 3/10*height
        )
    )
  )
}
// py 3:5 coat of arms
#let flag-py(height:.65em) = {
  box(
    flag-h3((rgb("d52b1e"),white,rgb("0038a8")),height:height, ratio:3/5)
    + place(
        dy:-(2/3-1/24)*height,
        dx:height*(2/3+1/24),
        image("coat of arms/PY.svg",height:1/4*height)
        )
    /*    
    + place(
        line(
          start:(0*height,0*height),
          end:(5/3*height,-height)
          )
        )
    + place(
        line(
          start:(0*height,-height),
          end:(5/3*height,0*height)
          )
        )
    */
  )
}
// qa 11:28
#let flag-qa(height:.65em) = {
  box(
    rect(
      height:height,
      width:28/11*height,
      fill: rgb(138,21,56)
    )
    + place(
      top,
      rect(
        height:height,
        width:(4200-504)/12600*28/11*height,
        fill:white
      )
      +for i in range(9).map(i=>i*2) {
       place(
          top,
          polygon(
            ((4200-504-50)/12600*28/11*height,(i)*275/4950*height),
            ((4200-504)/12600*28/11*height,(i)*275/4950*height),
            ((4200+504)/12600*28/11*height,(i+1)*275/4950*height),
            ((4200-504)/12600*28/11*height,(i+2)*275/4950*height),
            ((4200-504-50)/12600*28/11*height,(i+2)*275/4950*height),
            fill:white
          )
        ) 
      }
      )
    )
}
// re 2:3
#let flag-re(height:.65em) = {
  flag-fr(height: height)
}
// ro 2:3
#let flag-ro(height:.65em) = {
  flag-v3((rgb("002b7f"),rgb("fcd116"),rgb("ce1126")),height: height, ratio:2/3, color-width: (1/3,1/3,1/3))
}
// rs 2:3
#let flag-rs(height:.65em) = {
  box(
    flag-h3((cmyk(0%, 90%, 70%, 10%),rgb("0C4077"),rgb("FFFFFF")),height: height, ratio:2/3)
    +place(
      dx:2/3*height/2,
      dy:-(1-2/18)*height,
      image("coat of arms/RS.svg", width:2/3*height/2, ))
    )
}
// ru 2:3
#let flag-ru(height:.65em) = {
  flag-h3((white,rgb("0039A6"),rgb("D52b1e")), ratio:2/3, height: height)
}
// rw 2:3
#let flag-rw(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(0,161,255),)*2,
        rgb(250,210,1),
        rgb(32,96,61)
      ).sharp(4)
    )
    + place(
      top+right,
      dy:1/10*height,
      dx:-1/10*3/2*height,
      text(
        fill:rgb(250,210,1),
        size:height/3,
        // \u{2739}
        [\u{1f7d2}]
      )
    )
    + place(
      top+right,
      dy:1/10*height,
      dx:-1/10*3/2*height,
      rotate(
        360deg/12/2,
        text(
          fill:rgb(250,210,1),
          size:height/3,
          // \u{2739}
          [\u{1f7d2}]
        )
      )
    )
    + place(
      top+right,
      dy:15./100*height,
      dx:-15.5/100*3/2*height,
      circle(
        radius: height/16,
        fill:rgb(0,161,255)
      )
    )
    + place(
      top+right,
      dy:15.75/100*height,
      dx:-16/100*3/2*height,
      circle(
        radius: height/18,
        fill:rgb(250,210,1)
      )
    )
  )
}
// sa 2:3
#let flag-sa(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:rgb(0,84,48)
    )
    + place(horizon+center,
    image("coat of arms/SA.svg", height:height/2))
  )
}
// sb 1:2
#let flag-sb(height: .65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb(252,209,22)
    )
    +place(
      top+left,
      polygon(
        (0*height*2,0*height),
        (97.5%*height*2,0*height),
        (0*height*2,95%*height),
        fill:rgb(0,81,186)
        )
    )
    +place(
      bottom+right,
      polygon(
        (0*height*2,0*height),
        (-97.5%*height*2,0*height),
        (0*height*2,-95%*height),
        fill:rgb(33,91,51)
        )
    )
    +place(
      top+left,
      dx:height/7,
      dy:height/9,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/10,
          white)
        )
    )
    +place(
      top+left,
      dx:height/7,
      dy:height/2,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/10,
          white)
        )
    )
    +place(
      top+left,
      dx:height/2,
      dy:height/9,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/10,
          white)
        )
    )
    +place(
      top+left,
      dx:height/2,
      dy:height/2,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/10,
          white)
        )
    )
    +place(
      top+left,
      dx:height/3,
      dy:height/3.5,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/10,
          white)
        )
    )
  )

}
// sc 1:2
#let flag-sc(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(0,123,58),
      /*fill: gradient.conic(
        center:(0%,100%),
        rgb(0,123,58),
        white,
        rgb(215,35,35),
        rgb(252,217,85),
        rgb(0,61,136)
      ).sharp(5).repeat(4)*/
    )
    + place(
        polygon(
        (0*height,0*height),
        (0*height,-1*height),
        (2/6*2*height,-1*height),
        fill:rgb(0,61,136),
      )
    )
    + place(
        polygon(
        (0*height,0*height),
        (2/6*2*height,-1*height),
        (4/6*2*height,-1*height),
        fill:rgb(252,217,85),
      )
    )
    + place(
        polygon(
        (0*height,0*height),
        (4/6*2*height,-1*height),
        (2*height,-1*height),
        (2*height,-1*2/3*height),
        fill:rgb(215,35,35),
      )
    )
    + place(
        polygon(
        (0*height,0*height),
        (2*height,-1*2/3*height),
        (2*height,-1/3*height),
        fill:white,
      )
    )
  )

}
// sd 1:2
#let flag-sd(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(210,16,42),
        white,black,
      ).sharp(3)
    )
    + place(
      top,
      polygon(
        (0*2*height,0*height),
        (1/3*2*height,1/2*height),
        (0*2*height,1*height),
        fill:rgb(0,114,41),
      )
    )
  )
}
// se 5:8
#let flag-se(height:.65em) = {
  box(
    rect(
      height: height,
      width: 8/5*height,
      fill: rgb("005293")
    )
    + place(
        top,
        dx: 5/16*8/5*height,
        rect(
          height:height,
          width:2/16*8/5*height,
          fill: rgb("FFCD00")
        )
    )
    + place(
        horizon,
        rect(
          height:2/10*height,
          width:8/5*height,
          fill: rgb("FFCD00")
        )
    )
  )
}
// sg 
#let flag-sg(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(238,37,54),
        white
        ).sharp(2)
    )
    + place(
        horizon+left,
        dy:-9/36*height,
        dx:5.25/36*height,
        circle(
          radius:13.25/72*height,
          fill:white
        )
      )
    + place(
        horizon+left,
        dy:-9/36*height,
        dx:8.25/36*height,
        circle(
          radius:13.25/72*height,
          fill:rgb(238,37,54)
        )
      )
    + for i in range(5) {
      place(
          horizon+left,
          dy:-(9+calc.sin(72deg*i+18deg)*4)/36*height,
          dx:(14.25+calc.cos(72deg*i+18deg)*4)/36*height,
          text(
            fill:white,
            size:5/36*height,
            [\u{2605}]
          )
        )
      } 
  )
}
// sh
#let flag-sh(height:.65em) = {
  flag-gb(height: height,)
    
}
// si 1:2
#let flag-si(height:.65em) = {
  box(
    flag-h3((white,rgb("#0004e6e0"),cmyk(0%,100%,100%,0%)),height: height,ratio: 1/2)
    + place(
        dy:-(1-1/6)*height,
        dx:1.5/6*height,
        image("coat of arms/SI.svg",height:height/3)
      )
    )
}
// sj
#let flag-sj(height:.65em) = {
  flag-no(height: height,)
}
// sk 2:3
#let flag-sk(height:.65em) = {
  box(
    flag-h3((white,rgb("0b4ea2"),rgb("ee1c25")),height: height,ratio: 2/3)
    + place(dy:(-1+15/60)*height, dx:15/90*height,image("coat of arms/SK.svg", height:height/2))
  )
}
// sl 2:3
#let flag-sl(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        rgb(30,181,58),
        white,
        rgb(0,114,198),
      ).sharp(3)
    )
  )
}
// sm 3:4
#let flag-sm(height:.65em) = {
  box(
    flag-h3((white,cmyk(55%,10%,5%,0%),none),height: height,ratio: 3/4,color-height: (1/2,1/2,0))
    + place(
        dy:-(1-5/18)*height,
        dx:1/2*height,
        image("coat of arms/SM.svg",height:height*3/8)
      )
    )
}
// sn 2:3?
#let flag-sn(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        rgb(30,181,58),
        rgb(252,209,22),rgb(206,17,38)
      ).sharp(3)
    )
    + place(
      horizon+center,
      dy:-5/100*height,
      text(
        fill:rgb(30,181,58),
        size:height/2,
        [\u{2605}]
      )
    )
    /*
    // construction line
    + place(
      horizon+center,line()
    )
    */
  )
}
// so 2:3?
#let flag-so(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:blue
    )
    +place(
      horizon+center,
      dy:-9%*height,
      text(
        fill:white,
        size:height*3/4,
        [\u{2605}]
      )
    )
    /*
    // construction line
    +place(
      line(
        start:(0*height,-1/2*height),
        end:(3/2*height,-1/2*height),
        )
      )
    */
  )
}
// sr 2:3
#let flag-sr(height:.65em) = {
  box(
    rect(fill:white,height:height,width: 3/2*height)
    + place(
      dy:-height,
      rect(fill:rgb(55,126,63),height:1/5*height,width: 3/2*height)
    )
    + place(
      rect(fill:rgb(55,126,63),height:-1/5*height,width: 3/2*height)
    )
    + place(
      dy:-7/10*height,
      rect(
          fill:rgb(180,10,45),width: 3/2*height, height:2/5*height)
    )
    +place(
      dx:56.8%*height,
      dy:-3/4*height,
      text(yellow,size:3/5*height,[\u{2605}])
    )
    /*
    // construction lines
    +place(line(
      start:(0*height,-50%*height),
      end:(3/2*height,-50%*height)
    ))
    +place(line(
      start:(3/4*height,-100%*height),
      end:(3/4*height,-0%*height)
    ))
    */
  )
}
// ss 1:2
#let flag-ss(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:gradient.linear(
        dir:ttb,
        ..(black,)*6,
        white,
        ..(rgb(210,16,42),)*6,
        white,
        ..(rgb(0,114,41),)*6,
      ).sharp(20)
    )
    +place(
      top,
      polygon(
        (0*2*height,0*height),
        (calc.sqrt(1-1/4)*height,1/2*height),
        (0*2*height,1*height),
        fill:rgb("#00b6f2")
      )
    )
    +place(
      horizon,
      dy:-5%*height,
      dx:15%*height,
      text(
        size:height/2,
        fill:yellow,
        [\u{2605}]
      )
    )
  )
}
// st 1:2
#let flag-st(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(18,173,43),)*4,
        ..(rgb(255,206,0),)*3
      ).sharp(7).repeat(2,mirror: true)
    )
    + place(
      polygon(
        (0*2*height,0*height),
        (0*2*height,-1*height),
        (1/2*height,-1/2*height),
        fill:rgb(210,16,52)
      )
    )
    + place(
      horizon+center,
      dy:-5/84*height,
      dx:48/168*height,
      text(
        fill:black,
        size:2/3*height,
        [\u{2605} \u{2605}]
      )
    )
    /*
    // construction line
    +place(
      line(
        start:(height,0*height),
        end:(height,-height),
      )
    )
    */
  )
}
// sv 189:335
#let flag-sv(height:.65em) = {
  box(
    rect(
      height: height,
      width: 335/189*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(0,71,175),white,rgb(0,71,175)
      ).sharp(3)
    )
    +place(
      center+horizon,
      image("coat of arms/SV.svg", height: height/3.2)
      )
  )
}
// sx 2:3
#let flag-sx(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(173,29,37),rgb(30,71,133)
        ).sharp(2)
    )
    +place(
      top,
      polygon(
        fill:white,
        (0*3/2*height,0*height),
        (4/9*3/2*height,1/2*height),
        (0*3/2*height,1*height),
        )
      )+place(
        horizon,
        dx:1/18*3/2*height,
        image("coat of arms/SX.svg",height: 3/8*height)
      )
  )
}
// sy 2:3
#let flag-sy(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        rgb(0,122,61),white,black
      ).sharp(3)
    )
    +place(
      horizon+center,
      dy:-1/20*height,
      text(
        fill:rgb(206,17,38),
        size:height/2,
        [\u{2605} \u{2605} \u{2605}]
        )
    )
  )
}
// sz 2:3
#let flag-sz(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:gradient.linear(
        dir:ttb,
        ..(rgb("3e5eb9"),)*3,
        ..(rgb("ffd900"),)*1,
        ..(rgb("b10c0c"),)*3
      ).sharp(7).repeat(2, mirror: true)
    )
    + place(
      horizon+center,
      image("coat of arms/SZ.svg", height: height*1.1/3)
    )
  )
}
// ua 3:4
#let flag-ua(height:.65em) = {
  flag-h3((rgb("0057b8"),rgb("ffd700"),none), height: height, color-height: (1/2,1/2,0), ratio: 2/3)
}
// ug 2:3
#let flag-ug(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        dir:ttb,
        black,
        rgb(252,220,4),
        rgb(217,0,0)
      ).sharp(3).repeat(2)
    )
    +place(
      horizon+center,
      circle(
        fill:white,
        radius:.95*1/3*height/2
        )
      )  
    + place(
      horizon+center,
      dx: 1/90*3/2*height,
      image("coat of arms/UG.svg", height:.90*1/3*height)
      )
    )
      

}
// us 10:19
#let flag-us(height:.65em) = {
  box(
    rect(fill:none, stroke:none,height:height,width: 19/10*height,inset: 0pt,
      stack(
        dir:ttb,
        ..range(13)
          .map(i=>rect(
            width:100%,
            height: 100%*1/13,
            fill:if calc.even(i) {rgb("B31942")} else {white},
            stroke:none
            )
          )
      )
    )
    + place(
        dy:-100%*height,
        rect(
          inset: 0pt,
          outset:0pt,
          width: 2/5*19/10*height,
          height: 7/13*height,
          fill:rgb("0a3161"),
          text(
            white,
            size:0.082*height,
            place(dy:.2em,
              stack(
                dir:ttb,
                repeat([#h(.4em) \u{2605} #h(.4em)]),
                ..(
                  box(width:83%,
                    place(
                      dx:.8em,
                      repeat([#h(.4em) \u{2605} #h(.4em)])
                      )
                    ),
                  linebreak(),
                  repeat([#h(.4em) \u{2605} #h(.4em)])
                  )*4,
              )
            )
          )
        )
      )
  )

}
// uy 2:3
#let flag-uy(height:.65em) = {
  box(
    rect(width: 3/2*height,height: height, fill:white)
    + place(
        polygon(
          fill:rgb(0,56,168),
          (0*height,-1/9*height),
          (3/2*height,-1/9*height),
          (3/2*height,-2/9*height),
          (0*height,-2/9*height),
        )
      )
    + place(
        polygon(
          fill:rgb(0,56,168),
          (0*height,-3/9*height),
          (3/2*height,-3/9*height),
          (3/2*height,-4/9*height),
          (0*height,-4/9*height),
        )
      )
    + place(
        polygon(
          fill:rgb(0,56,168),
          (1/2*height,-5/9*height),
          (3/2*height,-5/9*height),
          (3/2*height,-6/9*height),
          (1/2*height,-6/9*height),
        )
      )
    + place(
        polygon(
          fill:rgb(0,56,168),
          (1/2*height,-7/9*height),
          (3/2*height,-7/9*height),
          (3/2*height,-8/9*height),
          (1/2*height,-8/9*height),
        )
      )
    + place(
      dy:-95%*height,
      dx: 5%*2/3*height,
      image("coat of arms/UY.svg", height: height/2.2))
    )
}
// uz 1:2
#let flag-uz(height:.65em) = {
  box(
    rect(
      height:height,
      width: height*2,
      fill: gradient.linear(
        dir: ttb,
        ..(rgb(0,153,181),)*80,
        ..(rgb(206,17,38),)*5,
        ..(white,)*80,
        ..(rgb(206,17,38),)*5,
        ..(rgb(0,128,0),)*80,
        ).sharp(250)
    )
    +place(
      top,
      dx:(20)/250*height*2,
      dy:6/125*height,
      circle(
        fill:white,         
        radius:15/125*height)
    )
    +place(
      top,
      dx:27/250*height*2,
      dy:6/125*height,
      circle(
        fill:rgb(0,153,181),         
        radius:15/125*height)
    )
    +place(
      top,
      dx:(20+15+5+4+12+12)/250*height*2,
      dy:8/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12+12)/250*height*2,
      dy:8/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12+12+12)/250*height*2,
      dy:8/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12)/250*height*2,
      dy:20/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12)/250*height*2,
      dy:20/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12+12)/250*height*2,
      dy:20/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12+12+12)/250*height*2,
      dy:20/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4)/250*height*2,
      dy:32/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12)/250*height*2,
      dy:32/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12)/250*height*2,
      dy:32/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12+12)/250*height*2,
      dy:32/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
    +place(
      top,
      dx:(20+15+5+4+12+12+12+12)/250*height*2,
      dy:32/125*height,
      rotate(-18deg,polygram((5,2),4/125*height,white))
    )
  )
}
// tc 1:2
#let flag-tc(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
    fill: rgb("012169"),
    )
    +place(
      top,
      flag-gb(height: height/2)
    )
    +place(
      horizon+right,
      dx:-1/8*2*height,
      image("coat of arms/TC.svg", height:1/2*height)
    )
  )
}
// td 2:3
#let flag-td(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: gradient.linear(
        rgb(0, 37, 105),
        rgb(255, 204, 0),
        rgb(210, 15, 54),
      ).sharp(3)
    )
  )
}
// tf 2:3
#let flag-tf(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:rgb(0,85,164),
    )
    +place(
      top,
      flag-fr(height:1/2*height))
    +place(
      bottom+right,
      dx:-.95/8*3/2*height,
      image("coat of arms/TF.svg",height:height/2)
      )

    +place(
      bottom+right,
      dx:-22/100*3/2*height,
      rotate(-18deg,polygram((5,2),height/27,white))
      )
    +place(
      bottom+right,
      dx:-16.9/100*3/2*height,
      dy:-8.9/100*height,
      rotate(-18deg,polygram((5,2),height/27,white))
      )
    +place(
      bottom+right,
      dx:-27.8/100*3/2*height,
      dy:-8.9/100*height,
      rotate(-18deg,polygram((5,2),height/27,white))
      )
    +place(
      bottom+right,
      dx:-33/100*3/2*height,
      dy:-35.5/100*height,
      rotate(-18deg,polygram((5,2),height/27,white))
      )
    +place(
      bottom+right,
      dx:-11.2/100*3/2*height,
      dy:-35.5/100*height,
      rotate(-18deg,polygram((5,2),height/27,white))
      )
    
  )
}
// tg 1:phi
#let flag-tg(height:.65em) = {
  box(
    rect(
      height: height,
      width: (1+calc.sqrt(5))/2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb(0,106,78),)*1,
        ..(rgb(255,206,0),)*1,
        ..(rgb(0,106,78),)*1,
        ..(rgb(255,206,0),)*1,
        ..(rgb(0,106,78),)*1,
      ).sharp(5)
    )
    + place( top,
      rect(
        height:3/5*height,
        width:3/5*height,
        fill:rgb(210,16,52)
      )
      + place(
        horizon+center,
        dy:-6/100*height,
        text(fill:white,
        size:3/5*height,
        [\u{2605}])
      )
      // construction line
      //+ place(horizon, line(length: 3/5*height))
    )
  )
}
// th 2:3
#let flag-th(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*3/2,
      fill: gradient.linear(
        dir:ttb,
        rgb(165,25,49),
        rgb(244,245,248),
        rgb(45,42,74)).sharp(3).repeat(2, mirror: true)
    )
  )
}
// tj 1:2
#let flag-tj(height:.65em) = {
  box(
    rect(
      height:height,
      width:height*2,
      fill: gradient.linear(
        dir:ttb,
        ..(
          (rgb(205,0,0),)*2,
          (white,)*3,
          (rgb(0,102,0),)*2,
          ).flatten(),
      ).sharp(7)
    )
    +place(
      horizon+center,
      image("coat of arms/TJ.svg", height:2.7/7*height)
    )
  )
}
// tk 1:2
#let flag-tk(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb(1,33,105)
    )
    +place(top,
    image("coat of arms/TK.svg", height: height))
    +place(
      top,
      dx:19.5/100*2*height,
      dy:11.5/100*height,
      rotate(-18deg,polygram((5,2),1/20*height,white))
      )
    +place(
      top,
      dx:19.5/100*2*height,
      dy:72/100*height,
      rotate(-18deg,polygram((5,2),1/20*height,white))
      )
    +place(
      top,
      dx:8/100*2*height,
      dy:35/100*height,
      rotate(-18deg,polygram((5,2),1/20*height,white))
      )
    +place(
      top,
      dx:29/100*2*height,
      dy:29/100*height,
      rotate(-18deg,polygram((5,2),1/25*height,white))
      )
  )
}
// tl 1:2
#let flag-tl(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:red
    )
    + place(
      polygon(
        fill:yellow,
        (0*height,0*height),
        (0*height,-height),
        (height,-1/2*height)
      )
    )
    + place(
      polygon(
        fill:black,
        (0*height,0*height),
        (0*height,-height),
        (12/18*height,-1/2*height)
      )
    )
    + place(
      horizon+left,
      dy:-1/18*height,
      text(
        white,
        size:height/1.6,
        rotate(calc.atan(-4/9),[\u{2605}])
        )
      )
    //construction line
    /*
    + place(
      horizon,
      line(stroke:white)
    )
    */
  )
}
// tm 2:3
#let flag-tm(height:.65em) = {
  box(
    rect(
      height:height,
      width: 3/2*height,
      fill:rgb(0,133,58)
    )
    +place(
      top,
      image("coat of arms/TM.svg", height: height)
    )
  )
}
// tn 2:3
#let flag-tn(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: rgb(206,17,38)
    )
    + place(
      horizon+center,
      circle(
        radius:20/80*height,
        fill:white,
        )
    )
    + place(
      horizon+center,
      circle(
        radius:15/80*height,
        fill:rgb(206,17,38),
        )
    )
    + place(
      horizon+center,
      dx:2/30*height,
      circle(
        radius:12/80*height,
        fill: white,
      )
    )
    + place(
      horizon+center,
      dy:-1.66/80*height,
      dx:8/120*3/2*height,
      rotate(54deg,
        text(
          fill:rgb(206,17,38),
          size:height*2/5,
          [\u{2605}]
        )
      )
    )
    /*
    // construction line
    + place(
      horizon+center,
      line()
      )
    */
  )
}
// to 1:2
#let flag-to(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill: rgb(193,0,0)
    )
    + place(
        top,
        rect(
          height: height/2,
          width: 20/48*2*height,
          fill: white
        )
        )
    + place(
        top,
        polygon(
          ((10+1.5)/48*2*height,(6-4.5)/24*height),
          ((10+1.5)/48*2*height,(4.5)/24*height),
          ((10+4.5)/48*2*height,(4.5)/24*height),
          ((10+4.5)/48*2*height,(7.5)/24*height),
          ((10+1.5)/48*2*height,(7.5)/24*height),
          ((10+1.5)/48*2*height,(10.5)/24*height),
          ((10-1.5)/48*2*height,(10.5)/24*height),
          ((10-1.5)/48*2*height,(7.5)/24*height),
          ((10-4.5)/48*2*height,(7.5)/24*height),
          ((10-4.5)/48*2*height,(4.5)/24*height),
          ((10-1.5)/48*2*height,(4.5)/24*height),
          ((10-1.5)/48*2*height,(6-4.5)/24*height),
          fill:rgb(193,0,0)
        )
    )
  )
}
// tr
#let flag-tr(height:.65em) = {
  box(
      rect(height: height,width:3/2*height, fill:rgb("e30a17"),inset:0pt,
      align(
      center,
      place(
        dx:height/6,
        dy:(1-2/3)/2*height,
        circle(fill:white, radius:(1-2/3)*height)
        )
      + place(
        dx:(1/6-.8/16+.5/2)*height,
        dy:(1-.5)/2*height,
        circle(fill:rgb("e30a17"),  radius:(.5/2)*height)
        )
      + place(
        dx:(6/8)*height,
        dy:(1-.43)/2*height,
        text(white, size:1/2*height)[#rotate(-20deg,[\u{2605}])]
      )
      /*
      + place(
        dy:50%,
        line(length:height*3/2, stroke:(dash:"dotted"))
      )
      */
      )
    )
  )
}
// tt 3:5
#let flag-tt(height:.65em) = {
  box(
    rect(
      height: height,
      width : 5/3*height,
      fill : rgb(218,28,53)
    )
    + place(
        top,
        polygon(
          (0*5/3*height,0*height),
          ((4.58*2)/30*5/3*height,0*height),
          (1*5/3*height,1*height),
          ((30-4.58*2)/30*5/3*height,1*height),
          fill:white
        )
      )
    + place(
        top,
        polygon(
          (1.5/30*5/3*height,0*height),
          ((4.58*2-1.5)/30*5/3*height,0*height),
          (28.5/30*5/3*height,1*height),
          ((30-4.58*2+1.5)/30*5/3*height,1*height),
          fill:black
        )
      )
  )
}
// tv 1:2
#let flag-tv(height: .65em) = {
  box(
    rect(
      height:height,
      width:2*height,
      fill:rgb(0,156,222),
    )
    +place(
      top,
      flag-gb(height: height/2)
      )
    // Nukulaelae
    +place(
      top,
      dx:93/100*2*height,
      dy:13/100*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Funafuti
    +place(
      top,
      dx:83/100*2*height,
      dy:30/100*height,
      rotate(
        18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Vaitupu
    +place(
      top,
      dx:75/100*2*height,
      dy:36/100*height,
      rotate(
        18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Niulakita
    +place(
      top,
      dx:93/100*2*height,
      dy:43/100*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Nukufetau
    +place(
      top,
      dx:86/100*2*height,
      dy:53/100*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Niutao
    +place(
      top,
      dx:63/100*2*height,
      dy:53/100*height,
      rotate(
        18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Nui
    +place(
      top,
      dx:75/100*2*height,
      dy:66/100*height,
      rotate(
        18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Nanumanga
    +place(
      top,
      dx:63/100*2*height,
      dy:73/100*height,
      rotate(
        18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
    // Nanumea
    +place(
      top,
      dx:55/100*2*height,
      dy:76/100*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          height/12,
          yellow
        )
      )
    )
  )
}
// tw 2:3
#let flag-tw(height:.65em) = {
  box(
    rect(height:height, width: 3/2*height,fill:rgb(254,0,0))
    +place(top,
      rect(
        height:height/2,
        width: 3/4*height,
       fill:rgb(0,0,149) 
      )
      + place(
        horizon+center,
        text(white,size:35/80*height,[\u{2739}]
        )
      + place(horizon+center,
        circle(radius: 17/80*height/2, fill:rgb(0,0,149) )
        )
      + place(horizon+center,
        circle(radius: 15/80*height/2, fill:white)
        )
        
      )
    )
  )
}
// tz 2:3?
#let flag-tz(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:black
    )
    + place(
      top,
      polygon(
        fill:rgb(30,151,58),
        (0*3/2*height,0*height),
        (685.25/900*3/2*height,0*height),
        (0*3/2*height,457.25/600*height),
      )
    )
    + place(
      top,
      polygon(
        fill:rgb("fcd116"),
        (685.25/900*3/2*height,0*height),
        (750.25/900*3/2*height,0*height),
        (0*3/2*height,502.35/600*height),
        (0*3/2*height,457.25/600*height),
      )
    )
    + place(
      bottom+right,
      polygon(
        fill:rgb("fcd116"),
        (-685.25/900*3/2*height,0*height),
        (-750.25/900*3/2*height,0*height),
        (0*3/2*height,-502.35/600*height),
        (0*3/2*height,-457.25/600*height),
      )
    )
    + place(
      bottom+right,
      polygon(
        fill:rgb("00a3dd"),
        (0*3/2*height,0*height),
        (-685.25/900*3/2*height,0*height),
        (0*3/2*height,-457.25/600*height),
      )
    )
  )
}
// um
#let flag-um(height:.65em) = {
  flag-us(height:height)
}
// va 1:1 
#let flag-va(height:.65em) = {
  box(
    flag-v2((rgb(255,242,0),white),height: height, ratio:1, color-width: (1/2,1/2))
    +place(
      // coat of arms
      dx:(13/22)*height,
      dy:-16/22*height,
      image("coat of arms/VA.svg", width:1/3*height)
    )
  )
}
// vc 2:3
#let flag-vc(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ltr,
        ..(rgb(0,38,116),rgb(252,208,34),rgb(252,208,34),rgb(0,124,46))
      ).sharp(4)
    )
    + place(
        top,
        dy:1/2*height,
        dx:66/150*3/2*height,
        polygon(
          (0*height,height/7),
          (1/2*height/7,0*height),
          (0*height,-height/7),
          (-1/2*height/7,0*height),
          fill:rgb(0,124,46),
        )
    )
    + place(
        top,
        dy:1/2*height,
        dx:84/150*3/2*height,
        polygon(
          (0*height,height/7),
          (1/2*height/7,0*height),
          (0*height,-height/7),
          (-1/2*height/7,0*height),
          fill:rgb(0,124,46),
        )
    )
    + place(
        top,
        dy:50/75*height,
        dx:1/2*3/2*height,
        polygon(
          (0*height,height/7),
          (1/2*height/7,0*height),
          (0*height,-height/7),
          (-1/2*height/7,0*height),
          fill:rgb(0,124,46),
        )
    )
    // construction lines
    // + place(
    //     top,
    //     line(
    //       start:(0*height,height/2),
    //       end:(3/2*height,height/2)
    //       )
    //   )
    // + place(
    //     top,
    //     line(
    //       start:(3/4*height,0*height),
    //       end:(3/4*height,height)
    //       )
    //   )
  )
}
// ve 2:3
#let flag-ve(height:.65em) = {
  box(
    flag-h3((rgb("FFCD00"),rgb("003087"),rgb("C8102E")),height:height, ratio:2/3)+
    for i in range(8) {
      place(
        dx:(.71 + calc.cos(i*25.71*1deg)/4)*height,
        dy:-(.44 + calc.sin(i*25.71*1deg)/4)*height,
        text(white, size:1/7*height,[\u{2605}]),
      )
    } 
    + place(
        dy:-height,
        dx:5/100*height,
      image("coat of arms/VE.svg", height:height/3)
    )
    /*
    +place(
      line(
        start:(0*height,0*height),
        end:(3/2*height,-height)
        )
      )
    +place(
      line(
        start:(3/2*height,0*height),
        end:(0*height,-height)
        )
      )
    */
    )
}
// vg 1:2
#let flag-vg(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
     fill: rgb("012169"),
    )
    +place(
      top,
      flag-gb(height: height/2)
    )
    +place(
      horizon+right,
      dx:-1/12*2*height,
      image("coat of arms/VG.svg", height:2/3*height)
    )
  )
}
// vi 2:3
#let flag-vi(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill:white
    )
    +place(horizon+center,
    image("coat of arms/VI.svg", height: height))
  )
}
// vn
#let flag-vn(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*3/2,
      fill:rgb(218,37,29)
    )
    +place(
      horizon+center,
      dy:-2/20*height,
      dx:.05/30*height,
      text(fill:rgb(255,255,0), size:1.1*height,[\u{2605}])
      )
    // construction lines
    /*
    +place(
      horizon,
      line(
        start:(0*height,0*height),
        end:(3/2*height,0*height),
      )
    )
    +place(
      top+center,
      line(
        start:(0*height,0*height),
        end:(0*height,1*height),
      )
    )
    */
  )
}
// vu 19:36
#let flag-vu(height:.65em) = {
  box(
    rect(
      height:height,
      width:36/19*height,
      fill:black
    )
    +place(
      top,
      polygon(
        (0*36/19*height,0*height),
        (1*36/19*height,0*height),
        (1*36/19*height,15/36*height),
        (.5*36/19*height,15/36*height),
        fill:rgb(220,36,31)
        )
      )
    +place(
      top,
      polygon(
        (0*36/19*height,1*height),
        (1*36/19*height,1*height),
        (1*36/19*height,21/36*height),
        (.5*36/19*height,21/36*height),
        fill:rgb(0,122,77)
        )
      )
    +place(
      top,
      polygon(
        (0*36/19*height,2/36*height),
        (26/54*36/19*height,17/36*height),
        (1*36/19*height,17/36*height),
        (1*36/19*height,19/36*height),
        (26/54*36/19*height,19/36*height),
        (0*36/19*height,34/36*height),
        (0*36/19*height,32/36*height),
        (24/54*36/19*height,18/36*height),
        (0*36/19*height,4/36*height),
        
        fill:rgb(255,209,0)
        )
      )
    + place(
        horizon,
        dx:3/54*36/19*height,
        image(
          "coat of arms/VU.svg",
          height: height/3
          )
        )
  )
}
// wf 2:3
#let flag-wf(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: rgb(239,65,53)
    )
    +place(
      top,
      rect(flag-fr(height:height/3), stroke:(paint:white, thickness: 1%*height), inset: 0pt)
    )
    +place(
      horizon+right,
      dx:-3/9*height,
      rect(
        height:height/3,
        width:height/3,
        fill:white)
      +place(
        top,
        polygon(
          fill:rgb(239,65,53),
          (0%*height/3,10%*height/3),
          (0%*height/3,0%*height/3),
          (10%*height/3,0%*height/3),
          (100%*height/3,90%*height/3),
          (100%*height/3,100%*height/3),
          (90%*height/3,100%*height/3),
          )
        )
      +place(
        top,
        polygon(
          fill:rgb(239,65,53),
          (100%*height/3,10%*height/3),
          (100%*height/3,0%*height/3),
          (90%*height/3,0%*height/3),
          (0%*height/3,90%*height/3),
          (0%*height/3,100%*height/3),
          (10%*height/3,100%*height/3),
          )
        )
    )
  )
}
// ws 1:2
#let flag-ws(height:.65em) = {
  box(
    rect(
      height: height,
      width: height*2,
      fill:rgb(206,17,38)
    )
    +place(
      top,
      rect(
        height:height/2,
        width:height,
        fill:rgb(0,43,127)
      )
      )
    +place(
      top,
      dx:73/288*height*2,
      dy:7/144*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          8/144*height,
          white
        )
      )
    )
    +place(
      top,
      dx:90/288*height*2,
      dy:20/144*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          7/144*height,
          white
        )
      )
    )
    +place(
      top,
      dx:79/288*height*2,
      dy:38/144*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          5/144*height,
          white
        )
      )
    )
    +place(
      top,
      dx:53/288*height*2,
      dy:25/144*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          8/144*height,
          white
        )
      )
    )
    +place(
      top,
      dx:73/288*height*2,
      dy:57/144*height,
      rotate(
        -18deg,
        polygram(
          (5,2),
          10/144*height,
          white
        )
      )
    )
    // construction line
    // + place(
    //     top,
    //     line(
    //       start:(72/288*height*2,0*height),
    //       end:(72/288*height*2,1/2*height),
    //     )
    //   )
  )  
}
// ye
#let flag-ye(height:.65em) = {
  box(
      rect(
        height:height,
        width:3/2*height,
        fill:gradient.linear(
          dir:ttb,
          rgb(206,17,38),white,black
        ).sharp(3)
      )
    )
  }
// yt
#let flag-yt(height:.65em) = {
  flag-fr(height: height)
}
// za 
#let flag-za(height:.65em) = {
  box(
    rect(
      height:height,
      width:3/2*height,
      fill:gradient.linear(
        dir:ttb,
        ..(rgb(222,56,49),)*5,
        white,
        ..(rgb(0,122,77),)*3,
        white,
        ..(rgb(0,35,149),)*5
      ).sharp(15)
    )
    + place(
        top,
          polygon(
            (18/90*height*3/2,0*height),
            (48/90*height*3/2,20/60*height),
            (46/90*height*3/2,24/60*height),
            (10/90*height*3/2,0*height),
            fill:white
          )
        )
    + place(
        top,
          polygon(
            (18/90*height*3/2,1*height),
            (48/90*height*3/2,40/60*height),
            (46/90*height*3/2,36/60*height),
            (10/90*height*3/2,1*height),
            fill:white
          )
        )
    
    + place(
        top,
          polygon(
            (0*height*3/2,0*height),
            (10/90*height*3/2,0*height),
            (46/90*height*3/2,24/60*height),
            (46/90*height*3/2,36/60*height),
            (10/90*height*3/2,1*height),
            (0*height*3/2,1*height),
            fill:rgb(0,122,77)
          )
        )
    + place(
        top,
        polygon(
          (0*height*3/2,7/60*height),
          (36/90*height*3/2,30/60*height),
          (0*height*3/2,53/60*height),
          fill:rgb(255,182,18)
        )
      )
    + place(
        top,
        polygon(
          (0*height*3/2,12/60*height),
          (28/90*height*3/2,30/60*height),
          (0*height*3/2,48/60*height),
          fill:black
        )
      )
    /*
    // construction lines
    + place(
        horizon,
        line(length: 3/2*height)
    )
    + place(
        horizon+center,
        rotate(90deg,line(length: height))
    )
    + place(
        top,
        line(
          start:(0*3/2*height,0*height),
          end:(1*3/2*height,1*height),

          )
    )
    + place(
        top,
        line(
          start:(1*3/2*height,0*height),
          end:(0*3/2*height,1*height),
        )
    )
    */
  )

}
// zm 2:3
#let flag-zm(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
      fill: rgb(25,138,0)
    )
    + place(
      right,
      rect(
        height:-144/224*height,
        width: 120/336*3/2*height,
        fill: gradient.linear(
          rgb(222,32,16),
          black,
          rgb(239,125,0)
        ).sharp(3)
        )
        + place(
          bottom+center,
          dy: -19/224*height,
          image("coat of arms/ZM.svg", height: 42/224*height )
        )
    )
  )
}
// zw 1:2
#let flag-zw(height:.65em) = {
  box(
    clip:true,
    rect(
      height: height,
      width: 2*height,
      fill: gradient.linear(
        dir:ttb,
        ..(rgb("006400"),)*2,
        ..(rgb("ffd200"),)*2,
        ..(rgb("d40000"),)*2,
        black,
      ).sharp(7).repeat(2,mirror: true),
    )
    + place(
      top,
      polygon(
        (-.01*height,.01*height),
        (158/504*2*height,1/2*height),
        (-.01*height,.99*height),
        fill:white,
        stroke:(paint: black, thickness: 6/252*height)
      )
    )
    + place(
      horizon,
      dy:-10%*height,
      dx:3%*height,
      text(
        fill:cmyk(0%, 100%, 100%, 0%),
        size:2/3*height,
        [\u{2605}]
      )
    )
    + place(
      horizon,
      dy:-4%*height,
      dx:15%*height,
      image("coat of arms/ZW.svg", height:1/4*height)
    )
  )
}

// Make the iso3166 flag function 
#let flag(iso3166, height:.65em,) = {
  assert(iso3166.len()==2 and type(iso3166)==str,message: "iso3166 code should be a string of 2 letters")
  let flags = (
    AD: flag-ad(height:height),
    AE: flag-ae(height:height),
    AF: flag-af(height:height),
    AG: flag-ag(height:height),
    AI: flag-ai(height:height),
    AL: flag-al(height:height),
    AM: flag-am(height:height),
    AO: flag-ao(height:height),
    AQ: flag-aq(height:height),
    AR: flag-ar(height:height),
    AS: flag-as(height:height),
    AT: flag-at(height:height),
    AU: flag-au(height:height),
    AX: flag-ax(height:height),
    AW: flag-aw(height:height),
    AZ: flag-az(height:height),
    BA: flag-ba(height:height),
    BB: flag-bb(height:height),
    BD: flag-bd(height:height),
    BE: flag-be(height:height),
    BF: flag-bf(height:height),
    BG: flag-bg(height:height),
    BH: flag-bh(height:height),
    BI: flag-bi(height:height),
    BJ: flag-bj(height:height),
    BL: flag-bl(height:height),
    BM: flag-bm(height:height),
    BN: flag-bn(height:height),
    BO: flag-bo(height:height),
    BQ: flag-bq(height:height),
    BR: flag-br(height:height),
    BS: flag-bs(height:height),
    BT: flag-bt(height:height),
    BV: flag-bv(height:height),
    BW: flag-bw(height:height),
    BY: flag-by(height:height),
    BZ: flag-bz(height:height),
    CA: flag-ca(height:height),
    CC: flag-cc(height:height),
    CD: flag-cd(height:height),
    CF: flag-cf(height:height),
    CG: flag-cg(height:height),
    CH: flag-ch(height:height),
    CI: flag-ci(height:height),
    CK: flag-ck(height:height),
    CL: flag-cl(height:height),
    CM: flag-cm(height:height),
    CN: flag-cn(height:height),
    CO: flag-co(height:height),
    CR: flag-cr(height:height),
    CU: flag-cu(height:height),
    CV: flag-cv(height:height),
    CW: flag-cw(height:height),
    CX: flag-cx(height:height),
    CY: flag-cy(height:height),
    CZ: flag-cz(height:height),
    DE: flag-de(height:height),
    DJ: flag-dj(height:height),
    DK: flag-dk(height:height),
    DM: flag-dm(height:height),
    DO: flag-do(height:height),
    DZ: flag-dz(height:height),
    EC: flag-ec(height:height),
    EE: flag-ee(height:height),
    EG: flag-eg(height:height),
    EH: flag-eh(height:height),
    ER: flag-er(height:height),
    ES: flag-es(height:height),
    ET: flag-et(height:height),
    EU: flag-eu(height:height),
    FI: flag-fi(height:height),
    FJ: flag-fj(height:height),
    FK: flag-fk(height:height),
    FM: flag-fm(height:height),
    FO: flag-fo(height:height),
    FR: flag-fr(height:height),
    GA: flag-ga(height:height),
    GB: flag-gb(height:height),
    GD: flag-gd(height:height),
    GE: flag-ge(height:height),
    GF: flag-gf(height:height),
    GG: flag-gg(height:height),
    GH: flag-gh(height:height),
    GI: flag-gi(height:height),
    GL: flag-gl(height:height),
    GM: flag-gm(height:height),
    GN: flag-gn(height:height),
    GP: flag-gp(height:height),
    GQ: flag-gq(height:height),
    GR: flag-gr(height:height),
    GS: flag-gs(height:height),
    GT: flag-gt(height:height),
    GU: flag-gu(height:height),
    GY: flag-gy(height:height),
    GW: flag-gw(height:height),
    HK: flag-hk(height:height),
    HM: flag-hm(height:height),
    HN: flag-hn(height:height),
    HR: flag-hr(height:height),
    HT: flag-ht(height:height),
    HU: flag-hu(height:height),
    ID: flag-id(height:height),
    IE: flag-ie(height:height),
    IL: flag-il(height:height),
    IM: flag-im(height:height),
    IN: flag-in(height:height),
    IO: flag-io(height:height),
    IQ: flag-iq(height:height),
    IR: flag-ir(height:height),
    IS: flag-is(height:height),
    IT: flag-it(height:height),
    JE: flag-je(height:height),
    JM: flag-jm(height:height),
    JO: flag-jo(height:height),
    JP: flag-jp(height:height),
    KE: flag-ke(height:height),
    KG: flag-kg(height:height),
    KH: flag-kh(height:height),
    KI: flag-ki(height:height),
    KM: flag-km(height:height),
    KN: flag-kn(height:height),
    KP: flag-kp(height:height),
    KR: flag-kr(height:height),
    KW: flag-kw(height:height),
    KY: flag-ky(height:height),
    KZ: flag-kz(height:height),
    LA: flag-la(height:height),
    LB: flag-lb(height:height),
    LC: flag-lc(height:height),
    LI: flag-li(height:height),
    LK: flag-lk(height:height),
    LR: flag-lr(height:height),
    LS: flag-ls(height:height),
    LT: flag-lt(height:height),
    LU: flag-lu(height:height),
    LV: flag-lv(height:height),
    LY: flag-ly(height:height),
    MA: flag-ma(height:height),
    MC: flag-mc(height:height),
    MD: flag-md(height:height),
    ME: flag-me(height:height),
    MF: flag-mf(height:height),
    MG: flag-mg(height:height),
    MH: flag-mh(height:height),
    MK: flag-mk(height:height),
    ML: flag-ml(height:height),
    MM: flag-mm(height:height),
    MN: flag-mn(height:height),
    MO: flag-mo(height:height),
    MP: flag-mp(height:height),
    MQ: flag-mq(height:height),
    MR: flag-mr(height:height),
    MS: flag-ms(height:height),
    MT: flag-mt(height:height),
    MU: flag-mu(height:height),
    MV: flag-mv(height:height),
    MW: flag-mw(height:height),
    MX: flag-mx(height:height),
    MY: flag-my(height:height),
    MZ: flag-mz(height:height),
    NA: flag-na(height:height),
    NC: flag-nc(height:height),
    NE: flag-ne(height:height),
    NF: flag-nf(height:height),
    NG: flag-ng(height:height),
    NI: flag-ni(height:height),
    NL: flag-nl(height:height),
    NO: flag-no(height:height),
    NP: flag-np(height:height),
    NR: flag-nr(height:height),
    NU: flag-nu(height:height),
    NZ: flag-nz(height:height),
    OM: flag-om(height:height),
    PA: flag-pa(height:height),
    PE: flag-pe(height:height),
    PF: flag-pf(height:height),
    PG: flag-pg(height:height),
    PH: flag-ph(height:height),
    PK: flag-pk(height:height),
    PL: flag-pl(height:height),
    PM: flag-pm(height:height),
    PN: flag-pn(height:height),
    PR: flag-pr(height:height),
    PS: flag-ps(height:height),
    PT: flag-pt(height:height),
    PW: flag-pw(height:height),
    PY: flag-py(height:height),
    QA: flag-qa(height:height),
    RE: flag-re(height:height),
    RO: flag-ro(height:height),
    RS: flag-rs(height:height),
    RU: flag-ru(height:height),
    RW: flag-rw(height:height),
    SA: flag-sa(height:height),
    SB: flag-sb(height:height),
    SC: flag-sc(height:height),
    SD: flag-sd(height:height),
    SE: flag-se(height:height),
    SG: flag-sg(height:height),
    SH: flag-sh(height:height),
    SI: flag-si(height:height),
    SJ: flag-sj(height:height),
    SK: flag-sk(height:height),
    SL: flag-sl(height:height),
    SM: flag-sm(height:height),
    SN: flag-sn(height:height),
    SO: flag-so(height:height),
    SR: flag-sr(height:height),
    SS: flag-ss(height:height),
    ST: flag-st(height:height),
    SV: flag-sv(height:height),
    SX: flag-sx(height:height),
    SY: flag-sy(height:height),
    SZ: flag-sz(height:height),
    TC: flag-tc(height:height),
    TD: flag-td(height:height),
    TF: flag-tf(height:height),
    TG: flag-tg(height:height),
    TH: flag-th(height:height),
    TJ: flag-tj(height:height),
    TK: flag-tk(height:height),
    TL: flag-tl(height:height),
    TM: flag-tm(height:height),
    TN: flag-tn(height:height),
    TO: flag-to(height:height),
    TR: flag-tr(height:height),
    TT: flag-tt(height:height),
    TV: flag-tv(height:height),
    TW: flag-tw(height:height),
    TZ: flag-tz(height:height),
    UA: flag-ua(height:height),
    UG: flag-ug(height:height),
    UM: flag-um(height:height),
    US: flag-us(height:height),
    UY: flag-uy(height:height),
    UZ: flag-uz(height:height),
    VA: flag-va(height:height),
    VC: flag-vc(height:height),
    VE: flag-ve(height:height),
    VG: flag-vg(height:height),
    VI: flag-vi(height:height),
    VN: flag-vn(height:height),
    VU: flag-vu(height:height),
    WF: flag-wf(height:height),
    WS: flag-ws(height:height),
    YE: flag-ye(height:height),
    YT: flag-yt(height:height),
    ZA: flag-za(height:height),
    ZM: flag-zm(height:height),
    ZW: flag-zw(height:height),
    )
  flags.at(upper(iso3166))
}