# S4 object framework

# Create class for general league information containing teams.in.league, players.in.league, and games.played in season
#' general.league.information
#'
#' @slot teams.in.league ANY.
#' @slot players.in.league ANY.
#' @slot games.played ANY.
#'
#' @exportClass general.league.information
setClass("general.league.information",
         slots=c(
           teams.in.league="ANY",
           players.in.league="ANY",
           games.played="ANY"
         ))

# do.call example (https://stackoverflow.com/questions/76483080/create-s4-slots-dynamically)

# Create class game.id.object that will be used to store information for each game independantly and will be embded the corresponding season type (pre.season, regular.season, or playoffs). The class contains game.stats, player.stats.by.game, and plays.by.game

#' game.id.object
#'
#' @slot game.stats ANY.
#' @slot player.stats.by.game ANY.
#' @slot plays.by.game ANY.
#'
#' @exportClass game.id.object
setClass("game.id.object",
         slots=c(
           id="character",
           game.stats="ANY",
           player.stats.by.game="ANY",
           plays.by.game="ANY"
         ))

# Create a class for every season type

#' pre.season class
#'
#' @slot games.played ANY.
#'
#' @exportClass pre.season
setClass("pre.season", slots=c(games.played="ANY"))

#' regular.season class
#'
#' @slot players.by.game.type ANY.
#' @slot games.played ANY.
#'
#' @exportClass regular.season
setClass("regular.season", slots=c(players.by.game.type="ANY", games.played="ANY"))

#' playoffs class
#'
#' @slot players.by.game.type ANY.
#' @slot games.played ANY.
#'
#' @exportClass playoffs
setClass("playoffs", slots=c(players.by.game.type="ANY", games.played="ANY"))



# game.types <- c("pre.season", "regular.season", "playoffs")
# for(game.type.number in 1:3){
#   if(game.type.number==1){
#     setClass(game.types[game.type.number],
#              slots=c(games.played="ANY")
#     )
#   }else{
#     setClass(game.types[game.type.number],
#              slots=c(players.by.game.type="ANY", games.played="ANY")
#     )
#   }
# }
# rm("game.types", "game.type.number")

# Create a class that assembles all other classes into a usable object
#' @export
setClass("SLAP",
         slots=c(
           general.league.information="general.league.information",
           pre.season="pre.season",
           regular.season="regular.season",
           playoffs="playoffs"
         ))



#' @importFrom stats setNames
create.game.class <- function(season, teams, season.type, game.ids){
  setClass(paste(season, paste(teams, collapse="."), season.type, sep="."),
           slots=c(
             setNames(rep("game.id.object", length(game.ids)), game.ids)
           ))
}


#
# # save s4 object with list of create.game.class() calls
#
# library(methods)
#
# bundle_save <- function(obj, class_code, path, extras = list()) {
#   # class_code: character vector like deparse(your_setClass_call)
#   saveRDS(list(class_code = class_code,
#                class_name = class(obj),
#                object = obj,
#                extras = extras), path)
# }
#
# bundle_load <- function(path, envir = .GlobalEnv) {
#   z <- readRDS(path)
#   if (!isClass(z$class_name)) {
#     eval(parse(text = z$class_code), envir = envir)  # defines class/methods
#   }
#   z$object
# }
#
# ## Example: build class from user variables
# user_slots <- c(data = "list", user = "character")
# user_validity <- function(object) {
#   if (length(object@user) != 1L) "user must be length 1" else TRUE
# }
#
# # Turn the dynamic definition into code strings:
# def_code <- paste(
#   "setClass('UserClass',",
#   sprintf("slots = %s,", deparse(user_slots)),
#   sprintf("validity = %s)", deparse(user_validity))
# )
#
# # Create object under that class
# eval(parse(text = def_code))
# obj <- new("UserClass", data = list(), user = "Bailey")
#
# # Save (with the recipe)
# bundle_save(obj, def_code, "userclass_bundle.rds")
#
# # Later (fresh session):
# x <- bundle_load("userclass_bundle.rds")
