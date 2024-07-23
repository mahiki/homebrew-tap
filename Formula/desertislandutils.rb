class Desertislandutils < Formula
  include Language::Python::Virtualenv

  desc "Be here, thy collection of personal convenience utilities"
  homepage "https://github.com/mahiki/homebrew-tap"
  url "https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10-py3-none-any.whl"
  sha256 "ee2a20015a6329e3a298ffd7a562e519161599331c0424c99c4c77afa3af68c3"
  license "MIT"

  depends_on "python@3.11"
  depends_on "poetry"

  def install
    venv = virtualenv_create(libexec, "python3")
    ENV["VIRTUAL_ENV"] = libexec
    ENV.prepend_path "PATH", "#{libexec_path}/bin"
    puts "instal stage libexec path: #{libexec}"
    puts "env VIRTUAL_ENV: #{libexec}"
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
