rec {
  kernelPackages = {
    version,
    src,
    rpiVersion,
    callPackage ? callPackage,
    ...
  } @ args:
    callPackage ./kernel.nix args;

  firmwarePackage = {
    version,
    src,
    raspberrypifw ? raspberrypifw,
    ...
  }:
    raspberrypifw.overrideAttrs (prev: {
      inherit version src;
    });

  wirelessFirmwarePackage = {
    version,
    srcs,
    raspberrypiWirelessFirmware ? raspberrypiWirelessFirmware,
    ...
  }:
    raspberrypiWirelessFirmware.overrideAttrs (prev: {
      inherit version srcs;
    });

  getFirmwares = versions': pkgs: let
    versions = pkgs.callPackage versions' {};

    inherit (versions) bluez firmware-nonfree firmware;
  in {
    raspberrypiWirelessFirmware = wirelessFirmwarePackage {
      srcs = [bluez firmware-nonfree];
      version = "${bluez.rev}-${firmware-nonfree.rev}";

      inherit (pkgs) raspberrypiWirelessFirmware;
    };

    raspberrypifw = firmwarePackage {
      src = firmware;
      version = firmware.rev;

      inherit (pkgs) raspberrypifw;
    };
  };

  getKernels = versions': pkgs: let
    versions = pkgs.callPackage versions' {};

    inherit (versions) version kernel;

    rpiKernel = rpiVersion:
      kernelPackages {
        inherit rpiVersion version;
        inherit (pkgs) callPackage;

        src = kernel;
      };
  in {
    # linux_rpi1 = rpiKernel 1;
    # linux_rpi2 = rpiKernel 2;
    linux_rpi3 = rpiKernel 3;
    linux_rpi4 = rpiKernel 4;
    linux_rpi5 = rpiKernel 5;
  };

  getPackages = versions': pkgs:
    (
      getKernels versions' pkgs
    )
    // (
      getFirmwares versions' pkgs
    );

  overlay = versions': final: prev:
    {
      kernels = prev.kernels.extend (kFinal: kPrev: getKernels versions' prev);
    }
    // getFirmwares versions' prev;
}
