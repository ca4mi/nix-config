{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/ca4mi/secrets.git";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;

    supportedSystems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

  in {
    # nix-env -f '<nixpkgs>' -iA git
    # Available through 'nixos-rebuild --flake .#your-hostname'
    # sudo nixos-rebuild switch --flake "git+file:.#asahina"
    nixosConfigurations = {
      asahina = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/asahina/configuration.nix
          ./nixos/_common
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          {
            nixpkgs.overlays = [
              (import ./pkgs/keyboard-layouts)
            ];
          }
        ];
      };
    };
    # nixos-install --root "/mnt" --no-root-passwd --flake "git+file:///mnt/etc/nixos#nagato"
    nixosConfigurations = {
      nagato = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/nagato
          ./nixos/_common
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          #./users/ca4mi
          # todo - make it work
          #inputs.home-manager.nixosModules.home-manager
          #  {
          #    home-manager.useGlobalPkgs = false;
          #    home-manager.extraSpecialArgs = { inherit inputs outputs; };
          #    home-manager.users.ca4mi.imports = [
          #    inputs.agenix.homeManagerModules.default
          #    ];
          #    home-manager.backupFileExtension = "bak";
          #};
        ];  
      };
    };
  };
}
