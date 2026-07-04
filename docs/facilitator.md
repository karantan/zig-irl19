# Facilitator guide — solution branch

Participants clone **`main`** only. The reference implementation lives on branch **`solution/siteprobe`** — do not share the branch name until the retro.

## Pre-flight (before training day)

From your facilitator clone:

```bash
git fetch origin solution/siteprobe
git worktree add ../zig-irl19-solution solution/siteprobe
cd ../zig-irl19-solution
devenv shell
cd solution
zig build test && zig build run
```

Use the worktree for demos and debugging during the day. Participants stay on `main` in their own clones.

### Without worktree

```bash
git fetch origin solution/siteprobe
git checkout solution/siteprobe
cd solution
devenv shell
zig build test && zig build run
git checkout main   # when done — do not leave participants' machines on this branch
```

## Revealing the solution (16:45 retro)

Option A — show your worktree or a live diff:

```bash
git diff main..solution/siteprobe -- src/ web/ wasm/
```

Option B — let participants merge after retro:

```bash
git fetch origin solution/siteprobe
git merge origin/solution/siteprobe
cd solution
zig build test && zig build run
```

Option C — publish `solution/` on `main` after the day:

```bash
git checkout main
git merge solution/siteprobe
git push origin main
```

## Branch layout

| Branch | Audience | Contents |
|--------|----------|----------|
| `main` | Participants | Starter skeleton, docs, no answer key |
| `solution/siteprobe` | Facilitators | Same + `solution/` reference implementation |

## Push both branches

After updating the repo locally:

```bash
git push -u origin main
git push -u origin solution/siteprobe
```

Participants only need `git clone` / `git pull` on `main`.
