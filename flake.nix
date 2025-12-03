{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    home-manager,
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
          inputs.agenix.nixosModules.default
          {
            nixpkgs.overlays = [
              (import ./pkgs/keyboard-layouts)
            ];
          }
        ];
      };
    };

    # Available through 'home-manager --flake .#your-username@your-hostname'
    # home-manager switch --flake "git+file:.#ca4mi@asahina"
    homeConfigurations = {
      "ca4mi@asahina" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          inputs.agenix.homeManagerModules.default 
          ./users/ca4mi/home.nix 
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
          ./modules/odoo
        ];  
      };
    };
  };
}
