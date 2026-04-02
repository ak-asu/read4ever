# Read4ever — Product Requirements

## Problem Statement

Self-taught developers and students collect online learning resources compulsively but rarely finish them — because saving a link and actually working through it are two entirely different habits. Without structure or progress tracking, learning material stays in a browser tab graveyard: no context between sessions, no sense of forward movement, no way to find notes or highlights after the fact. Read4ever replaces the browser + Notion patchwork with a single tool that handles import, reading, annotation, and progress tracking in one calm, well-made interface.

---

## User Stories

### Epic: Importing Resources

- As a developer starting a new topic, I want to share a documentation URL directly from Chrome so that it opens in Read4ever pre-filled and ready to configure.
  - [ ] Sharing a URL from Chrome opens the app with the URL pre-populated in the import dialog
  - [ ] If the URL already exists as a resource or chapter in the library, the app opens that resource/chapter directly instead of starting an import
  - [ ] The URL is validated before any fetch is attempted

- As a developer importing a multi-page docs site, I want to see all available chapters and choose which ones to import so that I'm not forced to take the whole site.
  - [ ] If a sitemap is detected, the app shows an import dialog with a checkbox tree of available chapters, all selected by default
  - [ ] The user can select/deselect individual chapters; at least one chapter must remain selected
  - [ ] Tapping "Advanced" expands the dialog to allow: reordering chapters, editing the resource name (auto-derived from page metadata), adding a resource description
  - [ ] In simple mode, resource name is auto-derived and not visible — it's only editable in advanced mode
  - [ ] Tapping confirm imports the selected chapters and opens the shared URL in the reader

- As a developer importing a standalone article, I want it to be imported automatically so that I don't have to configure anything for a single page.
  - [ ] A standalone page shows the same import dialog, but with a single chapter pre-selected
  - [ ] At least one chapter must remain selected (cannot deselect the only chapter)
  - [ ] After confirm, the user is taken directly to the reader for that page
  - [ ] If the URL already exists as a chapter in another resource, the app opens that chapter instead

- As a developer adding a resource from within the app, I want a clearly visible way to add a resource without leaving to Chrome so that I can import from any URL I have at hand.
  - [ ] A FAB in the bottom right of the Library screen opens a URL input field
  - [ ] Submitting the URL triggers the same detection and import flow as the share sheet
  - [ ] On first launch with an empty library, the screen shows an empty-state prompt pointing the user to import their first resource

- As a developer managing an existing resource, I want duplicate detection so that importing a URL I already have doesn't create confusion.
  - [ ] If a shared/entered URL matches an existing chapter, the app opens that chapter rather than re-importing
  - [ ] If a URL matches an existing resource (sitemap root), the app opens that resource's detail page

---

### Epic: Reading

- As a developer reading a chapter, I want a full-screen WebView reader with minimal chrome so that the content is front and center.
  - [ ] The reader opens the chapter URL in a full-screen WebView
  - [ ] A toolbar is visible (always or on scroll/tap) containing: back, chapter dropdown, bookmark toggle, done toggle
  - [ ] Tapping back returns to wherever the user came from (library, bookmarks, etc.)

- As a developer navigating a multi-chapter resource, I want a chapter dropdown in the reader so that I can jump to any chapter without leaving the reader.
  - [ ] Tapping the chapter dropdown shows the full chapter list for the current resource
  - [ ] Each chapter entry shows its title and a trailing checkmark if it has been marked done
  - [ ] Tapping a chapter navigates to it directly in the reader

- As a developer finishing a chapter, I want to mark it done from the reader so that my progress is recorded immediately.
  - [ ] The done toggle in the toolbar marks the current chapter as done
  - [ ] Tapping it again un-marks the chapter as done
  - [ ] When all chapters in a resource are marked done, the resource status automatically updates to Done
  - [ ] The done toggle visually reflects the current done/not-done state of the chapter

- As a developer who resumes reading, I want the app to open the last chapter I was reading so that I pick up exactly where I left off.
  - [ ] Resume (from Library card or Continue Reading strip) opens the last chapter the user had open for that resource
  - [ ] If the app is backgrounded and resumed, scroll position is retained in memory
  - [ ] If the app is fully closed and reopened, the chapter opens at the top

- As a developer reading a page that fails to load, I want a clear error state so that I know what happened and can retry.
  - [ ] If the WebView fails to load (offline, dead URL, etc.), the reader shows an error state
  - [ ] The error state includes a retry button that attempts to reload the page

