# AoC2019

Working through [Advent of Code 2019](https://adventofcode.com/2019) in Elixir.

## Running

Each day is broken into a separate module in [`lib`](lib/), and each problem for each day 
can be invoked via IEX:

```bash
> iex -S mix
iex> Aoc.Day01.problem01()
```

Starting with the Day 3 problems, tests are included, which can be run with `mix test`. The test
code for each day can be found in [`test/aoc`](test/aoc).



# Solutions

 * [Day 01](#day-01) - ⭐️⭐️
 * [Day 02](#day-02) - ⭐️⭐️
 * [Day 03](#day-03) - ⭐️⭐️
 * [Day 04](#day-04) - ⭐️⭐️
 * [Day 05](#day-05) - ⭐️⭐️
 * [Day 06](#day-06) - ⭐️⭐️
 * [Day 07](#day-07) - ⭐️⭐️


## Day 01

**Problem**: [The Tyranny of the Rocket Equation](https://adventofcode.com/2019/day/1)

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

## Day 02

**Problem**: [1202 Program Alarm](https://adventofcode.com/2019/day/2)

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

## Day 03

**Problem**: [Crossed Wires](https://adventofcode.com/2019/day/3)

**Stars**: ⭐️⭐️

**Code**: [day03.ex](lib/aoc/day03.ex)

**Tests**: [day03_test.exs](test/aoc/day03_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), String Parsing, Recursion, List Expansion

Presented with a grid and two wires that traverse the grid, we need to make sense of where the wires intersect. For the
first problem, where we need to find the intersection closest to the origin of the wires, this is mostly straight forward:

 1. Parse the wire descriptions into tuples that better describe the direction of movement and the scale of movement.
 
Our overloaded `translate_move/1` function makes this part easy, turning a wire description like `R113` into `{:right, 113}`.

 2. Convert the move tuples into a list of all of the coordinates that the wire will pass through.
 
To convert a list of tuples with move descriptions like `{:right, 113}` into a list of points like `[{1, 1}, {1, 2}, ...]` we
turn to recursion, and count down each of the move descriptions to "unroll" a tuple like `{:right, 3}` into `[{1, 1}, {1, 2}, {1, 3}, {1, 4}]`.

 3. Use the list of points for each wire to find all of the points both wires occupy.
 
To make this a bit quicker we convert the list of points for one of our wires into a map, and then look up each point in
the other wire in the map of the first wire - if a point from the list of wire 2 is in the map of wire 1, they intersect.

 4. Convert this list of intersections into a distance metric, and find the shortest distance.

The problem defines a distance metric for us: the [Manhattan Distance](https://en.wikipedia.org/wiki/Taxicab_geometry), which is
the horizontal distance from the wire origin plus the vertical distance from the wire origin. Keep in mind, the wire coordinates
could be negative (the problem never specifies the dimensions of the grid we're working on), so the Manhattan Distance of an
intersection point at `{i_X, i_Y}` from the wire origin point at `{o_X, o_Y}` is:

```elixir
abs(i_X - o_X) + abs(i_Y - o_Y)
```

Solving problem two is mostly similar: instead of the Manhattan distance from the origin, we want to find the intersection
of the two wires that requires the least amount of total wire to get to. Our solution follows the same steps as for problem one,
with the added step of keeping track of how many moves it takes the wires to get to each point they pass through. In the
end, the final solution is similar: find the minimum value of the length of each wire for each intersection.

## Day 04

**Problem**: [Secure Container](https://adventofcode.com/2019/day/4)

**Stars**: ⭐️⭐️

**Code**: [day04.ex](lib/aoc/day04.ex)

**Tests**: [day04_test.exs](test/aoc/day04_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Predicates, List Manipulation

A password protected fuel depot! Instead of trying all six digit numbers, we have a few hints about how our
password is composed.

For both problem one and problem two we have a series of _predicates_: conditions that our candidate password 
needs to meet to be one of the possibly valid passwords. The bulk of our solution for both problems is the
functions we use to test each of the predicates. The predicates for requiring adjacent (duplicate) digits and
an always equal or increasing digit value when reading from left to right look roughly the same in predicate
form. For both we look at the first five digits of the candidate password one by one, and compare them to the
next digit:

```elixir
def always_increasing?(candidate) do
   
   digits = Integer.digits(candidate)
   
   0..length(digits) - 1
   |> Enum.map(
       fn idx -> 
           Enum.at(digits, idx) <= Enum.at(digits, idx + 1)
       end
   )
   |> Enum.all?(fn r -> r end)
    
end
```

To test for always increasing (or equal) digits, each digit is compared to the next digit with `Enum.at(digits, idx) <= Enum.at(digits, idx + 1)`,
while the test for adjacent duplicate digits compares each digit with `String.at(c_str, idx) == String.at(c_str, idx + 1)`. Why strings in one
function and integers in another? Zero reason what so ever - honestly just writing the first thing that came to mind for each.

Those two predicate functions are enough to solve the first problem, we can pass those, along with the bounds of our
password candidates, to the `candidate_passwords/3` function, and determine how many possible passwords we're dealing with:

```elixir
candidate_passwords(124075, 580769, [&adjacent_digits?/1, &always_increasing?/1])
|> length()
```

Since our `candidate_passwords/3` function takes a _list_ of predicates, we can easily extend it to solve problem two
by writing another predicate: our candidate passwords must contain a series of _exactly two_ duplicate digits in a row. Multiple
duplicates of different digits can exist, but one set must be two copies, no more no less. This predicate is a
bit trickier, as a simple iterator like the first two predicates won't work - we need to look further ahead (or behind) than
a single digit. We want to break apart a candidate password into _runs_ of duplicates, so that a number like `123345666` becomes
a list like `[ [1], [2], [3, 3], [4], [5], [6, 6, 6]]`. This new list is easy to evaluate for our predicate - is any sub list
of integers exactly length 2? With a function that breaks our number down in this way (see [`take_sequences/1`](https://github.com/patricknevindwyer/advent_of_code_2019/blob/master/lib/aoc/day04.ex#L106)), this new
predicate function is easier to write:

```elixir
def exactly_two_adjacent_digits?(candidate) do
    candidate
    |> take_sequences()
    |> Enum.any?(fn seq -> length(seq) == 2 end)    
end
```

Now a solution to problem two looks almost exactly like a solution to problem one:

```elixir
candidate_passwords(124075, 580769, [&adjacent_digits?/1, &always_increasing?/1, &exactly_two_adjacent_digits?/1])
|> length()
```

## Day 05

**Problem**: [Sunny with a Chance of Asteroids](https://adventofcode.com/2019/day/5)

**Stars**: ⭐️⭐️

**Code**: [day05.ex](lib/aoc/day05.ex)

**Tests**: [day05_test.exs](test/aoc/day05_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Pattern Matching, Virtual Machine, Input/Output Virtualization

The Intcode Virtual Machine returns, and introduces more complexity:

 - new instructions (input, output, instruction pointer jumping, and two comparisons) with different parameter sizes
 - memory modes for parameters (parameter as literal value, parameter as memory location of actual value)
 
While our solution includes a whole new copy of the Intcode VM we wrote for Day 02, it really just modifies the core
features of the original VM to add the new instructions and features.

Instead of hard-coding literal values in the pattern matching of the `eval_at/3` function, we use a new [`decode_instruction/1`](https://github.com/patricknevindwyer/advent_of_code_2019/blob/master/lib/aoc/day05.ex#L289) 
function, which decodes the various attributes (like parameter memory mode) of each op code. So instead of looking
at an integer opcode like `1002`, we get a decoded instruction like `{:multiply, :position, :position, :position}` which
tells us that our multiply instruction is using memory addressing (`:position`) instead of literal mode (`:immediate`) for the
two parameters and the location to store the multiply result.

Because our instructions now have different parameter counts, our program instruction pointer should move differently. The
`eval_at/3` function now returns an instruction count when issuing a `:continue`, and a literal memory location for the
new `:jump` return code. The `eval_program/3` function now uses these values to properly move the instruction pointer, and
keep the program running.

This update to the Intcode virtual machine also included the `input` and `output` functions. For the output, we just print
to standard out. Input should come from the user - and it would have been simple to hard code this. But that made it difficult
to test - we want the test code to be able to specify an input automatically. By luck (as we'll see in a later problem set for
Day 07) the best way to make input work for both testing and user mode was to supply an _input function_ to the virtual machine.
This input function is called whenever an input Opcode is encountered. In user mode, this just calls the `default_input/0`
function:

```elixir
def default_input() do
    {v, _} = IO.gets("input: ") |> Integer.parse()
    v
end
```

The default input encapsulates what we would have hard coded - get an input from the user via STDIN, and parse it into an
integer. Because the input function can change, we can automate input when testing. The third parameter to `eval_program/3` is
a keyword list, with the only (optional) keyword being `input_function`. When we're testing, we pass in a function that returns 
a literal value when a program asks for an input, like:

```elixir
[input_function: fn -> 8 end]
````

With these updates to the Intcode VM in place, the solution to problem one is:

```elixir
def problem01() do
   eval_program(program) 
end
```

and the solution to problem two is just as simple. Instead of requiring human interaction for the one input to the problem,
we use the input function option we added during testing:

```elixir
def problem02() do
   eval_program(program, 0, [input_function: fn -> 5 end]) 
end
```

## Day 06

**Problem**: [Universal Orbit Map](https://adventofcode.com/2019/day/6)

**Stars**: ⭐️⭐️

**Code**: [day06.ex](lib/aoc/day06.ex)

**Tests**: [day06_test.exs](test/aoc/day06_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Map, Tree, String Parsing

Lots of things orbiting each other, and we need to see if it all makes sense. It all starts with an orbital catalog,
as list (or file) of which bodies orbit each other. Every entry in the catalog is of the form `AAA)BBB`, which means
that object `BBB` orbits object `AAA`. If we parse all of the entries, we'll build up a tree of orbits, all centered
on the Center of Mass (`COM`). Should we approach this as a tree problem? Nah - in my experience, we can solve it quicker
by using maps. Each entry in our map (dictionary, hash, whatever) has a key of an orbital body, with the value being
what this body orbits (so in our example our simple map would be `%{"BBB" => "AAA"}`).

The core part of the solutions for problems one _and_ two is building this map of orbits:

```elixir
orbits = "data/day06/orbits.txt"
|> File.read!()
|> String.split("\n")

catalog = orbits
|> build_orbit_map()
```

With this map of orbits, we can easily find individual objects in the catalog, and using recursion we can map any
object to it's orbits all the way to the Center of Mass (`COM`). Effectively we're encoding a tree as a map or as
an [adjacency list](https://en.wikipedia.org/wiki/Adjacency_list).

The remainder of problem one is fairly straight forward - calcuate the the number of objects each body in the catalog
is orbiting (an _orbital checksum_), and sum the total for the catalog:

```elixir
catalog
|> Map.keys()
|> Enum.map(
   fn body ->
       orbit_checksum(catalog, body)
   end
) 
|> Enum.sum()
```

Problem two is interesting - orbital transfers is finding the path through the orbit catalog between two objects. This is
_distinctly_ a tree problem. We could venture down the rabbit hole of [spanning trees](https://en.wikipedia.org/wiki/Spanning_tree)
looking for different optimal algorithms, but we know that our orbital catalog has no cycles, and is otherwise a simple
directed graph - so [we're going to cheat](https://github.com/patricknevindwyer/advent_of_code_2019/blob/master/lib/aoc/day06.ex#L129). Given two bodies (`YOU` and `SAN` in the problem definition), we find the path
between each of the two and the Center of Mass (`COM`). This will be a list of bodies for each, the objects each orbits
all the way down to the Center of Mass. Given list A, we can determine where each body exists (if it exists) in list B. The entry
in both A and B with the smallest index is the _intercept_ between the two paths. The number of orbital transfers to
get between A and B is the sum of the offset of the _intercept_ in the orbit lists for A and B. Finding the answer for
problem two consists of finding the number of orbital transfers between where `YOU` are and where `SAN` is in the galaxy:

```elixir
body_a = catalog |> Map.get("YOU")
body_b = catalog |> Map.get("SAN")

catalog |> min_transfers(body_a, body_b)
```

## Day 07

**Problem**: [Amplification Circuit](https://adventofcode.com/2019/day/7)

**Stars**: ⭐️⭐️

**Code**: [day07.ex](lib/aoc/day07.ex)

**Tests**: [day07_test.exs](test/aoc/day07_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Pattern Matching, Virtual Machine, Input/Output Virtualization, Processes

Remember in Day 05 when we added a bunch of instructions to the Intcode Virtual Machine, we noted that virtualizing the input opcode to use a
function (letting us automate input) was a lucky coincidence? That's because on day 7 we need to virtualize input _and output_ of the virtual machine
so that different VMs running an Intcode program can communicate. That's the heart of problems one and two: after initialization with an input
parameter we supply, five different Intcode VMs communicate their output to the input of the next VM. This is a bit like a computer network, or
multiple programs piping data between each other via **STDIN** and **STDOUT**. 

We need to make some superficial changes to our virtual machine in the `eval_at/3` function to use newly virtualized output methods (like we did earlier
for input methods). Running multiple Intcode VMs that can pipe data back and forth in Elixir is really, really easy - we spawn a new process for each
VM. Using the built in `send` and `receive` functions to move data between processes, and the virtualized I/O methods we've added to the VM, we've
got a fairly quick solution.

Our VMs will take an *input_function* that uses `receive` to wait for data:

```elixir
def receive_input() do
  receive do
     v -> v 
  end 
end
```

and an *output_function* that sends data between processes. The output function is actually a function that generates a function: we we create
our virtual machines, we specify _which process_ each VM should send it's output to:

```elixir
def send_output(dest_pid) do
  fn v ->
     send(dest_pid, v)
  end 
end
```

we can use these functions together to setup a VM running in a separate process:

```elixir
spawn_program(
    program, 
    [
        input_function: &receive_input/0, 
        output_function: send_output(amp_e)
    ]
)
```

Here we've launched a VM running `program` that waits for input (from another VM, _or from another source_), and sends output to the process
named `amp_e`.

The full solution for problem one launches the five VMs for the five amplifiers in reverse order (because we need a process ID for one VM to send 
output to another), with an extra virtualized function (the `halt_function`) for the last amplifier/VM, so we can wait in our main process for
everything to finish. The VMs are launched, and run, for a specific set of initialization parameters, in [`run_amplifiers/2`](https://github.com/patricknevindwyer/advent_of_code_2019/blob/master/lib/aoc/day07.ex#L63).

For problem two, a feedback loop is introduced. The last amplifier/VM in the series send output to the _first_ amplifier/VM, creating a loop. Only
when the last VM in the series issues a `halt` command is the program series complete - the last output from the last VM before the `halt` command
is our final answer. This poses a small problem: our setup for solving problem one required knowing the process ID of where to send output when
launching each VM. Because we're starting a _loop_ - where the last VM send output to the first, this is impossible. To get around this we exploit the
fact that there _is_ a process ID we always know: the main process. We deploy a [trampoline](https://en.wikipedia.org/wiki/Trampoline_(computing)#) in
our main process, which is already collecting output from the last VM. When the main process receives an output message from the last VM in the
series, it forwards that value on to the _first_ VM, completing the loop. The VM series with feedback is in [`run_feedback_amplifiers/2`](https://github.com/patricknevindwyer/advent_of_code_2019/blob/master/lib/aoc/day07.ex#L87).

The solution code in `problem01/0` and `problem02/0` generates the permutations of the VM configuration parameters, runs each VM, and finds the
maximum output value of the amplifier chain.