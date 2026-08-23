// appendixa.typ — Code listing appendix
// Mirrors appendixa.tex; uses Typst's built-in raw blocks with syntax highlighting.

== Code listing

This example uses Typst's built-in syntax highlighting for code blocks.

#v(1em)

```lua
function print_rate(kappa, xMin, xMax, npoints, option)
    local c = 1 - kappa * kappa
    local croot = (1 - kappa * kappa)^(1/2)
    local logx = math.log(xMin)
    local psi = 0

    local xstep = (math.log(xMax) - math.log(xMin)) / (npoints - 1)

    arg0 = math.sqrt(xMin / c)
    psi0 = (1/c) * math.exp((kappa * arg0)^2) * (erfc(kappa * arg0) - erfc(arg0))

    if option ~= [] then
        tex.sprint("\\addplot+[" .. option .. "] coordinates{")
    else
        tex.sprint("\\addplot+ coordinates{")
    end
    tex.sprint("(" .. xMin .. "," .. psi0 .. ")")

    for i = 1, (npoints - 1) do
        x = math.exp(logx + xstep)
        arg = math.sqrt(x / c)
        karg = kappa * arg
        if karg < 5 then
            -- this break compensates for exp(karg^2)
            logpsi = -math.log(croot) + karg^2 + math.log(erfc(karg) - erfc(arg))
            psi = math.exp(logpsi)
        else
            psi = (1/(karg) - 1/(2*(karg^3)) + 3/(4*(arg^5))) / (1.77245385 * croot)
            -- this is the large x asymptote of the reaction rate
        end
        logx = math.log(x)
        tex.sprint("(" .. x .. "," .. psi .. ")")
    end
    tex.sprint("}")
end
```
