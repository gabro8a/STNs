#########################################################################
# Network Analysis of Search Trajectory Networks (STN)
# Authors: Gabriela Ochoa, Katherine Malan, Christian Blum
# Date: May 2021
# Construction of merged STN network of several algorithms
# Input:  Folder containing RData files of algorithm STNs to merge 
#         It is assumed that the folder contains one file per algorithm to merge  
# Output: Merged STN graph object - saved in current directory as an .RData file
#############################################################################

# ---------- Processing input from command line ----------

args = commandArgs(trailingOnly=TRUE)   # Take command line arguments
if (length(args) < 1) {  #  Test if there is one argument if not, return an error
   stop("One argument is required: the input folder with STNs files to merge.", call.=FALSE)
}

infolder <- args[1]
if (!dir.exists(infolder) ){
  stop("Input folder does not exist", call.=FALSE)
}

## Packages required
# igraph: tools handling graph objects
# dplyr:  tools for working with data frames (we used function "coalesce")
# tidyr:  tools to help to create tidy data  (we used function "replace_na")

packages = c("igraph", "dplyr", "tidyr")

## If a package is installed, it will be loaded. If any are not, 
## the missing package(s) will be installed from CRAN and then loaded.

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      suppressWarnings(library(x, character.only = TRUE))
    }
  }
)

# ---- Read input files given folder ----------------

data_files <- list.files(infolder)
cat("Input folder: ", infolder, "\n")
num_alg <- length(data_files)  # Number of algorithms

if (num_alg < 2 || num_alg > 3 ){
  stop("Number of algorithms to merge can only be 2 or 3", call.=FALSE)
}  

alg <- vector(mode = "list", length = num_alg) # to keep the STNS of the algorithms 
algn <-vector(mode = "character", length = num_alg) # to keep names of the algorithms 


i <- 1
for (f in data_files) {
  alg_name <- strsplit(f,"_")[[1]][1]   # Assume that the name of the algorithm is the first string before the "_"
  print(alg_name)
  fname <- paste0(infolder,"/",f)
  load(fname, verbose = F)
  # Add Algorithm as a property of nodes and edges 
  V(STN)$Alg <- alg_name
  E(STN)$Alg <- alg_name
  algn[i] <- alg_name
  alg[[i]] <- STN   # keep STN in a list to then proceed with unioning the graphs 
  i <- i + 1
}

# Union the separate algorithms graphs 
stnm <- graph.union(alg)

# The part of the code below is not pretty (not to proud of it), if someone knows a better way to do it, please let me know!
# The problem is that when creating a union graph, the attributes with the same name are given a counter
# So for the merged networks, the attributes need to be combined, and the numbered attributes removed 
# I am doing this manually for 2 or 3 algorithms being merged. 
# It remains as future work to generalise this code for more than 3 algorithms,doing somore elegantly!

# Creating Node attributes for merged network, combining the previous attributes
# It works for 2 o3 3 algorithms only

# This handles the two main attributes of nodes: Fitness and Count
if (num_alg == 2) {
  V(stnm)$Fitness <- coalesce(V(stnm)$Fitness_1, V(stnm)$Fitness_2) # Simply keeps the first fitness and removes NA
  V(stnm)$Count <-  rowSums(cbind(V(stnm)$Count_1, V(stnm)$Count_2), na.rm=TRUE)
} else {  
  V(stnm)$Fitness <- coalesce(V(stnm)$Fitness_1, V(stnm)$Fitness_2, V(stnm)$Fitness_3)
  V(stnm)$Count <-  rowSums(cbind(V(stnm)$Count_1, V(stnm)$Count_2, V(stnm)$Count_3), na.rm=TRUE)
}

