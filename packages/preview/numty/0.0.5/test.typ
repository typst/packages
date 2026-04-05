#import "main.typ" as nt
#import "main.typ": r,c


#let M = ((1,3), (3,4))
#let N = ((1,5), (1,4))
#let n-DimM = (M,N)

#let u = (1,2,3)
#let v = (3,2,1)
#let a = 1
#let b = 2

#let testf(name, f, ..args, assertion: none) = {
    // unfortunatelly f is not aware of his own name, 
    // and eval scope is out of nt, not sure how to include it
    assert(f(..args) == assertion)
    [#name ( #nt.p(..args, "= ", assertion) ]
}

= Automatic Tests

== Test data: 

$ M = #M \ N =#N \ u = #u \ v = #v \ a = #a \ b = #b $


== Print

  For now print default to col vectors, that may change, as it is still an experimental API, but be mindful that 1d is considered col by default use nt.c and nt.r to convert them.

  Small print

  #let u = (1,2,3)
  #let v = (3,2,1)
  
  // matrix 
  #nt.p("N M = ",N, M , nt.matmul(N,M)) 

  #nt.p((N,M,M).reduce(nt.matmul))
  

  #let S = ((1,2, 4), (3,4, 5) )
  #let K = ((1,2), (3,4), (4,2) )
  
  #nt.p("S K = ", S, K , nt.matmul(S, K) )
  #nt.p("K S = ", K, S , nt.matmul(K, S) )
  
  // matrix
  #nt.p("u_c v_r = ",  c(..v), r(..u), " = ", nt.matmul(c(..v), r(..u))) 
  
  Big print:
  
  #nt.print("N M = ", N, M , nt.matmul(N,M)) 

=== Logic
  === eq(u,v)
    Checks element wise equality:
    
    // mat mat
    eq(#nt.p(M,N, " = ", nt.eq(M,N))
    
    // arr arr 
    eq#nt.p(u,v)  #nt.eq(u,v) //
    
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
    all#nt.p(((true, true),(true,true))) = #nt.all(((true, true),(true,true)))
    
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

  === is-1d
    Checks if u is normal array or 1d mat 

    #assert(nt.is-1d( (1,2)  ) == true) 
    #assert(nt.is-1d( r(1,2) ) == true) 
    #assert(nt.is-1d( c(1,2) ) == true) 
    #assert(nt.is-1d( ((1,2), (2,3)) )  == false) 

  === is-1d-arr
    Check if is a typst 1d array, no nested 

    #assert(nt.is-1d-arr( (1,2)  ) == true) 
    #assert(nt.is-1d-arr( r(1,2) ) == false) 
    #assert(nt.is-1d-arr( c(1,2) ) == false) 
    #assert(nt.is-1d-arr( ((1,2), (2,3)) )  == false) 


== Operators
  === add(u,v)
    Adds matrices vectors numbers:
    
    #let A = ((1,3),(1,3))
    #let B = ((1,3),(1,5))
    // mat mat
     #nt.p(A,B) = #nt.p(nt.add(A, B))
    
     #testf("add", nt.add, A,B, assertion: nt.add(A, B))
     
     #testf("add", nt.add, u,v, assertion: (4,4,4))
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
  
  #nt.p(N)
  
  #assert(nt.transpose(N) == ((1,1),(5,4)))

  === matmul

  Tests: 
  
  #nt.p(N)  #nt.p(M) =   #nt.p(nt.matmul(N,M))
  #assert(nt.matmul(N,M) == ((16,23),(13,19)))

  #nt.p( (1,3), )) #nt.p( ((16,23),(13,19)) ) 
  #nt.p( nt.matmul( ((1,3)),  ((16,23),(13,19)) ))
  
  #nt.matmul(((16,23),(13,19)), ((1,), (2,)))
  //#nt.transpose(((1,3)))
  #( (1,), (2, ))
  
  #((1,2,),)

  #nt.r(1,2)
  #nt.c(1,2)

  transpose:
  #nt.r(1,2)
  
  #nt.p(r(1,2))
  //#nt.p(r(1,2))

  #nt.p( ((1,2),(3,4)) ) #nt.p(c(1,2) ) 
  #nt.p(nt.matmul( ((1,2),(3,4)), c(1,2) ))

  #nt.p(r(1,2)) 
  #nt.p(nt.matmul(c(1,2), ((1,2),(3,4)) ))
  
  #nt.transpose(c(1,2))

  == det

  Only 2x2 for now
  
  #M
  
  #nt.det(M)

  == trace
  
  #nt.trace(M)
  
  

#pagebreak()
