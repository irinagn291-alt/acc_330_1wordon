# Cordon

Save loose cash by hand toward a named goal. A drop sits in a tray. The vine grows only when you set that whole batch.

People who stash cash between paydays use it. There is no bank feed.

## Architecture

Each goal is a canopy fold with three phases: bare, trayed, and canopied. The phase is not a flag. It is the result of replaying marks.

`CordonLedger` is the fold. `CordonStore` is the only seam that writes `CordonArchive`. Screens read `CordonCanvasState` from that store. The file is a projection of the in-memory ledger, saved after each mark.

That split fits this product because unpooled cash must not be able to move the vine. The height is committed canopy over the target. Quartile wires sit at 0.25, 0.50, 0.75, and 1.00. `vineSeed` picks the branch shape. Cash is typed by hand.

## Drop, then set

This is the reason to pick Cordon over a balance list.

- Drop writes a `DropMark` and adds the amount to the tray. A bare cordon becomes trayed. Canopy height stays put.
- Set Canopy writes a `SetMark`, moves the whole tray into `CanopyTotal`, clears the tray, and folds trayed to canopied when the target is met, otherwise back to bare.
- Set on a bare cordon, or on an empty tray, writes a `HollowMark` and changes nothing else.
- A drop on a ripe cordon writes a `RipeMark` and is refused.
- Peel removes only the latest open `DropMark`. Committed height never walks backward.

Home is that cordon: a vine, the waiting tray, and Set Canopy. The Simulator seed leaves two drops in the tray so the first tap can set.

## Art

Style: tactile neon outline glowing line art, cutouts with transparent corners.

Shared prompt:

```
Tactile neon outline glowing line art with crisp luminous vector-like botanical contours, subtle phosphor edge bloom, and clean interior structure rendered as true alpha-channel cutouts with transparent corners and solid silhouette presence.
```

`cdn_Onboarding1` (1024x1536): shared prompt, plus a person or object that is this product in one glance.

`cdn_Onboarding2` (1024x1536): shared prompt, plus the primary action of this product, mid-gesture.

`cdn_Onboarding3` (1024x1536): shared prompt, plus a later moment when the product has accumulated meaning.

`cdn_EmptyHome` (1024x1024): shared prompt, plus a solid closed bowl, crate or folded cloth waiting to be used. Ceramic, wood or fabric, fully opaque.

`cdn_TwistHero` (1024x1024): shared prompt, plus an emblem representing drop-then-set.

`cdn_EmptyCanopyCutout` (1024x1024): A tactile glowing neon-outline botanical cordon trellis post with a coiled dormant vine sprout at the base, crisp luminous linework with a solid dark interior body and real transparent PNG alpha background, centered composition, no text.

`cdn_RipeCrownBadge` (1024x1024): A tactile glowing neon-outline botanical canopy crown emblem showing a knotted vine crest resting on a horizontal trellis wire with four luminous leaf nodes, solid interior silhouette with transparent PNG alpha corners, no text.

## How this one differs

The vine does not move on every coin. Growth is a batch commit. Pending tray cash stays visible until Set Canopy. Analytics and Settings are sheets over that cordon. There is no tab bar and no game board.

## Build

```bash
cd apps/Cordon
xcodegen generate
xcodebuild build-for-testing -scheme Cordon -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Cordon -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcodebuild test-without-building -scheme Cordon -destination 'platform=iOS Simulator,name=iPhone 17' -jobs 4
```

Portrait only. iOS 17. No third-party packages.
