# EXECUTION.md

## 1. Purpose

This document defines how the coding agent must operate while implementing the project described in `AGENTS.md`.

It does not define the application's architecture, libraries, frameworks, implementation patterns, or other technical solutions unless explicitly required by `AGENTS.md`.

Its purpose is to establish an autonomous, disciplined, and verifiable execution process.

---

## 2. Source of Truth

Before making any implementation decision, read and understand `AGENTS.md` in its entirety.

`AGENTS.md` is the authoritative specification for the project.

The agent must preserve all explicit requirements defined there.

When `AGENTS.md` leaves an implementation detail open, the agent must make the technical decision autonomously.

Do not replace explicit requirements with assumptions.

Do not reinterpret functional requirements merely because another implementation would be technically preferable.

---

## 3. Initial Assessment

Before writing implementation code:

1. Read `AGENTS.md`.
2. Inspect the existing project structure.
3. Identify the available development environment and tooling.
4. Determine what is already implemented, if anything.
5. Identify the major implementation areas required by the specification.
6. Establish a reasonable implementation order based on dependencies between those areas.

Do not ask the user to choose between ordinary technical alternatives that can be resolved by engineering judgment.

---

## 4. Autonomous Technical Decisions

The agent has authority to make technical decisions that are not explicitly defined by `AGENTS.md`.

Examples include:

- architecture;
- project structure;
- database access strategy;
- SQLite library or persistence mechanism;
- state management approach;
- navigation implementation;
- data transfer between screens;
- filtering implementation;
- validation approach;
- error-handling structure;
- dependency selection;
- internal abstractions;
- naming of internal implementation components.

When multiple technically valid solutions exist:

1. Evaluate the project requirements.
2. Consider simplicity and maintainability.
3. Consider compatibility with the project's platform and constraints.
4. Prefer solutions appropriate to the size and scope of the application.
5. Select one solution and proceed.

Do not stop implementation merely because multiple valid alternatives exist.

---

## 5. When to Ask the User

The agent should avoid unnecessary interruptions.

Ask the user only when:

- an explicit requirement is contradictory;
- an essential requirement is genuinely ambiguous and cannot reasonably be resolved;
- a required resource or credential is unavailable;
- an external action requires user authorization;
- continuing would require making a decision that materially changes the defined product;
- the environment prevents implementation and no reasonable workaround exists.

Do not ask for confirmation of ordinary implementation decisions.

Do not ask the user to choose an architecture, library, state-management solution, navigation strategy, or similar technical detail when `AGENTS.md` intentionally leaves that decision open.

---

## 6. Implementation Strategy

Work toward a complete, executable application rather than producing isolated code fragments.

Prioritize the dependency chain of the application.

A reasonable execution sequence is:

1. Project foundation.
2. Core data models.
3. Persistence.
4. Core application logic.
5. Main screens and navigation.
6. Task operations.
7. Categories.
8. Filtering and search-related behavior.
9. Due dates.
10. Notifications and permissions.
11. Error handling.
12. UI refinement.
13. Validation and acceptance review.

This order is not mandatory.

The agent may change the implementation order when doing so is technically justified.

Avoid premature abstractions.

Avoid adding infrastructure or dependencies that do not provide meaningful value for the requirements.

---

## 7. Incremental Execution

After completing a meaningful implementation unit:

1. Check the affected files.
2. Validate the implementation.
3. Resolve errors before continuing when practical.
4. Continue to the next implementation unit.

Do not repeatedly stop after every small change to request approval.

The objective is autonomous progress toward a complete application.

---

## 8. Validation Loop

The agent must validate its own work throughout development.

Whenever applicable:

- run static analysis;
- run formatting tools;
- run tests;
- build the application;
- verify database operations;
- verify navigation;
- verify user interactions;
- verify permissions;
- verify notifications;
- inspect runtime errors;
- correct problems found.

If a validation step fails:

1. Determine the cause.
2. Fix the underlying problem.
3. Re-run the relevant validation.
4. Continue only after confirming the correction when practical.

Do not consider generated code complete merely because it was written successfully.

---

## 9. Requirement Traceability

While implementing, continuously compare the implementation against `AGENTS.md`.

For each major requirement, determine whether it is:

- implemented;
- partially implemented;
- not implemented;
- blocked.

Do not silently omit requirements.

If a requirement cannot be implemented because of an environmental limitation, record the limitation in `BUILD_LOG.md`.

---

## 10. Technical Decision Logging

Whenever the agent makes a meaningful technical decision that was not explicitly defined by `AGENTS.md`, record it in `BUILD_LOG.md`.

For significant decisions, record:

- the decision;
- the reason for the decision;
- relevant alternatives considered, when useful;
- the resulting impact, when relevant.

Do not record trivial implementation details merely for the sake of producing a long log.

The purpose of the log is to make the agent's reasoning and development history observable.

---

## 11. BUILD_LOG.md

`BUILD_LOG.md` must be kept updated during development according to the requirements in `AGENTS.md`.

The log should reflect actual development activity.

Do not fabricate decisions, validations, tests, or implementation progress.

Do not rewrite history to make the development process appear cleaner than it was.

If the agent changes a previous technical decision, record the change and the reason for it.

---

## 12. Self-Review

Before declaring the project complete, perform a final review.

Check:

1. Every explicit requirement in `AGENTS.md`.
2. Every functional acceptance criterion.
3. Every required screen and user flow.
4. Persistence behavior.
5. Error handling.
6. Permissions.
7. Notifications.
8. Navigation.
9. Filtering.
10. Data integrity.
11. Build and runtime stability.
12. UI requirements.

Fix incomplete or incorrect behavior discovered during the review.

---

## 13. Completion Criteria

The task is complete only when:

- the application is implemented to the extent permitted by the environment;
- the main requirements in `AGENTS.md` are satisfied;
- validation has been performed;
- discovered problems have been addressed where practical;
- `BUILD_LOG.md` reflects the actual development process;
- remaining limitations, if any, are explicitly documented.

Do not declare completion solely because the application builds.

---

## 14. Final Report

At the end of execution, provide a concise summary containing:

- architecture selected;
- important technical decisions;
- main dependencies;
- persistence strategy;
- state-management strategy;
- navigation strategy;
- notification strategy;
- validation performed;
- relevant problems encountered and corrected;
- remaining limitations or pending work.

The final report should describe what was actually implemented, not what was originally planned.
