# Mobile To-Do App — Project Specification

## Specification Authority

This document is the authoritative specification for the project.

It defines the product requirements, functional requirements, constraints, and acceptance criteria.

When implementation details are not explicitly defined here, the coding agent is expected to make an appropriate technical decision autonomously.

Do not replace explicit requirements with assumptions, preferences, or generated implementation patterns.

---

# 1. Development Log Requirement

You are responsible for implementing this project and continuously documenting the real development process in:

`BUILD_LOG.md`

Create `BUILD_LOG.md` at the beginning of the project.

Keep it updated throughout development.

For every meaningful development interaction, decision, implementation step, bug, correction, or relevant discovery, append a new entry.

Each meaningful entry should contain:

## Prompt / Request

Record the user request that led to the change.

Preserve the original wording whenever practical.

## Decision Summary

Briefly explain:

- what was decided;
- important architectural or technical decisions;
- assumptions made;
- relevant alternatives considered.

Provide concise reasoning only. Do not expose private hidden chain-of-thought.

## Actions Performed

Describe what changed, such as:

- files created or modified;
- dependencies installed;
- database schema changes;
- navigation changes;
- notification changes;
- refactoring.

## Result

Describe the actual result:

- feature implemented;
- build succeeded or failed;
- feature partially works;
- runtime error occurred;
- notification behavior failed or succeeded.

## Problems / Errors

Record relevant:

- compiler errors;
- runtime errors;
- incorrect assumptions;
- bugs;
- unexpected behavior.

## Fixes Attempted

Record meaningful attempts made to solve problems, including unsuccessful attempts when relevant.

## Current Status

Use one of:

- Completed
- Partially completed
- Broken
- Needs testing
- Blocked

Do not rewrite previous entries merely to make the history appear cleaner.

If a previous decision turns out to be wrong, preserve the original entry and add a new entry describing the correction.

---

# 2. Project Goal

Build a mobile to-do application with:

- SQLite persistence;
- multiple screens;
- task categories;
- task filtering;
- optional due date and time;
- scheduled local notifications.

The application must continue to work after being closed and reopened.

---

# 3. Task Data Model

A task must contain at least:

- `id`
- `title`
- `description`
- `completed`
- `dueDateTime`
- `createdAt`
- `categoryId`

Requirements:

- `id` must uniquely identify the task;
- `title` is required;
- `description` is optional;
- `completed` indicates whether the task has been completed;
- `dueDateTime` is optional;
- `createdAt` must record when the task was created;
- `categoryId` is optional.

Additional fields may be added when they are useful for a sound implementation.

Document additional fields in `BUILD_LOG.md`.

---

# 4. Category Data Model

A category must contain at least:

- `id`
- `name`

Examples:

- Personal
- Work
- Study
- Shopping

Categories must be stored persistently in SQLite.

Additional properties such as color, icon, or description may be added when useful.

Document additional fields in `BUILD_LOG.md`.

---

# 5. SQLite Persistence

Use SQLite for local persistence.

At minimum, the database must persist:

- tasks;
- categories.

Data must remain available after:

- navigating between screens;
- closing the app;
- reopening the app;
- restarting the emulator or device.

The agent may choose the appropriate SQLite library, ORM, abstraction layer, DAO, repository, or direct SQL approach.

Document the selected approach in `BUILD_LOG.md`.

---

# 6. Required Screens

The application must contain at least three screens.

## Screen 1 — Task List

This is the main application screen.

Display stored tasks.

Each task should visibly show at least:

- title;
- completed/pending state;
- category, if one exists;
- due date/time, if one exists.

The screen must allow filtering tasks by:

- All;
- Pending;
- Completed.

The screen must also allow filtering by category.

The exact UI is intentionally left open.

The user must be able to:

- create a new task;
- open an existing task;
- mark a task as completed or pending;
- navigate to category management.

## Screen 2 — Task Editor / Detail

This screen must allow creating and editing tasks.

Editable fields:

- title;
- description;
- due date;
- due time;
- category;
- completed status.

Requirements:

- title is required;
- category is optional;
- due date/time is optional.

When editing an existing task, populate the form with its current values.

The user must be able to:

- save;
- cancel;
- delete an existing task.

## Screen 3 — Category Management

This screen must allow the user to:

- list existing categories;
- create a category;
- rename a category;
- delete a category.

The behavior when deleting a category currently used by tasks is intentionally left as a technical/product decision for the agent.

Choose a sensible behavior and document it in `BUILD_LOG.md`.

---

# 7. Navigation

Implement navigation between:

1. Task List
2. Task Editor / Detail
3. Category Management

When opening an existing task for editing, choose an appropriate data-transfer strategy.

Possible approaches include:

- passing only the task ID;
- passing the full task object;
- shared application state;
- another suitable approach.

Choose the approach appropriate to the architecture and document the decision in `BUILD_LOG.md`.

---

# 8. Task Operations

The application must support:

## Create

Create a new task and persist it to SQLite.

## Edit

Edit an existing task and persist the changes.

## Complete / Reopen

The user must be able to:

- mark a pending task as completed;
- mark a completed task as pending again.

## Delete

Delete a task from SQLite.

If the task has an associated scheduled notification, cancel it.

---

# 9. Due Dates

Tasks may have an optional due date and time.

If no due date/time is selected, the task must work normally without a reminder.

If a future date/time is selected, schedule a local notification.

---

# 10. Local Notifications

Use scheduled local notifications.

Do not depend on a remote push notification server.

Required behavior:

## Task created with future due date

Schedule a notification.

## Task due date changed

Cancel the old notification and schedule a new one.

## Task due date removed

Cancel the existing notification.

## Task completed

Cancel its scheduled notification.

