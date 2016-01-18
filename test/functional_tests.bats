load functions

@test "hooktftp binary is owned by root:root" {
  uidgid=$(docker run --rm --entrypoint /bin/sh hooktftp-runtime -c "stat -c %u:%g /usr/bin/hooktftp" | tr -d '=r')
  test '0:0' = "$uidgid"
}

@test "hooktftp drops privileges" {
  run docker logs tftpd
  [[ ${output} =~ 'Dropped privileges' ]]
}

@test "downloads site/menu from fixtures" {
  tftp_get $ip site/menu
  run docker run --rm --volumes-from downloads alpine:3.3 test -r /home/user/menu
  [ ${status} -eq 0 ]
}

@test "downloads pxelinux.0" {
  tftp_get $ip pxelinux.0
  run docker run --rm --volumes-from downloads alpine:3.3 test -s /home/user/pxelinux.0
  [ ${status} -eq 0 ]
}

@test "does not download a non-existent-file" {
  tftp_get $ip non-existent-file
  run docker run --rm --volumes-from downloads alpine:3.3 test -s /home/user/non-existent-file
  [ ${status} -ne 0 ]
}

@test "downloads pxelinux.cfg/default" {
  tftp_get $ip pxelinux.cfg/default
  run docker run --rm --volumes-from downloads alpine:3.3 test -s /home/user/default
  [ ${status} -eq 0 ]
}

@test "downloads pxelinux.cfg/F1.msg" {
  tftp_get $ip pxelinux.cfg/F1.msg
  run docker run --rm --volumes-from downloads alpine:3.3 test -s /home/user/F1.msg
  [ ${status} -eq 0 ]
}

@test "hooktftp server log is meaningful" {
  run docker logs tftpd
  [[ ${output} =~ 'Reading hooks' ]]
  [[ ${output} =~ 'GET site/menu' ]]
}
