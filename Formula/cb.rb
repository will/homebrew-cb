class Cb < Formula
  desc "CLI for Crunchy Bridge"
  homepage "https://crunchybridge.com"
  url "https://github.com/will/cb/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "96b8a1ec377e77ff908f9e4ee7aac82300b1acb7842c29506bafc95a5f76faaf"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/will/homebrew-cb/releases/download/cb-0.7.0"
    sha256 cellar: :any,                     arm64_big_sur: "8db3b08fb512ef96c8f1543e963e053fd26be0073410debe04be0a76f763264c"
    sha256 cellar: :any,                     catalina:      "bef1eeafc4b59eb9a419ee7a1588f2ba5482c7d9df6b9ea04167e6ab371ad94b"
    sha256 cellar: :any_skip_relocation,     x86_64_linux:  "9611c90c843c60401d9fbbf4909fc8887d12225d1549b1c3997a27a2e64fa6f8"
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
