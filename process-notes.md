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
