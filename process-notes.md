# Process Notes

## /onboard

**Technical experience:** Experienced Flutter developer, shipped multiple Android apps. Also strong in full stack and AI engineering. Treat as a senior peer throughout.

**Learning goals:** Master SDD methodology; build a non-slop AI app. The "non-slop" framing is his — keep it as a north star throughout the build phase.

**Creative sensibility:** Limited design background, self-aware about it. Has strong language for what good UX feels like but no specific aesthetic references. Default to clean/functional. Frame design decisions around user outcome.

**Prior SDD experience:** Informal — already creates a docs folder with research markdown files before building. Understands the value; this curriculum formalizes and extends his existing habit.

**Energy/engagement:** Arrived with a fully-formed, clearly-articulated product idea. High signal-to-noise from the start. Will likely move fast through scope and planning — be ready to match pace.

## /scope

**Idea evolution:** Arrived with a fully-formed concept and both a detailed research doc and a near-complete MVP plan. Scope conversation was less about discovery and more about calibration — confirming the core concept, sharpening design direction, and drawing the MVP line.

**Pushback received:**
- Challenged on "non-slop AI app" goal vs. no AI in plan → clarified he means UI craft quality, not AI features; wants UI that looks human-designed, not generated
- Challenged on Duolingo as design reference → agreed it doesn't translate to a reading app; dropped it
- Challenged on Playfair Display + warm terracotta direction → acknowledged it's not final; open to revisiting in /spec
- Proposed cutting YouTube import, export/import, streak, search, filters → accepted all cuts without pushback

**References that resonated:** NotebookLM (primary design quality target — smooth, minimal, calm, intelligent-tool aesthetic); Notion (simplicity); Medium (reading clarity). NotebookLM was unprompted and the strongest signal about his aesthetic sensibility.

**Key clarification:** The app is a shell around a WebView reader — the reading content itself isn't styled by the app. Design applies to Library, Tracks, Highlights, Bookmarks, import screens, and the reader toolbar overlay only. This meaningfully changes the design brief.

**Deepening rounds:** 1 round chosen. Surfaced: (1) the core UX moment (organized docs reading with progress vs. browser chaos), (2) Duolingo doesn't translate, (3) design direction is open — not locked to current plan choices, (4) NotebookLM as the design quality target, (5) WebView constraint clarification. The extra round materially improved the design direction in the scope doc.

**Active shaping:** Aakash drove the direction throughout. He volunteered research and a full plan without prompting. He pushed back on Duolingo himself. He flagged the WebView constraint unprompted. The scope conversation confirmed and sharpened his existing thinking rather than building it from scratch.

## /prd

**Key changes vs scope doc:**
- Tracks/modules eliminated entirely; replaced by free-text tags on resources (metadata only, no filter UI in MVP). Big simplification to the data model.
- Import flow gained significant precision: two-mode dialog (simple = checkboxes only, advanced = reorder/rename/description); same dialog for both docs and standalone imports; duplicate detection on both resource and chapter level; FAB-initiated import from within app
- Bookmarks clarified as a chapter reading queue with prev/next sequential navigation when reading from the Bookmarks screen — more distinct from the chapter list than it seemed
- Drawer reduced from 5 to 4 items (Library, Bookmarks, Highlights, Settings)
- Delete app data added to Settings

