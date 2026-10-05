# 02: Restyle the Date Planner form to the Figma design

**What to build:** Make the Date Planner form match the Figma `date_planner` frame (file `l7CCuJoNk8RE4yCsCmndNE`, node `27:4133`) and keep plan generation, saving and invitations unchanged.

The user picks a day on an inline calendar that circles the dates that already have a saved plan. They set a start and an end time instead of a duration, and choose a Vibe from an illustrated carousel. Distance preference and transport are chips. The budget is a formatted VND field with quick-pick chips. The form ends with a history link and the "BẮT ĐẦU LÊN Ý TƯỞNG" button. The generating, loading, results and error views don't change.

See the parent spec, `.scratch/figma-landing-date-planner/spec.md` (user stories 23–58), for full context.

**Blocked by:** None (can start immediately)

**Status:** implemented, awaiting manual verification

- [x] On the form, the header reads "Thiết Kế Hẹn Hò" (Vietnamese, per user request; not the Figma "Date Planner") with a back button, and the bell shows for logged-in users. Results and error keep their current titles.
- [x] The shared footer and the existing EverUs background stay on the planner screen.
- [x] An inline month calendar replaces the system date picker. It has month arrows, dates before today are disabled, and the selected date is filled.
- [x] Dates with an existing plan are circled: from the saved-plans list on the server when logged in, or from the one locally cached plan for guests. Tapping a circled date only selects it.
- [x] The "Ngày hẹn hò" row shows the selected date in words, e.g. "Thứ năm, 17/9".
- [x] Start and end time pickers ("… đến …") replace the duration slider. The duration sent to the generator is worked out from the two times.
- [x] An end time earlier than the start time means the next day and shows "(hôm sau)". The plan's date stays the start date.
- [x] Dates shorter than 1 hour are prevented. There is no maximum length.
- [x] Working out the duration from start and end time is a small pure function.
- [x] The Vibe options ("Đời thường", "Lãng mạn", "Trải nghiệm") are illustrated cards in a sideways carousel. The selected card has a thicker plum border and a slight lift, and is scrolled into view. "Lãng mạn" is the default.
- [x] Vibe card gradients are built in code where that's faithful, otherwise exported from Figma at 3x.
- [x] The Distance preference chips ("Gần", "Xa", "Tuỳ hứng") and transport chips ("Đi bộ", "Xe máy", "Taxi") are styled like the design, with the same values as today.
- [x] The budget is a numbers-only field that displays e.g. "500,000 VND" and starts empty. The budget slider is removed.
- [x] The 100K, 200K, 300K and 500K chips fill the budget field. A chip is highlighted when the amount equals its value.
- [x] Parsing and formatting the budget is a small pure function.
- [x] "BẮT ĐẦU LÊN Ý TƯỞNG" is disabled while the budget is empty or under 50,000, and otherwise starts generation as today.
- [x] Location is still detected automatically. A compact one-line row, with the manual address entry, appears only while detecting or after permission is denied.
- [x] The stop-count control is hidden and its current default is kept.
- [x] "Xem lại lịch sử ý tưởng" opens the existing saved-plans/history screen.
- [x] Fonts, sizes and colours come from the Figma design data, scaled from the roughly 3x frame to phone size.
- [ ] Verified by hand (no new automated tests):
  - calendar navigation, and circled dates as a guest and when logged in;
  - time ranges within one day, across midnight, and under 1 hour;
  - budget typing, the chips, and the button enabling around 50,000;
  - location granted vs denied;
  - generating a plan end to end and opening the history.


## Comments

- Implementation notes (agent):
  - The vibe card art (`assets/images/vibe_{casual,romantic,adventure}.png`, 447×490 px, about 3x at phone width) was put together from the Figma layers: the raw images, the leaf and iridescence layers, and their blend modes. The Figma MCP node-export limit had been reached, so the layers were rendered with headless Chrome instead of exported directly. Labels, border and lift are drawn in code.
  - The location row also shows while no position has been obtained yet (for example, after opening a plan from a notification and returning to the form), with a "Thử lại" retry. Without it, the form would be stuck with no location.
  - For guests, "Xem lại lịch sử ý tưởng" opens their one cached plan, as the old guest link did. If there's no cached plan, it opens the history screen, which asks them to log in.
  - A guest's circled date comes from the new `saved_date_plan_date` SharedPreferences key, written when a plan is generated. Plans cached before this change aren't circled.
  - Changing the start time so the date is under 1 hour moves the end time to start + 1 hour. Choosing an end time under 1 hour is rejected with a snackbar.
  - Per user request, all UI text is in Vietnamese instead of following the Figma frame: header "Thiết Kế Hẹn Hò", calendar month "THÁNG 9" ("THÁNG 1/2027" for other years), weekdays "CN T2 … T7".
