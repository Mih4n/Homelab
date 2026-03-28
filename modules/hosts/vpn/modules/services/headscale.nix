{ config, lib, pkgs, ... }: {
    options.bytes.headscale = {
        adminUser = lib.mkOption {
            type = lib.types.str;
            default = "vpn";
            description = "Username for the headscale admin user";
        };
        exitNodes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
        };
        subnetRouters = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
        };
    };

    config = let
        cfg = config.bytes.headscale;
        admin = cfg.adminUser;
        allUsers = lib.unique([ admin ] ++ cfg.exitNodes ++ cfg.subnetRouters);
        normalize = users: lib.map (user: "${user}@") users;

        aclConfig = {
            acls = [
                {
                    action = "accept";
                    src = ["*"];
                    dst = ["*:*"];
                }
            ];
            
            groups = {
                "group:admins" = normalize [ admin ];
                "group:exit-nodes" = normalize cfg.exitNodes;
                "group:subnet-routers" = normalize cfg.subnetRouters;
            };

            tagOwners = {
                "tag:admin" = [ "group:admins" ];
                "tag:exit-node" = [ "group:admins" "group:exit-nodes" ];
                "tag:subnet-router" = [ "group:admins" "group:subnet-routers" ];
            };

            autoApprovers = {
                routes = {
                    "0.0.0.0/0" = [ "group:admins" ];
                    "10.0.0.0/8" = [ "group:admins" "group:subnet-routers" ];
                    "192.168.0.0/16" = [ "group:admins" "group:subnet-routers" ];
                };
                exitNode = [ "group:admins" "group:exit-nodes" ];
            };
        };

        aclHuJson = builtins.toJSON aclConfig;
        aclFile = pkgs.writeText "acl-policy.hujson" aclHuJson;
    in {
        services.headscale = {
            enable = true;
            port = 3009;
            settings = {
                listen_addr = "0.0.0.0:3009";
                server_url = "https://vpn.mih4n.xyz";
                dns = {
                    base_domain = "bytes";
                    nameservers.global = [ "8.8.8.8" "1.1.1.1" ];
                };
                policy.path = "${aclFile}";
            };
        };

        systemd.services.headscale-ensure-users = lib.mkIf config.services.headscale.enable {
            description = "Ensure Headscale users exist";
            after = [ "headscale.service" ];
            requires = [ "headscale.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                Type = "oneshot";
                User = "headscale";
                Group = "headscale";
            };

            script = let
              headscaleCmd = "${pkgs.headscale}/bin/headscale";
            in
            lib.concatStringsSep "\n" ([
              "set -e"
            ] ++ (lib.map 
                    (user: ''${headscaleCmd} users create "${user}" 2>/dev/null || echo "User ${user} already exists or creation failed."'') 
                    allUsers
                )
            );
        };
    };
}