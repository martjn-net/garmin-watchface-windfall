# Dive Data Accessibility for Connect IQ Watch Faces

> Research document for the Windfall watch face project.
> Target devices: Descent G2, Descent Mk3 / Mk3i
> Date: 2026-03-28

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Can a Connect IQ Watch Face Access Dive Data?](#2-can-a-connect-iq-watch-face-access-dive-data)
3. [What Happens to Connect IQ During a Dive?](#3-what-happens-to-connect-iq-during-a-dive)
4. [Can a Watch Face Show Post-Dive Data?](#4-can-a-watch-face-show-post-dive-data)
5. [What Dive-Related Data IS Available via the Connect IQ API?](#5-what-dive-related-data-is-available-via-the-connect-iq-api)
6. [Garmin Developer Forum Findings](#6-garmin-developer-forum-findings)
7. [Existing Dive-Related Connect IQ Apps](#7-existing-dive-related-connect-iq-apps)
8. [Dive API Status and Future Outlook](#8-dive-api-status-and-future-outlook)
9. [Non-Dive Water Data Useful for Divers](#9-non-dive-water-data-useful-for-divers)
10. [FIT SDK Dive Fields (Post-Processing Only)](#10-fit-sdk-dive-fields-post-processing-only)
11. [Recommendations for Windfall Watch Face](#11-recommendations-for-windfall-watch-face)
12. [Sources](#12-sources)

---

## 1. Executive Summary

**The core finding is unambiguous: Garmin does NOT expose dive-specific data (depth, NDL, tissue loading, surface interval, no-fly time, gas mix, decompression stops) to the Connect IQ API. This is a deliberate safety and liability decision, not a technical oversight.**

A Connect IQ watch face on the Descent G2/Mk3 can display the same general smartwatch data as on any Garmin watch (steps, HR, weather, battery, etc.) but cannot access any dive computer data. During an active dive, Connect IQ is completely disabled. After a dive, post-dive data (surface interval, no-fly time, tissue saturation) is visible only through Garmin's native firmware widgets and watch face -- not through Connect IQ.

However, several **dive-adjacent** data points ARE accessible and can make a watch face genuinely useful for divers at the surface.

---

## 2. Can a Connect IQ Watch Face Access Dive Data?

### In-Dive Data -- ALL INACCESSIBLE

| Data Point | Available to CIQ Watch Face? | Notes |
|---|---|---|
| Current depth | **NO** | Native dive mode only |
| Water temperature | **NO** | Native dive mode only |
| No-decompression limit (NDL) | **NO** | Native dive mode only |
| Dive time | **NO** | Native dive mode only |
| Surface interval | **NO** | Native widget/glance only, not exposed to CIQ |
| Gas mix / PO2 | **NO** | Native dive mode only |
| Ascent/descent rate | **NO** | Native dive mode only |
| Decompression stops | **NO** | Native dive mode only |
| Tissue loading / saturation | **NO** | Native widget/glance only, not exposed to CIQ |
| No-fly time | **NO** | Native widget/watch face only, not exposed to CIQ |

### Why Not?

Garmin's position is explicit and documented in their [App Approval Exceptions](https://forums.garmin.com/developer/connect-iq/w/wiki/10/app-approval-exceptions) policy:

> "The diving features available on Descent products are the only Garmin features intended for underwater diving use."

This is a **safety and liability** decision. Dive computers are life-critical equipment, and Garmin does not allow third-party code to:
- Interfere with dive calculations
- Display dive-critical data that might be incorrect
- Run during active dives

### No Dive-Specific Toybox Module

There is no `Toybox.Dive`, `Toybox.DiveComputer`, or similar module in the Connect IQ SDK. The entire dive computer subsystem is firmware-level and completely walled off from Connect IQ.

---

## 3. What Happens to Connect IQ During a Dive?

### Complete CIQ Shutdown During Dive Mode

When a dive is initiated on the Descent G2 or Mk3:

1. **Connect IQ watch faces are replaced** by the native dive display
2. **All CIQ apps, widgets, and data fields are suspended**
3. **Hold functions are disabled** for safety
4. **The native dive firmware takes full control** of the display, sensors, and computation

This is explicitly stated across all Descent owner's manuals:

> "For your safety, Connect IQ features are not available while diving. This ensures that all dive capabilities function as designed."

Source: [Descent Mk2/Mk2s Owner's Manual - Connect IQ Features](https://www8.garmin.com/manuals/webhelp/GUID-120241CE-9583-49CD-A0BC-8839B887F7CA/EN-US/GUID-C3289B5E-1A70-4BB2-A7F0-9B16CF60D75D.html)

### After Surfacing

When the dive ends, the watch returns to normal smartwatch mode and the CIQ watch face resumes. However, the CIQ watch face receives **no callback or notification** that a dive just occurred, and **no dive summary data is passed** to it.

---

## 4. Can a Watch Face Show Post-Dive Data?

### Native Firmware: YES (but limited to Garmin's own UI)

The **native** Garmin watch face and **native** glances/widgets on the Descent G2 and Mk3 can display:

| Post-Dive Data | Where Displayed | CIQ Access? |
|---|---|---|
| No-fly time remaining | Native watch face (icon + hours) | **NO** |
| No-fly end time | Surface interval glance (press DOWN) | **NO** |
| Surface interval time | Native watch face + glance | **NO** |
| CNS oxygen toxicity % | Surface interval glance (press START) | **NO** |
| OTU (Oxygen Toxicity Units) | Surface interval glance | **NO** |
| Tissue loading details | Surface interval glance (press DOWN) | **NO** |
| N2/He loading | Surface interval glance (Mk3) | **NO** |
| Last dive summary | Dive log (separate app) | **NO** |
| Number of dives today | Dive log | **NO** |
| Tissue desaturation time | Surface interval glance | **NO** |

Source: [Descent G2 - Viewing the Surface Interval Glance](https://www8.garmin.com/manuals/webhelp/GUID-EA4C028F-6CC0-4957-9BB2-20B2E5DAE9CD/EN-US/GUID-5B6754B2-AC50-4686-AD61-8BCC57AE2D55.html)

### Connect IQ Watch Face: NO

**None** of this post-dive data is exposed through any Connect IQ API. This has been explicitly confirmed:

- In the [Garmin developer forum](https://forums.garmin.com/developer/connect-iq/f/discussion/244569/dive-data-surf-interval-and-no-fly-time-to-be-available-for-custom-watch-faces), a developer asked: "Would it be possible for Garmin to release basic dive info like surface interval time and no-fly time for custom watch faces?"
- The response from the community: "Garmin were not looking to release this data."
- No Garmin official response was given, confirming the lack of plans.

### The UserActivityHistory Workaround (Limited)

The `UserProfile.getUserActivityHistory()` API (since API 3.3.0) returns an iterator of `UserActivity` objects with:
- `type` (Activity.Sport enum)
- `startTime` (Time.Moment)
- `duration` (Time.Duration)
- `distance` (Number, meters)

**Diving is Sport type 53** in the FIT protocol, with sub-sports for single-gas (53), multi-gas (54), gauge (55), apnea (56), apnea hunt (57), and CCR (58).

However, the `UserActivity` class does **not** expose `subSport`, and the Connect IQ `Activity.Sport` enum does **not include a `SPORT_DIVING` constant** (the enum goes up to 77 but skips several values; diving at 53 may not be mapped). Even if it were mapped, the only data available would be start time, duration, and distance -- **no depth, temperature, NDL, or tissue data**.

**Verdict:** You might be able to detect that a dive activity occurred and know its start time and duration, but this is unreliable and unverified. It would require testing on actual hardware.

---

## 5. What Dive-Related Data IS Available via the Connect IQ API?

### Confirmed Available Data for Watch Faces

| Data Point | API | Permission | Relevance for Divers |
|---|---|---|---|
| **Barometric pressure** | `SensorHistory.getPressureHistory()` | SensorHistory | Weather trends for dive planning; altitude diving |
| **Altitude/Elevation** | `SensorHistory.getElevationHistory()` | SensorHistory | Critical for altitude diving corrections |
| **Temperature (sensor)** | `SensorHistory.getTemperatureHistory()` | SensorHistory | Ambient/wrist temp at surface |
| **Weather temperature** | `Weather.getCurrentConditions().temperature` | Weather | Air temp for exposure suit planning |
| **Weather pressure** | `Weather.getCurrentConditions().pressure` | Weather | Sea-level pressure (API 5.1.0) |
| **Sunrise/Sunset** | `Weather.getSunrise/getSunset()` | Weather | Dive planning (visibility, boat schedules) |
| **UV Index** | `Weather.getCurrentConditions().uvIndex` | Weather | Sun protection on boat days (API 5.1.0) |
| **Wind speed/direction** | `Weather.getCurrentConditions().windSpeed/windBearing` | Weather | Surface conditions, boat dive planning |
| **Visibility** | `Weather.getCurrentConditions().visibility` | Weather | Atmospheric visibility (API 5.1.0) |
| **Cloud cover** | `Weather.getCurrentConditions().cloudCover` | Weather | Light conditions (API 5.1.0) |
| **Dew point** | `Weather.getCurrentConditions().dewPoint` | Weather | Fog risk (API 5.1.0) |
| **Humidity** | `Weather.getCurrentConditions().relativeHumidity` | Weather | Comfort on surface |
| **Precipitation chance** | `Weather.getCurrentConditions().precipitationChance` | Weather | Dive day weather |
| **Daily forecast** | `Weather.getDailyForecast()` | Weather | Multi-day dive trip planning |
| **Hourly forecast** | `Weather.getHourlyForecast()` | Weather | Timing dives around weather |
| **Heart rate** | `SensorHistory.getHeartRateHistory()` | SensorHistory | Pre/post-dive HR |
| **SpO2** | `SensorHistory.getOxygenSaturationHistory()` | SensorHistory | Surface-level pulse oximetry |
| **Body battery** | `SensorHistory.getBodyBatteryHistory()` | SensorHistory | Physical readiness before dive |
| **Stress** | `SensorHistory.getStressHistory()` | SensorHistory | Pre-dive anxiety/stress |
| **Recovery time** | `ActivityMonitor.getInfo().timeToRecovery` | None | Hours to recovery from last activity |
| **Respiration rate** | `ActivityMonitor.getInfo().respirationRate` | None | Breathing rate at surface |

### Complications API (API 4.2.0+)

The Complications API provides system-level data including:

| Complication | Type ID | Diver Use |
|---|---|---|
| `COMPLICATION_TYPE_ALTITUDE` | 15 | Altitude diving |
| `COMPLICATION_TYPE_SEA_LEVEL_PRESSURE` | 16 | Barometric trends |
| `COMPLICATION_TYPE_SUNRISE` | 13 | Dive planning |
| `COMPLICATION_TYPE_SUNSET` | 14 | Dive planning |
| `COMPLICATION_TYPE_CURRENT_TEMPERATURE` | 38 | Surface conditions |
| `COMPLICATION_TYPE_CURRENT_WEATHER` | 8 | Weather overview |
| `COMPLICATION_TYPE_BODY_BATTERY` | 23 | Readiness |
| `COMPLICATION_TYPE_RECOVERY_TIME` | 21 | Recovery status |
| `COMPLICATION_TYPE_STRESS` | 22 | Pre-dive mental state |

**No dive-specific complication types exist** (no surface interval, no-fly, tissue loading, etc.).

---

## 6. Garmin Developer Forum Findings

### Thread: "Dive data (surf interval and no fly time) to be available for custom watch faces?"

**URL:** https://forums.garmin.com/developer/connect-iq/f/discussion/244569/dive-data-surf-interval-and-no-fly-time-to-be-available-for-custom-watch-faces

- Developer "Ben" requested that Garmin expose surface interval and no-fly time to CIQ watch faces
- Response from jim_m_58 (prolific CIQ developer): "Very doubtful, as that would not only be for the Descent devices, and there's already many things the firmware doesn't expose in CIQ"
- **No official Garmin response** in the thread
- **Status: No plans to implement**

### Thread: "Freediving Depth Data Field"

**URL:** https://forums.garmin.com/developer/connect-iq/f/discussion/4028/freediving-depth-data-field

- Developer wanted to build a freediving depth data field
- Key finding: "There seems to be no way to get the pressure reading from the barometer into a data field" because the Sensor module is restricted to apps only, not data fields or watch faces
- Even if accessible, `Info.pressure` returns altitude-corrected values, not raw pressure needed for depth calculation
- **No viable workaround for watch faces**

### Thread: "Water depth with Instinct 2"

**URL:** https://forums.garmin.com/developer/connect-iq/f/discussion/290491/water-depth-with-instinct-2

- Developers discussed using `Activity.getActivityInfo().ambientPressure` for depth calculation
- Formula: `depth = -((pressure_mb - 1013.25) / 100.7)` where pressure is in millibars
- **This only works in apps/data fields during an active activity, NOT in watch faces**
- On non-Descent watches, depth is capped at ~6m / 20ft by firmware
- On Descent watches, the depth sensor goes much deeper but is controlled by native firmware

### Thread: Surface Interval on Mk1 Watch Face

**URL:** https://forums.garmin.com/outdoor-recreation/outdoor-recreation-archive/f/descent-mk1/171250/

- Users requesting SI data on the Garmin default watch faces (not CIQ)
- Garmin eventually added SI display to their native watch faces and as a glance/widget
- This data remains unavailable to CIQ

### App Approval Exceptions Wiki

**URL:** https://forums.garmin.com/developer/connect-iq/w/wiki/10/app-approval-exceptions

Key policies:
- Apps for scuba diving, free diving, skydiving, and base-jumping **will NOT be listed on the Connect IQ store**
- The altimeter/barometer is "intended for general altitude reference only, and is not intended for extreme sports"
- Developers **may still build and distribute** dive apps outside the official store (sideloading)
- Garmin will not host these apps on any Garmin-affiliated resource

---

## 7. Existing Dive-Related Connect IQ Apps

### IQ Dive Computer (Third-Party, NOT on Store)

**Forum:** https://forums.garmin.com/developer/connect-iq/f/showcase/3840/iq-dive-computer

- Provides real-time decompression information using Buhlmann ZH-L16 algorithm
- Computes NDL, depth, dive time, and deco ceiling in real-time
- Uses barometric pressure sensor for depth calculation
- **NOT allowed in the Garmin Connect IQ store** per App Approval Exceptions
- Must be sideloaded
- Only works on older watches (pre-Fenix 6) because newer devices cap depth readings at ~6m / 20ft
- **Does NOT work on Descent watches** (native dive mode takes over)

### Tide Apps (Available on Store)

Several tide apps are available on the Connect IQ store and work on Descent devices:
- **JMG-WF Tides** (watch face with tide data)
- **AK Tides** (Alaska-focused)
- **Tides** (general)
- These use internet data via background services, not device sensors

### Dive-Themed Watch Faces

Several watch faces on the Connect IQ store are marketed for dive watches but display **zero dive-specific data**. They are purely cosmetic/thematic designs showing standard smartwatch data (time, steps, HR, battery) with a diving aesthetic.

---

## 8. Dive API Status and Future Outlook

### Current Status (March 2026)

- **No Dive API exists** in Connect IQ
- **No announcement of plans** for a Dive API
- The latest SDK (8.2.1) added sensor synchronization features but **nothing dive-related**
- The Complications API has been expanded but includes no dive complications
- Minimum SDK version requirement is being raised (8.1+ for store uploads as of July 2025), but this is a general platform change, not dive-related

### Likelihood of a Future Dive API

**Very unlikely in the near term.** Reasons:

1. **Liability:** Dive computers are safety-critical. Exposing dive data to third-party code creates liability risk.
2. **Certification:** Dive computers may need to meet standards (EN 13319). Third-party data display could compromise this.
3. **Competitive advantage:** The native dive experience is a key differentiator for Descent devices.
4. **Historical pattern:** Despite years of community requests (since Descent Mk1 in 2017), Garmin has not moved on this.
5. **No incremental steps:** Even "safe" post-dive data (surface interval, no-fly time) has not been exposed.

### What MIGHT Eventually Happen

- **Read-only post-dive complications** (surface interval, no-fly time) are the most plausible future addition, since they don't affect safety during a dive
- If the Complications API is expanded to include dive data, it would likely be read-only and post-dive only
- There is zero indication this is being planned

---

## 9. Non-Dive Water Data Useful for Divers

### Available Now via Connect IQ

| Data | How to Access | Diver Use |
|---|---|---|
| **Barometric pressure (raw)** | `SensorHistory.getPressureHistory()` | Weather trends; pressure dropping = storm risk = bad dive day |
| **Sea-level pressure** | `COMPLICATION_TYPE_SEA_LEVEL_PRESSURE` | Barometric trend analysis |
| **Altitude** | `SensorHistory.getElevationHistory()` | Altitude diving corrections (critical for decompression) |
| **Surface temperature** | `SensorHistory.getTemperatureHistory()` | Exposure suit choice (note: sensor reads wrist temp, not water) |
| **Sunrise** | `Weather.getSunrise()` | Earliest dive time, visibility planning |
| **Sunset** | `Weather.getSunset()` | Latest dive time, night dive planning |
| **UV Index** | `Weather.getCurrentConditions().uvIndex` | Sunburn risk on boat days |
| **Wind** | `Weather.getCurrentConditions().windSpeed/windBearing` | Surface conditions, wave height estimation |
| **Visibility (atmospheric)** | `Weather.getCurrentConditions().visibility` | General conditions indicator |
| **Hourly forecast** | `Weather.getHourlyForecast()` | Planning dive windows around weather |

### Moon Phase (Must Be Calculated)

Garmin does NOT provide moon phase data via any API. However, many watch face developers calculate it algorithmically:

- Use the current date (`Time.Gregorian.info()`) to calculate moon phase
- Standard astronomical algorithms exist and can be implemented in Monkey C
- Moon phase is useful for divers because:
  - Full/new moon = stronger tides (spring tides)
  - Affects marine life behavior (manta rays, coral spawning)
  - Night dive planning (moonlight underwater visibility)

### Tides (Must Be Fetched Externally)

- No native tide API in Connect IQ
- Can be implemented via Background service + Communications permission
- Fetch tide data from an external API (NOAA, WorldTides, etc.)
- Store locally for display on watch face
- Several existing CIQ apps do this successfully
- **Descent G2 has a built-in tides feature**, but this data is NOT exposed to CIQ

### Location Data (Indirect)

Watch faces cannot use GPS directly, but location is needed for sunrise/sunset/tides:

1. `Weather.getCurrentConditions().observationLocationPosition` -- best option, updates with weather
2. `Activity.getActivityInfo().currentLocation` -- last GPS fix, goes stale
3. Store last known location to `Application.Storage` for persistence

---

## 10. FIT SDK Dive Fields (Post-Processing Only)

While NOT accessible from a Connect IQ watch face, the FIT SDK (used for parsing dive logs on a computer/phone) contains extensive dive data. This is documented here for completeness and to show what data Garmin tracks internally but does not expose to CIQ.

### FIT Session Message -- Dive Fields

| Field | Description |
|---|---|
| `avg_depth` | Average depth |
| `max_depth` | Maximum depth |
| `surface_interval` | Surface interval before dive |
| `start_cns` | CNS % at start |
| `end_cns` | CNS % at end |
| `start_n2` | N2 loading at start |
| `end_n2` | N2 loading at end |
| `min_temperature` | Minimum water temperature |
| `o2_toxicity` | Oxygen toxicity (OTU) |
| `dive_number` | Dive number |

### FIT Record Message -- Dive Fields

| Field | Description |
|---|---|
| `air_time_remaining` | Remaining air time |
| `pressure_sac` | Pressure-based SAC rate |
| `volume_sac` | Volume-based SAC rate |
| `rmv` | Respiratory minute volume |
| `ascent_rate` | Current ascent rate |
| `po2` | Partial pressure of O2 |

### FIT Dive Summary Message

| Field | Description |
|---|---|
| `avg_pressure_sac` | Average pressure SAC |
| `avg_volume_sac` | Average volume SAC |
| `avg_rmv` | Average RMV |
| `descent_time` | Time spent descending |
| `ascent_time` | Time spent ascending |

### FIT Dive Gas Message

| Field | Description |
|---|---|
| `mode` | Gas mode |

### FIT Tank Messages

- `tank_update`: timestamp, sensor, pressure
- `tank_summary`: timestamp, sensor, start_pressure, end_pressure, volume_used

### Activity.Sport and SubSport for Diving

| Enum | Value | Description |
|---|---|---|
| Sport (Diving) | 53 | Parent sport type |
| SUB_SPORT_SINGLE_GAS_DIVING | 53 | Single gas scuba |
| SUB_SPORT_MULTI_GAS_DIVING | 54 | Multi gas scuba |
| SUB_SPORT_GAUGE_DIVING | 55 | Gauge mode |
| SUB_SPORT_APNEA_DIVING | 56 | Apnea/freediving |
| SUB_SPORT_APNEA_HUNTING | 57 | Apnea hunting |
| SUB_SPORT_CCR_DIVING | 58 | Closed-circuit rebreather |

**Note:** These SubSport values exist in the FIT SDK and Connect IQ `Activity` module, but `UserProfile.UserActivity` does not expose `subSport`, only `type` (Activity.Sport). Diving as Sport 53 may or may not be mapped in the Connect IQ enum -- this requires hardware testing.

Source: [FIT SDK Release Notes - SDK 21.105.00](https://forums.garmin.com/developer/fit-sdk/b/news-announcements/posts/fit-sdk-21-105-00-release)

---

## 11. Recommendations for Windfall Watch Face

Given the findings above, the Windfall watch face should focus on being **the best surface companion for divers**, since underwater data is off-limits.

### Tier 1: High-Value Diver Features (Implementable Now)

| Feature | Implementation | Why Divers Want It |
|---|---|---|
| **Sunrise / Sunset** | `Weather.getSunrise/getSunset()` | Dive window planning |
| **Moon phase** | Algorithmic calculation from date | Tides, marine life, night dives |
| **Barometric pressure + trend** | `SensorHistory.getPressureHistory()` | Weather trend for dive day decisions |
| **Altitude** | `SensorHistory.getElevationHistory()` | Altitude diving corrections |
| **Wind speed/direction** | `Weather.getCurrentConditions()` | Surface conditions |
| **UV Index** | `Weather.getCurrentConditions().uvIndex` | Sun protection |
| **Weather forecast** | `Weather.getHourlyForecast()` | Timing dives |

### Tier 2: Health / Readiness (Good for Pre-Dive Assessment)

| Feature | Implementation | Why Divers Want It |
|---|---|---|
| **Body Battery** | `SensorHistory.getBodyBatteryHistory()` | Physical readiness |
| **Stress level** | `SensorHistory.getStressHistory()` | Mental readiness |
| **SpO2** | `SensorHistory.getOxygenSaturationHistory()` | Baseline oxygen saturation |
| **Recovery time** | `ActivityMonitor.getInfo().timeToRecovery` | Recovery from previous activity |
| **Resting HR** | `UserProfile.getProfile().averageRestingHeartRate` | Baseline fitness |

### Tier 3: Aspirational / Future (Requires Background Service)

| Feature | Implementation | Notes |
|---|---|---|
| **Tide data** | Background service + external API | Requires Communications permission |
| **Custom surface interval** | Manual timer or UserActivityHistory heuristic | Unreliable without native data |

### What NOT to Attempt

- **Do NOT try to display depth, NDL, or decompression data** -- impossible and unsafe
- **Do NOT try to replace native dive mode** -- CIQ is shut down during dives
- **Do NOT market as showing surface interval or no-fly time** -- this data is not available
- **Do NOT use barometric pressure for depth calculation** -- not accurate, not allowed in store

---

## 12. Sources

### Official Garmin Documentation

- [Descent G2 Owner's Manual (PDF)](https://www8.garmin.com/manuals/webhelp/GUID-EA4C028F-6CC0-4957-9BB2-20B2E5DAE9CD/EN-US/Descent_G2_Series_OM_EN-US.pdf)
- [Descent G2 - Watch Face Settings](https://www8.garmin.com/manuals/webhelp/GUID-EA4C028F-6CC0-4957-9BB2-20B2E5DAE9CD/EN-US/GUID-A4EA51C3-D0B2-48E3-807A-768C6F07D7BA.html)
- [Descent G2 - Surface Interval Glance](https://www8.garmin.com/manuals/webhelp/GUID-EA4C028F-6CC0-4957-9BB2-20B2E5DAE9CD/EN-US/GUID-5B6754B2-AC50-4686-AD61-8BCC57AE2D55.html)
- [Descent G2 - No-Fly Time](https://www8.garmin.com/manuals-apac/webhelp/descentg2/EN-SG/GUID-137D35A0-FB9B-48E9-9F26-2D577B694662-3361.html)
- [Descent Mk3 - Watch Face Settings](https://www8.garmin.com/manuals/webhelp/GUID-9183E86B-2399-4CFC-AB50-EAFC6D6ED326/EN-US/GUID-A4EA51C3-D0B2-48E3-807A-768C6F07D7BA.html)
- [Descent Mk3 - No-Fly Time](https://www8.garmin.com/manuals/webhelp/GUID-9183E86B-2399-4CFC-AB50-EAFC6D6ED326/EN-US/GUID-96AE8D7C-9677-47EF-89CF-CEB040B8F497.html)
- [Descent Mk2/Mk2s - Connect IQ Features](https://www8.garmin.com/manuals/webhelp/GUID-120241CE-9583-49CD-A0BC-8839B887F7CA/EN-US/GUID-C3289B5E-1A70-4BB2-A7F0-9B16CF60D75D.html)
- [Garmin No-Fly Time Technology](https://www.garmin.com/en-US/garmin-technology/dive-science/in-dive-features/no-fly-time/)
- [Garmin Surface Interval Technology](https://www.garmin.com/en-US/garmin-technology/dive-science/in-dive-features/surface-interval/)

### Connect IQ SDK / API Documentation

- [Connect IQ SDK Overview](https://developer.garmin.com/connect-iq/overview/)
- [Toybox.Activity (Sport/SubSport enums)](https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html)
- [Toybox.ActivityMonitor.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html)
- [Toybox.Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- [Toybox.Complications.Id](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications/Id.html)
- [Toybox.Sensor.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/Sensor/Info.html)
- [Toybox.UserProfile](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile.html)
- [Toybox.UserProfile.UserActivity](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile/UserActivity.html)
- [Toybox.UserProfile.UserActivityHistoryIterator](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile/UserActivityHistoryIterator.html)
- [Toybox.WatchUi.DataField](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/DataField.html)
- [Connect IQ Complications Core Topic](https://developer.garmin.com/connect-iq/core-topics/complications/)

### Garmin Developer Forums

- [Dive data (surf interval and no fly time) for custom watch faces?](https://forums.garmin.com/developer/connect-iq/f/discussion/244569/dive-data-surf-interval-and-no-fly-time-to-be-available-for-custom-watch-faces)
- [Freediving Depth Data Field](https://forums.garmin.com/developer/connect-iq/f/discussion/4028/freediving-depth-data-field/1391311)
- [Water depth with Instinct 2](https://forums.garmin.com/developer/connect-iq/f/discussion/290491/water-depth-with-instinct-2/1404491)
- [IQ Dive Computer (showcase)](https://forums.garmin.com/developer/connect-iq/f/showcase/3840/iq-dive-computer)
- [App Approval Exceptions Wiki](https://forums.garmin.com/developer/connect-iq/w/wiki/10/app-approval-exceptions)
- [Dive mode - screens & watch face (Mk2)](https://forums.garmin.com/outdoor-recreation/outdoor-recreation/f/descent-mk2-mk2i/275267/dive-mode---screens-need-watch-face)
- [Surface interval on Mk1 watch face](https://forums.garmin.com/outdoor-recreation/outdoor-recreation-archive/f/descent-mk1/171250/)
- [How to read pressure info](https://forums.garmin.com/developer/connect-iq/f/discussion/245448/how-to-simply-read-pressure-info)
- [Barometric vs GPS altitude](https://forums.garmin.com/developer/connect-iq/f/discussion/6792/barometric-altitude-or-gps-altitude-how-to-determine)
- [Sunrise/sunset from IQ watchface](https://forums.garmin.com/developer/connect-iq/f/discussion/1515/access-sunset-sunrise-times-from-iq-watchface)

### FIT SDK

- [FIT SDK Overview](https://developer.garmin.com/fit/overview/)
- [FIT SDK - Activity File Type](https://developer.garmin.com/fit/file-types/activity/)
- [FIT SDK Release Notes (dive fields in 21.105.00)](https://forums.garmin.com/developer/fit-sdk/b/news-announcements/posts/fit-sdk-21-105-00-release)
- [Dive FIT File for Conditions (forum)](https://forums.garmin.com/developer/fit-sdk/f/discussion/353344/dive-fit-file-for-conditions)

### Community / Third-Party

- [Garmin Descent G2 Announcement](https://www.garmin.com/en-US/newsroom/press-release/outdoor/garmin-announces-the-descent-g2-watch-style-dive-computer/)
- [DC Rainmaker - Descent Mk1 Hands-On](https://www.dcrainmaker.com/2017/10/garmins-descent-diving.html)
- [DiveNet - Garmin Descent G2](https://divernet.com/scuba-gear/computers/garmin-unveils-watch-style-descent-g2/)
- [GitHub - GarminDiveFitAppender](https://github.com/sumoDave/GarminDiveFitAppender)
- [GitHub - fit2subs (FIT to Subsurface)](https://github.com/xplwowi/fit2subs)
