= 0997. Find the Town Judge

In a town, there are $n$ people labeled from $1$ to $n$. There is a rumor that one of these people is secretly the town judge.

If the town judge exists, then:

1. The town judge trusts nobody.
2. Everybody (except for the town judge) trusts the town judge.
3. There is exactly one person that satisfies properties 1 and 2.

You are given an array `trust` where `trust[i] = [a, b]` representing that the person labeled `a` trusts the person labeled `b`. If a trust relationship does not exist in `trust` array, then such a trust relationship does not exist.

Return the label of the town judge if the town judge exists and can be identified, or return `-1` otherwise.

*Constraints:*

- $1 <= n <= 1000$
- $0 <= "trust.length" <= 10^4$
- All the pairs of `trust` are *unique*.
- `trust[i]` are all different.
- `trust[i][0] != trust[i][1]`
