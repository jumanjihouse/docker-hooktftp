# shellcheck shell=bash
docker_rm() {
  cid=$1
  docker rm -f "${cid}" &>/dev/null || :
}

tftp_get() {
  host=$1
  file=$2
  docker run --rm --volumes-from downloads tftp "${host}" -c get "${file}"
}
