class Desertislandutils < Formula
  include Language::Python::Virtualenv

  desc "Be here, thy collection of personal convenience utilities"
  homepage "https://github.com/mahiki/homebrew-tap"
  url "https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10.tar.gz"
  sha256 "9c8304fdb02a1fd9d3ffd460cdaf25f1b22a70f2d18ebde700080d328c306216"
  license "MIT"

  depends_on "poetry"
  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3")
    ENV["VIRTUAL_ENV"] = libexec
    ENV.prepend_path "PATH", "#{libexec}/bin"
    puts "install stage libexec path: #{libexec}"
    puts "env VIRTUAL_ENV: #{ENV["VIRTUAL_ENV"]}"
    puts "buildpath: #{buildpath}"
    cd buildpath do
      system "poetry", "install", "--no-root"
    end
    venv.pip_install_and_link buildpath
  end

  test do
    system "#{bin}/wn", "--help"
    system "#{bin}/too", "--help"
  end
end
