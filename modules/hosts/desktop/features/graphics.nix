{ ... }: {
    flake.nixosModules.hostDesktopGraphics = { pkgs, ... }: {
        boot.initrd.kernelModules = ["amdgpu"];
        services.xserver.videoDrivers = ["amdgpu"];

        hardware.graphics = {
            enable = true;
            enable32Bit = true;
        };

        hardware.amdgpu = {
            initrd.enable = true; 
            opencl.enable = true; 
        };
       
        environment.systemPackages = with pkgs; [
            clinfo 
            amdgpu_top 
            vulkan-tools 
        ];
    };
}