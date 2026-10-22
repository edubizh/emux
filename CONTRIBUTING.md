# Contributing to emux

emux is a curated tmux keybinding "distro." The **keybindings are the product**,
so the bar is: changes are deliberate, tested in a live tmux session, and never
break someone's muscle memory by accident. These rules keep it that way — and
keep the version number honest.

## Commit messages — [Conventional Commits](https://www.conventionalcommits.org)

```
<type>(<optional scope>): <summary in the imperative>
```

| Type | Use for | Version effect |
|------|---------|----------------|
| `feat` | a new binding or capability | → **minor** |
| `fix` | a bug in existing behavior | → **patch** |
| `docs` | README / docs only | none |
| `refactor` | internal change, same behavior | none |
| `chore` | tooling, meta, repo plumbing | none |
| `feat!` / `fix!` or a `BREAKING CHANGE:` footer | changes or removes an existing binding | → **major** |

Keep each commit to one logical change. We append a trailer crediting any
pair/assistant on the commit; that's convention, not a requirement.

## Branches

- `main` is always releasable and is **protected** — no direct pushes.
- Do work on a short-lived branch named `type/short-description`, e.g.
  `feat/zoom-toggle`, `fix/cycle-single-pane`, `docs/readme-badges`.
- One branch = one focused change. Delete it after merge.

## Pull requests

- Every change reaches `main` through a PR. Open it against `main`.
- Say **what** changed and **why**; note if any existing binding changed.
- Test the change in a real tmux session before marking it ready.
- PRs are **squash-merged**, so the PR title becomes the commit — make it a
  valid Conventional Commit.

## Versioning — [SemVer](https://semver.org), and how to not spam it

The version is `MAJOR.MINOR.PATCH`. For emux, read against the **set of
keybindings**:

- **MAJOR** — a binding is removed, renamed, or now does something different
  (breaks muscle memory), or supported tmux versions drop.
- **MINOR** — a new binding/feature is added; everything old still works.
- **PATCH** — a bug fix or docs tweak that doesn't change the binding set
  (e.g. making the clockwise cycle stuck-proof).

**The anti-spam rule:** a version is **not** bumped per commit or per PR.
Merged PRs pile up under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md). A
release is a separate, deliberate act. When you cut one, the bump level is the
**highest-impact change since the last tag** — any breaking change ⇒ major, else
any `feat` ⇒ minor, else patch. If nothing user-facing changed, don't release.

## Cutting a release

1. Decide the new version from the `[Unreleased]` entries (rule above).
2. In `CHANGELOG.md`, move `[Unreleased]` items under a new `## [X.Y.Z] - DATE`.
3. Merge that via PR.
4. Tag it on `main`:
   ```sh
   git tag -a vX.Y.Z -m "emux vX.Y.Z"
   git push origin vX.Y.Z
   ```
5. Publish a GitHub Release from the tag using the changelog section as notes.

Tags are the contract: TPM users can pin `set -g @plugin 'edubizh/emux#vX.Y.Z'`
to freeze a known-good set of bindings.
