# meta

A file metadata reader in zig!

# temp

```
zig build -Doptimize=ReleaseSafe

mkdir -p ~/.local/bin
ln -s $(pwd)/zig-out/bin/meta ~/.local/bin/meta
```

# to do

- add colors - x
- Toggle what to display is '-v' using custom config script (.config/meta_)
- display what type of file (text, img, vid)
- work with directories
- img support (resolution)
- vid (know its a video) (know teh playback time) (resolution)
- checksum
- Maybe TUI?
