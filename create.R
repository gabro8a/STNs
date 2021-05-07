#########################################################################
# Network Analysis of Search Trajectory Networks (STN)
# Authors: Gabriela Ochoa, Katherine Malan, Christian Blum
# Date: May 2021
# STN construction for single algorithms. 
# Input:  Folder containing text file trace of runs, number of runs
# Output: STN graph objects - saved in output folder 
#########################################################################
# ---------- Processing inputs from command line ----------
args = commandArgs(trailingOnly=TRUE)   # Take command line arguments
#  Test if there are two arguments if not, return an error
if (length(args) < 3) {
  stop("3 arguments are required, and the 4th is optional: \ 
       1) The input folder and \
       2) The number of runs from data to be used.\
       3) The global optimum (or best-knwon solution) evaluation (with the desired precision).\
       4) Optional argument  0: Maximisation, 1 : Minimisation (default).", call.=FALSE)
}

infolder <- args[1]
nruns <- as.integer(args[2])
best <- as.numeric(args[3])
bmin <- 1

if (length(args) > 3){
  bmin <- as.integer(args[4])
}

if (!dir.exists(infolder) ){
  stop("Input folder does not exist", call.=FALSE)
}

if (is.na(nruns)) {
  stop("2nd (number of runs) argument is not a number", call.=FALSE)
}

if (is.na(best)) {
  stop("3nd argument (best-known) is not a number", call.=FALSE)
}

## Packages required
# igraph: tools handling graph objects
# plyr:   tools for Splitting, Applying and Combining Data

packages = c("igraph", "plyr")

## If a package is installed, it will be loaded. If any are not, 
## the missing package(s) will be installed from CRAN and then loaded.

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

# Function for Creating the STN of a given instance/algorithm 
# Read data from text input file and construct the STN network model
# Saves the STN oject in a file within the outfolder
# Returns numebr of nodes of the STN

stn_create <- function(instance)  {
  fname <- paste0(infolder,"/",instance)
  print(fname)
  trace_all <- read.table(fname, header=T,
                          colClasses=c("integer", "numeric", "character", "numeric", "character"),
                          stringsAsFactors = F)
  trace_all <- trace_all[trace_all$Run <= nruns,]
  lnodes <- vector("list", nruns)
  ledges <- vector("list", nruns)
  
  # Store the nodes at the end of runs. Need to detect change of Run
  k = 1
  end_ids <- vector()
  start_ids <- vector()
  n <- nrow(trace_all)-1
  start_ids[1] <- trace_all$Solution1[1]
  for (j in (1:n)) {
    if (trace_all$Run[j] != trace_all$Run[j+1]) { # when the run counter changes
      end_ids[k] <- trace_all$Solution2[j]        # keep the name of the end solution
      start_ids[k+1] <- trace_all$Solution1[j+1]  # keep the name of the next start solution
      k = k+1
    }
  }
  end_ids[k] <- trace_all$Solution2[j+1]   # last end ID -s considered as the end of the trajectory
  
  end_ids <- unique(end_ids)     # only unique nodes required
  start_ids <- unique(start_ids)
  
  for (i in (1:nruns)) {  # combine all runs in a single network
    trace <- trace_all[which(trace_all$Run==i),c(-1)] # take by run and remove first column run number
    colnames(trace) <- c("fit1", "node1", "fit2", "node2")  # set simpler names to column
    lnodes[[i]] <- rbind(setNames(trace[,c("node1","fit1")], c("Node", "Fitness")),
                         setNames(trace[,c("node2","fit2")], c("Node", "Fitness")))
    ledges[[i]] <- trace[,c("node1", "node2")]
  }
  
  # combine the list of nodes into one dataframe and
  # group by (Node,Fitness) to identify unique nodes and count them
  nodes <- ddply((do.call("rbind", lnodes)), .(Node,Fitness), nrow)
  colnames(nodes) <- c("Node", "Fitness", "Count")
  nodesu<- nodes[!duplicated(nodes$Node), ]  # eliminate duplicates from dataframe, in case node ID us duplicated
  # combine the list of edges into one dataframe and
  # group by (node1,node2) to identify unique edges and count them
  edges <- ddply(do.call("rbind", ledges), .(node1,node2), nrow)
  colnames(edges) <- c("Start","End", "weight")
  
  STN <- graph_from_data_frame(d = edges, directed = T, vertices = nodesu) # Create graph
  STN <- simplify(STN,remove.multiple = F, remove.loops = TRUE)  # Remove self loops
  
  if (bmin) {  # minimisation problem 
    best_ids <- which(V(STN)$Fitness <= best)
  } else {    # maximisation  
    best_ids <- which(V(STN)$Fitness >= best)
  }
  # Four types of nodes, useful for visualisation: Start, End, Best and Standard.
  V(STN)$Type <- "standard"  # Default type
  V(STN)[end_ids]$Type <- "end"
  V(STN)[start_ids]$Type <- "start"
  V(STN)[best_ids]$Type <- "best"
  
  fname <-  gsub('.{4}$', '', instance) # removes  (last 4 characters, .ext) from file to use as name
  fname <- paste0(outfolder,"/",fname,"_stn.RData")
  save(STN,nruns, bmin, best, file=fname) # Store STN, wether it is a minimisation problem and the best-known given
  return(vcount(STN))
}

# Create outfolder folder to save STN objects  -- rule append "-stn" to input folder

outfolder <- paste0(infolder,"-stn")

if (!dir.exists(outfolder) ){
  dir.create(outfolder)
}
cat("Output folder: ", outfolder, "\n")

# ---- Process all datasets in the given inpath folder ----------------
data_files <- list.files(infolder)

nsizes <- lapply(data_files, stn_create)  # Applies stn_creat function to all files
print("Numer of nodes in the STNs created:")
print(as.numeric(nsizes))



