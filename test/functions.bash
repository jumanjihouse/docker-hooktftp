# shellcheck shell=bash

. ci/vars

tftp_get() {
  host=$1
  file=$2
  docker-compose run --rm tftp "${host}" -c get "${file}"
}
