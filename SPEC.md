# Cordon — Build Specification

> Portfolio app 230, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Save loose cash by hand toward a goal and grow it when you commit each payday batch.

| Field | Value |
| --- | --- |
| Product name | Cordon |
| Bundle identifier | `com.cordon.canopy` |
| Domain | https://cordon-canopy.pro |
| Contact URL | https://cordon-canopy.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `cdn_` |
| User-Agent | `Cordon/1.0 (iOS; +https://cordon-canopy.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Cordon -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A cash saver drops each hand deposit into a tray and sets the batch so the canopy vine grows only when a payday commit lands.

### 2.1 User flow

1. Tap Set on the action strip to commit the two seeded tray drops and advance the neon vine one canopy step
2. Plant a named goal and target amount on the cordon header
3. Drop the next hand deposit amount into the tray after payday or a side gig
4. Review the Swift Charts shaded band and SetMark timeline in Analytics
5. Mark the goal Ripe when canopy height reaches the target wire
6. Peel the last Drop from the tray or reset the garden from Settings

### 2.2 Essential behaviour

- Manual Drop amounts with no bank link
- Tray versus committed CanopyTotal separation
- Set batch commit with SpriteKit vine swell animation
- Swift Charts cumulative canopy band on home
- SetMark history keyed by daykey in Analytics
- Local UserDefaults persistence and CSV export from Settings

---

## 3. Uniqueness assignment for Cordon

| Axis | Assigned value |
| --- | --- |
| Architecture | **Canopy ADT fold (Bare | Trayed | Canopied); the cordon is a fold over SetMarks; Drop writes a DropMark and adds amount to Tray, folding Bare to Trayed; Set writes a SetMark, moves Tray sum into CanopyTotal, clears Tray, and folds Trayed to Canopied when CanopyTotal reaches target else back to Bare; Set on Bare or empty Tray writes HollowMark; Drop on Ripe writes RipeMark; Retract removes the last DropMark from Tray only; an unstaked cordon writes Bare** |
| UI approach | **SwiftUI RealityKit particle background · canvas-first** |
| Naming convention | **Cordon / canopy lexicon (Cordon, Goal, Tray, DropMark, SetMark, CanopyTotal, HollowMark, RipeMark, Wire, Peel)** |
| File organization | **By canopy role (Cordon, Goal, Tray, DropMark, SetMark, CanopyTotal, HollowMark, RipeMark, Wire)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **cal · ledger · high-contrast** |
| Typography | **Menlo** |
| Navigation pattern | **Canopy-locked chrome (the side-view cordon and Charts band never leave; the tray and fused drop-set verbs sit in the action strip; Analytics and Settings arrive as sheets; no tab bar)** |
| AI art style | **Neon outline glowing line art · tactile** |
| Functional twist | **Drop-then-set (drop fills tray; set commits the whole tray into canopy height; unpooled drops never move the vine)** |
| Persistence | **UserDefaults+Codable · one Grid root record holding Pets, Routines, Cues and Marks, encoded under a single key with debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — savings_vine

**Core** — A cash saver drops each hand deposit into a tray and sets the batch so the canopy vine grows only when a payday commit lands.

**Audience** — People who stash loose cash between paydays and want the plant to move on deliberate set days, not on every coin typed or a bank feed.

**User flow**

1. Tap Set on the action strip to commit the two seeded tray drops and advance the neon vine one canopy step
2. Plant a named goal and target amount on the cordon header
3. Drop the next hand deposit amount into the tray after payday or a side gig
4. Review the Swift Charts shaded band and SetMark timeline in Analytics
5. Mark the goal Ripe when canopy height reaches the target wire
6. Peel the last Drop from the tray or reset the garden from Settings

**Essential features**

- Manual Drop amounts with no bank link
- Tray versus committed CanopyTotal separation
- Set batch commit with SpriteKit vine swell animation
- Swift Charts cumulative canopy band on home
- SetMark history keyed by daykey in Analytics
- Local UserDefaults persistence and CSV export from Settings

**Twist** — Drop-then-set fold (Bare | Trayed | Canopied). Home is the cordon side view with a live numeric action strip. Drop writes a DropMark, adds its amount to Tray, and folds Bare to Trayed; the SpriteKit stem and CanopyTotal do not move. Set writes a SetMark, transfers the entire Tray sum into CanopyTotal, clears Tray, animates one canopy swell, and folds Trayed toward Canopied when the target is met else back to Bare. Set on Bare or with an empty Tray writes HollowMark and is refused. Drop on a Ripe goal writes RipeMark and is refused. Retract peels only the latest DropMark from Tray; CanopyTotal never walks backward. Simulator seed places two DropMarks in Tray so the opening tap is Set. Home verb: set-the-canopy — not pinch-the-leader, clip-the-rung, fuse-the-beads, or type-a-balance. Unit tests must reject Set on Bare.

**Why this is not a repeat** — Fourth savings_vine product: batch Set commit replaces Palmette pinch lignification, Batten pool clip milestones, and Hopcrown spool fuse merges. Home verb is set-the-canopy; pending Tray is visible before growth. Canopy-locked chrome avoids the forbidden three-tab Garden pattern. No camera, no OFF, no subscription math.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Garden of vines. Manual add grows them.
- Invariant: progress = current/target. Milestones 0.25/0.5/0.75/1.0. vineSeed drives branch shape. Manual only — no bank.
- Never: No Plot / GardenGame tab.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The domain models each goal cordon as a pure Canopy ADT fold over three aggregate phases (`Bare | Trayed | Canopied`) driven by append-only mark records (`DropMark`, `SetMark`, `HollowMark`, `RipeMark`). Executing a `drop(amount:dayKey:)` command appends a `DropMark`, increments the uncommitted `Tray` balance, and folds a `Bare` cordon into `Trayed` while leaving `CanopyTotal` and the vine height untouched. Executing the home verb `set-the-canopy` (`setCanopy(dayKey:)`) validates that the cordon is `Trayed` with a positive `Tray`, appends a `SetMark` with quartile wire crossings (`0.25`, `0.50`, `0.75`, `1.00`), transfers the full `Tray` sum into `CanopyTotal`, clears `Tray` to zero, and folds `Trayed` to `Canopied` when `CanopyTotal >= targetAmount` or back to `Bare` otherwise. Calling `setCanopy` on a `Bare` cordon or when `Tray` is zero is refused and records a `HollowMark`, while calling `drop` on a `Canopied` (Ripe) cordon is refused and records a `RipeMark`; `peelLastDrop()` removes only the latest uncommitted `DropMark` from `Tray` so `CanopyTotal` never walks backward. Under `#if targetEnvironment(simulator)`, the first launch behind `cdn.demo.v1` seeds an active goal in the `Trayed` phase with prior committed `SetMark` history plus two uncommitted `DropMark` entries waiting in `Tray`, ensuring `set-the-canopy` is immediately enabled on the opening frame.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Canopy-first SwiftUI canvas backed by a subtle RealityKit ambient particle field and an interactive SpriteKit cordon scene that renders the procedural vine from `vineSeed` and animates a spring swell (response 0.4, damping 0.8, gated to a clean fade when `accessibilityReduceMotion` is active) only when a `SetMark` commits. Below the horizontal target wires, a live Swift Charts cumulative area band plots committed `SetMark` growth by integer `YYYYMMDD` daykey alongside a dense `cal`-style ledger action strip housing the uncommitted `Tray` pills, quick-drop chips, Peel control, and the primary `Set Canopy` capsule button.

