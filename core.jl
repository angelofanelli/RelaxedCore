
module RelaxedCore

using Pkg
Pkg.add("Graphs")
Pkg.add("SimpleWeightedGraphs")
Pkg.add("Random")
Pkg.add("Colors")
Pkg.add("Combinatorics")


using Graphs
using SimpleWeightedGraphs
using Random
using Colors
using Combinatorics
using Statistics


# Basic color codes
const RED = "\033[31m"
#const GREEN = "\033[32m"
#const YELLOW = "\033[33m"
#const BLUE = "\033[34m"
const RESET = "\033[0m"  # Reset to default color





# Function to print the matrix 
function write_matrix(matrix::Matrix{Tuple{Int64, Bool}})
    rows, cols = size(matrix) 

    for i in 1:rows
        for j in 1:cols
            print(stdout, "$(matrix[i,j])  ")
        end
        println(stdout, "")
    end
end



# Function to remove rows from the matrix. It returns a new matrix  
function delete_rows(matrix::Matrix{Tuple{Int64, Bool}}, rows_to_remove::Vector{Int})::Matrix{Tuple{Int64, Bool}}
    # Validate the rows_to_remove indices
    if any(x -> x < 1 || x > size(matrix, 1), rows_to_remove)
        error("Some row indices are out of bounds.")
    end
    
    all_rows = 1:size(matrix, 1) # Create a set of all row indices
    rows_to_keep = setdiff(all_rows, rows_to_remove) # Get the indices of the rows to keep
    return matrix[rows_to_keep, :] # Select and return the matrix with the remaining rows
end



# Function to remove rows from the matrix by keeping those with indices in rows_to_keep. It returns a new matrix  
function keep_rows(matrix::Matrix{Tuple{Int64, Bool}}, rows_to_keep::Vector{Int})::Matrix{Tuple{Int64, Bool}}
    # Validate the rows_to_remove indices
    if any(x -> x < 1 || x > size(matrix, 1), rows_to_keep)
        error("Some row indices are out of bounds.")
    end
    
    return matrix[rows_to_keep, :] # Select and return the matrix with the remaining rows
end


# It searches for row containing a true value. IT returns the indices of such rows 
function search_true_rows(matrix::Matrix{Tuple{Int64, Bool}})::Vector{Int}
    rows_to_remove = []

    rows, cols = size(matrix) 
    for i in 1:rows
        for j in 1:cols
            m, c = matrix[i,j]
            if c == true
                push!(rows_to_remove, i)
                break
            end 
        end
    end   
    return rows_to_remove 
end



# Function to compute the average value and standard deviation of a matrix
function compute_statistics_moves(matrix::Matrix{Tuple{Int64, Bool}})::Tuple{Float64, Float64}

    vector = Int64[]  # Initialize an empty vector to hold the first elements
    rows, cols = size(matrix) 

    for i in 1:rows
        for j in 1:cols
            m, c = matrix[i,j]
            push!(vector, m)
        end
    end
    
    # Compute the mean and standard deviation
    avg_value = mean(vector)
    std_dev = std(vector)
    
    return avg_value, std_dev
end



# Function to compute the percentage of true values in the matrix 
function compute_statistics_cycles(matrix::Matrix{Tuple{Int64, Bool}})::Float64

    count_true = 0  # Initialize an empty vector to hold the first elements
    rows, cols = size(matrix) 

    for i in 1:rows
        for j in 1:cols
            m, c = matrix[i,j]
            if c == true
                count_true += 1
            end
        end
    end
    
    println("Num of trues -> $count_true\n")
    # Compute the percentage of true values 
    avg_false = count_true/(rows * cols)
    
    return avg_false
end



# It generates a graph with n nodes, and for every pair of nodes generates an edge with probability p 
function generate_weighted_graph(n::Int, p::Float64, simple::Bool)::SimpleWeightedGraph{Int64, Float64}
    g = SimpleWeightedGraph(n)
    if simple
        interval = 1:1
    else
        interval = 1:100
    end
    for i in 1:n
        for j in i+1:n
            if rand() < p
                add_edge!(g, i, j, rand(interval))  # Random weight between 1 and 10
            end
        end
    end
    return g
end



# It prints the set of edges of the graph g
function write_graph(g::SimpleWeightedGraph{Int64, Float64})
    for e in edges(g)
        i = src(e)
        j = dst(e)
        println(stdout, "w($i, $j) = ", weight(e))
    end
