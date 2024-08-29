#!/bin/sh

top_dir="$(cd "$(dirname "$0")" > /dev/null 2>&1 && pwd)"
cd $top_dir

template="kali"
name="kali"
iso_path="$HOME/Downloads/kali-linux-2024.2-installer-amd64.iso"
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
      create
      install
EOF
}

upload()
{
  if [ ! -e "/vm/.iso/$iso" ]; then
    sudo vm iso $iso_path
  fi
}

create()
{
  upload

  cat - << EOF > _tmp.conf
loader="uefi"
uefi_var="yes"
cpu=2
memory="2048m"
network0_type="virtio-net"
network0_switch="sw0"
disk0_type="ahci-hd"
disk0_name="disk0.img"
EOF

  sudo cp -f _tmp.conf /vm/.templates/${template}.conf
  rm -f _tmp.conf

  sudo vm create -t ${template} -s 128g ${name}
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


