
group_nest_impl <- function(.tbl, .key, keep = FALSE){
  mutate(group_keys(.tbl), !!.key := group_split_impl(.tbl, isTRUE(keep), environment(), TRUE))
}

#' Nest a tibble using a grouping specification
#'
#' ```
#' \Sexpr[results=rd, stage=render]{mypkg:::lifecycle("experimental")}
#' ```
#'
#' @family grouping functions
#'
#' @description
#'
#' Nest a tibble using a grouping specification
#'
#' @param .tbl A tbl
#' @param ... Grouping specification, forwarded to [group_by()]
#' @param .key the name of the list column
#' @param keep Should the grouping columns be kept in the list column.
#'
#' @details
#'
#' @section Grouped data frames:
#'
#' The primary use case for [group_nest()] is with already grouped data frames,
#' typically a result of [group_by()]. In this case [group_nest()] only uses
#' the first argument, the grouped tibble, and warns when `...` is used.
#'
#' @section Ungrouped data frames:
#'
#' When used on ungrouped data frames, [group_nest()] forwards the `...` to
#' [group_by()] before nesting, therefore the `...` are subject to the data mask.
#'
#' @return A tbl with one row per unique combination of the grouping variables.
#' The first columns are the grouping variables, followed by a list column of tibbles
#' with matching rows of the remaining columns.
#'
#' @keywords internal
#' @examples
#'
#' #----- use case 1: a grouped data frame
#' iris %>%
#'   group_by(Species) %>%
#'   group_nest()
#'
#' # this can be useful if the grouped data has been altered before nesting
#' iris %>%
#'   group_by(Species) %>%
#'   filter(Sepal.Length > mean(Sepal.Length)) %>%
#'   group_nest()
#'
#' #----- use case 2: using group_nest() on a ungrouped data frame with
#' #                  a grouoping specification that uses the data mask
#' starwars %>%
#'   group_nest(species, homeworld)
#'
#'
#' @export
group_nest <- function(.tbl, ..., .key = "data", keep = FALSE){
  UseMethod("group_nest")
}

#' @export
group_nest.data.frame <- function(.tbl, ..., .key = "data", keep = FALSE) {
  if (dots_n(...)) {
    group_nest_impl(group_by(.tbl, ...), .key = .key, keep = keep)
  } else {
    tibble(!!.key := list(.tbl))
  }
}

#' @export
group_nest.grouped_df <- function(.tbl, ..., .key = "data", keep = FALSE) {
  if (dots_n(...)) {
    warn("... is ignored in group_nest(<grouped_df>), please use group_by(..., add = TRUE) %>% group_nest()")
  }
  group_nest_impl(.tbl, .key = .key, keep = keep)
}
