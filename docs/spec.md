# Read4ever — Technical Spec

## Stack

| Layer | Technology | Rationale |
|---|---|---|
| Framework | Flutter (stable) | Android-first; Aakash's primary stack |
| State management | Riverpod + `riverpod_annotation` (codegen) | Compile-safe providers, clean async handling via `AsyncValue` |
| Navigation | `go_router` | Declarative routing, ShellRoute for persistent drawer, typed extras |
| Database | Drift + `sqlite3_flutter_libs` | Type-safe SQLite ORM, native stream support, no backend |
| WebView | `flutter_inappwebview` | Bidirectional JS channels, `ContextMenu` API, `UserScript` injection — required for highlight feature |
| Data classes | `freezed` + `freezed_annotation` | Immutable UI state models, pattern matching, copyWith |
| Fonts | `google_fonts` | DM Sans |
| HTTP | `http` | Sitemap discovery (simple GETs, no auth, no interceptors needed) |
| XML parsing | `xml` | Sitemap XML parsing |
| Persistence | `shared_preferences` | Theme setting only |
| Share intent | `flutter_sharing_intent` | Android share sheet handling (text/URL); actively maintained (updated Nov 2025) |

**Documentation links:**
- Drift: https://drift.simonbinder.eu/docs/
- Riverpod: https://riverpod.dev/docs/introduction/getting_started
- go_router: https://pub.dev/documentation/go_router/latest/
- flutter_inappwebview: https://inappwebview.dev/docs/
- freezed: https://pub.dev/packages/freezed

---

## Runtime & Deployment

- **Target:** Android only, local-first, no backend, no sync
- **Run:** Android Studio or `flutter run` — Windows environment (`C:\Users\presyze\flutter\bin`)
- **For this build:** Local device/emulator. No Play Store config needed.
- **Future:** Play Store. Architecture does not block this — no hardcoded paths, no debug-only dependencies, no platform channels beyond what packages provide.
- **No API keys required.** All data is local SQLite.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter App                             │
│                                                                 │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌──────────────────┐ │
│  │ Library  │ │Bookmarks │ │ Highlights│ │    Settings      │ │
│  └────┬─────┘ └────┬─────┘ └─────┬─────┘ └────────┬─────────┘ │
│       │             │             │                 │            │
│  ┌────▼─────────────▼─────────────▼─────────────────▼────────┐ │
│  │                   Riverpod Providers                       │ │
│  │      (streams, notifiers, async state, freezed models)     │ │
│  └─────────────────────────┬──────────────────────────────────┘ │
│                            │                                     │
│  ┌─────────────────────────▼──────────────────────────────────┐ │
│  │              Drift DAOs  ←→  AppDatabase (SQLite)          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ ReaderScreen                                              │ │
│  │  ┌──────────────────┐   ┌─────────────────────────────┐  │ │
│  │  │  ReaderToolbar   │   │  flutter_inappwebview        │  │ │
│  │  │  (Flutter UI)    │   │  ContextMenu (Highlight/Note)│  │ │
│  │  └──────────────────┘   │  UserScript injection        │  │ │
│  │                         │  JsBridge ↔ HighlightService │  │ │
│  │                         └─────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ ImportScreen                                              │ │
│  │  SitemapService (http + xml) → ImportNotifier → Drift     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  IntentHandler ──→ context.push('/import?url=...')             │
│  (Android share sheet)                                          │
└─────────────────────────────────────────────────────────────────┘
```

**Data flow for the core loop:**

```
User shares URL (Chrome)
  → Android Intent → IntentHandler → context.push('/import?url=$url')
  → SitemapService: validate → deduplicate → discover sitemap → parse XML
  → ImportDialog: user selects chapters, confirms
  → ResourcesDao + ChaptersDao: write to SQLite
  → resourcesProvider (stream): emits updated list → LibraryScreen rebuilds
  → User taps Resume → ReaderScreen opens chapter URL in WebView
  → onPageFinished: JsBridge injects selection_listener.js + highlight_restore.js; ChaptersDao.updateTitle() from document.title
  → User selects text → ContextMenu → Highlight tapped
  → JsBridge.getSelection() (evaluateJavascript) → returns text + XPath
  → HighlightService: write to SQLite → inject visual mark via JS
```

---

## Design System

Implements: all screens. Defined in `lib/theme/`.

### Color Palette

```dart
// lib/theme/app_colors.dart

// Light mode
static const background     = Color(0xFFFFFFFF);
static const surface        = Color(0xFFF8FAFC);   // card/sheet backgrounds
static const border         = Color(0xFFE2E8F0);
static const textPrimary    = Color(0xFF0F172A);   // cool-tinted near-black
static const textSecondary  = Color(0xFF64748B);   // metadata, captions
static const accent         = Color(0xFF0D9488);   // teal-600
static const accentSubtle   = Color(0xFFCCFBF1);   // teal-100 — highlight tint, badges
static const onAccent       = Color(0xFFFFFFFF);

// Dark mode
static const backgroundDark  = Color(0xFF0F172A);
static const surfaceDark      = Color(0xFF1E293B);
static const borderDark       = Color(0xFF334155);
static const textPrimaryDark  = Color(0xFFF1F5F9);
static const textSecondaryDark = Color(0xFF94A3B8);
// accent stays the same — reads well on both
```

### Typography

Font: **DM Sans** (via `google_fonts`).

```dart
// lib/theme/app_theme.dart
textTheme: GoogleFonts.dmSansTextTheme().copyWith(
  displayLarge:  GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w600),
  titleLarge:    GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600),
  titleMedium:   GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
  bodyLarge:     GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400),
  bodyMedium:    GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400),
  labelSmall:    GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400),
)
```

### Shape & Spacing

```
Cards:          BorderRadius.circular(12)
Buttons/chips:  BorderRadius.circular(8)
Bottom sheets:  BorderRadius.vertical(top: Radius.circular(16))
Dialogs:        BorderRadius.circular(12)

