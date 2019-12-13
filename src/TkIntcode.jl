module TkIntcode

export intcode, start

using OffsetArrays

mutable struct Intcode
    code::AbstractArray{Int}
    ip::Int
    input
    output
end

# Handling jump instructions
abstract type Jump end
struct JumpNext <: Jump end
struct JumpFar <: Jump 
    location
end

# Default code parser
function read_code(s::AbstractString)
    code = parse.(Int, split(s, ","))
    return OffsetArray(code, 0:length(code)-1)
end

# Intcode constructor
intcode(s::AbstractString, input, output) = Intcode(read_code(s), 0, input, output)

# I/O support
read_input(c::Channel) = take!(c)
write_output(c::Channel, data) = put!(c, data)

read_input(io::IO) = begin print("Enter input: "); parse(Int,readline(io)); end
write_output(io::IO, data) = println(io, data)

read_input(f::Function) = f()
write_output(f::Function, data) = f(data) 

# Start program
function start(ic::Intcode)
    while true
        i = ic.ip
        instruction = ic.code[i]
        op = instruction % 100      # rightmost two digits
        opmode = instruction ÷ 100  # shift right by two digits
        # println("ic $(ic.id): executing op=$op opmode=$opmTode i=$i")
        if op in (1,2,7,8)
            execute!(Val(op), Val(opmode), ic.code, ic.code[i+1], ic.code[i+2], ic.code[i+3])
            ic.ip += 4
        elseif op == 3
            execute!(Val(op), Val(opmode), ic, ic.input, ic.code, ic.code[i+1])
            ic.ip += 2
        elseif op == 4
            execute!(Val(op), Val(opmode), ic, ic.output, ic.code, ic.code[i+1])
            ic.ip += 2
        elseif op in (5,6)
            j = execute!(Val(op), Val(opmode), ic.code, ic.code[i+1], ic.code[i+2])
            if j isa JumpFar
                ic.ip = j.location
            else
                ic.ip += 3
            end
        elseif op == 99 
            break
        else
            println("Unknown op code $op")
        end
    end
end

execute!(::Val{1}, ::Val{000}, code, p1, p2, p3) = code[p3] = code[p1] + code[p2]
execute!(::Val{1}, ::Val{001}, code, p1, p2, p3) = code[p3] = p1       + code[p2]
execute!(::Val{1}, ::Val{010}, code, p1, p2, p3) = code[p3] = code[p1] + p2
execute!(::Val{1}, ::Val{011}, code, p1, p2, p3) = code[p3] = p1       + p2

execute!(::Val{2}, ::Val{000}, code, p1, p2, p3) = code[p3] = code[p1] * code[p2]
execute!(::Val{2}, ::Val{001}, code, p1, p2, p3) = code[p3] = p1       * code[p2]
execute!(::Val{2}, ::Val{010}, code, p1, p2, p3) = code[p3] = code[p1] * p2
execute!(::Val{2}, ::Val{011}, code, p1, p2, p3) = code[p3] = p1       * p2

function execute!(::Val{3}, ::Val{000}, ic, channel, code, p1)
    code[p1] = read_input(channel)
end

function execute!(::Val{4}, ::Val{000}, ic, channel, code, p1)
    write_output(channel, code[p1])
end

function execute!(::Val{4}, ::Val{001}, ic, channel, code, p1)
    write_output(channel, p1) 
end

execute!(::Val{5}, ::Val{000}, code, p1, p2) = code[p1] != 0 ? JumpFar(code[p2]) : JumpNext()
execute!(::Val{5}, ::Val{001}, code, p1, p2) = p1 != 0       ? JumpFar(code[p2]) : JumpNext()
execute!(::Val{5}, ::Val{010}, code, p1, p2) = code[p1] != 0 ? JumpFar(p2)       : JumpNext()
execute!(::Val{5}, ::Val{011}, code, p1, p2) = p1 != 0 ?       JumpFar(p2)       : JumpNext()

execute!(::Val{6}, ::Val{000}, code, p1, p2) = code[p1] == 0 ? JumpFar(code[p2]) : JumpNext()
execute!(::Val{6}, ::Val{001}, code, p1, p2) = p1 == 0       ? JumpFar(code[p2]) : JumpNext()
execute!(::Val{6}, ::Val{010}, code, p1, p2) = code[p1] == 0 ? JumpFar(p2)       : JumpNext()
execute!(::Val{6}, ::Val{011}, code, p1, p2) = p1 == 0       ? JumpFar(p2)       : JumpNext()

execute!(::Val{7}, ::Val{000}, code, p1, p2, p3) = code[p3] = code[p1] < code[p2] ? 1 : 0
execute!(::Val{7}, ::Val{001}, code, p1, p2, p3) = code[p3] = p1       < code[p2] ? 1 : 0
execute!(::Val{7}, ::Val{010}, code, p1, p2, p3) = code[p3] = code[p1] < p2       ? 1 : 0
execute!(::Val{7}, ::Val{011}, code, p1, p2, p3) = code[p3] = p1       < p2       ? 1 : 0

execute!(::Val{8}, ::Val{000}, code, p1, p2, p3) = code[p3] = code[p1] == code[p2] ? 1 : 0
execute!(::Val{8}, ::Val{001}, code, p1, p2, p3) = code[p3] = p1       == code[p2] ? 1 : 0
execute!(::Val{8}, ::Val{010}, code, p1, p2, p3) = code[p3] = code[p1] == p2       ? 1 : 0
execute!(::Val{8}, ::Val{011}, code, p1, p2, p3) = code[p3] = p1       == p2       ? 1 : 0

end # module
