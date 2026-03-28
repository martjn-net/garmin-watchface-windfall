# Dive Data Workarounds for Connect IQ Watch Faces

> Research document for the Windfall watch face project.
> Target devices: Descent G2, Descent Mk3 / Mk3i
> Date: 2026-03-28

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Inter-App Data Sharing via Connect IQ](#2-inter-app-data-sharing-via-connect-iq)
3. [Background Services and FIT Data](#3-background-services-and-fit-data)
4. [Companion App via Communications Module](#4-companion-app-via-communications-module)
5. [FIT File Reading On-Device](#5-fit-file-reading-on-device)
6. [Complications API (API 4.2+)](#6-complications-api-api-42)
7. [Temporal Workaround: Detecting Last Activity](#7-temporal-workaround-detecting-last-activity)
8. [Web API Workaround](#8-web-api-workaround)
9. [UserActivity / Activity.Info Post-Dive](#9-useractivity--activityinfo-post-dive)
10. [Existing Apps Showing Dive Data](#10-existing-apps-showing-dive-data)
11. [Forum and Community Findings](#11-forum-and-community-findings)
12. [Feasibility Matrix](#12-feasibility-matrix)
13. [Recommended Architecture](#13-recommended-architecture)
14. [Sources](#14-sources)

---

## 1. Executive Summary

After thorough investigation of all potential workarounds, the situation is clear: **there is no reliable way to get dive-specific data (surface interval, no-fly time, tissue loading, last dive depth) onto a Connect IQ watch face.** Garmin has deliberately walled off all dive data from the Connect IQ sandbox for safety and liability reasons.

However, two partial workarounds exist that could provide **limited** dive-adjacent functionality:

1. **Complications API (best option):** A separate CIQ device app could act as a "dive data bridge," publishing custom complications that the watch face subscribes to. The device app cannot read native dive data either, but it could fetch data from an external server via a background service. This creates a two-app architecture: companion phone app -> server -> CIQ device app -> complication -> watch face.

2. **UserActivityHistory heuristic (unverified):** The watch face could call `UserProfile.getUserActivityHistory()` and attempt to detect dive activities by their sport type. If diving activities appear as type 53 in the iterator, the watch face could calculate a rough surface interval from `startTime + duration`. However, `SPORT_DIVING` (53) is **not defined** in the Connect IQ `Activity.Sport` enum, making this unreliable without hardware testing.

3. **Web API via background service (complex):** A background service in the watch face could call an external server that fetches dive data from the unofficial Garmin Connect API. This requires a server component, is fragile, and updates at most every 5 minutes.

**Bottom line:** None of these workarounds can provide real-time or reliable post-dive data. The Windfall watch face should focus on being the best surface companion for divers using data that IS reliably available (weather, pressure, altitude, sunrise/sunset, body battery, etc.).

---

## 2. Inter-App Data Sharing via Connect IQ

### Question: Can a CIQ app/widget write data to a shared location that a watch face can read?

### Answer: No direct sharing. Complications API is the only inter-app channel.

**Application.Storage and Application.Properties are sandboxed.** Each CIQ app has its own isolated storage. Files are stored in `GARMIN/apps/data/` and `GARMIN/apps/settings/` with per-app separation. A watch face cannot read storage written by another app.

Garmin explicitly rejected a feature request for shared storage between apps:

> "For the record, this has been decided to not implement this for various reasons (primarily for security)."
> -- Garmin official response, [Allow shared storage between apps](https://forums.garmin.com/developer/connect-iq/i/bug-reports/allow-shared-storage-between-apps)

A developer in the forum [Can a Watchface and a Widget share parameters?](https://forums.garmin.com/developer/connect-iq/f/discussion/194213/can-a-watchface-and-a-widget-share-parameters) confirmed:

> "Watch faces and widgets can not share settings or data."

### Available Inter-App Channels

| Channel | How It Works | Limitations |
|---|---|---|
| **Complications API** | App publishes data; watch face subscribes | Only channel for on-device app-to-watchface data. Custom complications appear as `COMPLICATION_TYPE_INVALID`. |
| **Companion phone app** | Phone app acts as intermediary between watch apps | Requires developing a native Android/iOS app. Complex architecture. |
| **External web service** | Both apps read/write to same server | Requires internet, server, background service. 5-minute minimum interval. |

### Key Constraint

Even if inter-app communication were trivial, **no CIQ app can read native dive data**. The source app would need to get dive data from somewhere else (e.g., an external server parsing Garmin Connect data).

---

## 3. Background Services and FIT Data

### Question: Can a CIQ background service read dive-related FIT data after a dive completes?

### Answer: No. CIQ cannot read FIT files. Period.

The Connect IQ SDK provides **no filesystem access** and **no FIT file reader**. Background services have even more restricted APIs than foreground apps.

Background service constraints:
- **Maximum runtime:** 30 seconds per execution
- **Maximum frequency:** Once every 5 minutes (via `Background.registerForTemporalEvent`)
- **Memory limit:** 32 KB (background process)
- **Available APIs:** Communications (makeWebRequest, transmit, registerForPhoneAppMessages), Application.Storage read/write, limited system APIs
- **NOT available:** Sensor module, Activity module, FIT file access, filesystem access

> "You cannot read .fit files with Connect IQ."
> -- [How does a Garmin device read .FIT files?](https://forums.garmin.com/developer/connect-iq/f/discussion/7578/how-does-a-garmin-device-read-fit-files)

> "The SDK doesn't provide a way to read stored .fit files."
> -- [Read value from latest FIT activity file](https://forums.garmin.com/developer/connect-iq/f/app-ideas/7012/read-value-from-latest-fit-activity-file-stored-on-watch-and-display-as-widget)

The `FitContributor` module only allows **writing** custom fields into FIT files during active recording -- it cannot read existing files.

### What About the FIT Files on Disk?

Dive FIT files are stored at `GARMIN/Activity/*.fit` on the device. They contain rich dive data (depth, NDL, tissue loading, gas mixes, etc. -- see Section 10 of `research_dive_data.md`). But CIQ apps have no access to this filesystem path. Only USB access or Garmin Connect sync can extract these files.

---

## 4. Companion App via Communications Module

### Question: Can a phone app read dive data from Garmin Connect and push it to the watch face?

### Answer: Technically possible but extremely complex. Requires a full companion app + server infrastructure.

### Architecture Required

```
Garmin Connect (cloud)
    |
    v  (unofficial API / OAuth)
Custom Server / Phone App
    |
    v  (Communications.transmit / makeWebRequest)
CIQ Background Service on Watch
    |
    v  (Application.Storage / Complications)
Watch Face Display
```

### Communications Module Capabilities

The Connect IQ Mobile SDK allows companion phone apps (Android/iOS) to communicate with CIQ apps:

- **Phone to Watch:** `Communications.registerForPhoneAppMessages()` -- registers callback for incoming messages from the phone companion app
- **Watch to Phone:** `Communications.transmit()` -- sends data to the companion phone app
- **Web Requests:** `Communications.makeWebRequest()` -- HTTP requests from background service

**Watch face constraint:** Watch faces cannot use Communications directly. They must use a **background service** that runs at most every 5 minutes, for at most 30 seconds, with 32 KB memory.

### Connect IQ Mobile SDK

- **Android:** `com.garmin.connectiq:ciq-companion-app-sdk:2.2.0@aar` ([GitHub](https://github.com/garmin/connectiq-android-sdk))
- **iOS:** ConnectIQ Companion App SDK ([GitHub](https://github.com/garmin/connectiq-companion-app-sdk-ios))

The phone app UUID must match the CIQ app UUID (with dashes for iOS: `"a3421fee-d289-106a-538c-b9547ab12095"`).

### Why This Is Impractical for a Watch Face

1. **Requires building a native Android AND iOS app** -- massive development effort
2. **Requires user to install and configure companion app** -- poor UX
3. **Dive data on Garmin Connect may not include all post-dive data** (surface interval, no-fly time are computed by firmware, not stored as activity fields)
4. **5-minute minimum update interval** -- too slow for time-critical data like no-fly countdown
5. **Push notifications require Garmin approval** -- cannot reliably push data to watch
6. **Battery impact** of frequent background communication

### Verdict: Theoretically possible, practically infeasible for a watch face project.

---

## 5. FIT File Reading On-Device

### Question: Can a CIQ app or watch face read FIT activity files stored on the device?

### Answer: Absolutely not.

Connect IQ applications operate in a strict sandbox. There is no filesystem API, no file I/O, and no way to access `GARMIN/Activity/*.fit` files. This has been confirmed repeatedly:

> "You can't read .fit files with CIQ."

The FIT files on a Descent device contain all dive data (depth profiles, gas mixes, tissue loading, decompression info), but this data is only accessible via:
- USB cable (mount as mass storage)
- Garmin Connect sync (uploaded to cloud)
- Third-party PC tools (Subsurface, MacDive, DiveLog)

File location on device: `Primary/GARMIN/Activity/YYYY-MM-DD-HH-MM-SS.fit`

---

## 6. Complications API (API 4.2+)

### Question: Can the watch face receive data from another app via Complications?

### Answer: Yes -- this is the ONLY viable on-device inter-app communication channel. But the source app still cannot access native dive data.

### How It Works

The Complications API uses a **publish/subscribe model**:

1. **Publisher (device app):** Declares complications in `complications.xml`, publishes data via `Complications.updateComplication()`
2. **Subscriber (watch face):** Registers callback via `Complications.registerComplicationChangeCallback()`, subscribes to specific complication IDs

### Publishing Custom Complications

A device app publishes a complication:

```xml
<!-- complications.xml in the publisher app -->
<complication id="0" access="public"
    longLabel="@Strings.longComplicationLabel"
    shortLabel="@Strings.shortComplicationLabel"
    icon="@Drawables.ComplicationIcon"
    glancePreview="false">
    <faceIt defaultText="@Strings.AppName" />
</complication>
```

```monkeyc
// In the publisher app's background service
var comp = {
    :value => surfaceIntervalMinutes,  // Double, Float, Long, Number, or String
    :shortLabel => "SI",
    :longLabel => "Surface Interval",
    :units => "min"
};
Complications.updateComplication(0, comp);
```

### Subscribing in Watch Face

```monkeyc
// In the watch face
function initialize() {
    Complications.registerComplicationChangeCallback(method(:onComplicationChanged));
}

function onComplicationChanged(complicationId) {
    var complication = Complications.getComplication(complicationId);
    var type = complication.getType();  // COMPLICATION_TYPE_INVALID for custom
    var label = complication.shortLabel;
    var value = complication.value;
}
```

### Discovery Issue

Custom complications from third-party apps appear with `COMPLICATION_TYPE_INVALID` (value 0). To find a specific custom complication, the watch face must iterate through all available complications and match by `shortLabel` or `longLabel`. This is fragile:

> "Nothing prevents two different apps from using the same long/short label."
> -- [Publishing custom Complication via app](https://forums.garmin.com/developer/connect-iq/f/discussion/327551/publishing-custom-complication-via-app-and-subscribe-to-it-in-watchface)

### Complications.Value Types

The `:value` field accepts: `Double`, `Float`, `Long`, `Number`, or `String`.

### Known Issues

- Custom complications that worked in CIQ 4.2.4 have been reported as broken in CIQ 7.x ([forum thread](https://forums.garmin.com/developer/connect-iq/f/discussion/378515/has-something-changed-in-a-recent-ciq-regarding-passing-custom-complications-to-watch-faces/1805117))
- The Complications API has documentation inconsistencies (units, value types, localization issues) ([forum thread](https://forums.garmin.com/developer/connect-iq/f/discussion/328568/the-complications-api-is-kind-of-a-mess-right-now-help))
- No dive-specific complication types exist (no `COMPLICATION_TYPE_SURFACE_INTERVAL`, etc.)

### Theoretical Dive Data Bridge

A two-app system could work:
1. **"Windfall Dive Bridge" device app** with a background service that:
   - Calls an external server every 5-30 minutes
   - Server fetches dive data from Garmin Connect (unofficial API)
   - App publishes surface interval, no-fly time, last dive depth as custom complications
2. **Windfall watch face** subscribes to these custom complications

**Problems:**
- Requires users to install a second app
- Requires a server component
- Unofficial Garmin Connect API is fragile and may break
- 5-minute minimum update interval
- Custom complications have known stability issues
- The Descent G2 may or may not support the Complications API (need to verify API level support)

### Descent G2 API Level

The Descent G2 manifest lists `minApiLevel="3.2.0"`. The Complications API requires API 4.2.0. We need to verify the Descent G2's **maximum** supported API level. If it supports 4.2+, Complications are viable. The Descent Mk3 almost certainly supports it.

---

## 7. Temporal Workaround: Detecting Last Activity

### Question: Can we detect when the last activity ended and calculate surface interval?

### Answer: Partially possible via `UserProfile.getUserActivityHistory()`, but diving sport type is not in the enum.

### ActivityMonitor.getInfo() -- No Last Activity Time

`ActivityMonitor.Info` contains **no fields** for last activity time or last activity type. It only provides current/accumulated daily metrics:

- steps, stepGoal, calories, distance
- floorsClimbed, floorsDescended
- activeMinutesDay, activeMinutesWeek
- respirationRate, stressScore, timeToRecovery
- moveBarLevel, pushes (wheelchair)

**There is no `lastActivityTime`, `lastActivityType`, or `lastActivityEndTime` field.**

### UserProfile.getUserActivityHistory() -- Possible but Unreliable

Available since API 3.3.0. Returns an iterator of `UserActivity` objects with:

| Field | Type | Description |
|---|---|---|
| `type` | `Activity.Sport` or null | Sport type enum |
| `startTime` | `Time.Moment` or null | Activity start time |
| `duration` | `Time.Duration` or null | Activity duration |
| `distance` | `Lang.Number` or null (meters) | Distance covered |

**Critical problem: `SPORT_DIVING` does not exist in the `Activity.Sport` enum.**

The enum jumps from `SPORT_SOFTBALL_SLOW_PITCH` (51) directly to `SPORT_SHOOTING` (56). Values 52-55 are skipped. In the FIT protocol, diving is sport type 53 -- but this value has **no named constant** in the CIQ API.

What this means:
- If a dive activity's `type` field returns the raw integer 53, you could detect it by comparing `activity.type == 53`
- But it might return `null`, `SPORT_GENERIC` (0), or `SPORT_INVALID` (255) instead
- **This requires testing on actual Descent hardware** -- the simulator cannot simulate dive activities

### Sub-Sport Types DO Exist

Interestingly, dive sub-sport constants ARE defined (since API 4.1.6):
- `SUB_SPORT_SINGLE_GAS_DIVING` (53)
- `SUB_SPORT_MULTI_GAS_DIVING` (54)
- `SUB_SPORT_GAUGE_DIVING` (55)
- `SUB_SPORT_APNEA_DIVING` (56)
- `SUB_SPORT_APNEA_HUNTING` (57)
- `SUB_SPORT_CCR_DIVING` (63)

But `UserActivity` does **not expose `subSport`** -- only `type` (Activity.Sport).

### Hypothetical Surface Interval Calculation

If dive activities are detectable:
```monkeyc
var history = UserProfile.getUserActivityHistory();
if (history != null) {
    var activity = history.next();
    while (activity != null) {
        if (activity.type == 53) {  // Raw integer for diving
            var diveEnd = activity.startTime.add(activity.duration);
            var now = Time.now();
            var surfaceInterval = now.subtract(diveEnd);
            // surfaceInterval.value() gives seconds since dive ended
            break;
        }
        activity = history.next();
    }
}
```

### Verdict: Unverified, likely unreliable, requires hardware testing.

---

## 8. Web API Workaround

### Question: Can a background service call the Garmin Connect API to fetch dive log data?

### Answer: Not the official API. The unofficial API could work via a proxy server, but it is fragile.

### Official Garmin Connect Developer Program API

The official Activity API is **only available to approved business developers.** Individual/hobby developers cannot access it. The API does support dive activity types (DIVING, APNEA, CCR_DIVE, etc.), but:
- Requires business application and approval
- Uses OAuth 2.0 -- too complex for a 32 KB background service
- Does not expose post-dive computed data (surface interval, no-fly time, tissue loading)

### Unofficial Garmin Connect API

Libraries like [python-garminconnect](https://github.com/cyberjunky/python-garminconnect) reverse-engineer the Garmin Connect web interface. These can:
- Authenticate with Garmin SSO (OAuth via Garth library)
- Fetch activity lists including dive activities
- Download FIT files
- Get activity detail summaries

However, these libraries do **not** have dive-specific endpoints. Dive data would need to be extracted from:
1. The generic activity detail JSON (may include max_depth, avg_depth for dive activities)
2. Downloaded FIT files (parsed server-side with the FIT SDK)

### Architecture for Web API Workaround

```
Garmin Connect (cloud)
    |
    v  (python-garminconnect / unofficial API)
Custom Server (your infrastructure)
    |  - Authenticates as user
    |  - Fetches latest dive activity
    |  - Parses FIT file for dive summary
    |  - Computes surface interval, no-fly estimate
    |  - Exposes REST API endpoint
    |
    v  (HTTPS GET)
CIQ Background Service (every 5-30 min)
    |  - makeWebRequest to custom server
    |  - Stores result in Application.Storage
    |
    v
Watch Face reads from Storage
```

### Constraints

- **Background service memory:** 32 KB -- must keep response small (JSON with a few fields)
- **Update interval:** Minimum 5 minutes between background runs
- **Server required:** Must maintain a server with user's Garmin credentials
- **Unofficial API breaks regularly** when Garmin changes authentication or endpoints
- **No-fly time cannot be accurately computed** without the proprietary Buhlmann algorithm parameters Garmin uses
- **Surface interval is trivial to compute** if you know the last dive's end time
- **Security concern:** Storing Garmin credentials on a third-party server

### What Data Could Be Fetched

| Data | Feasibility | Source |
|---|---|---|
| Last dive date/time | High | Activity list API |
| Last dive max depth | Medium | Activity detail or FIT file |
| Last dive duration | High | Activity list API |
| Surface interval | High | Computed from last dive end time |
| No-fly time | Low | Would need to replicate Garmin's algorithm |
| Tissue loading | Very Low | Not available via API; requires FIT parsing + Buhlmann model |
| CNS / OTU | Low | May be in FIT file; requires parsing |
| Number of dives today | High | Activity list filtered by date |

### Verdict: Technically possible but requires server infrastructure, is fragile, and cannot provide safety-critical data like no-fly time or tissue loading accurately.

---

## 9. UserActivity / Activity.Info Post-Dive

### Question: After a dive activity completes, is any summary data available via these APIs?

### Answer: Very limited. Only generic activity fields (time, duration, distance). No dive-specific data.

### UserProfile.getUserActivityHistory()

As discussed in Section 7, this API returns:
- `type`: Activity.Sport (diving = 53, but not in enum)
- `startTime`: Time.Moment
- `duration`: Time.Duration
- `distance`: Number (meters) -- likely 0 for most dives

**No depth, temperature, NDL, gas mix, tissue data, or any dive-specific fields.**

### Activity.getActivityInfo()

This returns `Activity.Info` which provides real-time data during an **active** recording session. Fields include:
- `currentSpeed`, `averageSpeed`, `maxSpeed`
- `currentHeartRate`, `averageHeartRate`
- `calories`, `elapsedDistance`
- `ambientPressure` (available during active activity only)

**This API is NOT available on a watch face.** It requires an active activity session, which a watch face cannot create. Even if accessible, it would only work during an activity, not after.

### Activity.Info.ambientPressure -- Depth Hack?

During an active activity (app or data field only), `ambientPressure` could theoretically be used for depth:
```
depth_meters = (pressure_mb - 1013.25) / 100.7
```

But this:
- Does NOT work in watch faces (no active activity)
- Is capped at ~6m/20ft on non-Descent devices
- Is controlled by native firmware on Descent devices during dive mode
- Would violate Garmin's App Approval Exceptions policy

### Verdict: UserActivityHistory provides minimal post-dive metadata. Activity.Info is irrelevant for watch faces.

---

## 10. Existing Apps Showing Dive Data

### Question: Are there any existing apps that show dive data outside of native dive mode?

### Answer: No CIQ app successfully shows native dive data. Some apps provide their own dive functionality.

### Apps on the Connect IQ Store

| App | Type | What It Does | Shows Native Dive Data? |
|---|---|---|---|
| **Dive Timer - Freediving Surface Coach** | App | Countdown timer for freediving surface intervals | **No** -- user-configured timer, not reading device dive data |
| **JMG-APP Apnea Training** | App | Freediving training tables (O2/CO2 tables) | **No** -- training protocol, not device data |
| **Apnea.me** | App | Freediving app with depth detection via barometer | **No** -- uses its own pressure-based depth (limited to ~6m on non-Descent) |
| **Dive-themed watch faces** | Watch Face | Aesthetic designs for divers | **No** -- purely cosmetic, show standard smartwatch data |
| **Tide apps** (JMG-WF Tides, etc.) | Watch Face/App | Tide predictions | **No** -- fetch data from internet APIs, not device |

### Apps on GitHub (Sideloaded)

| App | What It Does | Shows Native Dive Data? |
|---|---|---|
| **IQ Dive Computer** | Real-time decompression using Buhlmann algorithm | **No** -- computes its own data from barometer. Does NOT work on Descent (native dive mode takes over). Capped at 6m on newer non-Descent devices. |
| **Freediver** ([GitHub](https://github.com/BertilBraun/Freediver)) | Freediving logger using barometric pressure | **No** -- its own depth calculation, not native dive data |

### Key Finding

**No existing app or watch face on any platform successfully reads or displays native Garmin dive data (surface interval, no-fly time, tissue loading) via Connect IQ.** This confirms that the limitation is fundamental and not merely a matter of nobody having tried.

---

## 11. Forum and Community Findings

### Garmin Developer Forums

**Thread: "Dive data (surf interval and no fly time) to be available for custom watch faces?"**
URL: https://forums.garmin.com/developer/connect-iq/f/discussion/244569/

- Developer requested basic dive info for CIQ watch faces
- Community response: "Garmin were not looking to release this data"
- jim_m_58 (prolific CIQ developer): "Very doubtful, as that would not only be for the Descent devices"
- **No official Garmin response. Status: No plans.**

**Thread: "Allow shared storage between apps"**
URL: https://forums.garmin.com/developer/connect-iq/i/bug-reports/allow-shared-storage-between-apps

- Feature request for inter-app storage sharing
- **Garmin's response: "Decided not to implement this for various reasons (primarily for security)"**
- Workaround suggested: "Share data from a glance app that produces complications and consume the complications in a watchface"

**Thread: Surface Interval on Mk1 Watch Face**
URL: https://forums.garmin.com/outdoor-recreation/outdoor-recreation-archive/f/descent-mk1/171250/

- Users requested SI data on standard watch faces (not CIQ)
- Garmin eventually added SI to their **native** watch faces and glance widgets
- This data remains unavailable to CIQ apps

**Thread: Custom Complications stability issues**
URL: https://forums.garmin.com/developer/connect-iq/f/discussion/378515/

- Custom complications that worked in CIQ 4.2.4 reportedly broke in CIQ 7.x
- Indicates the Complications API is not fully stable for inter-app use

**App Approval Exceptions Wiki**
URL: https://forums.garmin.com/developer/connect-iq/w/wiki/10/app-approval-exceptions

- Apps for scuba/free diving will NOT be listed on the Connect IQ store
- Sideloading is still permitted
- Garmin's position on dive safety is firm and unchanged

### Reddit / ScubaBoard

No significant community workarounds found. Discussions on ScubaBoard and Garmin forums consistently confirm that native dive data is inaccessible to CIQ. Users requesting this feature are directed to use the native glance widgets.

### SDK Release Notes (2025-2026)

- **CIQ SDK 8.3.0** (latest): New sensor synchronization features. No dive-related additions.
- **No roadmap or announcement** for dive data APIs
- **No incremental steps** toward exposing even "safe" post-dive data

---

## 12. Feasibility Matrix

| Workaround | Feasibility | Complexity | Reliability | Data Quality | Recommendation |
|---|---|---|---|---|---|
| **Complications bridge (app + server)** | Medium | Very High | Low-Medium | Medium | Not recommended for v1 |
| **UserActivityHistory heuristic** | Low-Medium | Low | Unknown | Very Low | Test on hardware; use if verified |
| **Companion phone app** | Medium | Very High | Medium | Medium | Not recommended |
| **Web API via background service** | Medium | High | Low | Medium | Not recommended |
| **FIT file reading on-device** | Impossible | N/A | N/A | N/A | Cannot be done |
| **Direct inter-app storage** | Impossible | N/A | N/A | N/A | Rejected by Garmin |
| **Native dive API** | Non-existent | N/A | N/A | N/A | Does not exist |

---

## 13. Recommended Architecture

### For Windfall v1: Do NOT attempt dive data workarounds

The effort-to-value ratio is extremely poor. All workarounds are either:
- Technically impossible (FIT reading, shared storage, direct dive API)
- Unreliable and unverified (UserActivityHistory sport type 53)
- Massively complex for minimal benefit (companion app, server infrastructure)

Instead, focus on making the watch face the best **surface companion** for divers with reliably available data.

### For Windfall v2 (Future): Two potential experiments

**Experiment 1: UserActivityHistory Dive Detection (Low Effort)**

On actual Descent G2 hardware, test whether:
1. `UserProfile.getUserActivityHistory()` returns dive activities
2. What value the `type` field contains for dives (53? null? SPORT_GENERIC?)
3. Whether `startTime` and `duration` are accurate

If diving activities are detectable, calculate and display:
- "Time since last activity" (not labeled as "surface interval" for safety/liability)
- "Last activity duration"

This requires zero additional infrastructure -- just reading an API that's already available.

**Experiment 2: Complications Bridge (High Effort)**

If there's demand, build a separate "Windfall Dive Data" device app that:
1. Has a background service making periodic web requests
2. Fetches the user's latest dive activity from a custom server
3. Server uses python-garminconnect to read Garmin Connect data
4. App publishes custom complications (last dive time, depth, duration)
5. Windfall watch face subscribes to these complications

This would require:
- A server component (could be a small Lambda function)
- User authentication with Garmin Connect credentials
- A second CIQ app for users to install
- Extensive testing of the Complications API stability

### Important Safety Note

**Never label any computed value as "surface interval," "no-fly time," or "tissue loading."** These are safety-critical values that divers rely on for flight decisions and repetitive dive planning. Displaying inaccurate values could endanger lives. If any dive timing data is displayed, it should be clearly labeled as informational only, e.g., "Time since last activity."

---

## 14. Sources

### Garmin Developer Forums

- [Dive data (surf interval and no fly time) for custom watch faces?](https://forums.garmin.com/developer/connect-iq/f/discussion/244569/dive-data-surf-interval-and-no-fly-time-to-be-available-for-custom-watch-faces)
- [Can a Watchface and a Widget share parameters?](https://forums.garmin.com/developer/connect-iq/f/discussion/194213/can-a-watchface-and-a-widget-share-parameters)
- [Allow shared storage between apps](https://forums.garmin.com/developer/connect-iq/i/bug-reports/allow-shared-storage-between-apps)
- [Publishing custom Complication via app and subscribe to it in Watchface](https://forums.garmin.com/developer/connect-iq/f/discussion/327551/publishing-custom-complication-via-app-and-subscribe-to-it-in-watchface)
- [The Complications API is kind of a mess right now](https://forums.garmin.com/developer/connect-iq/f/discussion/328568/the-complications-api-is-kind-of-a-mess-right-now-help)
- [Has something changed in CIQ regarding custom complications?](https://forums.garmin.com/developer/connect-iq/f/discussion/378515/has-something-changed-in-a-recent-ciq-regarding-passing-custom-complications-to-watch-faces/1805117)
- [How does a Garmin device read .FIT files?](https://forums.garmin.com/developer/connect-iq/f/discussion/7578/how-does-a-garmin-device-read-fit-files)
- [Read value from latest FIT activity file](https://forums.garmin.com/developer/connect-iq/f/app-ideas/7012/read-value-from-latest-fit-activity-file-stored-on-watch-and-display-as-widget)
- [VERY Simple sample of a watch face with a background process](https://forums.garmin.com/developer/connect-iq/f/discussion/5287/very-simple-sample-of-a-watch-face-with-a-background-process)
- [UserProfile activity history available for watch faces since System5?](https://forums.garmin.com/developer/connect-iq/f/discussion/310328/is-the-running-distance-time-history-available-via-api-toybox-userprofile-useractivity-or-otherwise-for-the-watch-faces-since-system5)
- [How to hand over data to a background service](https://forums.garmin.com/developer/connect-iq/f/discussion/358782/how-to-hand-over-data-to-a-background-service)
- [Support for sports and sub-sports](https://forums.garmin.com/developer/connect-iq/f/discussion/406402/support-for-sports-and-sub-sports)
- [Surface interval on Mk1 watch face](https://forums.garmin.com/outdoor-recreation/outdoor-recreation-archive/f/descent-mk1/171250/)
- [App Approval Exceptions Wiki](https://forums.garmin.com/developer/connect-iq/w/wiki/10/app-approval-exceptions)
- [Background module - companion app communication in background](https://forums.garmin.com/developer/connect-iq/f/discussion/6168/background-module---is-companion-app-communication-supported-in-the-background)
- [How to use Communications module with Watchface](https://forums.garmin.com/developer/connect-iq/f/discussion/209661/how-can-i-use-communications-module-to-work-with-webservices-in-garmin-watchface-app)
- [Complication Suggestions for Garmin](https://forums.garmin.com/developer/connect-iq/f/discussion/311604/complication-suggestions-for-garmin)

### Connect IQ SDK / API Documentation

- [Toybox.Activity (Sport/SubSport enums)](https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html)
- [Toybox.ActivityMonitor.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html)
- [Toybox.Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- [Toybox.Complications.Complication](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications/Complication.html)
- [Toybox.Communications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html)
- [Toybox.UserProfile.UserActivity](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile/UserActivity.html)
- [Toybox.UserProfile.UserActivityHistoryIterator](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile/UserActivityHistoryIterator.html)
- [Complications Core Topic](https://developer.garmin.com/connect-iq/core-topics/complications/)
- [Background Services Core Topic](https://developer.garmin.com/connect-iq/core-topics/backgrounding/)
- [Communicating with Mobile Apps](https://developer.garmin.com/connect-iq/core-topics/communicating-with-mobile-apps/)
- [Background Service FAQ](https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-create-a-connect-iq-background-service/)
- [REST Services FAQ](https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-use-rest-services/)
- [Connect IQ Mobile SDK FAQ](https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-use-the-connect-iq-mobile-sdk/)
- [App Types](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)

### Garmin Connect Developer Program

- [Activity API](https://developer.garmin.com/gc-developer-program/activity-api/)
- [Health API](https://developer.garmin.com/gc-developer-program/health-api/)

### GitHub Repositories

- [Connect IQ Android SDK](https://github.com/garmin/connectiq-android-sdk)
- [Connect IQ iOS Companion SDK](https://github.com/garmin/connectiq-companion-app-sdk-ios)
- [Connect IQ iOS Example App](https://github.com/garmin/connectiq-companion-app-example-ios)
- [python-garminconnect (unofficial API)](https://github.com/cyberjunky/python-garminconnect)
- [Freediver (barometric depth app)](https://github.com/BertilBraun/Freediver)
- [fit2subs (FIT to Subsurface)](https://github.com/xplwowi/fit2subs)
- [awesome-garmin (resource list)](https://github.com/bombsimon/awesome-garmin)

### Connect IQ Store Apps

- [Dive Timer - Freediving Surface Coach](https://apps.garmin.com/apps/c53ad8b5-0fa9-4e19-bf8c-853b37a1bf5a)
- [JMG-APP Apnea Training](https://apps.garmin.com/en-US/apps/f3ad8a61-f4bf-422c-8113-30d2eb774bec)

### Other

- [Garmin Descent G1 FIT file location discussion](https://forums.garmin.com/outdoor-recreation/outdoor-recreation/f/descent-g1/344557/)
- [Garmin Unofficial API Documentation](https://wiki.brianturchyn.net/programming/apis/garmin/)
- [Garmin Activity API Integration Guide (Scribd)](https://www.scribd.com/document/794184899/Garmin-Developer-Program-Activity-API)
