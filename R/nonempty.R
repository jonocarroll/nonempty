#' Validate a nonempty data structure
#'
#' @export
check_nonempty <- function(object) {
  errors <- character()

  # can not be NULL
  if (is.null(object)) {
    msg <- "data cannot be NULL"
    errors <- c(errors, msg)
  }

  # must have non-zero length
  if (length(object) == 0) {
    msg <- "data length is 0, needs to be > 0"
    errors <- c(errors, msg)
  }

  # if character, must have at least 1 non-empty string
  if (is.character(object)) {
    if (all(nzchar(unique(object)) == 0))  {
      msg <- "data has no characters, needs to have > 0"
      errors <- c(errors, msg)
    }
  }

  if (length(errors) == 0) {
    TRUE
  } else {
    errors
  }
}

#' A non-empty data structure
#'
#' @export
setClass("nonempty",
         contains = "ANY",
         validity = check_nonempty)

#' Create a new nonempty data structure
#'
#' @param x non-empty structure
#'
#' @return an object of class `nonempty`
#' @export
nonempty <- function(x) {
  new("nonempty", x)
}

#' Print a nonempty object
#'
#' @export
setMethod("show", "nonempty", function(object)
  show(object@.Data))

#' Combine nonempty with nonempty via Ops
#'
#' @export
setMethod("Ops", signature(e1 = "nonempty", e2 = "nonempty"),
          function(e1, e2) {
            e1@.Data = callGeneric(e1@.Data, e2@.Data)
            validObject(e1)
            e1
          })

#' Combine nonempty with ANY via Ops
#'
#' @export
setMethod("Ops", signature(e1 = "nonempty", e2 = "ANY"),
          function(e1, e2) {
            e1@.Data = callGeneric(e1@.Data, e2)
            validObject(e1)
            e1
          })

#' Combine ANY with nonempty via Ops
#'
#' @export
setMethod("Ops", signature(e1 = "ANY", e2 = "nonempty"),
          function(e1, e2) {
            e2@.Data = callGeneric(e1, e2@.Data)
            validObject(e2)
            e2
          })

#' Extract from nonempty
#'
#' @export
setMethod("[", signature(x = "nonempty", i = "ANY", j = "ANY", drop = "ANY"),
          function(x, i, j, ..., drop = TRUE) {
            if (missing(j)) {
              res <- callGeneric(x@.Data, i, ...)
            } else {
              res <- callGeneric(x@.Data, i, j)
            }
            nonempty(res)
          })

#' Replace part of non-empty
#'
#' @export
setReplaceMethod("[", signature(x = "nonempty", i = "ANY", j = "ANY", value = "ANY"),
                 function(x, i, j, value) {
                   if (missing(j)) {
                     res <- callGeneric(x@.Data, i, value)
                   } else {
                     res <- callGeneric(x@.Data, i, j, value)
                   }
                   nonempty(res)
                 })

#' Extract substring from nonempty
#'
#' @export
setMethod("substr", signature(x = "nonempty", start = "numeric", stop = "numeric"),
          function(x, start, stop) {
            res <- callGeneric(x@.Data, start, stop)
            nonempty(res)
          })

#' Combine nonempty with c()
#'
#' @export
setMethod("c", signature= "nonempty",
          function(x, ..., recursive = FALSE) {
            elements <- list(x, ...)
            insides <- lapply(elements, \(y) y@.Data)
            nonempty(do.call("c", insides))
          })
