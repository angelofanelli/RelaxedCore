This repository contains the code of the experimental work described in the manuscript A. Fanelli, G. Monaco, L. Moscardelli, "Relaxed Core Stability", submitted for publication in Artificial Intelligence Journal (https://www.sciencedirect.com/journal/artificial-intelligence)



########
Execution

Execute scripts.jl to run all the experiments  


########
Description of  the experiment

The experiment process starts by randomly generating a weighted (or unweighted) graph with $n$ nodes and whose edges are established based on a given probability $p$ (an edge between any pair of nodes is created with probability $p$).  
This setup allows for the creation of graphs with different values of edge density, depending on the value of $p$. 
Then an initial partition of agents into coalitions (groups) is defined. 
The experiment proceeds with a random sequence of profitable deviations starting from the initial partition. 
The algorithm iteratively checks if there exists a group of agents that can perform a profitable deviation by going through a uniformly sampled sequence of subsets of agents. This random sampling ensures a thorough exploration of possible coalition formations when executing multiple dynamics over the same instance. 
During the dynamics, the algorithm checks for cycles by keeping track of previously encountered outcomes.
The process continues until no further improvements can be made (in this case, the total number of deviations performed is reported) or a cycle is detected. 





