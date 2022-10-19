using AdvancedLayoutCalculator.TextProcessor
using AdvancedLayoutCalculator.TextProcessor: _updatedict!, _ngram, _hassymbol, _filtercounts!

@testset "Has symbol" begin
    pstr = PString("hEllo")
    @test _hassymbol(pstr)
    pstr = PString("hello")
    @test !_hassymbol(pstr)
end

@testset "Processing strings" begin
    
    p = PString(["1", "h", :shift, "p"]);
    q = to_string(p)
    @test q == "1hP"
    
    backp = to_pstring(q)
    @test backp[1] == PString("1")
    @test backp[2] == PString("h")
    @test backp[3] == PString(:shift)
    @test backp[4] == PString("p")

    p = to_pstring("helLo")
    @test p[1] == PString("h")
    @test p[2] == PString("e")
    @test p[3] == PString("l")
    @test p[4] == PString(:shift)
    @test p[5] == PString("l")
    @test p[6] == PString("o")

    @test to_string(p) == "helLo"

end

@testset "update dict" begin

    using AdvancedLayoutCalculator.TextProcessor: _updatedict!, _ngram
    
    d = Dict{Int, Dict{String, Int}}(1 => Dict("a" => 1))
    _updatedict!(d, "a")
    @test length(d) == 1
    @test length(d[1]) == 1
    @test d[1]["a"] == 2
    _updatedict!(d, "sa")
    @test length(d) == 2
    @test length(d[2]) == 1
    @test d[2]["sa"] == 1
    _updatedict!(d, "sa", 49)
    @test d[2]["sa"] == 49
    
    d = Dict{Int, Dict{PString, Int}}(1 => Dict(PString("a") => 1))
    _updatedict!(d, PString[:shift, "e", "e", "c", "a", "bd"])
    @test length(d) == 2
    @test length(d[1]) == 4
    @test d[1][:shift] == 1
    @test d[1]["e"] == 2
    @test d[1]["c"] == 1
    @test d[1]["a"] == 2
    @test d[2]["bd"] == 1
    @test length(d[2]) == 1
    _updatedict!(d, PString(:shift), 64)
    @test d[1][:shift] == 64

end

@testset "ngram" begin

    subgrams = _ngram("hello Ez", 3)
    @test subgrams[1] == "hel"

    d = getngrams("heLh", 3)
    @test length(d) == 3
    @test length(d[1]) == 3
    @test d[1]["h"] == 2
    @test d[1]["e"] == 1
    @test d[1]["L"] == 1
    @test length(d[2]) == 3
    @test d[2]["he"] == 1
    @test d[2]["eL"] == 1
    @test d[2]["Lh"] == 1
    @test length(d[3]) == 2
    @test d[3]["heL"] == 1
    @test d[3]["eLh"] == 1

    r1 = Piece("heLh", 3)
    @test getcountsdict(r1) == d
    @test gettotals(r1) == Int[4, 3, 2]
    r2 = Piece(d, Int[4, 3, 2])
    @test getcountsdict(r2) == d
    @test gettotals(r2) == Int[4, 3, 2]
    r3 = Piece(d)
    @test getcountsdict(r3) == d
    @test gettotals(r3) == Int[4, 3, 2]
    let err = nothing
        try
            Piece(d, Int[3, 3, 2])
        catch err
        end

        @test err isa Exception
        @test sprint(showerror, err) == "For ngram (1), sum of 'counts' (4) must equal the 'total' (3)!"
    end

    let err = nothing
        try
            getngrams("heLo", 5)
        catch err
        end

        @test err isa Exception
        @test sprint(showerror, err) == "Max ngram size (5) can't be greater than length of text (4)!"
    end

    _filtercounts!(d; mincount=1)
    @test length(d) == 3
    @test length(d[1]) == 3
    @test d[1]["h"] == 2
    @test d[1]["e"] == 1
    @test d[1]["L"] == 1
    @test length(d[2]) == 3
    @test d[2]["he"] == 1
    @test d[2]["eL"] == 1
    @test d[2]["Lh"] == 1
    @test length(d[3]) == 2
    @test d[3]["heL"] == 1
    @test d[3]["eLh"] == 1

    _filtercounts!(d; mincount=2)
    @test length(d) == 1
    @test length(d[1]) == 1
    @test d[1]["h"] == 2

    d = getngrams("apapaL", 3)
    @test length(d) == 3
    @test length(d[1]) == 3
    @test d[1]["a"] == 3
    @test d[1]["p"] == 2
    @test d[1]["L"] == 1
    @test length(d[2]) == 3
    @test d[2]["ap"] == 2
    @test d[2]["pa"] == 2
    @test d[2]["aL"] == 1
    @test length(d[3]) == 3
    @test d[3]["apa"] == 2
    @test d[3]["pap"] == 1
    @test d[3]["paL"] == 1

    r1 = Piece("apapaL", 3)
    @test getcountsdict(r1) == d
    @test gettotals(r1) == Int[6, 5, 4]

    _filtercounts!(d; mincount=2)
    @test length(d) == 3
    @test length(d[1]) == 2
    @test d[1]["a"] == 3
    @test d[1]["p"] == 2
    @test length(d[2]) == 2
    @test d[2]["ap"] == 2
    @test d[2]["pa"] == 2
    @test length(d[3]) == 1
    @test d[3]["apa"] == 2


    d = getngrams("hasta", 4)
    @test length(d) == 4
    @test d[1]["h"] == 1
    @test d[1]["a"] == 2
    @test d[1]["s"] == 1
    @test d[1]["t"] == 1
    @test d[2]["ha"] == 1
    @test d[2]["as"] == 1
    @test d[2]["st"] == 1
    @test d[2]["ta"] == 1
    @test d[3]["has"] == 1
    @test d[3]["ast"] == 1
    @test d[3]["sta"] == 1
    @test d[4]["hast"] == 1
    @test d[4]["asta"] == 1

    r1 = Piece("hasta", 4)
    @test getcd(r1) == d
    @test gett(r1) == Int[5, 4, 3, 2]
end

# @testset "actual text" begin
#     f = "./data/1342-0.txt"
#     open(f, "r") do fi
#         s = read(f, String)
#         println(length(s))
#         d = getngrams(s, 4)
#         println(length(d))
#         println(sum(values(d[1])))
#     end
# end

@testset "Other Piece types" begin
    p = Piece("Hi", 2)
    q = RawPieceC("Hi", 2)
    r = Piece{String, Int}("Hi", 2)
    @test p == q
    @test q == r

    # d2 = raw2processed(p)
    # # println(d2)
    # @test d2[1]["i"] == 1
    # @test d2[1][:shift] == 1
    # @test d2[1]["h"] == 1
    # @test d2[2]["hi"] == 1
    # @test d2[2][PString(:shift, "h")] == 1
    
    p2 = RawPieceC("Hihi", 4)
    d2 = raw2processed(p2)
    @test d2[1][:shift] == 1
    @test d2[1]["h"] == 2
    @test d2[1]["i"] == 2
    @test d2[2][PString(:shift, "h")] == 1
    @test d2[2]["hi"] == 2
    @test d2[2]["ih"] == 1
    @test d2[3][PString(:shift, "h", "i")] == 1
    @test d2[3]["hih"] == 1
    @test d2[3]["ihi"] == 1

end