### 3.3 Naming contract

Convention: Cordon / canopy lexicon (Cordon, Goal, Tray, DropMark, SetMark, CanopyTotal, HollowMark, RipeMark, Wire, Peel).

Examples to follow: `CordonState` (`Bare` | `Trayed` | `Canopied`), `CordonLedger`, `DropMark`, `SetMark`, `HollowMark`, `RipeMark`, `CanopyWire`, `CanopyTotal`, `TrayBalance`, `setCanopy(dayKey:)`, `peelLastDrop()`

### 3.4 Dependency contract

Zero external dependencies (`None`). The target links exclusively against Apple system frameworks: `SwiftUI`, `SpriteKit`, `RealityKit`, `Charts`, `Foundation`, and `UIKit` (for `UIImpactFeedbackGenerator` commit haptics and share sheet export). No Swift Package Manager entries, no CocoaPods, no vendored source, no `AVFoundation` or `Vision` capture imports, and no `URLSession` calls to external catalogs.

### 3.5 Navigation contract

Canopy-locked single-root chrome with zero `TabView` and no root back button. The side-view SpriteKit cordon, horizontal wire gauge, Swift Charts cumulative band, goal switcher rail, and fused Drop/Set action strip stay permanently mounted on the root canvas. Secondary destinations (`Analytics`, `GoalPlantSheet`, and `Settings`) present as modal sheets with explicit `Close` buttons on their own navigation stacks, and `-ReviewScreen` launch arguments (`today`, `log`, `goals`, `settings`, `plant`, `wires`) route directly after the `cdn.demo.v1` Simulator seed marks onboarding complete.

