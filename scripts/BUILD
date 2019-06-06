# Execute Rake command

#genrule(
#    name = "gen_website_test_script",
#    cmd = "echo '#!/bin/bash\nrake' | tee $(location tests.sh); chmod 755 tests.sh",
#    local = True,
#    outs = ["$(location tests.sh)"]
#)
sh_binary(
    name = "rake_tests",
    srcs = ["tests.sh"]
)
