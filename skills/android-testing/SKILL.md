---
name: android-testing
description: |
  Testing patterns for Android/KMP - ViewModel unit tests with JUnit5, Turbine, AssertK, UnconfinedTestDispatcher, fake repositories, SavedStateHandle, and Compose UI tests. Use this skill whenever writing or reviewing tests for ViewModels, repositories, use cases, or Compose screens. Trigger on phrases like "write a test", "unit test the ViewModel", "test a repository", "Turbine", "fake repository", "UnconfinedTestDispatcher", "runTest", "ComposeTestRule", or "JUnit5".
metadata:
  author: Philipp Lackner
---

# Android / KMP Testing

Read the reference matching the test boundary:

- Pure in-process logic, ViewModels, fakes, Turbine, SavedStateHandle or dispatcher
  injection: [unit tests](references/unit-testing.md).
- Real repositories, Room, networking or other I/O boundaries: [integration tests](references/integration-testing.md).
- Compose UI on a device/emulator, real ViewModels, feature E2E or the Robot pattern:
  [UI tests](references/ui-testing.md).

Read another branch only when the test crosses that boundary. For test library and
infrastructure setup, use `testing-setup`. The current source set keeps the original
`android-testing` entry point rather than installing the upstream split names.
