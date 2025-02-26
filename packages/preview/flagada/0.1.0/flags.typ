#let flag_v2(colors,height:.65em,ratio:3/5,color_width:(1/2,)*2) = {
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
          rect(width:100%*color_width.at(0), height: 100%,fill:colors.at(0),),
          rect(width:100%*color_width.at(1), height: 100%,fill:colors.at(1),),
        )
      }
    )
  )
}

#let flag_v3(colors,height:.65em,ratio:2/3,color_width:(1/3,)*3) = {
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
        rect(width:100%*color_width.at(0), height: 100%,fill:colors.at(0),),
        rect(width:100%*color_width.at(1), height: 100%,fill:colors.at(1),),
        rect(width:100%*color_width.at(2), height: 100%,fill:colors.at(2),)
        )
      }
    )
  ) 
}

#let flag_h3(colors,height:.65em,ratio:3/5,color_height:(1/3,)*3) = {
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
        rect(width:100%, height: 100%*color_height.at(0),fill:colors.at(0),stroke:none),
        rect(width:100%, height: 100%*color_height.at(1),fill:colors.at(1),stroke:none),
        rect(width:100%, height: 100%*color_height.at(2),fill:colors.at(2),stroke:none)
        )
      }
    )
  ) 
}

#let flag_cross(colors,height:.65em,x_sets:(5,0,3,0,10),y_sets:(4,0,3,0,4), full_cross:true) = {
  // up to 3 colors and 2 crosses 
  box(
    height:height,
    width:x_sets.sum()/y_sets.sum()*height,
    grid(
      columns: x_sets.map(i=>i*1fr),
      // first line 
      rect(fill:colors.at(0),height: y_sets.at(0)/y_sets.sum()*100%,width: 100%, outset: (bottom: 1pt,right:if full_cross {0pt} else {1pt}),),
      rect(fill:colors.at(1),height: y_sets.at(0)/y_sets.sum()*100%,width: 100%, outset: (bottom: 1pt), stroke:none),
      rect(fill:if full_cross {colors.at(2)} else {colors.at(1)},height: y_sets.at(0)/y_sets.sum()*100%,width: 100%, outset: (bottom: 1pt,x:if full_cross {0pt} else {1pt}),),
      rect(fill:colors.at(1),height: y_sets.at(0)/y_sets.sum()*100%,width: 100%, outset: (bottom: 1pt,x:1pt), stroke:none),
      rect(fill:colors.at(0),height: y_sets.at(0)/y_sets.sum()*100%,width: 100%, outset: (bottom: 1pt,left:1pt)),
      // second line
      rect(fill:colors.at(1),height: y_sets.at(1)/y_sets.sum()*100%,width: 100%, stroke:none),
      rect(fill:colors.at(1),height: y_sets.at(1)/y_sets.sum()*100%,width: 100%, outset: (left:1pt),stroke:none),
      rect(fill:colors.at(2),height: y_sets.at(1)/y_sets.sum()*100%,width: 100%, outset: (bottom: 1pt,)),
      rect(fill:colors.at(1),height: y_sets.at(1)/y_sets.sum()*100%,width: 100%, outset: (x:1pt), stroke:none),
      rect(fill:colors.at(1),height: y_sets.at(1)/y_sets.sum()*100%,width: 100%, stroke:none),
      // middle line
      rect(fill:if full_cross {colors.at(2)} else {colors.at(1)},height: y_sets.at(2)/y_sets.sum()*100%,width: 100%, outset: (y:if full_cross {0pt} else {1pt})),
      rect(fill:colors.at(2),height: y_sets.at(2)/y_sets.sum()*100%,width: 100%, outset: (x:1pt)),
      rect(fill:colors.at(2),height: y_sets.at(2)/y_sets.sum()*100%,width: 100%, outset: (x:1pt,)),
      rect(fill:colors.at(2),height: y_sets.at(2)/y_sets.sum()*100%,width: 100%, outset: (x:1pt)),
      rect(fill:if full_cross {colors.at(2)} else {colors.at(1)},height: y_sets.at(2)/y_sets.sum()*100%,width: 100%, outset: (y:if full_cross {0pt} else {1pt})),
      // penultimate line
      rect(fill:colors.at(1),height: y_sets.at(3)/y_sets.sum()*100%,width: 100%, stroke:none),
      rect(fill:colors.at(1),height: y_sets.at(3)/y_sets.sum()*100%,width: 100%, outset: (left:0pt),stroke:none),
      rect(fill:colors.at(2),height: y_sets.at(3)/y_sets.sum()*100%,width: 100%, outset: (top: 1pt)),
      rect(fill:colors.at(1),height: y_sets.at(3)/y_sets.sum()*100%,width: 100%, outset: (right:0pt),stroke:none),
      rect(fill:colors.at(1),height: y_sets.at(3)/y_sets.sum()*100%,width: 100%, stroke:none),
      // last line 
      rect(fill:colors.at(0),height: y_sets.at(4)/y_sets.sum()*100%,width: 100%, outset: (top:if full_cross {0pt} else {1pt}, right: if full_cross {0pt} else {1pt}),),
      rect(fill:colors.at(1),height: y_sets.at(4)/y_sets.sum()*100%,width: 100%, outset: (top:1pt), stroke:none),
      rect(fill:if full_cross {colors.at(2)} else {colors.at(1)},height: y_sets.at(4)/y_sets.sum()*100%,width: 100%, outset: (top:1pt,x:if full_cross {0pt} else {1pt}),),
      rect(fill:colors.at(1),height: y_sets.at(4)/y_sets.sum()*100%,width: 100%, outset: (top:1pt), stroke:none),
      rect(fill:colors.at(0),height: y_sets.at(4)/y_sets.sum()*100%,width: 100%, outset: (top:if full_cross {0pt} else {1pt}, left: if full_cross {0pt} else {1pt}),),
    )
  ) 
}
// 
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
#let flag_ad(height:.65em) = {
  box(
    flag_v3(
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
#let flag_ae(height:.65em) = {
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
// ag 2:3
#let flag_ag(height:.65em) = {
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
#let flag_al(height:.65em) = {
  rect(height: height, width: 7/5*height, inset:0pt, fill:red,image("coat of arms/AL.svg",width: 100%))
}
// am 2:1
#let flag_am(height:.65em) = {
  flag_h3((rgb(217,0,18),rgb(0,51,160),rgb(242,168,0)), height: height, color_height: (1/3,1/3,1/3), ratio: 1/2)
}
// ao 2:3
#let flag_ao(height:.65em) = {
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
// ar 5:8
#let flag_ar(height:.65em) = {
  box(
    flag_h3((rgb("74acdf"),white,rgb("74acdf")),ratio: 5/8, height: height)
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
// at 2:3
#let flag_at(height:.65em) = {
  flag_h3((rgb(200,16,46),white,rgb(200,16,46)),height: height, ratio:2/3)
}
// az 
#let flag_az(height:.65em) = {
  box(
    flag_h3((rgb(0,181,226),rgb(239,51,64),rgb(80,158,47)),height: height, ratio:2/3)
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
#let flag_ba(height:.65em) = {
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
#let flag_bb(height:.65em) = {
  box(
    flag_v3((rgb(0,38,127),rgb(255,199,38),rgb(0,38,127)), height:height, ratio: 2/3)
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
#let flag_bd(height:.65em) = {
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
#let flag_be(height:.65em) = {
  flag_v3((rgb(0,0,0),rgb(255,233,54),rgb(255,15,33)), height:height)
}
// bf 2:3?
#let flag_bf(height:.65em) = {
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
#let flag_bg(height:.65em) = {
  flag_h3((rgb("FFFFFF"),rgb(0,155,117),rgb(208,28,31)),height: height, ratio:3/5)
}
// bh 3:5
#let flag_bh(height:.65em) = {
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
#let flag_bi(height:.65em) = {
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
#let flag_bj(height:.65em) = {
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
// bn 1:2
#let flag_bn(height:.65em) = {
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
#let flag_bo(height:.65em) = {
  box(
    flag_h3((rgb(213,43,30),rgb(252,209,22),rgb(0,121,52)),height: height, ratio:15/22)
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
#let flag_br(height:.65em) = {
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
#let flag_bs(height:.65em) = {
  box(
    flag_h3((rgb(0,119,139),rgb(255,199,44), rgb(0,119,139)),height: height, ratio:1/2, color_height: (1/3,1/3,1/3))
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
#let flag_bt(height:.65em) = {
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
#let flag_bw(height:.65em) = {
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
#let flag_by(height:.65em) = {
  box(
    flag_h3((rgb(0,151,57),rgb(210,39,48), none),height: height, ratio:1/2, color_height: (2/3,1/3,0))
    + place(
      dy:-height,
      image("coat of arms/BY.svg", height: height)
    )
    )
}
// bz coat of arms 3:5
#let flag_bz(height:.65em) = {
  box(
    flag_h3((rgb("d90f19"),rgb("171696"),rgb("d90f19")), height: height,ratio:3/5,color_height: (1/10,8/10,1/10))
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
#let flag_ca(height:.65em) = {
  box(
    flag_v3((rgb("ed1c24"),white,rgb("ed1c24")), height:height, color_width: (1/4,1/2,1/4), ratio: 1/2)
    + place(
      dx:(1/2+1/7)*height,
      dy:(-1+1/8)*height,
      image("coat of arms/CA.svg", height: 3/4*height)
    )
    //+ place(dy:-height/2,line(length: 2*height))
    //+ place(dy:-height/2, dx:height/2,rotate(90deg,line(length: height)))
  )
}
// cd 4:3
#let flag_cd(height:.65em) = {
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
#let flag_cf(height:.65em) = {
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
#let flag_cg(height:.65em) = {
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
// ch 5:5
#let flag_ch(height:.65em) = {
  flag_cross((rgb(200,16,46),rgb(200,16,46),white), height:height,x_sets: (1,1,1,1,1),y_sets: (1,1,1,1,1), full_cross: false)
}
// ci 2:3
#let flag_ci(height:.65em) = {
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
#let flag_cl(height:.65em) = {
  box(
    flag_h3((white,rgb(213,43,30),none),color_height: (1/2,1/2,0),ratio:2/3, height: height)
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
#let flag_cm(height:.65em) = {
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
#let flag_cn(height:.65em) = {
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
#let flag_co(height:.65em) = {
  box(
    flag_h3((rgb("FFCD00"),rgb("003087"),rgb("C8102E")),color_height: (1/2,1/4,1/4), height: height, ratio:2/3)
  )
}
// cr 3:5
#let flag_cr(height:.65em) = {
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
#let flag_cu(height:.65em) = {
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
#let flag_cv(height:.65em) = {
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
// cy 3/5
#let flag_cy(height:.65em) = {
  //align(left,
    rect(
      height: height,
      width: height*5/3, 
      inset: 0pt,
      fill:white,
      align(center+horizon,
      image("coat of arms/CY.svg")
      ))
    //)
}
// cz
#let flag_cz(height:.65em) = {
  box(
    flag_h3((white,cmyk(0%, 100%, 96%, 8%),none),height: height,color_height: (1/2,1/2,0), ratio:2/3)+
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
#let flag_de(height:.65em) = {
  flag_h3((rgb("000000"),rgb("FF0000"), rgb("FFCC00")),height: height)
}
// dj 2:3?
#let flag_dj(height:.65em) = {
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
// do 
#let flag_do(height:.65em) = {
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
// dk 28:37
#let flag_dk(height:.65em) = {
  flag_cross((rgb(200,16,46),none,white),height: height, x_sets: (12,0,4,0,21),y_sets: (12,0,4,0,12)) 
}
// dz 2:3
#let flag_dz(height:.65em) = {
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
#let flag_ec(height:.65em) = {
  box(
    flag_h3((rgb("FFDD00"),rgb("034ea2"),rgb("ed1c24")),color_height: (1/2,1/4,1/4), height: height, ratio:2/3)
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
#let flag_ee(height:.65em) = {
  flag_h3((rgb("0072ce"),rgb("000000"),white),height: height, ratio:7/11)
}
// eg 
#let flag_eg(height:.65em) = {
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
// er 1:2
#let flag_er(height:.65em) = {
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
#let flag_es(height:.65em) = {
  box(
    flag_h3((rgb("AD1519"),rgb("FABD00"),rgb("AD1519")), height:height,color_height: (1/4,1/2,1/4),ratio:2/3)+place(
      // coat of arms
      dx:height*30%,
      dy:height*-72%,
      image("coat of arms/ES.svg", width:3/8*height)
    )
  )
}
// et 1:2
#let flag_et(height:.65em) = {
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
#let flag_eu(height:.65em) = {
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
#let flag_fi(height:.65em) = {
  flag_cross((white,none,blue), height: height, x_sets: (5,0,3,0,10), y_sets: (4,0,3,0,4) )
}
// fr 2:3
#let flag_fr(height:.65em) = {
  flag_v3((rgb(0,85,164),white,rgb(239,65,53)), height:height)
}
// ga 3:4
#let flag_ga(height:.65em) = {
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
#let flag_gb(height:.65em) = {
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
}
// au 1:2
#let flag_au(height:.65em) = {
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
      flag_gb(height:height/2)
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
// ge 2:3
#let flag_ge(height:65em) = {
  box(
    flag_cross((white,none,red),height:height, x_sets: (130,0,40,0,130), y_sets: (80,0,40,0,80))
    +place(dy:-180/200*100%, dx:10%,text(red, size: height/3,[\u{2720}]))
    +place(dy:-60/200*100%, dx:10%,text(red, size: height/3,[\u{2720}]))
    +place(dy:-180/200*100%, dx:65%,text(red, size: height/3,[\u{2720}]))
    +place(dy:-60/200*100%, dx:65%,text(red, size: height/3,[\u{2720}]))
  )
}
// gh 2:3
#let flag_gh(height:.65em) = {
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
// gm 2:3
#let flag_gm(height:.65em) = {
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
#let flag_gn(height:.65em) = {
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
// gq 2:3
#let flag_gq(height:.65em) = {
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
#let flag_gr(height:.65em) = {
  box(
  stack(
    dir:ttb,
    flag_h3((rgb("004C98"),white,rgb("004C98")),height: height/3,color_height: (1/3,1/3,1/3), ratio:2/9),
    flag_h3((white,rgb("004C98"),white),height: height/3,color_height: (1/3,1/3,1/3), ratio:2/9),
    flag_h3((rgb("004C98"),white,rgb("004C98")),height: height/3,color_height: (1/3,1/3,1/3), ratio:2/9),
  )+place(
      dy:-height,
      flag_cross((rgb("004C98"),rgb("004C98"),white),height: height*10/18, x_sets: (1,1,1,1,1),y_sets: (1,1,1,1,1),)
    )
  )
}
// gt 5:8
#let flag_gt(height:.65em) = {
  box(
    flag_v3((blue,white,blue), height: height, ratio: 5/8)
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
// gw 1:2
#let flag_gw(height:.65em) = {
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
// hn 1:2
#let flag_hn(height:.65em) = {
  box(
    flag_h3((rgb(0, 188, 228),rgb(255,255,255),rgb(0, 188, 228)),height: height,ratio: 1/2)
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
#let flag_gy(height:.65em) = {
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
#let flag_hr(height:.65em) = {
  box(flag_h3((rgb(255, 0, 0),rgb(255,255,255),rgb(23, 23, 150)),height: height,ratio: 1/2)+place(
    // coat of arms
    dx:height*80%,
    dy:height*-84.2%,
    image("coat of arms/HR.svg", width:5/24*2*height)
  )
  )
}
// ht 3:5
#let flag_ht(height:.65em) = {
  box(
    flag_h3((rgb("00209f"),rgb("d21034"),none),color_height: (1/2,1/2,0), height: height, ratio:3/5)
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
#let flag_hu(height:.65em) = {
  flag_h3((rgb(206, 41, 57),rgb(255,255,255),rgb(71, 112, 80)),height: height,ratio: 1/2)
}
// id 2:3
#let flag_id(height:.65em) = {
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
#let flag_ie(height:.65em) = {
  flag_v3((rgb(22, 155, 98),rgb(255,255,255),rgb(255,136,62)), height:height, ratio:1/2)
}
// il 8:11
#let flag_il(height:.65em) = {
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
// in 2:3
#let flag_in(height:.65em) = {
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
// iq 2:3
#let flag_iq(height:.65em) = {
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
#let flag_ir(height:.65em) = {
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
// is 
#let flag_is(height:.65em) = {
  flag_cross((rgb("02529C"),rgb("FFFFFF"),rgb("DC1E35")),height: height,x_sets: (7,1,2,1,14),y_sets: (7,1,2,1,7))
}
// it 2:3
#let flag_it(height:.65em) = {
  flag_v3((rgb(0,146,70),rgb(241,242,241),rgb(206,43,55)), height:height)
}
// jm
#let flag_jm(height:.65em) = {
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
#let flag_jo(height:.65em) = {
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
#let flag_jp(height:.65em) = {
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
#let flag_ke(height:.65em) = {
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
// kh
#let flag_kh(height:.65em) = {
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
// km 3:5
#let flag_km(height:.65em) = {
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
// kp
#let flag_kp(height:.65em) = {
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
#let flag_kr(height:.65em) = {
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
#let flag_kw(height:.65em) = {
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
// la 2:3
#let flag_la(height:.65cm) = {
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
#let flag_lb(height:.65cm) = {
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
// li 3:5
#let flag_li(height:.65em) = {
  box(
    flag_h3((rgb(0,39,128),rgb(207,9,33),none),height: height,ratio:3/5,color_height: (1/2,1/2,0))+place(
      // coat of arms
      dx:height*40%,
      dy:height*-92%,
      image("coat of arms/LI.png", width:5/3/4*height)
    )
  )
