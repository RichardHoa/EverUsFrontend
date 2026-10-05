# Restyle the landing page and Date Planner form to the EverUs_Official Figma design

Status: ready-for-agent

Design source: Figma file `EverUs_Official` (key `l7CCuJoNk8RE4yCsCmndNE`), frames `landing_page` (node `2:7`) and `date_planner` (node `27:4133`).

## Problem Statement

The landing page and the Date Planner form work, but they don't match the official EverUs design in Figma. The landing page has a generic heart mascot, a title banner and plainer cards. The planner form uses system date and time pickers, a duration slider and a budget slider. Neither looks or feels like the soft, illustrated product the couple is meant to use. On the planner form, some inputs are also less direct than the design: you can't see a date's context on a calendar, you pick a duration when you'd rather pick an end time, and you slide to a budget when you'd rather type one.

## Solution

Restyle both screens to match the Figma frames and keep every existing behaviour: the Love counter sync, forced Love counter setup, notifications, plan generation, saving and invitations.

On the landing page, an animated yarn-ball mascot replaces the heart mascot. The Love counter card shows both partners' photos, joined by a heart-shaped thread, with each partner's chosen name curved around their circle. The Date Planner and Relationship Reflection cards use the illustrated Figma artwork.

On the Date Planner form, an inline month calendar marks the dates that already have saved plans. The duration slider becomes a start time and an end time. The Vibe options become an illustrated sideways carousel. Distance and transport become chips. The budget becomes a formatted VND text field with quick-pick chips.

## User Stories

### Landing page

1. As a user, I want the landing page to look like the official EverUs design, so that the app feels polished and coherent.
2. As a user, I want the "EverUs" title and tagline banner removed from the landing page, so that the mascot and the Love counter take centre stage.
3. As a logged-in user, I want the notification bell to stay in the top-right corner of the landing page, so that I can still reach plan invites.
4. As a user with unread notifications, I want the bell to still show its unread dot, so that I know an invite is waiting.
5. As a user, I want the mascot to be the yarn ball from the design, so that it matches the brand.
6. As a user, I want the yarn ball to gently bob and breathe while idle, so that the home screen feels alive.
7. As a user, I want the yarn ball to bounce or squish when I tap it, so that tapping it feels responsive.
8. As a user, I want each tap to change the thought-bubble comment, as the current mascot does, so that the interaction stays playful.
9. As a user, I want the comment in a thought bubble styled like the design, so that it reads as the mascot "thinking".
10. As a user, I want the Love counter card to say "CHÚNG MÌNH ĐÃ BÊN NHAU" ("We've been together") with the day count and "ngày" ("days"), so that I see how long we've been together at a glance.
11. As a user, I want my photo and my partner's photo in the two circles on the Love counter card, so that the card feels personal.
12. As a user who hasn't added a photo, I want that circle to fall back to the design's colour (pink for me, green for my partner), so that the card still looks complete.
13. As a user, I want the heart-shaped thread drawn between the two circles, so that the card visually ties us together.
14. As a user, I want my chosen name curved around the top of my circle and my partner's name around theirs, so that the names feel woven into the design.
15. As a user with a long name, I want it to spread along the arc, shrink slightly if needed and end with "…" if it still doesn't fit, so that it never overlaps or breaks the layout.
16. As a user, I want tapping the Love counter card to still open the Love counter screen, so that I can edit our details.
17. As a user who hasn't set up the Love counter, I want to still be taken to the Love counter setup, so that the app has what it needs.
18. As a user, I want the Date Planner card to show the calendar illustration from the design, so that its purpose is obvious.
19. As a user, I want tapping the Date Planner card to still let me choose between planning a date and the date challenge, so that both flows stay reachable.
20. As a user, I want the Relationship Reflection card to show the hands illustration from the design, so that it feels inviting.
21. As a user, I want tapping the Relationship Reflection card to still open Reflection, so that nothing I rely on breaks.
22. As a user, I want the same background and the same footer as today on the landing page, so that the app stays consistent.

### Date Planner form

