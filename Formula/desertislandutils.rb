class Desertislandutils < Formula
  include Language::Python::Virtualenv

  desc "Be here, thy collection of personal convenience utilities"
  homepage "https://github.com/mahiki/homebrew-tap"
  url "https://github.com/mahiki/desertislandutils/releases/download/v0.3.16/desertislandutils-0.3.16.tar.gz"
  sha256 "50568c366a90860007a5a11e493c33ded2448da97d1bdb7a82b3a2a81a311ba8"
  license "MIT"

  depends_on "poetry"
  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
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
