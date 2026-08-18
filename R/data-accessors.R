.flowsorted_dlpfc_cache <- function() {
    BiocFileCache::BiocFileCache(tools::R_user_dir("FlowSorted.DLPFC.450k", "cache"), ask = FALSE)
}

.flowsorted_dlpfc_load <- function(rname, url, md5, object_name) {
    bfc <- .flowsorted_dlpfc_cache()
    path <- BiocFileCache::bfcrpath(bfc, rnames = rname, fpath = url)
    actual_md5 <- unname(tools::md5sum(path))
    if (!identical(actual_md5, md5)) {
        BiocFileCache::bfcremove(bfc, BiocFileCache::bfcquery(bfc, rname, "rname")$rid)
        stop(
            "Downloaded file for '", rname, "' failed its checksum check ",
            "(expected ", md5, ", got ", actual_md5, "). The cached copy was ",
            "removed; please call this function again to retry the download."
        )
    }
    e <- new.env()
    load(path, envir = e)
    get(object_name, envir = e)
}

# Sets up FlowSorted.DLPFC.450k as an active binding in the package
# namespace: referencing the bare name (as with the historical
# lazy-loaded data() object) downloads (once; cached locally afterwards
# via BiocFileCache) and returns the object. This preserves the
# get(pkgname)-style access used by minfi::estimateCellCounts() and
# other downstream consumers.
.onLoad <- function(libname, pkgname) {
    ns <- asNamespace(pkgname)

    .install_lazy_binding <- function(sym, loader) {
        cached <- NULL
        makeActiveBinding(sym, function() {
            if (is.null(cached)) cached <<- loader()
            cached
        }, ns)
    }

    .install_lazy_binding("FlowSorted.DLPFC.450k", function() {
        .flowsorted_dlpfc_load(
            rname = "FlowSorted.DLPFC.450k.rda",
            url = "https://zenodo.org/records/21998570/files/FlowSorted.DLPFC.450k.rda?download=1",
            md5 = "eb0b6fa70fcdc7f39b2cacea39bc69df",
            object_name = "FlowSorted.DLPFC.450k"
        )
    })
}
