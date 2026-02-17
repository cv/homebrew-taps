class BashAst < Formula
  desc "Parse bash scripts to JSON AST using GNU Bash's actual parser"
  homepage "https://github.com/cv/bash-ast"
  url "https://github.com/cv/bash-ast.git",
      tag:      "v0.3.2",
      revision: "26330eec13aff1040b7ed55f9e7492800af44997"
  license "GPL-3.0-only"
  bottle do
    root_url "https://github.com/cv/bash-ast/releases/download/v0.3.2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7e44521bfc46b7006cc20c0cc0ce1f747e909db731faf2b686ca92f8d25ec15f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "54eb73278c32a5207fac19921ed8f669453a041d8042ef469df3a936d2f54901"
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
