This package adds the ability to syntax highlighting VonSim source code in Typst.

## How to use

To add global support for VonSim, just add these lines and use a raw block with `vonsim` as its language.

````typst
#import "@preview/vonsim:0.2.0": vonsim-syntax

// Adds global support for VonSim
#set raw(syntaxes: vonsim-syntax)

// Highlight VonSim code
```vonsim
; Welcome to VonSim!
; This is an example program that calculates the first
; n numbers of the Fibonacci sequence, and stores them
; starting at memory position 1000h.

     n  equ 10    ; Calculate the first 10 numbers

        org 1000h
start   db 1

        org 2000h
        mov bx, offset start + 1
        mov al, 0
        mov ah, start

loop:   cmp bx, offset start + n
        jns finish
        mov cl, ah
        add cl, al
        mov al, ah
        mov ah, cl
        mov [bx], cl
        inc bx
        jmp loop
finish: hlt
        end
```
````

You can also add the `mips` language to a raw block to highlight WinMIPS64 assembly code.

```typst
#import "@preview/vonsim:0.2.0": vonsim-syntax, mips-syntax

#set raw(syntaxes: (vonsim-syntax, mips-syntax))
```

### VonSim theme

This package also includes a theme for VonSim. To use it, add the following lines to your Typst document:

```typst
#import "@preview/vonsim:0.2.0": vonsim-theme

#set raw(theme: vonsim-theme)
```