Base spacing unit: 4px
Common: 8, 12, 16, 24, 32
```

### Component Overrides

In `app_theme.dart`, override:
- `CardTheme` — surface color, radius 12, subtle shadow (1dp elevation)
- `ElevatedButtonTheme` — accent fill, white text, radius 8
- `ProgressIndicatorTheme` — accent color for linear/circular indicators
- `BottomSheetTheme` — surface color, top radius 16
- `DrawerTheme` — surface color, no shadow
- `ListTileTheme` — consistent padding, bodyMedium style

### Dark Mode

`ThemeData.dark()` with the dark color constants above. The `ThemeNotifier` (see State Management) provides the current `ThemeMode` and persists it via `SharedPreferences`. Applied in `app.dart` via `MaterialApp.router(themeMode: ...)`.

---

## Navigation

### Shell Routes (Drawer)

`ShellRoute` wraps the 4 main destinations with a persistent `DrawerScaffold` widget:

```
ShellRoute (DrawerScaffold)
├── /library       → LibraryScreen
├── /bookmarks     → BookmarksScreen
├── /highlights    → HighlightsScreen
└── /settings      → SettingsScreen
```

The `DrawerScaffold` renders the `Drawer` with 4 `NavigationDrawerDestination` items. Active route is derived from `GoRouterState`. The scaffold's `AppBar` title updates based on current route.

### Full-Screen Routes

Push on top of the shell — no drawer chrome:

```
/resource/:id                   → ResourceDetailScreen
/reader/:chapterId              → ReaderScreen
/import                         → ImportScreen
```

- **ResourceDetailScreen:** pushed from Library via `context.push('/resource/$id')`
- **ReaderScreen:** pushed from Library (Resume), ResourceDetail, Bookmarks, Highlights. Uses `context.push('/reader/$chapterId', extra: ReaderContext(...))`  
- **ImportScreen:** pushed via `context.push('/import')` with URL passed via `ImportNotifier` (see below). Or from share sheet: `context.push('/import')` after pre-populating `ImportNotifier` with the URL.

### Chapter Navigation in Reader

Within the reader, navigating between chapters uses `context.pushReplacement('/reader/$newChapterId', extra: newContext)` with `CustomTransitionPage(transitionDuration: Duration.zero)`. Back button returns to the pre-reader screen correctly.

### Share Sheet Intent Handler

- Uses `flutter_sharing_intent` package — handles both cold start (app not running) and warm open (app in background), covers `ACTION_SEND` with `text/plain` MIME type
- `AndroidManifest.xml` intent filter configured per package docs
- Flutter side: `IntentHandler` service calls `FlutterSharingIntent.instance.getMediaStream()` for warm opens and `FlutterSharingIntent.instance.getInitialSharing()` for cold starts, pre-populates `ImportNotifier` with the URL, then calls `router.push('/import')` — only if ImportScreen is not already on the stack (check via `router.location`)

---

## Data Model

Implements: all epics. Defined in `lib/db/`.

### Resources Table

```dart
// lib/db/tables/resources.dart
class Resources extends Table {
  IntColumn get id           => integer().autoIncrement()();
  TextColumn get title       => text()();
  TextColumn get description => text().nullable()();
  TextColumn get url         => text()();          // root/sitemap URL
  DateTimeColumn get createdAt     => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()(); // updated on reader open
  IntColumn get lastOpenedChapterId => integer().nullable()
    .references(Chapters, #id)();
}
```

`lastAccessedAt` drives the Continue Reading strip (last 3 in-progress resources, sorted by this field DESC).

`lastOpenedChapterId` drives the Resume button. Updated every time the user opens a chapter from this resource.

### Chapters Table

```dart
// lib/db/tables/chapters.dart
class Chapters extends Table {
  IntColumn get id         => integer().autoIncrement()();
  IntColumn get resourceId => integer().references(Resources, #id,
    onDelete: KeyAction.cascade)();
  TextColumn get title     => text()();
  TextColumn get url       => text()();
  IntColumn  get position  => integer()();           // sort order
  BoolColumn get isDone    => boolean().withDefault(const Constant(false))();
  DateTimeColumn get bookmarkedAt => dateTime().nullable()(); // null = not bookmarked
  DateTimeColumn get createdAt    => dateTime()();
}
```

`bookmarkedAt` being non-null = bookmarked. Ordering in Bookmarks screen = `bookmarkedAt ASC` (preserves order bookmarks were added).

### Highlights Table

```dart
// lib/db/tables/highlights.dart
class Highlights extends Table {
  IntColumn get id          => integer().autoIncrement()();
  IntColumn get chapterId   => integer().references(Chapters, #id,
    onDelete: KeyAction.cascade)();
  TextColumn get selectedText => text()();
  TextColumn get xpathStart   => text()();
  TextColumn get xpathEnd     => text()();
  IntColumn  get startOffset  => integer()();   // char offset within text node
  IntColumn  get endOffset    => integer()();
  TextColumn get note         => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
```

Highlights are always chapter-scoped. Resource-level filtering in the Highlights screen is a JOIN: `highlights JOIN chapters ON highlights.chapter_id = chapters.id WHERE chapters.resource_id = ?`.

### Tags Table

```dart
// lib/db/tables/tags.dart
class Tags extends Table {
  IntColumn get id   => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}
```

### Resource Tags Table (Junction)

```dart
class ResourceTags extends Table {
  IntColumn get resourceId => integer().references(Resources, #id,
    onDelete: KeyAction.cascade)();
  IntColumn get tagId      => integer().references(Tags, #id,
    onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {resourceId, tagId};
}
```

### Drift Setup

```dart
// lib/db/database.dart
@DriftDatabase(tables: [Resources, Chapters, Highlights, Tags, ResourceTags],
               daos: [ResourcesDao, ChaptersDao, HighlightsDao, TagsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override int get schemaVersion => 1;
}
```

`AppDatabase` is a singleton, provided via Riverpod:
```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase();
```

### DAOs

One DAO per domain. Each DAO is a `DatabaseAccessor` with typed query methods.

**ResourcesDao** (`lib/db/daos/resources_dao.dart`):
- `watchAll()` → `Stream<List<ResourceWithStatus>>` — includes computed chapter counts + done counts, sorted (in-progress → not-started → done, then by `lastAccessedAt DESC`). Uses a custom Drift query with GROUP BY.
- `watchById(int id)` → `Stream<ResourceWithChapters>` — resource + all its chapters in position order
- `watchContinueReading()` → `Stream<List<ResourceWithChapter>>` — last 3 in-progress by `lastAccessedAt DESC`
- `insert(...)`, `update(...)`, `delete(int id)` (cascades via FK)
- `updateLastOpened(int resourceId, int chapterId)` — updates `lastOpenedChapterId` + `lastAccessedAt`

**ChaptersDao** (`lib/db/daos/chapters_dao.dart`):
- `watchByResource(int resourceId)` → `Stream<List<Chapter>>` ordered by `position`
- `setDone(int id, bool done)`, `toggleBookmark(int id)`, `reorder(List<int> ids)`
- `updateTitle(int id, String title)` — called from reader `onPageFinished` with `document.title`
- `bulkDelete(List<int> ids)`, `bulkUnbookmark(List<int> ids)`

**HighlightsDao** (`lib/db/daos/highlights_dao.dart`):
- `watchAll()` → `Stream<List<HighlightWithChapterAndResource>>`
- `watchByChapter(int chapterId)` → `Stream<List<Highlight>>` — used by reader for restore
- `insert(...)`, `updateNote(int id, String? note)`, `delete(int id)`, `bulkDelete(List<int> ids)`
- `deleteAll()` — used by Settings > Delete All Data

**TagsDao** (`lib/db/daos/tags_dao.dart`):
- `watchAll()` → `Stream<List<Tag>>`
- `watchByPrefix(String prefix)` → `Stream<List<Tag>>` — for autocomplete
- `addTagToResource(int resourceId, String name)` — upserts tag, inserts junction
- `removeTagFromResource(int resourceId, int tagId)`
- `deleteAll()`

---

## State Management

All providers use `riverpod_annotation` codegen. All async providers surface `AsyncValue<T>` — every consumer handles `loading`, `data`, and `error` states explicitly. No silent failures.

### Provider Architecture

```
UI (Screens/Widgets)
    ↓ watches/reads
Riverpod Providers
    ↓ calls
DAOs / Services
    ↓ reads/writes
Drift (SQLite)
```

Drift DAOs return `Stream<T>` → Riverpod `StreamProvider` wraps them → `ref.watch()` in widget rebuilds on DB change automatically.

### Resource Providers

```dart
// lib/providers/resources_provider.dart

@riverpod
Stream<List<ResourceWithStatus>> resources(ResourcesRef ref) =>
  ref.watch(appDatabaseProvider).resourcesDao.watchAll();

@riverpod
Stream<ResourceWithChapters> resourceDetail(ResourceDetailRef ref, int id) =>
  ref.watch(appDatabaseProvider).resourcesDao.watchById(id);

@riverpod
Stream<List<ResourceWithChapter>> continueReading(ContinueReadingRef ref) =>
  ref.watch(appDatabaseProvider).resourcesDao.watchContinueReading();
```

### Highlight Providers

```dart
@riverpod
Stream<List<HighlightWithChapterAndResource>> highlights(HighlightsRef ref) =>
  ref.watch(appDatabaseProvider).highlightsDao.watchAll();

@riverpod
Stream<List<Highlight>> chapterHighlights(ChapterHighlightsRef ref, int chapterId) =>
  ref.watch(appDatabaseProvider).highlightsDao.watchByChapter(chapterId);

// Filter state for Highlights screen
@freezed
class HighlightFilter with _$HighlightFilter {
  const factory HighlightFilter({int? resourceId, int? chapterId}) = _HighlightFilter;
}

@riverpod
class HighlightFilterNotifier extends _$HighlightFilterNotifier {
  @override HighlightFilter? build() => null;
  void filterByResource(int id) => state = HighlightFilter(resourceId: id);
  void filterByChapter(int id)  => state = HighlightFilter(chapterId: id);
  void clearFilter()            => state = null;
}
```

### Bookmark Provider

```dart
@riverpod
Stream<List<ChapterWithResource>> bookmarks(BookmarksRef ref) =>
  ref.watch(appDatabaseProvider).chaptersDao.watchBookmarked();
// watchBookmarked: chapters WHERE bookmarked_at IS NOT NULL ORDER BY bookmarked_at ASC
```

### Import Provider

```dart
@freezed
class ImportState with _$ImportState {
  const factory ImportState({
    @Default('') String url,
    @Default(ImportStatus.idle) ImportStatus status,
    @Default([]) List<SitemapPage> pages,
    @Default({}) Set<int> selectedIndexes,  // selected page indexes
    @Default(2) int maxDepth,
    @Default('') String resourceName,
    @Default('') String description,
    String? errorMessage,
  }) = _ImportState;
}

@riverpod
class ImportNotifier extends _$ImportNotifier {
  @override ImportState build() => const ImportState();
  void setUrl(String url) ...
  Future<void> discover() ...       // runs sitemap discovery
  void togglePage(int index) ...
  void setMaxDepth(int depth) ...
  void setResourceName(String name) ...
  Future<void> confirm() ...        // writes to Drift, returns resource id
  void reset() ...
}
```

### Reader Provider

```dart
@freezed
class ReaderContext with _$ReaderContext {
  const factory ReaderContext({
    @Default(ReaderSource.library) ReaderSource source,
    List<int>? adjacentChapterIds,    // [prevId, nextId] — for bookmarks nav
    int? scrollToHighlightId,         // navigate to specific highlight
  }) = _ReaderContext;
}

enum ReaderSource { library, resourceDetail, bookmarks, highlights }

@freezed
class ReaderState with _$ReaderState {
  const factory ReaderState({
    required int chapterId,
    @Default(true) bool isLoading,
    required ReaderContext context,
  }) = _ReaderState;
}

@riverpod
class ReaderNotifier extends _$ReaderNotifier {
  @override ReaderState build(int chapterId, ReaderContext context) =>
    ReaderState(chapterId: chapterId, context: context);
  void setLoading(bool loading) ...
}
```

### Theme Provider

```dart
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _key = 'theme_mode';
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    return ThemeMode.values.firstWhere((m) => m.name == stored,
      orElse: () => ThemeMode.system);
  }
  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
    state = mode;
  }
}
```

### Multi-Select State (Shared Pattern)

Used on Library (for resources), ResourceDetail (chapters), Highlights, Bookmarks screens:

```dart
@riverpod
class MultiSelectNotifier extends _$MultiSelectNotifier {
  @override Set<int> build() => {};
  void toggle(int id) ...
  void selectAll(List<int> ids) ...
  void clear() ...
}
```

Each screen instantiates its own scoped notifier. Long-press enters multi-select mode (`state.isNotEmpty`). AppBar transforms to show count + select all + delete.

---

## Import System

Implements: `prd.md > Importing Resources`

### URL Validation

```dart
// lib/services/sitemap_service.dart
bool isValidUrl(String url) => Uri.tryParse(url)?.hasAbsolutePath ?? false;
// Reject empty, non-HTTP/S, malformed
```

### Duplicate Detection

Before any network call:
1. Query `ChaptersDao` for exact URL match → if found, `router.push('/reader/$chapterId')` directly
2. Query `ResourcesDao` for exact URL match → if found, `router.push('/resource/$id')` directly
3. No match → proceed to sitemap discovery

### Sitemap Discovery

```dart
// lib/services/sitemap_service.dart
Future<SitemapResult?> discover(String url, {int maxDepth = 2}) async {
  // Attempt 1: GET {url}/sitemap.xml
  // Attempt 2: GET {url}/sitemap_index.xml
  // Attempt 3: GET {url} → parse <head> for <link rel="sitemap" href="...">
  // If all fail → return null (triggers single-chapter fallback)
  // If found → parseSitemap(sitemapUrl, maxDepth: maxDepth)
}

Future<List<SitemapPage>> parseSitemap(String sitemapUrl, {
  int currentDepth = 0, required int maxDepth
}) async {
  // Fetch XML → parse with `xml` package
  // If <sitemapindex>: recurse child <sitemap> entries up to maxDepth
  // If <urlset>: extract <loc> entries → SitemapPage(url, title)
  // Title derived from <loc> path segment (e.g. /docs/getting-started → "Getting Started")
  // This is a placeholder — the real page title is fetched lazily in the reader via document.title
}
```

**Fallback behavior:** If discovery returns `null`, `ImportNotifier` shows a `SnackBar` ("Couldn't detect other chapters — importing as a single resource") and proceeds with the single-page import dialog.

### Import Dialog

**Implements:** `prd.md > Importing Resources` — two-mode dialog for both multi-chapter and standalone imports.

Same dialog shown for both cases. Shown as a `showModalBottomSheet` (not a full screen push):

**Simple mode (default):**
- Chapter list as checkboxes (all selected by default)
- For standalone: single checkbox, locked (cannot deselect only chapter)
- Resource name not visible
- `[Advanced ▾]` button to expand
- `[Cancel]` `[Import]` actions

**Advanced mode (expanded):**
- `ReorderableListView` for chapter reordering
- Resource name text field (auto-derived from page `<title>` or URL)
- Description text field
- Depth stepper: `[−] 2 [+]` (range 1–4), with "Re-scan" button to re-fetch at new depth
- Collapse back to simple with `[Simple ▴]`

Minimum 1 chapter must always be selected — deselecting the last one is blocked.

### Import Confirmation & Database Write

On confirm:
1. `ResourcesDao.insert(title, description, url)` → returns `resourceId`
2. `ChaptersDao.insertAll(chapters)` — with `position` index from selected order
3. `ResourcesDao.updateLastOpened(resourceId, firstChapterId)` — sets resume target to first chapter
4. `router.pop()` (close dialog) → `router.push('/reader/$firstChapterId', extra: ReaderContext())`

---

## Reader

Implements: `prd.md > Reading`

### ReaderScreen Structure

```
ReaderScreen (Scaffold)
├── Column
│   ├── ReaderToolbar          (always visible, height 56)
│   ├── LinearProgressIndicator (teal, shows during load, height 2)
│   └── Expanded
│       └── InAppWebView
│           ├── contextMenu: ContextMenu (Highlight + Add Note)
│           ├── onLoadStart: readerNotifier.setLoading(true)
│           ├── onLoadStop: _onPageLoaded() — inject scripts, restore highlights, update chapter title
│           ├── onLoadError: show ErrorState widget overlay
│           └── initialSettings: InAppWebViewSettings(
│                 javaScriptEnabled: true,
│                 supportZoom: false,
│                 transparentBackground: false)
```

### ReaderToolbar

```
[←]  [Chapter title / dropdown ▾]  [🔖]  [✓]
```

- **Back:** `context.pop()`
- **Chapter dropdown:** taps open a `showModalBottomSheet` listing all chapters in the resource with trailing `✓` icon for done chapters. Tapping a chapter calls `context.pushReplacement('/reader/$newId', extra: newContext)` with `CustomTransitionPage(transitionDuration: Duration.zero)`
- **Bookmark toggle:** calls `ChaptersDao.toggleBookmark(chapterId)`. Icon fills (teal) when bookmarked.
- **Done toggle:** calls `ChaptersDao.setDone(chapterId, !isDone)`. Icon fills (teal) when done. Triggers resource status recomputation via stream.

Toolbar reads `chapterHighlightsProvider` and `resourceDetailProvider` — rebuilds reactively.

### Chapter Navigation

`context.pushReplacement` with `CustomTransitionPage(transitionDuration: Duration.zero)` — seamless chapter swap. A thin `LinearProgressIndicator` below the toolbar shows during `onLoadStart` → `onLoadStop`. Back button exits the reader entirely (returns to pre-reader screen).

### Error State

If `onLoadError` fires (offline, dead URL):
```
Center column:
  Icon(offline)
  Text("Couldn't load this page")
  ElevatedButton("Retry") → webView.reload()
```

Shown as an overlay on top of the WebView (not replacing it), so the toolbar remains functional.

### Scroll Position

In-memory only. `InAppWebView` retains scroll position while the app is alive. On full close and reopen, chapter opens at the top. Scroll-to-disk is deferred to v2.

**Exception:** when `ReaderContext.scrollToHighlightId` is non-null (opened from Highlights screen), after `onLoadStop` and highlight restore, call `jsBridge.scrollToHighlight(highlightId)` — JS finds the `<mark data-id="$id">` and scrolls it into view.

---

## Highlighting System

Implements: `prd.md > Highlighting and Notes`

### Text Selection (ContextMenu)

```dart
// lib/screens/reader/reader_screen.dart
ContextMenu(
  menuItems: [
    ContextMenuItem(
      title: 'Highlight',
      androidId: 1,
      action: () async {
        final sel = await jsBridge.getSelection();
        if (sel == null) return;
        await highlightService.createHighlight(chapterId, sel, note: null);
      },
    ),
    ContextMenuItem(
      title: 'Add Note',
      androidId: 2,
      action: () async {
        final sel = await jsBridge.getSelection();
        if (sel == null) return;
        _showNoteBottomSheet(chapterId, sel);   // user types note, then saves
      },
    ),
  ],
)
```

Uses the native Android text selection toolbar — no custom positioning, no overlay edge cases. Reliable and consistent with system UX.

### JS Bridge

```dart
// lib/services/js_bridge.dart
// Low-level WebView interop — channel registration and script injection only.
// No domain logic.

class JsBridge {
  final InAppWebViewController controller;

