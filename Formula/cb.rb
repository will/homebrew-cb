class Cb < Formula
  desc "CLI for Crunchy Bridge"
  homepage "https://crunchybridge.com"
  url "https://github.com/will/cb/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "4769cd0959704ecec35ae95f3c661ace44cd02e266fde21d240baae3846570c2"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/will/homebrew-cb/releases/download/cb-0.6.0"
    sha256 cellar: :any,                     arm64_big_sur: "ea5416486425cfae1c712c3c05f7d5ca74cfc6d68ec7fe9bb223d25ae162d680"
    sha256 cellar: :any,                     catalina:      "acf3dbccb7d139a3567bd17393d0579de90752d24817aec17b67bd56688e4e28"
    sha256 cellar: :any_skip_relocation,     x86_64_linux:  "5e185cdf77c6ff522653336712b8b70bc2309542c67d6da62cf0bffb36a11e91"
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
