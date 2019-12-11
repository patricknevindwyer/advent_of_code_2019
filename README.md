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
 * [Day 08](#day-08) - ⭐️⭐️
 * [Day 09](#day-09) - ⭐️⭐️
 * [Day 10](#day-10) - ⭐️⭐️


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