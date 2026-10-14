# Releasing

This repository follows three release streams: **Dev → Candidate → Stable**.

## Streams

| Stream | What it is | Version |
| --- | --- | --- |
| **Dev** | Every merge to `main` | No tag |
| **Candidate** | A tag on `main`, published as a GitHub **pre-release** | `vX.Y.Z-rc.N` |
| **Stable** | A tag on the **same commit** as the accepted candidate. The release workflow creates a **draft** GitHub Release, and the owner publishes it | `vX.Y.Z` |

## Version source

`VERSION` holds the **next release's base version**, `X.Y.Z`. Versions follow [Semantic Versioning](https://semver.org):

- **MAJOR:** breaking changes;
- **MINOR:** new content or capability;
- **PATCH:** fixes only.

## Cutting a release

1. **Prepare.** Open a PR titled `release: X.Y.Z`. In `CHANGELOG.md`, move the entries under `## [Unreleased]` into a new `## [X.Y.Z]` section, and leave an empty `## [Unreleased]` above it. Merge it.
2. **Candidate.** Tag the merge commit and push the tag:

   ```bash
   git tag -a vX.Y.Z-rc.1 -m "vX.Y.Z-rc.1"
   ```

   ```bash
   git push origin vX.Y.Z-rc.1
   ```

   The `release` workflow checks that the tag matches `VERSION`, that `CHANGELOG.md` has the section and that the commit is on `main`. It then creates a pre-release.
3. **Accept.** Review the pre-release. If it needs changes, fix them on `main` and cut `-rc.2`.
4. **Stable.** Tag the **same commit** `vX.Y.Z` and push it. The workflow creates a **draft** release, and the owner publishes it.
5. **Next.** Open a PR that bumps `VERSION` to the next base version.

To validate a tag name without creating anything, run the `release` workflow by hand (Actions → release → Run workflow).

## Rules

- **Tags are immutable.** A `v*` tag is never moved or deleted. A bad release is fixed by the next patch.
- **Every change goes through a PR.** `main` is protected and requires the `release-checks` status check.
- **Every PR updates `CHANGELOG.md` under `[Unreleased]`**, or carries the label `changelog:skip` with a reason.
- **Fixes land on `main`.** A `release/X.Y` branch is created only if an older version needs a patch.
- **Support:** only the newest release.

The rulesets that enforce these rules are in `.github/rulesets/`.
