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
#' STL.20242025 <- SLAP(team="STL")
#' SLAP.season(STL.20242025)
#' }
SLAP.season <- function(SLAPbase){
  season <- uuln(SLAPbase@league@all.games[,"season"])
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
#' STL.20242025 <- SLAP(team="STL")
#' SLAP.team(STL.20242025)
#' }
SLAP.team <- function(SLAPbase){
  # team <- teamName.teamId.triCode(teams.in.league(SLAPbase)[1, ], SLAPbase)
  team <- teamName.teamId.triCode(uuln(SLAPbase@regular.season@player.stats[,"teamId"]), SLAPbase)
  return(team)
}

#' SLAP.zip
#' @importFrom methods is slot slotNames
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
  if(is.na(filename)){
    season <- SLAP.season(SLAPbase)
    teamTriCode <- SLAP.team(SLAPbase)$triCode
    filename <- paste(season, teamTriCode, "zip", sep=".")
  }

  print(season)

  # if(season=="20242025" & teamTriCode=="STL"){
  #   file.copy("load/dataDownload/20242025.STL.zip", file)
  #   return()
  # }

  temp <- tempdir()
  temp.dir <- paste(temp, "temp.dir", sep="/")
  suppressWarnings(dir.create(temp.dir, recursive=TRUE))

  save.csv.recurrsive <- function(object, path, itteration=1){
    if(is(object, "data.frame")){ # if the innermost slot is a data frame, save it
      write.csv(object, paste(path, "csv", sep="."), row.names=FALSE)
      return() # end call
    }else if(is.null(object)){
      return() # end call
    }else if(is(object, "list")){
      suppressWarnings(dir.create(path))
      # cat(paste("\n  ", path))

      slots <- names(object)
      for(slot.number in 1:length(slots)){
        object.slot <- object[[slots[slot.number]]]
        path.slot <- paste(path, slots[slot.number], sep="/")
        save.csv.recurrsive(object.slot, path.slot, itteration=itteration+1)
      }
    }else{
      suppressWarnings(dir.create(path))
      # cat(paste("\n  ", path))

      slots <- slotNames(object)
      for(slot.number in 1:length(slots)){
        object.slot <- slot(object, slots[slot.number])
        path.slot <- paste(path, slots[slot.number], sep="/")
        save.csv.recurrsive(object.slot, path.slot, itteration=itteration+1)
      }
    }

    # fail safe in case of infinite loop
    if(itteration>100){
      return(NULL)
    }
  }

  save.csv.recurrsive(SLAPbase, temp.dir) # Save files to folder


  png.path <- paste("inst/extdata", "SLAPstructure.png", sep="/")
  # png.path <- system.file("extdata", "SLAPstructure.png", package="SLAP")
  print(paste(temp.dir, "SLAPstructure.png", sep="/"))
  file.copy(png.path, paste(temp.dir, "SLAPstructure.png", sep="/"))


  files.dirs <- c(list.files(temp.dir, full.names = TRUE), list.dirs(temp.dir, recursive=FALSE))
  zip::zip(filename, files.dirs, recurse=TRUE, mode="cherry-pick") # Zip files in folder
  # zip(file, list.dirs(temp.dir, recursive=FALSE), recurse=TRUE) # Zip files in folder

  unlink(temp.dir, recursive=TRUE) # Delete unzipped folder
}
