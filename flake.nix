{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    { self, nixpkgs, devenv, systems, nuget-packageslock2nix, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);

    in {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in rec {
          devenv-up = self.devShells.${system}.default.config.procfileScript;

          library = pkgs.buildDotnetModule {
            name = "project-references-test-library";
            src = ./library;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "project-references-test-library";
              lockfiles =
                [ ./library/packages.lock.json ];
            };


            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            packNupkg = true;
          };

          application = pkgs.buildDotnetModule {
            name = "project-references-test-application";
            src = ./application;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "project-references-test-application";
              lockfiles =
                [ ./application/packages.lock.json ];
            };

            projectReferences = [ library ];

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;
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
                dotnet-sdk_8 # .NET SDK version 7
              ];

              enterShell = ''
                export DOTNET_ROOT=${pkgs.dotnet-sdk_8}
                cowsay "Welcome to .NET dev shell" | lolcat
              '';

              processes.run.exec = "hello";

            }];
          };
        });
    };
}
