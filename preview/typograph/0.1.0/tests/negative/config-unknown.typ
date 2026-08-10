// Should fail: misspelled config options must not be silently ignored.
#import "/src/lib.typ" as typ
#typ.config(sacle: 2)[body]