# This deals with the attributes Type and Alg, which are strings. The idea is to concatenate the strings
# as a given node can have more than one Type and more than one Alg (comming from each algorithm STNs).
# Concatenation of the algorithms visiting a node
V(stnm)$Type_1 <- replace_na(V(stnm)$Type_1,"")
V(stnm)$Type_2<-replace_na(V(stnm)$Type_2, "")
V(stnm)$Alg_1 <- replace_na(V(stnm)$Alg_1,"")
V(stnm)$Alg_2<-replace_na(V(stnm)$Alg_2, "")
if (num_alg == 2) {
  dft <- data.frame(V(stnm)$Type_1, V(stnm)$Type_2)
  dfa <- data.frame(V(stnm)$Alg_1, V(stnm)$Alg_2)
} else { 
  V(stnm)$Alg_3<-replace_na(V(stnm)$Alg_3, "")
  V(stnm)$Type_3<-replace_na(V(stnm)$Type_3, "")
  dft <- data.frame(V(stnm)$Type_1, V(stnm)$Type_2, V(stnm)$Type_3)
  dfa <- data.frame(V(stnm)$Alg_1, V(stnm)$Alg_2, V(stnm)$Alg_3)
}  

dft <- unite(dft,"Type", remove = T, sep = "")
dfa <- unite(dfa,"Alg", remove = T, sep = "")


V(stnm)$Type <- as.vector(dft$Type) # Contains a concatenation of types of nodes associated with each node
V(stnm)$Alg <- as.vector(dfa$Alg)   # Contains a concatenation of Algorithms names that visited each node

# Remove vertex attributes that are no longer needed 
old_vattr = c("Fitness_1", "Fitness_2", "Count_1", "Count_2", 
              "Type_1", "Type_2", "Alg_1", "Alg_2")
if (num_alg == 3) {
  old_vattr = c(old_vattr, "Fitness_3", "Count_3", "Alg_3", "Type_3")
}
for (i in old_vattr) {
  stnm<-delete_vertex_attr(stnm, name = i)
}  

# Creating Edge attributes for merged network, combining the previous attributes
if (num_alg == 2) {  # Weights are summed, aggregating the visits of the combined algorithms
  E(stnm)$weight <- rowSums(cbind(E(stnm)$weight_1, E(stnm)$weight_2), na.rm=TRUE)
} else {
  E(stnm)$weight <- rowSums(cbind(E(stnm)$weight_1, E(stnm)$weight_2, E(stnm)$weight_3), na.rm=TRUE)
}

#  Concatenation of the algorithms visiting an edge
E(stnm)$Alg_1 <- replace_na(E(stnm)$Alg_1,"")
E(stnm)$Alg_2<-replace_na(E(stnm)$Alg_2, "")
if (num_alg == 2) {
  dfa <- data.frame(E(stnm)$Alg_1, E(stnm)$Alg_2)
} else {  
  E(stnm)$Alg_3<-replace_na(E(stnm)$Alg_3, "")
  dfa <- data.frame(E(stnm)$Alg_1, E(stnm)$Alg_2, E(stnm)$Alg_3)
}

dfa <- unite(dfa,"Alg", remove = T, sep = "")
E(stnm)$Alg <- as.vector(dfa$Alg)
# Remove vertex attributes that are no longer needed 
old_eattr = c("weight_1", "weight_2", "Alg_1", "Alg_2")
if (num_alg == 3) {
  old_eattr = c(old_eattr,"weight_3", "Alg_3")
}
for (i in old_eattr) {
  stnm <- delete_edge_attr(stnm, name = i)
} 
# Detecting shared nodes, that were visited by more than one algorithm
# Keep an attribute for shared nodes, this is later useful for visualisation and metrics
V(stnm)$Shared <- TRUE  # Assume shared node
for (i in 1:num_alg) { #  Detect nodes visited by a single Algorithm
  V(stnm)[V(stnm)$Alg == algn[i]]$Shared <- FALSE
}


# save useful variables for later report metrics
# stnm: merged STN network
# nruns number of runs for creating singl STNs
# num_alg: number of algorithms merged
# algn:  names of the algorithms merged
# bmin: Boolean indicating if minimisation (or maximisation), it comes from the indiviual STNs
# best: Best evaluation, it also comes from the individual STNs

# Create output file and save the relevant objects

ofname <- paste0(infolder,"-merged.RData")
cat("Output file: ", ofname, "\n")
save(stnm, nruns, num_alg, algn, bmin, best, file= ofname)




