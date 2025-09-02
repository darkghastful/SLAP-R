
#' @export
general.league.information <- function(...){
  object <- do.call("new", c(Class="general.league.information", list(...)))
  return(object)
}


#' api.teams.by.season
#'
#' @param season season string
#'
#' @return dataframe
#' @export
#'
#' @examples
#' api.teams.by.season("20242025")
api.teams.by.season <- function(season){
  all.games.temp <- api.games.by.season(season)

  all.teams.temp <- content.from.endpoint("https://api.nhle.com/stats/rest/en/team")$data
  colnames(all.teams.temp)[which.col.name(all.teams.temp, "id")] <- "teamId"
  colnames(all.teams.temp)[which.col.name(all.teams.temp, "fullName")] <- "teamName"
  all.teams.temp <- subset.object(all.teams.temp, uuln(all.games.temp[, c("homeTeamId")]), "teamId")
  all.teams.temp <- all.teams.temp[, c("teamId", "triCode", "teamName")]
  # assign("all.teams.temp", all.teams.temp, envir=parent.env(environment()))
  return(all.teams.temp)
}

#' api.players.by.season
#'
#' @param season season string
#'
#' @return dataframe
#' @export
#'
#' @examples
#' api.players.by.season("20242025")
api.players.by.season <- function(season){
  # csv.path <- paste0("inst/extdata/players/", season, ".players.csv")
  csv.path <- system.file("extdata/players", paste0(season, ".players.csv"), package="SLAP")
  if(file.exists(csv.path)){
    all.players.temp <- read.csv(csv.path)
    return(all.players.temp)
  }

  all.teams.temp <- api.teams.by.season(season)

  season.team.tri.codes <- all.teams.temp[,"triCode"]
  suppressWarnings(rm("players.by.team"))
  suppressWarnings(rm("all.players.temp"))
  for(team.number in 1:length(season.team.tri.codes)){
    season.roster <- content.from.endpoint(paste("https://api-web.nhle.com/v1/roster", season.team.tri.codes[team.number], season, sep="/"))
    for(season.roster.number in 1:length(season.roster)){
      if(length(season.roster[[season.roster.number]])==0){
        break
      }
      player.type.embeded <- season.roster[[season.roster.number]]
      player.type <- player.type.embeded[,!uln(lapply(player.type.embeded, class))=="data.frame"]
      player.type.embeded <- flatten(player.type.embeded)
      player.type <- cbind(player.type, player.type.embeded[,str_detect(colnames(player.type.embeded), "default")])

      colnames(player.type) <- uln(lapply(str_split(colnames(player.type), "[.]"), `[[`, 1))
      if(season.roster.number==1){
        players.by.team <- player.type
      }else{
        players.by.team <- merge(players.by.team, player.type, all=TRUE)
      }
    }

    if(exists("players.by.team")){
      colnames(players.by.team)[which.col.name(players.by.team, "id")] <- "playerId"
      players.by.team[, "teamId"] <- all.teams.temp[team.number, "teamId"]

      if(!exists("all.players.temp")){
        all.players.temp <- players.by.team
      }else{
        all.players.temp <- rbind(all.players.temp, players.by.team)
      }
    }
  }
  return(all.players.temp)
}



#' api.games.by.season
#'
#' @param season season string
#'
#' @return dataframe
#' @export
#'
#' @examples
#' api.games.by.season("20242025")
api.games.by.season <- function(season){
  # csv.path <- paste0("inst/extdata/games/", season, ".games.csv")
  csv.path <- system.file("extdata/games", paste0(season, ".games.csv"), package="SLAP")
  all.games.temp <- read.csv(csv.path)

  # all.games.temp[,"Date"] <- format(as.Date(all.games.temp[,"easternStartTime"], format="%Y-%m-%dT%H:%M:%S"), "%m-%d-%Y")
  all.games.temp <- all.games.temp[,c("season", "gameId", "easternStartTime", "gameDate", "gameType", "period", "homeScore", "visitingScore", "homeTeamId", "visitingTeamId")]

  # colnames(all.games.temp)[which.col.name(all.games.temp, "id")] <- "gameId"
  all.games.temp <- subset.object(all.games.temp, season, "season")
  # assign("all.games.temp", all.games.temp, envir=parent.env(environment()))
  return(all.games.temp)
}


#' api.players.by.game.type
#'
#' @param season season string
#' @param team triCode
#' @param game.type choose one ("regular.season" or 2) ("playoffs" or 3)
#'
#' @return dataframe
#' @export
#'
#' @examples
#' api.players.by.game.type("20242025", "STL", "regular.season")
api.players.by.game.type <- function(season, team, game.type){
  suppressWarnings(rm("temp.game.type.players"))
  suppressWarnings(rm("players.by.game.type.frame"))

  if(is(game.type, "character")){
    if(game.type=="pre.season"){
      game.type <- 1
    }else if(game.type=="regular.season"){
      game.type <- 2
    }else if(game.type=="playoffs"){
      game.type <- 3
    }
  }

  for(team.number in 1:length(team)){
    game.type.player.stats <- content.from.endpoint(paste("https://api-web.nhle.com/v1/club-stats", team[team.number], season, game.type, sep="/"))
    for(game.type.player.stats.number in 1:length(game.type.player.stats)){
      if(length(game.type.player.stats[[game.type.player.stats.number]])==0){
        break
      }
      if(class(game.type.player.stats[[game.type.player.stats.number]])=="data.frame"){
        player.type.embeded <- game.type.player.stats[[game.type.player.stats.number]]
        player.type <- player.type.embeded[,!uln(lapply(player.type.embeded, class))=="data.frame"]
        player.type.embeded <- flatten(player.type.embeded)
        player.type <- cbind(player.type, player.type.embeded[, str_detect(colnames(player.type.embeded), "default")])

        colnames(player.type) <- uln(lapply(str_split(colnames(player.type), "[.]"), `[[`, 1))
        if(!exists("players.by.game.type.frame")){
          players.by.game.type.frame <- player.type
        }else{
          players.by.game.type.frame <- merge(players.by.game.type.frame, player.type, all=TRUE)
        }
      }
    }

    if(exists("players.by.game.type.frame")){
      colnames(players.by.game.type.frame)[which.col.name(players.by.game.type.frame, "id")] <- "playerId"
      players.by.game.type.frame[, "teamId"] <- teamName.teamId.triCode(team[team.number])$teamId

      if(!exists("temp.game.type.players")){
        temp.game.type.players <- players.by.game.type.frame
      }else{
        temp.game.type.players <- rbind(temp.game.type.players, players.by.game.type.frame)
      }
    }
  }
  return(temp.game.type.players)
}



