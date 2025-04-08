// The only export is this function which returns a dictionary of languages with
// all fields required by `codly`.
//
// To use:
//
// ```typst
// #import "@preview/codly:1.2.0": *
// #show: codly-init
//
// #import "codly-languages.typ:0.1.8": *
// #codly(languages: codly-languages)
// ```
#let codly-languages = {
  // helper function which takes an image filename and creates an icon
  let __icon(image-filename) = {
    box(
      image("icons/" + image-filename, height: 0.9em),
      baseline: 0.05em,
      inset: 0pt,
      outset: 0pt,
    ) + h(0.3em)
  }

  let __emoji(emoji) = {
    box(
      emoji,
      inset: 0pt,
      outset: 0pt,
    ) + h(0.3em)
  }

  // configurations for languages
  (
    //ActionScript
    ascript:              (name: "ActionScript",      color: rgb("#c41718"), icon: __icon("actionscript.svg")), //VSCode Icons
    "as":                 (name: "ActionScript",      color: rgb("#c41718"), icon: __icon("actionscript.svg")), //VSCode Icons
    //Ada
    ada:                  (name: "Ada",               color: rgb("#0f23c3"), icon: __icon("ada.svg")), //VSCode Icons
    adb:                  (name: "Ada",               color: rgb("#0f23c3"), icon: __icon("ada.svg")), //VSCode Icons
    ads:                  (name: "Ada",               color: rgb("#0f23c3"), icon: __icon("ada.svg")), //VSCode Icons
    gpr:                  (name: "Ada",               color: rgb("#0f23c3"), icon: __icon("ada.svg")), //VSCode Icons
    //Agda
    agda:                 (name: "Agda",              color: rgb("#000000"), icon: __icon("agda.svg")), //VSCode Icons
    //Angular
    angular:              (name: "Angular",           color: rgb("#e40035"), icon: __icon("angular.svg")), //Devicons
    //Ansible
    ansible:              (name: "Ansible",           color: rgb("#1a1918"), icon: __icon("ansible.svg")), //Devicons
    //Apache
    apache:               (name: "Apache",            color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    envvars:              (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    htaccess:             (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    HTACCESS:             (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    htgroups:             (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    HTGROUPS:             (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    htpasswd:             (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    HTPASSWD:             (name: "Apache Config",     color: rgb("#cb2533"), icon: __icon("apache.svg")), //Devicons
    //APL
    apl:                  (name: "APL",               color: rgb("#24a148"), icon: __icon("apl.svg")), //Devicons
    //AppleScript
    applescript:          (name: "AppleScript",       color: rgb("#a8c2ab"), icon: __icon("applescript.svg")), //VSCode Icons
    //AsciiDoc
    asciidoc:             (name: "AsciiDoc",          color: rgb("#e40046"), icon: __icon("asciidoc.svg")), //VSCode Icons
    ad:                   (name: "AsciiDoc",          color: rgb("#e40046"), icon: __icon("asciidoc.svg")), //VSCode Icons
    adoc:                 (name: "AsciiDoc",          color: rgb("#e40046"), icon: __icon("asciidoc.svg")), //VSCode Icons
    //ASP
    asp:                  (name: "ASP",               color: rgb("#0088b6"), icon: __icon("asp.svg")), //VSCode Icons
    asa:                  (name: "ASP",               color: rgb("#0088b6"), icon: __icon("asp.svg")), //VSCode Icons
    //Assembly (ARM)
    aarch64:              (name: "Assembly (ARM)",    color: rgb("#1b3888"), icon: __icon("aarch64.svg")), //Devicons
    arm:                  (name: "Assembly (ARM)",    color: rgb("#1b3888"), icon: __icon("aarch64.svg")), //Devicons
    //Assembly (x86_64)
    asm:                  (name: "Assembly (x86_64)", color: rgb("#0000bf"), icon: __icon("assembly.svg")), //VSCode Icons
    yasm:                 (name: "Assembly (x86_64)", color: rgb("#0000bf"), icon: __icon("assembly.svg")), //VSCode Icons
    nasm:                 (name: "Assembly (x86_64)", color: rgb("#0000bf"), icon: __icon("assembly.svg")), //VSCode Icons
    inc:                  (name: "Assembly (x86_64)", color: rgb("#0000bf"), icon: __icon("assembly.svg")), //VSCode Icons
    mac:                  (name: "Assembly (x86_64)", color: rgb("#0000bf"), icon: __icon("assembly.svg")), //VSCode Icons
    //Authorized Keys
    authorized_keys:      (name: "Authorized Keys",   color: rgb("#dfb300"), icon: __icon("key.svg")), //VSCode Icons
    authorized_keys2:     (name: "Authorized Keys",   color: rgb("#dfb300"), icon: __icon("key.svg")), //VSCode Icons
    pub:                  (name: "Authorized Keys",   color: rgb("#dfb300"), icon: __icon("key.svg")), //VSCode Icons
    //AWK
    awk:                  (name: "AWK",               color: rgb("#0a094d"), icon: __icon("awk.svg")), //Devicons
    //Batch File
    bat:                  (name: "Batch",             color: rgb("#404f5c"), icon: __icon("bat.svg")), //VSCode Icons
    cmd:                  (name: "Batch",             color: rgb("#404f5c"), icon: __icon("bat.svg")), //VSCode Icons
    //BibTeX
    bibtex:               (name: "BibTeX",            color: rgb("#000000"), icon: __icon("bibtex.svg")), //Wikimedia
    bib:                  (name: "BibTeX",            color: rgb("#000000"), icon: __icon("bibtex.svg")), //Wikimedia
    //Bash/Shell
    bash:                 (name: "Bash",              color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    fish:                 (name: "Fish",              color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    sh:                   (name: "Shell",             color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    shell:                (name: "Shell",             color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    shellscript:          (name: "Shell",             color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    zsh:                  (name: "Z shell",           color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    shell_unix_generic:   (name: "Shell",             color: rgb("#293138"), icon: __icon("bash.svg")), //Devicons
    commands_bash:        (name: "Bash",              color: rgb("#2c3e50"), icon: __icon("bash.svg")), //Devicons
    //C
    c:                    (name: "C",                 color: rgb("#03599c"), icon: __icon("c.svg")), //Devicons
    h:                    (name: "C Header",          color: rgb("#005f91"), icon: __icon("cheader.svg")), //VSCode Icons
    //C#
    cs:                   (name: "C#",                color: rgb("#68217a"), icon: __icon("csharp.svg")), //Devicons
    csharp:               (name: "C#",                color: rgb("#68217a"), icon: __icon("csharp.svg")), //Devicons
    csx:                  (name: "C#",                color: rgb("#68217a"), icon: __icon("csharp.svg")), //Devicons
    //C++
    C:                    (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    cc:                   (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    cp:                   (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    cplusplus:            (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    cpp:                  (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    inl:                  (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    ipp:                  (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    cxx:                  (name: "C++",               color: rgb("#004482"), icon: __icon("cplusplus.svg")), //Devicons
    hh:                   (name: "C++ Header",        color: rgb("#984c93"), icon: __icon("cppheader.svg")), //VSCode Icons
    hpp:                  (name: "C++ Header",        color: rgb("#984c93"), icon: __icon("cppheader.svg")), //VSCode Icons
    hxx:                  (name: "C++ Header",        color: rgb("#984c93"), icon: __icon("cppheader.svg")), //VSCode Icons
    //Cabal
    cabal:                (name: "Cabal",             color: rgb("#2e5bc1"), icon: __icon("cabal.svg")), //VSCode Icons
    //Cairo
    cairo:                (name: "Cairo",             color: rgb("#f39914"), icon: __icon("cairo.svg")), //Devicons
    //Clojure
    clojure:              (name: "Clojure",           color: rgb("#63b132"), icon: __icon("clojure.svg")), //Devicons
    clj:                  (name: "Clojure",           color: rgb("#63b132"), icon: __icon("clojure.svg")), //Devicons
    //ClojureScript
    clojurescript:        (name: "ClojureScript",     color: rgb("#96ca4b"), icon: __icon("clojurescript.svg")), //Devicons
    cljs:                 (name: "ClojureScript",     color: rgb("#96ca4b"), icon: __icon("clojurescript.svg")), //Devicons
    //CMake
    cmake:                (name: "CMake",             color: rgb("#064f8c"), icon: __icon("cmake.svg")), //Devicons
    cmakecache:           (name: "CMake",             color: rgb("#064f8c"), icon: __icon("cmake.svg")), //Devicons
    cmakecommands:        (name: "CMake",             color: rgb("#064f8c"), icon: __icon("cmake.svg")), //Devicons
    //CoffeeScript
    Cakefile:             (name: "CoffeeScript",      color: rgb("#28334c"), icon: __icon("coffeescript.svg")), //Devicons
    cson:                 (name: "CoffeeScript",      color: rgb("#28334c"), icon: __icon("coffeescript.svg")), //Devicons
    coffeescript:         (name: "CoffeeScript",      color: rgb("#244776"), icon: __icon("coffeescript.svg")), //Devicons
    coffee:               (name: "CoffeeScript",      color: rgb("#28334c"), icon: __icon("coffeescript.svg")), //Devicons
    //CSV
    csv:                  (name: "CSV",               color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    tsv:                  (name: "TSV",               color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    //CpuInfo
    cpuinfo:              (name: "CpuInfo",           color: rgb("#3c70cc"), icon: __emoji(emoji.info)),
    //Crontab
    crontab:              (name: "Crontab",           color: rgb("#e84f69"), icon: __emoji(emoji.clock.alarm)),
    tab:                  (name: "Crontab",           color: rgb("#e84f69"), icon: __emoji(emoji.clock.alarm)),
    //Crystal
    crystal:              (name: "Crystal",           color: rgb("#000000"), icon: __icon("crystal.svg")), //Devicons
    cr:                   (name: "Crystal",           color: rgb("#000000"), icon: __icon("crystal.svg")), //Devicons
    //CSS
    css:                  (name: "CSS",               color: rgb("#663399"), icon: __icon("css.svg")), //VSCode Icons
    //Cuda
    cuda:                 (name: "CUDA",              color: rgb("#80bc00"), icon: __icon("cuda.svg")), //VSCode Icons
    cu:                   (name: "CUDA",              color: rgb("#80bc00"), icon: __icon("cuda.svg")), //VSCode Icons
    //D
    d:                    (name: "D",                 color: rgb("#b03931"), icon: __icon("dlang.svg")), //VSCode Icons
    di:                   (name: "D",                 color: rgb("#b03931"), icon: __icon("dlang.svg")), //VSCode Icons
    //Dart
    dart:                 (name: "Dart",              color: rgb("#0075c9"), icon: __icon("dart.svg")), //Devicons
    //Diff
    diff:                 (name: "Diff",              color: rgb("#c00000"), icon: __icon("diff.svg")), //VSCode Icons
    patch:                (name: "Patch",             color: rgb("#c00000"), icon: __icon("diff.svg")), //VSCode Icons
    //Docker
    docker:               (name: "Docker",            color: rgb("#028bb8"), icon: __icon("docker.svg")), //Devicons
    dockerfile:           (name: "Docker",            color: rgb("#028bb8"), icon: __icon("docker.svg")), //Devicons
    Dockerfile:           (name: "Docker",            color: rgb("#028bb8"), icon: __icon("docker.svg")), //Devicons
    //DotENV
    dotenv:               (name: "DotENV",            color: rgb("#ecd53f"), icon: __icon("dotenv.svg")), //VSCode Icons
    env:                  (name: "DotENV",            color: rgb("#ecd53f"), icon: __icon("dotenv.svg")), //VSCode Icons
    //Elixir
    elixir:               (name: "Elixir",            color: rgb("#26053d"), icon: __icon("elixir.svg")), //Devicons
    ex:                   (name: "Elixir",            color: rgb("#26053d"), icon: __icon("elixir.svg")), //Devicons
    exs:                  (name: "Elixir",            color: rgb("#26053d"), icon: __icon("elixir.svg")), //Devicons
    //Elm
    elm:                  (name: "Elm",               color: rgb("#60b5cc"), icon: __icon("elm.svg")), //Devicons
    //Emacs
    emacs:                (name: "Emacs",             color: rgb("#421f5f"), icon: __icon("emacs.svg")), //Devicons
    //Email
    email:                (name: "Email",             color: rgb("#4682d2"), icon: __emoji(emoji.email)),
    eml:                  (name: "Email",             color: rgb("#4682d2"), icon: __emoji(emoji.email)),
    msg:                  (name: "Email",             color: rgb("#4682d2"), icon: __emoji(emoji.email)),
    mbx:                  (name: "Email",             color: rgb("#4682d2"), icon: __emoji(emoji.email)),
    mboxz:                (name: "Email",             color: rgb("#4682d2"), icon: __emoji(emoji.email)),
    //Erlang
    erlang:               (name: "Erlang",            color: rgb("#a90533"), icon: __icon("erlang.svg")), //Devicons
    erl:                  (name: "Erlang",            color: rgb("#a90533"), icon: __icon("erlang.svg")), //Devicons
    hrl:                  (name: "Erlang",            color: rgb("#a90533"), icon: __icon("erlang.svg")), //Devicons
    Emakefile:            (name: "Erlang",            color: rgb("#a90533"), icon: __icon("erlang.svg")), //Devicons
    emakefile:            (name: "Erlang",            color: rgb("#a90533"), icon: __icon("erlang.svg")), //Devicons
    yaws:                 (name: "Erlang",            color: rgb("#a90533"), icon: __icon("erlang.svg")), //Devicons
    //F#
    fsharp:               (name: "F#",                color: rgb("#378bba"), icon: __icon("fsharp.svg")), //Devicons
    fs:                   (name: "F#",                color: rgb("#378bba"), icon: __icon("fsharp.svg")), //Devicons
    fsi:                  (name: "F#",                color: rgb("#378bba"), icon: __icon("fsharp.svg")), //Devicons
    fsx:                  (name: "F#",                color: rgb("#378bba"), icon: __icon("fsharp.svg")), //Devicons
    //Fortran
    fortran:              (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    f:                    (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    F:                    (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    f77:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    F77:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    "for":                (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    FOR:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    fpp:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    FPP:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    f90:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    F90:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    f95:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    F95:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    f03:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    F03:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    f08:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    F08:                  (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    namelist:             (name: "Fortran",           color: rgb("#734c94"), icon: __icon("fortran.svg")), //Devicons
    //fstab
    fstab:                (name: "fstab",             color: rgb("#9b96a2"), icon: __emoji(emoji.page)),
    crypttab:             (name: "fstab",             color: rgb("#9b96a2"), icon: __emoji(emoji.page)),
    mtab:                 (name: "fstab",             color: rgb("#9b96a2"), icon: __emoji(emoji.page)),
    //Git
    git:                  (name: "Git",               color: rgb("#f34f29"), icon: __icon("git.svg")), //Devicons
    //GLSL
    vs:                   (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    gs:                   (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    vsh:                  (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    fsh:                  (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    gsh:                  (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    vshader:              (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    fshader:              (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    gshader:              (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    vert:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    frag:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    geom:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    tesc:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    tese:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    comp:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    glsl:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    mesh:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    task:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    rgen:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    rint:                 (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    rahit:                (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    rchit:                (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    rmiss:                (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    rcall:                (name: "GLSL",              color: rgb("#4386b5"), icon: __icon("glsl.svg")), //VSCode Icons
    //gnuplot
    gp:                   (name: "gnuplot",           color: rgb("#fd0303"), icon: __icon("gnuplot.svg")), //VSCode Icons
    gpl:                  (name: "gnuplot",           color: rgb("#fd0303"), icon: __icon("gnuplot.svg")), //VSCode Icons
    gnuplot:              (name: "gnuplot",           color: rgb("#fd0303"), icon: __icon("gnuplot.svg")), //VSCode Icons
    gnu:                  (name: "gnuplot",           color: rgb("#fd0303"), icon: __icon("gnuplot.svg")), //VSCode Icons
    plot:                 (name: "gnuplot",           color: rgb("#fd0303"), icon: __icon("gnuplot.svg")), //VSCode Icons
    plt:                  (name: "gnuplot",           color: rgb("#fd0303"), icon: __icon("gnuplot.svg")), //VSCode Icons
    //Go
    go:                   (name: "Go",                color: rgb("#6ad7e5"), icon: __icon("go.svg")), //Devicons
    golang:               (name: "Go",                color: rgb("#6ad7e5"), icon: __icon("go.svg")), //Devicons
    //GraphQL
    graphql:              (name: "GraphQL",           color: rgb("#e10098"), icon: __icon("graphql.svg")), //Devicons
    graphqls:             (name: "GraphQL",           color: rgb("#e10098"), icon: __icon("graphql.svg")), //Devicons
    gql:                  (name: "GraphQL",           color: rgb("#e10098"), icon: __icon("graphql.svg")), //Devicons
    //Graphviz (DOT)
    dot:                  (name: "Graphviz (DOT)",    color: rgb("#4ed1f8"), icon: __icon("graphviz.svg")), //VSCode Icons
    DOT:                  (name: "Graphviz (DOT)",    color: rgb("#4ed1f8"), icon: __icon("graphviz.svg")), //VSCode Icons
    gv:                   (name: "Graphviz (DOT)",    color: rgb("#4ed1f8"), icon: __icon("graphviz.svg")), //VSCode Icons
    //Groovy
    groovy:               (name: "Groovy",            color: rgb("#619cbc"), icon: __icon("groovy.svg")), //Devicons
    gvy:                  (name: "Groovy",            color: rgb("#619cbc"), icon: __icon("groovy.svg")), //Devicons
    gradle:               (name: "Groovy",            color: rgb("#619cbc"), icon: __icon("groovy.svg")), //Devicons
    //gRPC
    grpc:                 (name: "gRPC",              color: rgb("#00b0ad"), icon: __icon("grpc.svg")), //Devicons
    //Handlebars
    handlebars:           (name: "Handlebars",        color: rgb("#f0772b"), icon: __icon("handlebars.svg")), //Devicons
    //Haskell
    haskell:              (name: "Haskell",           color: rgb("#5e5187"), icon: __icon("haskell.svg")), //Devicons
    hs:                   (name: "Haskell",           color: rgb("#5e5187"), icon: __icon("haskell.svg")), //Devicons
    lhs:                  (name: "Haskell",           color: rgb("#5e5187"), icon: __icon("haskell.svg")), //Devicons
    //Haxe
    haxe:                 (name: "Haxe",              color: rgb("#ea8220"), icon: __icon("haxe.svg")), //Devicons
    //Highlight non-printables
    show_nonprintable:    (name: "Non Printables",    color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    //hosts
    hosts:                (name: "Hosts",             color: rgb("#00608b"), icon: __icon("host.svg")), //VSCode Icons
    //HTML
    html:                 (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    htm:                  (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    shtml:                (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    xhtml:                (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    tmpl:                 (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    tpl:                  (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    html5:                (name: "HTML",              color: rgb("#e44d26"), icon: __icon("html5.svg")), //Devicons
    //HTTP
    http:                 (name: "HTTP",              color: rgb("#60ccfa"), icon: __emoji(emoji.globe.meridian)),
    //INI
    ini:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    INI:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    inf:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    INF:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    reg:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    REG:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    lng:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    cfg:                  (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    FG:                   (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    hgrc:                 (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    dektop:               (name: "INI",               color: rgb("#40535b"), icon: __icon("ini.svg")), //VSCode Icons
    url:                  (name: "URL",               color: rgb("#60ccfa"), icon: __emoji(emoji.globe.meridian)),
    URL:                  (name: "URL",               color: rgb("#60ccfa"), icon: __emoji(emoji.globe.meridian)),
    //Java
    java:                 (name: "Java",              color: rgb("#0074bd"), icon: __icon("java.svg")),  //Devicons
    bsh:                  (name: "BeanShell",         color: rgb("#0074bd"), icon: __icon("java.svg")),  //Devicons
    properties:           (name: "Properties",        color: rgb("#0074bd"), icon: __icon("java.svg")),  //Devicons
    javadoc:              (name: "JavaDoc",           color: rgb("#0074bd"), icon: __icon("java.svg")),  //Devicons
    jsp:                  (name: "JSP",               color: rgb("#f98200"), icon: __icon("jsp.svg")), //VSCode Icons
    //JavaScript
    javascript:           (name: "JavaScript",        color: rgb("#f0db4f"), icon: __icon("javascript.svg")),  //Devicons
    js:                   (name: "JavaScript",        color: rgb("#f0db4f"), icon: __icon("javascript.svg")),  //Devicons
    //Jinja
    jinja:                (name: "Jinja",            color: rgb("#2f2f2f"), icon: __icon("jinja.svg")), //VSCode Icons
    jinja2:               (name: "Jinja",            color: rgb("#2f2f2f"), icon: __icon("jinja.svg")), //VSCode Icons
    j2:                   (name: "Jinja",            color: rgb("#2f2f2f"), icon: __icon("jinja.svg")), //VSCode Icons
    //JQ
    jq:                   (name: "JQ",                color: rgb("#444444"), icon: __icon("jq.svg")), //Wikimedia
    //JSON
    json:                 (name: "JSON",              color: rgb("#000000"), icon: __icon("json.svg")), //Devicons
    //jsonnet
    jsonnet:              (name: "jsonnet",           color: rgb("#0064bd"), icon: __icon("jsonnet.svg")), //VSCode Icons
    libsonnet:            (name: "jsonnet",           color: rgb("#0064bd"), icon: __icon("jsonnet.svg")), //VSCode Icons
    libjsonnet:           (name: "jsonnet",           color: rgb("#0064bd"), icon: __icon("jsonnet.svg")), //VSCode Icons
    //Julia
    julia:                (name: "Julia",             color: rgb("#389826"), icon: __icon("julia.svg")), //Devicons
    jl:                   (name: "Julia",             color: rgb("#389826"), icon: __icon("julia.svg")), //Devicons
    //Kotlin
    kotlin:               (name: "Kotlin",            color: rgb("#c711e1"), icon: __icon("kotlin.svg")), //Devicons
    kt:                   (name: "Kotlin",            color: rgb("#c711e1"), icon: __icon("kotlin.svg")), //Devicons
    kts:                  (name: "Kotlin",            color: rgb("#c711e1"), icon: __icon("kotlin.svg")), //Devicons
    //LaTeX
    latex:                (name: "LaTeX",             color: rgb("#008080"), icon: __icon("latex.svg")), //Devicons
    ltx:                  (name: "LaTeX",             color: rgb("#008080"), icon: __icon("latex.svg")), //Devicons
    tex:                  (name: "TeX",               color: rgb("#171786"), icon: __icon("tex.svg")), //Devicons
    //Lean
    lean:                 (name: "Lean",              color: rgb("#000000"), icon: __icon("lean.svg")), //Wikimedia
    //Less
    less:                 (name: "Less",              color: rgb("#172e4e"), icon: __icon("less.svg")), //VSCode Icons
    //Lisp
    lisp:                 (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    cl:                   (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    clisp:                (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    l:                    (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    mud:                  (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    el:                   (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    scm:                  (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    ss:                   (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    lsp:                  (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    fasl:                 (name: "Lisp",              color: rgb("#c40804"), icon: __icon("lisp.svg")), //VSCode Icons
    //LLVM
    ll:                   (name: "LLVM",              color: rgb("#09637d"), icon: __icon("llvm.svg")), //Devicons
    llvm:                 (name: "LLVM",              color: rgb("#09637d"), icon: __icon("llvm.svg")), //Devicons
    //log
    log:                  (name: "log",               color: rgb("#00bd02"), icon: __icon("log.svg")), //VSCode Icons
    //Lua
    lua:                  (name: "Lua",               color: rgb("#000080"), icon: __icon("lua.svg")), //Devicons
    //Makefile
    make:                 (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    GNUmakefile:          (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    makefile:             (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    Makefile:             (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    OCamlMakefile:        (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    mak:                  (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    mk:                   (name: "Makefile",          color: rgb("#030303"), icon: __icon("makefile.svg")), //VSCode Icons
    //Manpage
    manpage:              (name: "Manpage",           color: rgb("#ef4469"), icon: __emoji(emoji.quest)),
    man:                  (name: "Manpage",           color: rgb("#ef4469"), icon: __emoji(emoji.quest)),
    groff:                (name: "Manpage",           color: rgb("#ef4469"), icon: __emoji(emoji.quest)),
    troff:                (name: "Manpage",           color: rgb("#ef4469"), icon: __emoji(emoji.quest)),
    //Markdown
    md:                   (name: "Markdown",          color: rgb("#755838"), icon: __icon("markdown.svg")), //VSCode Icons
    mdown:                (name: "Markdown",          color: rgb("#755838"), icon: __icon("markdown.svg")), //VSCode Icons
    markdown:             (name: "Markdown",          color: rgb("#755838"), icon: __icon("markdown.svg")), //VSCode Icons
    markdn:               (name: "Markdown",          color: rgb("#755838"), icon: __icon("markdown.svg")), //VSCode Icons
    multimarkdown:        (name: "MultiMarkdown",     color: rgb("#755838"), icon: __icon("markdown.svg")), //VSCode Icons
    //MATLAB
    matlab:               (name: "MATLAB",            color: rgb("#de5239"), icon: __icon("matlab.svg")), //Devicons
    //Mediawiki
    mediawikerpanel:      (name: "MediawikerPanel",   color: rgb("#ff0000"), icon: __icon("mediawiki.svg")), //VSCode Icons
    mediawiki:            (name: "Mediawiki",         color: rgb("#ff0000"), icon: __icon("mediawiki.svg")), //VSCode Icons
    wikipedia:            (name: "Mediawiki",         color: rgb("#ff0000"), icon: __icon("mediawiki.svg")), //VSCode Icons
    wiki:                 (name: "Mediawiki",         color: rgb("#ff0000"), icon: __icon("mediawiki.svg")), //VSCode Icons
    //MemInfo
    meminfo:              (name: "MemInfo",           color: rgb("#3c70cc"), icon: __emoji(emoji.info)),
    //NAnt Build File
    build:                (name: "NAnt Build File",   color: rgb("#5d5489"), icon: __emoji(emoji.ant)),
    //Nextflow
    nextflow:             (name: "Nextflow",          color: rgb("#0dc09d"), icon: __icon("nextflow.svg")), //VSCode Icons
    //nginx
    conf:                 (name: "nginx",             color: rgb("#019639"), icon: __icon("nginx.svg")), //VSCode Icons
    fastcgi_params:       (name: "nginx",             color: rgb("#019639"), icon: __icon("nginx.svg")), //VSCode Icons
    scgi_params:          (name: "nginx",             color: rgb("#019639"), icon: __icon("nginx.svg")), //VSCode Icons
    uwsgi_params:         (name: "nginx",             color: rgb("#019639"), icon: __icon("nginx.svg")), //VSCode Icons
    nginx:                (name: "nginx",             color: rgb("#019639"), icon: __icon("nginx.svg")), //VSCode Icons
    //Nim
    nim:                  (name: "Nim",               color: rgb("#f3d400"), icon: __icon("nim.svg")), //Devicons
    nims:                 (name: "Nim",               color: rgb("#f3d400"), icon: __icon("nim.svg")), //Devicons
    nimble:               (name: "Nimble",            color: rgb("#c5b514"), icon: __icon("nimble.svg")), //Devicons
    //Ninja
    ninja:                (name: "Ninja",             color: rgb("#400000"), icon: __icon("ninja.svg")), //VSCode Icons
    //Nix
    nix:                  (name: "Nix",               color: rgb("#5277c3"), icon: __icon("nixos.svg")), //Devicons
    nixos:                (name: "Nix",               color: rgb("#5277c3"), icon: __icon("nixos.svg")), //Devicons
    //Objective-C
    objective_c:          (name: "Objective-C",       color: rgb("#c2c2c2"), icon: __icon("objectivec.svg")), //VSCode Icons
    objc:                 (name: "Objective-C",       color: rgb("#c2c2c2"), icon: __icon("objectivec.svg")), //VSCode Icons
    obj-c:                (name: "Objective-C",       color: rgb("#c2c2c2"), icon: __icon("objectivec.svg")), //VSCode Icons
    objectivec:           (name: "Objective-C",       color: rgb("#c2c2c2"), icon: __icon("objectivec.svg")), //VSCode Icons
    m:                    (name: "Objective-C",       color: rgb("#c2c2c2"), icon: __icon("objectivec.svg")), //VSCode Icons
    //Objective-C++
    mm:                   (name: "Objective-C++",     color: rgb("#c2c2c2"), icon: __icon("objectivecpp.svg")), //VSCode Icons
    M:                    (name: "Objective-C++",     color: rgb("#c2c2c2"), icon: __icon("objectivecpp.svg")), //VSCode Icons
    //OCaml
    ocaml:                (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    ml:                   (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    mli:                  (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    mll:                  (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    ocamllex:             (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    ocamlyacc:            (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    mly:                  (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    camlp4:               (name: "OCaml",             color: rgb("#ec670f"), icon: __icon("ocaml.svg")), //Devicons
    //orgmode
    org:                  (name: "orgmode",           color: rgb("#77aa99"), icon: __icon("org.svg")), //VSCode Icons
    orgmode:              (name: "orgmode",           color: rgb("#77aa99"), icon: __icon("org.svg")), //VSCode Icons
    //Pascal
    pas:                  (name: "Pascal",            color: rgb("#3c70cc"), icon: __emoji(emoji.parking)),
    p:                    (name: "Pascal",            color: rgb("#3c70cc"), icon: __emoji(emoji.parking)),
    dpr:                  (name: "Pascal",            color: rgb("#3c70cc"), icon: __emoji(emoji.parking)),
    pascal:               (name: "Pascal",            color: rgb("#3c70cc"), icon: __emoji(emoji.parking)),
    //passwd
    passwd:               (name: "passwd",            color: rgb("#f7b74c"), icon: __emoji(emoji.key)),
    //Perl
    perl:                 (name: "Perl",              color: rgb("#212178"), icon: __icon("perl.svg")), //Devicons
    pl:                   (name: "Perl",              color: rgb("#212178"), icon: __icon("perl.svg")), //Devicons
    pm:                   (name: "Perl",              color: rgb("#212178"), icon: __icon("perl.svg")), //Devicons
    pod:                  (name: "Perl",              color: rgb("#212178"), icon: __icon("perl.svg")), //Devicons
    t:                    (name: "Perl",              color: rgb("#212178"), icon: __icon("perl.svg")), //Devicons
    PL:                   (name: "Perl",              color: rgb("#212178"), icon: __icon("perl.svg")), //Devicons
    //PHP
    php:                  (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    php3:                 (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    php4:                 (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    php5:                 (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    php7:                 (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    phps:                 (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    phpt:                 (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    phtml:                (name: "PHP",               color: rgb("#777bb3"), icon: __icon("php.svg")), //Devicons
    twig:                 (name: "Twig",              color: rgb("#63bf6a"), icon: __icon("twig.svg")), //VSCode Icons
    //Plain Text
    text:                 (name: "Plain Text",        color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    txt:                  (name: "Plain Text",        color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    //PowerShell
    powershell:           (name: "PowerShell",        color: rgb("#1e2f43"), icon: __icon("powershell.svg")), //Devicons
    ps1:                  (name: "PowerShell",        color: rgb("#1e2f43"), icon: __icon("powershell.svg")), //Devicons
    //Processing
    processing:           (name: "Processing",        color: rgb("#1f34ab"), icon: __icon("processing.svg")), //Devicons
    //Prolog
    prolog:               (name: "Prolog",            color: rgb("#ec1c24"), icon: __icon("prolog.svg")), //Devicons
    //Protocol Buffer
    proto:                (name: "Protocol Buffer",   color: rgb("#0f9855"), icon: __icon("protobuf.svg")), //VSCode Icons
    protodevel:           (name: "Protocol Buffer",   color: rgb("#0f9855"), icon: __icon("protobuf.svg")), //VSCode Icons
    textpb:               (name: "Protocol Buffer",   color: rgb("#0f9855"), icon: __icon("protobuf.svg")), //VSCode Icons
    pbtxt:                (name: "Protocol Buffer",   color: rgb("#0f9855"), icon: __icon("protobuf.svg")), //VSCode Icons
    prototxt:             (name: "Protocol Buffer",   color: rgb("#0f9855"), icon: __icon("protobuf.svg")), //VSCode Icons
    //Puppet
    pp:                   (name: "Puppet",            color: rgb("#ffae1a"), icon: __icon("puppet.svg")), //VSCode Icons
    epp:                  (name: "Puppet",            color: rgb("#ffae1a"), icon: __icon("puppet.svg")), //VSCode Icons
    puppet:               (name: "Puppet",            color: rgb("#ffae1a"), icon: __icon("puppet.svg")), //VSCode Icons
    //PureScript
    purs:                 (name: "PureScript",        color: rgb("#111419"), icon: __icon("purescript.svg")), //Devicons
    purescript:           (name: "PureScript",        color: rgb("#111419"), icon: __icon("purescript.svg")), //Devicons
    //Python
    python:               (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    py:                   (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    py3:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    pyw:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    pyi:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    pyx:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    pxd:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    pxi:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    rpy:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    cpy:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    SConstruct:           (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    sconstruct:           (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    SConscript:           (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    gyp:                  (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    gypi:                 (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    Snakefile:            (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    wscript:              (name: "Python",            color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    pip:                  (name: "Requirements.txt",  color: rgb("#306998"), icon: __icon("python.svg")), //Devicons
    //QML
    qml:                  (name: "QML",               color: rgb("#41cd52"), icon: __icon("qml.svg")), //VSCode Icons
    qmlproject:           (name: "QML",               color: rgb("#41cd52"), icon: __icon("qml.svg")), //VSCode Icons
    //R
    r:                    (name: "R",                 color: rgb("#276dc3"), icon: __icon("r.svg")), //Devicons
    R:                    (name: "R",                 color: rgb("#276dc3"), icon: __icon("r.svg")), //Devicons
    s:                    (name: "R",                 color: rgb("#276dc3"), icon: __icon("r.svg")), //Devicons
    S:                    (name: "R",                 color: rgb("#276dc3"), icon: __icon("r.svg")), //Devicons
    Rprofile:             (name: "R",                 color: rgb("#276dc3"), icon: __icon("r.svg")), //Devicons
    rd:                   (name: "R Documentation",   color: rgb("#276dc3"), icon: __icon("r.svg")), //Devicons
    //Racket
    racket:               (name: "Racket",            color: rgb("#9f1d20"), icon: __icon("racket.svg")), //VSCode Icons
    rkt:                  (name: "Racket",            color: rgb("#9f1d20"), icon: __icon("racket.svg")), //VSCode Icons
    //Rego
    rego:                 (name: "Rego",              color: rgb("#536367"), icon: __icon("rego.svg")), //VSCode Icons
    //Regular Expression
    re:                   (name: "RegEx",             color: rgb("#000000"), icon: __emoji(emoji.ast)),
    //resolv
    resolv:               (name: "resolv",            color: rgb("#a89cb8"), icon: __emoji(emoji.gear)),
    //reStructuredText
    rst:                  (name: "reStructuredText",  color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    rest:                 (name: "reStructuredText",  color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    restructuredtext:     (name: "reStructuredText",  color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    //Robot Framework
    robot:                (name: "Robot Framework",   color: rgb("#000000"), icon: __icon("robotframework.svg")), //VSCode Icons
    resource:             (name: "Robot Framework",   color: rgb("#000000"), icon: __icon("robotframework.svg")), //VSCode Icons
    //Ruby
    rb:                   (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Appfile:              (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Appraisals:           (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Berksfile:            (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Brewfile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    capfile:              (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    cgi:                  (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Cheffile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Deliverfile:          (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Fastfile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    fcgi:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Gemfile:              (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    gemspec:              (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Guardfile:            (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    irbrc:                (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    jbuilder:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    podspec:              (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    prawn:                (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    rabl:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    rake:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Rakefile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Rantfile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    rbx:                  (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    rjs:                  (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Scanfile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    simplecov:            (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Snapfile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    thor:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Thorfile:             (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    Vagrantfile:          (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    ruby:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    haml:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    slim:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    skim:                 (name: "Ruby",              color: rgb("#820c01"), icon: __icon("ruby.svg")), //Devicons
    //Ruby on Rails
    rails:                (name: "Ruby on Rails",     color: rgb("#5e000e"), icon: __icon("rails.svg")), //Devicons
    rxml:                 (name: "Ruby on Rails",     color: rgb("#5e000e"), icon: __icon("rails.svg")), //Devicons
    builder:              (name: "Ruby on Rails",     color: rgb("#5e000e"), icon: __icon("rails.svg")), //Devicons
    rhtml:                (name: "Ruby on Rails",     color: rgb("#5e000e"), icon: __icon("rails.svg")), //Devicons
    erb:                  (name: "Ruby on Rails",     color: rgb("#5e000e"), icon: __icon("rails.svg")), //Devicons
    erbsql:               (name: "Ruby on Rails",     color: rgb("#5e000e"), icon: __icon("rails.svg")), //Devicons
    //Rust
    rust:                 (name: "Rust",              color: rgb("#a04f12"), icon: __icon("rust.svg")), //VSCode Icons
    rs:                   (name: "Rust",              color: rgb("#a04f12"), icon: __icon("rust.svg")), //VSCode Icons
    //Scala
    scala:                (name: "Scala",             color: rgb("#de3423"), icon: __icon("scala.svg")), //Devicons
    sc:                   (name: "Scala",             color: rgb("#de3423"), icon: __icon("scala.svg")), //Devicons
    sbt:                  (name: "Scala",             color: rgb("#de3423"), icon: __icon("scala.svg")), //Devicons
    //SCSS
    scss:                 (name: "SCSS",              color: rgb("#cb6699"), icon: __icon("sass.svg")), //Devicons
    sass:                 (name: "SASS",              color: rgb("#cb6699"), icon: __icon("sass.svg")), //Devicons
    //SML
    sml:                  (name: "SML",               color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    cm:                   (name: "SML",               color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    sig:                  (name: "SML",               color: rgb("#829ec2"), icon: __icon("text.svg")), //VSCode Icons
    //Solidity
    solidity:             (name: "Solidity",          color: rgb("#2b247c"), icon: __icon("solidity.svg")), //Devicons
    sol:                  (name: "Solidity",          color: rgb("#2b247c"), icon: __icon("solidity.svg")), //Devicons
    //Splunk
    splunk:               (name: "Splunk",            color: rgb("#0c1724"), icon: __icon("splunk.svg")), //Devicons
    spl:                  (name: "Splunk",            color: rgb("#0c1724"), icon: __icon("splunk.svg")), //Devicons
    //SQL
    sql:                  (name: "SQL",               color: rgb("#ffda44"), icon: __icon("sql.svg")), //VSCode Icons
    ddl:                  (name: "SQL",               color: rgb("#ffda44"), icon: __icon("sql.svg")), //VSCode Icons
    dml:                  (name: "SQL",               color: rgb("#ffda44"), icon: __icon("sql.svg")), //VSCode Icons
    mysql:                (name: "MySQL",             color: rgb("#e48e00"), icon: __icon("mysql.svg")), //Devicons
    postgresql:           (name: "PostgreSQL",        color: rgb("#336791"), icon: __icon("postgresql.svg")), //Devicons
    sqlite:               (name: "SQLite",            color: rgb("#003956"), icon: __icon("sqlite.svg")), //Devicons
    //SSH
    ssh:                  (name: "SSH",               color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    ssh_config:           (name: "SSH Config",        color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    ssh-config:           (name: "SSH Config",        color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    sshd_config:          (name: "SSHD Config",       color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    sshd-config:          (name: "SSHD Config",       color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    known_hosts:          (name: "Known Hosts",       color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    known-hosts:          (name: "Known Hosts",       color: rgb("#231f20"), icon: __icon("ssh.svg")), //Devicons
    //Strace
    strace:               (name: "Strace",            color: rgb("#f59217"), icon: __icon("strace.svg")), //Wikimedia
    //Stylus
    stylus:               (name: "Stylus",            color: rgb("#333333"), icon: __icon("stylus.svg")), //Devicons
    styl:                 (name: "Stylus",            color: rgb("#333333"), icon: __icon("stylus.svg")), //Devicons
    //Sublime
    sublime-settings:     (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-menu:         (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-keymap:       (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-mousemap:     (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-theme:        (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-build:        (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-project:      (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-completions:  (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-commands:     (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-macro:        (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-color-scheme: (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    sublime-Syntax:       (name: "Sublime",           color: rgb("#ff9800"), icon: __icon("sublime.svg")), //VSCode Icons
    //Svelte
    svelte:               (name: "Svelte",            color: rgb("#ff3e00"), icon: __icon("svelte.svg")), //Devicons
    svlt:                 (name: "Svelte",            color: rgb("#ff3e00"), icon: __icon("svelte.svg")), //Devicons
    //Swift
    swift:                (name: "Swift",             color: rgb("#f05138"), icon: __icon("swift.svg")), //Devicons
    //syslog
    syslog:               (name: "Syslog",            color: rgb("#00bd02"), icon: __icon("log.svg")), //VSCode Icons
    //SystemVerilog
    sv:                   (name: "SystemVerilog",     color: rgb("#2c087e"), icon: __icon("systemverilog.svg")), //VSCode Icons
    svh:                  (name: "SystemVerilog",     color: rgb("#2c087e"), icon: __icon("systemverilog.svg")), //VSCode Icons
    vh:                   (name: "SystemVerilog",     color: rgb("#2c087e"), icon: __icon("systemverilog.svg")), //VSCode Icons
    systemverilog:        (name: "SystemVerilog",     color: rgb("#2c087e"), icon: __icon("systemverilog.svg")), //VSCode Icons
    //Tcl
    tcl:                  (name: "Tcl",               color: rgb("#c3b15f"), icon: __icon("tcl.svg")), //VSCode Icons
    adp:                  (name: "Tcl",               color: rgb("#c3b15f"), icon: __icon("tcl.svg")), //VSCode Icons
    //Terraform
    terraform:            (name: "Terraform",         color: rgb("#4040b2"), icon: __icon("terraform.svg")), //Devicons
    tf:                   (name: "Terraform",         color: rgb("#4040b2"), icon: __icon("terraform.svg")), //Devicons
    tfvars:               (name: "Terraform",         color: rgb("#4040b2"), icon: __icon("terraform.svg")), //Devicons
    hcl:                  (name: "Terraform",         color: rgb("#4040b2"), icon: __icon("terraform.svg")), //Devicons
    tfstate:              (name: "Terraform",         color: rgb("#4040b2"), icon: __icon("terraform.svg")), //Devicons
    //Textile
    textile:              (name: "Textile",           color: rgb("#ffe7ac"), icon: __icon("textile.svg")), //VSCode Icons
    //TOML
    toml:                 (name: "TOML",              color: rgb("#9c4221"), icon: __icon("toml.svg")), //VSCode Icons
    tml:                  (name: "TOML",              color: rgb("#9c4221"), icon: __icon("toml.svg")), //VSCode Icons
    Pipfile:              (name: "TOML",              color: rgb("#9c4221"), icon: __icon("toml.svg")), //VSCode Icons
    //TypeScript
    ts:                   (name: "TypeScript",        color: rgb("#007acc"), icon: __icon("typescript.svg")), //Devicons
    mts:                  (name: "TypeScript",        color: rgb("#007acc"), icon: __icon("typescript.svg")), //Devicons
    cts:                  (name: "TypeScript",        color: rgb("#007acc"), icon: __icon("typescript.svg")), //Devicons
    typescript:           (name: "TypeScript",        color: rgb("#007acc"), icon: __icon("typescript.svg")), //Devicons
    tsx:                  (name: "TSX",               color: rgb("#007acc"), icon: __icon("typescript.svg")), //Devicons
    typescriptreact:      (name: "React",             color: rgb("#61dafb"), icon: __icon("react.svg")), //Devicons
    //Typst
    typst:                (name: "Typst",             color: rgb("#8b70c3"), icon: __icon("typst.svg")), //Typst
    typ:                  (name: "Typst",             color: rgb("#458fa0"), icon: __icon("typst.svg")), //Typst
    typc:                 (name: "Typst",             color: rgb("#8b70c3"), icon: __icon("typst.svg")), //Typst
    typm:                 (name: "Typst",             color: rgb("#458fa0"), icon: __icon("typst.svg")), //Typst
    //UML
    uml:                  (name: "UML",               color: rgb("#452e7f"), icon: __icon("unifiedmodelinglanguage.svg")), //Devicons
    //Vala
    vala:                 (name: "Vala",              color: rgb("#6639a4"), icon: __icon("vala.svg")), //Devicons
    //varlink
    varlink:              (name: "varlink",           color: rgb("#ccc4d3"), icon: __emoji(emoji.chain)),
    //Verilog
    v:                    (name: "Verilog",           color: rgb("#1a348f"), icon: __icon("verilog.svg")), //VSCode Icons
    V:                    (name: "Verilog",           color: rgb("#1a348f"), icon: __icon("verilog.svg")), //VSCode Icons
    verilog:              (name: "Verilog",           color: rgb("#1a348f"), icon: __icon("verilog.svg")), //VSCode Icons
    //Vim
    vim:                  (name: "Vim",               color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    vimrc:                (name: "Vim",               color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    gvimrc:               (name: "Vim",               color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    _vimrc:               (name: "Vim",               color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    _gvimrc:              (name: "Vim",               color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    viml:                 (name: "Vim",              color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    vimscript:            (name: "Vim",               color: rgb("#019833"), icon: __icon("vim.svg")), //Devicons
    neovim:               (name: "Neovim",            color: rgb("#439240"), icon: __icon("neovim.svg")), //Devicons
    nvim:                 (name: "Neovim",            color: rgb("#439240"), icon: __icon("neovim.svg")), //Devicons
    //Visual Basic
    visualbasic:          (name: "Visual Basic",      color: rgb("#004e8c"), icon: __icon("visualbasic.svg")), //Devicons
    vb:                   (name: "Visual Basic",      color: rgb("#004e8c"), icon: __icon("visualbasic.svg")), //Devicons
    //Vue
    vue:                  (name: "Vue",               color: rgb("#41b883"), icon: __icon("vuejs.svg")), //Devicons
    //Vyper
    vyper:                (name: "Vyper",             color: rgb("#9f4cf2"), icon: __icon("vyper.svg")), //Devicons
    vy:                   (name: "Vyper",             color: rgb("#9f4cf2"), icon: __icon("vyper.svg")), //Devicons
    //XML
    xml:                  (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    xsd:                  (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    xslt:                 (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    tld:                  (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    dtml:                 (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    rss:                  (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    opml:                 (name: "XML",               color: rgb("#005fad"), icon: __icon("xml.svg")), //Devicons
    svg:                  (name: "SVG",               color: rgb("#ffb13b"), icon: __icon("svg.svg")), //VSCode Icons
    //WASM
    wasm:                 (name: "WASM",              color: rgb("#654ff0"), icon: __icon("wasm.svg")), //Devicons
    //YAML
    yaml:                 (name: "YAML",              color: rgb("#cb171e"), icon: __icon("yaml.svg")), //Devicons
    yml:                  (name: "YAML",              color: rgb("#cb171e"), icon: __icon("yaml.svg")), //Devicons
    //Zig
    zig:                  (name: "Zig",               color: rgb("#f7a41d"), icon: __icon("zig.svg")), //Devicons
  )
}
