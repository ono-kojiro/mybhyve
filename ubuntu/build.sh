#!/bin/sh

top_dir="$(cd "$(dirname "$0")" > /dev/null 2>&1 && pwd)"
cd $top_dir

iso_path="$HOME/Downloads/ubuntu-24.04-live-server-amd64.iso"
iso=`basename $iso_path`

name="ubuntu"
template="${name}"

all()
{
  help
}

help()
{
  cat - << EOF
usage : $0 target1 target2 ...

    target
      create
      install
EOF
}

create()
{
  if [ ! -e "/vm/.iso/$iso" ]; then
    sudo vm iso $iso_path
  fi

  cat - << EOF > _tmp.conf
loader="uefi"
cpu="2"
memory="1024m"
network0_type="virtio-net"
network0_switch="sw0"
#network1_type="virtio-net"
#network1_switch="pcap"
#network1_span="yes"
disk0_type="virtio-blk"
disk0_name="disk0.img"
EOF

  sudo cp -f _tmp.conf /vm/.templates/${template}.conf
  sudo vm create -t ${template} -s 128g -m 1024m -c 2 ${name}
}

install()
{
  sudo vm install -f ${name} ${iso}
}

console()
{
  sudo vm console ${name}
}

destroy()
{
  sudo vm destroy ${name}
}

if [ $# -eq 0 ]; then
  all
fi

for target in "$@"; do
  LANG=C type "$target" 2>&1 | grep 'function' > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    $target
  else
    default $target
  fi
done


