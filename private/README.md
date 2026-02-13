# Private

Files here are encrypted with [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age).

```bash
sops decrypt private/notes.md    # decrypt to stdout
sops private/notes.md            # edit in-place
sops encrypt -i private/new.json # encrypt a new file
```
