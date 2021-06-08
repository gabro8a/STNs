# Search Trajectory Networks (STNs)

<img src="/images/STN.png" alt="STN" width="125" />   Construction, visualisation and analysis.

STNs can be constructed for single algorithms (evolutionary algorithms and other metaheuristics) when solving instances of continuous or combinatorial optimisation problems. Once constructed, the STNs of  two or three algorithms can be merged into a single STN model, which facilitates contrasting the behaviour of the studied algorithms. This repository is associated with the following research article:

Gabriela Ochoa, Katherine Malan, Christian Blum (2021) [Search trajectory networks](https://authors.elsevier.com/a/1d4u35aecSjv5w): A tool for analysing and visualising the behaviour of metaheuristics, *Applied Soft Computing*, Elsevier. https://doi.org/10.1016/j.asoc.2021.107492

Access the article from:  
- Authors' personalised [Share Link](https://authors.elsevier.com/a/1d4u35aecSjv5w)
- Local [pre-print](stns_asoc_2021.pdf)

The repository contains a set of  [R](https://cran.r-project.org/) scripts for constructing, visualising and computing metrics of search trajectory networks (STNs) models extracted from running metaheuristics on optimisation problems.  The scripts use the following R packages: [igraph](https://igraph.org/r/), [plyr](https://cran.r-project.org/web/packages/plyr/index.html) and [tidyr](https://tidyr.tidyverse.org/), whose installation is automated within the provided scripts.

The readme is structured as follows:
1. [Input Data](#part1): describes the format of the input data. 
2. [STNs for single Algorithms](#part2): covers the construction, visualisation and metrics of STNs for single algorithms. 
3. [Merged STNs](#part3): covers the aggregation of the STNs of two or three algorithms into a single merged STN model.

-------------------------------------------------------------------------------------------------------

## 1. Input Data <a name="part1"></a>

The repository contains two folders ([rana](rana) and [pmed7](pmed7)) with examples of input files, for continuous and discrete optimisation respectively.  Each folder has 3  files, each corresponding to a different metaheuristic algorithm. Each file contains the trajectory logs of 10 runs of a single instance-algorithm pair. 

The input files can be formatted as either space/tab separated or comma-separated files. If comma separated files are used, their extension should be .`csv`. For space/tab separated files, any other file extension can be used (such as `.txt` or `.out`).

The files report a list of transitions between consecutive locations in the search space. Each line contains the number of the run, followed by the start and end location of each transition.  So the input files are edges-list used to construct the STN models. 

Let us consider the simple example of the *Onemax* problem for solutions of length 10.  The search space consists of binary strings of length 10, and fitness is an integer value counting the number of ones in the string. The format of the input files for a metaheuristic solving this problem would be as follows: 

| Run  | Fitness1 | Solution1  | Fitness2 | Solution2  |
| ---- | -------- | ---------- | -------- | ---------- |
| 1    | 5        | 0101100011 | 6        | 0101101011 |
| 1    | 6        | 0101101011 | 7        | 1101101011 |
| ...  | ...      | ...        | ...      | ...        |

Where **Run** is the run number (recall that several runs are used to construct an STN model). For each step in the trajectory,  **Fitness1**  and **Solution1** are the fitness value and signature, respectively, of the of the *start* location;  and **Fitness2**  and **Solution2** are the fitness value and signature, respectively, of the of the *end* location. Notice that each step in the trajectory has a *start* and *end* location, and the *start* of the subsequent step is the same as the *end* of the preceding step.

For discrete representations, such as binary strings or integer representations with low arity, the signature of a location can be the same as the solution encoding (a compression scheme can be used for large problems).  However, for continuous encodings or other complex representations, a mapping between the solution encoding and a string representing the location signature is required. There are different ways of implemented such mapping. A detailed description of how we have implemented this, can be found [here](). (tbc) 

## 2. STNs for Single Algorithms <a name="part2"></a>

The following scripts are used for handling single algorithms: 

- [create.R](#create) - Creates STN models from raw data
- [plot-alg.R](#plot-alg) - Plots STN models using force-directed graph layout algorithms
- [plot-alg-tree.R](#plot-alg-tree) - Plots STN models using a tree layout algorithm
- [metrics-alg.R](#metrics-alg) - Computes a set of metrics associated to the STN models  

These are to be run from the command line as described below. 

------

### create.R <a name="create"></a>

Creates the STN models of single algorithms from raw data and saves the created models in an output folder. The input raw data is read from a folder, and the script will process all the files in the folder. The command requires one argument and three optional arguments: 

1. The name of the folder containing the raw data files [*Required*].
2. Boolean[*Optional*] indicating minimisation (1) or maximisation (0). If no argument is given, minimisation (i.e 1) is assumed.
3. The objective value of global optimum (or best-known solution)  of the instance considered [*Optional*], with the desired precision in case of real valued functions.  If no argument is given, the best evaluation value in the collection of input files is used.
4. The number of runs from the input files to be used [*Optional*]. This should be a number between 1 up to total number of runs within in the raw data files. If no argument is given, the largest run number in the collection of input files is used.

Below, some examples of how to run the `create.R` script from the command line, using the provided folders with examples as input:

```
Rscript create.R rana  
Rscript create.R rana 1 0.001
Rscript create.R pmed7  
```

Running the command will create a folder: `rana-stn` or `pmed7-stn` with the RData files containing the STN graphs. The naming convention for the output file is to add the suffix-`stn` to the input folder name.

-------------------------------------------------------------------------------------------------
### plot-alg.R <a name="plot-alg"></a>

Plots the STNs of single algorithms. The command requires one argument and a second optional argument:

1. The name of the folder containing the input STN `RData` files created with the `create.R` script [*Required*]. 
2. A numeric value/real number (size factor) [*Optional*] that multiplies the base size of nodes and edges, so you can make them larger or smaller. The default value of this parameter is 1.

Below, some examples of how to run the `plot-alg.R` script from the command line, using a folder with `RData` files with STN models previously created using the `create.R` script:

```
Rscript plot-alg.R rana-stn 
Rscript plot-alg.R rana-stn 0.8
Rscript plot-alg.R pmed7-stn 
Rscript plot-alg.R pmed7-stn 2
```

Running the command  will create a folder: `rana-stn-plot` or `pmed7-stn-plot` containing  .`pdf` files with visualisations of the STN models. As the naming convention for the output folder, we add the suffix "-plot" to the input folder name.  

Each file contains 2 plots (2 pages, 1 plot per page), each showing a different [force-directed graph layout](https://en.wikipedia.org/wiki/Force-directed_graph_drawing) visualisation of the same graph. Force-directed layouts try to get a nice-looking graph where edges are similar in length and cross each other as little as possible. The first plot uses the Fruchterman-Reingold (FR) layout and the second the Kamada-Kawai (KK) layout as implemented in igraph.

-------------------------------------------------------------------------------------------------
### plot-alg-tree.R <a name="plot-alg-tree"></a>

Plots the STNs of single algorithms using a tree layout. The command works in the same way as the [plot-alg.R](#plot-alg) command described above.

```
Rscript plot-alg-tree.R rana-stn 
Rscript plot-alg-tree.R rana-stn 0.8
Rscript plot-alg-tree.R pmed7-stn 
Rscript plot-alg-tree.R pmed7-stn 2
```

Running the command  will create a folder: `rana-stn-plot-tree` or `pmed7-stn-plot-tree` containing  .`pdf` files with visualisations of the STN models. As the naming convention for the output folder, we add the suffix "-plot-tree" to the input folder name.

Each file contains a single plot visualising the STN using the [Reingold-Tilford](https://igraph.org/r/doc/layout_as_tree.html) graph layout algorithm as implemented in igraph. This layout arranges the nodes in a tree where the given node is used as the root. The tree is directed downwards and the parents are centered above its children.  

This layout is perfect for trees, and sometimes acceptable for graphs with not too many cycles.  It does not work well for graphs with many cycles. This is why we are providing it as a separate script. 

STNs are close to trees in some cases, especially for very large search spaces when there is little overlap between the trajectories, even after partitioning the search space. 

------

### metrics-alg.R <a name="metrics-alg"></a>

Computes a set of metrics associated to the STN models producing a `.csv` file. The command requires a  single argument:

1. The name of the folder containing the input STN `RData` files created with the `create.R` script  [*Required*]. 

Below, some examples of how to run the `metrics-alg.R` script from the command line, using a folder with `RData` files containing STN models created by previously running the `create.R` script:

    Rscript metrics-alg.R rana-stn 
    Rscript metrics-alg.R pmed7-stn 

Running the command will create a `.csv` file in the main directory: `rana-stn-metrics.csv` or `pmed7-stn-metics.csv` containing the values of the following metrics for each file in the folder.

- *instance*: name of the input file with indication of the instance 
- *nodes*: total number of nodes
- *edges*: total number of edges
- *nbest*: number of best nodes (nodes with best fitness value), zero if none exist
- *nend*: number of nodes at the end of trajectories (excluding the best nodes)
- *components*: number of connected components
- *strength*: normalised strength (incoming weighted degree) of best nodes - normalised with the number of runs.  *NA* if *nbest* = 0
- *plength*: average of the shortest path length from start nodes to the best node. *NA* if *nbest* = 0
- *npaths*: number of shortest paths to best optima. Zero if *nbest* = 0

## 3. Merged STNs <a name="part3"></a>

The STNs of two or three algorithms can be merged into a single STN model. The following scripts are provided to handle merged STNs.

- [merge.R](#merge) - Creates the merged STN model from the single STN models of 2 or 3 algorithms
- [plot-merged.R](#plot-merged)- Plots the merged STN model using force-directed layout algorithms
- [plot-merged-tree.R](#plot-merged-tree)- Plots the merged STN model using a tree layout algorithms
- [metrics-merged.R](#metrics-merged) - Computes a set of metrics associated to the merded STN model

These are to be run from the command line as described below. 

------

### merge.R <a name="merge"></a>

Creates the merged STN model from the single STNs of 2 or 3 algorithms. More than 3 STNs cannot be merged with the current version of the software. Future versions may allow this, but bear in mind that the models may get too large, and visualisation and analysis might  become difficult. The idea is to contrast the 2 or 3 best-performing algorithms for your problem, rather than contrasting too many algorithms simultaneously. 

It is expected that the 2 or 3 STN models to merge (`.RData` files produced by the `creat.R` script) are located in a folder, and their file names start with the algorithm acronym followed by a '`_`'. For example, `ILS_`_,`GA_`_, `PSO_`, etc.   

 The command requires a single argument:

1. The name of the folder containing the input STN `RData` files created with the `create.R` script  [*Required*]. 

Below, some examples of how to run the `create.R` script from the command line, using the provided folders with examples as input:

```
Rscript merge.R rana-stn 
Rscript merge.R pmed7-stn 
```

Running the command will create an  `.Rdata` file:   `rana-stn-merged.RData` or  `pmed7-stn-merged.RData` that contains the merged STN model. The naming convention for the output file is to add the suffix `-stn-merged` to the input folder name.

-------------------------------------------------------------------------------------------------

### plot-merged.R <a name="plot-merged"></a>

Plots the merged STN model given as input. The command requires one argument and a second optional argument:

1. The name of the `.RData` file containing the input merged STN model [*Required*].
2. A numeric value/real number (size factor) [*Optional*] that multiplies the base size of nodes and edges, so you can make them larger or smaller.  The default value of this parameter is 1.

Below, some examples of how to run the `plot-merged.R` script from the command line:

```
Rscript plot-merged.R rana-stn-merged.RData 
Rscript plot-merged.R rana-stn-merged.RData 0.8
Rscript plot-merged.R pmed7-stn-merged.RData 
Rscript plot-merged.R pmed7-stn-merged.Rdata 2
```

Running the command will create a file: `rana-stn-merged-plot.pdf` or `pmed7-stn-plot.pdf` with the network visualisations. 

Each file contains 4 plots (4 pages, 1 plot per page). The 1st and 2nd plots show the whole network visualised with 2 different [force-directed graph layout](https://en.wikipedia.org/wiki/Force-directed_graph_drawing) algorithms (Fruchterman-Reingold (FR) and  Kamada-Kawai (KK) layouts), respectively. The 3rd and 4th plots show  a sub-graph of the whole network. Specifically, the nodes with fitness values in the top 25% percentile. Again two alternative graph layouts (Fruchterman-Reingold (FR) and  Kamada-Kawai (KK) layouts) are used.

-------------------------------------------------------------------------------------------------
### plot-merged-tree.R <a name="plot-merged-tree"></a>

Plots the merged STN model given as input using a tree layout. The command works in the same way as the [plot-merged.R](#plot-merged) command described above.

```
Rscript plot-merged-tree.R rana-stn-merged.RData 
Rscript plot-merged-tree.R rana-stn-merged.RData 0.8
Rscript plot-merged-tree.R pmed7-stn-merged.RData 
Rscript plot-merged-tree.R pmed7-stn-merged.Rdata 2
```

Running the command will create a file: `rana-stn-merged-plot-tree.pdf` or `pmed7-stn-plot-tree.pdf` with the network visualisation. 

The file contains a single plot visualising the merged STN using the [Reingold-Tilford](https://igraph.org/r/doc/layout_as_tree.html) graph layout algorithm as implemented in igraph. This layout arranges the nodes in a tree where the given node is used as the root. The tree is directed downwards and the parents are centered above its children.  

This layout is perfect for trees, and sometimes acceptable for graphs with not too many cycles.  It does not work well for graphs with many cycles. This is why we are providing it as a separate script. 

STNs are close to trees in some cases, especially for very large search spaces when there is little overlap between the trajectories, even after partitioning the search space. This layout can be informative as it shows clearly which algorithm has shorter or longer trajectories.

-------------------------------------------------------------------------------------------------
### metrics-merged.R  <a name="metrics-merged"></a>

Computes a set of metrics associated to the merged STN model producing a `.csv` file with the metrics. The command requires a single argument:

1. The name of the `.RData` file containing the input merged STN model [*Required*].

Below, some examples of how to run the `metrics-merged.R` script from the command line:

    Rscript metrics-merged.R rana-stn-merged.RData 
    Rscript metrics-merged.R rana-stn-merged.RData 

Running the command will create a `.csv` file in the main directory: `rana-stn-merged-metrics.csv` or `pmed7-stn-merged-metrics.csv` containing the values of the following metrics:.

- *instance*: name of the input file with indication of the instance 
- *nodes*: total number of nodes
- *edges*: total number of edges
- *nshared*: number of nodes visited by more than one algorithm
- *nbest*: number of best nodes (nodes with best fitness value)
- *nend*: number of nodes at the end of trajectories (excluding the best nodes)
- *components*: number of connected components
- *strength*: normalised strength (incoming weighted degree) of best nodes - normalised with the number of runs.  
