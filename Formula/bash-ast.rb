class BashAst < Formula
  desc "Parse bash scripts to JSON AST using GNU Bash's actual parser"
  homepage "https://github.com/cv/bash-ast"
  url "https://github.com/cv/bash-ast.git",
      tag:      "v0.3.0",
      revision: "b636ae13e6ab5e0cc4dbb83163d750b3f3ed26fe"
  license "GPL-3.0-only"
  bottle do
    root_url "https://github.com/cv/bash-ast/releases/download/v0.3.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dabc1c66e0965dbfdee2595ae027121ea8533791c6e44438836e23dafb1d8d55"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "90e3ae80fde319cfa734bf9bfcdefe7e9d8e81b3ca80cb84183e8dd370bf9cb7"
  end
  head "https://github.com/cv/bash-ast.git", branch: "main"

  depends_on "llvm" => :build
  depends_on "rust" => :build

  def install
    # Ensure LLVM is found by bindgen
    ENV["LLVM_CONFIG_PATH"] = Formula["llvm"].opt_bin/"llvm-config"

    # Initialize and update git submodules (bash source)
    system "git", "submodule", "update", "--init", "--recursive"

    # Set version from formula version (strips 'v' prefix if present)
    inreplace "Cargo.toml", /^version = .*/, "version = \"#{version}\""

    # Build and install the release binary
    system "cargo", "install", *std_cargo_args
  end

  test do
    # Test basic parsing
    output = pipe_output(bin/"bash-ast", "echo hello")
    json = JSON.parse(output)
    assert_equal "simple", json["type"]

    # Test pipeline parsing
    output = pipe_output(bin/"bash-ast", "ls | grep foo")
    json = JSON.parse(output)
    assert_equal "pipeline", json["type"]

    # Test for loop parsing
    output = pipe_output(bin/"bash-ast", "for i in a b c; do echo $i; done")
    json = JSON.parse(output)
    assert_equal "for", json["type"]
    assert_equal "i", json["variable"]
  end
end
