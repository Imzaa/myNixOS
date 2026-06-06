{ self, inputs, ... }: {

  flake.nixosConfigurations.myNix = inputs.nixpkgs.lib.nixosSystem {
    modules = [ 
      self.nixosModules.myNixConfiguration
      inputs.home-manager.nixosModules.home-manager
    ];
  };
}
