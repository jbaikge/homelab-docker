{
  imports = [
    ../common
  ];

  networking = {
    hostName = "cherry";
    interfaces.enp0s2f0.ipv4.addresses = [
      {
        address = "10.100.6.48";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f1.ipv4.addresses = [
      {
        address = "10.100.10.49";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f2.ipv4.addresses = [
      {
        address = "192.168.1.50";
        prefixLength = 24;
      }
    ];
  };
}