---

### Epic: Highlighting and Notes

- As a developer reading, I want to highlight text and optionally attach a note so that I can capture what's important while I'm in context.
  - [ ] Selecting text in the reader surfaces a floating toolbar with two options: Highlight and Note
  - [ ] Tapping Highlight saves the selection as a highlight with no note
  - [ ] Tapping Note saves the selection as a highlight and opens a text input for the note
  - [ ] Saved highlights are visually marked in the WebView

- As a developer reviewing my annotations, I want to edit or delete a highlight and its note later so that I can refine my notes after the fact.
  - [ ] Tapping a highlight in the Highlights screen opens a bottom sheet
  - [ ] The bottom sheet includes: delete, resource/chapter info, navigate to position in reader
  - [ ] From that sheet, the user can edit the attached note or remove it

---

### Epic: Library

- As a developer managing my library, I want to see all my resources in one place with clear progress indicators so that I can tell at a glance what's in progress and what's done.
  - [ ] The Library screen lists all imported resources as cards
  - [ ] Each resource card shows: title, description (ellipsis clipped), chapter count, progress bar, and a Resume button
  - [ ] Tapping the card body opens the Resource Detail screen
  - [ ] Tapping Resume opens the last chapter the user had open for that resource

- As a developer with in-progress work, I want a Continue Reading strip at the top of the library so that I can jump back in without scrolling.
  - [ ] The Continue Reading strip shows up to 3 in-progress resources
  - [ ] Each entry shows the resource title only
  - [ ] Tapping an entry opens the last chapter the user had open

- As a developer organizing resources, I want to add tags to a resource so that I can group related material.
  - [ ] Tags can be added on the Resource Detail screen
  - [ ] Typing in the tag field shows autocomplete suggestions from previously created tags
  - [ ] The user can select an existing tag or type a new one to create it
  - [ ] Tags are displayed on the resource — no filtering UI in the MVP

---

### Epic: Resource Management

- As a developer managing a resource, I want a dedicated detail screen where I can configure everything about it so that I don't have to go to different places for different settings.
  - [ ] The Resource Detail screen includes: resource name (editable), description (editable), tags, chapter list, track assignment
  - [ ] Chapters can be reordered via drag
  - [ ] Individual chapters can be deleted
  - [ ] Additional chapters can be imported from the original source (for docs resources where not all pages were selected initially)
  - [ ] The entire resource can be deleted with a confirmation dialog

- As a developer deleting a resource, I want a clear confirmation that tells me what will be lost so that I don't accidentally delete annotations.
  - [ ] The delete confirmation dialog lists the number of highlights and bookmarks that will be permanently deleted
  - [ ] Confirming the deletion cascade-deletes all associated chapters, highlights, and bookmarks

- As a developer managing lists of items (chapters, resources, bookmarks, highlights), I want to bulk-select and delete so that I can clean up efficiently.
  - [ ] Long-pressing any list item enters multi-select mode
  - [ ] In multi-select mode: select all, deselect all, and bulk delete are available
  - [ ] Bulk delete shows a confirmation before executing

---

### Epic: Highlights Screen

- As a developer reviewing all my annotations, I want a dedicated Highlights screen that shows every highlight across all resources so that I can use them as a study reference.
  - [ ] The Highlights screen lists all highlights across all resources
  - [ ] Each entry shows the highlighted text, truncated by default
  - [ ] Double-tapping an entry expands/collapses the full highlighted text
  - [ ] The list can be filtered by resource or by chapter
  - [ ] Tapping an entry opens a bottom sheet with: delete, resource/chapter info, navigate to position in reader
  - [ ] Long-pressing enters multi-select mode (bulk delete + select/deselect all)

---

### Epic: Bookmarks Screen

- As a developer curating chapters I want to return to, I want a Bookmarks screen that acts as a quick-access reading queue.
  - [ ] Tapping the bookmark icon in the reader toolbar toggles the bookmark on/off for that chapter
  - [ ] The Bookmarks screen lists all bookmarked chapters
  - [ ] Tapping a bookmarked chapter opens it in the reader
  - [ ] When reading a chapter opened from Bookmarks, two floating action buttons (prev/next) appear, navigating to the previous/next bookmarked chapter in the list
  - [ ] Long-pressing enters multi-select mode (bulk delete + select/deselect all)

---

### Epic: Settings

