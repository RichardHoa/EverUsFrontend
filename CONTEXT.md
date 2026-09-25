# EverUs

A couples app: users answer a preferences Questionnaire, then use features like the date planner built on top of those preferences.

## Language

**Questionnaire**:
The set of questions asked about a user's (or couple's) preferences, distinct from the date planner's separate likes/dislikes feature. Backed by `QuestionnaireScreen`/`QuestionnaireHelper` on the client and the `/questionnaire/*` routes on the backend.
_Avoid_: Survey, onboarding form

**QuestionnaireResponse**:
A single record per identity (`user_id` or, for guests, `device_id`) holding a user's answers to the Questionnaire. Has a status of `in_progress` or `submitted`; answers accumulate in place on the same record as they're autosaved, and submitting flips the status rather than creating a new record.
_Avoid_: Draft, submission (as separate entities — this repo models them as one record with a status, not two concepts)

**Identity resolution**:
How a QuestionnaireResponse (and other guest-accessible data) is scoped: to a logged-in user's `user_id` from the JWT, or, for guests, to a `device_id` from the `X-Device-Id` header. Both identity kinds can have their own QuestionnaireResponse.

**AuthWrapper gate**:
The top-level widget (`main.dart`) that reactively routes between `LoginScreen`, `QuestionnaireScreen`, and `LandingScreen` based on session state and `QuestionnaireHelper.isCompletedNotifier`. This is the hard-redirect mechanism that sends a logged-in user straight to the Questionnaire on every login until their QuestionnaireResponse status is `submitted`.

**Stage**:
One stop in a generated date plan. Each stage has a primary Location and up to three Backup options for the same keyword/category.
_Avoid_: Location (when you mean the whole stage rather than the specific place)

**Distance preference**:
The user's chosen search radius band for the whole plan: `gan` (Vietnamese for "near", ≤5km), `xa` ("far", 5-15km), or `tuyHung` ("random"), which resolves client-side to `gan` or `xa` before the plan request is sent.
_Avoid_: Budget tier, proximity mode

**Candidate pool**:
The set of places fetched for one Stage's keyword, already filtered by the active Distance preference's band via a Haversine SQL query anchored on a reference point.
_Avoid_: Search results, options list

**Backup rank**:
The ordering applied to a Stage's Backup options. For Stage 1 and later, ranked by distance to the previous stage's chosen Location. For Stage 0 (the first stop), ranked by distance to the user's own location instead, since there is no previous stage to anchor to.
