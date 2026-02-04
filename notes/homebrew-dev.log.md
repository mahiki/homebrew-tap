# Homebrew Dev Log

## CHEWS PLACE
```sh
# DEV: run install from local formula
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose Formula/desertislandutils.rb

# DEV: test locally
brew test-bot --only-tap-syntax Formula/desertislandutils.rb
```

## 2024-07-24: INSTALL FROM REMOTE
**Final Formula works great! (so proud)**

[Formula Cookbook](https://docs.brew.sh/Formula-Cookbook#basic-instructions)
[Homebrew builds doc](https://docs.brew.sh/Reproducible-Builds)

```sh
==> poetry install --no-root
Last 15 lines from $HOME/Library/Logs/Homebrew/desertislandutils/02.poetry:
2024-07-23 22:25:05 +0000

poetry
install
--no-root

Poetry could not find a pyproject.toml file in /private/tmp/desertislandutils-20240724-57124-8bvipf or its parents
```
### Final Formula
* added VIRTUAL_ENV
* change directory to buildpath
* poetry still installing in weird directory, but symlink step still works
```rb
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
```

## 2024-07-23: HOMEBREW INSTALL FROM FILE
### Totally Works!
```ruby
  def install
    venv = virtualenv_create(libexec, "python3")
    ENV["VIRTUAL_ENV"] = libexec
    system "poetry", "install", "--no-root"
    venv.pip_install_and_link buildpath
  end
```

### First Try: wn installed and linked, but dependencies installed to poetry venv
```sh
cd ./the-others/homebrew-tap
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose Formula/desertislandutils.rb

# it pulls down a whole lotta objects.

==> Finishing up
ln -s ../Cellar/desertislandutils/0.3.10/bin/too too
ln -s ../Cellar/desertislandutils/0.3.10/bin/wn wn
==> Summary
🍺  /opt/homebrew/Cellar/desertislandutils/0.3.10: 22 files, 35.6KB, built in 9 seconds

# Install works! symlinks created.

which wn
/Users/hans/bin/utility/wn
/opt/homebrew/bin/wn

/opt/homebrew/bin/wn --help
    # Traceback (most recent call last):
    # File "/opt/homebrew/bin/wn", line 5, in <module>
    #     from src.weeknumber.wn import app
    # File "/opt/homebrew/Cellar/desertislandutils/0.3.10/libexec/lib/python3.12/site-packages/src/weeknumber/wn.py", line 9, in <module>
    #     import pendulum
    # ModuleNotFoundError: No module named 'pendulum'
```
Module not found, because it installed in the usual poetry env:

    ==> poetry install --no-root
    Creating virtualenv desertislandutils-wMi-OlyN-py3.12 in /private/tmp/desertislandutils-20240723-43941-or2nph/desertislandutils-0.3.10/.brew_home/Library/Caches/pypoetry/virtualenvs

## 2024-07-23: POETRY INSTALL IN HOMEBREW
Chatgpt narrows down a potentially workable idea.
The crux is that when poetry install is run inside a virtual environment, it doesn't create a new random path.

```sh
cd "$(mktemp -d)"
python3 -m venv libexec
source libexec/bin/activate
tar -xf desertislandutils-0.3.10.tar.gz
cd desertislandutils-0.3.10.tar.gz
poetry install
poetry env info
    # /private/var/folders/x9/d983fsw11ls6y88p7f2_2zrc0000gn/T/tmp.rrm9NYOBXR/libexec

l /private/var/folders/x9/d983fsw11ls6y88p7f2_2zrc0000gn/T/tmp.rrm9NYOBXR/libexec/bin/
    # -rwxr-xr-x 1  186 2024-07-23 20:49 wn
    # -rwxr-xr-x 1  192 2024-07-23 20:49 too

bat --plain /private/var/folders/x9/d983fsw11ls6y88p7f2_2zrc0000gn/T/tmp.rrm9NYOBXR/libexec/bin/wn
    #!/private/var/folders/x9/d983fsw11ls6y88p7f2_2zrc0000gn/T/tmp.rrm9NYOBXR/libexec/bin/python
    import sys
    from src.weeknumber.wn import app

    if __name__ == '__main__':
        sys.exit(app())

# Destroy the virtual environment
deactivate
rm -rf venv
```
GREAT! The install is within the existing virtual environment. No random path like:

    ../Caches/pypoetry/virtualenvs/templisher-4hu7XBP5-py3.11

**Problem:** maybe homebrew doesn't activate the virtual enviro. Then what?

```sh
cd "$(mktemp -d)"
python3 -m venv libexec
curl -LO https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10.tar.gz
# untar and cd
export VIRTUAL_ENV=../libexec
cd desertislandutils-0.3.10     # I hope homebrew is smart enough to do this
poetry install
l ../libexec/bin
    # -rwxr-xr-x 1  117 2024-07-23 22:03 wn
    # -rwxr-xr-x 1  123 2024-07-23 22:03 too
    # lrwxr-xr-x 1   10 2024-07-23 21:30 python -> python3.11

poetry env info --executable
    # ../libexec/bin/python

bat --plain ../libexec/bin/wn -l py
    #!../libexec/bin/python
    import sys
    from src.weeknumber.wn import app

    if __name__ == '__main__':
        sys.exit(app())
```
WOW. So if homebrew handles with absolute paths it should be no problem.
Obv the relative assignment I did there wasnt good.


## 2024-07-23: CAPITULATE - SPECIFY ALL DEPENDENCIES
```sh
brew update-python-resources --print-only Formula/desertislandutils.rb
# long list of packages, they looks like a subset of the lock file.
```

I guesss that plus the way it can rewrite the formula file opens up a good option 
for triggering a GHA job that pulls the repo, updates the formula, build and test, merge to main.

* And the links will work correctly
* And the uninstall process will work, where maybe not with poetry

### How to use homebrew-pypi-poet
```sh
# Use a temporary directory for the virtual environment
cd "$(mktemp -d)"

# Create and source a new virtual environment in the venv/ directory
python3 -m venv venv
source venv/bin/activate

# Install the package of interest as well as homebrew-pypi-poet
pip install some_package homebrew-pypi-poet
    # I did:
    # pip install https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10.tar.gz  homebrew-pypi-poet
        # Building wheel for desertislandutils (pyproject.toml) ... done
        # Created wheel for desertislandutils: filename=desertislandutils-0.3.10-py3-none-any.whl size=5531 sha256=ee2a20015a6329e3a298ffd7a562e519161599331c0424c99c4c77afa3af68c3
        # Stored in directory: /Users/hans/Library/Caches/pip/wheels/d0/56/ee/2b008b2c75cf901cf5894ae81a4fee4f7b105cf658cd653555
        # Successfully built desertislandutils

poet desertislandutils
# pretty much the same as update-python-resources
# with also:
    # resource "desertislandutils" do
        # url "https://files.pythonhosted.org/packages/62/0f/db9abf3d5d7513b50f618d634cf666278cd6deb0e73f5880bfcc838b5c59/desertislandutils-0.1.0.tar.gz"
        # sha256 "573c103661d99ff73a3f9749f5c3343f2e8255e36a66928a7192aaabecd056ef"
    # end

# Destroy the virtual environment
deactivate
rm -rf venv
```

## 2024-07-23: DEEPER AND DEEPER - POETRY IN HOMEBREW
I asked chat GPT if i can just do poetry install inside the homebrew installation. I suspect the fine points are the symlinks and the script with special shebang that homebrew creates as a local executable.

Brew docs say dont use pip or setup.py to install dependencies, which are unversioned ie from master branch.
But look at `poetry.lock`: these are versioned and checksummed in poetry:

```toml
[[package]]
name = "argparse"
version = "1.4.0"
description = "Python command-line parsing library"
optional = false
python-versions = "*"
files = [
    {file = "argparse-1.4.0-py2.py3-none-any.whl", hash = "sha256:c31647edb69fd3d465a847ea3157d37bed1f95f19760b11a47aa91c04b666314"},
    {file = "argparse-1.4.0.tar.gz", hash = "sha256:62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"},
]
```
Doesnt have the URL, but see PyPi: https://pypi.org/project/argparse/1.4.0/#files
Hashes are there, tar and .whl just like GH releases.

## 2024-07-23: MINIMAL FORMULA
I just want to generate teh formula

```sh
export HOMEBREW_NO_INSTALL_FROM_API=1
url="https://github.com/mahiki/desertislandutils/releases/download/v0.3.10/desertislandutils-0.3.10.tar.gz"

brew create --tap "mahiki/homebrew-tap" $url
# Formula name [desertislandutils]:
# ==> Tapping homebrew/core
# Cloning into '/opt/homebrew/Library/Taps/homebrew/homebrew-core'...
# fetching about 2M objects for some reason
```

Why is it alwasy a sh*t show?

```sh
brew create --no-fetch --tap "mahiki/homebrew-tap" $url
# Cloning into '/opt/homebrew/Library/Taps/homebrew/homebrew-core'...
# remote: Enumerating objects: 2068170, done.
# remote: Counting objects: 100% (2515/2515), done.
# remote: Compressing objects: 100% (935/935), done.
# Receiving objects:   1% (20682/2068170), 12.13 MiB | 2.12 MiB/s
```
Well this sucks a##.
This gets me nowhere. The example formula comes out as Ruby install commands.

### ChatGPT says try `brew-pypi-poet`
```sh
brew install brew-pypi-poet
poet mypackage > MyPackage.rb
```
There is no such brew package. U can install with pip. I don't want all that entails.

### Just change the file, merge to mahiki/homebrew-tap:main
```sh
brew update
brew uninstall desertislandutils
brew info desertislandutils
    # ==> mahiki/tap/desertislandutils: stable 0.3.10
    # Be here, thy collection of personal convenience utilities
    # https://github.com/mahiki/homebrew-tap
    # Not installed
brew install desertislandutils
```

### FAILURE: just not working go back to the tarball with explicit resource dependencies.

## 2024-07-22: THE EXECUTABLE
I found in the 0.3.9 deployment that the src/weeknumber module wasn't added to pyproject.toml.
Investigating uncovered the format of the executable script that homebrew makes:

```sh
# FILE: /opt/homebrew/bin/wn

#!/opt/homebrew/Cellar/desertislandutils/0.3.9/libexec/bin/python
# -*- coding: utf-8 -*-
import re
import sys
from src.weeknumber.wn import app
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(app())
```

And Poetry creates an executable script as well in the virtual environment:

```sh
# bin/wn:
bat --style plain /Users/hans/Library/Caches/pypoetry/virtualenvs/desertislandutils-zyraM7-y-py3.12/bin/wn
#!/Users/hans/Library/Caches/pypoetry/virtualenvs/desertislandutils-zyraM7-y-py3.12/bin/python
import sys
from src.weeknumber.wn import app

if __name__ == '__main__':
    sys.exit(app())
```

# bin/too:
bat --style plain /Users/hans/Library/Caches/pypoetry/virtualenvs/desertislandutils-zyraM7-y-py3.12/bin/too
#!/Users/hans/Library/Caches/pypoetry/virtualenvs/desertislandutils-zyraM7-y-py3.12/bin/python
import sys
from src.toobigdatadoc.too import main

if __name__ == '__main__':
    sys.exit(main())
```