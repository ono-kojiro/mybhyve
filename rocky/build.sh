#!/bin/sh

top_dir="$(cd "$(dirname "$0")" > /dev/null 2>&1 && pwd)"
cd $top_dir

template="rocky"
name="rocky"
iso_path="$HOME/Downloads/Rocky-9.4-x86_64-minimal.iso"
iso=`basename $iso_path`

all()
{
  help
}

help()
{
  cat - << EOF
usage : $0 target1 target2 ...

    target
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
cpu=2
memory=1024M
network0_type="virtio-net"
network0_switch="sw0"
disk0_type="virtio-blk"
disk0_name="disk0.img"
EOF


  sudo cp -f _tmp.conf /vm/.templates/${template}.conf
  sudo vm create -t ${template} -s 128g -m 1024m -c 2 ${name}

  cat - << EOF
INFO: In grub menu, type 'e' and add following kernel options

  console=ttyS0,115200n8
EOF

}

install()
{
  sudo vm install -f ${name} ${iso}
}

console()
{
  sudo vm console ${name}
}

start()
{
  sudo vm start ${name}
}

list()
{
  sudo vm list
}

stop()
{
  sudo vm stop ${name}
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

