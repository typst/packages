/*
  使用模板前，请先安装 https://github.com/csimide/SEU-Typst-Template/tree/master/fonts 内的所有字体。
  如果使用 Web App，请将这些字体上传到 Web App 项目的根目录中。
*/

// 仅当使用 Web App 时，才应该使用此文件，否则都应该直接修改 `bachelor_thesis.typ` 或 `degree_thesis.typ` 文件。

// 由于本模板组包括两个模板: bachelor 和 degree 
// 但是只能设置一个 entrypoint 
// 因此使用奇怪的方法来切换模板

// 默认渲染 degree
#include "degree_thesis.typ"
// 注释上面一行，并取消注释下面这一行，可以渲染 bachelor
// #include "bachelor_thesis.typ"

// 然后，请修改对应的实际 typ 文件，即 `bachelor_thesis.typ` 或 `degree_thesis.typ`