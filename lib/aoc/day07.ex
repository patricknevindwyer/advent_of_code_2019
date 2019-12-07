defmodule Aoc.Day07 do
   @moduledoc """
   
   """ 
   
   require Aoc.Day05
   
   @amp_program [
       3,8,1001,8,10,8,105,1,0,0,21,34,51,64,81,102,183,264,345,426,99999,3,9,
       102,2,9,9,1001,9,4,9,4,9,99,3,9,101,4,9,9,102,5,9,9,1001,9,2,9,4,9,99,
       3,9,101,3,9,9,1002,9,5,9,4,9,99,3,9,102,3,9,9,101,3,9,9,1002,9,4,9,4,9,
       99,3,9,1002,9,3,9,1001,9,5,9,1002,9,5,9,101,3,9,9,4,9,99,3,9,102,2,9,9,
       4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,
       9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,
       9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,
       1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,
       3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,
       4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,
       1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,
       1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,1,
       9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,
       9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,
       1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,
       9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,
       4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,
       9,9,4,9,99
   ]
   
   def problem01() do
       
       # generate the permutations of [0, 1, 2, 3, 4]
       permutations([0, 1, 2, 3, 4])
       
       # run them through the amplifiers
       |> Enum.map(
           fn phase ->
               run_amplifiers(@amp_program, phase)
           end
       )
       
       # return the best result
       |> Enum.max()
   end
   
   def problem02() do
       # generate the permutations of [0, 1, 2, 3, 4]
       permutations([5, 6, 7, 8, 9])
       
       # run them through the amplifiers
       |> Enum.map(
           fn phase ->
               run_feedback_amplifiers(@amp_program, phase)
           end
       )
       
       # return the best result
       |> Enum.max()       
   end
   
   def permutations([]), do: [[]]
   def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
   
   def run_amplifiers(program, phase) do
      
       # setup the amps in reverse
       amp_e = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(self()), halt_function: send_halt(self())])
       amp_d = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_e)])
       amp_c = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_d)])
       amp_b = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_c)])
       amp_a = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_b)])
       
       # send phase indicators
       send_output(amp_a).(Enum.at(phase, 0))
       send_output(amp_b).(Enum.at(phase, 1))
       send_output(amp_c).(Enum.at(phase, 2))
       send_output(amp_d).(Enum.at(phase, 3))
       send_output(amp_e).(Enum.at(phase, 4))
       
       # send the initializer to amp a
       send_output(amp_a).(0)
       
       # now wait to halt
       await_result(:none)
       
   end
   
   def run_feedback_amplifiers(program, phase) do
       
       # setup the amps in reverse
       amp_e = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(self()), halt_function: send_halt(self())])
       amp_d = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_e)])
       amp_c = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_d)])
       amp_b = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_c)])
       amp_a = spawn_program(program, [input_function: &receive_input/0, output_function: send_output(amp_b)])
       
       # send phase indicators
       send_output(amp_a).(Enum.at(phase, 0))
       send_output(amp_b).(Enum.at(phase, 1))
       send_output(amp_c).(Enum.at(phase, 2))
       send_output(amp_d).(Enum.at(phase, 3))
       send_output(amp_e).(Enum.at(phase, 4))
       
       # send the initializer to amp a
       send_output(amp_a).(0)
       
       # now wait to halt
       await_and_forward(:none, [amp_a])
       
   end
   
   @doc """
   Keep track of the current output of the last amplifier, and return
   it after we halt
   """
   def await_result(last_result) do
      receive do
          :halt -> last_result
          v -> await_result(v) 
      end
   end
   
   @doc """
   Keep track of the current output of the last amplifier, and forward
   it on to a list of other amplifiers. When we get a halt message,
   we can return our value
   """
   def await_and_forward(last_result, forwards) when is_list(forwards) do
       
       receive do
           :halt -> last_result
           v ->
               forwards |> Enum.each(fn pid -> send(pid, v) end)
               await_and_forward(v, forwards)
       end
   end
   
   def spawn_program(program, opts) do
       spawn(fn -> eval_program(program, 0, opts) end)
   end
   
   @doc """
   Run an Intcode program, and return the program when complete. Optionally provide a
   starting address and program options.
   
   ## Options
       
    - :input_function - the function to use when requesting user input, defaults to parsing an integer from `stdin`
   
   
   ## Example
   
       iex> eval_program([1, ...])
       [12, 0, ...]
   
   When passing program options, the starting address needs to be explicitly provided:
   
       iex> eval_program([1, ...], 0, [input_function: fn -> ... end])
       [22, 0, ...]
       
   """
   def eval_program(program, at \\ 0, opts \\ []) do
              
       # make sure we have an input routine
       input_func = opts |> Keyword.get(:input_function, &default_input/0)
       output_func = opts |> Keyword.get(:output_function, &default_output/1)
       halt_func = opts |> Keyword.get(:halt_function, &default_halt/0)
       
       prog_opts = [input_function: input_func, output_function: output_func, halt_function: halt_func]
       
       case eval_at(program, at, prog_opts) do
          {:halt, u_program} -> 
              
              # determine what to do when we halt
              halt_func.()
              
              # return the program
              u_program
          {:continue, inst_inc, u_program} -> eval_program(u_program, at + inst_inc, prog_opts) 
          {:jump, pointer, u_program} -> eval_program(u_program, pointer, prog_opts) 
       end
       
   end
   
   @doc """
   By default when we halt, we just null route the message
   """
   def default_halt() do
       :ok
   end
   
   @doc """
   Send the halt notification to a specific PID
   """
   def send_halt(pid) do
      fn ->
          send(pid, :halt) 
      end 
   end
   
   @doc """
   Retrieve input from STDIN
   """
   def default_input() do
       {v, _} = IO.gets("input: ") |> Integer.parse()
       v
   end
   
   @doc """
   Retrieve input from our PID mailbox
   """
   def receive_input() do
      receive do
         v -> v 
      end 
   end
   
   @doc """
   Push output to STDOUT
   """
   def default_output(v) do
       IO.puts("#{v}")
   end
   
   @doc """
   Generate a function that will send output to another PID
   """
   def send_output(dest_pid) do
      fn v ->
         send(dest_pid, v)
      end 
   end
   
   @doc """
   Generate a function that will send outputs to multiple PIDs
   """
   def send_multiple_outputs(dest_pids) when is_list(dest_pids) do
       fn v ->
          dest_pids
          |> Enum.each(fn pid -> send(pid, v) end) 
       end
   end
   
   @doc """
   Eval the program instruction at the given offset, returning the updated program
   with:
       
    - :halt and program contents
    - :continue, instruction pointer increment, and program contets
   
   ## Example
   
       iex> eval_at(program, 0)
       {:continue, 2, [...]}
       
       iex> eval_at(program, 0)
       {:continue, 4, [...]}
   
       iex> eval_at(program, 12)
       {:halt, [...]}
   """
   def eval_at(program, offset, opts) do
      
      case decode_instruction(Enum.at(program, offset)) do
         
         {:halt} -> 
             
             {:halt, program}
         
         {:add, l_addr_mode, r_addr_mode, :position} -> 
             
             [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
             
             # gather our values
             l_val = case l_addr_mode do
                :position -> Enum.at(program, l_addr)
                :immediate -> l_addr
             end
             
             r_val = case r_addr_mode do
                :position -> Enum.at(program, r_addr)
                :immediate -> r_addr
             end
             
             {:continue, 4, List.update_at(program, store_addr, fn _ -> r_val + l_val end)}
             
         {:multiply, l_addr_mode, r_addr_mode, :position} ->
             
             [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
             
             # gather our values
             l_val = case l_addr_mode do
                :position -> Enum.at(program, l_addr)
                :immediate -> l_addr
             end
             
             r_val = case r_addr_mode do
                :position -> Enum.at(program, r_addr)
                :immediate -> r_addr
             end
             
             {:continue, 4, List.update_at(program, store_addr, fn _ -> r_val * l_val end)}
             
         {:input, :position} ->
             
             input_func = opts |> Keyword.get(:input_function)
             
             int_in = input_func.()
             store_addr = Enum.at(program, offset + 1)
             
             {:continue, 2, List.update_at(program, store_addr, fn _ -> int_in end)}
             
         {:output, o_addr_mode} ->
             
             output_func = opts |> Keyword.get(:output_function)
             
             o_addr = Enum.at(program, offset + 1)
             
             o_val = case o_addr_mode do
                 :position -> Enum.at(program, o_addr)
                 :immediate -> o_addr                  
             end
             
             output_func.(o_val)

             {:continue, 2, program}
             
         {:jump_if_true, l_addr_mode, j_addr_mode} ->

             [l_addr, j_addr] = Enum.slice(program, offset + 1, 2)
             
             l_val = case l_addr_mode do
                :position -> Enum.at(program, l_addr)
                :immediate -> l_addr
             end
             
             j_val = case j_addr_mode do
                :position -> Enum.at(program, j_addr)
                :immediate -> j_addr
             end
             
             if l_val > 0 do
                 {:jump, j_val, program}
             else
                 {:continue, 3, program}
             end
             
         {:jump_if_false, l_addr_mode, j_addr_mode} ->

             [l_addr, j_addr] = Enum.slice(program, offset + 1, 2)
             
             l_val = case l_addr_mode do
                :position -> Enum.at(program, l_addr)
                :immediate -> l_addr
             end
             
             j_val = case j_addr_mode do
                :position -> Enum.at(program, j_addr)
                :immediate -> j_addr
             end
             
             if l_val == 0 do
                 {:jump, j_val, program}
             else
                 {:continue, 3, program}
             end
             
         {:less_than, l_addr_mode, r_addr_mode, :position} ->
             
             [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
         
             # gather our values
             l_val = case l_addr_mode do
                :position -> Enum.at(program, l_addr)
                :immediate -> l_addr
             end
         
             r_val = case r_addr_mode do
                :position -> Enum.at(program, r_addr)
                :immediate -> r_addr
             end
             
             # what are we storing
             store_val = if l_val < r_val do
                 1
             else
                 0
             end
             
             {:continue, 4, List.update_at(program, store_addr, fn _ -> store_val end)}
             
         {:equals, l_addr_mode, r_addr_mode, :position} ->
         
             [l_addr, r_addr, store_addr] = Enum.slice(program, offset + 1, 3)
         
             # gather our values
             l_val = case l_addr_mode do
                :position -> Enum.at(program, l_addr)
                :immediate -> l_addr
             end
         
             r_val = case r_addr_mode do
                :position -> Enum.at(program, r_addr)
                :immediate -> r_addr
             end
             
             # what are we storing
             store_val = if l_val == r_val do
                 1
             else
                 0
             end
             
             {:continue, 4, List.update_at(program, store_addr, fn _ -> store_val end)}              
      end
   end
   
   @doc """
   Decode the given instruction, according to:
   
       ABCDE
        1002

       DE - two-digit opcode,      02 == opcode 2
        C - mode of 1st parameter,  0 == position mode
        B - mode of 2nd parameter,  1 == immediate mode
        A - mode of 3rd parameter,  0 == position mode, omitted due to being a leading zero
   """
   def decode_instruction(inst) do
       digits = Integer.digits(inst) |> Enum.reverse()
       
       # op code
       op = digits |> Enum.slice(0, 2) |> Enum.reverse() |> Integer.undigits()
       
       case op do
          1 -> 
              {
                  :add,
                  digits |> Enum.at(2, 0) |> memory_mode(),
                  digits |> Enum.at(3, 0) |> memory_mode(),
                  :position
              } 
              
          2 ->
              {
                  :multiply,
                  digits |> Enum.at(2, 0) |> memory_mode(),
                  digits |> Enum.at(3, 0) |> memory_mode(),
                  :position
              }
              
          3 ->
              {
                  :input,
                  :position
              }
              
          4 ->
              {
                  :output,
                  digits |> Enum.at(2, 0) |> memory_mode()
              }
              
          5 ->
              {
                  :jump_if_true,
                  digits |> Enum.at(2, 0) |> memory_mode(),
                  digits |> Enum.at(3, 0) |> memory_mode()                   
              }
              
          6 ->
              {
                  :jump_if_false,
                  digits |> Enum.at(2, 0) |> memory_mode(),
                  digits |> Enum.at(3, 0) |> memory_mode()                   
              }
              
          7 ->
              {
                  :less_than,
                  digits |> Enum.at(2, 0) |> memory_mode(),
                  digits |> Enum.at(3, 0) |> memory_mode(),
                  :position
              }
              
          8 ->
              {
                  :equals,
                  digits |> Enum.at(2, 0) |> memory_mode(),
                  digits |> Enum.at(3, 0) |> memory_mode(),
                  :position
              }
              
          99 ->
              {
                  :halt
              }
                  
       end
       
       
   end
   
   defp memory_mode(0), do: :position
   defp memory_mode(1), do: :immediate
end