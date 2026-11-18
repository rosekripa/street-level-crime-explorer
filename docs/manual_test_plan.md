# Manual test plan

Run in Chrome (desktop) against the live APIs, using a release build served
locally. The data is monthly and can be republished, so totals other than the
SW1A 1AA reference may differ slightly between runs.

## How to run the build

    flutter build web
    python3 -m http.server 8081 -d build/web

Open http://localhost:8081. In Chrome DevTools, use the Network tab with
"Disable cache" ticked and the Fetch/XHR filter.

## Reference values

SW1A 1AA, September 2026: 2,929 incidents, 6.2% lower than August 2026.
Top six: Other theft 541, Violent crime 501, Theft from the person 472,
Anti-social behaviour 412, Shoplifting 403, Public order 164.
Plus 8 other categories totalling 436.

## Cases

| # | Area | Steps                                                                                                                                                        | Expected | Result |
|---|------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|-------|
| 1 | Start screen | Open the app                                                                                                                                                 | Navy hero with brand, heading and three pills (1-mile radius, Monthly data, England, Wales and NI). Search card overlapping the hero. Three example chips, Scotland coverage note, "Data available up to September 2026". "About these numbers" with three tiles. No Clear button. Exactly one request (crime-last-updated, 200). No console errors. Icons visible. | Pass  |
| 2 | Happy path | SW1A 1AA, September 2026, press Search                                                                                                                       | 2,929 incidents reported. "6.2% lower than August 2026". Six bars, top one full width. "+ 8 other categories: 436 incidents". Three requests: postcodes.io, then police date=2026-09 and date=2026-08. | Pass  |
| 3 | Example chip | Click CF10 1EP                                                                                                                                               | Postcode fills and the search runs immediately. Results for Cardiff, about 1,300 incidents. Comparison with August 2026. | Pass  |
| 4 | Enter key | Type SW1A 1AA, press Enter                                                                                                                                   | Same as pressing Search, one search only (three requests). Changing the month first and then pressing Enter searches the new month. | Pass  |
| 5 | Empty input | Empty postcode, press Search. Then a single space.                                                                                                           | "Enter a UK postcode" under the field. No network request. Message clears on a valid search. | Pass  |
| 6 | Postcode formats | Try sw1a1aa and a postcode with spaces around it                                                                                                             | Results, or "Postcode not found". Never a crash or a stuck spinner. | Pass  |
| 7 | Unknown postcode | ZZ99 9ZZ                                                                                                                                                     | "Postcode not found". No Retry button. | Pass  |
| 8 | Scotland | EH1 1YZ                                                                                                                                                      | "No data returned" with the Scotland coverage sentence. Never says "no crime". | Pass  |
| 9 | Month picker limits | Open the picker                                                                                                                                              | October to December 2026 greyed out. Year arrows stop at 2023 and 2026. October 2023 selectable. | Pass  |
| 10 | Picker sends nothing | Pick a month, watch the Network tab                                                                                                                          | No request until Search is pressed. | Pass  |
| 11 | Month comparison | Pick August 2026, search SW1A 1AA                                                                                                                            | Compared with July 2026. | Pass  |
| 12 | Slow network | Network: Slow 3G, Disable cache, then search                                                                                                                 | Spinner on the button. Either results arrive, or an error panel with Retry appears after the 15 s timeout and retries. Never stuck on loading. | Pass |
| 13 | Offline and Retry | Network: Offline, search. Then back online and press Retry.                                                                                                  | Error panel with Retry after the automatic retries. Retry loads results. | Pass  |
| 14 | Stale response | Slow 3G. Search SW1A 1AA, then at once CF10 1EP.                                                                                                             | Only the Cardiff results are shown. | Pass  |
| 15 | Clear | (a) After results, press Clear. (b) Slow 3G: search, then press Clear while loading.                                                                         | (a) Start screen, empty postcode, latest month selected. (b) Start screen stays and late results never appear. | Pass |
| 16 | Partial failure | Block requests matching url pattern example: `https://data.police.uk/api/crimes-street/all-crime?*date=2026-08` (DevTools, More tools, Request conditions), search September | September results show. Comparison line says it could not be loaded. | Pass  |
| 17 | Narrow widths | Resize to 375 px, then 320 px. Check the start screen, a results screen and the month dialog.                                                                | No overflow or clipped text. Pills wrap and tiles stack. Below about 250 px is not supported. | Pass |
| 18 | Keyboard | Tab through the form, Enter to search, Esc to close the month dialog                                                                                         | Order: postcode, month field, Search, then Clear (when shown) and the example chips. Focus is visible. Esc closes the dialog. | Pass |
| 19 | Info tiles | Look under the chips and under results                                                                                                                       | "About these numbers" with three tiles: fixed 1-mile area, published monthly, counts not rates. One row on desktop, stacked at 375 px, no overflow. | Pass |
| 20 | Wording | Read every state, the hero and the tiles. Search the code for risky words.                                                                                   | Numbers are always described as incidents reported. "Crime rate" and "safety score" appear only in "not a ..." disclaimers (results footnote, Counts, not rates tile). Never "no crime". | Pass |
| 21 | Loading screen | Slow 3G, Disable cache, hard reload                                                                                                                          | Light loading screen with a bobbing pin, then a fade into the app with no white flash. | Pass |

## Observations

- Automatic retries are capped at 2 per request (3 attempts). Each manual
  Search or Retry press starts a new search with its own attempts.
- Requests from an abandoned search are not cancelled. The screen ignores
  their answers (cases 14 and 15).

## Browsers

- Chrome (macOS): all cases above.
- Safari (macOS): the final UI was checked, including the start screen, search,
  month dialog, Clear, validation and the not-found and no-data states.
  Safari has no throttling, offline or request-blocking switches like Chrome's,
  so cases 12 to 16 were run in Chrome only.

## Not tested

- Firefox and real mobile devices.
- A real screen reader. Semantic labels are set on the bars but not verified.
- Very busy areas that hit the 10,000-incident limit (503 from the police API).