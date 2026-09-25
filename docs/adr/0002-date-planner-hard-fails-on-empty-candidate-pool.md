---
status: accepted
---

# Date planner aborts generation on any empty candidate pool, instead of inserting a placeholder stage

When a Stage's Candidate pool comes back empty (e.g. no places within the active Distance preference band), the date planner previously fabricated a placeholder `NOT_FOUND_NAME` place for that stage so the rest of the plan could still be generated. We decided to remove this fallback entirely: any stage with an empty candidate pool now raises an error that aborts the whole plan generation, surfaced to the user via the existing error UI, rather than ever returning a plan containing a fake stage.

We chose this because a placeholder stage silently violates the guarantees users pick a Distance preference for — most concretely, it broke the requirement that a `gan` first stage (and its backups) must be genuinely ≤5km from the user, since a placeholder has no real distance at all. Failing loudly and letting the user retry or widen their preference was judged better than shipping a plan with a stage that isn't a real place.
