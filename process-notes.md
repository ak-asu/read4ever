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
- Core story confirmed: "LearnStack turns scattered online docs and guides into structured, trackable reading units"
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
- `lib/app.dart` — stub `LearnStackApp` (MaterialApp with light/dark theme, placeholder home screen showing teal ElevatedButton)
- `lib/main.dart` — `runApp` wrapped in `ProviderScope`
- `flutter pub get` ran successfully: 101 packages resolved

**Issues:** None. All dependencies resolved cleanly.

**Verification:** Pending — learner to run `flutter run` and confirm DM Sans renders, teal accent visible, no errors.
