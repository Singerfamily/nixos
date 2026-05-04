_:
{
  den.aspects.graphify.homeManager =
    { pkgs, ... }:
    let
      py = pkgs.python3Packages;
      graphify = py.buildPythonApplication rec {
        pname = "graphifyy";
        version = "0.7.4";
        pyproject = true;

        src = pkgs.fetchFromGitHub {
          owner = "safishamsi";
          repo = "graphify";
          rev = "v${version}";
          hash = "sha256-vfwCCF5R6ZQCT2cXWqHWFAsNloWE45gkkdPWzEkR0pU=";
        };

        build-system = [ py.setuptools ];

        # tree-sitter language bindings not yet in nixpkgs are dropped from
        # metadata; graphify imports them lazily and degrades to "not installed"
        # for the corresponding file types (see graphify/extract.py).
        pythonRemoveDeps = [
          "tree-sitter-typescript"
          "tree-sitter-go"
          "tree-sitter-java"
          "tree-sitter-c"
          "tree-sitter-cpp"
          "tree-sitter-ruby"
          "tree-sitter-kotlin"
          "tree-sitter-scala"
          "tree-sitter-php"
          "tree-sitter-swift"
          "tree-sitter-lua"
          "tree-sitter-zig"
          "tree-sitter-powershell"
          "tree-sitter-elixir"
          "tree-sitter-objc"
          "tree-sitter-julia"
          "tree-sitter-verilog"
        ];

        dependencies = [
          py.networkx
          py.tree-sitter
          py.tree-sitter-python
          py.tree-sitter-javascript
          py.tree-sitter-rust
          py.tree-sitter-c-sharp
        ];

        # No test suite shipped via pyproject; tests/ requires unpackaged deps.
        doCheck = false;

        pythonImportsCheck = [ "graphify" ];

        meta = {
          description = "Turn a folder of code, docs, and media into a queryable knowledge graph";
          homepage = "https://github.com/safishamsi/graphify";
          license = pkgs.lib.licenses.mit;
          mainProgram = "graphify";
        };
      };
    in
    {
      home.packages = [ graphify ];
    };
}