### 3.6 Screen composition contract

Canopy-root fused strip (Canopy holds SpriteKit vine, Swift Charts band, and fused drop-set; Analytics and Settings as sheets; no tab bar and no pushed deposit ledger)

1. `CanopyRootView` (primary root canvas: RealityKit particle backdrop, cordon goal header with `CanopyTotal / Target` readout and quartile wire badges, SpriteKit procedural vine canvas, Swift Charts cumulative `SetMark` area band, and fused bottom action strip with uncommitted `Tray` ledger pills, `Peel` button, hand-drop numeric pad, and primary `Set Canopy` CTA; full-page empty state with cutout art and `Plant First Goal` CTA when unstaked). 2. `AnalyticsSheetView` (sheet: Swift Charts step-area timeline of committed `SetMark` batches keyed by `YYYYMMDD` integer daykey, quartile wire crossing ledger, and refused `HollowMark` / `RipeMark` audit counter). 3. `GoalPlantSheetView` (sheet: create, switch, or mark a cordon goal Ripe, configure target amount, currency code, and deterministic `vineSeed`). 4. `SettingsSheetView` (sheet: CSV ledger export of `SetMark` and `DropMark` records, default quick-drop denominations, garden reset confirmation, and tappable support contact link to `https://cordon-canopy.pro`). 5. `OnboardingCanopyView` (first-run full-bleed walkthrough explaining Drop into Tray versus Set into Canopy, full-width bottom `Continue` CTA, bypassed on Simulator when `cdn.demo.v1` seeds).

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By canopy role (Cordon, Goal, Tray, DropMark, SetMark, CanopyTotal, HollowMark, RipeMark, Wire)**

```
Cordon/
  Cordon/
  App/
    CordonApp.swift
    ReviewScreenRouter.swift
  Design/
    DesignTokens.swift
    CanopyButtonStyle.swift
  Cordon/
    CordonState.swift
    CordonFold.swift
    CordonStore.swift
  Goal/
    GoalRecord.swift
    GoalPlantSheetView.swift
  Tray/
    TrayBuffer.swift
    DropMark.swift
    PeelAction.swift
  SetMark/
    SetMark.swift
    CanopyTotal.swift
    HollowMark.swift
    RipeMark.swift
  Wire/
    CanopyWire.swift
    VineSpriteScene.swift
    ParticleBackdropView.swift
  Views/
    CanopyRootView.swift
    FusedActionStripView.swift
    AnalyticsSheetView.swift
    SettingsSheetView.swift
    OnboardingCanopyView.swift
  Persistence/
    CordonArchive.swift
    SimulatorSeed.swift
    CSVExporter.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Garden
A first-class screen for **Garden**. Must render empty, populated and error states.

### 5.3 Analytics
A first-class screen for **Analytics**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **SavingGoal** — named per this app's convention.
- **Contribution** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **cal · ledger · high-contrast**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#0F0F0F` | Screen background |
| `surface` | `#1F1F1F` | Cards, rows, sheets |
| `ink` | `#FAFAFA` | Primary text and icons |
| `accent` | `#EED34F` | Primary action, key figure, progress fill |
| `muted` | `#B2B2B2` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Cordon/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Menlo**

