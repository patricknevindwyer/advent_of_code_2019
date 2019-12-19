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

Solution summaries:

 * [Day 01](#day-01) - ⭐️⭐️ - The Tyranny of the Rocket Equation
 * [Day 02](#day-02) - ⭐️⭐️ - 1202 Program Alarm
 * [Day 03](#day-03) - ⭐️⭐️ - Crossed Wires
 * [Day 04](#day-04) - ⭐️⭐️ - Secure Container
 * [Day 05](#day-05) - ⭐️⭐️ - Sunny with a Chance of Asteroids
 * [Day 06](#day-06) - ⭐️⭐️ - Universal Orbit Map
 * [Day 07](#day-07) - ⭐️⭐️ - Amplification Circuit
 * [Day 08](#day-08) - ⭐️⭐️ - Space Image Format
 * [Day 09](#day-09) - ⭐️⭐️ - Sensor Boost
 * [Day 10](#day-10) - ⭐️⭐️ - Monitoring Station
 * [Day 11](#day-11) - ⭐️⭐️ - Space Police
 * [Day 12](#day-12) - ⭐️⭐️ - The N-Body Problem
 * [Day 13](#day-13) - ⭐️⭐️ - Care Package
 * [Day 14](#day-14) - ⭐️⭐️ - Space Stoichiometry
 * [Day 15](#day-15) - ⭐️⭐️ - Oxygen System
 * [Day 16](#day-16) - ⭐️⭐️ - Flawed Frequency Transmission
 * [Day 17](#day-17) - ⭐️⭐️ - Set and Forget
 * [Day 18](#day-18) -  - Many Worlds Interpretation
 * [Day 19](#day-19) - ⭐️⭐️ - Tractor Beam
 

Support modules:

 * [Intcode VM](lib/aoc/intcode.ex) - Up-to-date Intcode Virtual Machine, with support, IO, and program functions


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


## Day 08

**Problem**: [Space Image Format](https://adventofcode.com/2019/day/8)

**Stars**: ⭐️⭐️

**Code**: [day08.ex](lib/aoc/day08.ex)

**Tests**: [day08_test.exs](test/aoc/day08_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Image Decoding

The elves have sent us an image in _Space Image Format_, an image encoding with pixel data on multiple layers. 

For problem one we need to setup a full image decoder to get our layer data, and test that it isn't corrupted. The image decoder itself isn't too
hard to piece together - we read in a data file, parse out the pixel data, and convert it to integers. The only interesting part is breaking the
data into layers - for this we add another new chunking function, `take_chunks/3`. This function recursively breaks a single list (the pixel data
for our entire image) into sublists of a specific size (the pixel data for each layer).

The remainder of problem one is testing the layer data for corruption. The Elixir methods for working with enumerables are super useful here - one
set of enumerations maps every layer to the number of zeroes in the layer, and a second set of enumerations takes that layer and counts up the
ones and twos. Problem one solved.

We have image data on hand, it would make sense that we should see the image, right? Problem two defines _how_ the image layers work together, with
some pixel values being transparent, and others being black or white. We need to flatten our layers to find the _real_ pixel value, and display the
results.

For the flattening function, the built in Elixir Enum functions really shine:

```elixir
def flatten_image(layers) do
    layers
    |> Enum.zip()
    |> Enum.map(
        fn pixel_set ->
            pixel_set
            |> Tuple.to_list()
            |> Enum.drop_while(fn p -> p == 2 end)
            |> List.first()
        end
    )
end
```

Knowing we have equally sized layers, the `Enum.zip/1` function turns our list of layer data into a list of pixel values grouped by pixel. So a
list of layers that started with `[ [a, b, c, ...], [d, e, f, ...], [g, h, i, ...], ...]` would now look like `[{a, d, g}, {b, e, h}, {c, f, i}, ...]`. We
can then map each pixel tuple, walking through the values until we find the first non-transparent value for that pixel. The result of the `Enum.map/2` is
a new list of pixel data - our flattened image.

The image we're working with is small (25 pixels wide, by 6 pixels tall) - we could easily display that on STDOUT using spaces and characters. The
`display_image/2` function takes a flattened image, and walks through the pixel data row by row, printing a space for black pixels, and a `▊` character
for white pixels. The `take_chunks/3` function we wrote earlier for the image decoder is helpful here - we use it to break down our flattend image
into rows of pixels.

In the end, the solution to problem two is drastically simpler than the solution for problem one:

```elixir
path_to_image
|> load_image()
|> flatten_image()
|> display_image()
```

If the pattern of puzzles so far is any indication, we'll being seeing the Space Image Format again soon, probably with more data encoded in the image,
and larger image sizes. Who knows, maybe we even write a SIF decoder and display in Intcode...

## Day 09

**Problem**: [Sensor Boost](https://adventofcode.com/2019/day/9)

**Stars**: ⭐️⭐️

**Code**: [day09.ex](lib/aoc/day09.ex)

**Tests**: [day09_test.exs](test/aoc/day09_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Pattern Matching, Virtual Machine, Input/Output Virtualization, Processes, State

Another day, another Intcode virtual machine update. This round, we add the following to our VM:

 - A new memory mode - relative addressing
 - A new _op code_ - adjusting the _relative memory mode_ base value
 - Large number support (no change for us - we got that out of the box with standard Elixir integers)
 - Expanded VM memory
 
The new memory mode seems straight forward, but causes us the most work. Up until now our Intcode virtual machine was setup to track
the program code as the only mutable state - everything else was computed on the fly. We knew more state was probably going to be
required (like registers, external memory, or, it turns out, an alternate instruction pointer), but we'd put off adding an explicit
VM state variable. Because we're running our VM with recursion, the state data needs to be tracked in a bunch of places - every return
code (like `continue` and `jump`), and every call into `eval_program/4` and `eval_at/4`. Once we're confident the VM state is being
handed around properly (we're using a atom index map, for ease of use), we can focus on the new memory mode.

The `relative` memory mode works from a base address (starting at `0`), which can be used as a lookup for any parameter by _adding_ the
parameter value to the relative base address. This is a bit like `position` mode, but requires some extra book-keeping. It would be
fairly boring if the base address for `relative` mode was always the same, so there's a new Opcode that can modify the base address.

Up until now our virtual machine has assumed that result values from opcodes (like `multiply`, `add`, and `less_than`) were always
in `position` mode. The BOOST program for Day 9 runs diagnostics on the virtual machine, and now tests to make sure position and relative
mode both work for storage addresses. This requires a minor update to our VM to catch these circumstances.

With added memory modes it makes sense to _finally_ abstract away the parameter lookup that has been hard coded into every instruction
case. This removes some error prone code, and reduces the overall foot print of each instruction. In our `add` instruction handler, the
parameter value lookup turns from:

```elixir
[l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)

l_val = case l_addr_mode do
    :position -> Enum.at(program, l_addr)
    :immediate -> l_addr
end

r_val = case r_addr_mode do
    :position -> Enum.at(program, r_addr)
    :immediate -> r_addr
end
```

into:

```elixir
[l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)

l_val = decode_parameter(program, state, l_addr, l_addr_mode)
r_val = decode_parameter(program, state, r_addr, r_addr_mode)
```

Much nicer.

The last bit of Day 9 updates involves _how much space_ is allocated for a program. The previous versions of our VM, and the Intcode
programs it ran, always worked within the address space of the provided program - if a program was only 100 instructions long, it never
tried to access a value beyond address 100. This update to Intcode, and the diagnostic program it runs, doesn't follow this limit. It explicitly
requires memory beyond the end of the literal program. At some point we may need a more elegant solution to this problem, like dynamically extending
the program space. For now, we remap programs running on the Intcode VM into a larger, `0` padded list before running.

With these updates in place, along with a utility method to load a program from a file, the solutions for problems one _and two_ are easy:

```elixir
"data/day09/boost.ic"
|> program_from_file()
|> run_intcode()
``` 

An input of `1` for problem one, an `2` for problem two, and we're done!


## Day 10

**Problem**: [Monitoring Station](https://adventofcode.com/2019/day/10)

**Stars**: ⭐️⭐️

**Code**: [day10.ex](lib/aoc/day10.ex)

**Tests**: [day10_test.exs](test/aoc/day10_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Occlusion, 2D Graphics, Geometry

A break from Intcode instructions to work with... geometry! The wording of the initial problem for Day 10 is very precise, and while
it makes great big gesturing motions towards [occlusion culling](https://en.wikipedia.org/wiki/Hidden-surface_determination) in a full
2D space, because of the _very_ precise wording of the problem, we're going to side step the (big, hairy, frustraing) mess of generating
a full scene representation and take advantage of the fact that our asteroid map is perfectly mapped to an integer grid.

Because we're on an integer grid (or just a standard planar graph), and all our asteroids are on grid points (like `(3, 4)` or `(11, 0)`),
we can use a really simple _slope_ calculation to determine which asteroids block view of each other. The algorithm is fairly simple. To determine
if the view from one asteroid to another is occluded:

 - Given three asteroids, at `(1, 1)`, `(5, 7)`, and `(7, 10)` called `A`, `B`, and `C`
 - The slope from `A` to `C` is `6/9`
 - The simplified fraction of the slope is `2/3`
 - Walk up the coordinates from `A` to `C` by the simplified slope
 - first step is `(3, 4)`, no asteroid there...
 - second step is `(5, 7)`, and asteroid `B` is there!
 - last step is `(7, 10)`, which is asteroid `C`
 - We found _at least_ one other asteroid between `A` and `C`, so the view of `C` is **occluded** when looking from `A`

We know ahead of time where all of our asteroids are (and they're just points on a plane), so it's _drastically_ easier to evaluate the
view from every asteroid of every other asteroid to determine what is visible from where, than it is to try and run a full 2D surface occlusion. It
may be `O(n^2)` over the number of asteroids to evaluate problem one, but that beats the speed of a true 2D occlusion algorithm (ray tracing is _notoriously_
compute intensive). In the end we reduce the computation time even further (for problem one at least) by building a Map of know asteroids, which takes
the inner loop (of checking for existing asteroids) down to an `O(1)` operation.

Using our occlusion algorithm to cheat at our visibility calculations, and wrapping the loop over every asteroid to see _what_ is visible from _where_, 
it's fairly easy to solve problem one:

```elixir
asteroid_map = asteroid_map_from_file("data/day10/problem_01.map")            
highest_visibility_asteroid(asteroid_map)
```

Solving problem two builds on problem one. We want to find the _vaporization_ order, which is explained in the problem statement. Knowing that
we can quickly determine which asteroids are visible, and which are occluded, from any given vantage point, the algorithm for building our
vaporization ordered list becomes:

 - given an asteroid map, and a central asteroid from which we'll be vaporizing everything
 - remove any occluded asteroids from the map
 - order the remaining asteroids in clockwise direction from the top, in the order they'd be hit
 - build the list of asteroids _we didn't hit_
 - recurse until done
 
```elixir
def vaporization_order([], _asteroid), do: []
def vaporization_order(asteroid_map, asteroid) do

   # remove occulusions
   unoccluded = remove_occluded(asteroid_map, asteroid)
   
   # order by angle
   ordered_asteroids = order_asteroids_by_angle(unoccluded, asteroid)
   
   # remove from original
   remaining_asteroids = remove_from(asteroid_map, ordered_asteroids ++ [asteroid])
   
   # recurse
   ordered_asteroids ++ vaporization_order(remaining_asteroids, asteroid)
   
end
``` 

The only tricky operation is the `order_asteroids_by_angle/2` method; our coordinate space is wonky (we're in pixel orientation, not graph), and
we want to start from the very top, and go clockwise. The [atan2](https://en.wikipedia.org/wiki/Atan2) function will get us a mostly useful angle
in the ordering we want, given the relative position of our origin asteroid and any other asteroid, but we'll need to mess with the values a bit.
Given an origin asteroid at `(o_x, o_y)` and a candidate asteroid in a sorting algorithm at `(c_x, c_y)` we use the modified `atan2` of:

```elixir
:math.atan2((c_x - o_x + 0.001) * -1, (c_y - o_y))
```

This orients our mapped ordering space so the atan2 starts in the **up** direction, and proceeds normally clockwise. Oh, and the `0.001` term pushes
the first parameter of `atan2` so that a value of `0` doesn't hit an asymptote of `atan2` (which results in vertically aligned coordinates mapping
strangely).

The elves are betting on which asteroid will be the 200th destroyed. Problem two tells us:

```elixir
asteroid_map = asteroid_map_from_file("data/day10/problem_01.map")            
{laser_base, _} = highest_visibility_asteroid(asteroid_map)

{bet_x, bet_y} = asteroid_map
|> vaporization_order(laser_base)
|> Enum.at(199)
```

Isn't geometry fun?


## Day 11

**Problem**: [Space Police](https://adventofcode.com/2019/day/11)

**Stars**: ⭐️⭐️

**Code**: [day11.ex](lib/aoc/day11.ex)

**Tests**: [day11_test.exs](test/aoc/day11_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Pattern Matching, Virtual Machine, Input/Output Virtualization, Processes, State, 2D Graphics, Turtle Graphics

Image generation meets Intcode. My prediction from Day 08 wasn't too far off; we may not be writing a SIF decoder, but we are creating images using 
Intcode programs. This doesn't require any modifications to the Intcode VM itself, but we will add a few methods to manage state for our [Turtle](https://en.wikipedia.org/wiki/Turtle_graphics)^W Hull Bot as in navigates a 2D space to draw our ship registration code.

Managing state for the Hull Bot isn't terrible - a few methods for moving the bot and handling input and output, and a few test methods for simulating
bot movement for testing purposes. With an extra few methods for re-routing input and output from the Intcode VM (I lied - we modified the VM start method
slightly, so that we could specify how to await VM IO) to the Hullbot, we have a working first problem solution - we know the size of the test area, so
no extra configuration required. The _counting_ part of the problem (how many spaces actually get painted) is solved with a bit of a cheat: every space on
the hull starts out set to `-1`, or _unpainted_. When painted, the space is set to `0` for black, and `1` for white. When it comes time to test the value
on a tile (or later to draw the tiles) a `0` _or a_ `-1` is treated as black.

Handling the IO for the interaction between the Intcode VM and the Hull Bot is done with a set of `await_*` functions. Because we know that output from
the VM will always start with a paint instruction, and then a move instruction, we can chain together two `await_*` functions that expect this
ordering:

```elixir
def await_paint(hull_bot) do

    receive do
       :halt -> hull_bot
       
       {:input, dest} -> 
           send_hull_bot_sensor_input(hull_bot, dest) 
           await_paint(hull_bot)
           
       v ->
           
           hull_bot
           |> hull_bot_paint(v)
           |> await_move()
    end
end

def await_move(hull_bot) do
    
    receive do
        :halt -> hull_bot
    
        {:input, dest} -> 
            send_hull_bot_sensor_input(hull_bot, dest) 
            await_move(hull_bot)
        
        v ->
            hull_bot
            |> hull_bot_rotate_and_move(rot_by(v))
            |> await_paint()
    end        
end
```

Both functions listen for input requests from the VM, where we read the current tile of the Hull Bot and send the color as input to the Intcode
program, as well as for the **halt** instruction, which signals program termination. When `await_paint/1` receives an output value, it informs
the Hull Bot, and passes `await` control on to the `await_move/1`. The `await_move/1` function passes output to the Hull Bot to control movement,
and then hands `await` control _back_ to `await_paint/1`, and the cycle continues. 

For problem two, we have a slight issue - it's never specified _where_ the bot will start, or _how big_ the hull space is that might get painted. There
are a handful of approaches we could take: automatic resizing, iterative testing to resize when the VM crashes, etc. We take a bit simpler approach: draw
in a really large space, and crop the image space when we're done to _just the tiles_ that got painted. In this case our hacky solution for counting tiles
in problem one saves us _a ton_ of extra work in problem two. 
 
In the end the solutions for problem one and two are _very_ similar. Run a hull bot program, and count painted panels:

```elixir
run_hull_bot(program, hull_bot)
|> painted_panel_count()
```

or run a hull bot and display the results:

```elixir
run_hull_bot(program, hull_bot)
|> display_hull()
```

our output is a (sort of nice) ASCII image output:

```bash
  ▊▊  ▊  ▊  ▊▊  ▊  ▊ ▊▊▊▊ ▊▊▊▊ ▊▊▊  ▊  ▊  
 ▊  ▊ ▊  ▊ ▊  ▊ ▊  ▊    ▊ ▊    ▊  ▊ ▊ ▊   
 ▊  ▊ ▊▊▊▊ ▊    ▊▊▊▊   ▊  ▊▊▊  ▊  ▊ ▊▊    
 ▊▊▊▊ ▊  ▊ ▊    ▊  ▊  ▊   ▊    ▊▊▊  ▊ ▊   
 ▊  ▊ ▊  ▊ ▊  ▊ ▊  ▊ ▊    ▊    ▊    ▊ ▊   
 ▊  ▊ ▊  ▊  ▊▊  ▊  ▊ ▊▊▊▊ ▊▊▊▊ ▊    ▊  ▊ 
```


## Day 12

**Problem**: [The N-Body Problem](https://adventofcode.com/2019/day/12)

**Stars**: ⭐️⭐️

**Code**: [day12.ex](lib/aoc/day12.ex)

**Tests**: [day12_test.exs](test/aoc/day12_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Structs, Agent Based Simulation, Simulation, Multi-variate analysis

Given that we're flying through space searching for Santa, it was only a matter of time before we encountered the [N-Body Problem](https://en.wikipedia.org/wiki/N-body_simulation) - thankfully it's only for four celestial bodies. And thankfully (I guess?) problem
one is deceptively simple: we need to build a system simulator that handles three spatial dimensions and velocity. The velocity calculations are
super simple, and the dynamics of each step in the simulation are clear, concise, and fast. A fair bit of test code to make sure we didn't miss
anything, but the solution for problem one is quick:

```elixir
bodies_from_file("data/day12/problem_01.bodies")
|> step_bodies(1000)
|> system_energy()
```

Nothing surprising, nothing _terribly_ difficult. Stepping the simulation forward by `N` steps is reasonably quick, with the book keeping taken
care of by the the support code for our `Body` struct. Calculating system energy is a closed form equation. Hmm. Something _feels_ wrong. Like an
ominous cloud on the horizon.

That ominous cloud is problem two. The premise is simple, and doesn't directly change the way we've built our simulation so far: determine how
many steps it takes for our N-Body system to _exactly_ repeat a previous state, including positions and velocities. For the first test case this
is easy: just track the previous states (we use a `MapSet`), and step forward until we hit a known state. For the first example this only takes
a few thousand steps. Easy.

For the second example (and the problem two system of bodies) this same approach would take prohibitively long, if we could even find a computer
with enough memory to hold our history of previous states. At a million steps per second, it would take approximately 10 years to solve the problem
two system. Looking at the problem for awhile (and digging through Reddit, with a h/t to [What am I not seeing?](https://www.reddit.com/r/adventofcode/comments/e9jxh2/help_2019_day_12_part_2_what_am_i_not_seeing/) ), carefully reading the problem statement's
admonishment to "find a more efficient way to simulate the universe", and staring off into the void for about 10 minutes, the solution presented
itself:

> the three spatial dimensions are independent of one another

in our simulation calculations the three dimensions operate independently - velocity in the `x` direction is only effected by the `x` location of
the other bodies, `y` by `y`, etc. This means we can run the simulation, and only look for a repeat in system state in a single dimension. If we
find when the `x`, `y`, and `z` dimensions repeat independently (which is, hopefully, a _much_ more tractable calculation), we can use that information
to determine when the entire system would repeat in the combined dimensions using a Least Common Multiple. 

We can then write a function to calculate the number of steps for the full system to repeat a previously seen state with:

```elixir
def steps_until_repeat(bodies) do        
    state_map = MapSet.new() |> MapSet.put(state_vector(bodies, :x))
    x_steps = steps_until_repeat(bodies, :x, state_map, 0)
    
    state_map = MapSet.new() |> MapSet.put(state_vector(bodies, :y))
    y_steps = steps_until_repeat(bodies, :y, state_map, 0)
    
    state_map = MapSet.new() |> MapSet.put(state_vector(bodies, :z))
    z_steps = steps_until_repeat(bodies, :z, state_map, 0)
    
    lcm(x_steps, lcm(y_steps, z_steps))
end
```

With the `steps_until_repeat/1` function, the solution to problem two becomes:

```elixir
bodies_from_file("data/day12/problem_01.bodies")
|> steps_until_repeat
```

Even with our optimized solution it takes about 10-20 seconds to solve problem two, which makes sense. The system doesn't repeat itself until
well after 320 _trillion_ steps.


## Day 13

**Problem**: [Care Package](https://adventofcode.com/2019/day/13)

**Stars**: ⭐️⭐️

**Code**: [day13.ex](lib/aoc/day13.ex)

**Tests**: [day13_test.exs](test/aoc/day13_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Pattern Matching, Virtual Machine, Input/Output Virtualization, Processes, State, 2D Graphics, Game Emulation

We're building a [MAME](https://en.wikipedia.org/wiki/MAME) system, are't we?

```bash
▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊                                  
▊                                            ▊                                  
▊ =  = == =  ====                            ▊                                  
▊  =  == =     =                         =   ▊                                  
▊           =     =               =     ==== ▊                                  
▊ =  ===    =                                ▊                                  
▊ == =                                       ▊                                  
▊          =                     =         = ▊                                  
▊                                     =   =  ▊                                  
▊      =                                     ▊                                  
▊     ====                          =        ▊                                  
▊      ==  =                                 ▊                                  
▊                                            ▊                                  
▊                          =           ==    ▊                                  
▊                                       =    ▊                                  
▊      =                                     ▊                                  
▊                                       *    ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊    =                                       ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊ 
```

The elves have sent a care package - an arcade game that can run on our Intcode machine, provided we wire up an input system. The
game state setup is similar to our Hull Bot - tracking and updating state through VM outputs. This is a good time to take the opportunity
to move our (hopefully nearing complete) Intcode VM into it's own module, and add a generalized output redirection method:

```elixir
Intcode.await_io(
    game_state, 
    output_function: &handle_game_instruction/2, 
    output_count: 3, 
    input_function: &handle_game_input/1
)
```

The `await_io/2` function passes a state variable, much like Elixir's [GenServer](https://hexdocs.pm/elixir/GenServer.html). With `output_function`
and `output_count` parameters we can gather up a defined number of VM outputs before sending them on to a handler function - for our arcade game
the outputs will always be three consecutive values for updating the game.

We could manually provide input to our program, but that sounds like it could take awhile. Instead we'll have the game auto-play:

```elixir
def handle_game_input(game_state) do
            
    {ball_x, _} = game_state |> find_coord_of(4)
    {pad_x, _} = game_state |> find_coord_of(3)
    
    cond do
       ball_x < pad_x -> -1
       pad_x < ball_x -> 1
       true -> 0 
    end
end
```

Whenever the Arcade VM requests input, we move our paddle to try and be directly under the ball. Simple, but effective, [breakout](https://en.wikipedia.org/wiki/Breakout_(video_game)) strategy.

For problem one, we don't even need to play the game - just run a sanity check to count the number of break-able blocks
on screen when the program starts up:

```elixir
"data/day13/rom.ic"
|> Intcode.program_from_file()
|> run_arcade()
|> block_count()
```

Insert some quarters for problem two:

```elixir
        game_res = "data/day13/rom.ic"
        |> Intcode.program_from_file()
        
        # write two quarters to memory address 0 for free-play
        |> Intcode.memory_write(0, 2)
        
        # run our program
        |> run_arcade()
        
        # draw the result
        |> draw_screen()
        
        # and print the score
        IO.puts("Score: #{game_res.settings.score}")
```

and we can run the game until we win:

```bash
▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊     *                                      ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊                                            ▊                                  
▊     -                                      ▊                                  
▊                                            ▊  
```


## Day 14

**Problem**: [Space Stoichiometry](https://adventofcode.com/2019/day/14)

**Stars**: ⭐️⭐️

**Code**: [day14.ex](lib/aoc/day14.ex)

**Tests**: [day14_test.exs](test/aoc/day14_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Chemical Reactions, Constraint Solver, Binary Search

Every good space ship should be able to make it's own fuel. With the help of a batch of chemical equations, our ship is no exception. For problem
one, we need to take the list of chemical reaction equations, and determine how they all fit together to turn raw `ORE` into `FUEL`. This is a
classic constraint solving problem - each of the chemical reactions takes one or more input quantities to create some number of output quantities. 
We can invert those inputs and outputs into a series of statements where creating some amount of _output_ requires some number of _inputs_. Working
backwards from a desired end state (like, wanting to create `1 FUEL`), we evaluate the reactions until we end up with only some quantity of `ORE`
required. If our chemical reactions were the simple set of formulae:

```
1 ORE => 1 A
3 ORE => 1 B
5 ORE => 1 C
1 A, 1 B, 2 C => 1 FUEL
```

We could work through our constraints, building up a list of requirements by appending the results of each step to a list of required chemicals. Starting
with just the requirement of needing 1 FUEL:

```
[1 FUEL]
```

From our reactions, we know how to produce one fuel, and our list of required chemicals becomes:

```
[1 A, 1 B, 2 C]
```

Next we need to produce `A`, which requires `ORE`, and our requirements list updates again:

```
[1 B, 2 C, 1 ORE]
```

The head of our list is now creating some `B`, again requiring `ORE`:

```
[2 C, 1 ORE, 3 ORE]
```

While creating `1 A` only required `1 ORE`, creating the same amount of `B` took `3 ORE`. Next step is producing some `C`. We need `2 C`, but
our formula for `C` only produces one. Let's run the reaction twice, requiring `10 ORE`. Our requirements list is now:

```
[1 ORE, 3 ORE, 10 ORE]
```

The only thing left in our constraint list is `ORE` - our chemical reactions are complete, and summing up the `ORE` it looks like we need `14 ORE`
to produce one fuel.

To solve problem one, we use _almost exactly_ this approach: we recursively work through a set of required chemicals, until only `ORE` is left. To
generate a correct solution we need to account for an edge case: sometimes we need to produce a chemical in some quantity (like needing `7 A`), but
our reaction creates more than we need (like `10 A`). We need to keep track of this extra production, as it can be applied in different parts of our
reaction evaluation. The first example set of reactions covers this - a naive solution that doesn't account for extra production will over estimate
the required amount of `ORE` needed to produce 1 fuel.

With a basic constraint solver that walks through the above steps (see [`ore_requirements/3`](lib/aoc/day14#L57) ), solving problem one becomes:

```elixir
reactions_from_file("data/day14/problem_01.chems")
|> ore_requirements(%{"FUEL" => 1})
```

We made a number of lucky assumptions in the solver we wrote for problem one: we didn't hard code the number of fuel to produce, the recursive solver
is built to find an efficient solution, and we carry along an accounting of extra production of chemicals from reactions. All of these are important
when it comes to solving problem two. Finding out _the maximum_ amount of fuel we can produce given a quantity of ore is interesting - we could brute
force the answer and incrementally walk from `1` up to some solution - but given the maximum amount of fuel cited for the ealier examples, this would
be time prohibitive. 

But finding that maximum quantity of fuel, when we can use the `ore_requirements` function from problem one to quickly determine how much ore is needed
for any particular amount of fuel, sounds a lot like a search problem. We need to efficiently search through _some range_ of integers. If we could determine
and upper bound on the amount of fuel, this would break down to a binary search problem. Knowing that the upper bound could be fairly large (into the millions
for our final solution), we'll take a simple approach by combining a binary search with a bounds search:

 1. Evaluate a quantity of fuel - 
 2. if the amount of ore required is _less_ than the total ore available, double our fuel and try again
 3. if the amount of ore required is _greater_ than the total ore available, start a binary search using the previous amount of fuel tested and the current amount as lower and upper bounds

The amount by which we increase our upper bound in step 2 is (somewhat) arbitrary. Given that we know some _approximate_ possible upper bounds from the
examples, doubling at each step is mostly practical. If we increase _too_ quickly, the search space for step 3 becomes large. If we don't increase quickly
enough, we spend a long time looking for an upper bound. For the final solution to problem two, we find the upper bound in 24 steps, leaving a decently
sized space to search through for step 3. 

During step 3, if our upper and lower bound are adjacent (like a lower bound of `10` and upper bound of `11`), or if the amount of fuel we can create
for a given value being tested uses _exactly_ the amount of available `ORE`, we're done searching.

Using the above steps encoded as [`maximize_fuel/4`](lib/aoc/day14#L21), the solution for problem two becomes:

```elixir
reactions_from_file("data/day14/problem_01.chems")
|> maximize_fuel(1000000000000)
```


## Day 15

**Problem**: [Oxygen System](https://adventofcode.com/2019/day/15)

**Stars**: ⭐️⭐️

**Code**: [day15.ex](lib/aoc/day15.ex)

**Tests**: No Tests

**Hex Libraries**: [Chunky](https://hexdocs.pm/chunky/readme.html)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Path Finding, Maze Solving, Space Filling, Intcode

Our Intcode virtual machine has become just another tool in our quest to get through space. Though the VM does feature today, it plays a
background role to the real problem: our repair droid needs to map out a series of corridors. Sounds like a maze solving problem to me!

With a combination of tools we built for our hull painting robot (namely the Grid code for tracking data on a 2 dimensional surface and the IO
routines for interacting with a program running on the VM in a stateful way), we set out to guide our repair droid through unknown hallways,
mapping as we go until we find the oxygen system. There are a ton of [maze solving](https://en.wikipedia.org/wiki/Maze_solving_algorithm)
algorithms to choose from - but I have a feeling that the first question asking for the shortest path from our droid's start position to the
oxygen system isn't the whole story. We want to map out _the entire_ map grid, and then find our shortest path. This is a variation on classic
maze solving, in that we only uncover information about the maze as we navigate - no looking ahead, no full scans of the maze. 

We'll use a robust, though somewhat slow, [wall following](https://en.wikipedia.org/wiki/Maze_solving_algorithm#Wall_follower) approach, which
uses a simple heuristic to navigate around and discover the **entire** map:

 1. If we encounter a wall:
  - turn left of right if the tile in either of those directions is unknown (bias to explore)
  - If the tile to the right is a wall, turn left (don't get caught in a loop)
  - otherwise turn left
 2. If we didn't encounter a wall:
  - if the tile to the right is a wall, keep going forward
  - if the tile to the right _isn't_ a wall, turn right

With those simple steps, we quickly:

```bash
              ############### ####### ###########           
              D..............#.......#...........#          
                        .###.#.     .#.       .##           
                        ...#.#.   ...#.   ... ...#          
                          .###.   .###.   .#.   .#          
                          ..... ...#... ...#.....#          
                                .#.#.   .## ####.#          
                              ...#.#.   .#.#.....#          
                              .###.#.   .#.#.####           
                              .#...#. ...#.#.#...#          
                              .#####. .###.#.#.##           
                              .....#. .#...#.#...#          
                                  .#. .#.###.#.#.#          
                                  ... .#.....#.#.#          
                                      .#.#######.#          
                                      .#.........#          
                                      .#########.#          
                                      .#.......#.#          
                                      .#.#####.#.#          
                                ... ...#.....#.#.#          
                            ### .#. .###.###.###.#          
                           #..@#.#...#.....#.#...#          
                           #. # .#########.#.#.##           
                           #. ...#.......#.#...#.#          
                           #. .###.     .#.#####.#          
                           #. .#... .....#...#...#          
                           #. .#.   .#######.###.#          
                           #. ...   .#.....#.....#          
                           #.       .###.#######.#          
                           #.   ... ...#.......#.#          
                    ###    #.   .#.   .#.#.#####.#          
                   #...#   #.   .#.....#.#.....#.#          
                  ##. .#   #.   .#######.#####.#.#          
                 #... .#   #.   .#.....#.#.#...#.#          
                 #.   .#####.   .#####.#.#.#.###.#          
                 #.   .......   .....#.#.#.#.....#          
                 #.                 .#.#.#.######           
                 #...   .......   ...#.#.#...#...#          
                  ##.   .#####.   .###.#.#.#.#.#.#          
                   #.....#.........#.......#...#S#          
                    ##### ######### ####### ### #           
```

map out the entire maze:

```
          # ################# ####### ###########           
         #.#.................#.......#...........#          
         #.#.###########.###.#.#####.#.#######.##           
         #.#...........#...#.#...#...#...#...#...#          
         #.###########.###.###.###.###.###.#.###.#          
         #...........#.#.#.....#...#...#...#.....#          
         #.###.#####.#.#.#######.#.#.###.## ####.#          
         #.#.#...#...#...#...#...#.#...#.#.#.....#          
         #.#.###.#######.#.#.#.###.#.###.#.#.####           
         #.#...#.#.....#.#.#.#.#...#.#...#.#.#...#          
         #.###.#.#.###.#.#.#.#.#####.#.###.#.#.##           
         #...#.#...#...#.#.#.#.....#.#.#...#.#...#          
          ##.#.#####.###.#.#######.#.#.#.###.#.#.#          
         #...#.#...#.....#.......#...#.#.....#.#.#          
         #.###.#.#.#############.#####.#.#######.#          
         #.#...#.#.........#...#.....#.#.........#          
         #.#.#.#.#.#######.#.#.###.#.#.#########.#          
         #.#.#...#.#.....#.#.#.....#.#.#.......#.#          
         #.#######.#.#.###.#.#.#### ##.#.#####.#.#          
         #.........#.#.......#.#...#...#.....#.#.#          
          ##########.###########.#.#.###.###.###.#          
         #...#.......#.....#..@#.#...#.....#.#...#          
         #.#.#.#######.#####.###.#########.#.#.##           
         #.#.#.#.#.........#.#...#.......#.#...#.#          
         #.###.#.#.#######.#.#.###.#####.#.#####.#          
         #.....#...#.....#.#.#.#...#.....#...#...#          
         #.#####.###.###.#.#.#.#.###.#######.###.#          
         #.#...#...#.#.#...#.#.....#.#.....#.....#          
         #.#.###.###.#.###.#.#.#####.###.#######.#          
         #.#.....#...#...#.#.#.#...#...#.......#.#          
         #.#######.#####.#.#.#.#.#.###.#.#.#####.#          
         #...#.....#...#...#.#.#.#.....#.#.....#.#          
          ##.#.#.###.#.#.###.#.#.#######.#####.#.#          
         #.#.#.#.#...#.#...#.#.#.#.....#.#.#...#.#          
         #.#.#.###.###.#####.#.#.#####.#.#.#.###.#          
         #.#.#...#.#.#.......#.#.....#.#.#.#.....#          
         #.#.###.#.#.###########.###.#.#.#.######           
         #.#...#.#...#.........#.#...#.#.#...#...#          
         #.###.#.###.###.#####.###.###.#.#.#.#.#.#          
         #.........#..D..#.........#.......#...#S#          
          ######### ##### ######### ####### ### #           
```

Given that there are unreachable tiles on our map, it's hard to have a good heuristic for when we've completed
exploration. Our maze solver uses a cycle timer - after `N` cycles of searching, it considers the map explored.
For problem one, ~2,600 cycles was enough. With a map of our maze in hand (with `S` marking the oxygen sensor, and `@`
our starting point), a [depth first search](https://en.wikipedia.org/wiki/Depth-first_search) of the map arrives
at an optimal path quickly, starting with our point of origin (`@`):

 1. From current point:
  1. If the current point is in the list of points already traveled, we've hit a loop. End this search path.
  2. If the current point is the oxygen sensor, we've found a path. End this search path.
  3. Othewise continue
 2. Find all neighbors that are valid moves (north, south, east, and west)
 3. Repat for each valid neighbor move

This will find all valid paths from the origin to the finish - an extra step to filter out dead ends and loops, and sort
for the shortest valid route, and we're done with problem one:

```elixir
route = run_droid()
|> depth_search()
```

Looking at problem two, our intuition about building a complete map in problem one proves correct: we need a map of
_every_ corridor so we can determine how long it will take to replace oxygen through the entire map. Given that problem
one already generated all the map data we need, the solution for problem two is much easier. The method by which oxygen 
spreads through the corridors (as described by the problem) is a [flood fill](https://en.wikipedia.org/wiki/Flood_fill):

```bash
          # ################# ####### ###########           
         #.#.................#.......#...........#          
         #.#.###########.###.#.#####.#.#######.##           
         #.#...........#...#.#...#...#...#...#...#          
         #.###########.###.###.###.###.###.#.###.#          
         #...........#.#.#.....#...#...#...#.....#          
         #.###.#####.#.#.#######.#.#.###.## ####.#          
         #.#.#...#...#...#...#...#.#...#.#.#.....#          
         #.#.###.#######.#.#.#.###.#.###.#.#.####           
         #.#...#.#.....#.#.#.#.#...#.#...#.#.#...#          
         #.###.#.#.###.#.#.#.#.#####.#.###.#.#.##           
         #...#.#...#...#.#.#.#.....#.#.#...#.#...#          
          ##.#.#####.###.#.#######.#.#.#.###.#.#.#          
         #...#.#...#.....#.......#...#.#.....#.#.#          
         #.###.#.#.#############.#####.#.#######.#          
         #.#...#.#.........#...#.....#.#.........#          
         #.#.#.#.#.#######.#.#.###.#.#.#########.#          
         #.#.#...#.#.....#.#.#.....#.#.#.......#.#          
         #.#######.#.#.###.#.#.#### ##.#.#####.#.#          
         #.........#.#.......#.#...#...#.....#.#.#          
          ##########.###########.#.#.###.###.###.#          
         #...#.......#.....#..@#.#...#.....#.#...#          
         #.#.#.#######.#####.###.#########.#.#.##           
         #.#.#.#.#.........#.#...#.......#.#...#.#          
         #.###.#.#.#######.#.#.###.#####.#.#####.#          
         #.....#...#.....#.#.#.#...#.....#...#...#          
         #.#####.###.###.#.#.#.#.###.#######.###.#          
         #.#...#...#.#.#...#.#.....#.#OOOOO#.....#          
         #.#.###.###.#.###.#.#.#####.###O#######.#          
         #.#.....#...#...#.#.#.#...#...#OOOOOOO#.#          
         #.#######.#####.#.#.#.#.#.###.#O#O#####.#          
         #...#.....#...#...#.#.#.#.....#O#OOOOO#.#          
          ##.#.#.###.#.#.###.#.#.#######O#####O#.#          
         #.#.#.#.#D..#.#...#.#.#.#OOOOO#O#O#...#.#          
         #.#.#.###.###.#####.#.#.#####O#O#O#.###.#          
         #.#.#...#.#.#.......#.#.....#O#O#O#.....#          
         #.#.###.#.#.###########.###.#O#O#O######           
         #.#...#.#...#.........#.#...#O#O#OOO#OOO#          
         #.###.#.###.###.#####.###.###O#O#O#O#O#O#          
         #.........#.....#.........#OOOOOOO#OOO#O#          
          ######### ##### ######### ####### ### #           
```

With a step counter and a few lookup and update functions, the fill works quickly:

```bash
          # ################# ####### ###########           
         #.#OOOOOOOOOOOOOOOOO#OOOOOOO#OOOOOOOOOOO#          
         #.#O###########O###O#O#####O#O#######O##           
         #.#OOOOOOOOOOO#OOO#O#OOO#OOO#OOO#OOO#OOO#          
         #O###########O###O###O###O###O###O#O###O#          
         #OOOOOOOOOO.#O#O#OOOOO#OOO#OOO#OOO#OOOOO#          
         #O###O#####.#O#O#######O#O#O###O## ####O#          
         #.#.#OOO#...#OOO#...#OOO#O#OOO#O#O#OOOOO#          
         #.#.###O#######O#.#.#O###O#O###O#O#O####           
         #.#...#O#OOOOO#O#.#.#O#OOO#O#OOO#O#O#OOO#          
         #.###.#O#O###O#O#.#.#O#####O#O###O#O#O##           
         #...#.#OOO#OOO#O#.#.#OOOOO#O#O#OOO#O#OOO#          
          ##.#.#####O###O#.#######O#O#O#O###O#O#O#          
         #...#.#...#OOOOO#.......#OOO#O#OOOOO#O#O#          
         #.###.#.#.#############.#####O#O#######O#          
         #.#...#.#.........#...#.....#O#OOOOOOOOO#          
         #.#.#.#.#.#######.#.#.###.#.#O#########O#          
         #.#.#...#.#.....#.#.#.....#.#O#OOOOOOO#O#          
         #.#######.#.#.###.#.#.#### ##O#O#####O#O#          
         #.........#.#.......#.#OOO#OOO#OOOOO#O#O#          
          ##########.###########O#O#O###O###O###O#          
         #...#.......#.....#..@#O#OOO#OOOOO#O#OOO#          
         #.#.#.#######.#####.###O#########O#O#O##           
         #.#.#.#.#.........#.#OOO#OOOOOOO#O#OOO#O#          
         #.###.#.#.#######.#.#O###O#####O#O#####O#          
         #.....#...#.....#.#.#O#OOO#OOOOO#OOO#OOO#          
         #.#####.###.###.#.#.#O#O###O#######O###O#          
         #.#...#...#.#.#...#.#OOOOO#O#OOOOO#OOOOO#          
         #.#.###.###.#.###.#.#O#####O###O#######O#          
         #.#.....#...#...#.#.#O#OOO#OOO#OOOOOOO#O#          
         #.#######.#####.#.#.#O#O#O###O#O#O#####O#          
         #...#.....#OOO#...#.#O#O#OOOOO#O#OOOOO#O#          
          ##.#.#.###O#O#.###.#O#O#######O#####O#O#          
         #.#.#.#.#DOO#O#...#.#O#O#OOOOO#O#O#OOO#O#          
         #.#.#.###O###O#####.#O#O#####O#O#O#O###O#          
         #.#.#...#O#O#OOO....#O#OOOOO#O#O#O#OOOOO#          
         #.#.###.#O#O###########O###O#O#O#O######           
         #.#...#.#OOO#OOOOOOOOO#O#OOO#O#O#OOO#OOO#          
         #.###.#.###O###O#####O###O###O#O#O#O#O#O#          
         #.........#OOOOO#OOOOOOOOO#OOOOOOO#OOO#O#          
          ######### ##### ######### ####### ### #           
```

And within a few hundred steps, the entire map is oxygenated. A bit more book-keeping work, and problem two is solved:

```elixir
%{maze: maze} = maze_state = run_droid()

[{oxy_x, oxy_y}] = find_index(maze, "S")

start_grid = maze |> Grid.put_at(oxy_x, oxy_y, "O")

steps = oxygen_flood(%{maze_state | maze: start_grid})
```


## Day 16

**Problem**: [Flawed Frequency Transmission](https://adventofcode.com/2019/day/16)

**Stars**: ⭐️⭐️

**Code**: [day16.ex](lib/aoc/day16.ex)

**Tests**: [day16_test.exs](test/aoc/day16_test.exs)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, List Manipulation, FFT

Oh joy! Fast Fourier Transforms! I mean _Flawed Frequency Transmissions_! 

The concept is the same, though. For problem one a handful of simple methods to do some matrix math like operations
across an input signal, repeat a few times, and we're done. That seems _too easy_. Especially coming off of a long
maze solving problem from yesterday, 10 minutes of throwing together list manipulations seems like we're missing
something. None of the premonitions of previous days, where a lucky choice algorithmically in the first problem
sets up an optimal solution to the second. Nope. Problem one has a solution with a rather nasty set of nested (and then
_repeated_) loops, with the core of the solution in the reduction/accumulation:

```elixir
    |> Enum.reduce(
        0,
        fn {a_d, a_idx}, acc -> 
            acc + (a_d * fft_pattern_digit_at(pattern, a_idx, index: index))
        end
    )                
```

Even with a relatively small input for 100 iterations of our `fft`, this takes awhile. The original solution for
problem one (prior to trying to troubleshoot problem two) was even more time inefficient; it created new lists of
phase digits (long lists, at that) in the inner loop, for every single iteration. The `fft_pattern_digit_at/3`
function is a short-cut: a constant time, constant space closed form interpolation of the current FFT digit and
phase index into a _phase multiplier_. It's like taking the long list of phase digits, and generating them one
at a time, only as needed. The overhead of calling a function is added, but we save the expense of building 
long lists _over and over_, as well as the linear time required to look up values in those generated lists.

And that optimization wasn't nearly enough to make problem two tractable. I _knew_ problem one seemd too easy. With
a _much_ longer signal (a bit over 6 _million_ digits), even a highly optimized direct "fft" of the signal would
still require 6.5 million<sup>2</sup> add/multiply operations - brute forcing an optimized solution would still
take hours to run. That's just not going to work.

A careful reading of the statement for problem two (and a bit of poking around on [Reddit](https://www.reddit.com/r/adventofcode/) to verify some assumptions), we can bypass our solution to problem one entirely. It all comes down to two factors:

 1. The final answer for our problem involves a series of 8 digits _in the middle of the signal_
 2. The first digit of our phase pattern is `0`

The reason these two factors matter, is that when combined we realize that when we're calculating the value
of the digits at (and after) the message offset into our signal, _all of the previous digits will be multiplied
by zero_. By the time we get to the message offset, our _phase pattern_ will consist of a list of zeros, ones, zeros
and negatives ones, each as long as the message offset (given the rules earlier in the problem on how to build and
repeat the phase pattern). Through a bit of induction, we discover that we can skip calculating _anything_ about all
of the digits before the message offset.

This alone doesn't lead to an optimal solution, though. Just dropping half of the input signal still leaves _a lot_ of
digits. Too many to run a full "fft" on in any reasonable time. But - just like the insight about all of the zeros _before_
the message offset, we can look at what is in the phase pattern _after_ the message offset. It turns out that, because of
_where_ in the signal we're calculating, all of the multiplications we do for the rest of the signal will be a signal value
multiplied by `1`. That's something we can skip! If our original formula for working with each digit looked like:

```
signal_digit_0 * phase_digit_0 + signal_digit_1 * phase_digit_1 + signal_digit_2 * phase_digit_2 + ...
```

for problem two it now looks like:

```
signal_digit_0 + signal_digit_1 + signal_digit_2 + ...
```

That's a _lot_ less work. In fact, calculating each pass of our "fft" is now reduced to running a _tail summation_ against
the signal. For a tail summation, we calculate the new value at any position in the signal list by adding the value currently
at that position, with all of the values that occur _after_ it in the list. So a list that starts out as `[1, 2, 3, 4]` becomes `[10, 9, 7, 4]`, 
with each value in the new list being the sum of itself, and all following values from the previous list. This is great! The
`O(N*N*k)` "fft" required for a solution to problem one can be reduced in problem two into:

```elixir
result = num 
|> tail_sum()
|> Enum.map(fn v -> 
    v |> Integer.digits() |> List.last() |> abs()
end)
```

That's a `O(2N)` set of operations per FFT repetition. Even that isn't optimal, but it does get the job done.


## Day 17

**Problem**: [Set and Forget](https://adventofcode.com/2019/day/17)

**Stars**: ⭐️⭐️

**Code**: [day17.ex](lib/aoc/day17.ex)

**Tests**: No Tests

**Hex Libraries**: [Chunky](https://hexdocs.pm/chunky/readme.html)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Path Finding, Maze Solving, Space Filling, Intcode, LZ77, Compression

The first half of Day 17 seems a lot like the maze finding/drawing problem from Day 15. In fact, so similar that a few minor tweaks to the code, and we're
able to draw the scaffolding map. Altering our code to capture the map output data, we get:

```
 ..........####^..............................
 ..........#..................................
 ..........#..................................
 ..........#..................................
 ..........#######............................
 ................#............................
 ................#.......#############........
 ................#.......#...........#........
 #######.........#.......#...........#........
 #.....#.........#.......#...........#........
 #.....#.........#.#####.#.....#########......
 #.....#.........#.#...#.#.....#.....#.#......
 #.....#.......###########.###########.#......
 #.....#.......#.#.#...#...#...#.......#......
 #.....#.......#.#######...#...#.......#......
 #.....#.......#...#.......#...#.......#......
 #.....#.###########.###########.......#......
 #.....#.#.....#.....#.....#...........#......
 #.....#########.....#.....#...........#......
 #.......#...........#.....#...........#......
 #######.#...........#.....#######.....#######
 ......#.#...........#...........#...........#
 ......#.#############...........#...........#
 ......#.........................#...........#
 ......#.........................#...........#
 ......#.........................#...........#
 ......#.........................#...........#
 ......#.........................#...........#
 ......#.........................#.###########
 ......#.........................#.#..........
 ......#######...................#######......
 ..................................#...#......
 ..................................#...#......
 ..................................#...#......
 ..................................#####......

```

For problem one we need to count loops (or intersections) in the scaffolding. This is fairly easy is we scan through the entire map, looking
for any scaffolding point that has **four cardinal** neighbors that are also scaffolding, like the scaffolding piece marked `A` below:

```
 .#.
 #A#
 .#.
```

Finding all of those, and doing some simple math gets a quick solution to problem one.

Problem two is a bit odd at first glance. We have limited space to provide an input program, in a very specific format. At first I got
stuck on an ambiguity in the problem statement, and a resulting bug in my code: when providing an instruction like "turn right, move 10 spaces" the
code provided to the VM looks like `R10`. Given the problem statement, every character should be separated by a comma, which would look like `R,1,0`.
But this means the bot turns right, moves one, moves zero. That's not what we wanted! It wasn't immediately clear to me that the problem statement
_meant_ that you could provide input like `R,10,...` and that it would be handled correctly. This left me in a loop (ha) of my own, trying to
figure out how to get a proper path for the bot.

The solution for problem two hinges on recognizing that a fully plotted out route for the bot will have a lot of repeating patterns. For my
puzzle inputs, the full path of the bot looks like:

```
L4 L4 L6 R10 L6 L4 L4 L6 R10 L6 L12 L6 R10 L6 R8 R10 L6 R8 R10 L6 L4 L4 L6 R10 L6 R8 R10 L6 L12 L6 R10 L6 R8 R10 L6 L12 L6 R10 L6
```

Had I not gotten stuck on the input bugs, this would have been an excellent time to write a modified [LZ77 Deflate](https://en.wikipedia.org/wiki/LZ77_and_LZ78) algorithm. The problem statement for the second half of Day 17 sets up the idea well:
find a subset of 3 programs that, when chainged together repeatedly, make the bot travel the entire path of the scaffolding. If you recognize
that we're looking at repeated patterns, and know (even roughly) about dictionary compression, this is a tractable problem.

If you take the path for this bot, and substitute each unique move combination (like `L4`) for a letter, you get:

```
q  q  w  e  w  q  q  w  e  w  r  w  e  w  t  e  w  t  e  w  q  q  w  e  w  t  e  w  r  w  e  w  t  e  w  r  w  e  w
```

Now the repetition starts to stand out. Making the patterns even clearer:

```
q  q  w  e  w
q  q  w  e  w
r  w  e  w
t  e  w
t  e  w
q  q  w  e  w
t  e  w
r  w  e  w
t  e  w
r  w  e  w
```

That looks like three subprograms. If it wasn't already 10PM when I had time to dig into problem two, and the input bugs hand't burned an hour, I
would write an auto-solver for this:

 - Trace the needed moves given the scaffolding map (move til hit a wall, turn left or right as available, repeat)
 - Write a modified (and simple) LZ77 compressor. Limiting max run length to meet our program requirements means there are only a handful of solutions
 
But. It's 10:30 at night. I hand solved the move packing, as that was quicker.

## Day 18

**Problem**: [Many Worlds Interpretation](https://adventofcode.com/2019/day/18)

**Stars**: 

**Code**: [day18.ex](lib/aoc/day18.ex)

**Tests**: [day18_test.exs](test/aoc/day18_test.exs)

**Hex Libraries**: [Chunky](https://hexdocs.pm/chunky/readme.html)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Path Finding, Maze Solving, Breadth First Search, [Dijkstra's Algorithm](https://en.wikipedia.org/wiki/Dijkstra's_algorithm)

Haven't yet managed to solved Day 18 - I have code using naive depth and breadth first search that works for 3/4 of the example maps, but there
are errors in the caching and routing planning for one of the example maps and the map for problem one. We'll get back to this later.


## Day 19

**Problem**: [Tractor Beam](https://adventofcode.com/2019/day/19)

**Stars**: ⭐️⭐️

**Code**: [day19.ex](lib/aoc/day19.ex)

**Tests**: No Tests

**Hex Libraries**: [Chunky](https://hexdocs.pm/chunky/readme.html)

**Techniques**: [Enum/Mapping](https://hexdocs.pm/elixir/Enum.html#content), Recusion, Intcode, Binary Search

Problem one for the **Tractor Beam** is to figure out _where_ it points. As with some of the other days, a particularly easy problem one
isn't usually a good sign. For today, running repeatedly through an Intcode program for our drone, to map out a small square of data, it
becomes clear that doing any significant amount of naive row by column mapping will be insufficient later on. But for problem one, we can
brute force through the 2,500 iterations of the program in under 30 seconds:

```
#.................................................
..................................................
..................................................
..................................................
...#..............................................
....#.............................................
.....#............................................
......#...........................................
......##..........................................
.......##.........................................
........#.........................................
........##........................................
.........##.......................................
..........##......................................
...........##.....................................
...........###....................................
............###...................................
.............###..................................
.............####.................................
..............###.................................
...............###................................
................###...............................
................####..............................
.................####.............................
..................####............................
...................####...........................
...................#####..........................
....................#####.........................
.....................#####........................
.....................#####........................
......................#####.......................
.......................#####......................
........................#####.....................
........................######....................
.........................######...................
..........................######..................
..........................#######.................
...........................#######................
............................######................
.............................######...............
.............................#######..............
..............................#######.............
...............................#######............
...............................########...........
................................########..........
.................................########.........
..................................########........
..................................#########.......
...................................########.......
....................................########......
```

Looks like our tractor beam has a narrow field of view...

For problem two it becomes clear that scanning through every row and column _really_ won't work. We need a more efficient way to find
the rows we're looking for. We wrap calls to our Intcode IO cycle in a simple function to get the drone reading at a particular point,
so we can directly inspect a point anytime we need:

```elixir
iex> tractor_beam_test_at(3, 4)
1
```

And rather than map a whole row, we use a search function that implements a modified binary search to find the edges of the beam
at a specific row, giving us the pair of _X, y_ coordinates describing the beam:

```elixir
iex> Aoc.Day19.beam_at_row(678)
{{489, 678}, {606, 678}}
```

With these tools in hand (and a bunch of supporting functions for `beam_at_row/1` that run the actual binary search and edge finding),
we use a simple search heuristic:

 - Find a row at least 100 units wide, with left coordinate of x_bottom
 - where the row 100 units above has a beam with a right edge coordinate equal or greater than  x_bottom + 100
 
Scanning through row by row would still be too slow, even with the efficient search functions we have so far, so our `find_first_fit/2`
function uses some additional heuristics to speed up the search:

 - if the bottom row isn't wide enough to fit the 100 unit wide ship, jump ahead 100 rows
 - otherwise, if the top row isn't wide enough, calculate how far over the right edge the ship hangs, and just ahead `(overhang / 2)`

There are more optimal ways to scan for the beam - this one takes 55 steps to get to the solution for problem two. That's still better
than the naive scanning solution, which would have scanned nearly a million locations.
 