23. As a user, I want the planner header to say "Date Planner" with a back button, so that it matches the design.
24. As a logged-in user, I want the notification bell to stay in the planner header, so that invites stay reachable from the planner.
25. As a user, I want the footer to stay on the planner screen, so that navigation is consistent everywhere.
26. As a user, I want an inline month calendar in place of a date-picker popup, so that I can see and choose dates directly.
27. As a user, I want to move between months with arrows, so that I can plan ahead.
28. As a user, I want past dates disabled, so that I can't plan a date in the past.
29. As a user, I want the selected date filled in on the calendar, so that I know which day I'm planning.
30. As a logged-in user, I want circles around every date that already has a saved plan from the server, so that I can see what's already planned.
31. As a guest, I want a circle around the date of my one plan saved on this device, so that I get the same cue without an account.
32. As a user, I want tapping a circled date to simply select it, so that I can plan another date on the same day.
33. As a user, I want a "Ngày hẹn hò" (date) row showing the selected date as e.g. "Thứ năm, 17/9" (Thursday, 17/9), so that the choice is confirmed in words.
34. As a user, I want a start time and an end time ("17:00 đến 19:00", "17:00 to 19:00") in place of a duration slider, so that I think in clock times.
35. As a user, I want the date to be at least 1 hour long, so that the plan has room for at least one stop.
36. As a user, I want no upper limit on the length, so that I can plan a long day out.
37. As a user, I want an end time earlier than the start time to count as the next day and be labelled "(hôm sau)" ("next day"), so that late-night plans work and it's clear what happened.
38. As a user, I want the Vibe options ("Đời thường" Everyday, "Lãng mạn" Romantic, "Trải nghiệm" Experience) as illustrated cards in a sideways carousel, so that choosing a mood feels expressive.
39. As a user, I want the selected Vibe card to have a thicker plum border and a slight lift, so that I can tell what I picked.
40. As a user, I want the carousel to scroll the selected Vibe into view, so that my choice is always visible.
41. As a user, I want "Lãng mạn" selected by default, as today, so that the default doesn't change.
42. As a user, I want the "Khoảng cách" (Distance preference) chips "Gần / dưới 5km" (Near, under 5km), "Xa / 5–15 km" (Far) and "Tuỳ hứng / Để EverUs chọn" (Random, let EverUs choose), so that picking a search radius matches the design.
43. As a user, I want the "Phương tiện di chuyển" (transport) chips "Đi bộ" (walking), "Xe máy" (motorbike) and "Taxi", so that picking transport matches the design.
44. As a user, I want a text field for the maximum budget per person, so that I can type an exact amount.
45. As a user, I want the amount formatted as I type, e.g. "500,000 VND", so that large numbers are easy to read.
46. As a user, I want only digits accepted in the budget field, so that the amount is always valid.
47. As a user, I want quick-pick chips for 100K, 200K, 300K and 500K that fill the budget field, so that common amounts take one tap.
48. As a user, I want a chip to light up when the amount equals its value, so that I can see that a preset is active.
49. As a user, I want the budget field to start empty, so that I consciously choose a budget.
50. As a user, I want the "BẮT ĐẦU LÊN Ý TƯỞNG" ("Start generating ideas") button disabled until the budget is at least 50,000 VND, so that I can't request a plan with no budget or an unrealistic one.
51. As a user, I want my starting location detected automatically without taking up form space, so that the form stays clean.
52. As a user, I want a compact one-line location row only while location is being detected or after permission was denied, so that I can see the status or type a starting address when needed.
53. As a user, I want the stop count to keep its current default without a visible control, so that the form matches the design.
54. As a user, I want a "Xem lại lịch sử ý tưởng" ("Review idea history") link that opens my saved plans, so that I can revisit past ideas.
55. As a user, I want the "BẮT ĐẦU LÊN Ý TƯỞNG" button styled like the design and to start generation as today, so that the main action is clear.
56. As a user, I want the generating, results and error screens unchanged, so that what I already know keeps working.
57. As a user, I want the results and error screens to keep their current Vietnamese titles, so that only the form header changes.
58. As a user, I want the same EverUs background behind the planner as on the landing and login screens, so that every screen looks like one app.

## Implementation Decisions

- **Restyle, not rebuild.** Keep all existing state, controllers, helpers and API calls. Change only presentation, apart from the input-model changes listed below.
- **Background.** Keep the existing EverUs background image on every screen. Don't adopt the Figma frames' own background fills.
- **Footer.** Leave the shared footer as it is. It already matches the Figma bottom bar and stays on every screen, including the planner.
- **Landing header.** Remove the title and tagline. Keep the notification bell and its unread-dot behaviour.
- **Mascot.** Replace the heart mascot artwork with one yarn-ball image exported from Figma, animated in code: a continuous idle bob and breathe, and a short bounce or squish on tap. The tap-to-cycle comment list and its emotions stay as the source of the bubble text. Emotions don't change the artwork; there's one image only.
- **Love counter card.** Restyle the mini Love counter to the Figma layout:
  - a header label, the large day count and "ngày";
  - two circles joined by a heart-shaped thread, drawn in code or exported from Figma, whichever looks closer;
  - each circle holds that partner's photo when one exists, otherwise the design colour (pink for the user, green for the partner);
  - each partner's chosen name is laid out along an arc over their circle. The arc may cover up to about half the circumference. Past that, the font shrinks a little, then the name is cut off with "…".
