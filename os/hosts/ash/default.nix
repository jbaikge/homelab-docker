{
  imports = [
    ../common
  ];

  networking = {
    hostName = "ash";
    interfaces.enp0s2f0.ipv4.addresses = [
      {
        address = "10.100.6.38";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f1.ipv4.addresses = [
      {
        address = "10.100.10.39";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f2.ipv4.addresses = [
      {
        address = "192.168.1.40";
        prefixLength = 24;
      }
    ];
  };
}