  Future<void> injectScripts() async {
    final selectionScript  = await rootBundle.loadString('assets/js/selection_listener.js');
    final restoreScript    = await rootBundle.loadString('assets/js/highlight_restore.js');
    await controller.evaluateJavascript(source: selectionScript);
    await controller.evaluateJavascript(source: restoreScript);
  }

  Future<SelectionData?> getSelection() async {
    final result = await controller.evaluateJavascript(
      source: 'JSON.stringify(window.__read4ever_getSelection())');
    // parses and returns SelectionData(text, xpathStart, xpathEnd, startOffset, endOffset)
  }

  Future<void> applyHighlight(int id, String xpathStart, String xpathEnd,
    int startOffset, int endOffset) async { ... }

  Future<void> restoreHighlights(List<Highlight> highlights) async { ... }

  Future<void> scrollToHighlight(int id) async { ... }
}
```

### Highlight Service

```dart
// lib/services/highlight_service.dart
// Domain logic — owns highlight creation, restore sequencing, Drift writes.

class HighlightService {
  Future<void> createHighlight(int chapterId, SelectionData sel, {String? note}) async {
    final highlight = await highlightsDao.insert(
      chapterId: chapterId,
      selectedText: sel.text,
      xpathStart: sel.xpathStart, xpathEnd: sel.xpathEnd,
      startOffset: sel.startOffset, endOffset: sel.endOffset,
      note: note,
    );
    await jsBridge.applyHighlight(highlight.id, ...);
  }

