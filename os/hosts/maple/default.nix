{
  imports = [
    ../common
  ];

  networking = {
    hostName = "maple";
    interfaces.enp0s2f0.ipv4.addresses = [
      {
        address = "10.100.6.64";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f1.ipv4.addresses = [
      {
        address = "10.100.10.65";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f2.ipv4.addresses = [
      {
        address = "192.168.1.66";
        prefixLength = 24;
      }
    ];
  };
}
