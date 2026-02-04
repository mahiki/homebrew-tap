class Desertislandutils < Formula
  include Language::Python::Virtualenv

  desc "Be here, thy collection of personal convenience utilities"
  homepage "https://github.com/mahiki/homebrew-tap"
  url "https://github.com/mahiki/desertislandutils/releases/download/v0.4.4/desertislandutils-0.4.4.tar.gz"
  sha256 "4f8dec76c36c0fb52172a4deac8b96a04b6eea5f7605615c37ce6dfb7216503c"
  license "MIT"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")

    # Install the package and its dependencies
    venv.pip_install_and_link buildpath
  end

  test do
    system "#{bin}/wn", "--help"
    system "#{bin}/too", "--help"
  end
end