**"What if" questions that landed:**
- First-run empty state (hadn't been considered explicitly — led to: empty state prompt + FAB)
- Cascade delete on resource deletion (unsure at first — accepted recommendation: cascade delete with informative confirmation dialog showing highlight/bookmark count)
- Scroll position persistence (accepted pragmatic answer: memory only while app is alive, cleared on full close — scroll-to-disk deferred to "more time" list)
- Offline/dead URL in reader (not considered — added: error state with retry)

**Pushback and strong opinions:**
- Pushed back on "first incomplete chapter" for Resume → insisted on "last chapter opened." Clear preference grounded in reading-flow intuition.
- Eliminated Tracks without hesitation when tags-as-metadata alternative was presented — no attachment to the more complex data model.
- Asked for external validation ("what do existing solutions do?") on the Resume behavior question before deciding — comfortable deferring to data, then overriding it with his own preference.

**Scope guard moments:**
- Tag filtering: explicitly deferred ("not needed at the moment" — described future vision only). Kept tags as metadata. No pushback on the deferral.
- Search: confirmed still cut — "search bar" mention was loose language describing the future layout, not a request to add search.

**Deepening rounds:** 0 rounds chosen — proceeded directly to document. Aakash moved efficiently; mandatory questions were sufficient given his prior clarity on the concept.

**Active shaping:** Strongly active throughout. Eliminated Tracks on his own initiative. Introduced the two-mode dialog pattern (simple/advanced) unprompted. Added multi-select mode detail broadly across all list screens without being asked. Introduced the bookmark queue + prev/next navigation detail. Made clear product decisions quickly. The one moment of passivity was the cascade delete question — genuinely uncertain, accepted recommendation without pushback.

## /spec

**Technical decisions made:**
- `flutter_inappwebview` over `webview_flutter` — agent recommended based on highlight feature requirements (bidirectional JS channels, ContextMenu API, evaluateJavascript with return values). Aakash deferred to recommendation.
- Native Android ContextMenu for highlight toolbar — Aakash asked about how system apps do it (Cut/Copy/Paste bar); agent confirmed flutter_inappwebview supports this natively. Preferred over custom overlay or bottom-right FABs as the most reliable and native approach.
- `bookmarked_at` nullable timestamp on chapters table — no separate bookmarks table needed. Aakash accepted.
- Router extra for bookmark navigation context — cleaner than query params, no URL pollution, type-safe with freezed `ReaderContext`. Agent recommended over query param approach.
- Design system: DM Sans + teal (#0D9488) + light-first + cool neutrals. Aakash chose each element: light-first, teal/cyan, DM Sans. Agent proposed the specific palette and shape values; Aakash accepted.
- External JS asset files (`assets/js/`) over inline Dart strings — better separation of concerns, version-controlled independently. Agent recommended; Aakash deferred.
- Split highlight bridge: `js_bridge.dart` (WebView interop only) + `highlight_service.dart` (domain logic). Agent recommended three-layer split for modularity. Aakash specified he wants flexible, modular, secure, scalable code following best practices.
- Sitemap depth: 2 levels by default, configurable 1–4 in advanced import panel. Aakash's idea.
- Chapter navigation: `pushReplacement` with zero-duration `CustomTransitionPage`. Aakash asked if seamless-feeling chapter nav was possible; agent confirmed yes and proposed the pattern.
- Loading indicator during chapter load: thin `LinearProgressIndicator` below toolbar. Aakash's choice over accepting the white flash.
- `freezed` for UI state models + `AsyncValue` error handling contract — every async provider handles all three states explicitly.

**What Aakash was confident about vs uncertain:**
- Confident: stack (Flutter/Drift/Riverpod/go_router), data hierarchy (Resource → Chapter), no-backend/local-first constraint, all PRD decisions
- Uncertain about / deferred to agent: WebView package choice, JS architecture layering, file structure details, design system specifics
- Aakash drove design direction (light-first, teal, DM Sans) but needed agent to translate to concrete values

**Stack choices and rationale:**
Flutter/Drift/Riverpod/go_router were fully pre-decided. The /spec conversation was about filling in package-level gaps (flutter_inappwebview), design system, architectural patterns, and JS bridge design.

**Deepening rounds:** 0 rounds chosen. Aakash had enough clarity from the mandatory questions and was ready to generate. The mandatory questions were productive — they surfaced the ContextMenu vs custom overlay decision, the bookmark routing approach, and the resource sort order definition.

**Active shaping:**
- Aakash drove all design direction choices (light-first, teal, DM Sans)
- Asked a genuinely good question about whether native system selection toolbar could be used for highlights — this led to a better architecture than the original custom overlay plan
- Specified "flexible, modular, secure, scalable" + best practices as a constraint — led to 3-layer JS bridge split and freezed/AsyncValue patterns
- Consistently deferred on package-level and architecture decisions while actively shaping design and UX decisions

## /checklist

**Sequencing decisions and rationale:**
- Foundation first: design system → navigation shell → DB layer, because every subsequent item depends on these
- Risky items early: Reader (item 7) and Highlighting (item 8) are in the first half — both have the most unknowns (flutter_inappwebview ContextMenu API, XPath JS bridge reliability). Validated against a real surface before 7 other screens are built on top
- Import system split into 5a (SitemapService) and 5b (ImportScreen) after deepening round — sitemap HTTP/XML work and dialog UI are independent enough to isolate
- Bookmarks comes before Highlights screen because the bookmark toggle is already built in the reader; Highlights screen is more complex (filter, scroll-to-highlight)
- Multi-select (item 13) comes after all 3 target screens are built — it's a retrofit pattern, cleaner to apply once each screen's data and actions are stable
- Settings before multi-select because Settings touches SharedPreferences/ThemeNotifier infrastructure needed throughout; multi-select is pure UI retrofit

**Methodology preferences:**
- Build mode: Step-by-step
- Comprehension checks: Yes
- Verification: Yes, per item (learner runs app after each item)
- Git: Commit after each item
- Check-in cadence: Learning-driven — more discussion and explanation of decisions/tradeoffs during build

**Item count and estimated time:**
- 15 items total (after splitting Import into 5a/5b and Settings+Multi-select into 11/12)
- Estimated 15–30 min verification + discussion per item → roughly 4–7 hours total

**What Aakash was confident about vs needed guidance on:**
- Confident: sequencing logic (immediately identified reader/highlighting as the riskiest pieces); agreed the foundation-first order was right without pushback
- No strong opinions on splits — accepted both the Import split and the Settings/Multi-select split when proposed
- Deepening round: chose to run 1 round; actively improved the highlighting verification step (asked for more scenarios and edge cases)

**Submission planning notes:**
- Core story confirmed: "Read4ever turns scattered online docs and guides into structured, trackable reading units"
- Wow moments: import dialog (smart chapter detection) + reader with highlight marked
- GitHub repo already exists
- Deployment: GitHub Release with release APK (v1.0.0)
- Demo video: not planned, optional

**Deepening rounds:** 1 round, 4 questions.
- Q1: Import system too big → split into SitemapService + ImportScreen. Accepted immediately.
- Q2: Settings + Multi-select too broad → split into two items. Accepted immediately.
- Q3: Highlighting verification specificity → Aakash pushed back, asked for more scenarios and edge cases. Led to an expanded 8-scenario verification list covering DOM-spanning selections, cross-chapter bleed-through, note editing, and scroll-to-highlight from Highlights screen.
- Q4: Drift codegen as a hidden dependency → confirmed Aakash will run `build_runner` manually; checklist flags it explicitly.

**Active shaping:** Aakash accepted the proposed sequencing without modification. His one meaningful contribution during the checklist conversation was pushing back on the highlighting verification step — asked for more scenarios and cases, which led to a meaningfully more thorough test surface for the riskiest item on the list. Low engagement overall vs /spec and /prd; he arrived knowing what he wanted and primarily validated the proposed plan.

## /build

### Step I3: Bottom sheet polish — drag handles + Note sheet header

**What was built:**
- Added `showDragHandle: true` to all 7 `showModalBottomSheet` calls in the app: `highlights_screen.dart` (`_showResourcePicker`, `_showChapterPicker`, `_showDetailSheet`), `import_screen.dart` (`showImportBottomSheet`), `reader_toolbar.dart` (`_showChapterDropdown`), `reader_screen.dart` (`_showNoteBottomSheet`, `_onMarkTapped`)
- Added `Text('Add note', style: Theme.of(context).textTheme.titleSmall)` header + `SizedBox(height: 8)` spacer above the TextField in `_NoteSheet` — the sheet was previously unlabeled

**Issues:** None. `flutter analyze` — no issues.

**Verification:** Open every bottom sheet in the app (import, chapter dropdown, note, highlight detail, filter pickers) — all should display a visible drag handle. Open the note sheet from the reader context menu → confirm "Add note" header is visible above the text field.

---

### Step I1: Reader open jank — blank flash + progress bar layout shift

**What was built:**
- `lib/screens/reader/reader_screen.dart` (line 472): replaced `Scaffold(body: SizedBox.shrink())` with `Scaffold(body: Center(child: CircularProgressIndicator()))` — reader now shows a centered spinner while `_init()` resolves instead of a blank white screen
- `lib/screens/reader/reader_screen.dart` (lines 495–503): replaced `AnimatedOpacity` wrapping `LinearProgressIndicator` with `AnimatedContainer` that animates `constraints.maxHeight` between `0.0` and `2.0` (200ms, `Curves.easeOut`) — the 2px layout gap that was permanently reserved is now fully collapsed when not loading, eliminating the toolbar-to-WebView jitter

**Issues:** None. `flutter analyze` — no issues.

**Verification:** Learner to open any resource → tap Resume → confirm brief spinner (not white flash) before WebView appears. Watch toolbar/WebView boundary during page load — no 2px gap when progress bar is hidden.

---

### Step I2: Highlights filter chips — tap to change, X to clear

**What was built:**
- `lib/screens/highlights/highlights_screen.dart` — two changes:
  1. Removed early-return bail-outs in `_showResourcePicker` and `_showChapterPicker` (the `if (currentId != null) { notifier.clear(); return; }` blocks) — tapping a selected chip now always opens the picker
  2. Replaced `avatar: Icon(Icons.close)` on both `FilterChip` widgets with `onDeleted` callbacks (`null` when chip is unselected, clears filter when chip is selected) — X icon now appears natively via Flutter's chip delete affordance, tap = change, X = clear

**Issues:** None. `flutter analyze` — no issues.

**Verification:** Set a resource filter → tap the chip again → confirm picker opens → select a different resource → confirm filter switches without clearing first. Tap the X icon → confirm filter clears. Repeat for chapter chip.

---

### Step 14: Android share sheet integration

**What was built:**
- `android/app/src/main/AndroidManifest.xml` — added `ACTION_SEND / text/*` intent filter inside the existing `<activity>` block per `flutter_sharing_intent` package documentation
- `lib/services/intent_handler.dart` — `IntentHandler` service: subscribes to `getMediaStream()` for warm opens and calls `getInitialSharing()` for cold starts; extracts URL from `SharedFile.value`; checks `appRouter.routerDelegate.currentConfiguration.uri.path` to avoid opening a second import screen if one is already on the stack; pushes `/import` with the URL as a route `extra`
- `lib/router.dart` — `/import` route builder updated to read `state.extra as String?` and pass it as `initialUrl` to `ImportScreen`
- `lib/screens/import/import_screen.dart` — `ImportScreen` gains an `initialUrl` constructor parameter; when set, it passes `autoDiscover: true` to `showImportBottomSheet` so discovery starts immediately without the user tapping Scan; `ImportBottomSheet` gains an `autoDiscover` flag that triggers `importNotifier.discover()` in the same post-frame callback that sets the URL
- `lib/app.dart` — converted from `ConsumerWidget` to `ConsumerStatefulWidget`; `IntentHandler` initialized in `initState` and disposed in `dispose`

**Key design decision — URL via route extra instead of pre-setting the provider:**
The `importNotifierProvider` is `autoDispose`. Setting the URL on it from the `IntentHandler` before pushing `/import` creates a timing race: the provider is scheduled for disposal after the current frame, and `ImportScreen` might not have mounted and started watching it before disposal fires. Passing the URL as a go_router `extra` (a `String?`) sidesteps this entirely — the URL travels with the navigation event itself and arrives in `ImportScreen`'s constructor before any widget builds. No autoDispose concerns, no global state, no timing sensitivity.

**Issues:** None. `flutter analyze` — no issues on all 4 changed files.

**Verification:** Learner to test on Android device/emulator: (1) warm open — share URL from Chrome while app is running → confirm import dialog opens with URL pre-filled and scan already started; (2) cold start — kill app, share URL from Chrome → confirm app launches directly to import dialog; (3) duplicate detection — share an already-imported URL → confirm it navigates to the existing resource directly.

---

### Step 11: Resource Detail screen — inline editing, tags, chapter list, delete

**What was built:**
- `lib/models/resource_with_chapters.dart` — implemented stub as a real model (`Resource resource`, `List<Chapter> chapters`)
- `lib/db/daos/resources_dao.dart` — implemented `watchById(int id)` as `(select(resources)..where(id.equals)).watchSingleOrNull()`; removed unused `ResourceWithChapters` import
- `lib/db/daos/tags_dao.dart` — added `watchByResource(int resourceId)` using a type-safe join on `resource_tags` → returns ordered `List<Tag>` stream
- `lib/providers/resources_provider.dart` — added `resourceStreamProvider(id)` and `resourceChaptersProvider(id)` as `StreamProvider.autoDispose.family`
- `lib/providers/tags_provider.dart` — new file; `allTagsProvider` (all tags stream for autocomplete) and `tagsForResourceProvider(id)` (tags for a resource)
- `lib/providers/import_provider.dart` — added `excludeUrls` parameter to `discover()` and `_runDiscovery()`; excluded URLs are filtered from discovered pages before state update
- `lib/screens/import/import_screen.dart` — added `initialUrl`/`excludeUrls` to `ImportBottomSheet` constructor and `showImportBottomSheet()` helper; pre-fills URL on `initState`; passes `excludeUrls` to `notifier.discover()`
- `lib/screens/resource_detail/widgets/tag_input.dart` — `Autocomplete<Tag>` field backed by `allTagsProvider` (prefix-filtered, excludes already-attached tags); Enter and comma create new tags via `TagsDao.addTagToResource`; existing tags displayed as deletable `InputChip` widgets above the field; `_CommaSplitter` TextInputFormatter intercepts comma → fires onCommit with the prefix text, clears field
- `lib/screens/resource_detail/resource_detail_screen.dart` — replaced stub; `ConsumerStatefulWidget` with `FocusNode`-based auto-save for title and description (writes only when value changed); `ReorderableListView.builder` for chapters with done checkmarks, drag handles, per-item delete (confirm dialog shows highlight count); "Import more chapters" opens `showImportBottomSheet` with resource URL pre-filled and existing chapter URLs excluded; "Delete Resource" AlertDialog shows highlight + bookmark counts from DAO methods then calls `ResourcesDao.deleteById` (cascade-deletes chapters/highlights) + `context.pop()`

**Design decisions:**
- **Three separate providers instead of combined stream**: Combining `Resource`, `List<Chapter>`, `List<Tag>` streams cleanly requires rx_dart. Using three `StreamProvider.autoDispose.family` instances watched independently in the screen avoids the dependency with the same reactive behavior.
- **Auto-save via FocusNode listeners**: Each editable field gets its own FocusNode. On blur, we compare against `_savedTitle`/`_savedDesc` (last-written values) to avoid spurious DB writes on every tap-away. Only writes when value actually changed.
- **`excludeUrls` parameter on `discover()` — no freezed change**: Adding exclude logic as a runtime parameter to `discover()` avoids modifying `ImportState` (which would require a `build_runner` re-run). Clean and correct.
- **`_CommaSplitter` TextInputFormatter**: Intercepts commas mid-input to fire the commit callback, keeping the text after the last comma in the field. Cleaner than `onChanged` polling.

**Issues:** None. `flutter analyze` — no issues.

**Verification:** Learner to run all 9 acceptance criteria flows listed above (title/desc persistence, tag add/remove/autocomplete, chapter reorder, chapter delete with highlight count, import more chapters, delete resource with counts).

**Comprehension check:** Asked what happens before the tag chip appears after pressing Enter. Answer: "DB write → stream update → chip renders" — correct. Drift's reactive `watchByResource()` stream is the single source of truth; no local state needed.

---

### Step 10: Highlights screen — list, filter, bottom sheet, scroll-to-highlight

**What was built:**
- `lib/screens/highlights/widgets/highlight_list_item.dart` — `StatefulWidget` with `InkWell` for both `onTap` and `onDoubleTap`; local `_expanded` bool toggles `maxLines: null` vs `maxLines: 2`; left teal accent bar (3px wide `Container`) as a visual scan affordance; note preview if present (italic, textSecondary)
- `lib/screens/highlights/widgets/highlight_bottom_sheet.dart` — inline note editing (toggles `_editingNote` state, no new route); "Open in reader" pops sheet then pushes with `ReaderContext(source: highlights, scrollToHighlightId: h.id)`; Delete calls `highlightsDao.deleteHighlight()` only (no JS bridge — correct, user is on the Highlights screen not in the reader; mark disappears on next chapter open)
- `lib/screens/highlights/highlights_screen.dart` — replaced stub; `Column` with filter bar (shown only when highlights exist) + `Expanded` ListView; filter bar uses `FilterChip` widgets backed by `HighlightFilterNotifier`; chapter filter scoped to selected resource; two-level empty state (no highlights at all vs no highlights match filter)
- `lib/screens/reader/widgets/reader_highlight_sheet.dart` — bonus widget: tapping an existing mark in the reader opens a sheet with prev/next navigation through all chapter highlights, inline note edit, and delete via `HighlightService.removeHighlight()` (calls both DB delete and JS DOM removal)
- `lib/services/js_bridge.dart` / `lib/services/highlight_service.dart` — extended with `scrollToHighlight`, `updateHighlightNote`, `removeHighlight` methods (used by both reader highlight sheet and DOM cleanup)
- `assets/js/highlight_restore.js` — extended with `__read4ever_scrollToHighlight`, `__read4ever_updateHighlightNote`, `__read4ever_removeHighlight` (unwraps mark element, keeping text, then normalizes surrounding text nodes)
- `lib/screens/reader/reader_screen.dart` — scroll-to-highlight wired in `_onPageLoaded` after `injectScripts()` + `restoreForChapter()` — sequence matters: marks must exist in DOM before `scrollIntoView` is called

**Design decisions:**
- **Double-tap via InkWell (not GestureDetector)**: InkWell handles both tap + double-tap without tap delay on this device; kept simple
- **Inline note editing in sheet**: Avoids pushing a new route for a short-form field; the highlight context stays visible
- **No JS removal from Highlights screen delete**: The Highlights screen has no active WebView. Mark disappears naturally when the chapter is next opened (won't be in DB → won't restore). Correct behavior.
- **`reader_highlight_sheet.dart` carries its own highlight list**: Sheet receives the full chapter list and manages its own index state, so prev/next cycling works without re-querying on each tap

**Issues:** None. `flutter analyze` — no issues.

**Verification:** Learner confirmed all flows working. Minor chapter navigation consistency issues noted and resolved during the session.

**Comprehension check:** Asked what makes scroll-to-highlight work despite the mark not existing on navigation start. Answer: "scrollToHighlight runs after restore" — correct. Sequence in `_onPageLoaded`: inject → restore → scroll.

---

### Step 9: Bookmarks screen — list, prev/next reader FABs

**What was built:**
- `lib/models/chapter_with_resource.dart` — fully implemented (was a stub); Drift result class with `Chapter chapter` and `Resource resource` fields; `fromRow` factory reads aliased columns (`c_*`, `r_*`) from a JOIN query
- `lib/db/daos/chapters_dao.dart` — implemented `watchBookmarked()`: `customSelect` SQL that JOINs chapters to resources, filters `WHERE bookmarked_at IS NOT NULL`, ORDER BY `bookmarked_at ASC`; `readsFrom: {chapters, resources}` for reactive stream. Also added `getBookmarked()` (non-streaming Future variant) used by reader FABs to recompute adjacents on navigation
- `lib/providers/bookmarks_provider.dart` — `bookmarksProvider` (`StreamProvider.autoDispose` over `chaptersDao.watchBookmarked()`)
- `lib/screens/bookmarks/widgets/bookmark_list_item.dart` — `BookmarkListItem` ConsumerWidget: chapter title (bodyMedium), resource name (labelSmall, textSecondary); taps push reader with `ReaderContext(source: bookmarks, adjacentChapterIds: [prevId, nextId])`
- `lib/screens/bookmarks/bookmarks_screen.dart` — replaced stub; `ConsumerWidget` driven by `bookmarksProvider`; empty state (bookmark icon + two text lines); `ListView.builder` of `BookmarkListItem` widgets
- `lib/screens/reader/reader_screen.dart` — added `_hasPrevBookmark` / `_hasNextBookmark` computed properties; `_navigateViaBookmarkFab(targetId)` re-queries `getBookmarked()` to compute the target chapter's adjacents (so FABs keep working through the chain, not just one hop); `_buildBookmarkFabs()` returns a `Column` of up to two `FloatingActionButton.small` widgets (Prev = arrow_upward, Next = arrow_downward), only when source is bookmarks; added `floatingActionButton: _buildBookmarkFabs()` to Scaffold

**Design decisions:**
- **Fixed 2-element adjacentChapterIds encoding**: `[prevId_or_0, nextId_or_0]` — 0 is a sentinel meaning "no chapter in this direction." Drift auto-increment starts at 1, so 0 is never a valid chapter ID. Index 0 is always prev, index 1 is always next. This avoids the ambiguity in the spec's `.whereType<int>()` approach which would make index 0 mean different things depending on position in the list.
- **Re-query on FAB navigation**: When a user taps Prev/Next FAB, `getBookmarked()` fetches the full sorted bookmark list to compute the target chapter's own adjacents. This lets Prev/Next chaining work across multiple hops without needing to carry the full list in state. Cost is one DB query per FAB tap — negligible for local SQLite.
- **`FloatingActionButton.small`**: Keeps FABs compact; stacked in a Column so they don't obscure the WebView content more than necessary.
- **`ChapterWithResource.fromRow` pattern**: Mirrors `HighlightWithChapterAndResource` — aliased SQL columns with `c_/r_` prefixes to avoid collision on the multi-table JOIN.

**Issues:** One linter warning — `ids.length > 0` instead of `ids.isNotEmpty`. Fixed immediately. `flutter analyze` — no issues.

**Verification:** Learner to: bookmark 3 chapters → open Bookmarks screen → confirm all 3 appear in correct order → tap middle → confirm both Prev and Next FABs appear → tap Next → confirm navigates to third → tap Prev → confirm returns to middle → go back to Bookmarks → un-bookmark first chapter from reader toolbar → confirm it disappears from the list reactively.

### Step 8: Highlighting system — JS bridge, ContextMenu, restore

**What was built:**
- `assets/js/selection_listener.js` — exposes `window.__read4ever_getSelection()`: bottom-up XPath traversal using `node.tagName[n]` positional path from document root; text nodes get `/text()[n]` suffix; returns `{text, xpathStart, xpathEnd, startOffset, endOffset}` or null; error-guarded with try/catch
- `assets/js/highlight_restore.js` — IIFE exposing `window.__read4ever_restoreHighlights(json)` (bulk restore), `window.__read4ever_applyHighlight(id, xpathStart, xpathEnd, startOffset, endOffset)` (single new mark), `window.__read4ever_scrollToHighlight(id)` (scroll-to from Highlights screen); uses `surroundContents` with fallback to `extractContents + appendChild` for cross-element selections (scenario 7 in acceptance criteria)
- `lib/models/selection_data.dart` — plain immutable class (not freezed — no codegen needed for a value object with no pattern matching); `fromJson` factory handles numeric offset fields
- `lib/services/js_bridge.dart` — `JsBridge(InAppWebViewController)`: `injectScripts()` loads both JS assets via rootBundle; `getSelection()` calls evaluateJavascript + JSON-decodes result; `applyHighlight()` uses `jsonEncode` on XPath strings for safe JS string literals; `restoreHighlights()` double-encodes (JSON array → JSON string → JS arg) so the JS function receives the string to parse
- `lib/services/highlight_service.dart` — `HighlightService(highlightsDao, jsBridge)`: `createHighlight()` inserts to DB then calls `jsBridge.applyHighlight` with the new row ID; `restoreForChapter()` calls `highlightsDao.getByChapter()` then `jsBridge.restoreHighlights()`
- `lib/models/highlight_with_chapter_and_resource.dart` — fully implemented as a real Drift result class with aliased SQL columns (`h_*`, `c_*`, `r_*`) to avoid naming collisions across the three-table join
- `lib/db/daos/highlights_dao.dart` — `watchAll()` implemented with full three-table join (highlights ↔ chapters ↔ resources) aliased columns + ORDER BY `h.created_at DESC`; added `getByChapter()` (non-streaming Future for HighlightService)
- `lib/providers/highlights_provider.dart` — `highlightsProvider` (all highlights stream), `chapterHighlightsProvider` (family by chapterId), `HighlightFilterNotifier` + `highlightFilterNotifierProvider` (scaffolded for step 10)
- `lib/screens/reader/reader_screen.dart` — `ContextMenu` initialized as `late final` in `initState` with two items (Highlight/Add Note) using `id` parameter (flutter_inappwebview v6 API); `JsBridge` and `HighlightService` initialized in `onWebViewCreated`; `_onHighlightTapped` / `_onAddNoteTapped` methods guard null state; `_showNoteBottomSheet()` modal with autofocus TextField + Cancel/Save; `_onPageLoaded` now calls `injectScripts()` then `restoreForChapter()` then `scrollToHighlight()` (if `scrollToHighlightId` set in ReaderContext); temp mode returns early before script injection

**Design decisions:**
- `SelectionData` as plain class (not freezed): the spec says freezed but the practical benefit is zero here — no pattern matching, no union type, no copyWith needed. Avoids a build_runner re-run with no tradeoff.
- Double JSON encode in `restoreHighlights`: `jsonEncode(jsonEncode(list))` produces a JS string literal that, when passed as a function arg, gives JS a string it can `JSON.parse`. Single encode would pass a JS object literal which the function doesn't expect.
- `late final ContextMenu _contextMenu` in `initState`: ContextMenu must be stable across rebuilds; initializing in `build` would recreate it every frame. `late final` captures `this` in the action closures, giving access to `_jsBridge`/`_highlightService` at call time (they're guaranteed non-null once `onWebViewCreated` fires).
- `surroundContents` + `extractContents` fallback: `surroundContents` is simpler and leaves the DOM cleaner but throws for cross-element ranges. The fallback handles scenario 7 (bold mid-sentence selections).
- ContextMenu `id` not `androidId`: flutter_inappwebview v6 renamed the parameter.

**Issues:** One linter warning — `if` without braces in `_isInTempMode` branch (carried over from step 7 style). Fixed immediately. `flutter analyze` — no issues.

**Verification:** Learner to run all 8 scenarios against a real docs page in the reader.

### Step 7 (continued): Post-build fixes and additions

**Issues encountered and resolved after initial build:**
- Error overlay not covering WebView: `Container` in a `Stack` without positioning only wraps its children. Fixed with `Positioned.fill`.
- `onLoadStop` fires after Android's native error page loads, clobbering the chapter title with "Webpage not available" and clearing the error overlay. Fixed with `_lastLoadHadError` flag: set in `onReceivedError`, cleared in `onLoadStart`, checked in `_onPageLoaded` to skip title update and keep overlay.
- Retry flash: `onLoadStart` was clearing `_showErrorState` immediately, exposing the native error page while the retry request was in-flight. Fixed by not clearing the overlay in `onLoadStart` — it stays visible until `_onPageLoaded` succeeds.
- `shouldOverrideUrlLoading` infinite loop: with `useShouldOverrideUrlLoading: true`, the callback fires for the initial load AND for HTTP redirects. A redirect URL (e.g. `drift.simonbinder.eu` → `drift.simonbinder.eu/docs/`) didn't match `_chapterUrl` exactly, fell through to `findByUrl`, found the same chapter after normalization, and fired `pushReplacement` to itself — creating a new screen on every redirect. Fixed with normalized URL comparison and `existing.id == _effectiveChapterId` guard.
- Anchor links returned `CANCEL` which blocked the WebView's native scroll behavior. Fixed to return `ALLOW`.

**Feature added (user request): in-WebView link handling**
- `shouldOverrideUrlLoading` intercepts all link clicks
- Existing chapter match → `pushReplacement` to that chapter
- New HTTP/S URL → temp chapter mode: WebView loads the URL, banner appears ("isn't in your library — Dismiss / Add")
- Non-HTTP/S URL → external browser dialog
- `_effectiveChapterId` tracks current chapter independently — starts as `widget.chapterId`, updates to new chapter ID when temp is added in-place
- `_addTempChapterInPlace()`: inserts chapter to DB, updates `_effectiveChapterId` and toolbar in-place (no `pushReplacement`) — WebView keeps showing the same page without reloading
- Toolbar: `titleOverride` shows temp page title, `bookmarkOverride`/`doneOverride` suppress original chapter state, `onBookmarkToggle`/`onDoneToggle` callbacks auto-add before acting
- Chapter dropdown: phantom "currently viewing" entry (`tempChapterTitle`) shown at top with explore icon when in temp mode; no existing chapter highlighted
- Banner styled to app design system: `colorScheme.surface` background, 1.5px teal top border, `textSecondary` message, `AppColors.accent` buttons

**Comprehension check:** Asked why `_addTempChapterInPlace` doesn't call `pushReplacement`. Learner answered "to avoid shouldOverrideUrlLoading re-trigger" — close (that's a real consequence) but the primary reason is that the WebView is already on the correct page; pushReplacement would dispose and recreate the InAppWebView, reloading from scratch. Learner accepted the correction without pushback.

### Step 7: Reader — WebView, toolbar, chapter navigation, error state

**What was built:**
- `lib/providers/reader_provider.dart` — `ReaderSource` enum, `ReaderContext` (freezed: source, adjacentChapterIds, scrollToHighlightId), `ReaderState` (freezed: chapterId, isLoading, context), `ReaderNotifier` (AutoDisposeFamilyNotifier keyed by `(int chapterId, ReaderContext)`), `chapterStreamProvider` (watches single chapter — toolbar uses this for reactive title/bookmark/done), `resourceChaptersProvider` (watches all chapters for a resource — chapter dropdown uses this)
- `lib/db/daos/chapters_dao.dart` — added `watchById(int id)` (stream of single chapter) and `getById(int id)` (Future, used in reader's initState to get URL + resourceId)
- `lib/screens/reader/reader_screen.dart` — ConsumerStatefulWidget; `_init()` async-fetches chapter on mount to get URL + resourceId, then calls `updateLastOpened`; Column layout: ReaderToolbar (56px) + AnimatedOpacity LinearProgressIndicator (2px) + Expanded Stack (InAppWebView + ReaderErrorState overlay); `onLoadStart` → setLoading(true); `onLoadStop` → `_onPageLoaded` (setLoading false + updateTitle from page title); `onReceivedError` → show error overlay; placeholder comment for step 8's script injection
- `lib/screens/reader/reader_toolbar.dart` — ConsumerWidget; watches `chapterStreamProvider(chapterId)` for reactive title/bookmark/done state; back button (context.pop), title/dropdown trigger, bookmark toggle (teal fill), done toggle (teal fill); chapter dropdown shown as `showModalBottomSheet` returning selected ID, then `context.pushReplacement` with `ReaderContext(source: readerContext.source)`
- `lib/screens/reader/widgets/chapter_dropdown_sheet.dart` — ConsumerWidget; DraggableScrollableSheet; watches `resourceChaptersProvider(resourceId)`; current chapter non-tappable; done chapters get teal ✓ trailing icon; calls `onChapterSelected` callback (pops sheet via Navigator.of(context).pop(id))
- `lib/screens/reader/widgets/reader_error_state.dart` — full-width overlay container with wifi_off icon, "Couldn't load this page" text, Retry button (webViewController.reload())
- `lib/router.dart` — reader route converted from `builder` to `pageBuilder` returning `CustomTransitionPage(transitionDuration: Duration.zero)` — all reader navigations are instant; `state.extra as ReaderContext?` with const ReaderContext() default

**Design decisions:**
- `ReaderNotifier` uses `AutoDisposeFamilyNotifier<ReaderState, (int, ReaderContext)>` (Dart 3 record as family key) — manual Riverpod, no codegen needed beyond freezed for state classes
- `_init()` in `initState` fetches chapter data async before showing WebView — avoids rebuilding InAppWebView when chapter stream emits title updates later (which would reload the page)
- Toolbar passes `onChapterSelected` callback to dropdown sheet and handles navigation from the outer context — avoids the go_router context issue inside modal bottom sheet
- `AnimatedOpacity` on LinearProgressIndicator (vs Visibility) — smoother load/done transition, widget stays in layout so there's no height jump
- `CustomTransitionPage` applies to all reader navigations (initial push from Library + chapter-to-chapter pushReplacement) — acceptable since the LinearProgressIndicator provides visual loading feedback

**Issues:** Two unused imports after initial write (chapters.dart table import in reader_provider.dart, flutter/material.dart in router.dart since CustomTransitionPage comes from go_router). Fixed immediately. `flutter analyze` — no issues.

**Verification:** Learner to run app, import a multi-chapter docs site, tap Resume → confirm page loads with toolbar visible. Mark chapter done → reopen dropdown → confirm checkmark. Bookmark → icon fills teal. Switch chapters via dropdown → confirm zero-duration transition. Disable network → reload → confirm error overlay → re-enable + Retry → page loads.

### Step 6: ImportScreen — dialog, state, DB write, navigation

**What was built:**
- `lib/providers/import_provider.dart` — `ImportStatus` enum, `ImportState` freezed class (url, status, allPages, deselectedUrls, resourceName, description, maxDepth, isAdvanced, errorMessage), `ImportNotifier` (AutoDisposeNotifier) with methods: `setUrl`, `discover`, `rescan`, `_runDiscovery`, `togglePage`, `reorderPage`, `setMaxDepth`, `toggleAdvanced`, `confirm`, `reset`
- `lib/screens/import/import_screen.dart` — `ImportScreen` stub (opens sheet via addPostFrameCallback, for step 14 intent handler), `showImportBottomSheet()` function, `ImportBottomSheet` ConsumerStatefulWidget with URL field, Scan button, chapter count summary, Advanced/Simple toggle, Cancel/Import actions
- `lib/screens/import/widgets/sitemap_chapter_list.dart` — checkbox list; standalone locks last checkbox; URL shown as subtitle
- `lib/screens/import/widgets/advanced_import_panel.dart` — `ReorderableListView` with drag handles + checkboxes, resource name TextField, description TextField, depth stepper (1–4) + Re-scan button

**Design decisions:**
- Selection tracked by `deselectedUrls: List<String>` (URL-based, not index-based) so reordering in advanced mode doesn't affect which pages are selected
- `_runDiscovery` returns a `bool` (true = single-page fallback used) so context usage is clean — no context passed into the async helper; snackbar shown in callers after mount check
- `ImportNotifier` extends `AutoDisposeNotifier` — fresh state every time the sheet opens, auto-disposed when closed
- `ImportScreen` route class kept for step 14 (Android share intent); `showImportBottomSheet` used by Library FAB directly
- Duplicate detection: exact URL match on chapters → reader; exact URL match on resources → resource detail; skips discovery in both cases

**Issues:** Initial `Notifier` → should have been `AutoDisposeNotifier` for `.autoDispose` provider; `_runDiscovery` had context passed across async gap (lint info). Fixed by restructuring to return bool + checking mounted in callers. `flutter analyze` — no issues.

**Verification:** Learner to run app, tap FAB, enter a multi-chapter docs URL, confirm chapter list appears, deselect chapters, tap Import, confirm reader opens. Then enter the same URL again — confirm it opens existing resource instead of re-importing.

### Step 5: SitemapService — URL validation, discovery, XML parsing

**What was built:**
- `lib/models/sitemap_page.dart` — Freezed class with `url` and `title` fields
- `lib/services/sitemap_service.dart` — `SitemapService` with:
  - `isValidUrl(String url)` — rejects empty, non-HTTP/S, malformed URIs
  - `discover(String url, {int maxDepth = 2})` — three-strategy discovery: `{base}/sitemap.xml` → `{base}/sitemap_index.xml` → scrape `<link rel="sitemap">` from page `<head>`; returns `null` if all fail or result is empty
  - `parseSitemap(String sitemapUrl, {int currentDepth, required int maxDepth})` — dispatches to `<sitemapindex>` (recursive) or `<urlset>` (extract `<loc>`) handlers
  - `_titleFromUrl(String url)` — derives human-readable title from last URL path segment (kebab/snake → Title Case)
  - `_discoverFromPage(String url)` — regex scan for `<link rel="sitemap" href="...">` with both attribute orderings; resolves relative hrefs against page URL

**Design decision logged:** Used non-raw string literals for HTML regex patterns — Dart raw strings (`r'...'`) cannot include single quotes at all (no escape mechanism), which would break character classes like `["']`. Non-raw strings with `\'` work correctly.

**Issues:** Initial codegen failed due to raw string literal containing `\'`. Fixed by switching to non-raw string literals. Second codegen pass and `flutter build apk --debug` both clean.

**Verification:** Passed — `drift.simonbinder.eu` returned 41 pages via link extraction; `example.com` returned null as expected.

**Issue encountered:** The spec assumed `drift.simonbinder.eu` has a conventional sitemap — it doesn't (robots.txt exists but no `Sitemap:` directive; `/sitemap.xml` 404s). Fixed by adding two additional strategies beyond the spec: (1) robots.txt parsing as primary strategy, (2) same-origin `<a href>` link extraction as last-resort fallback. Also hit a Dart raw-string bug: `r'...'` can't contain single quotes, so regex patterns with `["']` character classes had to use non-raw string literals. URL normalization was also fixed — `Uri.replace(fragment: '', query: '')` leaves `?#` in the string; switched to `.split('?')[0].split('#')[0]`.

### Step 4: Library screen

**What was built:**
- `lib/models/resource_with_status.dart` — real Drift result class: `Resource resource`, `int totalCount`, `int doneCount`, computed getters `isDone` / `isInProgress` / `progress`, `factory fromRow(QueryRow row)`
- `lib/models/resource_with_chapter.dart` — real Drift result class: `Resource resource`, `Chapter lastOpenedChapter`, `factory fromRow(QueryRow row)`
- `ResourcesDao.watchAll()` — subquery SQL with GROUP BY + CASE sort (in-progress → not-started → done, then `lastAccessedAt DESC`); uses `customSelect` with `readsFrom: {resources, chapters}` for reactive streams
- `ResourcesDao.watchContinueReading()` — INNER JOIN on `last_opened_chapter_id` + EXISTS subqueries filtering to in-progress resources; LIMIT 3 ORDER BY `lastAccessedAt DESC`
- `lib/providers/resources_provider.dart` — manual `StreamProvider` (not codegen) to avoid requiring a build_runner re-run; `resourcesProvider` + `continueReadingProvider`
- `lib/screens/library/widgets/resource_card.dart` — Card with InkWell tap → `/resource/$id`, title, description (2 lines ellipsis), chapter count + LinearProgressIndicator, Resume button shown only when `lastOpenedChapterId` is non-null; done treatment: title at secondary opacity
- `lib/screens/library/widgets/continue_reading_strip.dart` — horizontal ListView of up to 3 entries, hidden when empty, each card 160px wide, taps to `/reader/$lastOpenedChapterId`
- `lib/screens/library/library_screen.dart` — ConsumerWidget with nested `Scaffold(backgroundColor: Colors.transparent)` for FAB placement; handles AsyncValue loading/error/data; shows `ContinueReadingStrip` + SliverList of ResourceCards; empty state with icon + two text lines; FAB → `/import`

**Design decision logged:** Used nested Scaffold (`Colors.transparent`) for the FAB rather than modifying `DrawerScaffold` — self-contained, no changes to the shell widget, FAB positions correctly relative to screen bottom.

**Design decision logged:** Used manual `StreamProvider` instead of Riverpod codegen for resource providers — avoids requiring build_runner re-run at this step. Behavior is identical.

**Issues:** None. `flutter analyze` — no issues.

**Verification:** Passed — empty state rendered correctly with FAB visible; FAB navigated to `/import` stub. Build_runner ran cleanly (two pre-existing warnings, no errors).

### Step 3: Database layer — tables, DAOs, codegen

**What was built:**
- `lib/db/tables/` — 5 table classes: `Resources`, `Chapters`, `Highlights`, `Tags`, `ResourceTags` with all columns, FK references, and `onDelete: cascade` constraints as specified
- `lib/db/database.dart` — `AppDatabase` with `@DriftDatabase` annotation, `_openConnection()` using `NativeDatabase.createInBackground` (requires `path_provider` + `path`, added to pubspec)
- `lib/db/daos/` — 4 DAO classes with `@DriftAccessor` annotations: `ResourcesDao`, `ChaptersDao`, `HighlightsDao`, `TagsDao`. Simple single-table queries implemented fully; complex multi-table/aggregate methods stubbed with `throw UnimplementedError()` (implemented in the step that introduces the consuming screen)
- `lib/models/` — 5 stub result classes (`ResourceWithStatus`, `ResourceWithChapters`, `ResourceWithChapter`, `ChapterWithResource`, `HighlightWithChapterAndResource`) for DAO return type signatures; fully implemented in steps 4, 8, 9
- `lib/providers/database_provider.dart` — `appDatabaseProvider` keepAlive singleton
- Codegen: all 6 `.g.dart` files generated successfully; `flutter analyze` — no issues

**Design decision logged:** `Resources.lastOpenedChapterId` uses `.nullable().customConstraint('REFERENCES chapters(id) ON DELETE SET NULL')` instead of `.references(Chapters, #id)` to avoid a circular Dart import between `resources.dart` and `chapters.dart`. Functionally identical at the SQLite level.

**Issues:** Initial codegen pass had one fixable warning (`lastOpenedChapterId` not declared nullable). Fixed by chaining `.nullable()` before `.customConstraint()`. Second codegen pass clean.

**Verification:** Pending — learner to run `flutter run` and confirm app launches without database errors in debug console.

### Step 2: Navigation shell + stub screens

**What was built:**
- `lib/router.dart` — full go_router config with `ShellRoute` wrapping `/library`, `/bookmarks`, `/highlights`, `/settings`; full-screen routes `/resource/:id`, `/reader/:chapterId`, `/import`
- `lib/widgets/drawer_scaffold.dart` — `DrawerScaffold` widget with `NavigationDrawer`, 4 destinations, active route derived from `GoRouterState.uri`
- Stub `Scaffold` screens for all 7 routes (title + placeholder body text)
- `lib/app.dart` updated to `MaterialApp.router` with real `appRouter`
- Placeholder test file updated (removed reference to deleted `MyApp` class)
- `flutter analyze` — no issues

**Issues:** Unused import in `router.dart` (fixed) and stale `widget_test.dart` referencing removed `MyApp` (fixed).

**Verification:** Pending — learner to run `flutter run`, open drawer, tap all 4 destinations, and verify full-screen routes push correctly.

### Step 1: Project setup + design system

**What was built:**
- `pubspec.yaml` updated with all 14 runtime dependencies and 4 dev dependencies as specified in spec.md
- `assets/js/` folder created with placeholder `selection_listener.js` and `highlight_restore.js`
- `lib/theme/app_colors.dart` — all light + dark color constants
- `lib/theme/app_theme.dart` — `ThemeData` light + dark using DM Sans, full typography scale, component overrides for Card, ElevatedButton, ProgressIndicator, BottomSheet, Drawer, ListTile
- `lib/app.dart` — stub `Read4everApp` (MaterialApp with light/dark theme, placeholder home screen showing teal ElevatedButton)
- `lib/main.dart` — `runApp` wrapped in `ProviderScope`
- `flutter pub get` ran successfully: 101 packages resolved

**Issues:** None. All dependencies resolved cleanly.

**Verification:** Pending — learner to run `flutter run` and confirm DM Sans renders, teal accent visible, no errors.

### Step 12: Settings screen + theme persistence

**What was built:**
- `lib/providers/theme_provider.dart` — `sharedPreferencesProvider` (keepAlive, overridden before runApp) + `ThemeNotifier` (keepAlive, reads stored theme from SharedPreferences on build, persists on setTheme)
- `lib/main.dart` — updated to `async`, initializes `SharedPreferences.getInstance()` before `runApp`, injects via `ProviderScope(overrides: [...])`
- `lib/app.dart` — updated to `ConsumerWidget`, watches `themeNotifierProvider` and passes it to `MaterialApp.router themeMode:`
- `lib/screens/settings/settings_screen.dart` — full implementation: `SegmentedButton<ThemeMode>` (Light / Dark / System), Delete All Data `ListTile` with red destructive styling, `AlertDialog` with warning copy, confirm → `HighlightsDao.deleteAll()` + `ResourcesDao.deleteAll()` + `TagsDao.deleteAll()` + `context.go('/library')`
- Ran `build_runner` — generated `theme_provider.g.dart` without errors

**Issues:** None. Pre-existing drift_dev warning on `chapters` reference in resources table (unrelated to this step).

**Verification:** Pending — learner to confirm theme persists across restarts and Delete All Data clears everything.

### Step 13: Multi-select pattern — Highlights, Bookmarks, ResourceDetail

**What was built:**
- `lib/providers/multi_select_provider.dart` — shared `MultiSelectNotifier` (`AutoDisposeNotifier<Set<int>>`) with `toggle`, `selectAll`, `clear`. Three named provider instances: `highlightsMultiSelectProvider`, `bookmarksMultiSelectProvider`, `resourceDetailMultiSelectProvider`. Auto-dispose ensures each screen instance gets fresh state.
- `lib/screens/highlights/widgets/highlight_list_item.dart` — extended with `isMultiSelectMode`, `isSelected`, `onLongPress`, `onToggleSelect` params. In multi-select mode: tap → toggle select, leading shows `Checkbox`, double-tap expand hidden. In normal mode: unchanged behavior. Selected items get a tinted background.
- `lib/screens/highlights/highlights_screen.dart` — watches `highlightsMultiSelectProvider`. Multi-select active when `selected.isNotEmpty`. Shows `_MultiSelectBar` (count + Select All + Clear + Delete) at top of Column when active. Filter bar hidden during multi-select (less noise). Long press on any item enters multi-select. Bulk delete shows confirm dialog, then calls `HighlightsDao.bulkDelete`.
- `lib/screens/bookmarks/widgets/bookmark_list_item.dart` — same multi-select params added to `BookmarkListItem`. Uses `ListTile.leading` for `Checkbox` in multi-select mode.
- `lib/screens/bookmarks/bookmarks_screen.dart` — same pattern. Bulk action is "Remove bookmarks" (calls `ChaptersDao.bulkUnbookmark`, does NOT delete chapters). `_MultiSelectBar` uses bookmark-remove icon instead of trash.
- `lib/screens/resource_detail/resource_detail_screen.dart` — since ResourceDetail has its own Scaffold+AppBar, AppBar transforms properly (not in-body bar). In multi-select mode: AppBar shows close button + "N selected" + "Select all" + delete. Chapters rendered as a plain `Column` of checkable `ListTile`s in multi-select mode, and as `ReorderableListView` in normal mode. `PopScope` intercepts back press to exit multi-select before navigating away. Confirm dialog for bulk chapter delete mentions highlights will also be deleted.

**Design decisions:**
- **In-body action bar for shell routes (Highlights/Bookmarks)**: DrawerScaffold controls the AppBar for shell routes and doesn't have cross-widget AppBar transformation hooks. Rather than coupling DrawerScaffold to per-screen state, a `_MultiSelectBar` widget appears inside the body Column when multi-select is active. Functionally identical to AppBar transformation; cleaner architectural boundary.
- **Proper AppBar transformation for ResourceDetail**: Since ResourceDetail is a full-screen route with its own Scaffold, it can own its AppBar. The screen watches `resourceDetailMultiSelectProvider` and switches between two `AppBar` configurations.
- **Auto-dispose scoping**: Three separate named provider instances (one per screen) rather than a family. Auto-dispose guarantees each screen gets fresh selection state on mount — no stale selections bleeding across sessions.
- **`PopScope` in ResourceDetail**: Intercepts the Android back gesture/button to exit multi-select mode before popping the route, matching standard UX expectations.
- **Two chapter list implementations**: `_buildReorderableChapterList` (normal, drag-to-reorder) vs `_buildMultiSelectChapterList` (checkboxes, no drag handles). Switching between them on `isMultiSelect` change is cleaner than toggling handle visibility inline.

**Issues:** None. `flutter analyze` — no new issues (one pre-existing unused import in settings_screen.dart unrelated to this step).

**Verification:** Pending — learner to run all 3 multi-select flows per checklist acceptance criteria.

---

## /iterate

### Iteration 1

**Improvement requested:** "UX polish and UI jank resolve wherever applicable" — broad directive, no specific target.

**Review pass surfaced:**
- Reader blank screen flash on every open (`reader_screen.dart` init guard returns empty Scaffold during async `_init()`)
- Progress bar 2px permanent layout gap causes toolbar/WebView jitter on load start/stop (AnimatedOpacity doesn't collapse height)
- Highlights filter chips clear filter on tap instead of reopening picker — can't change filter without clearing first; avatar used for close icon instead of idiomatic `onDeleted`
- All bottom sheets lack drag handles; Note sheet has no title

**Items created:** 3 (I1, I2, I3) — all UX/polish, no data model changes needed.

**Learner approach:** Gave a broad "fix all" directive rather than naming specific items — comfortable delegating the audit. Less hands-on than during the structured build phase.