end



# It constructs a state made of singletons
function singleton_state(g::SimpleWeightedGraph{Int64, Float64})::Vector{Vector{Int}}
    state = Vector{Vector{Int}}()
    for i in 1:nv(g)
        push!(state, [i])
    end
    return state 
end


# It returns the size of the largest coalition
function max_size_coalition(state::Vector{Vector{Int}})
    size = 0
    for c in state
        l = length(c)
        if  l > size
            size = l
        end
    end
    return size
end



# It returns the size of the smallest coalition 
function min_size_coalition(state::Vector{Vector{Int}})
    size = typemax(UInt64)
    for c in state
        l = length(c)
        if  l < size
            size = l
        end
    end
    return size
end



# It returns the coalition of a player i and his index in such coalition  
# It returns "nothing" if i is not in any coalition
function find_coalition(state::Vector{Vector{Int}}, i::Int)::Union{Nothing, Tuple{Vector{Int},Int}}
    for coalition in state
        for (index, value) in enumerate(coalition)
            if i == value 
                return (coalition, index)
            end
        end
    end
    return nothing
end



# It returns the utility of i in state of graph g
function utility(g::SimpleWeightedGraph{Int64, Float64}, state::Vector{Vector{Int}}, i::Int)::Float64
    if i ≤ 0 || i > nv(g)
        error("Index not corresponding to a player!")
    end
    coalition, _ = find_coalition(state, i)
    sum_weights = 0
    for j in coalition
        if has_edge(g, i, j) 
            sum_weights += get_weight(g, i, j)
        end
    end
    num_players = length(coalition)
    return sum_weights/num_players
end



# It searchs for a 2-size 1-improving coalition
# It returns nothing if it does not exist
function find_2size_improve_coalition(g::SimpleWeightedGraph{Int64, Float64}, state::Vector{Vector{Int}})::Union{Nothing, Vector{Int}}
    for edge in edges(g)
        i, j = src(edge), dst(edge)
        w = weight(edge)
        if utility(g, state, i) < w/2 && utility(g, state, j) < w/2
            return [i, j]
        end
    end
    return nothing
end



# It searchs for a 2-size or 3-size 1-improving coalition
# It returns nothing if it does not exist
function find_3size_improve_coalition(g::SimpleWeightedGraph{Int64, Float64}, state::Vector{Vector{Int}})::Union{Nothing, Vector{Int}}
    for edge in edges(g)
        w = weight(edge)
        i, j = src(edge), dst(edge)
        if utility(g, state, i) < w/2 && utility(g, state, j) < w/2
            return [i, j]
        end
    end
    for edge in edges(g)
        a, b = src(edge), dst(edge)
        for c in 1:nv(g)
            if c != a && c != b 
                coalition = [a, b, c]
                if is_Kblocking(g, state, coalition, 1)
                    return coalition
                end
            end
        end
    end
    return nothing
end



# It returns the index of the first empty coalition in state 
# It returns "nothing" if no empty coalition is found
function find_empty_coalition(state::Vector{Vector{Int}})::Union{Int, Nothing}
    for (index, c) in enumerate(state)
        if length(c) == 0
            return index
        end
    end
    return nothing
end


# It removes all empty coalitions from state 
function clear_state!(state::Vector{Vector{Int}})
    index = find_empty_coalition(state) 
    while index != nothing
        deleteat!(state, index)
        index = find_empty_coalition(state)
    end
end



# It updates the state by adding the new coalition blocking_coalition
function update_state!(state::Vector{Vector{Int}}, blocking_coalition::Vector{Int})
    for i in blocking_coalition
        coalition_i, index_i = find_coalition(state, i)
        deleteat!(coalition_i, index_i)
    end
    clear_state!(state)
    push!(state, blocking_coalition)
end



# It checks if coalition is a k-blocking coalition
function is_Kblocking(g::SimpleWeightedGraph{Int64, Float64}, state::Vector{Vector{Int}}, coalition::Vector{Int}, k::Float64)::Bool
    num_players = length(coalition)
    for i in coalition
        sum_weights_i = 0
        for j in coalition
            if has_edge(g, i, j) 
                sum_weights_i += get_weight(g, i, j)
            end
         end
        utility_i = sum_weights_i/num_players
        if utility_i ≤ k * utility(g, state, i)
            return false # the coalition is not blocking 
        end
    end
    return true
end



