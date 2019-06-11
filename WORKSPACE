workspace(name = "kubevirt_website")

git_repository(
    name = "io_bazel_rules_docker",
    commit = "8aeab63328a82fdb8e8eb12f677a4e5ce6b183b1",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

## Load container rules and repositories
load(
    "@io_bazel_rules_docker//container:container.bzl",
    "repositories",
    "container_pull",
)
repositories()

## Load Library to test over a built image
load(
    "@io_bazel_rules_docker//contrib:test.bzl",
    "container_test",
)

container_pull(
    name = "jekyll",
    registry = "docker.io",
    repository = "jekyll/jekyll",
    tag = "latest",
)
