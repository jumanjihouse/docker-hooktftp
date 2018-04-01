setup() {
  docker rm -fv runtime &> /dev/null || :
  docker run --name=runtime hooktftp-runtime -h 2>&1 | grep Usage
  docker cp runtime:/usr/bin/hooktftp /tmp/
}

@test "file command is available" {
  run command -v file
  [[ $status -eq 0 ]]
}

@test "scanelf command is available" {
  run command -v scanelf
  [[ $status -eq 0 ]]
}

@test "hooktftp binary is stripped" {
  run file /tmp/hooktftp
  [[ $output =~ stripped ]]
  [[ ! $output =~ 'not stripped' ]]
}

@test "hooktftp binary is statically compiled" {
  run scanelf -BF '%o#F' /tmp/hooktftp
  [[ $output =~ ET_EXEC ]]

  run file /tmp/hooktftp
  [[ $output =~ statically ]]
}