  Future<void> restoreForChapter(int chapterId) async {
    final highlights = await highlightsDao.getByChapter(chapterId);
    await jsBridge.restoreHighlights(highlights);
  }
}
```

### XPath Storage

XPath format: `//tagName[n]/tagName[n]/...` from document root to the text node containing the selection anchor/focus. Stored as `xpathStart` + `xpathEnd` + `startOffset` + `endOffset` (character offsets within the text node).

**Selection listener script (`assets/js/selection_listener.js`):**
- Exposed as `window.__read4ever_getSelection()` — called by Flutter on ContextMenu action
- Returns `{ text, xpathStart, xpathEnd, startOffset, endOffset }` or `null` if no selection
- XPath helper: walks `node.parentNode` chain building positional path

### Highlight Restore

**Restore script (`assets/js/highlight_restore.js`):**
- Exposed as `window.__read4ever_restoreHighlights(highlightsJson)`
- For each highlight: resolves XPath → creates a `Range` → wraps matched text in `<mark class="ls-highlight" data-id="$id" style="background:#CCFBF1; border-radius:2px;">`
- If XPath resolution fails (DOM changed after save): silently skip that highlight, log a warning

Called by `HighlightService.restoreForChapter()` in `onLoadStop`.

### Note Bottom Sheet

When "Add Note" is tapped from ContextMenu:
- `showModalBottomSheet` with a `TextField` (multiline, autofocus)
- `[Cancel]` and `[Save]` actions
- On save: `highlightService.createHighlight(..., note: noteText)`
- Note can be edited later from the Highlights screen bottom sheet

---

## Library Screen

Implements: `prd.md > Library`

### Resource Cards

`ListView` of `ResourceCard` widgets, driven by `ref.watch(resourcesProvider)`.

Each `ResourceCard`:
- Title (titleMedium, textPrimary)
- Description (bodyMedium, textSecondary, max 2 lines, ellipsis)
- Row: chapter count label + `LinearProgressIndicator` (teal, `doneCount / totalCount`)
- `[Resume]` button (accent fill) → `context.push('/reader/$lastOpenedChapterId', extra: ReaderContext())`
- Tap card body → `context.push('/resource/$id')`

**Done resource treatment:** full-width 100% progress bar, card title + description at `textSecondary` opacity (muted). Card positioned at bottom of list (handled by DAO sort query).

### Continue Reading Strip

Horizontal `ListView` of up to 3 in-progress resources, driven by `ref.watch(continueReadingProvider)`.

Each entry:
- Resource title only (bodyMedium, single line, ellipsis)
- Tap → `context.push('/reader/$lastOpenedChapterId', extra: ReaderContext())`

Strip is hidden if `continueReading.isEmpty`.

### Sort Order

Defined in `ResourcesDao.watchAll()` SQL:

```sql
ORDER BY
  CASE
    WHEN done_count = total_count AND total_count > 0 THEN 2  -- done → bottom
    WHEN done_count > 0 THEN 0                                 -- in-progress → top
    ELSE 1                                                     -- not started → middle
  END ASC,
  r.last_accessed_at DESC NULLS LAST                          -- most recent first within group
```

### Empty State

On first launch (`resources.isEmpty`):
```
Center:
  Icon (large, textSecondary)
  Text("Your library is empty", style: titleMedium)
  Text("Tap + to import your first resource", style: bodyMedium, textSecondary)
```

FAB points downward toward the bottom-right FAB button.

### FAB

`FloatingActionButton` bottom-right → `context.push('/import')`.

---

## Resource Management

Implements: `prd.md > Resource Management`

### Resource Detail Screen

Route: `/resource/:id`. Driven by `ref.watch(resourceDetailProvider(id))`.

Sections:
1. **Header:** Editable title (`TextField`, inline), editable description (`TextField`)
2. **Tags:** Tag chip row + autocomplete input (see Tag System below)
3. **Track:** — (removed; tags replace this)
4. **Chapters:** `ReorderableListView` of chapters with done checkmarks, drag handles, and delete-per-item button
5. **Import more chapters:** `[+ Import more chapters]` button → opens ImportScreen pre-filled with the resource URL and existing chapters filtered out
6. **Delete resource:** `[Delete Resource]` (destructive, bottom of screen)

### Tag System

```
Tag input field (TextFormField)
  → ref.watch(tagsProvider.select(tags => tags.where(t => t.name.startsWith(input))))
  → shows Autocomplete dropdown of matching existing tags
  → user selects existing or presses Enter/comma to create new
  → TagsDao.addTagToResource(resourceId, name)
```

Tags displayed as `InputChip` widgets (deletable) above the input field.

### Chapter List Management

- **Reorder:** `ReorderableListView` → on reorder end, `ChaptersDao.reorder(newIdOrder)`
- **Delete individual:** swipe-to-dismiss or trailing delete icon → `ChaptersDao.delete(id)` (confirm dialog if chapter has highlights)
- **Import more:** triggers the same `SitemapService.discover()` flow, pre-selects only chapters whose URLs aren't already in the resource

### Delete Resource

`[Delete Resource]` → confirmation `AlertDialog`:
```
"Delete [Resource Name]?"
"This will permanently delete X highlights and Y bookmarks."
[Cancel]  [Delete]
```
Counts fetched from `HighlightsDao.countByResource(id)` and `ChaptersDao.countBookmarkedByResource(id)`.

Confirm → `ResourcesDao.delete(id)` (cascades to chapters, highlights via FK `onDelete: cascade`).

### Multi-Select Pattern

Used consistently across: ResourceDetail (chapters), Highlights screen, Bookmarks screen.

1. **Long press** any list item → enter multi-select mode
2. **AppBar transforms:**
   - Title: "$n selected"
   - Actions: `[Select All]` `[✕ Clear]` `[🗑 Delete]`
3. Items show leading checkboxes
4. `[Delete]` → confirmation dialog → bulk delete via DAO
5. Tapping outside multi-select (or clearing selection) → exits mode

---

## Highlights Screen

Implements: `prd.md > Highlights Screen`

Driven by `ref.watch(highlightsProvider)` filtered by `ref.watch(highlightFilterNotifierProvider)`.

### List & Filtering

`ListView` of `HighlightListItem` widgets.

Each item:
- Highlighted text (bodyMedium, max 2 lines, ellipsis by default)
- Resource name + chapter name (labelSmall, textSecondary)
- Note preview if present (bodyMedium, italic, textSecondary)

**Filter bar** (shown at top when list is non-empty): two `ChoiceChip` dropdowns — "All resources" and "All chapters". Selecting one updates `HighlightFilterNotifier`. Clearing resets to `null` (show all).

### Expand/Collapse

Double-tap a `HighlightListItem` → toggles between 2-line truncated and full text expanded. Local widget state (not persisted).

### Bottom Sheet

Tap a `HighlightListItem` → `showModalBottomSheet`:
```
[Chapter title] in [Resource name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Full highlighted text
[Edit note / Add note]  →  opens note text field inline in sheet
[Open in reader]        →  context.push('/reader/$chapterId', extra:
                             ReaderContext(source: ReaderSource.highlights,
                                          scrollToHighlightId: id))
[Delete]                →  HighlightsDao.delete(id), pop sheet
```

### Multi-Select

Same pattern as defined in Resource Management > Multi-Select Pattern. `HighlightsDao.bulkDelete(ids)`.

---

## Bookmarks Screen

Implements: `prd.md > Bookmarks Screen`

Driven by `ref.watch(bookmarksProvider)` — chapters where `bookmarkedAt IS NOT NULL`, ordered by `bookmarkedAt ASC`.

### Bookmark List

`ListView` of `BookmarkListItem`:
- Chapter title (bodyMedium)
- Resource name (labelSmall, textSecondary)
- Tap → open reader with bookmarks context:
  ```dart
  final idx = bookmarks.indexOf(chapter);
  context.push('/reader/$chapterId', extra: ReaderContext(
    source: ReaderSource.bookmarks,
    adjacentChapterIds: [
      idx > 0 ? bookmarks[idx-1].id : null,
      idx < bookmarks.length-1 ? bookmarks[idx+1].id : null,
    ].whereType<int>().toList(),
  ));
  ```

### Prev/Next Navigation

When `ReaderState.context.source == ReaderSource.bookmarks` and `adjacentChapterIds` is non-empty, the reader shows two `FloatingActionButton`s (bottom-right, stacked vertically):
- `[← Prev bookmark]` — navigates to `adjacentChapterIds[0]` via `pushReplacement`
- `[Next bookmark →]` — navigates to `adjacentChapterIds[1]` via `pushReplacement`

FABs hidden when there is no prev/next respectively.

### Multi-Select

Same pattern. Removes bookmark (sets `bookmarkedAt = null`) rather than deleting the chapter. `ChaptersDao.bulkUnbookmark(ids)`.

---

## Settings Screen

Implements: `prd.md > Settings`

### Theme Selector

Three-way segmented button or `RadioListTile` group:
- `Light` | `Dark` | `System`
- Calls `themeNotifier.setTheme(ThemeMode.X)` on selection
- Persists via `SharedPreferences` (see ThemeNotifier)

### Delete All Data

`ListTile` with destructive red label → `AlertDialog`:
```
"Delete all data?"
"This will permanently delete all resources, chapters, highlights, and bookmarks.
 This cannot be undone."
[Cancel]  [Delete Everything]
```
Confirm →
1. `HighlightsDao.deleteAll()`
2. `ResourcesDao.deleteAll()` (cascades to chapters via FK)
3. `TagsDao.deleteAll()`
4. `router.go('/library')` — back to empty state

---

## File Structure

```
read4ever/
├── lib/
│   ├── main.dart                             # runApp, ProviderScope
│   ├── app.dart                              # MaterialApp.router, theme wiring
│   ├── router.dart                           # go_router config, ShellRoute, routes
│   │
│   ├── db/
│   │   ├── database.dart                     # AppDatabase Drift definition
│   │   ├── database.g.dart                   # (generated — do not edit)
│   │   ├── tables/
│   │   │   ├── resources.dart
│   │   │   ├── chapters.dart
│   │   │   ├── highlights.dart
│   │   │   └── tags.dart
│   │   └── daos/
│   │       ├── resources_dao.dart
│   │       ├── chapters_dao.dart
│   │       ├── highlights_dao.dart
│   │       └── tags_dao.dart
│   │
│   ├── providers/
│   │   ├── providers.g.dart                  # (generated — do not edit)
│   │   ├── database_provider.dart            # AppDatabase singleton provider
│   │   ├── resources_provider.dart
│   │   ├── highlights_provider.dart
│   │   ├── bookmarks_provider.dart
│   │   ├── import_provider.dart
│   │   ├── reader_provider.dart
│   │   ├── theme_provider.dart
│   │   └── multi_select_provider.dart
│   │
│   ├── services/
│   │   ├── sitemap_service.dart              # URL validation, discovery, XML parsing
│   │   ├── intent_handler.dart               # Android share sheet intent → Flutter
│   │   ├── js_bridge.dart                    # WebView interop (inject, evaluate, channel)
│   │   └── highlight_service.dart            # Highlight domain logic, Drift writes
│   │
│   ├── screens/
│   │   ├── library/
│   │   │   ├── library_screen.dart
│   │   │   └── widgets/
│   │   │       ├── resource_card.dart
│   │   │       └── continue_reading_strip.dart
│   │   ├── resource_detail/
│   │   │   ├── resource_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── chapter_list_item.dart
│   │   │       └── tag_input.dart
│   │   ├── reader/
│   │   │   ├── reader_screen.dart
│   │   │   ├── reader_toolbar.dart
│   │   │   └── widgets/
│   │   │       ├── chapter_dropdown_sheet.dart
│   │   │       └── reader_error_state.dart
│   │   ├── import/
│   │   │   ├── import_screen.dart
│   │   │   └── widgets/
│   │   │       ├── sitemap_chapter_list.dart   # checkbox list (simple mode)
│   │   │       └── advanced_import_panel.dart  # reorder + name + depth stepper
│   │   ├── highlights/
│   │   │   ├── highlights_screen.dart
│   │   │   └── widgets/
│   │   │       ├── highlight_list_item.dart
│   │   │       └── highlight_bottom_sheet.dart
│   │   ├── bookmarks/
│   │   │   ├── bookmarks_screen.dart
│   │   │   └── widgets/
│   │   │       └── bookmark_list_item.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   │
│   ├── models/
│   │   ├── resource_with_status.dart         # Drift result class + freezed
│   │   ├── resource_with_chapters.dart
│   │   ├── highlight_with_chapter.dart
│   │   ├── chapter_with_resource.dart
│   │   ├── sitemap_page.dart                 # freezed — URL + title from sitemap
│   │   ├── selection_data.dart               # freezed — XPath selection from JS
│   │   └── reader_context.dart               # freezed — navigation context for reader
│   │
│   └── theme/
│       ├── app_theme.dart                    # ThemeData light + dark, component overrides
│       └── app_colors.dart                   # Named color constants
│
├── assets/
│   └── js/
│       ├── selection_listener.js             # exposes window.__read4ever_getSelection()
│       └── highlight_restore.js              # exposes window.__read4ever_restoreHighlights()
│
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml               # ACTION_SEND intent filter, permissions
│       └── kotlin/.../MainActivity.kt        # intent interception → Flutter channel
│
├── docs/
│   ├── learner-profile.md
│   ├── scope.md
│   ├── prd.md
│   └── spec.md                               # this file
│
├── process-notes.md
└── pubspec.yaml
```

---

## Key Technical Decisions

### 1. `flutter_inappwebview` over `webview_flutter`

**Decided:** Use `flutter_inappwebview` as the WebView package.
**Why:** The highlighting feature requires bidirectional JS channels (`addJavaScriptHandler` / `callHandler`), `evaluateJavascript` with return values (for getting selection XPath back into Dart), `ContextMenu` API for native text selection integration, and `UserScript` injection timing. `webview_flutter` only supports one-way channels and has no `ContextMenu` API. The highlight feature would require fragile workarounds on `webview_flutter`.
**Tradeoff accepted:** Heavier dependency, more complex API. Worth it given highlights are a core feature.

### 2. Native Android ContextMenu for highlight toolbar

**Decided:** Use `flutter_inappwebview`'s `ContextMenu` API to add "Highlight" and "Add Note" items to the system text selection toolbar.
**Why:** The most reliable and consistent approach. Uses Android's built-in text selection mechanism — no JavaScript-based selection detection, no custom Flutter overlay positioning, no edge cases with scrolled WebView content. Familiar to users.
**Tradeoff accepted:** Menu items follow system styling (not custom-designed). Acceptable for a developer tool.

### 3. `bookmarked_at` nullable timestamp on Chapters (not separate Bookmarks table)

**Decided:** Store bookmark state as a nullable `DateTime` column on the `chapters` table.
**Why:** Bookmarks are 1:1 with chapters (a chapter is either bookmarked or not). The timestamp gives us ordering for the Bookmarks screen with no extra JOIN. A separate table would add a join for every chapters query with no practical benefit.
**Tradeoff accepted:** Schema is slightly less normalized. Acceptable — this is a local SQLite database with a small dataset.

---

## Dependencies

```yaml
# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter
  
  # State
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  
  # Navigation
  go_router: ^14.x
  
  # Database
  drift: ^2.x
  drift_flutter: ^0.x
  sqlite3_flutter_libs: ^0.x
  
  # WebView
  flutter_inappwebview: ^6.x
  
  # Data classes
  freezed_annotation: ^2.x
  json_annotation: ^4.x
  
  # Fonts
  google_fonts: ^6.x
  
  # HTTP & parsing
  http: ^1.x
  xml: ^6.x
  
  # Storage
  shared_preferences: ^2.x
  
  # Share sheet
  flutter_sharing_intent: ^2.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.x
  build_runner: ^2.x
  drift_dev: ^2.x
  riverpod_generator: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
```

**No external APIs, no API keys, no rate limits.** All data is local.

---

## Open Issues

### 1. Highlight restore on DOM change
**Issue:** If a docs site updates its page structure after a highlight is saved, the stored XPath may no longer resolve to the correct node (or any node). The current spec silently skips unresolvable highlights.
**Decision needed at build:** Accept silent skip + optional user-facing indicator ("Some highlights couldn't be restored"), or proactively warn the user when a highlight is unresolvable. Can wait until build.

### 2. ~~Sitemap title extraction~~ — Resolved
**Decision:** Two-phase title resolution:
1. **Import time:** Derive chapter title from URL path segment (`/docs/getting-started` → "Getting Started") — fast, no extra HTTP requests
2. **Reader `onPageFinished`:** `evaluateJavascript("document.title")` → if non-empty, call `ChaptersDao.updateTitle(chapterId, pageTitle)` — auto-updates title in Drift, propagates reactively to all screens (chapter dropdown, Resource Detail, Highlights screen)

**Chapter titles are not user-editable** — they are set exclusively by this auto-update mechanism. Resource title is derived from root URL at import time or user-entered in advanced mode, and is not auto-updated.

### 3. ~~Intent handler platform channel~~ — Resolved
**Decision:** Use `flutter_sharing_intent` package (updated November 2025, actively maintained). Handles cold start and warm open. Original `receive_sharing_intent` is no longer maintained; `flutter_sharing_intent` is the current recommended alternative. No custom platform channel needed.
