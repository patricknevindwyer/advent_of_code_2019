# AoC2019

Working through [Advent of Code 2019](https://adventofcode.com/2019) in Elixir.

## Running

Each day is broken into a separate module in [`lib`](lib/), and each problem for each day 
can be invoked via IEX:

```bash
> iex -S mix
iex> Aoc.Day01.problem01()
```

Starting with the Day 3 problems, tests are included, which can be run with `mix test`.



## Solutions

 * [Day 01](#day-01) - ⭐️⭐️
 * [Day 02](#day-02) - ⭐️⭐️
 * [Day 03](#day-03) - ⭐️⭐️
 * [Day 04](#day-04) - ⭐️⭐️
 * [Day 05](#day-05) - ⭐️⭐️
 * [Day 06](#day-06) - ⭐️⭐️
 * [Day 07](#day-07) - ⭐️⭐️


### Day 01

**Stars**: ⭐️⭐️

**Code**: [day01.ex](lib/aoc/day01.ex)

**Tests**: -

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recursion

Our ship needs fuel, let's calculate it. For problem one we use the literal equation for fuel per mass, and map
each of the ship modules across the fuel function. Simplifying out the comments, the heart of the solution is
only three lines:

```elixir
module_masses
|> Enum.map(&basic_fuel/1)
|> Enum.sum()
```  

For problem two, we deal with the (drastically simplified) [tyranny of the rocket equation](https://en.wikipedia.org/wiki/Tsiolkovsky_rocket_equation),
and wrap the basic fuel equation in a recursive function:

```elixir
def recurse_fuel(mass) do
    extra = basic_fuel(mass)
    if extra > 0 do
        extra + recurse_fuel(extra)
    else
        0
    end
end
```

Solving for problem two can then be reduced, again, to a simple mapping:

```elixir
module_masses
|> Enum.map(&recurse_fuel/1)
|> Enum.sum()
```

### Day 02

**Stars**: ⭐️⭐️

**Code**: [day02.ex](lib/aoc/day02.ex)

**Tests**: -

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recursion, Pattern Matching, Virtual Machine

Our first encounter with the _Intcode_ instruction set - we need to write a rudimentary virtual machine that handles
three different instructions: `add`, `multiply`, and `halt`. We'll keep things simple for now - the virtual machine
is only two functions: `eval_program` and `eval_at`. 

The `eval_program/2` function is both the entry point and the recursion function for our virtual machine. At each step of the program
it passes the current instruction pointer, along with the entire program, to the `eval_at` function. The `eval_at/2` function can
return either a `:halt` or `:continue` - if `eval_program` gets a `:continue` message, it moves the instruction pointer and recurses
into itself to keep the program running, otherwise it halts and returns the current program state.

For the `eval_at/2` function we use pattern matching against the literal opcodes defined in the problem to determine
what to do at every step of the program. Our opcodes are really simple at this point: every parameter is a literal
value (_immediate_ mode, in the later definitions of the Intcode instruction set), which we evaluate, store, and
return.

Solving problem one, once we have a working virtual machine, is easy - just run the program through the VM:

```elixir
program |> eval_program() 
```

For problem two, things are a bit more involved - we need to run our program through the Intcode VM multiple times,
using a different set of initial parameters for our first instruction in the program each time. The answer to the
problem is the set of parameters that result in our Intcode program returning a specific value.