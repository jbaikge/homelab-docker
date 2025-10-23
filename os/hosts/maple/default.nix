{
  imports = [
    ../common
  ];

  networking = {
    hostName = "maple";
    interfaces.enp0s2f0.ipv4.addresses = [
      {
        address = "10.100.6.53";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f1.ipv4.addresses = [
      {
        address = "10.100.10.54";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f2.ipv4.addresses = [
      {
        address = "192.168.1.55";
        prefixLength = 24;
      }
    ];
  };
}
