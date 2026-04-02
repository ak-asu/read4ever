# Read4ever

## Idea
A mobile-first Android app that turns scattered online resources — docs, guides, tutorials — into structured, trackable learning units: save a link, organize it into a track, read it in-app, highlight what matters, and always know exactly where you are and what you've completed.

## Who It's For
Self-taught developers, students, and upskilling professionals who learn from open web resources (documentation, guides, tutorials) but struggle to actually finish material, maintain context across sessions, and track what they've covered. The user is serious but overloaded — they're good at collecting links, bad at completing them. They want to move from "I saved it" to "I finished it, understood it, and can return to my notes."

## Inspiration & References

**Competitive landscape:**
- [Readwise Reader](https://readwise.io/read) — gold standard for reading + annotation UX; lacks learning path structure and topic-level progress
- [Matter](https://hq.getmatter.com) — clean mobile-first reading, intentional queue concept; no curriculum structure
- [Notion](https://notion.so) — best DIY approximation of a learning tracker; weak reading experience, no native progress tracking
- [PathCurator](https://pathcurator.com) — proof of demand for structured learning paths over external links; web-only, no reading or annotation

**Design references:**
- [NotebookLM](https://notebooklm.google.com) — primary design quality target: smooth, minimal, calm, easy on eyes for long-term usage, feels like an intelligent tool without being corporate or cold
- [Notion](https://notion.so) — simplicity and structural clarity as UX north star
- [Medium](https://medium.com) — reading clarity as a principle: smooth, distraction-free, not dull

**Design energy:**
The app is a shell around a WebView reader — the actual reading content is the webpage as-is. What gets designed is everything outside the reader: Library, Tracks, Resource Detail, Highlights, Bookmarks, Import screens, toolbar overlay. Direction: NotebookLM-quality — calm, minimal, precise, easy on the eyes. Clean sans-serif typography. Cooler, more restrained palette rather than warm terracotta/editorial serif. Not loud, not playful, not corporate. A serious daily tool that a developer would find beautiful.

## Goals
1. Make completing online learning material feel like forward momentum, not a backlog
2. Build a UI that feels genuinely crafted — non-generic, intentional, NotebookLM-quality — not AI-slop or generic Material
3. Master spec-driven development end-to-end as a methodology
4. Ship a complete, working Android app where every feature in scope is polished, not half-finished

## What "Done" Looks Like
A working Android app where a user can:
- Share any URL from Chrome → app opens with it pre-filled in the import screen
- Import a docs site (sitemap tree UI: select pages, reorder, confirm) or fall back to a single-chapter resource automatically
- Open any chapter in a full-screen WebView reader with a custom toolbar (back, chapter dropdown, bookmark, note, done toggle)
- Select text in the reader → floating toolbar → highlight saved; or add a note to the highlight
- Mark chapters done; resource auto-promotes to Done when all chapters complete
- Organize resources into named, colored Tracks with visible progress bars
- View all highlights across the app (filterable); view all bookmarked chapters
- See a "Continue Reading" strip on the Library home screen (last 3 in-progress resources)
- Toggle light/dark/system theme from Settings

The finished app looks and feels like a tool a developer would choose over their current browser + Notion patchwork — calm, fast, and clearly well-made.

## What's Explicitly Cut

| Feature | Rationale |
|---|---|
| YouTube playlist import | Fragile `__ytInitialData` scraping; breaks on YouTube DOM changes; ~3 days of work for a brittle dependency |
| Export (JSON + Markdown) | Important for data ownership but not part of the core learning experience; v2 |
| Import from JSON | Same — v2 |
| Streak counter | Gamification that doesn't deepen the learning loop; adds complexity for low value |
| Search | Lowest-priority feature; library too small early on to justify it |
| Filter by status + Sort options | Same reason; visual scanning works fine at small scale |
| PDF support | Trivial to add later; no dedicated logic needed |
| AI features | Explicitly deferred to a separate phase; no stubs, no body_text storage |
| Tags, notifications, multi-reader tabs | Out of scope entirely |

## Loose Implementation Notes
- Android only, local-first — Drift (SQLite ORM), no backend, no sync
- Flutter + Riverpod (riverpod_annotation codegen) + go_router
- Reader = WebView (webview_flutter) with JS injection for highlight capture; XPath-based position storage
- Smart import: attempt sitemap.xml discovery → checkbox tree UI if multiple pages found; fallback to single-chapter resource silently
- Data hierarchy: Track → Resource → Chapter; highlights belong to resource + optional chapter
- Drawer navigation (5 items: Library, Tracks, Bookmarks, Highlights, Settings) with ShellRoute
- Design system to be defined in /spec — revisit typography and color direction, moving away from Playfair Display + terracotta toward something cleaner and NotebookLM-adjacent