// lt 7:11
}
// lk 1:2
#let flag_lk(height:.65em) = {
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
#let flag_lr(height:.65em) = {
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
#let flag_ls(height:.65em) = {
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
// lt
#let flag_lt(height:.65em) = {
  flag_h3((rgb("fdb913"),rgb("006a44"),rgb("c1272d")),height: height,ratio:7/11)
}
// lu 3:5
#let flag_lu(height:.65em) = {
  flag_h3((rgb(199,63,74),white,rgb(0,137,182)),height: height)
}
// lv 7:11
#let flag_lv(height:.65em) = {
  flag_h3((rgb(158, 27, 52),rgb("FFFFFF"),rgb(158, 27, 52)),height: height,ratio:1/2,color_height:(2/5,1/5,2/5))
}
// ly 1:2?
#let flag_ly(height:.65em) = {
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
#let flag_ma(height:.65em) = {
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
#let flag_mc(height:.65em) = {
  flag_h3((rgb("CF142B"),rgb("FFFFFF"),none), color_height: (1/2,1/2,0), height:height)
}
// md 1:2
#let flag_md(height:.65em)={
  box(
    flag_v3((rgb("0046ae"),rgb("ffd200"),rgb("cc092f")),height: height, ratio:1/2, color_width: (1/3,1/3,1/3))
    +place(dy:-76.8%*height, dx:(1-2/10)*height,image("coat of arms/MD.svg", width:2/5*height))
    //+place(dy:-50%*height,line(length:height*2))
    //+place(dy:-50%*height, dx:height/2,rotate(90deg,line(length:height)))
  )
}
// me 1:2
#let flag_me(height:.65em) = {
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
// mg 2:3
#let flag_mg(height:.65em) = {
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
// mk 1:2
#let flag_mk(height:.65em) = {
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
}
// ml 2:3
#let flag_ml(height:.65em) = {
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
#let flag_mm(height:.65em) = {
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
#let flag_mn(height:.65em) = {
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
// mr 2:3
#let flag_mr(height:.65em) = {
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
// mt 2:3 coat of arms
#let flag_mt(height:.65em) = {
  box(
    flag_v2((rgb("FFFFFF"),rgb("CF142B")),height: height, ratio:2/3)+place(
    dx:(81/648-(112/648)/2)*height,
    dy:(81/432-(112/432)/2-1)*height,
    image("coat of arms/MT.svg", height:112/432*height
    ))
    )
}
// mu 2:3
#let flag_mu(height:.65em) = {
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
#let flag_mv(height:.65em) = {
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
#let flag_mw(height:.65em) = {
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
#let flag_mx(height:.65em) = {
  box(
    flag_v3((rgb(0,104,71),white,rgb(206,17,38)), height: height, ratio:4/7)
    +place(
      dy:-2/3*height,
      dx:2/3*height,
      image("coat of arms/MX.svg", width:7/16*height)
      )
  )
}
// my 1:2
#let flag_my(height:.65em) = {
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
#let flag_mz(height:.65em) = {
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
#let flag_na(height:.65em) = {
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
// ne 6:7?
#let flag_ne(height:.65em) = {
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
// ng 1:2?
#let flag_ng(height:.65em) = {
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
#let flag_ni(height:.65em) = {
  box(
    flag_h3((rgb("0080FF"),rgb(255,255,255),rgb("0080FF")),height: height,ratio: 3/5)
    + place(
        dy:-66%,
        dx:40%*5/3*height,
      image("coat of arms/NI.svg", height:height/3.1)
    )
  )
}
// nl 2:3
#let flag_nl(height:.65em) = {
  flag_h3((rgb(173,29,37),white,rgb(30,71,133)),height: height, ratio:2/3)
}
// no 
#let flag_no(height:.65em) = {
  flag_cross((rgb("BA0C2F"),rgb("FFFFFF"),rgb("00205B")),height: height,x_sets: (6,1,2,1,12),y_sets: (6,1,2,1,6))
}
// np 4/3:1
#let flag_np(height:.65em) = {
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
// nz 1:2
#let flag_nz(height:.65em) = {
  box(
    rect(
      height: height,
      width: 2*height,
      fill:rgb("012169")
    )
    + place(
      top,
      flag_gb(height:height/2)
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
#let flag_om(height:.65em) = {
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
#let flag_pa(height:.65em) = {
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
#let flag_pe(height:.65em) = {
  box(
    flag_v3((rgb(217,16,35),white,rgb(217,16,35)), height:height,ratio:2/3)
  )
}
// ph 1:2
#let flag_ph(height:.65em) = {
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
#let flag_pk(height:.65em) = {
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
#let flag_pl(height:.65em) = {
  flag_h3((rgb("EEEEEE"),rgb("D4213D"),none),height: height, ratio:5/8,color_height: (1/2,1/2,0))
}
// ps 1:2
#let flag_ps(height:.65em) = {
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
#let flag_pt(height:.65em) = {
  box(flag_v2((rgb("006600"),rgb("FF0000")),height: height, ratio:2/3, color_width: (2/5,3/5))+place(
    // coat of arms
    dx:(2/5)*height,
    dy:-2/3*height,
    image("coat of arms/PT.svg", width:7/35*2*height)
  )
  )
}
// py 3:5 coat of arms
#let flag_py(height:.65em) = {
  box(
    flag_h3((rgb("d52b1e"),white,rgb("0038a8")),height:height, ratio:3/5)
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
#let flag_qa(height:.65em) = {
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
// ro 2:3
#let flag_ro(height:.65em) = {
  flag_v3((rgb("002b7f"),rgb("fcd116"),rgb("ce1126")),height: height, ratio:2/3, color_width: (1/3,1/3,1/3))
}
// rs 2:3
#let flag_rs(height:.65em) = {
  box(
    flag_h3((cmyk(0%, 90%, 70%, 10%),rgb("0C4077"),rgb("FFFFFF")),height: height, ratio:2/3)
    +place(
      dx:2/3*height/2,
      dy:-(1-2/18)*height,
      image("coat of arms/RS.svg", width:2/3*height/2, ))
    )
}
// ru 2:3
#let flag_ru(height:.65em) = {
  flag_h3((white,rgb("0039A6"),rgb("D52b1e")), ratio:2/3, height: height)
}
// rw 2:3
#let flag_rw(height:.65em) = {
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
#let flag_sa(height:.65em) = {
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
// sc 1:2
#let flag_sc(height:.65em) = {
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
#let flag_sd(height:.65em) = {
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
#let flag_se(height:.65em) = {
  flag_cross((rgb("005293"),none,rgb("FFCD00")),height: height,x_sets: (5,0,2,0,9),y_sets: (4,0,2,0,4))
}
// sg 
#let flag_sg(height:.65em) = {
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
// si 1:2
#let flag_si(height:.65em) = {
  box(
    flag_h3((white,rgb("#0004e6e0"),cmyk(0%,100%,100%,0%)),height: height,ratio: 1/2)
    + place(
        dy:-(1-1/6)*height,
        dx:1.5/6*height,
        image("coat of arms/SI.svg",height:height/3)
      )
    )
}
// sk 2:3
#let flag_sk(height:.65em) = {
  box(
    flag_h3((white,rgb("0b4ea2"),rgb("ee1c25")),height: height,ratio: 2/3)
    + place(dy:(-1+15/60)*height, dx:15/90*height,image("coat of arms/SK.svg", height:height/2))
  )
}
// sl 2:3
#let flag_sl(height:.65em) = {
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
#let flag_sm(height:.65em) = {
  box(
    flag_h3((white,cmyk(55%,10%,5%,0%),none),height: height,ratio: 3/4,color_height: (1/2,1/2,0))
    + place(
        dy:-(1-5/18)*height,
        dx:1/2*height,
        image("coat of arms/SM.svg",height:height*3/8)
      )
    )
}
// sn 2:3?
#let flag_sn(height:.65em) = {
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
#let flag_so(height:.65em) = {
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
#let flag_sr(height:.65em) = {
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
#let flag_ss(height:.65em) = {
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
#let flag_st(height:.65em) = {
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
// sy 2:3
#let flag_sy(height:.65em) = {
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
#let flag_sz(height:.65em) = {
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
#let flag_ua(height:.65em) = {
  flag_h3((rgb("0057b8"),rgb("ffd700"),none), height: height, color_height: (1/2,1/2,0), ratio: 2/3)
}
// ug 2:3
#let flag_ug(height:.65em) = {
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
#let flag_us(height:.65em) = {
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
#let flag_uy(height:.65em) = {
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
// td 2:3
#let flag_td(height:.65em) = {
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
// tg 1:phi
#let flag_tg(height:.65em) = {
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
#let flag_th(height:.65em) = {
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
// tl 1:2
#let flag_tl(height:.65em) = {
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
// tn 2:3
#let flag_tn(height:.65em) = {
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
// tr
#let flag_tr(height:.65em) = {
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
// tw 2:3
#let flag_tw(height:.65em) = {
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
#let flag_tz(height:.65em) = {
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
// va 1:1 
#let flag_va(height:.65em) = {
  box(
    flag_v2((rgb(255,242,0),white),height: height, ratio:1, color_width: (1/2,1/2))
    +place(
      // coat of arms
      dx:(13/22)*height,
      dy:-16/22*height,
      image("coat of arms/VA.svg", width:1/3*height)
    )
  )
}
// ve 2:3
#let flag_ve(height:.65em) = {
  box(
    flag_h3((rgb("FFCD00"),rgb("003087"),rgb("C8102E")),height:height, ratio:2/3)+
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
// vn
#let flag_vn(height:.65em) = {
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
// ye
#let flag_ye(height:.65em) = {
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
// za 
#let flag_za(height:.65em) = {
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
#let flag_zm(height:.65em) = {
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
#let flag_zw(height:.65em) = {
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
// example
#let flag_zz(height:.65em) = {
  box(
    rect(
      height: height,
      width: 3/2*height,
    )
  )
}

