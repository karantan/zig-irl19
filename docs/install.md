# Installing Zig 0.16.0

Pin **exactly** this version for the training day. HTTP APIs changed in 0.15+; older blog posts will mislead you.

Everyone on the team uses Nix — we use **[devenv](https://devenv.sh/)** so Zig lands on your `PATH` automatically when you enter the project directory.

## One-time setup

Install [devenv](https://devenv.sh/getting-started/) if you do not have it yet:

```bash
devenv --version
```

Optional but recommended: enable [auto-activation on `cd`](https://devenv.sh/auto-activation/) so you never forget to enter the shell:

```bash
eval "$(devenv hook zsh)"   # or bash / fish / nu
```

## Enter the environment

From the repo root:

```bash
cd zig-irl19
devenv shell
```

First run downloads the toolchain (may take a minute). You should see:

```text
SiteProbe Zig training day
  zig version: 0.16.0
  ...
```

## Verify

```bash
zig version
# 0.16.0
```

## Pre-flight check

Inside `devenv shell`, from `zig-irl19/`:

```bash
zig build test    # starter: 2 pass, 2 fail (expected)
zig build run     # in another terminal (also in devenv shell):
curl http://127.0.0.1:8080/health
# {"status":"ok"}
```

The `solution/` subdirectory uses the same environment — stay in `devenv shell` and `cd solution` as needed.

## How it works

[`devenv.nix`](../devenv.nix) enables the Zig language module:

```nix
languages.zig = {
  enable = true;
  version = "0.16.0";
};
```

See [devenv Zig language docs](https://devenv.sh/languages/zig/) for details.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `command not found: devenv` | Install from [devenv.sh/getting-started](https://devenv.sh/getting-started/) |
| `command not found: zig` | Run `devenv shell` from `zig-irl19/` (or enable auto-activation) |
| Wrong Zig version | Delete `.devenv/` and re-run `devenv shell` to rebuild |
| Port 8080 in use | Stop other services or change port in `src/main.zig` |
| Copied HTTP code from old tutorial | Use this repo's skeleton; see [0.15.1 HTTP release notes](https://ziglang.org/download/0.15.1/release-notes.html) |

## Optional reading (send before the day)

- [Zig Learn — Chapter 0](https://ziglearn.org/chapter-0/) (skim)
- [Zig Cookbook — HTTP server](https://cookbook.ziglang.cc/05-03-http-server-std/)
