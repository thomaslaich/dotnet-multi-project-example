{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);

    in {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          nugetDeps = ./deps.nix;
        in rec {
          devenv-up = self.devShells.${system}.default.config.procfileScript;

          library = pkgs.buildDotnetModule {
            name = "project-references-test-library";
            src = ./library;

            inherit nugetDeps;

            dotnet-sdk = pkgs.dotnet-sdk_7;
            dotnet-runtime = pkgs.dotnet-runtime_7;

            packNupkg = true;
          };

          application = pkgs.buildDotnetModule {
            name = "project-references-test-application";
            src = ./application;
            
            inherit nugetDeps;

            projectReferences = [ library ];

            dotnet-sdk = pkgs.dotnet-sdk_7;
            dotnet-runtime = pkgs.dotnet-runtime_7;
          };

        });

      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};

        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [{
              packages = with pkgs; [
                cowsay
                lolcat
                just # task runner
                sqlite # sqlite3 db for now
                dotnet-sdk_7 # .NET SDK version 7
              ];

              enterShell = ''
                export DOTNET_ROOT=${pkgs.dotnet-sdk_7}
                cowsay "Welcome to .NET dev shell" | lolcat
              '';

              processes.run.exec = "hello";

            }];
          };
        });
    };
}
