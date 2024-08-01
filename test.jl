module Test


using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Plots")

using CSV
using DataFrames
using Plots
using Printf

include("core.jl")

using .RelaxedCore



struct Parameters 
	NUM_INSTANCES::Int # Num of instances tested for every possible combination of NUM_PLAYERS and PROBABILITIES
	NUM_ROUNDS::Int # Num of dynamics run on every instance 
	NUM_PLAYERS::StepRange{Int, Int} # Range of n (number of players) 
	PROBABILITIES::Vector{Float64} # Range of values of p (edge probabilities)
	MAX_NUM_MOVES::Int # Maximum number of moves performed during the execution of the dynamics
end




function run_test(; is_simple::Bool, is_singleton::Bool, q_size::Union{Int, Nothing}=nothing, k_improvement:: Float64=1.0, parameters:: Parameters, plot_title::String, max_num_moves::Union{Int, Nothing}=nothing)
	
	results = [] # Collection of tuples returned by the experiments 

	cycles = Dict{Tuple{Int64,Float64}, Float64}() 

	if q_size === nothing 
		q_size = parameters.NUM_PLAYERS.stop # If the parameter q_size is missing then we set it to the maximum number of players 
	end

	if max_num_moves === nothing
		max_num_moves = parameters.MAX_NUM_MOVES
	end

	for p in parameters.PROBABILITIES
		for n in parameters.NUM_PLAYERS
			println(stdout, "\n****** p = $p, n = $n ******\n")
			moves = RelaxedCore.experiment(n, p, is_simple, is_singleton, q_size, k_improvement, parameters.NUM_INSTANCES, parameters.NUM_ROUNDS, n*max_num_moves)
			cyclic_rows = RelaxedCore.search_true_rows(moves)
			if size(moves, 1) != parameters.NUM_INSTANCES
				error("Wrong dimension of matrix moves!")
			end
			cycles[(n, p)] = length(cyclic_rows)/size(moves, 1)		
			new_moves = RelaxedCore.delete_rows(moves, cyclic_rows)
			avg_moves, std_moves = RelaxedCore.compute_statistics_moves(new_moves)
			tuple = (n, p, avg_moves, std_moves, is_simple, is_singleton, q_size, k_improvement, size(new_moves, 1), parameters.NUM_ROUNDS, parameters.NUM_PLAYERS, parameters.PROBABILITIES)
			push!(results, tuple)
		end
	end

	# Convert the results to a DataFrame
	data = DataFrame(
		number_of_players = [r[1] for r in results],
		probability_p = [r[2] for r in results],
		avg_moves = [r[3] for r in results],
		std_moves = [r[4] for r in results],
		is_simple = [r[5] for r in results],
		is_singleton = [r[6] for r in results],
		q_size = [r[7] for r in results],
		k_improvement = [r[8] for r in results],
		NUM_INSTANCES = [r[9] for r in results],
		NUM_ROUNDS = [r[10] for r in results],
		NUM_PLAYERS = [r[11] for r in results],
		PROBABILITIES = [r[12] for r in results]
	)


	# Define the x-ticks in the plot
	xticks_val = []
	xticks_label = []
	for n in parameters.NUM_PLAYERS
		push!(xticks_val, n)
		push!(xticks_label, string(n))
	end

	font_name = "Nimbus Roman No9 L" 

	filtered_data  = filter(row -> row.probability_p == parameters.PROBABILITIES[1], data)
	pic = plot(filtered_data.number_of_players, filtered_data.avg_moves, ribbon=filtered_data.std_moves, fillalpha=0.1, linewidth=1, 
				label="p=" * @sprintf("%.2f",parameters.PROBABILITIES[1]),  
				xlabel="number of agents", ylabel="number of deviations", 
				xticks = (xticks_val, xticks_label),  
				title=plot_title, 
				titlefont=font(13,font_name), 
				xtickfont=font(13, font_name),  
				ytickfont=font(13, font_name), 
				guidefont=font(13, font_name),
				legendfont=font(11, font_name),
				size=(500, 375))

	for t in 2:length(parameters.PROBABILITIES)
		filtered_data  = filter(row -> row.probability_p == parameters.PROBABILITIES[t], data)
		plot!(filtered_data.number_of_players, filtered_data.avg_moves, ribbon=filtered_data.std_moves, fillalpha=0.1, linewidth=1, 
				label="p=" * @sprintf("%.2f",parameters.PROBABILITIES[t]))
	end

	# Name of the directory where the results of the experiments are saved 
	dir_name = "tests"

	if !isdir(dir_name)
    	mkdir(dir_name) # Create the directory if it does not exist 
    	println("Directory '$dir_name' created.")
	end

	tuple_filename = (is_simple, is_singleton, q_size, k_improvement, parameters.NUM_INSTANCES, parameters.NUM_ROUNDS, parameters.NUM_PLAYERS, parameters.PROBABILITIES)
	filename = dir_name * "/" * replace(string(tuple_filename),":" => "-")

	# Write the DataFrame to a CSV file
	CSV.write(filename * ".csv", data)
	# Save the Plot in a PNG file 
	savefig(pic, filename * ".pdf")

	println(data)
	display(pic)


	file_cycles_ratio =  open(filename * "_cyles_ratio" * ".csv", "w")
	print(file_cycles_ratio, ", ")
	for p in parameters.PROBABILITIES
		print(file_cycles_ratio, "$(p), ")
	end

	println(file_cycles_ratio, "")
	for n in parameters.NUM_PLAYERS
		print(file_cycles_ratio, "$(n), ")
		for p in parameters.PROBABILITIES
			print(file_cycles_ratio, "$(cycles[(n,p)]*100), ")
		end
		println(file_cycles_ratio, "")
	end

end


end # end module Test 

