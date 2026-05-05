import std/unittest

import sat/[sat, satvars]

suite "sat tests":
  test "test1":
    var b: Builder
    b.openOpr(AndForm)

    b.openOpr(OrForm)
    b.add newVar(VarId 1)
    b.add newVar(VarId 2)
    b.add newVar(VarId 3)
    b.add newVar(VarId 4)
    b.closeOpr

    b.openOpr(ExactlyOneOfForm)
    b.add newVar(VarId 5)
    b.add newVar(VarId 6)
    b.add newVar(VarId 7)

    #b.openOpr(NotForm)
    b.add newVar(VarId 8)
    #b.closeOpr
    b.closeOpr

    b.add newVar(VarId 5)
    b.add newVar(VarId 6)
    b.closeOpr

    let f = toForm(b)
    echo "original: "
    echo f

    let m = maxVariable(f)
    var s = createSolution(m)
    let res = satisfiable(f, s)
    check res == false
    echo "is solvable? ", res
    echo "solution"
    for i in 0..<m:
      echo "v", i, " ", s.getVar(VarId(i))
      check s.getVar(VarId(i)) == 0

  test "test2":
    var b: Builder
    b.openOpr(AndForm)

    b.openOpr(OrForm)
    b.add newVar(VarId 9)

    b.openOpr(OrForm)
    b.add newVar(VarId 1)
    b.add newVar(VarId 2)
    b.add newVar(VarId 3)
    b.add newVar(VarId 4)
    b.closeOpr # OrForm
    b.closeOpr # OrForm

    b.openOpr(ExactlyOneOfForm)
    b.add newVar(VarId 5)
    b.add newVar(VarId 6)
    b.add newVar(VarId 7)

    #b.openOpr(NotForm)
    b.add newVar(VarId 8)
    #b.closeOpr
    b.closeOpr

    b.add newVar(VarId 6)
    b.add newVar(VarId 1)
    b.closeOpr

    let f = toForm(b)
    echo "original: "
    echo f

    let m = maxVariable(f)
    var s = createSolution(m)
    let res = satisfiable(f, s)
    check res == true
    echo "is solvable? ", res
    let expected = @[ 0'u64, 1, 0, 0, 0, 2, 1, 2, 2, 2]
    echo "solution"
    for i in 0..<m:
      let v = s.getVar(VarId(i))
      echo "v", i, " ", v
      check v == expected[i]

  const
    myFormularU = """(&v0 v1 (~v5) (<->v0 (1==v6)) (<->v1 (1==v7 v8)) (<->v2 (1==v9 v10)) (<->v3 (1==v11)) (<->v4 (1==v12 v13)) (<->v14 (1==v8 v7)) (<->v15 (1==v9)) (<->v16 (1==v10 v9)) (<->v17 (1==v11)) (<->v18 (1==v11)) (<->v19 (1==v13)) (|(~v6) v14) (|(~v7) v15) (|(~v8) v16) (|(~v9) v17) (|(~v10) v18) (|(~v11) v19) (|(~v12) v20))"""
    myFormular = """(&(1==v0) (1==v1) (1>=v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13)
  (1>=v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28)
  (1>=v29 v30 v31) (1>=v32)
  (1>=v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58)
  (1>=v59 v60 v61 v62)
  (1>=v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74) (1>=v75) (1>=v76 v77)
  (1>=v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130 v131 v132 v133 v134 v135 v136 v137 v138 v139 v140 v141 v142 v143 v144 v145 v146 v147 v148 v149 v150 v151 v152 v153 v154 v155) (1>=v156 v157 v158 v159 v160 v161 v162 v163 v164 v165 v166 v167 v168 v169 v170 v171 v172) (1>=v173 v174 v175 v176 v177 v178 v179 v180 v181 v182 v183 v184 v185 v186 v187 v188)
  (1>=v189) (1>=v190)
  (1>=v191 v192 v193 v194 v195 v196 v197 v198 v199 v200 v201 v202)
  (1>=v203 v204 v205 v206 v207 v208 v209)
  (|(~v210) (1==v1)) (|(~v211) (&(1==v2) (1==v14) (1==v29) (1==v32) (1==v33) (1==v59)
  (1==v63) (1==v75) (1==v76) (1==v78) (1==v156) (1==v173))) (|(~v212) (1==v189))
  (|(~v214) (1==v190)) (|(~v215) (&(1==v202 v201 v200 v199 v198 v197 v196 v195 v194 v193 v192 v191)
  (1==v204 v203))) (|(~v216) (&(1==v202 v201 v200 v199 v198 v197 v196 v195 v194 v193 v192 v191)
  (1==v209 v208 v207 v206 v205 v204 v203))) (|(~v217) (1==v76)) (|(~v0) v210) (|(~v1) v211)
  (|(~v2) v212) (|(~v4) v212) (|(~v5) v212) (|(~v6) v212) (|(~v7) v214) (|(~v8) v214)
  (|(~v9) v214) (|(~v14) v215) (|(~v15) v215) (|(~v16) v215) (|(~v17) v215) (|(~v18) v215)
  (|(~v19) v215) (|(~v20) v215) (|(~v21) v216) (|(~v22) v216) (|(~v75) v217))"""

    mySol = @[
      SetToTrue, #v0
      SetToFalse, #v1
      SetToTrue, #v2
      SetToFalse, #v3
      SetToTrue, #v4
      SetToTrue, #v5
      SetToFalse, #v6
      SetToTrue, #v7
      SetToTrue, #v8
      SetToFalse, #v9
      SetToTrue, # v10
      SetToFalse, # v11
      SetToTrue, # v12
      SetToTrue, # v13
      SetToFalse,
      SetToFalse,
      SetToFalse,
      SetToFalse,
      SetToFalse,
      SetToFalse,
      SetToFalse
    ]

  test "test3":
    var b: Builder

    discard parseFormular(myFormular, 0, b)

    let f = toForm(b)
    echo "original: "
    echo f

    var s = createSolution(f)
    let res = satisfiable(f, s)
    echo "is solvable? ", res
    check res == true

    echo "SOLUTION"
    let expected = {0 ,1 ,2 ,14 ,29 ,32 ,33 ,59 ,63 ,75 ,76 ,78 ,156 ,173 ,189 ,202 ,204 ,210 ,211 ,212 ,215 ,217}
    let max = maxVariable(f)
    for i in 0..<max:
      if s.getVar(VarId(i)) == SetToTrue:
        echo "v", i
        check i in expected

    echo "REALLY? ", eval(f, s)

    when false:
      echo f.eval(s)

      var mx = createSolution(mySol.len)
      for i in 0..<mySol.len:
        mx.setVar VarId(i), mySol[i]
      echo f.eval(mx)


