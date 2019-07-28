load functions

@test "hooktftp drops privileges" {
  run docker-compose logs tftpd
  [[ ${output} =~ 'Dropped privileges' ]]

  cid=$(docker-compose ps -q tftpd)
  docker run --rm -it --pid container:${cid} --network container:${cid} "${BASE_IMAGE}" ps -o pid,user,group,comm |
  grep -E '1 1000     1000     hooktftp'
}

@test "downloads site/menu from fixtures" {
  tftp_get tftpd site/menu
  run docker-compose run --rm test -r /home/user/menu
  [ ${status} -eq 0 ]
}

@test "downloads pxelinux.0" {
  tftp_get tftpd pxelinux.0
  run docker-compose run --rm test -s /home/user/pxelinux.0
  [ ${status} -eq 0 ]
}

@test "does not download a non-existent-file" {
  tftp_get tftpd non-existent-file
  run docker-compose run --rm test -s /home/user/non-existent-file
  [ ${status} -ne 0 ]
}

@test "downloads pxelinux.cfg/default" {
  tftp_get tftpd pxelinux.cfg/default
  run docker-compose run --rm test -s /home/user/default
  [ ${status} -eq 0 ]
}

@test "downloads pxelinux.cfg/F1.msg" {
  tftp_get tftpd pxelinux.cfg/F1.msg
  run docker-compose run --rm test -s /home/user/F1.msg
  [ ${status} -eq 0 ]
}

@test "downloads a file from a host in /etc/hosts" {
  tftp_get internal.example.com memdisk
  run docker-compose run --rm test -s /home/user/memdisk
  [ ${status} -eq 0 ]
}

@test "hooktftp server log is meaningful" {
  run docker-compose logs tftpd
  [[ ${output} =~ 'Reading hooks' ]]
  [[ ${output} =~ 'GET site/menu' ]]
}
