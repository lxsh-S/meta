# meta

# Overview

Meta is a small command line utility also known as CLI written in zig. A file metadata reader!

# Design choises and goals

`meta` is a really small project I have worked on for learning the basics of `zig`

# How does it work?

A file's metadata is read by `meta` and then:

- It retrieves data such as file permissions, size, timestamps and for file identification it reads the magic bytes

- When verbose`-v` mode is enabled, meta reads the given files contents to calculate its checksum

# installtion

Git clone the repo

```
git clone https://github.com/lxsh-S/meta.git
cd meta/
```

build

```
zig build -Doptimize=ReleaseSafe
```

Add to path in your terminal (so that it works like a proper CLI)

```
mkdir -p ~/.local/bin
ln -s $(pwd)/zig-out/bin/meta ~/.local/bin/meta
```

and dont forget to crosscheck that `~/.local/bin/` is in your included path

THANKS FOR VISITING!