Assigned `Menlo` monospaced type hierarchy paired with `cal` ledger density. Hero `CanopyTotal`, uncommitted `Tray` sums, quartile wire percentages (`25%`, `50%`, `75%`, `100%`), and integer `YYYYMMDD` daykeys render in crisp `Menlo-Bold` and `Menlo-Regular` with `fixedSize(horizontal: false, vertical: true)` and `@ScaledMetric` sizing so numeric columns align to the character grid and never clip at AX5 Dynamic Type. Section headers, ledger row labels, and dry verb buttons (`Drop`, `Set Canopy`, `Peel`, `Plant Goal`) use tight tracking and single-rule hairline separation without em-dashes or decorative warmth.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **32pt** for cards, sheets and primary surfaces; **16pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI RealityKit particle background · canvas-first**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI RealityKit particle background · canvas-first** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **cal** — steal rhythm and restraint, not their colours or logos.

Mood: **Open-source scheduling. Clean neutral UI, developer-oriented simplicity.**.

Home rhythm (`ledger`, dense): A ledger of rows and a running total.

High-end agency: huge type, air, one accent, hairline depth. Layout `ledger`, density dense. Kit 32/16, material, filled capsule. Palette recipe `high-contrast`. One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Editorial measure, generous leading, one rule. Reference type feel: agency.

Motion (`spring`): One spring on the commit (response ~0.4, damping ~0.8). Everything else is ease-out. Reduce Motion: fade, no spring.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- iPhone allows portrait, landscape left, and landscape right. iPad allows all
  four orientations. Keep both lists in the Info settings, and let a rotated
  screen scroll instead of clipping.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Every headline, amount, and button title is fully visible. Do not give display
  type a fixed height shorter than the font, and do not let a sibling with
  `maxHeight: .infinity` compress it. When the column is taller than the screen,
  scroll it. `.clipped()` frames an image cell; it never wraps text.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- The root screen has no back button. `.navigationTitle` is a screen name, never
  the product name. A back control titled with the app name is a defect: it
  reads as a button that returns to this same app.
- A sheet dismisses with Close and owns its stack. Do not push it onto a stack
  whose title is the product name.
- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Grid root record holding Pets, Routines, Cues and Marks, encoded under a single key with debounced save after each mark**

`UserDefaults` + `Codable` storing a single root `CordonArchive` struct (containing `goals`, committed `setMarks`, uncommitted `dropMarks`, refused `hollowMarks` and `ripeMarks`, and `activeGoalID`) encoded as JSON under key `cdn.cordon.archive.v1` with a debounced write after every mark mutation. Simulator-only first launch checks `cdn.demo.v1` inside `#if targetEnvironment(simulator)` to seed four realistic goals, committed `SetMark` history across multiple `YYYYMMDD` daykeys, and two live `DropMark` items in the active goal's `Tray` while marking onboarding complete. `CSVExporter` serializes all marks into a plain-text CSV file from Settings.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Cordon/1.0 (iOS; +https://cordon-canopy.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.
No scanner and no remote catalog in this product. Do not import AVFoundation or Vision for capture, do not add a camera usage description, and do not call a search endpoint. Ignore a leftover scanner or search axis.


