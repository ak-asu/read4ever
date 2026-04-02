# Read4ever

Read4ever is an Android-first learning companion that turns scattered docs and tutorials into a structured, trackable reading workflow.

Instead of losing links in tabs or notes, you can import resources, read in-app, highlight key ideas, bookmark chapters, and track progress in one place.

## Core Features

- Smart URL import from share sheet or in-app input
- Multi-chapter discovery for docs sites (with chapter selection)
- Duplicate detection to avoid re-importing existing resources
- Library view with progress and continue-reading flow
- Full-screen reader with chapter switcher, bookmark toggle, and done toggle
- Text highlights with optional notes
- Dedicated Highlights and Bookmarks screens
- Light, dark, and system theme support
- Local-first storage (no backend required)

## Tech Stack

- Flutter (Android target)
- Riverpod + codegen for state management
- Drift + SQLite for local persistence
- go_router for navigation
- flutter_inappwebview for reading and text selection integrations

## Project Structure

- `read4ever/` Flutter application source
- `docs/` product scope, PRD, and technical notes

## Run Locally

From the project root:

```bash
cd read4ever
flutter pub get
flutter run
```

## Vision

Read4ever is built for self-learners who want momentum, not a link graveyard: import what matters, read with focus, annotate in context, and finish what you start.
