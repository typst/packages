# The `defined` Package
<div align="center">Version 0.1.0</div>

This package implements a simple C-like `defined` macro for typst. It allows you to check if a variable is defined in some scope and has limited support for macro expansion. The desired outcome is that it become easier to compile typst conditionally from command line arguments or a configuration file.

## Example Usage

```typ
#import "@preview/defined:0.1.0": *

// Check if a macro is defined
// You are allowed to use [..] to call the functions in the package, 
// making it look like a macro. The function will try to interpret the
// markup as a string.
#context if defined[CONFIG_DEBUG] [
  Debugging is enabled.
]

// Define a macro. If the macro is already defined, an error will be thrown.
#define[CONFIG_DEBUG](1)

// You can use --input foo=bar to define a macro in the command line.
#context if not defined[CONFIG_NO_ABSTRACT] [
  Abstract
]

// Define macros from a dictionary.
#from-scope(toml("config.toml"))

// Unset a macro. If the macro is not defined, nothing will happen.
#undef[CONFIG_DEBUG]

// Resolve the value of a macro. If the macro is not defined, none will be 
// returned.
The version is #context resolve[VERSION].

#define[foo](1)
#define[bar](2)

// Expand and evaluate macros. If the macro is not defined, an error will be thrown.
// Note that you have to use (..) to call this function as it uses `eval` 
// under the hood.
#context expand("foo + bar")

```
