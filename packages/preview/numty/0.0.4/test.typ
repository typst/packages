#import "main.typ" as nt



#let M = ((1,3), (3,4))
#let N = ((1,5), (1,4))
#let n-DimM = (M,N)

#let u = (1,2,3)
#let v = (3,2,1)
#let a = 1
#let b = 2

= Automatic Tests

== Test data: 

$ M = #M \ N =#N \ u = #u \ v = #v \ a = #a \ b = #b $

=== Logic
  === eq(u,v)
    Checks element wise equality:
    
    // mat mat
    nt.eq(#nt.p(M),#nt.p(N)) = #nt.p(nt.eq(M,N))
    
    // arr arr 
    nt.eq(#u,#v)  -> #nt.eq(u,v)
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
    
  === all(u)
    Check if array only contains true or 1 
    
    //mat
    #nt.all(((true, true),(true,true)))
    
    // arr
    #assert(nt.all((false, true, false)) == false)
    #assert(nt.all((true, true, true)) == true)
    #assert(nt.all((1, 1, 1)) == true)
    #assert(nt.all((0, 0, 0)) == false)
    
    // flt
    #assert(nt.all(true) == true)
    #assert(nt.all(false) == false)
    #assert(nt.all(1) == true)
  
  === all-eq(u)
    Checks all element wise equality:
    //arr
    #assert(nt.all-eq(u,v) == false)
    #assert(nt.all-eq(u,u) == true)

    //flt
    #assert(nt.all-eq(3,3) == true)

  === any(u)
    Checks if any element is true or 1
    // arr
    
    nt.any(#(false, true, false)) -> #true
    #assert(nt.any((false, true, false)) == true)
    #assert(nt.any((false, false, false)) == false)
    #assert(nt.any((0, 0, 1)) == true)

  === isna(u)
    Check if the value is float.na
    //arr
    #assert(nt.isna((1,2)) == (false, false))
    #assert(nt.isna((1,float.nan)) == (false, true))

  === apply(a)
    Applies a function element-wise without changing the shape

  === abs(a)
    Takes the abs of the mat, array, value
    #assert(nt.abs(((1,-1),(1,-4))) == ((1,1),(1,4)))
    
== Types
  //arrarr(a,b)
  === arrarr(u,v)
    Check if a,b are arrays
  #assert(nt.arrarr(u,v) == true)
  #assert(nt.arrarr(a,b) == false)

  === arrflt(u,a)
    check if u is array and a is float
  #assert(nt.arrflt(u,b) == true) 
  #assert(nt.arrflt(b,u) == false) 
  #assert(nt.fltarr(b,u) == true) 
  #assert(nt.fltarr(b,b) == false) 
  #assert(nt.fltflt(b,b) == true) 

== Operators
  === add(u,v)
    Adds matrices vectors numbers
    
    // mat mat
     #nt.add( ((1,3),(1,3)), ((1,1),(1,1)) )

    // mat flt
     #assert(nt.add( ((1,3),(1,3)), 2 ) == ((3,5),(3,5)))
    // arr arr 
     #assert(nt.add((1,3),(1,3))  == (2,6))
   
    // arr float
     #assert(nt.add((1,3),1)  == (2,4))
     #assert(nt.add(1,(1,3))  == (2,4))

    // float float
      #assert(nt.add(1,2) == 3)

  === sub(u,v)
    Substracts matrices 
    
    // arr arr 
      #assert(nt.sub((1,3),(1,3))  == (0,0))
    // arr flt 
      #assert(nt.sub((1,3),2)  == (-1,1))
    //#assert(nt.sub(2,(1,3))  == (1,-1))
      #nt.sub(2,(1,3))
    // flt flt 
      #assert(nt.sub(2,3)  == -1)

  === mult(u,v)
    Multiply two matrices
    // arr arr 
     #assert(nt.mult((1,3),(1,3))  == (1,9))
    // arr flt 
      #assert(nt.mult((1,3),2)  == (2,6))
      #assert(nt.mult(2,(1,3))  == (2,6))
    // flt flt 
      #assert(nt.mult(2,3)  == 6)

  === div(u,v) 
    divide two matrices
    // ndimmat num
      #assert(nt.div((((4,2),(4,2)), ((4,2),(4,2))), 2) == (((2,1),(2,1)), ((2,1),(2,1))))

    // num ndimmat 
      #assert(nt.div(2, (((1,2),(1,2)), ((1,2),(1,2)) )) == (((2,1),(2,1)), ((2,1),(2,1)) ))
    
    // arr arr 
      #assert(nt.div((1,3),(1,3))  == (1,1))
      #assert(nt.div((1,3),(1,0)).at(0)  ==1)
      #assert(nt.div((1,3),(1,0)).at(1).is-nan())
    // arr flt 
      #assert(nt.div((1,3),2)  == (1/2,3/2))
      #assert(nt.div(2,(1,3))  == (2,2/3))
      
    // flt flt 
      #assert(nt.div(2,3) == 2/3)

  === pow(u,v)
    exponentiation of matrices
    // arr arr 
      #assert(nt.pow((1,3),(1,3))  == (1,27))
    // arr flt 
      #assert(nt.pow((1,3),2)  == (1,9))
      #assert(nt.pow(2,(1,3))  == (2,8))
    // flt flt 
      #assert(nt.pow(2,3) == 8)

== Algebra
  // arr 
    #assert(nt.log((1,10, 100)) == (0,1,2))
    //#assert(nt.log((0,10, 100)) == (float.nan,1,2))
    #nt.sin(n-DimM)

  // others:
    #assert(nt.linspace(0,10,3) == (0,5,10))
    #assert(nt.geomspace(1,100,3) == (1,10,100))
    #assert(nt.logspace(1,3,3) == (10,100,1000))

== Matrix
  // matrix
  === transpose
  #N
  
  #assert(nt.transpose(N) == ((1,1),(5,4)))

  === matmul
  
  #N
  
  #M
  
  #assert(nt.matmul(N,M) == ((16,23),(13,19)))

== Print

#nt.print(N) 
#nt.print(M)
#nt.print(nt.matmul(N,M))

#nt.print(u)
