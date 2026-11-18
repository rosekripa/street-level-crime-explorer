# Manual test plan

Run against the live APIs. Cases 1 to 5 were run in Chrome
(desktop) using a release build served locally. The data is monthly and
can be republished, so totals other than the SW1A 1AA reference may differ
slightly between runs.

## How to run the build

    flutter build web --no-tree-shake-icons
    python3 -m http.server 8081 -d build/web

Open http://localhost:8081. In Chrome DevTools, use the Network tab with
"Disable cache" ticked and the Fetch/XHR filter.

`--no-tree-shake-icons` is needed because icon font subsetting was killed
(exit code -9, probably low memory) on my machine.

## Reference values

SW1A 1AA, September 2026: 2,929 incidents, 6.2% lower than August 2026.
Top six: Other theft 541, Violent crime 501, Theft from the person 472,
Anti-social behaviour 412, Shoplifting 403, Public order 164.
Plus 8 other categories totalling 436.

## Cases

| # | Area | Steps | Expected | Result                                                                                              |
|---|------|-------|----------|-----------------------------------------------------------------------------------------------------|
| 1 | Start screen | Open the app | Hero, search card, three example chips, Scotland coverage note, "Data available up to September 2026", methodology collapsed, no Clear button. Exactly one request (crime-last-updated, 200). No console errors. Icons visible. | Pass                                                                                                |
| 2 | Happy path | SW1A 1AA, September 2026, press Search | 2,929 incidents reported. "6.2% lower than August 2026". Six bars, top one full width. "+ 8 other categories: 436 incidents". Three requests: postcodes.io, then police date=2026-09 and date=2026-08. | Pass. The two police requests started 0.4 ms apart (55.14 ms and 55.52 ms), so they run in parallel. |
| 3 | Example chip | Click CF10 1EP | Postcode fills and the search runs immediately. Results for Cardiff, about 1,300 incidents on . Comparison with August 2026. | Pass. Total about 1,300.                                                                            |
| 4 | Enter key | Type SW1A 1AA, press Enter | Same as pressing Search, one search only (three requests). Changing the month first and then pressing Enter searches the new month. | Pass                                                                                                |
| 5 | Empty input | Empty postcode, press Search. Then a single space. | "Enter a UK postcode" under the field. No network request. Message clears on a valid search. | Pass                                                                                                |
| 6 | Postcode formats | Try sw1a1aa and a postcode with spaces around it | Results, or "Postcode not found". Never a crash or a stuck spinner. | Not yet run                                                                                         |
| 7 | Unknown postcode | ZZ99 9ZZ | "Postcode not found". No Retry button. | Not yet run                                                                                         |
| 8 | Scotland | EH1 1YZ | "No data returned" with the Scotland coverage sentence. Never says "no crime". | Not yet run                                                                                         |
| 9 | Month picker limits | Open the picker | October to December 2026 greyed out. Year arrows stop at 2023 and 2026. October 2023 selectable. | Not yet run                                                                                         |
| 10 | Picker sends nothing | Pick a month, watch the Network tab | No request until Search is pressed. | Not yet run                                                                                         |
| 11 | Month comparison | Pick August 2026, search SW1A 1AA | Compared with July 2026. | Not yet run                                                                                         |
| 12 | Slow network | Network: Slow 3G, then search | Spinner on the button. Results arrive. Never stuck on loading. | Not yet run                                                                                         |
| 13 | Offline and Retry | Network: Offline, search. Then back online and press Retry. | Error panel with Retry after the automatic retries. Retry loads results. | Not yet run                                                                                         |
| 14 | Stale response | Slow 3G. Search SW1A 1AA, then at once CF10 1EP. | Only the Cardiff results are shown. | Not yet run                                                                                         |
| 15 | Clear while loading | Slow 3G. Search, then press Clear. | Start screen stays. Late results never appear. | Not yet run                                                                                         |
| 16 | Partial failure | Block requests matching date=2026-08 (Network request blocking), search September | September results show. Comparison line says it could not be loaded. | Not yet run                                                                                         |
| 17 | Phone width | Resize to about 375 px | No overflow or clipped text. Month dialog fits. | Not yet run                                                                                         |
| 18 | Keyboard | Tab through the form, Enter to search, Esc to close the month dialog | Order is postcode, month, button. Focus is visible. | Not yet run                                                                                         |
| 19 | Methodology | Tap "How is this calculated?" | Expands to six sections and collapses again. | Not yet run                                                                                         |
| 20 | Wording | Read every state | Only "incidents reported". Never "crime rate" or "safety score". | Not yet run                                                                                         |

## Browsers

- Chrome (macOS): cases above, as marked.
- Safari (macOS): the start screen and the SW1A 1AA search were checked
  (icons load, 2,929 incidents). The remaining cases were not run in Safari.
  Safari has no throttling, offline or request-blocking switches like
  Chrome's, so cases 12 to 16 need Chrome DevTools.

## Not tested

- Firefox and real mobile devices.
- A real screen reader. Semantic labels are set on the bars but not verified.
- Very busy areas that hit the 10,000-incident limit (503 from the police API).