@test "HOOKTFTP_VERSION is a symlink at top-level" {
  [ -L HOOKTFTP_VERSION ]
}

@test "HOOKTFTP_VERSION is a regular file in build direcctory" {
  [ -f src/alpine/builder/HOOKTFTP_VERSION ]
}