---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- iPhone: portrait, landscape left, landscape right. iPad: all four orientations (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.finance`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.finance
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Drop-then-set (drop fills tray; set commits the whole tray into canopy height; unpooled drops never move the vine)

The Drop-then-Set mechanic strictly separates stashing loose cash from growing the vine across the `Bare | Trayed | Canopied` states. Tapping `Drop` records a `DropMark` into the pending `Tray` and transitions the cordon from `Bare` to `Trayed`, but `CanopyTotal` and the SpriteKit vine height remain completely still so unpooled coins never trigger premature growth. Tapping the home verb `set-the-canopy` (`Set Canopy`) commits the entire `Tray` batch at once: it writes a `SetMark`, adds the `Tray` sum into `CanopyTotal`, empties `Tray`, triggers the SpriteKit vine swell across any newly crossed `0.25 / 0.50 / 0.75 / 1.00` wires, and folds `Trayed` to `Canopied` when `CanopyTotal >= targetAmount` or back to `Bare` when further deposits are needed. Refused transitions are enforced and unit-tested: invoking `set-the-canopy` on a `Bare` cordon or when `Tray` is empty is rejected by the fold and appends a `HollowMark` without mutating `CanopyTotal`, and invoking `Drop` on a `Canopied` (Ripe) cordon is rejected and appends a `RipeMark`. Tapping `Peel` removes only the most recent uncommitted `DropMark` from `Tray` so committed `CanopyTotal` never regresses, and the `cdn.demo.v1` Simulator seed pre-populates two `DropMark` records in `Tray` (`Trayed` phase) so `Set Canopy` is enabled on the very first tap.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Neon outline glowing line art · tactile**


Base prompt, reused and extended for every asset:

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence.
```

All 7 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `cdn_` prefix.

### 13.1 App icon

Do not generate an app icon. Do not create an AppIcon image set and do not
paint icon artwork. The factory installs the icon later. Leave the empty
AppIcon.appiconset from the scaffold untouched.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `cdn_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 2 | `cdn_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 3 | `cdn_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 4 | `cdn_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 5 | `cdn_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Drop-then-set (drop fills tray; set commits the whole tray into canopy height; unpooled drops never move the vine)' feature screen. |
| 6 | `cdn_EmptyCanopyCutout` | 1024x1024 | **required cutout** | A tactile glowing neon-outline botanical cordon trellis post with a coiled dormant vine sprout at the base, crisp luminous linework with a solid dark interior body and real transparent PNG alpha background, centered composition, no text. |
| 7 | `cdn_RipeCrownBadge` | 1024x1024 | **required cutout** | A tactile glowing neon-outline botanical canopy crown emblem showing a knotted vine crest resting on a horizontal trellis wire with four luminous leaf nodes, solid interior silhouette with transparent PNG alpha corners, no text. |

### Prompt per asset

**`cdn_Onboarding1`** — 1024x1536

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence., a person or object that is this product in one glance

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cdn_Onboarding2`** — 1024x1536

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence., the primary action of this product, mid-gesture

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cdn_Onboarding3`** — 1024x1536

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence., a later moment when the product has accumulated meaning

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cdn_EmptyHome`** — 1024x1024

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cdn_TwistHero`** — 1024x1024

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence., an emblem representing this app's signature feature

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cdn_EmptyCanopyCutout`** — 1024x1024

```
A tactile glowing neon-outline botanical cordon trellis post with a coiled dormant vine sprout at the base, crisp luminous linework with a solid dark interior body and real transparent PNG alpha background, centered composition, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cdn_RipeCrownBadge`** — 1024x1024

```
A tactile glowing neon-outline botanical canopy crown emblem showing a knotted vine crest resting on a horizontal trellis wire with four luminous leaf nodes, solid interior silhouette with transparent PNG alpha corners, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`cdn.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `CordonTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Cordon/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Cordon -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.
- [ ] `CordonWatch` stays in the project. It reads `ReviewLaunch.screen` and opens the same today, log, and goals destinations, laid out for Apple Watch.

**Uniqueness**
- [ ] Architecture matches **Canopy ADT fold (Bare | Trayed | Canopied); the cordon is a fold over SetMarks; Drop writes a DropMark and adds amount to Tray, folding Bare to Trayed; Set writes a SetMark, moves Tray sum into CanopyTotal, clears Tray, and folds Trayed to Canopied when CanopyTotal reaches target else back to Bare; Set on Bare or empty Tray writes HollowMark; Drop on Ripe writes RipeMark; Retract removes the last DropMark from Tray only; an unstaked cordon writes Bare** with no leakage across layers.
- [ ] UI approach matches **SwiftUI RealityKit particle background · canvas-first**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Canopy-locked chrome (the side-view cordon and Charts band never leave; the tray and fused drop-set verbs sit in the action strip; Analytics and Settings arrive as sheets; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Menlo** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Cordon
xcodegen generate
xcodebuild build-for-testing -scheme Cordon -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.cordon.canopy/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Cordon -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.cordon.canopy/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Cordon -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.cordon.canopy/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
