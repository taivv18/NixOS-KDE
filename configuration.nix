{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";

    SDL_VIDEODRIVER = "wayland";

    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [
    "resume=UUID=67796cf3-3db9-4be2-a11a-f630507c1402"
    "resume_offset=124231680"
  ];
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.yama.ptrace_scope" = 1;

    "kernel.sysrq" = 4;

    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;

    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.tcp_syncookies" = 1;

    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;

    "kernel.randomize_va_space" = 2;

    "fs.suid_dumpable" = 0;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "ironMule";

  systemd.services.NetworkManager-wait-online.enable = false;

  networking.networkmanager = {
    enable = true;
    settings.connectivity.enabled = false;
  };
  networking.nftables.enable = true;
  networking.nameservers = ["1.1.1.1" "1.0.0.1"];
  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Driver giải mã video
      intel-media-driver
      # Hỗ trợ các app đồ họa cũ
      intel-vaapi-driver
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  fonts.packages = with pkgs; [
    inter
    ibm-plex
    nerd-fonts.jetbrains-mono

    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-unikey # Tiếng Việt (Telex/VNI)
      qt6Packages.fcitx5-chinese-addons # Pinyin, Wubi...
      qt6Packages.fcitx5-configtool
    ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.cloudflare-warp.enable = true;
  services.thermald.enable = true;
  # Enable KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.apparmor.enable = true;
  security.pam.services.sddm.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.login.fprintAuth = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.hashedPassword = "!";
  security.sudo = {
    wheelNeedsPassword = true;
    execWheelOnly = true;
  };
  users.users."taivv18" = {
    isNormalUser = true;
    description = "Vu Viet Tai";
    extraGroups = [
      "networkmanager" # Quản lý mạng, wifi
      "wheel" # Quyền chạy lệnh sudo
      "video" # Độ sáng màn hình
      "audio" # Pamixer chỉnh âm lượng
      "input" # Quyền đọc thiết bị, chuột, bàn phím
      "libvirtd" # Quyền chạy máy ảo, kvm
      "adbusers" # Quyền kết nối điện thoại qua android tools
      "kvm" # Tăng tốc phần cứng máy ảo
      # "docker" # Docker
      "wireshark"
    ];
    packages = with pkgs; [
      krita
      blender
      inkscape
      goldendict-ng
      anki
      meld
      gnucash
      obs-studio
    ];
  };

  # Install firefox.
  programs.tmux.enable = true;
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false; # Đổi thành true nếu bạn không dùng đồng bộ tài khoản Firefox
      PasswordManagerEnabled = false; # Khuyên dùng: Nên tắt để tránh bị malware đọc trộm mật khẩu trình duyệt

      # Ép buộc các cài đặt bảo mật sâu bên trong about:config
      Preferences = {
        "privacy.firstparty.isolate" = true; # Cô lập cookie của từng trang web riêng biệt
        "privacy.resistFingerprinting" = true; # Làm giả thông số phần cứng để các trang web không thể theo dõi bạn
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "dom.event.clipboardevents.enabled" = false; # Chặn không cho trang web đọc/ghi trộm vào khay nhớ tạm (Clipboard)
        "media.peerconnection.enabled" = false; # Tắt WebRTC để tránh bị rò rỉ địa chỉ IP thật khi dùng VPN
      };
    };
  };
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "cloudflare-warp"
    ];

  environment.systemPackages = with pkgs; [
    curl
    socat
    netcat
    wget
    inetutils
    mtr
    nmap
    tcpdump
    lynis
    usbguard
    espeak-ng
    testdisk
    aide
    gdb
    strace
    ltrace
    dust

    openssl
    libmbim
    zlib
    usbutils
    dmidecode
    pciutils
    lshw
    hwinfo
    inxi
    kmod
    systemd
    binwalk
    lsof
    bandwhich
    dig
    sysstat
    perf-tools
    btop
    iotop
    iftop
    nethogs
    powertop
    nodejs
    python3
    clang-tools
    corepack
    gcc
    stylua
    lua-language-server
    nil
    alejandra
    file-roller
    direnv
    nix-direnv
    neovim
    eza
    file
    tree
    ripgrep
    fd
    unzip
    starship
    lazygit
    android-tools
    scrcpy
    zip
    _7zz
    cmake
    gnumake
    pkg-config
    smartmontools
    lm_sensors
    brightnessctl
    cpufrequtils
    tpm2-tools
    wayland-utils

    kdePackages.kamoso
    kdePackages.kdeconnect-kde
    kdePackages.merkuro
    kdePackages.kcontacts
    kdePackages.akonadi-contacts
    kdePackages.kcalendarcore
    kdePackages.akonadi
    kdePackages.filelight
    kdePackages.plasma-browser-integration
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.krdp
    kdePackages.khelpcenter

    nix-tree
    nix-output-monitor
    nix-index
    comma
  ];

  # Keep Plasma installed, but disable KDE's crash handler entirely.
  systemd.services."drkonqi-coredump-processor@".enable = false;
  systemd.user.sockets."drkonqi-coredump-launcher".enable = false;
  systemd.user.services."drkonqi-coredump-launcher@".enable = false;
  systemd.user.services."drkonqi-coredump-pickup".enable = false;
  systemd.user.timers."drkonqi-coredump-cleanup".enable = false;
  systemd.user.services."drkonqi-sentry-postman".enable = false;
  systemd.user.paths."drkonqi-sentry-postman".enable = false;
  systemd.user.timers."drkonqi-sentry-postman".enable = false;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.wireshark.enable = true;
  programs.git = {
    enable = true;
    config = {
      user.name = "taivv18";
      user.email = "taivv18@gmail.com";
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  security.audit = {
    enable = true;
    rules = ["-a exit,always -F arch=b64 -S execve"]; # ví dụ
  };
  security.auditd.enable = true;
  services.gvfs.enable = true;
  services.dbus.enable = true;
  services.fwupd.enable = true;
  services.udisks2.enable = true;
  services.fprintd.enable = true;
  services.flatpak.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;

  services.power-profiles-daemon.enable = false;
  services.upower.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      USB_BLACKLIST_PHONE = 1;

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 90;

      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 40;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 75;
    };
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  systemd.packages = [
    pkgs.cloudflare-warp
  ];

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "15min";
  };

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
    };
  };
  zramSwap = {
    enable = true;
    priority = 100;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };
  swapDevices = [
    {
      device = "/swapfile";
      size = 34816;
      priority = 10;
    }
  ];
  system.stateVersion = "26.05";
}
