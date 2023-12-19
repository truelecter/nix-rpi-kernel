rec {
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

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/lib/firmware/brcm"

        # Wifi firmware
        cp -rv "$NIX_BUILD_TOP/firmware-nonfree/debian/config/brcm80211/." "$out/lib/firmware/"

        # Bluetooth firmware
        cp -rv "$NIX_BUILD_TOP/bluez-firmware/broadcom/." "$out/lib/firmware/brcm"

        # brcmfmac43455-stdio.bin is a symlink to the non-existent path: ../cypress/cyfmac43455-stdio.bin.
        # See https://github.com/RPi-Distro/firmware-nonfree/issues/26
        ln -s "./cyfmac43455-sdio-standard.bin" "$out/lib/firmware/cypress/cyfmac43455-sdio.bin"

        runHook postInstall
      '';
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
      pkgs.callPackage ./kernel.nix {
        inherit rpiVersion version;
        src = kernel;

        kernelPatches = with pkgs.kernelPatches; [
          bridge_stp_helper
          request_key_helper
        ];
      };
  in {
    # linux_rpi1 = rpiKernel 1;
    # linux_rpi2 = rpiKernel 2;
    linuxRpi3 = rpiKernel 3;
    linuxRpi4 = rpiKernel 4;
    linuxRpi5 = rpiKernel 5;
  };

  getKernelPackages = kernels: pkgs: let
    inherit (pkgs.lib) mapAttrs' nameValuePair;
  in
    mapAttrs' (name: value: nameValuePair "${name}Packages" (pkgs.linuxPackagesFor value)) kernels;

  getPackages = versions': pkgs: let
    kernels = getKernels versions' pkgs;
  in
    kernels
    // (
      getKernelPackages kernels pkgs
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
