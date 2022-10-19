"""
    AbstractPiece

An abstract type representing a piece of text.
"""
abstract type AbstractPiece end


"""
    RawPiece

Stores n-gram counts of a piece of text. Only accounts for raw characters.

```jldoctest
julia> using AdvancedLayoutCalculator.TextProcessor

julia> d = Dict(1 => Dict("a" => 10, "e" => 4)); 

julia> RawPiece(d, [15])
ERROR: For ngram (1), sum of 'counts' (14) must equal the 'total' (15)!
```
"""
struct RawPiece <: AbstractPiece
    counts::Dict{Int, Dict{String, Int}}
    totals::Vector{Int}

    function RawPiece(c::Dict{Int, Dict{String, Int}})
        # newc = Dict(convert(String, k) => convert(Int, v) for (k, v) in pairs(c))
        totals = Int[]
        for ngram in 1:length(c)
            push!(totals, sum(values(c[ngram])))
        end
        return new(c, totals)
    end
    function RawPiece(c::Dict{Int, Dict{String, Int}}, t::Vector{Int})
        # newc = Dict(convert(String, k) => convert(Int, v) for (k, v) in pairs(c))
        for ngram in 1:length(c)
            s = sum(values(c[ngram]))
            if s != t[ngram]
                error("For ngram ($ngram), sum of 'counts' ($s) must equal the 'total' ($(t[ngram]))!")
            end
        end
        return new(c, t)
    end
end

"""
    RawPiece(rawtext::String, n::Int)

Get RawPiece from `rawtext` up to `n` grams.
"""
function RawPiece(rawtext::String, up2n::Int)
    d = getngrams(rawtext, up2n)
    # newd = Dict(convert(String, k) => convert(Int, v) for (k, v) in pairs(d))
    return RawPiece(d)
end

getcountsdict(r::AbstractPiece) = r.counts
gettotals(r::AbstractPiece) = r.totals



"""
    getngrams(::String, ::Int)

Get all n-grams up to n.

```jldoctest
julia> using AdvancedLayoutCalculator.TextProcessor

julia> getngrams("heLo", 4)
Dict{Int64, Dict{String, Int64}} with 4 entries:
  4 => Dict("heLo"=>1)
  2 => Dict("Lo"=>1, "he"=>1, "eL"=>1)
  3 => Dict("heL"=>1, "eLo"=>1)
  1 => Dict("e"=>1, "o"=>1, "L"=>1, "h"=>1)
```
"""
function getngrams(rawtext::AbstractString, up2n::Int)
    total = length(rawtext)
    if up2n > total
        error("Max ngram size ($up2n) can't be greater than length of text ($total)!")
    end
    d = Dict{Int, Dict{String, Int}}()

    subgramsizes = 1:up2n-1

    validinds = collect(eachindex(rawtext))

    for i in 1:total-up2n+1
        startind = validinds[i]
        endind = validinds[i+up2n-1] 
        ss = rawtext[startind:endind]
        for sgs in subgramsizes
            validss = collect(eachindex(ss))
            startss = validss[end-sgs+1]
            endss = validss[end]
            untouched = if i == 1 ss else ss[startss:endss] end
            subgrams = _ngram(untouched, sgs)
            _updatedict!(d, subgrams)
        end
        _updatedict!(d, ss)
    end

    return d
end

"""
    _ngram(::String, ::Int)

https://stackoverflow.com/questions/42360957/generate-ngrams-with-julia

```jldoctest
julia> AdvancedLayoutCalculator.TextProcessor._ngram("hello Ez", 3)
6-element Vector{String}:
 "hel"
 "ell"
 "llo"
 "lo "
 "o E"
 " Ez"
```
"""
function _ngram(s::AbstractString, n::Int)
    grams = String[]
    validinds = collect(eachindex(s))
    for i in 1:length(s)-n+1
        startind = validinds[i]
        endind = validinds[i+n-1]
        push!(grams, s[startind:endind])
    end
    # [view(s,i:i+n-1) for i=1:length(s)-n+1]
    return grams
end


"""
    _updatedict!(::Dict, ::PChar)

```jldoctest updatedictdoctests
julia> using AdvancedLayoutCalculator.TextProcessor

julia> d = Dict(1 => Dict{String, Int}("a" => 1));

julia> AdvancedLayoutCalculator.TextProcessor._updatedict!(d, "a")
Dict{Int64, Dict{String, Int64}} with 1 entry:
  1 => Dict("a"=>2)
```
"""
function _updatedict!(d::Dict{T, Dict{U, V}}, k::U) where {T, U, V}
    ngram = length(k)
    d[ngram] = get(d, ngram, Dict{U, V}())
    d[ngram][k] = get(d[ngram], k, 0) + 1
    return d
end

"""
    _updatedict!(::Dict, ::PChar)

```jldoctest updatedictdoctests
julia> using AdvancedLayoutCalculator.TextProcessor

julia> d = Dict(1 => Dict{PString, Int}(PString("a") => 2));

julia> AdvancedLayoutCalculator.TextProcessor._updatedict!(d, PString[:shift, "a", "bd"]);

julia> d[1]
Dict{PString, Int64} with 2 entries:
  PString(Union{AbstractString, Symbol}[:shift]) => 1
  PString(Union{AbstractString, Symbol}["a"])    => 3

julia> d[2]
Dict{PString, Int64} with 1 entry:
  PString(Union{AbstractString, Symbol}["b", "d"]) => 1
```
"""
function _updatedict!(d::Dict{T, Dict{U, V}}, karr::Array{<:U}) where {T, U, V}
    for k in karr
        _updatedict!(d, k)
    end
    return d
end
