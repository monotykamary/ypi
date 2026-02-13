# contrib/

Community and optional extensions. **Nothing here is required to use ypi.**

ypi is a recursive Pi launcher — it doesn't bundle or manage Pi extensions.
Pi's own auto-discovery (`~/.pi/agent/extensions/`) handles extension loading
for both interactive sessions and rlm_query children.

## Extensions

These are Pi extensions we find useful alongside ypi. Install any you like
by symlinking into your Pi extensions directory:

```bash
ln -s "$(pwd)/contrib/extensions/hashline.ts" ~/.pi/agent/extensions/hashline.ts
```

### hashline.ts

Line-addressed editing with content hashes. Overrides Pi's `read` and `edit`
tools so every line is tagged `LINE:HASH|CONTENT`. Edits reference hashes
instead of requiring exact text match, catching stale-file errors before
they corrupt anything.

Ported from [oh-my-pi](https://github.com/can1357/oh-my-pi) by can1357.

**To uninstall:** `rm ~/.pi/agent/extensions/hashline.ts`
