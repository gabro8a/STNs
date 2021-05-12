# Search Trajectory Networks (STNs)

Construction, visualisationa and metrics of STNs for single algorithms and for agregating two or three algorithms.

#### Authors: Gabriela Ochoa, Katherine Malan, Christian Blum

This repository contains a set [R](https://cran.r-project.org/) scripts for constructing, visualising and computing metrics of search trajectory networks (STN) models extracted from running metaheuristics on optimisation problems.  The scripts use the following R packages: [igraph](https://igraph.org/r/), [plyr](https://cran.r-project.org/web/packages/plyr/index.html) and [tidyr](https://tidyr.tidyverse.org/), whose installation is automated within the provided scripts.

This readme file is organised into two parts. Part 1 cover STNs for single algorithms. Part 2 covers the aggregation of the STNs of two or three algorithms into a single merged STN model.

-------------------------------------------------------------------------------------------------------

## Part 1:  Single Algorithms

Three scripts are used for handling single algorithms: 
1) create.R:  Creates an STN model of the algorithm and saves it in an Rdata file  
2) plot-alg.R:     Plots the STN model in the given Rdata file producing a PDF file with the plot
3) metrics-alg.R:  Computes a set of metrics associated to the STN model producing a .csv file 

These are to be run from the command line, in sequence as described below. 

### create.R

Creates the STN models of single algorithms from raw data and saves them in an output folder. The input raw data is given in a folder, and the script will process all the files in the folder.
      - Requires 3 arguments (and a 4th optional argument): 
        1) The name of the folder containing the raw data files. 
        2) The number of runs from the input files to be used. This should be a number between 1 up to total number of runs within in the raw data files.
        3) The objective value of global optimum (or best-known solution) with the desired precision of the instance considered.
        4) Optional argument  0: Maximisation, 1 : Minimisation (default).
      
      - We give two folders as examples of input files "rana" and "pmed7", for continous and discrete optimisation respectively. 
      Each folder has 3 example files, one for each algorithm. Each file contains the trajectories of 10 runs of a single instance-algorithm pair. 

      - To run this script, with the given example folders with raw data you should write in the command line:
      Rscript create.R <folder_name> <num_runs> <best_kwnon>

      Here are some example command lines: 

      Rscript create.R rana 10 0.0
      Rscript create.R rana  6 0.0
      Rscript create.R pmed7 10 5631 
      Rscript create.R pmed7 3  5631 
      

    - This will create a folder: "rana-stn" or "pmed7-stn" with the RData files containing the STN graphs. 
      The naming convention for the output file is to add the suffix "-stn" to the input folder name.
  - The second parameter should be from 1 up to total number of runs within in the raw data files.

-------------------------------------------------------------------------------------------------
2) plot-alg.R:  Plots the STN of a single algorithm.
    - Requires one argument and a 2nd optional argument:
      1) The name of the folder containing the input STN RData files created with the create.R script. 
      2) A numeric value/real number (size factor) that multiplies the base size of nodes and edges, so you can make them larger or smaller.  

    - To run this script you should write in the command line:
    Rscript plot-alg.R <folder_name> <size_factor>  

    Examples: 
    Rscript plot-alg.R rana-stn 
    Rscript plot-alg.R rana-stn 0.8
    Rscript plot-alg.R pmed7-stn 
    Rscript plot-alg.R pmed7-stn 2

    - This will create a folder: "rana-stn-plot" or "pmed7-stn-plot" containing the pdf files plotting the STN graphs. 
    As the naming convention for the output folder, we add the suffix "-plot" to the input folder name. 
    Each file contains 2 plots (2 pages), each showing a different layout visualisation of the network.  
    The first plot uses the Fruchterman-Reingold (FR) layout and the second the Kamada-Kawai (KK) layout as implemented in igraph.

#-------------------------------------------------------------------------------------------------
3) metrics-alg.R - Computes a set of metrics associated to the STN models producing a .csv file 
    - Requires one argument:
      1) The name of the folder containing the input STN RData files created with the create.R script. 

    - To run this script you should write in the command line:
    Rscript metrics-alg.R <folder_name>   

    Examples: 
    Rscript metrics-alg.R rana-stn 
    Rscript metrics-alg.R pmed7-stn 

     - This will create a .csv file in the main directory: "rana-stn-metrics.csv" or "pmed7-stn-metics.csv" containing the values of the following metrics for each file in the folder.
       instance: Name of the file 
       nodes:   Total number of nodes
       edges:   Total number of edges
      nbest:   Number of best nodes (nodes with equal or lower than given best evaluation), zero if none exist
      nend:    Number of nodes at the end of trajectories (excluding the best nodes)
      components: Number of connected components
      The following metrics only apply if the number of best > 0, otherwise they are NA
      strength: Normalised strength (incoming weighted degree) of best nodes - normalised with the number of runs
      plength:  average of the shortest path length from start nodes to the best node, NA if non best exist
      npaths:  Number of shortest paths to best optima