- As a developer using the app in different lighting conditions, I want to control the app theme so that I can reduce eye strain.
  - [ ] Settings screen includes a theme selector: Light, Dark, System
  - [ ] The selection persists across app restarts

- As a developer who wants a clean slate, I want to delete all app data from Settings so that I can reset without uninstalling.
  - [ ] Settings includes a "Delete all data" option
  - [ ] Tapping it shows a confirmation dialog warning that all resources, highlights, and bookmarks will be permanently deleted
  - [ ] Confirming wipes all local data and returns the app to the first-run empty state

---

## What We're Building

The complete MVP is a working Android app covering:

1. **Share-sheet and in-app import** — URL sharing from Chrome and FAB-initiated import; sitemap detection with two-mode dialog (simple/advanced); standalone import with same dialog; duplicate detection; URL validation; sitemap fetch failure falls back to single-chapter with user notification; all non-docs URLs fall back to single-chapter
2. **Library screen** — Resource cards (title, clipped description, chapter count, progress bar, Resume); Continue Reading strip (last 3 in-progress, title only); FAB for adding resources; empty-state first-run prompt; done resources show 100% progress bar, sink to bottom of list with muted color
3. **Resource Detail screen** — Full resource management: edit name/description/tags, reorder/delete chapters, import additional chapters, delete resource with cascade confirmation
4. **Reader** — Full-screen WebView; toolbar with back, chapter dropdown (with done checkmarks), bookmark toggle, done toggle; error state with retry; scroll position retained in memory, cleared on full close
5. **Highlighting** — Text selection → floating toolbar (Highlight / Note); highlights visually marked in WebView; XPath-based position storage; edit/delete from Highlights screen
6. **Highlights screen** — All highlights across app; filter by resource or chapter; double-tap expand; bottom sheet with delete/info/navigate; multi-select bulk delete
7. **Bookmarks screen** — All bookmarked chapters; prev/next FAB navigation when reading from Bookmarks; multi-select bulk delete
8. **Tags** — Free-text tags on resources with autocomplete; displayed as metadata; no filter UI
9. **Drawer navigation** — 4 items: Library, Bookmarks, Highlights, Settings
10. **Settings** — Light/Dark/System theme toggle; delete all app data with confirmation

---

## What We'd Add With More Time

- **Tag filtering on Library screen** — A dropdown filter (or bottom sheet) to the right of a future search bar; filter the resource list by one or more tags
- **Search** — Full-text search across resource titles and chapter titles; low priority since the library is small early on
- **Scroll position persistence** — Save the exact scroll position of each chapter to the database so the user resumes mid-page even after fully closing the app
- **Export (JSON + Markdown)** — Export all resources, chapters, highlights, and notes for portability and backup
- **Import from JSON** — Restore a previously exported dataset
- **PDF support** — Render local or remote PDFs in the reader; minimal additional logic needed
- **AI features** — Summarization, Q&A over highlights, smart tagging; explicitly a separate phase
- **Additional import types** — GitHub READMEs, RSS feeds, or other structured web content beyond sitemap-based docs sites

---

## Non-Goals

- **YouTube playlist import** — Requires scraping `__ytInitialData`; fragile, breaks on DOM changes, ~3 days for a brittle dependency
- **Streak counter / gamification** — Doesn't deepen the learning loop; adds complexity for low value
- **User accounts / cloud sync** — App is intentionally local-first; no backend, no sync in this phase
- **Social or sharing features** — Tags, notifications, multi-reader tabs, shared tracks — all out of scope
- **AI features in this build** — No stubs, no body_text storage; AI is a separate future phase

---

## Open Questions

- **Highlight rendering in WebView** — XPath-based position storage is the plan. Behavior when a page's DOM changes after a highlight is saved (e.g., docs site updates) needs definition. *Can wait until build.*

---

## Resolved During PRD

- **Sitemap detection fallback** — If sitemap fetch fails or returns nothing useful, the app shows a brief notification ("couldn't extract other chapters") and falls back to single-chapter import. User is informed but not blocked.
- **Additional import types** — No special handling beyond docs sites (sitemap detected) and standalone pages. MDN, GitHub, and all other URLs fall back to single-chapter import. Two types are sufficient for MVP.
- **Done resource visual treatment** — A fully-done resource shows 100% on its progress bar, moves to the bottom of the Library list, and receives a slightly muted/disabled color treatment. No badge or separate section needed.
