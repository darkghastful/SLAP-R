# SLAP.name <- function(SLAPbase){
#   season <- SLAP.season(SLAPbase)
#   teamTriCode <- SLAP.team(SLAPbase)$triCode
#   return(paste(season, teamTriCode, sep="."))
# }

#' SLAP.season
#'
#' @param SLAPbase SLAPbase
#'
#' @return character
#' @export
#'
#' @examples
#' \dontrun{
#'  STL.20242025 <- SLAP(team="STL")
#'  SLAP.season(STL.20242025)
#' }
SLAP.season <- function(SLAPbase){
  season <- str_split(class(SLAPbase@regular.season@games.played), "\\.")[[1]][1]
  return(season)
}

#' SLAP.team
#'
#' @param SLAPbase SLAPbase
#'
#' @return list(teamName, teamId, triCode)
#' @export
#'
#' @examples
#' \dontrun{
#'  STL.20242025 <- SLAP(team="STL")
#'  SLAP.team(STL.20242025)
#' }
SLAP.team <- function(SLAPbase){
  # team <- teamName.teamId.triCode(teams.in.league(SLAPbase)[1, ], SLAPbase)
  team <- teamName.teamId.triCode(uuln(SLAPbase@regular.season@players.by.game.type[,"teamId"]), SLAPbase)
  return(team)
}

#' SLAP.zip
#' @importFrom methods slot slotNames
#' @importFrom utils write.csv
#' @importFrom zip zip
#'
#' @param SLAPbase SLAPbase
#' @param filename default is working dir/season.team.zip
#'
#' @return zip save
#' @export
#'
#' @examples
#' \dontrun{
#' STL.20242025 <- SLAP(team="STL")
#' SLAP.zip(STL.20242025, "STL.20242025.zip")
#' }
SLAP.zip <- function(SLAPbase, filename=NA){
  season <- SLAP.season(SLAPbase)
  teamTriCode <- SLAP.team(SLAPbase)$triCode

  if(is.na(filename)){
    filename <- paste(season, teamTriCode, "zip", sep=".")
  }

  print(season)

  # if(season=="20242025" & teamTriCode=="STL"){
  #   file.copy("load/dataDownload/20242025.STL.zip", file)
  #   return()
  # }

  temp <- tempdir()
  temp.dir <- paste(temp, "temp.dir", sep="/")
  suppressWarnings(dir.create(temp.dir))

  # png.path <- paste0("inst/extdata", "SLAPstructure.png")
  png.path <- system.file("extdata", "SLAPstructure.png", package="SLAP")
  file.copy(png.path, "SLAPstructure.png")

  save.csv.recurrsive <- function(object, path, itteration=1){
    if(class(object)=="data.frame"){ # if the innermost slot is a data frame, save it
      write.csv(object, paste(path, "csv", sep="."), row.names=FALSE)
      # cat(paste("\n   ", path))
      return() # end call
    }else if(class(object)=="NULL"){
      # cat(("\n   NULL"))
      return() # end call
    }

    suppressWarnings(dir.create(path))
    # cat(paste("\n  ", path))

    slots <- slotNames(object)
    for(slot.number in 1:length(slots)){
      object.slot <- slot(object, slots[slot.number])
      path.slot <- paste(path, slots[slot.number], sep="/")
      save.csv.recurrsive(object.slot, path.slot, itteration=itteration+1)
    }

    # fail safe in case of infinite loop
    if(itteration>100){
      return(NULL)
    }
  }

  save.csv.recurrsive(SLAPbase, temp.dir) # Save files to folder
  print(list.dirs(temp.dir, recursive=FALSE))
  zip::zip(filename, list.dirs(temp.dir, recursive=FALSE), recurse=TRUE, mode="cherry-pick") # Zip files in folder
  # zip(file, list.dirs(temp.dir, recursive=FALSE), recurse=TRUE) # Zip files in folder

  unlink(temp.dir, recursive=TRUE) # Delete unzipped folder
}
