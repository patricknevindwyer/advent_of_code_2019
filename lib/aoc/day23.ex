defmodule Aoc.Day23 do
    @moduledoc """
    Advent of Code 2019. Day 23. Problem 01/02.
    
    https://adventofcode.com/2019/day/23
    
    """ 
    
    alias Aoc.Intcode

    def problem01 do
        
        create_network_state(50)
        |> run_network()
        
    end
    
    def problem02 do
        create_network_state(50, false)
        |> run_network()
        
    end
    
    def create_network_state(nodes \\ 50, term_on_nat \\ true) do
        
        # setup the state for each computer, with a map to
        # network queues
        out_queues = 0..(nodes - 1)
        |> Enum.map(
            fn addr -> 
                {addr, []}
            end
        )
        in_packets = 0..(nodes - 1)
        |> Enum.map(
            fn addr -> 
                {addr, [addr]} 
            end
        )
        
        # what end check function are we using?
        end_func = if term_on_nat do
            &is_end_state?/1
        else
            fn _ -> false end
        end
        
        %{
            nodes: nodes,
            out_queues: out_queues |> Map.new(),
            in_packets: in_packets |> Map.new(),
            end_check: end_func,
            nat_packet: [],
            nat_retransmission: [],
            idle_count: 0
        }
        
    end
    
    def is_end_state?({dest_addr, [x, y]}) do
        if dest_addr == 255 do
            IO.puts("-> @(#{dest_addr}) -- {x: #{x}, y: #{y}}")
            true
        else
            false
        end
    end
    
    def run_network(network_state) do
                
        # load our program and run it
        program = "data/day23/nic.ic"
        |> Intcode.program_from_file()
        
        # launch all of our programs
        0..network_state.nodes - 1
        |> Enum.each(
            fn node_addr -> 
                program
                # run the program
                |> Intcode.run(
                    [
                        memory_size: 6000,
                        input_function: Intcode.send_for_labeled_input(self(), node_addr),
                        output_function: Intcode.send_labeled_output(self(), node_addr),
                        await_with: fn -> :ok end
                    ]
                )            
            end
        )
        
        # await
        Intcode.await_io(
            network_state, 
            output_function: &handle_network_output/2, 
            output_count: 1, 
            input_function: &handle_network_input/2)
        
    end 
    
    @doc """
    await_io handlers
    """
    def handle_network_input(network_state, net_addr) do
        
        # check for idle state
        post_idle_state = if is_network_idle?(network_state) do
            
            # what's the NAT data
            [x, y] = network_state.nat_packet
            
            # append to nat_retransmission
            retransmission = network_state.nat_retransmission ++ [y]
            
            # we need to transition data from NAT to addr zero
            updated_state = append_packet_data(network_state, 0, [x, y])
            
            # slice the retransmission data
            sliced_natr = if length(retransmission) > 2 do
                retransmission |> Enum.drop(1)
            else
                retransmission
            end
                        
            if length(sliced_natr) == 2 do
                [a_y, b_y] = sliced_natr
                # check the state
                if a_y == b_y do
                    IO.puts("NAT repeat #{a_y}")
                end
            end
            
            
            %{updated_state | nat_retransmission: sliced_natr}
            
            
        else
            # pump the idle state
            %{network_state | idle_count: network_state.idle_count + 1}
        end
        
        # see if we have a packet value for our address
        if has_packet_data?(post_idle_state, net_addr) do
            pop_packet_data(post_idle_state, net_addr)
        else
            # pump the idle state
            {
                -1,
                post_idle_state
            } 
        end
                
    end
    
    def is_network_idle?(network_state) do
        non_idle_queue_count = network_state.in_packets
        |> Enum.filter(fn {_addr, in_packets} -> length(in_packets) > 0 end)
        |> length()
        
        nat_packet_size = network_state.nat_packet |> length()
        
        non_idle_queue_count == 0 && network_state.idle_count > 1000 && nat_packet_size == 2
    end
    
    @doc """
    Do we have packets for a given address? Bool.
    """
    def has_packet_data?(state, net_addr) do
       state.in_packets |> Map.get(net_addr) |> length() > 0 
    end
    
    @doc """
    Does a network output queue for a node have sufficient data for
    a packet?
    """
    def has_packet_in_output?(state, net_addr) do
        state.out_queues |> Map.get(net_addr) |> length() > 2
    end
    
    @doc """
    Pop a packet and update the state.
    
    return {packet, state}
    """
    def pop_packet_data(state, net_addr) do
        in_queue = state.in_packets |> Map.get(net_addr)
        
        # packet and updated queue
        {packet, nin_queue} = in_queue |> List.pop_at(0)
        
        # updated state
        n_state = %{state | in_packets: Map.put(state.in_packets, net_addr, nin_queue), idle_count: 0}
        
        {packet, n_state}
    end
    
    @doc """
    Retrieve packet data, {dest, [data, data], state} form
    """
    def pop_output_packet_data(state, net_addr) do

        out_queue = state.out_queues |> Map.get(net_addr)
        
        # get data
        {[dest_addr, x, y], trimmed_queue} = out_queue |> Enum.split(3)
                
        # updated state
        n_state = %{state | out_queues: Map.put(state.out_queues, net_addr, trimmed_queue)}
        
        {dest_addr, [x, y], n_state}
        
    end
    
    @doc """
    Append a list of packet data to a network node, return form
    
        network_state 
    """
    def append_packet_data(state, net_addr, data) do
        packet_queue = state.in_packets |> Map.get(net_addr)
        
        %{state | in_packets: Map.put(state.in_packets, net_addr, packet_queue ++ data)}
        
    end
    
    @doc """
    Add a single value onto the network state for an output queue from a node
    """
    def append_queue_data(state, net_addr, raw) do
        out_queue = state.out_queues |> Map.get(net_addr)
        
        %{state | out_queues: Map.put(state.out_queues, net_addr, out_queue ++ [raw])}
    end
    
    
    @doc """
    
    """
    def handle_network_output(network_state, [%{label: net_addr, output: output}]) do
        
        # add to the output queue for the given net address
        temp_state = append_queue_data(network_state, net_addr, output)
        
        # if we have enough data in the output queue, we need to transition it
        # to a packet
        if has_packet_in_output?(temp_state, net_addr) do
            
            # we need to transition our packet
            {dest_addr, data, t_a_state} = pop_output_packet_data(temp_state, net_addr)
            
            if network_state.end_check.({dest_addr, data}) do
                {:halt, t_a_state}
            else
                
                # where is this packet going?
                t_b_state = if dest_addr == 255 do
                    
                    # store the last known NAT packet
                    %{t_a_state | nat_packet: data}
                else

                    # forward packets
                    append_packet_data(t_a_state, dest_addr, data)
                end
            
                {:continue, t_b_state}                
            end
        else
            # keep chugging along
            {:continue, temp_state}
        end  

    end
end