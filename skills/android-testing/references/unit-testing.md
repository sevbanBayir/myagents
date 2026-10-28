# Android Unit Testing

## What is a unit test (sharp definition)

A unit test:

- Runs entirely in-process, in memory.
- Does **no I/O** — no disk, no network, no database, no real system clock (use a fake `Clock`), no real concurrency primitives.
- Is independent of every other test, runs in milliseconds.
- May wire as many real classes together as is convenient, **as long as none of them cross those boundaries**.

Examples:

- ✅ `LoginViewModel` + real `LoginValidator` + real `EmailNormalizer` + fake `AuthRepository` → unit.
- ❌ `LoginViewModel` + real `AuthRepository` over `MockWebServer` → integration (network boundary).
- ❌ `UserDao` + in-memory Room → integration (real SQLite engine).

### When to switch to a different skill

- The test crosses an I/O / process / external-state boundary (Room, MockWebServer, real `Clock`, file system, WorkManager) → use [integration tests](integration-testing.md).
- The test exercises Compose UI on a device → use [UI tests](ui-testing.md).

---

## Stack

| Concern | Library |
|---|---|
| Test framework | JUnit5 |
| Assertions | AssertK |
| Flow / StateFlow | Turbine |
| Coroutines | `kotlinx-coroutines-test` + `UnconfinedTestDispatcher` |

---

## How to enumerate the test cases for a unit

A unit test suite is **complete** when you cannot name another way to break the unit without changing its public contract. Don't stop at the happy path.

Procedure:

1. List the unit's **public surface** — every `fun`, every observable state field, every emitted event, every return-value branch.
2. For every observable behavior, ask:

   > **"How could we possibly break this behavior?"**

   Write a test for each break vector you can name.
3. Walk this default checklist for every unit:

   - Empty input.
   - Single-element input.
   - Large / repeated input.
   - Null / optional fields, default values.
   - Each error branch from every collaborator (success, every `DataError`, exception).
   - Action dispatched while the unit is already busy (loading, in-flight network, debounce window).
   - Idempotency: same action twice in a row.
   - Loading → success → failure transitions, in every order.
   - State restoration from `SavedStateHandle` after process death.
   - Boundary values for any numeric / range logic (0, 1, max, max+1, negative).
4. Stop only when the next test you can name would re-test something already covered.

