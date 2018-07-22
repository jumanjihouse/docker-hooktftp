load functions

@test "hooktftp drops privileges" {
  run docker logs tftpd
  [[ ${output} =~ 'Dropped privileges' ]]

  docker run --rm -it --pid container:tftpd --network container:tftpd "${BASE_IMAGE}" ps -o pid,user,group,comm |
  grep -E '1 1000     1000     hooktftp'
}

@test "downloads site/menu from fixtures" {
  tftp_get $ip site/menu
  run docker run --rm --volumes-from downloads "${BASE_IMAGE}" test -r /home/user/menu
  [ ${status} -eq 0 ]
}

@test "downloads pxelinux.0" {
  tftp_get $ip pxelinux.0
  run docker run --rm --volumes-from downloads "${BASE_IMAGE}" test -s /home/user/pxelinux.0
  [ ${status} -eq 0 ]
}

@test "does not download a non-existent-file" {
  tftp_get $ip non-existent-file
  run docker run --rm --volumes-from downloads "${BASE_IMAGE}" test -s /home/user/non-existent-file
  [ ${status} -ne 0 ]
}

@test "downloads pxelinux.cfg/default" {
  tftp_get $ip pxelinux.cfg/default
  run docker run --rm --volumes-from downloads "${BASE_IMAGE}" test -s /home/user/default
  [ ${status} -eq 0 ]
}

@test "downloads pxelinux.cfg/F1.msg" {
  tftp_get $ip pxelinux.cfg/F1.msg
  run docker run --rm --volumes-from downloads "${BASE_IMAGE}" test -s /home/user/F1.msg
  [ ${status} -eq 0 ]
}

@test "hooktftp server log is meaningful" {
  run docker logs tftpd
  [[ ${output} =~ 'Reading hooks' ]]
  [[ ${output} =~ 'GET site/menu' ]]
}
