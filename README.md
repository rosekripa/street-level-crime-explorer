# Street Watch

A small Flutter web module. Enter a UK postcode and a month, and see the incidents
reported to police within 1 mile, with a top-categories chart and the change from
the previous month.

The repo and Dart package are called `street_level_crime_explorer`. "Street Watch"
is the name shown in the app.

## Track, APIs and why

**Track 2: UK Crime Explorer**, using two free APIs that need no key:

- [postcodes.io](https://postcodes.io): turns a postcode into latitude, longitude and country.
- [data.police.uk](https://data.police.uk): street-level crimes within 1 mile of a point, and the latest published month (`crime-last-updated`).

I chose this pair because the two APIs depend on each other and fail in different
ways, which gave me real material for the resilience criteria. I checked the
following in the browser before designing:

- CORS works for both APIs.
- A 404 means different things: "postcode not found" in postcodes.io, "month not
  published" in the police API.
- An empty `200` list from the police API can mean "not published yet" or "not
  covered" (Scotland returns an empty list), so the app never says "no crime".
- Coordinates are numbers in one API and strings in the other.
- The police point search uses a fixed 1-mile radius. Custom areas over 10,000
  incidents return a 503 (documented).


## Run it

Prerequisites: Flutter 3.41.9 (stable, Dart 3.11.5) and Chrome. No API keys are needed.

```bash
git clone https://github.com/rosekripa/street-level-crime-explorer.git
cd street-level-crime-explorer
flutter pub get
flutter run -d chrome
```

Try `SW1A 1AA`, or tap an example chip. The first search can take a few seconds,
because the police API is slow on the first request for an area.

To build and serve a release version:

```bash
flutter build web
python3 -m http.server 8081 -d build/web
```

Then open http://localhost:8081.

## Run the tests

```bash
flutter test                # all 68 tests
flutter test test/core      # one folder
flutter test test/features/crime_explorer/presentation/crime_cubit_test.dart   # one file
flutter analyze
```

The tests use mock HTTP clients and fake repositories, so they need no network and no API access.

## Architecture

MVVM with a clean-lite split (data, domain, presentation). There are no use cases:
the module has one operation, `getSummary`, so a use case class would only pass
the call through.

```
lib/
├── main.dart                      composition root (creates the real objects)
├── core/
│   ├── constants/                 API URLs, timeout and retry values
│   ├── errors/                    Failure types
│   ├── network/                   ApiClient (timeout, status checks, retry)
│   ├── theme/                     colours, typography, theme (and spacing values)
│   ├── utils/                     number formatting
│   └── widgets/                   shared message panel
└── features/crime_explorer/
    ├── data/
    │   ├── models/                tolerant JSON parsing
    │   ├── services/              PostcodeService, PoliceDataService
    │   └── repositories/          IncidentRepositoryImpl
    ├── domain/
    │   ├── entities/              location, summary, YearMonth (plain Dart)
    │   └── repositories/          abstract IncidentRepository
    └── presentation/
        ├── cubit/                 CrimeCubit and sealed CrimeState
        ├── screens/               the screen
        └── widgets/               results card, bars, month picker, info tiles
```

**MVVM mapping:** the screen and widgets are the View. `CrimeCubit` is the
ViewModel. Entities and the repository are the Model. Dependencies point
inwards: presentation depends on domain, and data implements domain's repository
interface, so Cubit tests use a fake repository with no network.

### Decisions and trade-offs

| Decision | Why | Trade-off |
|---|---|---|
| Cubit with sealed states, not BLoC or Provider | One screen, no event stream needed. Sealed states make the UI `switch` exhaustive, so a missing state won't compile. | No event log or event transformers. The stale-response guard is a small manual counter. |
| `Failure` is a sealed class that implements `Exception`, with `isRetryable` | The data layer throws, the Cubit catches. Retry rules live in one place and drive both the automatic retry and the Retry button. | Nothing forces a caller to catch it. The Cubit is the single catch point. |
| One shared `ApiClient` | 15 s timeout, status checked before JSON parsing, up to 2 retries for retryable failures on GET. The caller says what a 404 means. | A 503 from a very busy area is retried 3 times even though it likely fails each time. |
| Repository fetches the selected and previous month in parallel | Half the waiting time. If only the previous month fails, results still show without a comparison. | One extra request per search. |
| Logic lives in entities | Top six, "other" total and change percent are plain Dart, so they are easy to unit test. | None worth noting. |
| Hand-built bars and month picker, no packages | Six bars and a month grid are small, so a chart or picker package would add a dependency for little gain. Building them gives exact theming and lets the picker disable months with no data. | No tooltips or zoom, and a simpler picker than a package would give. |
| Search button, not search-on-change | Each search costs three requests, so changing a field shouldn't fire them. | The month field can show a different month from the results until Search is pressed. |
| Month list built from the API's latest month, with a fallback | No hardcoded dates. If the call fails, the Cubit uses today's month minus 2, an estimate. | The fallback can be wrong if the publishing lag changes. |

### Screen states

| State | Class | Shown as |
|---|---|---|
| Start | `CrimeInitial` | Example chips and coverage note. Also where Clear returns to. |
| Loading | `CrimeLoading` | Spinner on the button and in the results area |
| Results, with or without comparison | `CrimeLoaded` | Total, change card, bars. The comparison line says when the previous month could not be loaded. |
| No data | `CrimeNoData` | "No data returned", explaining that this does not mean nothing happened, plus a Scotland note when relevant |
| Postcode not found | `CrimePostcodeNotFound` | Message, no Retry |
| Error or timeout | `CrimeFailed` | Message, Retry only if the failure is retryable |

## Resilience

Timeouts, a capped retry on failures that may succeed, status checks before parsing,
tolerant parsing, ignoring stale responses, partial failure (the selected month
still shows if the comparison month fails), and an error state for anything
unexpected, so the screen never sticks on loading.

## Testing and QA

**Automated:** `flutter test` runs 68 tests, all passing, and `flutter analyze` is clean.

- Domain: `YearMonth` parsing and year wrap, and `IncidentSummary` (top six, the rest, change percent, null and zero previous month, stable tie order).
- Core: failure retryability, number and label formatting, and `ApiClient` with a mock HTTP client (success, caller-supplied 404, retry then success, give up after 3 tries, timeout, network error, bad JSON, empty body).
- Data: model parsing, URL building, 404 mapping for both services.
- Repository: partial failure, selected month failing, postcode not found stopping before any police request.
- Cubit (`bloc_test`): state sequences for each outcome, stale-response guard, retry, reset (including a search in flight and retry after reset), and the month fallback (unreadable, failed, unexpected error, year wrap).
- Widgets: results card, comparison text (lower, higher, about the same, missing previous month), and the month picker dialog.

The top six category counts in the tests are real police figures for SW1A 1AA in
September 2026 (total 2,929). The split of the remaining 436 across eight
categories is invented so the total matches.

**Not covered:** no widget test for the screen itself (the manual plan covers it),
no integration tests against the live APIs, no golden tests, no CI, no Firefox or
real-device testing, and no real screen reader test.

### Quick manual test plan

Run in Chrome against the live APIs. The full plan has 21 cases:
[docs/manual_test_plan.md](docs/manual_test_plan.md). The final UI was also checked in Safari.

| Check | Expected |
|---|---|
| SW1A 1AA, September 2026 | 2,929 incidents reported, 6.2% lower than August 2026, six bars, "+ 8 other categories: 436 incidents" |
| Empty postcode | Message under the field, no network request |
| ZZ99 9ZZ | "Postcode not found", no Retry button |
| EH1 1YZ (Scotland) | "No data returned" with a Scotland note, never "no crime" |
| Slow 3G | Spinner, then results (about 12 s) or an error panel with Retry |
| Offline, then back online | Error panel after 3 attempts, Retry loads results |
| Search, then another search at once | Only the newest search's results are shown |
| Clear while loading | Start screen stays, late results never appear |
| Block the August request | September results with "Comparison with the previous month could not be loaded." |
| 375 px and 320 px wide | No overflow, pills wrap, tiles stack |
| Keyboard | Tab order postcode, month, Search, Clear and chips. Enter searches. Esc closes the month dialog. |

## Known limitations

- Automatic retries are capped, but each manual Search or Retry press starts a new search, and requests from abandoned searches are not cancelled. The screen ignores their answers.
- The postcode is looked up again on every search.
- Very busy areas could hit the police API's 10,000-incident limit.
- Records without a category are skipped, so a total could be slightly low.
- If `crime-last-updated` fails, the latest month is an estimate (today minus 2 months). The police API's lag means the latest month is never the current month.
- Scotland is not covered, and locations in the data are approximate.
- The picker offers 36 months (October 2023 is the oldest the API lists). Layout is checked down to 320 px wide. UI text is inline, with no localisation.

## What I would do with more time

- Map view and a radius selector (1, 2 or 3 miles using a custom area, which brings the 10,000-incident limit into play).
- A multi-month trend for the searched postcode. The partial failure design already supports months that fail.
- Read the month list from `crimes-street-dates` instead of calculating it.
- Cancel in-flight requests, and remember the location to skip repeat lookups.
- Skeleton loading cards, recent searches, and centralised strings.
- A widget test for the screen, and GitHub Actions running analyze and tests.




