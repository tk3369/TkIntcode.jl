# TkIntcode

This is the Intcode computer as described in Advent of Code 2019.

## Usage

Create a new program using the `intcode` constructor with specific I/O device, which can be anything that implements the generic functions `read_input` and `write_output`. By default, it supports `IO`, `Channel`, and `Function`.  To run the program, just call `start`.

Interface:
- `read_input(device)` must read from device and return an integer
- `write_output(device, data)` writes data into device

For example:

```julia
julia> out_channel = Channel(32)
Channel{Any}(sz_max:32,sz_curr:0)

julia> start(intcode("3,0,4,0,99", stdin, out_channel))
Enter input: 200

julia> take!(out_channel)
200
```
