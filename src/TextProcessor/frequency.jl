"""
    AbstractPiece

An abstract type representing a piece of text.
"""
abstract type AbstractPiece{T, U} end


"""
    Piece

Stores n-gram counts of a piece of text. Only accounts for raw characters.

```jldoctest
julia> using AdvancedLayoutCalculator.TextProcessor

julia> d = Dict(1 => Dict("a" => 10, "e" => 4)); 

julia> Piece(d, [15])
ERROR: For ngram (1), sum of 'counts' (14) must equal the 'total' (15)!
```
"""
struct Piece{T <: UnString, U <: IntFloat} <: AbstractPiece{T, U}
    counts::Dict{Int, Dict{T, U}}
    totals::Vector{Int}

    function Piece(c::Dict{Int, Dict{T, U}}) where {T <: UnString, U <: IntFloat}
        # newc = Dict(convert(String, k) => convert(Int, v) for (k, v) in pairs(c))
        totals = Int[]
        for n in 1:length(c)
            push!(totals, sum(values(c[n])))
        end
        return new{T, U}(c, totals)
    end
    function Piece(c::Dict{Int, Dict{T, U}}, t::Vector{Int}) where {T <: UnString, U <: IntFloat}
        # newc = Dict(convert(String, k) => convert(Int, v) for (k, v) in pairs(c))
        for n in 1:length(c)
            s = sum(values(c[n]))
            if s != t[n]
                error("For ngram ($n), sum of 'counts' ($s) must equal the 'total' ($(t[n]))!")
            end
        end
        return new{T, U}(c, t)
    end
end

"""
    Piece(rawtext::String, n::Int)

Get Piece from `rawtext` up to `n` grams.
"""
function Piece{String, Int}(rawtext::String, up2n::Int)
    d = getngrams(rawtext, up2n)
    # newd = Dict(convert(String, k) => convert(Int, v) for (k, v) in pairs(d))
    return Piece(d)
end
function Piece(rawtext::String, up2n::Int)
    return Piece{String, Int}(rawtext, up2n)
end

Base.eltype(::Piece{U, V}) where {U, V} = Pair{U, V}
Base.show(io::IO, ::Type{Dict{Int64, Dict{T, U}}}) where {T, U} = print(io, "PieceDict{$T, $U}")
import Base: ==, hash
function ==(p1::Piece{T1, U1}, p2::Piece{T2, U2}) where {T1, U1, T2, U2} 
    if T1 != T2 || U1 != U2 return false end
    if getcd(p1) != getcd(p2) return false end
    if gett(p1) != gett(p2) return false end
    return true
end
function hash(p::Piece{T, U}, h::UInt) where {T, U}
    return hash((getcd(p), gett(p)), h)
end

getcountsdict(r::AbstractPiece) = r.counts
gettotals(r::AbstractPiece) = r.totals

"""
    RawPieceC

Raw counts of ngrams in the text. `Piece{String, Int}`
"""
const RawPieceC = Piece{String, Int}
# const ProcPieceC = Piece{PString, Int}
# const RawPieceF = Piece{String, Float64}
# const ProcPieceF = Piece{PString, Float64}


"""
    raw2processed
"""
function raw2processed(p::RawPieceC)
    d = Dict{Int, Dict{PString, Int}}()
    rawcd = getcd(p)
    for n in maximum(keys(rawcd)):-1:1
        d[n] = get(d, n, Dict{PString, Int}())
    end
    n = maximum(keys(rawcd))
    # for n in maximum(keys(rawcd)):-1:1
        for ngram in keys(rawcd[n])
            ngramcount = rawcd[n][ngram]
            println("raw2processed ngram to convert $ngram")
            println(d)
            pstr = to_pstring(ngram)

            if _hassymbol(pstr)

            else
                _updatedict!(d, gram, ngramcount; op=:set)
            end
            
            println("raw2processed pstring is $pstr")
            pgrams = _ngramsupto(pstr, n-1)
            for p in pgrams
                println(p)
            end
            for gram in pgrams
                _updatedict!(d, gram, ngramcount; op=:add)
            end
            # for eachn in 1:n
            #     grams = _ngram(pstr, eachn)
            #     println("raw2processed $grams")
            #     for gram in grams
            #         println("raw2processed $gram, $ngramcount")
            #         _updatedict!(d, gram, ngramcount; op=:add)
            #     end
            # end
        end
    # end
    return d
end


function _ngramsupto(rawtext::T, up2n::Int) where T <: UnString
    total = length(rawtext)
    if up2n > total
        error("Max ngram size ($up2n) can't be greater than length of text ($total)!")
    end

    subgramsizes = 1:up2n-1

    validinds = collect(eachindex(rawtext))

    grams = T[]

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
            push!(grams, subgrams...)
        end
        push!(grams, ss)
    end

    return grams
end

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
function getngrams(rawtext::T, up2n::Int) where T <: UnString

    d = Dict{Int, Dict{T, Int}}()
    grams = _ngramsupto(rawtext, up2n)
    for gram in grams
        _updatedict!(d, gram)
    end
    return d
end

"""
    _filtercounts!
"""
function _filtercounts!(d::Dict{Int, Dict{T, Int}}; mincount=0) where T <: UnString
    for n in keys(d)
        filter!(v -> v.second >= mincount, d[n])
    end
    filter!(v -> length(v.second) > 0, d)
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
function _ngram(s::T, n::Int) where T <: UnString
    grams = T[]
    validinds = collect(eachindex(s))
    for i in 1:length(s)-n+1
        startind = validinds[i]
        endind = validinds[i+n-1]
        # println("_ngram $(s[startind:endind])")
        push!(grams, s[startind:endind])
    end
    # [view(s,i:i+n-1) for i=1:length(s)-n+1]
    return grams
end


"""
    _updatedict!(::Dict, k)

Increment count of key `k` by one.

```jldoctest updatedictdoctests
julia> using AdvancedLayoutCalculator.TextProcessor

julia> d = Dict(1 => Dict{String, Int}("a" => 1));

julia> AdvancedLayoutCalculator.TextProcessor._updatedict!(d, "a")
Dict{Int64, Dict{String, Int64}} with 1 entry:
  1 => Dict("a"=>2)
```
"""
function _updatedict!(d::Dict{T, Dict{U, V}}, k::U) where {T, U, V}
    n = length(k)
    d[n] = get(d, n, Dict{U, V}())
    d[n][k] = get(d[n], k, 0) + 1
    return d
end

"""
    _updatedict!(::Dict, k, v)
    
Update dict according to key `k` with value `v`.
```
"""
function _updatedict!(d::Dict{T, Dict{U, V}}, k::U, v::V; op=:set) where {T, U, V}
    n = length(k)
    # d[n] = get(d, n, Dict{U, V}())
    if op == :set
        d[n][k] = v
    elseif op == :add
        # println("$(get(d[n], k, 0)) + $v")
        d[n][k] = get(d[n], k, 0) + v
    else
        d[n][k] = v
    end
    return d
end

"""
    _updatedict!(::Dict, karr)

For each key in `karr`, increment its value by 1.

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
