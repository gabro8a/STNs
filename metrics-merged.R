#########################################################################
# Network Analysis of Search Trajectory Networks (STN)
# Authors: Gabriela Ochoa, Katherine Malan, Christian Blum
# Date: May 20201
# Computing metrics of a merged STN network given as input
# Input:  File .RData containing Merged STN graph object 
# Output: CSV file with metrics saved in current folder
#########################################################################

library(igraph)  # assume it is already installed for producing STNs

# ---------- Processing inputs from command line ----------
args = commandArgs(trailingOnly=TRUE)   # Take command line arguments

if (length(args) < 1) { #  Test if there are two arguments if not, return an error
  stop("One rgument is required: the input folder with stn objects. \\
        A 2nd argument can be given, a size factor to scale nodes and edges", call.=FALSE)
}
infile <- args[1]

if (!file.exists(infile) ){
  stop("Input file does not exist", call.=FALSE)
}

if (length(args) > 1) {
  size_factor <- as.integer(args[2])
} else {
  size_factor <- 1
}

if (is.na(size_factor)) {
  stop("2nd argument is not a number", call.=FALSE)
}

#--------------------------------------------------------------------------
# Create dataframe with metrics
# instance: Name of the file 
# nodes:   number of nodes
# edges:   Total number of edges
# nshared: number of nodes visited by more than one algorithm
# nbest:   number of best nodes (nodes with equal or lower than given best evaluation)
# nend:    number of nodes at the end of trajectories (excluding the best nodes)
# components: Number of connected components
# strength: normalised strength (incoming weighted degree) of best nodes - normalised with the number of runs.  

col_types =  c("character", "integer", "integer", "integer", 
               "integer", "integer", "integer", "numeric")

col_names =  c("instance", "nodes", "edges", "nshared", 
               "nbest", "nend", "components", "strength")
metrics  <- read.table(text = "", colClasses = col_types, col.names = col_names)

# ---- Process all datasets in the given input folder ----------------

i = 1    # index to store in dataframe. Single column dataaset

cat ("Input file: ", infile, "\n" )
load(infile, verbose = F)

iname <-  gsub('.{6}$', '', infile) # removes  (last 6 characters, .RData) from file to use as name
metrics[i,"instance"] <- iname
metrics[i,"nodes"] <- vcount(stnm)
metrics[i,"edges"] <- ecount(stnm)

# Take the IDS of the nodes for metric computation
end_nodes <- which(grepl("end", V(stnm)$Type, fixed = TRUE))
best_nodes <- which(grepl("best", V(stnm)$Type, fixed = TRUE))

metrics[i,"nshared"] <- length(which(V(stnm)$Shared == TRUE))
metrics[i,"nbest"] <- length(best_nodes)
metrics[i,"nend"] <- length(end_nodes)
metrics[i,"components"] <- components(stnm)$no
# Strength metric
best_str <-  sum(strength(stnm, vids = best_nodes,  mode="in"))  #  incoming strength of best
metrics[i,"strength"] <- round(best_str/(num_alg*nruns),4)   # normalised by total number of runs

# Save metrics as .csv file
ofname <- paste0(iname,"-metrics.csv")   # file name and -metrics
cat ("Output file: ", ofname, "\n" )
write.csv(metrics, file = ofname)