# Homebrew Dev Log

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

### ChatGPT says try `brew-pypi-poet`
```sh
brew install brew-pypi-poet
poet mypackage > MyPackage.rb