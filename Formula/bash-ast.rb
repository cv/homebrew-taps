class BashAst < Formula
  desc "Parse bash scripts to JSON AST using GNU Bash's actual parser"
  homepage "https://github.com/cv/bash-ast"
  url "https://github.com/cv/bash-ast.git",
      tag:      "v0.3.3",
      revision: "dabfcc39c9f80f12940a0bdaa08c2db538e8b483"
  license "GPL-3.0-only"
  bottle do
    root_url "https://github.com/cv/bash-ast/releases/download/v0.3.3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bf0a9bb148e5df4f1b3e6d65a1dc55a609a50d89d5b39f1ff5d0bb4fb0a69bbc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "d36026d2f12b27f5a98d06e7d08bbf336ac3e2badedfb1ac5c24d909c232f7ab"
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
