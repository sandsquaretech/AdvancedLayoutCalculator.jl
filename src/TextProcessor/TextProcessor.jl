module TextProcessor


    const PChar = Union{AbstractString, Symbol}
    Base.show(io::IO, ::Type{PChar}) = print(io, "PChar")
    export PChar
    const IntFloat = Union{Int, Float64}
    export IntFloat
    
    include("processedstring.jl")
    export PString, getv, to_string, to_pstring

    const UnString = Union{String, PString}
    export UnString

    include("frequency.jl")
    export getngrams, Piece, getcountsdict, gettotals, RawPieceC, ProcPieceC, RawPieceF, ProcPieceF, raw2processed
    """
        getcd
    
    Alias for `getcountsdict`
    """
    const getcd = getcountsdict
    """
        gett
    
    Alias for `gettotal`
    """
    const gett = gettotals
    export getcd, gett

    # include("procpiece.jl")
    # export ProcPiece


end