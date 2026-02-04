# Mahiki Homebrew Tap

A personal tap for distributing CLI tools via Homebrew.

## desertislandutils

A collection of personal convenience utilities for managing parallel directory structures and ISO week numbers.

**Build:** UV-managed Python project  
**Deploy:** PyPI (primary) + Homebrew (alternative)  
**CI/CD:** GitHub Actions → Test → Tag → PyPI + Homebrew release

### Links

- [GitHub Repository](https://github.com/mahiki/desertislandutils)
- [GitHub Releases](https://github.com/mahiki/desertislandutils/releases)
- [PyPI Package](https://pypi.org/project/desertislandutils/)

## Installation

### Recommended: Install from PyPI

```bash
uv tool install desertislandutils
```

This is the preferred installation method for Python CLI tools.

### Alternative: Install via Homebrew

```bash
brew install mahiki/tap/desertislandutils
```

```bash
# or tap first, then install
brew tap mahiki/tap
brew install desertislandutils
```

## Usage

Once installed, two commands are available:

```bash
# ISO week number utility
wn --help

# Parallel directory manager (toobig/toodata/toodoc)
too --help
```

## Documentation

For Homebrew usage: `brew help`, `man brew`, or [Homebrew's documentation](https://docs.brew.sh).

For desertislandutils: See the [project README](https://github.com/mahiki/desertislandutils/blob/main/README.md).