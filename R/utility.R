#' teamName.teamId.triCode
#' @importFrom stringr str_split
#'
#' @param team teamName, teamId, or triCode
#' @param SLAPbase SLAPbase
#'
#' @return list(teamName, teamId, triCode)
#' @export
#'
#' @examples
#' teamName.teamId.triCode("STL")
teamName.teamId.triCode <- function(team, SLAPbase=NA){
  if(suppressWarnings(is.na(SLAPbase))){
    object <- api.teams.by.season(current.season())
  }else{
    object <- SLAPbase@league@teams
  }


  if(length(str_split(team, " ")[[1]])>1){
    row <- object[,"teamName"]==team
  }else if(!grepl("[^0-9]", as.character(team))){
    row <- object[,"teamId"]==as.numeric(team)
  }else{
    row <- object[,"triCode"]==team
  }

  return(as.list(object[row, c("teamName", "teamId", "triCode")]))
}


#' current.season
#'
#' @return character
#' @export
#'
#' @examples
#' current.season()
current.season <- function(){
  return("20242025")
  # seasons <- content.from.endpoint("https://api-web.nhle.com/v1/season")
  # return(rev(seasons)[1])
}
