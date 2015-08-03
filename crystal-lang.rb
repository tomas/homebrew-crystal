require 'formula'

PLATFORM = RUBY_PLATFORM["linux"] ? "linux" : "darwin"
CRYSTAL_VERSION  = "0.7.5"
CRYSTAL_SHA = if PLATFORM == "linux"
  "e852d176d26e749083005fb7689ff2c28f3a987df62cb29b6dd8e7f417c90a6c"
else
  "1ba2fa6b614aa9814efe15745fba5289cb3f423e8fd0d99ec1e8aba24fe44950"
end

class CrystalLang < Formula
  homepage 'http://crystal-lang.org/'
  version CRYSTAL_VERSION
  conflicts_with 'crystal'

  stable do
    url "https://github.com/manastech/crystal/releases/download/#{CRYSTAL_VERSION}/crystal-#{CRYSTAL_VERSION}-1-#{PLATFORM}-x86_64.tar.gz"
    sha256 CRYSTAL_SHA
  end

  # head do
  #   url 'http://github.com/manastech/crystal.git'

  #   resource 'latest' do
  #     url 'http://crystal-lang.s3.amazonaws.com/crystal-darwin-latest.tar.gz'
  #   end
  # end

  depends_on "libevent"
  depends_on "pcre"
  depends_on "bdw-gc"
  depends_on "libunwind"

  depends_on "llvm" => :optional
  depends_on "libpcl" => :recommended
  depends_on "pkg-config"

  def install
    # if build.head?
    #   resource('latest').stage do
    #     (prefix/"deps").install "bin/crystal-exe" => "crystal"
    #   end

    #   script_root = %Q(INSTALL_DIR="#{prefix}")
    # end

    script_root = %Q(INSTALL_DIR="#{prefix}")
    inreplace('bin/crystal') do |s|
      s.gsub! /INSTALL_DIR=.+/, script_root
    end

    if build.with?('llvm') || Formula["llvm"].installed?
      inreplace('bin/crystal') do |s|
        if s =~ /export PATH="(.*)"/
          llvm_path = Formula["llvm"].opt_prefix
          s.gsub! /export PATH="(.*)"/, %(export PATH="#{llvm_path}/bin:#{$1}")
        end
      end
    end

    prefix.install Dir["*"]
  end

  def post_install
    resource('latest').clear_cache if build.head?
  end
end
