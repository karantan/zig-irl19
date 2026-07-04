# Training day agenda

**Audience:** Python + Go web developers, no prior Zig  
**Duration:** 7 hours (09:00–17:00)  
**Project:** SiteProbe — URL health-check API + browser UI  
**Zig version:** 0.16.0 only

---

| Time | Block | Format | Materials |
|------|-------|--------|-----------|
| 09:00–09:30 | Why Zig + setup + Hello World | Whole group | [morning-lesson.md](morning-lesson.md) §1 |
| 09:30–10:30 | Memory, errors, slices | Lesson + micro-exercise | §2, [cheat-sheet.md](cheat-sheet.md) |
| 10:30–10:45 | Break | | |
| 10:45–12:00 | Structs, testing, comptime teaser | Lesson + exercise | §3 |
| 12:00–13:00 | Lunch | | |
| 13:00–13:45 | HTTP server + JSON walkthrough | Whole group | §4, starter `src/main.zig` |
| 13:45–16:15 | SiteProbe pair project | Pairs | [pair-tasks.md](pair-tasks.md), [afternoon-guide.md](afternoon-guide.md) |
| 16:15–16:45 | WASM stretch (optional) | Demo / fast pairs | [close-guide.md](close-guide.md) §1 |
| 16:45–17:00 | Demos + retro | Whole group | [close-guide.md](close-guide.md) §2 |

---

## Success criteria (17:00)

- [ ] `zig build run` serves `GET /health` and `POST /probe`
- [ ] `zig build test` passes
- [ ] `web/index.html` probes a live URL
- [ ] Everyone can explain allocators, `try`, and one Zig vs Go difference

## Facilitator prep checklist

- [ ] Everyone ran `devenv shell` from `zig-irl19/` ([install.md](install.md))
- [ ] Starter repo builds: `zig build` OK, `zig build test` 2 pass / 2 fail
- [ ] Solution tested: `devenv shell`, then `cd solution && zig build test && zig build run`
- [ ] Whiteboard: memory diagram (stack / heap / allocator)
- [ ] Whiteboard: [endpoint contract](endpoint-contract.md)
- [ ] Do not share `solution/` until retro

## Key messages

1. Zig feels like Go syntactically; memory is explicit like C
2. No hidden allocations — show the allocator every time
3. Blog posts may be stale — trust this repo + Zig 0.16 docs
4. SiteProbe mirrors real work (HTTP checks like snapshot tooling)
