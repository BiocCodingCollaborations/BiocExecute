test_that("skeletonCli creates exec/ and exec/scripts/ directories", {
    pkg_dir <- withr::local_tempdir()
    writeLines(c("Package: TestPkg"), file.path(pkg_dir, "DESCRIPTION"))

    skeletonCli(pkg_dir)

    expect_true(dir.exists(file.path(pkg_dir, "exec")))
    expect_true(dir.exists(file.path(pkg_dir, "exec", "scripts")))
})

test_that("skeletonCli creates the entry-point script named after the package", {
    pkg_dir <- withr::local_tempdir()
    writeLines(c("Package: TestPkg"), file.path(pkg_dir, "DESCRIPTION"))

    result <- skeletonCli(pkg_dir)

    expect_true(file.exists(result))
    expect_equal(basename(result), "TestPkg.R")
    expect_equal(dirname(result), file.path(pkg_dir, "exec"))
})