# It randomly searchs for a q-size k-improving coalition
# It returns nothing if it does not exist
function find_Qsize_Kimprove_coalition(g::SimpleWeightedGraph{Int64, Float64}, state::Vector{Vector{Int}}, q::Int, k::Float64)::Union{Nothing, Vector{Int}} 
    if q ≤ 1 || k ≤ 0
        return nothing
    end
    for size in 2:q
        set = randperm(nv(g)) # generate a random permutation of the players. In this way we are able to pick a random coalition 
        # set = 1:nv(g)
        for coalition in combinations(set, size)
            if is_Kblocking(g, state, coalition, k)
                return coalition
            end
        end

    end
    return nothing
end



# Function to get a canonical representation of the state
function state_canonical_representation(state::Vector{Vector{Int}})
    # Sort each vector in the state
    sorted_state = [sort(vec) for vec in state]
    # Sort the list of sorted vectors
    return sort(sorted_state, by=x -> (length(x), x))  # sort primarily by length, then lexicographically
end




# It runs a dynamics of q-size k-improving moves in g starting from initial_state
# It returns the final state and the number of moves 
function dynamics(g::SimpleWeightedGraph{Int64, Float64}, initial_state::Vector{Vector{Int}}, q::Int, k::Float64, max_num_moves::Int)::Tuple{Vector{Vector{Int}},Int,Bool}
    state = deepcopy(initial_state)
    num_moves = 0
    visited_states = Dict{Vector{Vector{Int}}, Bool}() # Dictionary of visited states 
    canonical_state = state_canonical_representation(state) # Calculate the canonical representation 
    visited_states[canonical_state] = true # Store the canonical state in the dictionary
    blocking_coalition = find_Qsize_Kimprove_coalition(g, state, q, k)
    while (blocking_coalition != nothing)  
        update_state!(state, blocking_coalition)
        #println(stdout, state)
        canonical_state = state_canonical_representation(state) # Calculate the canonical representation 

        if haskey(visited_states, canonical_state) # Check if this state has been visited before
            println("Cycle detected!")
            return (state, num_moves, true) # It returns the number of moves to obtain get into a cycle
        else
            visited_states[canonical_state] = true # Store the canonical state in the dictionary
        end

        num_moves += 1
        if num_moves == max_num_moves
            return (state, num_moves, false) # The dynammics terminates if it reaches a maximum number of moves 
        end
        blocking_coalition = find_Qsize_Kimprove_coalition(g, state, q, k)
    end
    return (state, num_moves, false) # It returns the number of moves to obtain a stable state  
end



# It repeatedly generates num_instances graphs. On each of them it runs num_rounds q-size k-improvement dynamics starting from the initial state specified by singleton 
# It returns the average number of moves in each round 
function experiment(n::Int, p::Float64, simple::Bool, singleton::Bool, q::Int, k::Float64, num_instances::Int, num_rounds::Int, max_num_moves::Int)::Matrix{Tuple{Int64, Bool}}
    if q ≤  1
        return nothing
    end 
    if q > n
        q = n 
    end

    # This is used to store the average number of moves for each instance
    #moves = zeros(Float64, num_instances, num_rounds)
    moves = Matrix{Tuple{Int64, Bool}}(undef, num_instances, num_rounds)
    # Fill the matrix with (0.0, false)
    for i in 1:num_instances
        for j in 1:num_rounds
            moves[i, j] = (0.0, false)
        end
    end

    for inst in 1:num_instances 
        # Generate a random weighted graph
        g = generate_weighted_graph(n, p, simple)
        println(stdout, RED * "\nInstance -> $inst/$num_instances" * RESET)
        #write_graph(g)

        # Define the initial state: either singleton or maximum connected components
        initial_state = Vector{Vector{Int}}()
        if singleton 
            initial_state = singleton_state(g)
        else
            initial_state = connected_components(g)
        end

        # It executes num_rounds random q-size k-improvement dynamics on g starting from initial_state
        for r in 1:num_rounds
            #print(stdout, "-- Round $r")
            _, num_moves, cycle = dynamics(g, initial_state, q, k, max_num_moves)
            #println(stdout, " => $num_moves moves")
            if num_moves == 0
                break # if initial_state is stable then do not proceed with other rounds 
            end
            moves[inst, r] = (num_moves, cycle)
        end
    end
    # It returnns the matrix of number of moves  
    return moves
end



end # end module RelaxedCore 
