#!/bin/sh
# CI build script
case $1 in
        "init")
                if [ "$IS_ACTIONS" = "y" ]; then
                        ln -s "$GITHUB_WORKSPACE" /work
                fi
                mkdir /out
                ln -s /out /work/out
                cd /work || exit 1
                #echo "https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main/" > /etc/apk/repositories
                #echo "https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community/" >> /etc/apk/repositories
                #echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
                #apk update
                #apk add build-base llvm-libunwind-dev compiler-rt libc++-dev alpine-sdk nimble shadow libarchive-tools perl zlib-dev llvm clang linux-headers openssl-dev binutils-dev gettext-dev xz libgcc gcc
                make deps
                make kpkg
                #./out/kpkg update || true
                #sed s/gcc/musl-gcc/g -i /etc/kpkg/kpkg.conf
                nim c -d:branch=master --threads:on -d:ssl -o=src/kreastrap/kreastrap src/kreastrap/kreastrap.nim
                #make kreastrap
        ;;

        "build")
                git config --global --add safe.directory /etc/kpkg/repos/main
                rm -rf /out/*
                cd /work || exit 1
                ./src/kreastrap/kreastrap rootfs --buildType="$2" --arch=amd64 || exit 1
                cd /out || exit 1
                tar -czvf /work/kreato-linux-"$2"-glibc-"$(date +%d-%m-%Y)"-amd64.tar.gz *
        ;;
esac
