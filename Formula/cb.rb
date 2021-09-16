class Cb < Formula
  desc "CLI for Crunchy Bridge"
  homepage "https://crunchybridge.com"
  url "https://github.com/will/cb/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "bc91905158ca0e24f65c903783910ea5ed6b968f8d6a6c7554ea602a93432619"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/will/homebrew-cb/releases/download/cb-0.7.1"
    sha256 cellar: :any,                     arm64_big_sur: "e61e7f517d168a205c3873cdbd7bc5c2563b06876af0e445c319b84b21cc18b6"
    sha256 cellar: :any,                     catalina:      "00d7a969877592496e1354c4b56d61e958735021da39acc600677a8bec841155"
    sha256 cellar: :any_skip_relocation,     x86_64_linux:  "5a8583db91d67ebc3604b4b4c200de899b73e6660628b7edc0289ff3871c7ab4"
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
