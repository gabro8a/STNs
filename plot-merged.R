#########################################################################
# Network Analysis of Search Trajectory Networks (STN)
# Authors: Gabriela Ochoa, Katherine Malan, Christian Blum
# Date: May 2021
# Visualisation of merged STN network of several algorithms
# Input:  File name with merged STN graph object (RData file)
# Output: Network plots (pdf) saved in current folder
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

# Functions for visualisation, and Default Colours -------------------------------- 

# Node Colors
best_ncol  <-  "red"    # Best solution found
end_run_ncol  <- "gray30"  # End of trajectories for each run.
start_ncol <-  "gold"   # Startof trajectories
shared_col <-  "gray70" #  Visitied by more than one algorithms

# Algorithm colors - used for single algorithms - Algorithms will be coloured
# in alphabetical order of their name: orange, blue, green
alg_col    <-  c("#fc8d62", "#377eb8", "#4daf4a")  #  orange, blue  green

# Plot legend

legend.col <- c("gold", "gray30", "red", alg_col, shared_col)

legend.shape <- c(15,17,16,16,16,16,16)  # square and circles


#################################################################
# triangle vertex shape
mytriangle <- function(coords, v=NULL, params) {
  vertex.color <- params("vertex", "color")
  if (length(vertex.color) != 1 && !is.null(v)) {
    vertex.color <- vertex.color[v]
  }
  vertex.size <- 1/200 * params("vertex", "size")
  if (length(vertex.size) != 1 && !is.null(v)) {
    vertex.size <- vertex.size[v]
  }
  
  symbols(x=coords[,1], y=coords[,2], bg=vertex.color, col = vertex.color,
          stars=cbind(vertex.size, vertex.size, vertex.size),
          add=TRUE, inches=FALSE)
}
# clips as a circle
add_shape("triangle", clip=shapes("circle")$clip,
          plot=mytriangle)

# Plot Networks 
# N: Graph objec
# tit: title for type of plot
# ewidthf: factor for vector with 
# asize: arrow size for plots
# nsizef: factor to multiply for node sizes
# ecurv: curvature of the edges (0 = non, 1 = max)
# mylayout: graph layout as a parameter, as differet situatuons require diff. layuts
# bleg = add a legend to the plot

plotNet <-function(N, tit, nsizef, ewidthf, asize, ecurv, mylay, bleg = T) 
{
  
  nsize <-  nsizef * V(N)$size
  ewidth <- ewidthf * E(N)$width
  print(tit)
  plot(N, layout = mylay, vertex.label = "", vertex.size = nsize, 
       edge.width = ewidth, main = tit, 
       edge.arrow.size = asize, edge.curved = ecurv)
  if (bleg == T) {
    legend("topleft", legend.txt, pch = legend.shape, col = legend.col, 
           cex = 0.7, pt.cex=1.4, bty = "n")
  }  
}

# Decorate mrged STN - combining 3 algorithms

# sfac: multiplicative factor for size of nodes
stn_decorate <- function(N)  {
  # Decoration of nodes- best evaluation read from RData file
  # Color of Nodes 
  V(N)$color <- shared_col  # default color of nodes
  for (i in 1:num_alg) {    # Assign color by algorithm order in vector - only colour nodes visited by a single alg.
    V(N)[V(N)$Alg == algn[i]]$color <- alg_col[i]
  }
  
  # Take the IDS of the type of nodes for decoration
  start_nodes <- grepl("start", V(N)$Type, fixed = TRUE)
  end_nodes <- grepl("end", V(N)$Type, fixed = TRUE)
  best_nodes <- grepl("best", V(N)$Type, fixed = TRUE)
  
  V(N)[start_nodes]$color = start_ncol  # Color of start nodes
  V(N)[end_nodes]$color = end_run_ncol  # Color of end of runs nodes
  V(N)[best_nodes]$color = best_ncol   # Color of  best nodes
  
  # Frame colors are the same as node colors, white around best to highlight it
  V(N)$frame.color <- V(N)$color
  V(N)[V(N)$color == shared_col]$frame.color <- "gray40"
  V(N)[grepl("best", V(N)$Type, fixed = TRUE)]$frame.color <- "white"
  
  # Shape of nodes
  V(N)$shape <- "circle"  # circle is the default shape
  V(N)[start_nodes]$shape = "square"  # Square for start nodes
  V(N)[end_nodes]$shape = "triangle"  # Triangle for start nodes
  
  # Size of Nodes Proportional to  incoming degree, 
  V(N)$size <- strength(N, mode="in") + 1   # nodes with strength 0 have at least size 0.8 
  V(N)[end_nodes]$size = V(N)[end_nodes]$size + 0.3 # Increase a a bit size of end nodes
  V(N)[best_nodes]$size = V(N)[best_nodes]$size + 0.6   # Increease a bit more the size of  best nodes
  
  # Color of edges 
  E(N)$color <- shared_col  # default color of edges
  for (i in 1:num_alg) {
    E(N)[E(N)$Alg==algn[i]]$color <- alg_col[i]
  }
  # width of edges proportional to their weight
  E(N)$width <- E(N)$weight
  return(N)
}


#------------------------------------------------------------------------
# Creates a sub-network with nodes with and below a given fitness level 

subFit <- function(N, fvalue)
{
  Top <- induced.subgraph(N,V(N)$Fitness <= fvalue)
  return (Top)
}

# Plot the merged Network
load(infile, verbose = F)

legend.txt <- c("Start", "End", "Best", algn, "Shared")  # needs to read names of algorithms
stnm <- stn_decorate(stnm)
lkk <-layout.kamada.kawai(stnm)
lfr <-layout.fruchterman.reingold(stnm)
# Produce a sub-graph of the merged STN by pruning by fitness  top 25%
zoom <- subFit(stnm,as.numeric(quantile(V(stnm)$Fitness)[2]))  # prune by fitness top 25%, quantile [2]
zoom <- delete.vertices(zoom,degree(zoom)==0)    # Remove isolated nodes

lzfr   <-layout.fruchterman.reingold(zoom)
lzkk <-layout.kamada.kawai(zoom)

ofname <-  gsub('.{6}$', '', infile) # removes  (last 6characters) .RData from file to use as name
ofname = paste0(ofname,'-plot.pdf')


pdf(ofname) 
print(ofname)

nf <- size_factor
ef <- size_factor * 0.7  # Edges width factor is 70% of nodes factor
plotNet(stnm, tit="FR layout", nsizef=nf, ewidthf=ef, asize=0.16, ecurv=0.3, mylay=lfr)
# Slightly smaller nodes and edges for the KK layout as it spreads the components and makes the nodes
# closer to each other
plotNet(stnm, tit="KK Layout", nsizef=nf*0.8, ewidthf=ef*0.8, asize=0.12, ecurv=0.3, mylay=lkk)

# Plots of zoomed  -- Increased summed size and edges as the zoomed network has less nodes 
nf <- size_factor*1.5  
ef <- size_factor

plotNet(N = zoom, tit="Zoomed (top 25%) FR", nsizef=nf, ewidthf=ef, asize=0.35, ecurv=0.3, mylay=lzfr, bleg = T)
plotNet(N = zoom, tit="Zoomed (top 25%) KK", nsizef=nf*0.8, ewidthf=ef*0.8, asize=0.2, ecurv=0.3, mylay=lzkk, bleg = T)

dev.off()

print("Merged STN number of nodes:")
print(vcount(stnm))


