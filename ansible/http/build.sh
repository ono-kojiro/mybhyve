#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

help()
{
  usage
}

usage()
{
  cat << EOS
usage : $0 [options] target1 target2 ...

  target:
    http
EOS

}

hosts()
{
  ansible-inventory -i template.yml --list --yaml > hosts.yml
}

all()
{
  ansible-playbook -K -i hosts.yml -t all site.yml
}

deploy()
{
  ansible-playbook -K -i hosts.yml -t dns site.yml
}

default()
{
  tag=$1
  ansible-playbook -K -i hosts.yml -t $tag site.yml
}

hosts

args=""
while [ $# -ne 0 ]; do
  case $1 in
    -h )
      usage
      exit 1
      ;;
    -v )
      verbose=1
      ;;
    * )
      args="$args $1"
      ;;
  esac
  
  shift
done

if [ -z "$args" ]; then
  all
  exit 1
fi

for arg in $args; do
  num=`LANG=C type $arg 2>&1 | grep 'function' | wc -l`
  if [ $num -ne 0 ]; then
    $arg
  else
    #echo "ERROR : $arg is not shell function"
    #exit 1
    default $arg
  fi
done

