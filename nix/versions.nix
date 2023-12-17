{}: let
  bluez = fetchFromGitHub: rev: hash:
    fetchFromGitHub {
      inherit rev hash;

      name = "bluez-firmware";
      owner = "RPi-Distro";
      repo = "bluez-firmware";
    };
  firmware-nonfree = fetchFromGitHub: rev: hash:
    fetchFromGitHub {
      inherit rev hash;

      name = "firmware-nonfree";
      owner = "RPi-Distro";
      repo = "firmware-nonfree";
    };

  firmware = fetchFromGitHub: rev: hash:
    fetchFromGitHub {
      inherit rev hash;

      owner = "raspberrypi";
      repo = "firmware";
    };

  kernel = fetchFromGitHub: rev: hash:
    fetchFromGitHub {
      inherit rev hash;

      owner = "raspberrypi";
      repo = "linux";
    };
in {
  "6.1.63" = {fetchFromGitHub}: {
    kernel = kernel fetchFromGitHub "stable_20231123" "sha256-4Rc57y70LmRFwDnOD4rHoHGmfxD9zYEAwYm9Wvyb3no=";
    firmware = firmware fetchFromGitHub "1.20230405" "sha256-UtUd1MbsrDFxd/1C3eOAMDKPZMx+kSMFYOJP+Kc6IU4=";
    bluez = bluez fetchFromGitHub "d9d4741caba7314d6500f588b1eaa5ab387a4ff5" "sha256-UtUd1MbsrDFxd/1C3eOAMDKPZMx+kSMFYOJP+Kc6IU5=";
    firmware-nonfree = firmware-nonfree fetchFromGitHub "88aa085bfa1a4650e1ccd88896f8343c22a24055" "sha256-UtUd1MbsrDFxd/1C3eOAMDKPZMx+kSMFYOJP+Kc6IU6=";
    version = "6.1.63";
  };
}