// Make the iso3166 flag function 
#let flag(iso3166, height:.65em,) = {
  assert(iso3166.len()==2 and type(iso3166)==str,message: "iso3166 code should be a string of 2 letters")
  let flags = (
    AD: flag_ad(height:height),
    AE: flag_ae(height:height),
    AG: flag_ag(height:height),
    AL: flag_al(height:height),
    AM: flag_am(height:height),
    AO: flag_ao(height:height),
    AR: flag_ar(height:height),
    AT: flag_at(height:height),
    AU: flag_au(height:height),
    AZ: flag_az(height:height),
    BA: flag_ba(height:height),
    BB: flag_bb(height:height),
    BD: flag_bd(height:height),
    BE: flag_be(height:height),
    BF: flag_bf(height:height),
    BG: flag_bg(height:height),
    BH: flag_bh(height:height),
    BI: flag_bi(height:height),
    BJ: flag_bj(height:height),
    BN: flag_bn(height:height),
    BO: flag_bo(height:height),
    BR: flag_br(height:height),
    BS: flag_bs(height:height),
    BT: flag_bt(height:height),
    BW: flag_bw(height:height),
    BY: flag_by(height:height),
    BZ: flag_bz(height:height),
    CA: flag_ca(height:height),
    CD: flag_cd(height:height),
    CF: flag_cf(height:height),
    CG: flag_cg(height:height),
    CH: flag_ch(height:height),
    CI: flag_ci(height:height),
    CL: flag_cl(height:height),
    CM: flag_cm(height:height),
    CN: flag_cn(height:height),
    CO: flag_co(height:height),
    CR: flag_cr(height:height),
    CU: flag_cu(height:height),
    CV: flag_cv(height:height),
    CY: flag_cy(height:height),
    CZ: flag_cz(height:height),
    DE: flag_de(height:height),
    DJ: flag_dj(height:height),
    DK: flag_dk(height:height),
    DO: flag_do(height:height),
    DZ: flag_dz(height:height),
    EC: flag_ec(height:height),
    EE: flag_ee(height:height),
    EG: flag_eg(height:height),
    ER: flag_er(height:height),
    ES: flag_es(height:height),
    ET: flag_et(height:height),
    EU: flag_eu(height:height),
    FI: flag_fi(height:height),
    FR: flag_fr(height:height),
    GA: flag_ga(height:height),
    GB: flag_gb(height:height),
    GE: flag_ge(height:height),
    GH: flag_gh(height:height),
    GM: flag_gm(height:height),
    GN: flag_gn(height:height),
    GQ: flag_gq(height:height),
    GR: flag_gr(height:height),
    GT: flag_gt(height:height),
    GY: flag_gy(height:height),
    GW: flag_gw(height:height),
    HN: flag_hn(height:height),
    HR: flag_hr(height:height),
    HT: flag_ht(height:height),
    HU: flag_hu(height:height),
    ID: flag_id(height:height),
    IE: flag_ie(height:height),
    IL: flag_il(height:height),
    IN: flag_in(height:height),
    IQ: flag_iq(height:height),
    IR: flag_ir(height:height),
    IS: flag_is(height:height),
    IT: flag_it(height:height),
    JM: flag_jm(height:height),
    JO: flag_jo(height:height),
    JP: flag_jp(height:height),
    KE: flag_ke(height:height),
    KH: flag_kh(height:height),
    KM: flag_km(height:height),
    KP: flag_kp(height:height),
    KR: flag_kr(height:height),
    KW: flag_kw(height:height),
    LA: flag_la(height:height),
    LB: flag_lb(height:height),
    LI: flag_li(height:height),
    LK: flag_lk(height:height),
    LR: flag_lr(height:height),
    LS: flag_ls(height:height),
    LT: flag_lt(height:height),
    LU: flag_lu(height:height),
    LV: flag_lv(height:height),
    LY: flag_ly(height:height),
    MA: flag_ma(height:height),
    MC: flag_mc(height:height),
    MD: flag_md(height:height),
    ME: flag_me(height:height),
    MG: flag_mg(height:height),
    MK: flag_mk(height:height),
    ML: flag_ml(height:height),
    MM: flag_mm(height:height),
    MN: flag_mn(height:height),
    MR: flag_mr(height:height),
    MT: flag_mt(height:height),
    MU: flag_mu(height:height),
    MV: flag_mv(height:height),
    MW: flag_mw(height:height),
    MX: flag_mx(height:height),
    MY: flag_my(height:height),
    MZ: flag_mz(height:height),
    NA: flag_na(height:height),
    NE: flag_ne(height:height),
    NG: flag_ng(height:height),
    NI: flag_ni(height:height),
    NL: flag_nl(height:height),
    NO: flag_no(height:height),
    NP: flag_np(height:height),
    NZ: flag_nz(height:height),
    OM: flag_om(height:height),
    PA: flag_pa(height:height),
    PE: flag_pe(height:height),
    PH: flag_ph(height:height),
    PK: flag_pk(height:height),
    PL: flag_pl(height:height),
    PS: flag_ps(height:height),
    PT: flag_pt(height:height),
    PY: flag_py(height:height),
    QA: flag_qa(height:height),
    RO: flag_ro(height:height),
    RS: flag_rs(height:height),
    RU: flag_ru(height:height),
    RW: flag_rw(height:height),
    SA: flag_sa(height:height),
    SD: flag_sd(height:height),
    SC: flag_sc(height:height),
    SE: flag_se(height:height),
    SG: flag_sg(height:height),
    SI: flag_si(height:height),
    SK: flag_sk(height:height),
    SL: flag_sl(height:height),
    SM: flag_sm(height:height),
    SN: flag_sn(height:height),
    SO: flag_so(height:height),
    SR: flag_sr(height:height),
    SS: flag_ss(height:height),
    ST: flag_st(height:height),
    SY: flag_sy(height:height),
    SZ: flag_sz(height:height),
    TD: flag_td(height:height),
    TG: flag_tg(height:height),
    TH: flag_th(height:height),
    TL: flag_tl(height:height),
    TN: flag_tn(height:height),
    TR: flag_tr(height:height),
    TW: flag_tw(height:height),
    TZ: flag_tz(height:height),
    UA: flag_ua(height:height),
    UG: flag_ug(height:height),
    US: flag_us(height:height),
    UY: flag_uy(height:height),
    VA: flag_va(height:height),
    VE: flag_ve(height:height),
    VN: flag_vn(height:height),
    YE: flag_ye(height:height),
    ZA: flag_za(height:height),
    ZM: flag_zm(height:height),
    ZW: flag_zw(height:height),
    )
  flags.at(upper(iso3166))
}