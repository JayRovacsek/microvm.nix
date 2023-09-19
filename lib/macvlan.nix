{ config, lib, }:
let
  interfaceFdOffset = 3;

  macvlanInterfaces =
    lib.imap0 (i: interface: interface // { fd = interfaceFdOffset + i; })
    (builtins.filter ({ type, ... }: type == "macvlan") config.interfaces);
in {
  openMacvlanFds = lib.concatMapStrings ({ id, fd, ... }: ''
    exec ${toString fd}<>/dev/tap$(< /sys/class/net/${id}/ifindex)
  '') macvlanInterfaces;

  macvlanFds =
    builtins.foldl' (result: { id, fd, ... }: result // { ${id} = fd; }) {
      nextFreeFd = interfaceFdOffset + builtins.length macvlanInterfaces;
    } macvlanInterfaces;
}
