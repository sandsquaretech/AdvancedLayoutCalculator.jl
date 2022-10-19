module TextProcessor


    const PChar = Union{AbstractString, Symbol}
    export PChar

    include("processedstring.jl")
    export PString, getv, to_string, to_pstring

    include("frequency.jl")
    export getngrams, RawPiece, getcountsdict, gettotals
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

    include("procpiece.jl")
    export ProcPiece


end