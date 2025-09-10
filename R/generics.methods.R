
# setGeneric("preseason", function(SLAPbase) standardGeneric("preseason"))
#
#
# setMethod("preseason", )

#' @describeIn SLAP compact print
#' @importFrom methods show
#'
#' @param object a \code{SLAPbase} object
#' @export
setMethod("show", "SLAP", function(object) {
  cat(sprintf("SLAP"))
  invisible(object)
})

## phyloseq-class experiment-level object
## otu_table()   OTU Table:         [ 10 taxa and 10 samples ]
## sample_data() Sample Data:       [ 10 samples by 2 sample variables ]
## tax_table()   Taxonomy Table:    [ 10 taxa by 7 taxonomic ranks ]
## phy_tree()    Phylogenetic Tree: [ 10 tips and 9 internal nodes ]
