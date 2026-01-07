{
  description = "Homelab flakes configuration";

  inputs.nixpkgs.url = "nixpkgs";

  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations.apps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/apps/configuration.nix ];
      };

      nixosConfigurations.infra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/infra/configuration.nix ];
      };

      nixosConfigurations.obs = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/obs/configuration.nix ];
      };

      nixosConfigurations.dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/dev/configuration.nix ];
      };
      nixosConfigurations.template = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/template/configuration.nix ];
      };
    };
}
