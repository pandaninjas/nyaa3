proc upgrade(root = "/",
        builddir = "/tmp/kpkg/build", srcdir = "/tmp/kpkg/srcdir"): string =
    ## Upgrade packages
    var repo: string
    for i in walkDir("/var/cache/kpkg/installed"):
        if i.kind == pcDir:
            var localPkg: runFile
            try:
                localPkg = parse_runfile(i.path)
            except CatchableError:
                raise

            if localPkg.pkg in getConfigValue("Upgrade", "dontUpgrade").split(" "):
                echo "skipping "&localPkg.pkg&": selected to not upgrade in kpkg.conf"
                continue

            when declared(localPkg.epoch):
                let epoch_local = epoch

            repo = findPkgRepo(lastPathPart(i.path))
            if isEmptyOrWhitespace(repo):
                echo "skipping "&localPkg.pkg&": not found in available repositories"
                continue

            var upstreamPkg: runFile
            try:
                upstreamPkg = parse_runfile(repo&"/"&lastPathpart(i.path))
            except CatchableError:
                raise

            if localPkg.version < upstreamPkg.version or localPkg.release <
              upstreamPkg.release or (localPkg.epoch != "no" and
                      localPkg.epoch < upstreamPkg.epoch):

                echo "Upgrading "&localPkg.pkg&" from "&localPkg.versionString&" to "&upstreamPkg.versionString

                if getConfigValue("Upgrade", "buildByDefault") == "yes":
                    discard builder(localPkg.pkg, root, dontInstall = true)
                else:
                    discard install(@[localPkg.pkg], root, true,
                            downloadOnly = true)

                discard removeInternal(localPkg.pkg, root)
                discard install(@[localPkg.pkg], root, true, offline = true)

    return "kpkg: done"
