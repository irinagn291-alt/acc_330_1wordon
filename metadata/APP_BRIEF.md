<!-- gf-brief source=7f314fda5e1f8998df6f16d2a5de27310fcb7999523d64868729f94b81e1b4f1 written=2026-10-22T03:04:37+03:00 -->
# Cordon
## What it is
Cordon is a dark-screen savings notebook for someone who wants to set aside loose cash by hand. You name a goal, record cash drops into a waiting tray, then commit the whole tray so a vine grows toward that goal. Nothing is linked to a bank.
## Launch and onboarding
A cold launch shows a dark screen with a gray placeholder block and no words. If loading lasts, a spinner appears under that block. There is no permission prompt.

The first time, three intro pages follow. "Skip" is at the top of every page and finishes the intro immediately.

1. "Cash, by hand." "Name a goal. Drop loose cash. Nothing is linked to a bank." The bottom button is "Next".
2. "The vine waits." "A drop does not grow the vine. Set the batch and the height moves." The bottom button is "Next".
3. "Payday is the commit." "Unpooled cash stays put until you set it. Peel takes back only the last drop." The bottom button is "Continue".

"Continue" or "Skip" opens the garden. The intro does not appear again unless you ask for it in Settings, or you reset the garden.
## Screens
### Garden
The title is "Garden". With no goal, the screen says "The garden is empty." and "Plant your first goal." The only button is "Plant First Goal", which opens the plant form.

With a goal, the screen always shows "Save loose cash by hand." and "Drops are waiting. Set the batch to grow the vine." A row of chips lists each goal by the name you typed. The current goal is selected. Tapping another name switches to it. The last chip is "Plant Goal" and opens the plant form.

The goal card shows the goal name, a phase pill ("Open", "Waiting", or "Ripe"), "Saved so far", the saved amount, and "Goal" plus the target amount. A progress bar shows the percent of the target. A vine drawing grows with that percent. Four markers read "25%", "50%", "75%", and "100%", each followed by "Lit" or "Not yet".

"Tray" lists each uncommitted drop as "Drop", the date (for example "Oct 22, 2026"), and the amount. If there are none, the tray says "Open". A "Waiting cash" row shows the phase and the tray total.

"Commits" is a chart of committed totals by date. Before the first commit it says "No commits yet. Drop cash, then commit the waiting batch." After a commit it shows the bars and a "Saved so far" row with the date and the new total.

"Amount" is a number field. Under it, chips show the quick amounts in the goal currency. The built-in chips are 5, 10, 20, and 50. Tapping a chip records that drop immediately. "Peel" asks to remove the latest uncommitted drop. "Drop" records the typed amount. "Set Canopy" commits the whole tray into the goal. On a wide iPad layout the vine and the chart sit side by side; the amount controls stay underneath.

The top bar, from the left: a list button labeled "History" (opens History), a target button labeled "Goals" (opens Goals), a gear labeled "Settings" (opens Settings). The amount keyboard has "Close".

"Peel" opens a confirmation titled "Peel the last drop?" with "Removing this drop lowers the waiting tray. Cash already committed to the goal stays saved." The buttons are "Peel" and "Close".

A banner can appear on the garden:
- "Tray is empty. Drop cash, then set the canopy."
- "This goal is ripe. Plant another goal to drop again."
- "The garden file could not be read. Starting from an empty cordon." with "Retry"
- "The garden could not be saved. This session is still on screen." with "Retry"
- "Reset could not clear the garden file. Try again." with "Retry"
- "Restored the last good garden file."

"Retry" tries to save again.

### History
The title is "History". "Close" dismisses it.

With no goal it shows "The garden is empty.", "Plant your first goal.", and "Plant First Goal". That button only closes History.

With a goal but no commits it shows "Commits", "Drops are waiting. Set the batch to grow the vine.", and "Set Canopy". That button only closes History.

With commits it shows the same "Commits" chart, then "Commit milestones". Each row is the date, either "Committed before the first quarter" or "Crossed" plus the percents that were passed (such as "25%" or "50%"), and the committed amount. A "Refused commits" row says "None on this goal" or "Empty-tray commits", with the count. The bottom button is "Close".

### Goals
The title is "Goals". "Close" dismisses it.

With no goal it shows "The garden is empty.", "Plant your first goal.", and "Plant First Goal", which opens the plant form.

Otherwise each goal is a row: the name, "Active" or "Switch", and the target amount. Tapping a row makes that goal the current one and leaves the sheet open. "Plant Goal" closes Goals and opens the plant form.

### Plant Goal
The title is "Plant Goal". "Close" dismisses it.

Four fields, each labeled and used as the placeholder: "Goals" (the name), "Target", "Currency" (starts as "USD"), and "Vine number" (optional). If a goal is already current, a row shows its name, phase, and target. "Plant Goal" creates the goal, makes it current, clears the form, and closes the sheet. The keyboard has "Close".

If planting is refused, a banner shows one of these, with "Retry" (which tries to plant again):
- "Enter a name."
- "Enter a target above zero."
- "Enter a 3 letter currency code."
- "Enter a whole number for the vine, or leave it blank."

