test_that("skeletonCli creates exec/ and exec/scripts/ directories", {
    pkgPath <- withr::local_tempdir()

    writeLines(
        c(
            "Package: ExamplePackage",
            "Title: Example package",
            "Description: Package used to test executable compilation."
        ),
        file.path(pkgPath, "DESCRIPTION")
    )

    execSkeleton(pkgPath)

    expect_true(dir.exists(file.path(pkgPath, "exec")))
    expect_true(dir.exists(file.path(pkgPath, "exec", "scripts")))
    expect_true(file.exists(file.path(pkgPath, "exec/scripts/base_template.R")))
})
