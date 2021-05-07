#########################################################################
# Network Analysis of Search Trajectory Networks (STN)
# Authors: Gabriela Ochoa, Katherine Malan, Christian Blum
# Date: May 2021
# Computing metrics of STN networks given on a folder 
# Input:  Folder name with files containing STN graph object (RData file)s
# Output: CSV file with metrics saved in current folder
#########################################################################

library(igraph)  # assume it is already installed for producing STNs

# ---------- Processing inputs from command line ----------
args = commandArgs(trailingOnly=TRUE)   # Take command line arguments

if (length(args) < 1) { #  Test if there are two arguments if not, return an error
  stop("One rgument is required: the input folder with STN objects.", call.=FALSE)
}

infolder <- args[1]

if (!dir.exists(infolder) ){
  stop("Input folder does not exist", call.=FALSE)
}

#--------------------------------------------------------------------------
# Create dataframe with metrics
# instance: Name of the file 
# nodes:   Total number of nodes
# edges:   Total number of edges
# nbest:   Number of best nodes (nodes with equal or lower than given best evaluation), zero if none exist
# nend:    Number of nodes at the end of trajectories (excluding the best nodes)
# components: Number of connected components
# The following metrics only apply if the number of best > 0, otherwise they are NA
# strength: Normalised strength (incoming weighted degree) of best nodes - normalised with the number of runs
# plength:  verage of the shortest path length from start nodes to the best node, NA if non best exist
# npaths:  Number of shortest paths to best optima

col_types =  c("character", "integer", "integer", "integer", "integer", "integer", 
               "numeric", "integer", "integer")

col_names =  c("instance", "nodes", "edges", "nbest", "nend", "components", 
               "strength","plength", 'npaths')

metrics  <- read.table(text = "", colClasses = col_types, col.names = col_names)


# ---- Process all datasets in the given inpath folder ----------------
instances <- list.files(infolder)

i = 1    # index to store in dataframe
for (inst in instances) {
  print(inst)
  fname <- paste0(infolder,"/",inst)
  load(fname, verbose = F)
  iname <-  gsub('.{6}$', '', inst) # removes  (last 5 characters, .RData) from file to use as name
  metrics[i,"instance"] <- iname
  metrics[i,"nodes"] <- vcount(STN)
  metrics[i,"edges"] <- ecount(STN)
  best_ids <- which(V(STN)$Type == "best")  # ids of best nodes
  metrics[i,"nbest"] <- length(best_ids)
  start_ids <- which(V(STN)$Type == "start")  # ids of start nodes
  end_ids <- which(V(STN)$Type == "end")  # ids of end  nodes, which are not best
  metrics[i,"nend"] <- length(end_ids)
  metrics[i,"components"] <- components(STN)$no
  if (length(best_ids) > 0)  { # if there are nodes with best-known evaluation
    best_str <-  sum(strength(STN, vids = best_ids,  mode="in"))  #  incoming strength of best
    metrics[i,"strength"] <- round(best_str/nruns,4)
    dg <- distances(STN, v=start_ids, to = best_ids, mode ="out", weights = NULL)
    d<- dg[is.finite(dg)] # Remove Inf values from distance matrix d
    metrics[i,"plength"] <- round(mean(d),4) # average length of shortest path to best
    metrics[i,"npaths"] <- length(d)      # Number of shortest paths to best
  } else {
    metrics[i,"plength"] <- NA   # average length of shortest path to best
    metrics[i,"npaths"] <-0      # Number of shortest paths to best
  }
  i = i+1
}

# Save metrics as .csv file
# Create outfolder folder to save STN objects  -- rule append "-plot" to input folder
ofname <- paste0(infolder,"-metrics.csv")

write.csv(metrics, file = ofname)