### Settings
The title is "Settings". "Close" dismisses it.

"Quick amounts" lists each shortcut as "Amount", "Drop", and the money value. A field placeholder reads "Add amount". "Add amount" is disabled until the field is a positive number; tapping it appends that shortcut. An invalid entry shows "Enter a positive amount." with "Retry".

"Export CSV" opens the system share sheet for a text file of the garden. While it works, the button can show a spinner. Failure shows "Export failed. The file was not written." with "Retry".

"Show intro" closes Settings and plays the three intro pages again. The garden is kept. "Contact" opens the support page in the browser. "Reset all data" asks "Reset the garden?" with "Goals and cash records are deleted from this device." The buttons are "Reset all data" and "Close". After a reset, the intro plays again and the garden is empty. The word "Support" sits under the buttons and is not a control.

The same save and reset banners from the garden can appear here, with "Retry".

### Apple Watch
The watch app is also named "Cordon". It does not follow the phone garden. It always shows a fixed sample.

The main face shows "Rainy week", the saved total, the waiting amount, and the words "Set Canopy". Those words are not a button.

The log lists past commit dates as eight-digit numbers and amounts. The goals list is "Rainy week", "Rent buffer", "Train fare", and "Bike lock", each with a target.
## Features
- Name a savings goal, with a target, a 3-letter currency, and an optional vine number.
- Keep several goals and switch the current one from the garden chips or from "Goals".
- Record a cash drop by typing an amount or tapping a quick amount. A drop waits in the tray and does not grow the vine.
- "Set Canopy" commits the whole waiting tray into "Saved so far" and grows the vine.
- "Peel" removes only the latest drop that has not been committed.
- Phase "Open" means nothing is waiting. "Waiting" means cash is in the tray. "Ripe" means saved cash has reached the target.
- Quartile markers at "25%", "50%", "75%", and "100%" turn "Lit" as the goal fills.
- "History" lists commits and how many refused commits this goal has.
- Change the quick amounts in "Settings".
- "Export CSV" shares a text file of the records.
- "Show intro" replays the three pages.
- "Reset all data" deletes goals and cash records on this device and shows the intro again.
- "Contact" opens the support page.
- The garden is still there after you leave the app.
## Behaviours that can look like bugs
- "Drops are waiting. Set the batch to grow the vine." stays on the garden even when the tray is empty.
- "Drop" stays disabled until "Amount" is a positive number. Anything else shows "Enter a positive amount."
- "Drop" also stays disabled while the phase is "Ripe". The quick-amount chips still respond. Tapping one then shows "This goal is ripe. Plant another goal to drop again." and the cash is not added. Plant another goal with "Plant Goal" to drop again.
- "Set Canopy" stays disabled while the tray is empty and while the goal is "Ripe". Fill the tray with "Drop" or a quick amount, then set it.
- "Peel" stays disabled when the tray has no drop. Add a drop first. A confirmation still only removes the latest uncommitted drop. Committed savings stay.
- On "History", "Set Canopy" and "Plant First Goal" only close the sheet. Commit and plant from the garden.
- "Add amount" in Settings stays disabled until the field is a positive number.
- "Plant Goal" will not continue until the name is filled, the target is above zero, and "Currency" is three letters. "Vine number" may be left blank.
- "Show intro" returns you to the first intro page on purpose. "Skip" or the last page's "Continue" returns to the garden with your records kept.
- "Reset all data" deletes the garden and plays the intro again on purpose.
- "Retry" on "The garden file could not be read. Starting from an empty cordon." saves the empty garden. It does not bring the old records back.
- "The garden could not be saved. This session is still on screen." means the amounts you see are still in this visit. "Retry" tries to save them.
- Dates on the phone use a fixed English form such as "Oct 22, 2026", even if the device language is different. The watch log shows dates as eight-digit numbers.
- The watch face never changes when you edit the phone, and "Set Canopy" there does nothing.
## Starter content and resume
On iPhone and iPad the garden starts empty. There is no sample goal. Waiting drops and commits remain after you leave the app, until you commit them, peel the last drop, or reset.

The Apple Watch shows a fixed sample only: "Rainy week" (target 400, with waiting cash), "Rent buffer" (target 1,200), "Train fare" (target 180), and "Bike lock" (target 80), in USD. That sample cannot be edited and does not resume phone work.
## Permissions
None.
## Absent
Login or accounts, in-app purchase, ads, analytics, shared user-generated content, an account-deletion flow, and an App Tracking Transparency prompt are all absent. Goal names you type stay on this device. "Reset all data" wipes this device only. There is no account to delete.
## Data and support
Goals, drops, and commits stay on this device. "Contact" in Settings opens the support page in the browser. The word "Support" is a label under that button.
## Scanning and health
None.
## Platform
No country lock. Money uses the currency code on the goal, which starts as "USD", with the device's currency formatting. The amount field reads numbers in the device's number format.

iPhone and iPad. The iPhone uses portrait and both landscapes. The iPad uses portrait, upside down, and both landscapes. The interface is always dark and fills the screen. Minimum iOS version is 17.0. The Apple Watch companion needs watchOS 26.0.
## Category
Finance
