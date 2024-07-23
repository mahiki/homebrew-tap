class Desertislandutils < Formula
  include Language::Python::Virtualenv

  desc "Be here, thy collection of personal convenience utilities"
  homepage "https://github.com/mahiki/homebrew-tap"
  url "https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10-py3-none-any.whl"
  sha256 "ee2a20015a6329e3a298ffd7a562e519161599331c0424c99c4c77afa3af68c3"
  license "MIT"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    # TODO: you should like test the brew install and function test of your cli things
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test desertislandutils`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
    # TODO: basic test of built function
    # system "#{bin}/wn", "--help"
    # system "#{bin}/too", "--help"
  end
end
