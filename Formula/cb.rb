class Cb < Formula
  desc "CLI for Crunchy Bridge"
  homepage "https://crunchybridge.com"
  url "https://github.com/will/cb/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "ba9a0674b43d9b7414b395b74ce3b9d500f856c8f9487eefcff0cc678e5d8c4d"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/will/homebrew-cb/releases/download/cb-0.4.0"
    sha256 cellar: :any, catalina: "fb2d48bfa21b646af3eb46d083bbf54a94ecc99d50ccb62ebdadbc45d2d874ba"
    sha256 cellar: :any, arm64_big_sur: "38001bfeb9897c504c6dce3a8df7c3306e404324c16b9de634104935078b0de4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6bda5a5e7608ed6e22a4fbd795111629ab35efed3455596a096874ce0020b658"
  end

  head do
    url "https://github.com/will/cb.git"
  end

  depends_on "make" => :build
  depends_on "pkg-config" => :build

  depends_on "libevent"
  depends_on "openssl@1.1"
  depends_on "pcre"

  uses_from_macos "zlib"

  on_macos do
    depends_on "bdw-gc"
    depends_on "crystal" => :build
  end

  resource "crystal" do
    on_linux do
      url "https://github.com/crystal-lang/crystal/releases/download/1.0.0/crystal-1.0.0-1-linux-x86_64.tar.gz"
      version "1.0.0-1"
      sha256 "00211ca77758e99210ec40b8c5517b086d2ff9909e089400f6d847a95e5689a4"
    end
  end

  def install
    unless OS.mac?
      # Use static Crystal compiler, since the one in Homebrew seems to be broken
      # for Linux
      (buildpath / "crystal").install resource("crystal")
      ENV.prepend_path "PATH", "crystal/bin"
      ENV.prepend_path "PATH", "crystal/embedded/bin"

      ENV.prepend_path "PKG_CONFIG_PATH", (Formula["readline"].opt_lib / "pkgconfig")
      ENV.prepend_path "PKG_CONFIG_PATH", (Formula["zlib"].opt_lib / "pkgconfig")

      ENV.prepend_path "CRYSTAL_LIBRARY_PATH", (buildpath / "crystal/lib/crystal/lib")
    end
    # system "shards", "build", "--release"
    system "make", "build", "RELEASE=1"

    bin.install "bin/cb"
    fish_completion.install "completions/cb.fish"
  end

  test do
    assert_match "Usage: cb", shell_output(bin / "cb --help")
  end
end