If you want to prove you stopped at the right point, an optional mutation-testing pass (see [Optional verification](#optional-verification--mutation-testing)) is the strongest check — run it when the user explicitly asks.

---

## ViewModel test setup

```kotlin
class NoteListViewModelTest {
    private val testDispatcher = UnconfinedTestDispatcher()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }
}
```

`UnconfinedTestDispatcher` runs coroutines eagerly inline — no need to call `advanceUntilIdle()` after every action.

---

## Testing state with Turbine

```kotlin
@Test
fun `loading notes emits loading then notes`() = runTest {
    val repo = FakeNoteRepository().apply {
        notes = listOf(Note("1", "Hello"))
    }
    val viewModel = NoteListViewModel(repo)

    viewModel.state.test {
        assertThat(awaitItem().notes).isEmpty()
        viewModel.onAction(NoteListAction.OnRefreshClick)
        assertThat(awaitItem().isLoading).isTrue()
        val loaded = awaitItem()
        assertThat(loaded.isLoading).isFalse()
        assertThat(loaded.notes).hasSize(1)
    }
}
```

---

## Testing effects (one-time side effects)

Use the local `Effect` contract and `effects` Flow from `android-presentation-mvi`.
Test a side effect that follows an async result, rather than routing a plain
navigation click through the ViewModel.

```kotlin
@Test
fun `successful login emits LoginSucceeded`() = runTest {
    val viewModel = LoginViewModel(FakeAuthRepository())

    viewModel.effects.test {
        viewModel.onAction(LoginAction.OnLoginClick)
        assertThat(awaitItem()).isEqualTo(LoginEffect.LoginSucceeded)
    }
}
```

---

## Fakes over mocks

Always prefer **fakes** for repository, data-source, and service collaborators. Reach for mocks only when faking is impossible (e.g., final framework class you can't subclass, and even then prefer a thin wrapper you control).

A fake is a working in-memory implementation of the real interface:

```kotlin
class FakeNoteRepository : NoteRepository {

    var notes = listOf<Note>()
    var shouldReturnError = false

    override suspend fun getNotes(): Result<List<Note>, DataError.Local> {
        return if (shouldReturnError) Result.Error(DataError.Local.UNKNOWN)
        else Result.Success(notes)
    }

    override suspend fun insertNote(note: Note): EmptyResult<DataError.Local> {
        notes = notes + note
        return Result.Success(Unit)
    }
}
```

Why fakes win:

- Tests assert **behavior** (final state, emitted values), not call patterns.
- Refactoring the production interface doesn't silently break tests because the fake refuses to compile.
- One fake serves dozens of tests; mocks usually duplicate setup per test.

Mocks (MockK) are acceptable only when:

- The collaborator is a final framework class you cannot subclass and don't own.
- You're verifying a side effect that has no observable result (rare — push back on this).

---

## A unit is not a single class

The "unit" is a **unit of logical behavior**, not a single file. A unit test of `LoginViewModel` may instantiate the real `LoginValidator`, real `EmailNormalizer`, and real `PasswordRulesProvider` — all of them are pure logic and stay within the unit-test boundaries. Don't extract a fake just to satisfy an imaginary "one class per test" purity rule.

Rule of thumb: if a collaborator is pure logic and cheap to construct, **use the real thing**. Only fake collaborators that would cross an I/O boundary.

---

## Instrumented unit tests are still unit tests

If a class needs Android framework types but does **no I/O** (e.g., a pure helper around `Uri` parsing), it can live under `androidTest/` and still be a unit test by this skill's definition. Don't force it onto the JVM by adding shadows or wrappers — run it instrumented.

This is rare. Most genuine units are JVM-only. But when a unit truly needs Android, an instrumented unit test is fine.

---

## SavedStateHandle in tests

Instantiate it directly with a map — no mocking:

```kotlin
val savedStateHandle = SavedStateHandle(mapOf("noteId" to "123"))
val viewModel = NoteEditorViewModel(savedStateHandle, FakeNoteRepository())
```

To verify state restoration after process death, set values on the handle, build the ViewModel, and assert the recovered state.

---

## When to inject dispatchers

Only inject `CoroutineDispatcher` into a class when **both** are true:

1. The class dispatches to a non-Main dispatcher (e.g., `withContext(Dispatchers.IO) { … }`).
2. The class is directly unit-tested.

ViewModels that only use `viewModelScope` do **not** need an injected dispatcher — `Dispatchers.setMain()` covers them.

If a non-ViewModel class uses `withContext(Dispatchers.IO)` and is unit-tested, inject:

```kotlin
class ImageEncoder(private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO) {
    suspend fun encode(bytes: ByteArray): String = withContext(ioDispatcher) { … }
}

// In test:
val encoder = ImageEncoder(ioDispatcher = UnconfinedTestDispatcher())
```

---

## Optional verification — mutation testing

Mutation testing is a separate workflow and is not installed in this collection.
For an explicitly requested mutation test, consult the [upstream mutation-testing guide](https://github.com/PL-Coding-GmbH/Skills/blob/c27b5b42c0fa3300d71d17d44e838f0f974ea145/skills/kotlin-mutation-testing/SKILL.md) and confirm its prerequisites before running it. Ordinary unit tests do not require this pass.

---

## Anti-patterns

| Anti-pattern | What to do instead |
|---|---|
| Asserting on mock `verify { … }` call patterns | Use a fake and assert on the resulting state or emission. |
| `delay()` or `Thread.sleep()` in tests | Use `UnconfinedTestDispatcher` and Turbine. |
| Two `@Test` methods sharing mutable state on the test class | Make state local to each test or reset in `@BeforeEach`. |
| Real `Dispatchers.IO` / `Default` reaching production code under test | Inject a test dispatcher per [When to inject dispatchers](#when-to-inject-dispatchers). |
| Fake silently swallows exceptions and returns success | Fakes should mirror real failure modes; expose a `shouldReturnError` toggle. |
| Testing private fields via reflection | Test through the public surface; if a behavior isn't observable, it shouldn't have a test. |
| Stopping the test suite at the happy path | Walk the [edge-case checklist](#how-to-enumerate-the-test-cases-for-a-unit) before declaring done; a mutation pass is an optional deeper check when requested. |
