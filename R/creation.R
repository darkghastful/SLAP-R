#' SLAP
#' @importFrom bqutils subset.object uuln content.from.endpoint
#'
#' @param season season string
#' @param team teamName, teamId, or triCode
#'
#' @return SLAP object
#' @export
#'
#' @examples
#' SLAP("20242025", "STL")
SLAP <- function(season=current.season(), team, game.types=c("pre.season", "regular.season", "playoffs")){
  team <- teamName.teamId.triCode(team)

  all.games.temp <- api.games.by.season(season)
  all.teams.temp <- api.teams.by.season(season)
  all.players.temp <- api.players.by.season(season)


  # Create a SLAP to populate
  SLAP <- new("SLAP")

  # add all of the games to game type slots
  ## subset all.games.temp by the provided teams
  all.games.temp.teams <- rbind(subset.object(all.games.temp, team$teamId, "homeTeamId"),
                                subset.object(all.games.temp, team$teamId, "visitingTeamId"))
  ## Order the games.temp.teams by gameId
  all.games.temp.teams <- all.games.temp.teams[order(all.games.temp.teams[, "gameId"]),]

  for(game.type.number in uuln(all.games.temp.teams[,"gameType"])){
    ## pull gameIds from all.games.temp.teams
    game.ids <- uuln(subset.object(all.games.temp.teams, game.type.number, "gameType")[,"gameId"])

    ## create class for the games.played slot in SLAP
    create.game.class(season, team$triCode, game.types[game.type.number], game.ids)
    ## create object for the games.played slot in SLAP
    games.in.game.type <- new(paste(season, paste(team$triCode, collapse="."), game.types[game.type.number], sep="."))
    ## store object in the slot
    slot(slot(SLAP, game.types[game.type.number]), "games.played") <- games.in.game.type
  }

  # populate object with data
  slot(slot(SLAP, "general.league.information"), "teams.in.league") <- all.teams.temp
  slot(slot(SLAP, "general.league.information"), "players.in.league") <- all.players.temp
  slot(slot(SLAP, "general.league.information"), "games.played") <- all.games.temp


  for(game.type.number in uuln(all.games.temp.teams[,"gameType"])){
    if(game.type.number!=1){
      slot(slot(SLAP, game.types[game.type.number]), "players.by.game.type") <- api.players.by.game.type(season, team$triCode, game.type.number)
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
    # for(game.id.number in 1:length(game.ids)){
    #   plays.by.game <- content.from.endpoint(paste("https://api-web.nhle.com/v1/gamecenter", as.character(game.ids[game.id.number]), "play-by-play", sep="/"))$plays
    #   if(is.null(plays.by.game)){
    #     next()
    #   } # added trying to fix
    #   #go to next game.id.number
    #   plays.by.game[, "eventId"] <- paste0(game.ids[game.id.number], plays.by.game[, "eventId"])
    #   plays.by.game <- flatten(plays.by.game)
    #   slot(slot(slot(slot(SLAP, game.types[game.type.number]), "games.played"), as.character(game.ids[game.id.number])), "plays.by.game") <- plays.by.game
    # }
  }

  # order teams by input
  ## if there are more than one team this needs to be ordered
  # <- lapply(teams, teamName.teamId.triCode(teams)$triCode
  teams.in.league <- SLAP@general.league.information@teams.in.league
  in.pos <- which(teams.in.league[,"triCode"] %in% team$triCode)
  other.pos <- which(!(teams.in.league[,"triCode"] %in% team$triCode))
  teams.in.league <- teams.in.league[c(in.pos, other.pos),]
  SLAP@general.league.information@teams.in.league <- teams.in.league

  return(SLAP)
}
