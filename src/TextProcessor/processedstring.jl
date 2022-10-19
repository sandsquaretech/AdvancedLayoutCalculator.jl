abstract type AbstractPString end



"""
    PString

Special type of string that can keep track of things like mods (e.g., shift).
"""
struct PString <: AbstractPString
    v::AbstractArray{PChar}
end
getv(pstr::PString) = pstr.v
Base.length(pstr::PString) = length(getv(pstr))
Base.getindex(pstr::PString, i::Int) = getindex(getv(pstr), i)
Base.getindex(d::Dict{PString, T}, s::U) where {T, U<:Union{String, Symbol}} = getindex(d, PString(s))
Base.setindex!(d::Dict{PString, T}, v::U, k::V) where {T, U, V<:Union{String, Symbol}} = error("For Dict{PString, T}, contents can be viewed with keys of type $V but they cannot be set.")
Base.convert(::Type{PString}, s::String) = to_pstring(s)
Base.convert(::Type{String}, p::PString) = to_string(p)
Base.convert(::Type{PString}, s::Symbol) = PString(s)
import Base: ==, hash
function ==(p1::PString, p2::PString) 
    if length(p1) != length(p2) return false end
    for i in 1:length(p1)
        if p1[i] != p2[i] return false end
    end
    return true
end
function hash(p::PString, h::UInt)
    return hash(getv(p), h)
end


function PString(text::String)::PString
    return to_pstring(text)
end
function PString(s::Symbol)::PString
    return PString(Symbol[s])
end


"""
to_string(::PString)

Converts PString to String.

```jldoctest
julia> using AdvancedLayoutCalculator.TextProcessor

julia> p = PString(["1", "h", :shift, "p"]);

julia> q = to_string(p)
"1hP"

julia> to_pstring(q)
PString(Union{AbstractString, Symbol}["1", "h", :shift, "p"])
```
"""
function to_string(pstr::PString)::String
    outstr = ""
    nextf(x::String) = identity(x)
    for i in 1:length(pstr)
        c = pstr[i]
        if c == :shift
            nextf = uppercase
            continue
        elseif typeof(c) == Symbol
            continue
        end
        outstr *= nextf(c)
        nextf = identity
    end
    return outstr
end

"""
    to_pstring(::String)

Converts String to PString. Currently only accounts for capital alphas.

```jldoctest
julia> using AdvancedLayoutCalculator.TextProcessor

julia> p = to_pstring("helLo")
PString(Union{AbstractString, Symbol}["h", "e", "l", :shift, "l", "o"])

julia> to_string(p)
"helLo"
```
"""
function to_pstring(str::String)::PString
    v = PChar[]
    for i in 1:length(str)
        c = str[i:i]
        if isuppercase(c[1])
            push!(v, :shift)
            push!(v, lowercase(c))
        else
            push!(v, c)
        end
    end
    return PString(v)
end



