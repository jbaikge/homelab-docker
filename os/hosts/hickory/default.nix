{
  imports = [
    ../common
  ];

  # diskio.devices.disk.disk1.device = "/dev/disk/by-id/ata-WDC_WDS100T2B0A-00SM50_205010A00786";

  networking = {
    hostName = "hickory";
    interfaces.enp0s2f0.ipv4.addresses = [
      {
        address = "10.100.6.56";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f1.ipv4.addresses = [
      {
        address = "10.100.10.57";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s2f2.ipv4.addresses = [
      {
        address = "192.168.1.58";
        prefixLength = 24;
      }
    ];
  };
}
