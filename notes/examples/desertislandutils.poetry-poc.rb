# Demonstrates using poetry install to bring dependencies without
# specifying every single resource URL and SHA like usual, which sucks.
# author: mahiki with help from chatgpt4, a lot of back and forth.

class YourPackage < Formula
    include Language::Python::Virtualenv
  
    desc "Description of your package"
    homepage "https://your.package.homepage"
    url "https://your.package.url/your_package-0.3.9.tar.gz"
    sha256 "SHA256_CHECKSUM_OF_YOUR_PACKAGE"
  
    depends_on "python@3.9"
    depends_on "poetry"
  
    def install
      # Create a virtual environment and folder
      venv = virtualenv_create(libexec, "python3")
  
      # Set the VIRTUAL_ENV, poetry uses this instead of generating a random path
      # libexec is a variable, the full path.
      # /opt/homebrew/Cellar/desertislandutils/0.3.10/libexec

      ENV["VIRTUAL_ENV"] = libexec
  
      # Install the package dependencies using poetry, not the package source
      system "poetry", "install", "--no-root"
  
      # Install the package itself using pip and create necessary symlinks
      venv.pip_install_and_link buildpath
    end
  
    test do
      # Test the installation
      system "#{bin}/your_executable", "--version"
    end
  end
  