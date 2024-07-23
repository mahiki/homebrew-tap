class Desertislandutils < Formula
  include Language::Python::Virtualenv

  desc "Be here, thy collection of personal convenience utilities"
  homepage "https://github.com/mahiki/homebrew-tap"
  url "https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10.tar.gz"
  sha256 "9c8304fdb02a1fd9d3ffd460cdaf25f1b22a70f2d18ebde700080d328c306216"
  license "MIT"

  depends_on "python@3.11"
  depends_on "poetry"

  def install
    venv = virtualenv_create(libexec, "python3")

    ENV["VIRTUAL_ENV"] = libexec

    puts "libexec: #{libexec}"
        # this comes as: libexec: /opt/homebrew/Cellar/desertislandutils/0.3.10/libexec

    system "poetry", "install", "--no-root"

    venv.pip_install_and_link buildpath

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
    system "#{bin}/wn", "--help"

    # TODO: basic test of built function
    # system "#{bin}/wn", "--help"
    # system "#{bin}/too", "--help"
  end
end
