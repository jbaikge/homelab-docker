{
  imports = [
    ../common
  ];

  # diskio.devices.disk.disk1.device = "/dev/disk/by-id/ata-WDC_WDS100T2B0A-00SM50_205006A008AC";

  networking = {
    hostName = "ash";
    interfaces.enp0s20f0.ipv4.addresses = [
      {
        address = "10.100.6.40";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s20f1.ipv4.addresses = [
      {
        address = "10.100.10.41";
        prefixLength = 24;
      }
    ];
    interfaces.enp0s20f2.ipv4.addresses = [
      {
        address = "192.168.1.42";
        prefixLength = 24;
      }
    ];
  };
}
