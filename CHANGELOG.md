# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### 0.5.1 (2026-02-23)


### Features

* --quiet flag to suppress system prompt override warning ([8bfe318](https://github.com/monotykamary/ypi/commit/8bfe318db9972744b65a1f096517e92f82c097d0))
* add CHANGELOG.md, RELEASING.md, update .npmignore and package.json ([370e537](https://github.com/monotykamary/ypi/commit/370e537a3afebb68d5e60353d11e86b7438b435e))
* add check-upstream.prose — upstream compat check as OpenProse program ([81eb915](https://github.com/monotykamary/ypi/commit/81eb915795d3b425d7acee62af4142679f7c66c4))
* add context window awareness to SYSTEM_PROMPT.md ([528ea7e](https://github.com/monotykamary/ypi/commit/528ea7ec1c21698a284931eeddced6ff9aa97132)), closes [#1](https://github.com/monotykamary/ypi/issues/1)
* add fresh_peer tool — lightweight spawn without conversation history ([66ef935](https://github.com/monotykamary/ypi/commit/66ef93566d651e6e110b862a742612951941e350))
* add LSP extension to contrib ([c993899](https://github.com/monotykamary/ypi/commit/c993899beac410e0260791b61ed3690fd195cd9f))
* add make land helper with optional agent audit ([93d2f6c](https://github.com/monotykamary/ypi/commit/93d2f6c77ba01c8890361cbc1c7a29dc3775ff1b))
* add notify-done extension, update AGENTS.md with sentinel pattern for prose programs ([5b159aa](https://github.com/monotykamary/ypi/commit/5b159aa10140b3ae1e9f6d2208ce0c4889d5ce94))
* add one-command release preflight and CI helper chores ([341a7ca](https://github.com/monotykamary/ypi/commit/341a7caed96b0a52bcea1b5e54532d7bf4ee9b2b))
* add package.json, LICENSE, .npmignore for npm publish ([a11a156](https://github.com/monotykamary/ypi/commit/a11a156dacecde4c982f6ec24862a0669b6e8688))
* add release.prose — automated release workflow ([6382b1c](https://github.com/monotykamary/ypi/commit/6382b1c518dad8b6168d52debc8bba540d57f3af))
* add timeout, max calls, model routing, cleanup to rlm_query ([0565846](https://github.com/monotykamary/ypi/commit/0565846c7a8db898c79bab5485b84000516e3072))
* configurable extensions in children, clean up README ([0d4772a](https://github.com/monotykamary/ypi/commit/0d4772a5a174be37831615cc3b2c674afac9e193))
* cost tracking and budget enforcement via JSON mode ([e00bee6](https://github.com/monotykamary/ypi/commit/e00bee6e678ef1abf1da03d44310d7185a0d3cfc))
* embed rlm_query source in system prompt ([7d149ff](https://github.com/monotykamary/ypi/commit/7d149ff9b9f451681c8ac0155f9eaf7d2cbaf788))
* find-the-others extension — discover all active pi/ypi instances ([ddd3867](https://github.com/monotykamary/ypi/commit/ddd3867d14567ce6fbd08d6adc05460e092e7bb1))
* jj workspace isolation for recursive child agents ([7237ede](https://github.com/monotykamary/ypi/commit/7237edea91d784dcde3381311a4c3da36f077a5d))
* land.prose — end-of-session cleanup with compounding reflection ([55c276c](https://github.com/monotykamary/ypi/commit/55c276c7c54b5d9563a526719948323b885dacbd))
* one-line installer script ([60d7f94](https://github.com/monotykamary/ypi/commit/60d7f9447fb0ee704ee07c088d9cbee2e9060ddd))
* persist-system-prompt extension — saves effective system prompt to session files ([6776550](https://github.com/monotykamary/ypi/commit/67765504c4992a3341a775689c806c34dba8f004))
* rewrite system prompt for QA + coding agent dual use ([f5f088d](https://github.com/monotykamary/ypi/commit/f5f088d38974ce77e6afcc9fb94144dd0b482abb))
* rlm_cleanup — manual reaper for stale temp files and jj workspaces ([622cf24](https://github.com/monotykamary/ypi/commit/622cf24f6f0b3b1ff2565d9b8a2b10890fa1ef98))
* rlm_query --async flag with --notify PID ([1ef9efd](https://github.com/monotykamary/ypi/commit/1ef9efd48fa145f53b06976a804614028cbf225d))
* rlm_sessions shared session log reader ([1a8225d](https://github.com/monotykamary/ypi/commit/1a8225d7d9322ca9a46f4ed0f517edd1401d063b))
* session tree — recursive children get persisted sessions ([bc0bbfb](https://github.com/monotykamary/ypi/commit/bc0bbfb4c788e11bed5f8582d314133ffaf86b8a))
* structured errors, graceful exit, execution summary ([c050941](https://github.com/monotykamary/ypi/commit/c05094157249a22a06696b0767c0017d6804022b))
* symbolic access (RLM_PROMPT_FILE), remove hardcoded provider/model, incorporate-insight.prose, land.prose e2e gate, gemini-flash e2e default ([01399c0](https://github.com/monotykamary/ypi/commit/01399c08170ae6c843097c6a8ea36bf21457f1b9))
* timestamps extension — gives agents time awareness ([c8bc23e](https://github.com/monotykamary/ypi/commit/c8bc23ee12a3580281ddda040276b1e38dcf83ac))
* timestamps extension — gives agents time awareness ([896e154](https://github.com/monotykamary/ypi/commit/896e1546b74b50fb18f6a5b98ec6ea77a0291e86))
* unify local/CI quality gates and harden release workflows ([8ba079f](https://github.com/monotykamary/ypi/commit/8ba079f4e591814ace260f663d60f9a791790c5e))


### Bug Fixes

* block broadcast sentinels in notify-done extension ([927a9ac](https://github.com/monotykamary/ypi/commit/927a9ac914632a9f05c634cf1e69d09d9a597d48))
* correct max-depth description — leaf nodes get full tools, just no rlm_query ([4bcdd9a](https://github.com/monotykamary/ypi/commit/4bcdd9af337734bd0d6228db76a8139406033a7e))
* fork_peer and fresh_peer spawn ypi when parent is ypi ([141a49d](https://github.com/monotykamary/ypi/commit/141a49de8efa423db1f2c9fee736e61fce66f434))
* kill orphan parser processes after timeout E2E test, add contrib extensions (colgrep, dirpack, treemap), experiment results ([c641467](https://github.com/monotykamary/ypi/commit/c641467b50ebc550fb0a20d2ca050432690cdd33))
* notify-done extension — use steer for busy agents, display: true, add integration tests ([7316413](https://github.com/monotykamary/ypi/commit/7316413a715f172bc1eb4307dc3f202313575688))
* plug /tmp leak in rlm_query — add reaper + async jj cleanup ([18c8dea](https://github.com/monotykamary/ypi/commit/18c8dea699b7fd0c5cb5504cea164d5dccab8e8e))
* preserve inherited CONTEXT when CI exposes empty stdin pipe ([14ced47](https://github.com/monotykamary/ypi/commit/14ced4773c8f2b44077e9482240cf205c47e0c87))
* re-register pi-mono submodule after history rewrite ([d0b1e78](https://github.com/monotykamary/ypi/commit/d0b1e78a7c6cfca7f255ad9fe4314e41709558ee))
* require YPI_INSTANCE_ID in sentinel filenames, add cross-instance isolation test ([f7bdd5d](https://github.com/monotykamary/ypi/commit/f7bdd5d02c16ced73c8b628b6c9d43436b3e0c19))
* resolve symlinks in SCRIPT_DIR for npm global install ([bbc4cb9](https://github.com/monotykamary/ypi/commit/bbc4cb9bccf22eda59ad0d2e901fa1a2f0186bfc))
* rlm_cleanup empty-list counting bug ([cf53412](https://github.com/monotykamary/ypi/commit/cf534122892e81fe64747d9074cd5af286b8811d))
* self-experiment.prose — concurrent conditions, use Pi session dir ([b3eb33c](https://github.com/monotykamary/ypi/commit/b3eb33c17f36d20edbf27816ea0ca3923a5d5ebb))
* unbound variable errors with empty arrays and Unicode arrow ([83d3682](https://github.com/monotykamary/ypi/commit/83d368257ebaaeeafe00521fc57b90ab7a20fb2b))
* **ypi:** use portable mktemp for BSD/GNU compatibility ([aab4080](https://github.com/monotykamary/ypi/commit/aab4080dad8568a4fbcf472fba0e480e39088e2d))

## [0.5.0] - 2026-02-15

### Added
- **Notify-done extension** (`contrib/extensions/notify-done.ts`): background task completion notifications via sentinel files — injects messages into conversation when tasks finish, no polling needed
- **LSP extension** (`contrib/extensions/lsp/`): Language Server Protocol integration for code intelligence (diagnostics, references, definitions, rename, hover, symbols)
- **Persist-system-prompt extension** (`contrib/extensions/persist-system-prompt.ts`): saves effective system prompt to session files for debugging and reproducibility
- **Auto-title extension** (`contrib/extensions/auto-title.ts`): automatic session title generation
- **Cachebro extension** (`contrib/extensions/cachebro.ts`): intelligent file caching with diff-aware invalidation and token estimation
- **Context window awareness**: SYSTEM_PROMPT.md now teaches agents about finite context budgets and how to manage them
- Tests for notify-done and persist-system-prompt extensions

### Changed
- **AGENTS.md**: added sentinel/notify-done workflow pattern, background task instructions
- **SYSTEM_PROMPT.md**: context window awareness guidance
- **contrib/README.md**: updated with new extensions documentation

### Fixed
- Notify-done extension: block broadcast sentinels, use `steer` for busy agents, `display: true` for visibility

## [0.4.0] - 2026-02-13

### Added
- **`rlm_sessions` command**: inspect, read, and search session logs from sibling and parent agents in the recursive tree (`rlm_sessions --trace`, `rlm_sessions read <file>`, `rlm_sessions grep <pattern>`)
- **Symbolic prompt access** (`RLM_PROMPT_FILE`): agents can grep/sed the original prompt as a file instead of copying tokens from context memory
- **Contrib extensions**: `colgrep.ts` (semantic code search via ColBERT), `dirpack.ts` (repository index), `treemap.ts` (visual tree maps) — opt-in extensions in `contrib/extensions/`
- **Encryption workflow**: `scripts/encrypt-prose` and `scripts/decrypt-prose` for sops/age encryption of private execution state before pushing
- **`.sops.yaml`**: age encryption rules for `.prose/runs/`, `.prose/agents/`, `experiments/`, `private/`
- **`.githooks/pre-commit`**: safety net blocking unencrypted private files on direct git push
- **OpenProse programs**: `release.prose`, `land.prose`, `incorporate-insight.prose`, `recursive-development.prose`, `self-experiment.prose`, `check-upstream.prose`
- **Experiment infrastructure**: `experiments/` directory with pipe-vs-filename, session-sharing, and tree-awareness experiments with results
- E2E tests: expanded coverage (+90 lines), gemini-flash as default e2e model
- Guardrail tests: `rlm_sessions` tests (G48-G51), session sharing toggle
- Unit tests: `RLM_PROMPT_FILE` tests (T14d)

### Changed
- **SYSTEM_PROMPT.md**: added symbolic access principle (SECTION 2), refined depth awareness guidance
- **AGENTS.md**: expanded with experiment workflow (tmux rules), self-experimentation, session history reading, OpenProse program references
- **README.md**: updated feature list and project description
- Removed hardcoded provider/model defaults from `rlm_query` — inherits from environment only

### Fixed
- Kill orphan `rlm_parse_json` processes after timeout in E2E tests
- Contrib extension GitHub links (dirpack, colgrep) now point to correct URLs

## [0.3.0] - 2026-02-13

### Added
- **ypi status extension** (`extensions/ypi.ts`): shows `ypi ∞ depth 0/3` in footer status bar and sets terminal title to "ypi" — visual indicator that this is recursive Pi, not vanilla
- **CI workflows**: GitHub Actions for push/PR testing and upstream Pi compatibility checks every 6 hours
- **`scripts/check-upstream`**: local script to test ypi against latest Pi version — no GitHub required
- **`tests/test_extensions.sh`**: verifies `.ts` extensions load cleanly with installed Pi
- **`.pi-version`**: tracks last known-good Pi version for compatibility monitoring
- `make test-extensions` and `make check-upstream` targets

### Changed
- Removed hardcoded hashline extension from `ypi` launcher — user's own Pi extensions (installed at `~/.pi/agent/extensions/`) are discovered automatically by Pi
- Removed `RLM_HASHLINE` environment variable (no longer needed)

## [0.2.1] - 2026-02-13

### Fixed
- Skip bundled `hashline.ts` extension when the global install (`~/.pi/agent/extensions/hashline.ts`) exists, fixing "Tool read/edit conflicts" error

## [0.2.0] - 2026-02-12

### Added
- **Cost tracking**: children default to `--mode json`, parsed by `rlm_parse_json` for structured cost/token data
- **Budget enforcement**: `RLM_BUDGET=0.50` caps dollar spend for entire recursive tree
- **`rlm_cost` command**: agent can query cumulative spend at any time (`rlm_cost` or `rlm_cost --json`)
- **`rlm_parse_json`**: streams text to stdout, captures cost via fd 3 to shared cost file
- System prompt updated with cost awareness (SECTION 4 teaches `rlm_cost`)
- `rlm_query` source embedded in system prompt (SECTION 6) so agents understand their own infrastructure

### Changed
- **Uniform children**: removed separate leaf path — all depths get full tools, extensions, sessions, jj workspaces
- **Extensions on by default** at all depths (`RLM_EXTENSIONS=1`)
- **`RLM_CHILD_EXTENSIONS`**: per-instance extension override for depth > 0
- Recursion limited by removing `rlm_query` from PATH at max depth (not `--no-tools`)
- `RLM_JSON=0` opt-out for plain text mode (disables cost tracking)

### Removed
- Separate leaf code path (`--no-tools`, `--no-extensions`, `--no-session` at max depth)
- sops/age/gitleaks references from README and install.sh (internal only)

## [0.1.0] - 2026-02-12

Initial release.

### Added
- `ypi` launcher — starts Pi as a recursive coding agent
- `rlm_query` — bash recursive sub-call function (analog of Python RLM's `llm_query()`)
- `SYSTEM_PROMPT.md` — teaches the LLM to use recursion + bash for divide-and-conquer
- Guardrails: timeout (`RLM_TIMEOUT`), call limits (`RLM_MAX_CALLS`), depth limits (`RLM_MAX_DEPTH`)
- Model routing: `RLM_CHILD_MODEL` / `RLM_CHILD_PROVIDER` for cheaper sub-calls
- jj workspace isolation for recursive children (`RLM_JJ`)
- Session forking and trace logging (`PI_TRACE_FILE`, `RLM_TRACE_ID`)
- Pi extensions support (`RLM_EXTENSIONS`, `RLM_CHILD_EXTENSIONS`)
- `install.sh` for curl-pipe-bash installation
- npm package with `ypi` and `rlm_query` as global CLI commands
