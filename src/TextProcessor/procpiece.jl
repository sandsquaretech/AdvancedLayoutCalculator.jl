"""
    ProcPiece

Stores n-gram counts of a piece of text. Converts strings to PChars.

```jldoctest
julia> using AdvancedLayoutCalculator.TextProcessor

julia> d = Dict("A" => 10, "e" => 4); 
```
"""
struct ProcPiece <: AbstractPiece
    counts::Dict{PString, Int}
    total::Int

    function ProcPiece(c::Dict{PString, Int})
        s = sum(values(c))
        return new(c, s)
    end
    function ProcPiece(c::Dict{PString, Int}, t::Int)
        s = sum(values(c))
        s != t ? error("Sum of 'counts' ($s) must equal the 'total' ($t)!") : new(c, t)
    end
end

function ProcPiece(r::RawPiece)
    # loop through each key
    # convert key String to PString
    # calculate what needs to be updated, max gram length still needed I think
end

# function ProcPiece(rawtext::String, up2n::Int)
#     d = getngrams(rawtext, up2n)
#     newd = Dict(k => convert(Int, v) for (k, v) in pairs(d))
#     r = RawPiece(newd)
#     return ProcPiece(r)
# end