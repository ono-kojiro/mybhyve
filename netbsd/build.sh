#!/bin/sh

top_dir="$(cd "$(dirname "$0")" > /dev/null 2>&1 && pwd)"
cd $top_dir

template="netbsd"
name="netbsd"
iso="NetBSD-10.0-amd64.iso"

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
    sudo vm iso $HOME/Downloads/$iso
  fi

  cat - << EOF > _tmp.conf
loader="grub"
cpu=2
memory=128M
network0_type="virtio-net"
network0_switch="sw0"
disk0_type="virtio-blk"
disk0_name="netbsd.img"
grub_install0="knetbsd -h -r cd0a /netbsd"
grub_run0="knetbsd -h -r dk0 /netbsd"
EOF

  sudo cp -f _tmp.conf /vm/.templates/${template}.conf
  cmd="sudo vm create -t ${template} -s 16g -m 128m -c 2 ${name}"
  echo $cmd
  $cmd
}

install()
{
  sudo vm install -f ${name} ${iso}
}

console()
{
  sudo vm console ${name}
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

