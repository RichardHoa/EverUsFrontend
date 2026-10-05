# 01: Restyle the landing page to the Figma design

**What to build:** Make the landing page match the Figma `landing_page` frame (file `l7CCuJoNk8RE4yCsCmndNE`, node `2:7`) and keep every existing behaviour.

The "EverUs" title and tagline are removed, and the notification bell stays. The heart mascot becomes an animated yarn ball whose thought bubble still cycles through the existing comments when tapped. The Love counter card shows the day count, both partners' photos (or colour fallbacks) joined by a heart-shaped thread, and each partner's chosen name curved around their circle. The Date Planner and Relationship Reflection cards use the illustrated Figma artwork. The background and footer don't change.

See the parent spec, `.scratch/figma-landing-date-planner/spec.md` (user stories 1–22), for full context.

**Blocked by:** None (can start immediately)

**Status:** implemented, awaiting manual verification

- [x] The title and tagline banner are removed.
- [x] The notification bell stays top-right, with its unread dot and its current tap behaviour, including the login prompt for guests.
- [x] The yarn-ball artwork is exported from Figma at 3x into the images asset folder and replaces the heart mascot.
- [x] The yarn ball has a continuous idle bob and breathe animation drawn in code.
- [x] Tapping the yarn ball plays a short bounce or squish and moves the bubble to the next existing comment.
- [x] The comment shows in a thought bubble styled like the design.
- [x] The Love counter card shows "CHÚNG MÌNH ĐÃ BÊN NHAU", the large day count and "ngày", laid out like the design.
- [x] Each circle shows that partner's photo when one exists, otherwise the design colour (pink for the user, green for the partner).
- [x] A heart-shaped thread connects the two circles.
- [x] Each partner's chosen name is laid out along an arc over their circle, covering up to about half the circumference. Longer names shrink slightly, then end with "…", and never overlap.
- [x] Tapping the Love counter card still opens the Love counter screen. An unconfigured Love counter still forces setup.
- [x] The Date Planner card uses the Figma calendar illustration and still opens the dialog to choose between planning a date and the challenge.
- [x] The Relationship Reflection card uses the Figma hands illustration and still opens Reflection.
- [x] Fonts, sizes and colours come from the Figma design data, scaled from the roughly 3x frame to phone size.
- [x] The existing EverUs background image and shared footer are unchanged.
- [ ] Verified by hand: with and without photos, with short and long names, with and without unread notifications, and the mascot's idle and tap behaviour.

## Comments

- Implemented. Artwork in `assets/images/` (`mascot_yarn.png`, `love_thread.png`, `card_date_planner.png`, `card_reflection.png`) was exported from Figma at 1x of the frame, which is about 3x phone size. Figma's PNG exports had a grey background baked in, so the yarn ball came from the original transparent source image and the cards and thread were exported as SVG, then rendered to transparent PNG.
- SF Compact Rounded isn't available on Android or web, so Nunito stands in for it. The bubble text uses w300 instead of Thin so it stays readable at about 9.8pt.
- A web preview was checked at 393pt width with short names, long names and a two-line comment. Photos, notifications and on-device animation still need checking by hand.

- Per user request (2026-10-05), all UI text is in Vietnamese instead of following the Figma copy:
  - The English titles in `card_date_planner.png` and `card_reflection.png` were erased from the images, and the Vietnamese titles "Lên Lịch Hẹn Hò" and "Nhìn Lại / Mối Quan Hệ" are drawn on top in code (`feature_action_cards.dart`).
  - The Date Planner options dialog title is now "Lên Lịch Hẹn Hò".
