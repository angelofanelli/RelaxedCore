
include("test.jl")

using .Test


##########################################################

# SCRIPT EXPERIMENTS 

##########################################################
# PARAMETERS FOR THE EXPERIMENT


const PAR = Test.Parameters(
    20,                                  # NUM_INSTANCES
    20,         	                     # NUM_ROUNDS
    5:5:20,                              # NUM_PLAYERS
    [Float64(1//20), Float64(1//10), Float64(2//10), Float64(3//10), Float64(1//2)],  # PROBABILITIES
    100                                  # MAX_NUM_MOVES_PER_PLAYER
)



const PARMAX = Test.Parameters(
    50,                                     # NUM_INSTANCES
    50,         	                        # NUM_ROUNDS
    10:10:100,                              # NUM_PLAYERS
    [Float64(1//20), Float64(1//10), Float64(2//10), Float64(3//10), Float64(1//2)],  # PROBABILITIES
    100                                     # MAX_NUM_MOVES_PER_PLAYER
)


##########################################################
# TITLES IN THE PLOT

PLOT_TITLE_ss = "in SS-FHGs from singletons"
PLOT_TITLE_sc = "in SS-FHGs from grand coalition"

PLOT_TITLE_ws = "in S-FHGs from singletons" 
PLOT_TITLE_wc = "in S-FHGs from grand coalition"

##########################################################


# Run test_size with one of the following definitions of the tuple parameters 


# q = 2

parameters = (is_simple = true,  is_singleton = true,  q_size = 2, parameters = PARMAX, plot_title = "2-size core dynamics\n" *  PLOT_TITLE_ss)
Test.run_test(; parameters...)
parameters = (is_simple = true,  is_singleton = false, q_size = 2, parameters = PARMAX, plot_title = "2-size core dynamics\n" *  PLOT_TITLE_sc)
Test.run_test(; parameters...)

# q = 2 (weighted)
parameters = (is_simple = false, is_singleton = true,  q_size = 2, parameters = PARMAX, plot_title = "2-size core dynamics\n" * PLOT_TITLE_ws)
Test.run_test(; parameters...)
parameters = (is_simple = false, is_singleton = false, q_size = 2, parameters = PARMAX, plot_title = "2-size core dynamics\n" * PLOT_TITLE_wc)
Test.run_test(; parameters...)




# k = 1
parameters = (is_simple = true,  is_singleton = true,  parameters = PAR, plot_title = "(1-improvement) core dynamics\n" * PLOT_TITLE_ss)
Test.run_test(; parameters...)
parameters = (is_simple = true,  is_singleton = false, parameters = PAR, plot_title = "(1-improvement) core dynamics\n" * PLOT_TITLE_sc)
Test.run_test(; parameters...)

# k = 1 (weighted)  
parameters = (is_simple = false,  is_singleton = true,  parameters = PAR, plot_title = "(1-improvement) core dynamics\n" * PLOT_TITLE_ws)
Test.run_test(; parameters...)
parameters = (is_simple = false,  is_singleton = false, parameters = PAR, plot_title = "(1-improvement) core dynamics\n" * PLOT_TITLE_wc)
Test.run_test(; parameters...)




# k = 3/2
parameters = (is_simple = true,  is_singleton = true,  k_improvement = 1.5, parameters = PAR, plot_title = "3/2-improvement core dynamics\n" * PLOT_TITLE_ss)
Test.run_test(; parameters...)
parameters = (is_simple = true,  is_singleton = false, k_improvement = 1.5, parameters = PAR, plot_title = "3/2-improvement core dynamics\n" * PLOT_TITLE_sc)
Test.run_test(; parameters...)

# k = 3/2 (weighted) 
parameters = (is_simple = false, is_singleton = true,  k_improvement = 1.5, parameters = PAR, plot_title = "3/2-improvement core dynamics\n" * PLOT_TITLE_ws)
Test.run_test(; parameters...)
parameters = (is_simple = false, is_singleton = false, k_improvement = 1.5, parameters = PAR, plot_title = "3/2-improvement core dynamics\n" * PLOT_TITLE_wc)
Test.run_test(; parameters...)




# k = 2
parameters = (is_simple = true,  is_singleton = true,  k_improvement = 2.0, parameters = PAR, plot_title = "2-improvement core dynamics\n" * PLOT_TITLE_ss)
Test.run_test(; parameters...)
parameters = (is_simple = true,  is_singleton = false, k_improvement = 2.0, parameters = PAR, plot_title = "2-improvement core dynamics\n" * PLOT_TITLE_sc)
Test.run_test(; parameters...)

# k = 2 (weighted)
parameters = (is_simple = false,  is_singleton = true,  k_improvement = 2.0, parameters = PAR, plot_title = "2-improvement core dynamics\n" * PLOT_TITLE_ws)
Test.run_test(; parameters...)
parameters = (is_simple = false,  is_singleton = false, k_improvement = 2.0, parameters = PAR, plot_title = "2-improvement core dynamics\n" * PLOT_TITLE_wc)
Test.run_test(; parameters...)





# q = 3
parameters = (is_simple = true,  is_singleton = true,  q_size = 3, parameters = PARMAX, plot_title = "3-size core dynamics\n" * PLOT_TITLE_ss)
Test.run_test(; parameters...)
parameters = (is_simple = true,  is_singleton = false, q_size = 3, parameters = PARMAX, plot_title = "3-size core dynamics\n" * PLOT_TITLE_sc)
Test.run_test(; parameters...)

# q = 3 (weighted) 
parameters = (is_simple = false,  is_singleton = true,  q_size = 3, parameters = PARMAX, plot_title = "3-size core dynamics\n" * PLOT_TITLE_ws)
Test.run_test(; parameters...)
parameters = (is_simple = false,  is_singleton = false, q_size = 3, parameters = PARMAX, plot_title = "3-size core dynamics\n" * PLOT_TITLE_wc)
Test.run_test(; parameters...)


