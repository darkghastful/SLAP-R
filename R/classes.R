# S4 object framework

# Create class for general league information containing teams.in.league, players.in.league, and games in season
#' league
#'
#' @slot teams `data.frame` Teams that played during specified season.
#' @slot players data.frame; players
#' @slot all.games data.frame; games
#'
#' @exportClass league
setClass("league",
         slots=c(
           teams="data.frame",
           players="data.frame",
           all.games="data.frame"
         ))


# Create a class for every season type

#' preseason class
#'
#' @slot game.stats data.frame; game stats
#' @slot games list; games
#'
#' @exportClass preseason
setClass("preseason", slots=c(game.stats="data.frame", games="list"))

#' regular.season class
#'
#' @slot player.stats data.frame; player stats
#' @slot game.stats data.frame; game stats
#' @slot games list; games
#'
#' @exportClass regular.season
setClass("regular.season", slots=c(player.stats="data.frame", game.stats="data.frame", games="list"))

#' playoffs class
#'
#' @slot player.stats data.frame; player stats
#' @slot game.stats data.frame; game stats
#' @slot games list; games
#'
#' @exportClass playoffs
setClass("playoffs", slots=c(player.stats="data.frame", game.stats="data.frame", games="list"))


#' SLAP
#'
#' @slot league S4; league object
#' @slot preseason S4; preseason object
#' @slot regular.season S4; regular.season object
#' @slot playoffs S4; playoffs object
#'
#' @exportClass SLAP
setClass("SLAP",
         slots=c(
           league="league",
           preseason="preseason",
           regular.season="regular.season",
           playoffs="playoffs"
         ))


