// Should fail: config() takes only named arguments plus the body.
#import "/src/lib.typ" as typ
#typ.config(12pt, font-size: 9pt)[body]
