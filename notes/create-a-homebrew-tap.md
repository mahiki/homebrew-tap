# Homebrew Tap: mahiki

- [Homebrew Tap: mahiki](#homebrew-tap-mahiki)
    - [IOYCSWISWYE: TOPLINES](#ioycswiswye-toplines)
    - [UNICORN DREAM: BUILT URL IS `/downloads/` LINK](#unicorn-dream-built-url-is-downloads-link)
    - [UNICORN DREAM: UPDATE BREW URL](#unicorn-dream-update-brew-url)
    - [INCEP-DATE](#incep-date)
    - [OFF-WORLD: setup github repo](#off-world-setup-github-repo)
    - [BLUSH-RESPONSE: create `too` formula](#blush-response-create-too-formula)
    - [BLUSH-RESPONSE: example brew python `asciinema`](#blush-response-example-brew-python-asciinema)
    - [BLUSH-RESPONSE: github actions poetry build/publish](#blush-response-github-actions-poetry-buildpublish)
        - [build workflow on GHA](#build-workflow-on-gha)
        - [local poetry publish to pypi](#local-poetry-publish-to-pypi)
    - [BLUSH-RESPONSE: ok create homebrew thingy now](#blush-response-ok-create-homebrew-thingy-now)
    - [EMPATHY](#empathy)

## IOYCSWISWYE: TOPLINES
NODO: trigger brew build on upstream updates at pypi

DONE: use github release istead of pypi. trigger brew bump formula on relase.

----------
## UNICORN DREAM: BUILT URL IS `/downloads/` LINK
```sh
curl -Ls https://github.com/mahiki/desertislandutils/releases/download/v0.1.0/desertislandutils-0.1.0.tar.gz | shasum -a 256
573c103661d99ff73a3f9749f5c3343f2e8255e36a66928a7192aaabecd056ef
```

Which is the same as the local tarball and the PyPi hosted download link as well.

Mystery solved!

## UNICORN DREAM: UPDATE BREW URL
The brew formula is working with tar.gz on pypi. I'm switching to github artifacts store via github release actions.

First lets try updating the formula with the new URL.

NOTE: the SHA of the tar.gz file locally is different than the github release tar.gz:
```sh
brew edit mahiki/tap/desertislandutils
# opens the desertislandtils.rb file

# github tar file created via Release UI from `main v0.1.0`
curl -Ls https://github.com/mahiki/desertislandutils/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
f787cbb83fd804fe7761ca2f1cceb425a74f4e581d557aea7e03e3afd8d49cc8  -

# ../desertislandutils/
shasum -a 256 dist/desertislandutils-0.1.0.tar.gz
573c103661d99ff73a3f9749f5c3343f2e8255e36a66928a7192aaabecd056ef  dist/desertislandutils-0.1.0.tar.gz
# DIFFERENT

# note the PyPi hosted one:
curl -Ls https://files.pythonhosted.org/packages/62/0f/db9abf3d5d7513b50f618d634cf666278cd6deb0e73f5880bfcc838b5c59/desertislandutils-0.1.0.tar.gz | shasum -a 256
573c103661d99ff73a3f9749f5c3343f2e8255e36a66928a7192aaabecd056ef  -
# SAME AS THE LOCAL COPY!
```

OK I have pushed the changed URL and SHA to `main` in tap-homebrew. Does it still work?
```sh
 brew audit desertislandutils
 # no result prob good

brew upgrade desertislandutils
# Warning: mahiki/tap/desertislandutils 0.1.0 already installed
```

OK, with no version change I suppose no action. But at least my .rb formula is now lined up for the next release.

----------
## INCEP-DATE
    python script -> poetry build -> pypi -> homebrew tap -> install local macos
    python script -> nuitka binary -> homebrew tap -> install local macos

* homebrew tap can install all of my:
    * python apps
    * bash scrips
    * julia apps
* on new machine, brew bundle install will bring everything in

## OFF-WORLD: setup github repo
```bash
cd $HOME/repo
git clone https://github.com/mahiki/homebrew-tap

brew tap-new mahiki/tap
cd $(brew --repo mahiki/tap)

# going to move the repo to ~/repo and symlink to brew location

brew developer off
```

Now my homebrew repo is set up, I can put all my brew formula there to publish to my tap with artifacts ready to download via github actions.

## BLUSH-RESPONSE: create `too` formula
* can do with binary or a gzip tar file
* Q: what about pypi repo?
    * [example rich text][richt] is a python repo with files deployed to pypi.
    * *has very simple Formula*
* Q: how does the execuatable get installed from brew, à la pipx?
    * need a good example, try visidata, a homebrew python project

```bash
# DONE: what goes at the URL? a pypi .whl or source.gz needs installer still
#   just use your pypi URL for package built.
brew create --tap=mahiki/tap <URL of tar artifact>
```

## BLUSH-RESPONSE: example brew python `asciinema`
* [ASCIINEMA has pyproject definition and pypi hosting.][asci]
* Maybe just make a pypi package and try the homebrew defaults

[asciinema brew formula simple](https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/asciinema.rb)

```rb
url "https://files.pythonhosted.org/packages/2c/31/492da48c9d7d23cd26f16c8f459aeb443ff056258bed592b5ba28ed271ea/asciinema-2.1.0.tar.gz"

bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1fea4ae9e201966f38b7b1d5a5edd46f047b8ab80ca382e5a4d218081ae5c8d5"
    # ..etc..
end

depends_on "python@3.10"

def install
virtualenv_install_with_resources
end
```

## BLUSH-RESPONSE: github actions poetry build/publish
See the section "Build and publish in one step" in [poetry issue: CI best practices][pogh].

* PyPi integration with token stored in GH secrets store
* Do you need to build with poetry on GHA? I don't think so, just the homebrew part.
* **OR:** can homebrew find the latest URL? it may update with version bump and then what.

### build workflow on GHA
1. develop/bufix on local machine in poetry environment on feature branch
2. test locally
3. merge to 'dev' branch
4. triggers GHA:
    * poetry publish --build
    * homebrew something something
5. `brew upgrade` to pull updated package home
   
Nice thing about this is the poetry publish reports the name of the new URL:

    Publishing desertislandutils (0.1.0) to PyPI
    - Uploading desertislandutils-0.1.0-py3-none-any.whl 100%
    - Uploading desertislandutils-0.1.0.tar.gz 100%

### local poetry publish to pypi

```bash
# pypi credentials setup here
poetry config --list

# build/publish in one step from GH actions (after pushing commit to main i guess)
poetry publish --build
```

OK get started, PyPi project created. Only way I can figure out to pass the token to poetry is paste to CLI, *no idea where that config is stored*.

WAIT: suddenly its in macos keychain, 'poetry-repository-pypi'.

    poetry config pypi-token.pypi pypi-AgEIcHl...
    # new entry in macos keychain is created

This from the [poetry issue:][pogh], build and publish to pypi in one go from github actions, with token stored in secrets vault.

```yaml
- name: Build Python package and publish to PyPI
  if: startsWith(github.ref, 'refs/tags/')
  run: poetry publish --build -u __token__ -p ${{ secrets.PYPI_TOKEN }}
```


## BLUSH-RESPONSE: ok create homebrew thingy now
**PASS:** homebrew install working.

```bash
brew create --help


brew create --python --tap mahiki/tap https://files.pythonhosted.org/packages/62/0f/db9abf3d5d7513b50f618d634cf666278cd6deb0e73f5880bfcc838b5c59/desertislandutils-0.1.0.tar.gz

    # Warning: Cannot verify integrity of 'f5af43b2315a0b6995de022db656819a240e789e3f4dd3f6e944338fbdab89ae--desertislandutils-0.1.0.tar.gz'.
    # No checksum was provided for this resource.
    # For your reference, the checksum is:
    # sha256 "573c103661d99ff73a3f9749f5c3343f2e8255e36a66928a7192aaabecd056ef"

# Please run `brew audit --new desertislandutils` before submitting, thanks.
# Editing /opt/homebrew/Library/Taps/mahiki/homebrew-tap/Formula/desertislandutils.rb
```

Edit description and license, maybe its good to go?

```bash
brew audit --new desertislandutils

# yeah just push straight into main
git add Formula/desertislandutils.rb
git commit --message "desertislandutils 0.1.0 (new formula)"
```

**Can we install with brew now?**
```bash
brew info mahiki/tap/desertislandutils
    # mahiki/tap/desertislandutils: stable 0.1.0
    # A collection of personal convenience utilities
    # https://github.com/mahiki/homebrew-tap
    # Not installed
    # From: https://github.com/mahiki/homebrew-tap/blob/HEAD/Formula/desertislandutils.rb
    # License: MIT

# looking good..
brew install mahiki/tap/desertislandutils

which too
# /opt/homebrew/bin/too
```

TEST: too package tests
```bash
cd ~/trashwork
mkdir brew-tap-test-too && cd brew-tap-test-too

too --help
# PASS

for arg in "big" "data" "doc"; do
    too $arg
    cat << EOF > $arg/testfile.txt
    PASS: your executable is working now
EOF
done

l
# total 0
# lrwxr-xr-x 1 35 Mar 18 13:31 big -> ../../toobig/repo/brew-tap-test-too
# lrwxr-xr-x 1 36 Mar 18 13:31 data -> ../../toodata/repo/brew-tap-test-too
# lrwxr-xr-x 1 35 Mar 18 13:31 doc -> ../../toodoc/repo/brew-tap-test-too

cat */testfile.txt
    # PASS: your executable is working now
    # PASS: your executable is working now
    # PASS: your executable is working now
```

Great!

----------
## EMPATHY
[brew manpage](https://docs.brew.sh/Manpage)

[brew create tap docs](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)

[brew Formula reference](https://rubydoc.brew.sh/Formula)

[**brew docs: Formula defs**](https://docs.brew.sh/Formula-Cookbook)

[blog: create maintain a homebrew tap](https://publishing-project.rivendellweb.net/creating-and-running-your-own-homebrew-tap/)

[example: asciinema python app][asci]

[asci]: https://github.com/asciinema/asciinema

[example: cloudflare tap](https://github.com/cloudflare/homebrew-cloudflare/blob/master/warp.rb)

[example: aws tap](https://github.com/aws/homebrew-aws)

[example: textualize tap with **very simple** Formula][richt]

[richt]: https://github.com/Textualize/homebrew-rich/blob/main/Formula/rich.rb

[example: hashicorp tap](https://github.com/hashicorp/homebrew-tap)

[example: somebody has a github actions tap](https://github.com/m-housh/homebrew-new-tap/blob/main/.github/workflows/publish.yml)

[blog: brew tap binaries](https://jonathanchang.org/blog/maintain-your-own-homebrew-repository-with-binary-bottles/)

[poetry issue: CI practice other than pypi, ie ghcr][pogh]

[pogh]: https://github.com/python-poetry/poetry/issues/366