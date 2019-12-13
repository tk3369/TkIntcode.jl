using TkIntcode
using Test

@testset "TkIntcode.jl" begin

    # echo program
    let value = 123
        start(intcode("3,0,4,0,99", () -> value, x -> @test(x == value)))
    end

    # day5 part2 test1
    let code = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
        for value in 1:7
            start(intcode(code, () -> value, x -> @test(x == 999)))
        end
        start(intcode(code, () -> 8, x -> @test(x == 1000)))
        start(intcode(code, () -> 9, x -> @test(x == 1001)))
        start(intcode(code, () -> 10, x -> @test(x == 1001)))
    end

end
