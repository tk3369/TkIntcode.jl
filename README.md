# TkIntcode

This is the Intcode computer as described in Advent of Code 2019.

## Usage

Create a new program using the `intcode` constructor with specific I/O device, which can be anything that implements the generic functions `read_input` and `write_output`. By default, it supports `IO`, `Channel`, and `Function`.

Interface:
- `read_input(device)` must read from device and return an integer
- `write_output(device, data)` writes data into device

For examples:
```julia
intcode("3,0,4,0,99", stdin, stdout)
intcode("3,0,4,0,99", input_channel, output_channel)
intcode("3,0,4,0,99", () -> parse(Int, readline()), x -> println(x))
```