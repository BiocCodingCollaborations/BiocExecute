test_that("skeletonCli creates exec/ and exec/scripts/ directories", {
    pkg_dir <- withr::local_tempdir()

    execSkeleton(pkg_dir)

    expect_true(dir.exists(file.path(pkg_dir, "exec")))
    expect_true(dir.exists(file.path(pkg_dir, "exec", "scripts")))
    expect_true(file.exists(file.path(pkg_dir, "exec/scripts/base_template.R")))
})