## Completed task changed back to pending

If its due date/time is still in the future, the notification may be scheduled again.

## Task deleted

Cancel its notification.

If useful, store a notification identifier associated with the task.

Document the notification strategy in `BUILD_LOG.md`.

---

# 11. Notification Permissions

If the operating system requires notification permission:

- request it appropriately;
- handle denial gracefully;
- do not crash if permission is denied.

Document permission-related decisions in `BUILD_LOG.md`.

---

# 12. Filtering

Support task filtering by:

## Status

- All
- Pending
- Completed

## Category

Allow selecting a category to display only tasks from that category.

The implementation may use:

- in-memory filtering;
- SQLite queries;
- reactive database queries;
- another reasonable approach.

Choose the approach appropriate to the project and document it in `BUILD_LOG.md`.

---

# 13. Error Handling

Handle common errors reasonably, including:

- invalid title;
- SQLite errors;
- invalid dates;
- notification permission denial;
- notification scheduling errors.

The app should not crash unnecessarily.

Provide user feedback when appropriate.

---

# 14. UI Requirements

There is no mandatory visual design.

The UI should be:

- usable;
- understandable;
- reasonably consistent;
- suitable for a mobile device.

The agent may choose the visual style.

Avoid spending excessive effort on visual polish before required functionality works.

---

# 15. Architecture

The architecture is intentionally not prescribed.

Possible approaches include:

- MVVM;
- MVC;
- repository-based architecture;
- feature-based organization;
- Clean Architecture;
- framework-native conventions.

Do not introduce unnecessary complexity only for architectural purity.

Prefer a structure appropriate for a small educational application.

The selected architecture and major architectural decisions must be documented in `BUILD_LOG.md`.

---

# 16. State Management

Choose an appropriate state-management approach.

The application must correctly refresh the UI after:

- creating a task;
- editing a task;
- deleting a task;
- completing a task;
- changing a filter;
- modifying categories.

The selected state-management strategy must be documented in `BUILD_LOG.md`.

---

# 17. Dependencies

Dependencies may be added when useful.

For every important dependency added, record in `BUILD_LOG.md`:

- dependency name;
- purpose;
- why it was selected.

Avoid unnecessary libraries.

---

# 18. Autonomous Technical Decisions

Technical decisions not explicitly defined by this specification belong to the coding agent.

When multiple valid solutions exist:

1. evaluate the project scope;
2. consider simplicity;
3. consider maintainability;
4. consider reliability and compatibility;
5. consider the stated requirements;
6. choose the solution that best fits the project;
7. document the decision in `BUILD_LOG.md`.

Do not ask the user to choose between ordinary implementation alternatives.

Only request clarification when:

- two explicit requirements conflict;
- a genuinely ambiguous requirement materially changes the expected product behavior;
- required information is unavailable;
- an external constraint prevents implementation;
- continuing would require violating an explicit requirement.

The agent should resolve ordinary technical uncertainty autonomously rather than delegating decisions back to the user.

---

# 19. Implementation Strategy

Work incrementally while maintaining awareness of the complete application.

A suggested implementation order is:

1. initialize project;
2. create `BUILD_LOG.md`;
3. establish basic navigation;
4. define models;
5. configure SQLite;
6. implement task CRUD;
7. implement category CRUD;
8. connect UI to persistent data;
9. implement filtering;
10. implement due dates;
11. implement notifications;
12. handle permissions;
13. test persistence;
14. test notification behavior;
15. review and clean up the project.

This order may be changed when the agent determines that another sequence is more appropriate.

If the order is changed for a meaningful architectural reason, document the decision in `BUILD_LOG.md`.

---

# 20. Validation

Do not assume generated code is correct.

Whenever possible:

- build the project;
- run it;
- inspect compiler output;
- test important user flows;
- verify persistence;
- verify notification behavior;
- fix errors found.

A feature is not complete merely because source code has been generated.

Record meaningful failures and fixes in `BUILD_LOG.md`.

---

# 21. Functional Acceptance Criteria

Before considering the project complete, verify:

- [ ] application builds successfully;
- [ ] application starts successfully;
- [ ] tasks can be created;
- [ ] tasks can be edited;
- [ ] tasks can be deleted;
- [ ] tasks can be marked completed;
- [ ] completed tasks can become pending again;
- [ ] tasks persist in SQLite;
- [ ] categories can be created;
- [ ] categories can be renamed;
- [ ] categories can be deleted;
- [ ] tasks can optionally belong to categories;
- [ ] status filtering works;
- [ ] category filtering works;
- [ ] navigation between required screens works;
- [ ] due dates can be assigned;
- [ ] local notifications can be scheduled;
- [ ] notifications are updated if due dates change;
- [ ] notifications are canceled when tasks are deleted;
- [ ] notifications are canceled when tasks are completed;
- [ ] notification permission is handled safely;
- [ ] data remains available after restarting the app;
- [ ] `BUILD_LOG.md` contains the development history.

---

# 22. Final Review

When the implementation appears complete:

1. review every acceptance criterion;
2. identify incomplete or partially working features;
3. test the most important application flows;
4. review important technical decisions;
5. verify that the implementation has not introduced unnecessary complexity;
6. update `BUILD_LOG.md`;
7. provide a concise final summary containing:
   - architecture used;
   - important dependencies;
   - SQLite strategy;
   - state-management strategy;
   - navigation strategy;
   - notification strategy;
   - known limitations;
   - remaining bugs.

Do not remove or rewrite earlier `BUILD_LOG.md` entries.

---

# Important Instruction

Throughout the entire project:

**KEEP `BUILD_LOG.md` UPDATED.**

The development history is an essential part of the assignment, not optional documentation.
