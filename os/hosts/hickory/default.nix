{
  imports = [
    ../common
  ];

  networking = {
    hostName = "hickory";
    interfaces.enp0s2f0.ipv4.addresses = [
      {
        address = "10.100.6.46";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f1.ipv4.addresses = [
      {
        address = "10.100.10.47";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f2.ipv4.addresses = [
      {
        address = "192.168.1.48";
        prefixLength = 24;
      }
    ];
  };
}
