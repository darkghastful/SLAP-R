#' SLAP
#' @importFrom bqutils subset.object uuln content.from.endpoint
#' @importFrom methods new slot<-
#'
#' @param season season string
#' @param team teamName, teamId, or triCode
#' @param game.types list; select one or more c("preseason", "regular.season", "playoffs")
#'
#' @return SLAP object
#' @export
#'
#' @examples
#' SLAP("20242025", "STL")
SLAP <- function(season=current.season(), team, game.types=c("preseason", "regular.season", "playoffs")){
  team <- teamName.teamId.triCode(team)

  all.games.temp <- api.games.by.season(season)
  all.teams.temp <- api.teams.by.season(season)
  all.players.temp <- api.players.by.season(season)


  # Create a SLAP to populate
  SLAPbase <- new("SLAP")

  # add all of the games to game type slots
  ## subset all.games.temp by the provided teams
  all.games.temp.teams <- rbind(subset.object(all.games.temp, team$teamId, "homeTeamId"),
                                subset.object(all.games.temp, team$teamId, "visitingTeamId"))
  ## Order the games.temp.teams by gameId
  all.games.temp.teams <- all.games.temp.teams[order(all.games.temp.teams[, "gameId"]),]

  for(game.type.number in uuln(all.games.temp.teams[,"gameType"])){
    ## pull gameIds from all.games.temp.teams
    game.ids <- uuln(subset.object(all.games.temp.teams, game.type.number, "gameType")[,"gameId"])

    ## create class for the games slot in SLAP
    # create.game.class(season, team$triCode, game.types[game.type.number], game.ids)

    games.in.game.type <- as.list(rep(NA, length(game.ids)))
    names(games.in.game.type) <- game.ids
    ## create object for the games slot in SLAP
    # games.in.game.type <- new(paste(season, paste(team$triCode, collapse="."), game.types[game.type.number], sep="."))

    ## store object in the slot
    slot(slot(SLAPbase, game.types[game.type.number]), "games") <- games.in.game.type
  }

  # populate object with data
  slot(slot(SLAPbase, "league"), "teams") <- all.teams.temp
  slot(slot(SLAPbase, "league"), "players") <- all.players.temp
  slot(slot(SLAPbase, "league"), "all.games") <- all.games.temp


  for(game.type.number in uuln(all.games.temp.teams[,"gameType"])){
    if(game.type.number!=1){
      slot(slot(SLAPbase, game.types[game.type.number]), "player.stats") <- api.players.by.game.type(season, team$triCode, game.type.number)
    }
  }

  # populate game slots one by one

  ## player stats by game content.from.endpoint("https://api-web.nhle.com/v1/player/8478402/game-log/20232024/2")
  ### for each player pull gamelog
  ### pull needed columns
  ### rename columns to fit the standard naming conventions

  for(game.type.number in uuln(all.games.temp.teams[,"gameType"])){
    ## pull gameIds from all.games.temp.teams
    game.ids <- uuln(subset.object(all.games.temp.teams, game.type.number, "gameType")[,"gameId"])

    # Uncomment for publish
    for(game.id.number in 1:length(game.ids)){
      # slot(slot(SLAPbase, game.types[game.type.number]), "games")[[game.id.number]] <- new("game")
      plays <- content.from.endpoint(paste("https://api-web.nhle.com/v1/gamecenter", as.character(game.ids[game.id.number]), "play-by-play", sep="/"))$plays
      if(is.null(plays)){
        next()
      } # added trying to fix
      #go to next game.id.number
      plays[, "eventId"] <- paste0(game.ids[game.id.number], plays[, "eventId"])
      plays <- flatten(plays)
      slot(slot(SLAPbase, game.types[game.type.number]), "games")[[game.id.number]] <- plays
    }
  }

  # order teams by input
  ## if there are more than one team this needs to be ordered
  # <- lapply(teams, teamName.teamId.triCode(teams)$triCode
  teams <- SLAPbase@league@teams
  in.pos <- which(teams[,"triCode"] %in% team$triCode)
  other.pos <- which(!(teams[,"triCode"] %in% team$triCode))
  teams <- teams[c(in.pos, other.pos),]
  SLAPbase@league@teams <- teams

  return(SLAPbase)
}
