#import "main.typ" as nt

#let u = (1,2,3)
#let v = (3,2,1)
#let a = 1
#let b = 2

// logic
  // eq 
    // arr arr 
    #assert(nt.eq(u,v) == (false, true, false))
    #assert(nt.eq(u,u) == (true, true, true))
  
    // arr float
    #assert(nt.eq(u,a) == (true, false, false))
    #assert(nt.eq(a,u) == (true, false, false))
    
    // flt flt 
    #assert(nt.eq(a,b) == false)
    #assert(nt.eq(a,a) == true)

    // with nan
    #assert(nt.eq((float.nan,1),(float.nan,1), equal-nan:true) == (true,true))
    #assert(nt.eq((float.nan,1),(float.nan,1)) == (false,true))
    
  // all
    // arr
    #assert(nt.all((false, true, false)) == false)
    #assert(nt.all((true, true, true)) == true)
    #assert(nt.all((1, 1, 1)) == true)
    #assert(nt.all((0, 0, 0)) == false)
    
    // flt
    #assert(nt.all(true) == true)
    #assert(nt.all(false) == false)
    #assert(nt.all(1) == true)
  
  // all_eq
    //arr
    #assert(nt.all-eq(u,v) == false)
    #assert(nt.all-eq(u,u) == true)

    //flt
    #assert(nt.all-eq(3,3) == true)

  // any
    // arr
    #assert(nt.any((false, true, false)) == true)
    #assert(nt.any((false, false, false)) == false)
    #assert(nt.any((0, 0, 1)) == true)

  //isna()
    //arr
    #assert(nt.isna((1,2)) == (false, false))
    #assert(nt.isna((1,float.nan)) == (false, true))
    
//types
  //arrarr(a,b)
  #assert(nt.arrarr(u,v) == true)
  #assert(nt.arrarr(a,b) == false)
  #assert(nt.arrflt(u,b) == true) 
  #assert(nt.arrflt(b,u) == false) 
  #assert(nt.fltarr(b,u) == true) 
  #assert(nt.fltarr(b,b) == false) 
  #assert(nt.fltflt(b,b) == true) 

  
//operators
  // add 
    // arr arr 
     #assert(nt.add((1,3),(1,3))  == (2,6))
   
    // arr float
     #assert(nt.add((1,3),1)  == (2,4))
     #assert(nt.add(1,(1,3))  == (2,4))

    // float float
    #assert(nt.add(1,2) == 3)

  // sub
    // arr arr 
      #assert(nt.sub((1,3),(1,3))  == (0,0))
    // arr flt 
      #assert(nt.sub((1,3),2)  == (-1,1))
      #assert(nt.sub(2,(1,3))  == (1,-1))
    // flt flt 
      #assert(nt.sub(2,3)  == -1)

  //mult 
    // arr arr 
     #assert(nt.mult((1,3),(1,3))  == (1,9))
    // arr flt 
      #assert(nt.mult((1,3),2)  == (2,6))
      #assert(nt.mult(2,(1,3))  == (2,6))
    // flt flt 
      #assert(nt.mult(2,3)  == 6)


  //div 
    // arr arr 
     #assert(nt.div((1,3),(1,3))  == (1,1))
     #assert(nt.div((1,3),(1,0)).at(0)  ==1)
     #assert(nt.div((1,3),(1,0)).at(1).is-nan())
    // arr flt 
      #assert(nt.div((1,3),2)  == (1/2,3/2))
      #assert(nt.div(2,(1,3))  == (2,2/3))
      
    // flt flt 
      #assert(nt.div(2,3) == 2/3)

  //pow
    // arr arr 
     #assert(nt.pow((1,3),(1,3))  == (1,27))
    // arr flt 
      #assert(nt.pow((1,3),2)  == (1,9))
      #assert(nt.pow(2,(1,3))  == (2,8))
    // flt flt 
      #assert(nt.pow(2,3) == 8)

// algebra
  // arr 
    #assert(nt.log((1,10, 100)) == (0,1,2))
    //#assert(nt.log((0,10, 100)) == (float.nan,1,2))


// others:
  #assert(nt.linspace(0,10,3) == (0,5,10))
  #assert(nt.geomspace(1,100,3) == (1,10,100))
  #assert(nt.logspace(1,3,3) == (10,100,1000))