- **Love counter setup.** The forced redirect to setup stays as it is today.
- **Feature cards.** The Date Planner and Relationship Reflection cards use artwork exported from Figma. The Date Planner card still opens the dialog to choose between planning a date and the challenge.
- **Assets.** Export Figma artwork (yarn ball, calendar card illustration, reflection hands, thread or heart if needed) at 3x into the existing images asset folder. Build the vibe card gradients in code where that looks right; otherwise export them too.
- **Fonts and colours.** Take typefaces, sizes and colours from the Figma design data, and reuse the existing plum palette where it matches.
- **Planner header.** On the form, the title is "Date Planner" with a back button and the bell (logged in only, as today). Results and error keep their current titles.
- **Inline calendar.** A custom month calendar replaces the system date picker:
  - Month arrows move between months.
  - Dates before today are disabled.
  - The selected date is filled.
  - Dates that already have a plan are circled. The source is the server's saved-plans list when logged in, or the one locally cached plan for guests.
  - Selecting a circled date only selects it.
  - The controller gains an exposed set of dates that already have plans, loaded on screen start.
- **Time range.** The form takes a start time and an end time; the duration slider goes away. The controller keeps sending start time plus duration to the generator, with duration worked out from the two times:
  - If the end time is earlier than the start time, it means the next day, and the UI shows "(hôm sau)" next to the end time.
  - The date must be at least 1 hour long, with no maximum. If a chosen end time would make it shorter than 1 hour, it is moved to start + 1 hour, or the choice is rejected with a short message.
  - The plan's date stays the start date.
- **Vibe carousel.** A horizontal, scrollable row of illustrated cards with the same three vibe keys and labels as today. The selected card gets a thicker plum border and a slight lift, and is scrolled into view. "Lãng mạn" (romantic) stays the default.
- **Distance preference and transport.** Chips styled like the design, with the same values as today. "Tuỳ hứng" still resolves on the client at generation time, as described in CONTEXT.md.
- **Budget input.** A numbers-only text field that displays the amount with thousands separators and a "VND" suffix (e.g. "500,000 VND"):
  - Chips for 100K, 200K, 300K and 500K fill the field, and a chip is highlighted when the amount equals its value.
  - The field starts empty, so the controller's budget becomes nullable or unset by default.
  - The generate button is disabled while the budget is unset or under 50,000.
  - The budget slider is removed.
- **Location.** Keep automatic detection on screen start. Show a compact one-line row only while detecting or after permission is denied; that row keeps the current manual-address entry.
- **Stop count.** Not shown on the form; it keeps its current default.
- **Bottom of the form.** A "Xem lại lịch sử ý tưởng" link opens the existing saved-plans/history screen, and "BẮT ĐẦU LÊN Ý TƯỞNG" triggers generation as today.
- **Untouched.** The generating, loading, results and error views, generation API contracts, saved-plan storage and invitation logic don't change. No backend changes are needed: the saved-plans list endpoint already exists.

## Testing Decisions

- Following the project's preference, no new automated tests are written for this work. Verification is by reasoning through the code and running the app by hand.
- The two places with real logic are (a) working out the duration from start and end time, including the next-day case and the 1-hour minimum, and (b) parsing and formatting the VND budget plus the 50,000 minimum. Keep both as small pure functions so they're easy to reason about. If extra confidence is wanted, check them with a standalone Dart script run outside the test framework, not with `flutter test`.
- Manual checks:
  - Landing with and without photos, with short and long names, and with unread notifications.
  - The mascot's idle animation and tap behaviour.
  - Calendar: month navigation, past dates disabled, circled dates as a guest and when logged in.
  - Time ranges within one day, across midnight, and under 1 hour.
  - Budget typing, the chips, and the button enabling around 50,000.
  - Location row: permission granted vs denied.
  - Generating a plan end to end and opening the history.
- A good check exercises behaviour the user can see (what the screen shows and what request gets sent), not widget internals.

## Out of Scope

- The `date_challenge`, `challenge ready` and `Sign in` Figma frames, and the empty `Frame 2`.
- The generating, loading, results and error views of the Date Planner, and the history screen's layout.
- Changes to the shared footer.
- Per-emotion mascot artwork. There is one animated yarn-ball image.
- Backend, API or schema changes.
- A maximum date length.
- Showing a live status or message from the partner in the mascot's thought bubble.

## Further Notes

- The Figma frames are drawn about 3x a phone width (around 1243–1319 px wide), so scale the measurements accordingly.
- In the design, the selected date (17) and the circled dates (8, 21) are example states, not fixed data.
- New glossary term added during design: **Love counter** (see CONTEXT.md).
