# Garmin Connect IQ Device Compatibility Research

**Date:** 2026-03-28
**Purpose:** Verified device compatibility data for the Windfall watch face project
**Current project target:** Descent G2, minApiLevel 5.1.0

---

## 1. Connect IQ System Level to API Level Mapping

| System Level | CIQ 3 Devices API | CIQ 4+ Devices API | Notes |
|---|---|---|---|
| System 4 | 3.2.x | 4.0.x | Introduced CIQ 4 track |
| System 5 | 3.3.x | 4.1.x | |
| System 6 | 3.4.x | 4.2.x | Last version for CIQ 3 devices |
| System 7 | -- (dropped) | 5.0.x | CIQ 3 devices left behind; all CIQ 4 devices got 5.0 |
| System 8 | -- | 5.1.x | Fenix 8 launch system; on-device watch face editor |
| System 8+ | -- | 5.2.x | Newer devices (Fenix 8 Pro, FR 570, Vivoactive 6 etc.) |

**Source:** [Garmin Forums - Difference between CIQ and API version](https://forums.garmin.com/developer/connect-iq/f/discussion/420567/difference-between-ciq-and-api-version), [System 7 Announcement](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/welcome-to-system-7), [System 8 Beta](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/system-8-beta-now-available)

---

## 2. Devices with Round AMOLED Displays by Resolution

### 2.1 Round 390x390 AMOLED

| Device | API Level | Notes |
|---|---|---|
| Venu (original) | 3.3.0 | First Garmin AMOLED watch |
| Venu 3S (41mm) | 5.0+ | Smaller Venu 3 variant |
| Vivoactive 5 | 5.0+ | Mid-range AMOLED |
| Vivoactive 6 | 5.2.x | 2025 release, SDK 8.1.1+ required |
| Venu 4 (41mm) | 5.1+ | Released Sep 2025 |
| Forerunner 165 / 165 Music | 5.0+ | Entry AMOLED runner |
| Forerunner 570 (42mm) | 5.1+ | Released May 2025, successor to FR 265 |
| Instinct 3 AMOLED (45mm) | 5.1.x | First AMOLED Instinct |
| Instinct Crossover AMOLED | 5.1.x | Hybrid analog/digital |
| Approach S50 | 5.1.x | Golf watch |
| Approach S70 (42mm) | 5.1.x | Golf watch |
| Descent G2 | 5.1.x | Dive computer, round AMOLED |
| Descent Mk3 43mm / Mk3i 43mm | 5.1.x | Dive computer |
| D2 Air | 3.2.x | Aviation (older) |
| Fenix 8 (43mm) | 5.1.x | **Actually 416x416, see below** |

**Note:** The Fenix 8 43mm is listed under 416x416, not 390x390. See section 2.2.

### 2.2 Round 416x416 AMOLED

| Device | API Level | Notes |
|---|---|---|
| Venu 2 / Venu 2 Plus | 4.0+ (upgraded to 5.0) | 2021 AMOLED |
| epix (Gen 2) | 4.0+ (upgraded to 5.0) | Premium multisport |
| epix Pro (Gen 2) 42mm | 5.0+ | |
| Fenix 8 (43mm) | 5.1.x | 1.3" AMOLED, 416x416 |
| Fenix E | 5.1+ | Budget Fenix |
| Forerunner 265 | 5.0+ | Mid-range runner AMOLED |
| D2 Air X10 | 5.0.x | Aviation |

### 2.3 Round 454x454 AMOLED

| Device | API Level | Notes |
|---|---|---|
| Venu 3 (45mm) | 5.0+ | 1.4" AMOLED |
| Venu 4 (45mm) | 5.1+ | Released Sep 2025 |
| Fenix 8 (47mm) | 5.1.x | 1.4" AMOLED |
| Fenix 8 (51mm) | 5.1.x | 1.4" AMOLED |
| Fenix 8 Pro (47mm) | 5.2.x | 2025/2026 premium |
| Fenix 8 Pro (51mm) | 5.2.x | 2025/2026 premium |
| Forerunner 965 | 5.0+ (upgraded to 5.1) | Premium runner AMOLED |
| Forerunner 970 | 5.1+ | Released 2025, successor to FR 965 |
| Forerunner 570 (47mm) | 5.1+ | 2025 release |
| Descent Mk3i (51mm) | 5.1.x | Dive computer, largest AMOLED |
| Instinct 3 AMOLED (50mm) | 5.1.x | Larger AMOLED Instinct |

**Note:** 454x454 is used by 1.4" AMOLED panels in the 47mm and 51mm case sizes.

### 2.4 Round 360x360 AMOLED

| Device | API Level | Notes |
|---|---|---|
| Venu 2S | 4.0+ (upgraded to 5.0) | Smaller Venu 2 |
| Forerunner 265S | 5.0+ | Smaller FR 265 |

### 2.5 Other AMOLED Resolutions (non-round or unusual)

| Device | Resolution | Shape | API Level |
|---|---|---|---|
| Venu Sq 2 / Sq 2 Music | 320x360 | Rounded square | 4.0+ |

---

## 3. Devices Supporting API Level 5.0 and Higher

### 3.1 API 5.0.x (System 7) - Broadest modern API

These devices originally shipped with older API levels but were **upgraded** to 5.0 via firmware updates:

- D2 Mach 1
- Edge 540 / 840 / 1040 series
- Enduro 2 series
- epix (Gen 2) / epix (Gen 2) Pro series
- Fenix 7 / 7S / 7X (all variants)
- Fenix 7 Pro / 7S Pro / 7X Pro (all variants)
- Forerunner 165 / 165 Music
- Forerunner 255 / 255 Music / 255S / 255S Music
- Forerunner 265 / 265S
- Forerunner 955 / 955 Solar
- Forerunner 965
- MARQ (Gen 2) series
- quatix 7 / 7 Pro series
- tactix 7 series
- Venu 2 / 2 Plus / 2S (later update)
- Venu 3 / 3S
- Venu Sq 2 / Sq 2 Music (later update)
- Vivoactive 5

**Source:** [Garmin Forums - API 5.0.0 Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/366559/api-5-0-0)

### 3.2 API 5.1.x (System 8)

Devices that shipped with or were upgraded to 5.1:

- Approach S50
- Approach S70 (42mm & 47mm)
- D2 Air X10
- Descent G2
- Descent Mk3 43mm / Mk3i 43mm / Mk3i 51mm
- Edge 1050
- Fenix 8 (43mm, 47mm, 51mm - all AMOLED and Solar variants)
- Fenix E
- Forerunner 570 (42mm & 47mm)
- Forerunner 955 (upgraded)
- Forerunner 965 (upgraded)
- Forerunner 970
- Instinct 3 AMOLED (45mm & 50mm)
- Instinct 3 Solar
- Instinct Crossover AMOLED
- Instinct E (40mm & 45mm)
- tactix 8 series
- Venu 4 / 4S
- Vivoactive 5 (upgraded)
- Vivoactive 6

**Note:** Many System 7 (5.0) devices receive firmware updates pushing them to 5.1.

### 3.3 API 5.2.x (Latest)

Newest devices and firmware updates:

- Fenix 8 Pro (47mm & 51mm)
- Vivoactive 6 (reported via SDK Manager)
- Forerunner 165 / 165 Music (updated)
- Additional devices being updated via quarterly firmware releases

**Source:** [Garmin Forums - API 5.2 Bug Report](https://forums.garmin.com/developer/connect-iq/i/bug-reports/api-level-5-2-not-supported-by-latest-sdk-8-2-3)

---

## 4. Device Family Overview for Major AMOLED Watches

In Connect IQ, the "device family" is defined by the combination of screen shape, resolution, display technology, and input method. Devices sharing the same physical characteristics can share resources (layouts, bitmaps, fonts).

| Device Family Grouping | Resolution | Display | Input | Devices |
|---|---|---|---|---|
| round-390x390-amoled-touch | 390x390 | AMOLED | Touch + buttons | Vivoactive 5/6, Venu 3S, Venu 4 (41mm), FR 165, FR 570 (42mm), Instinct 3 AMOLED 45mm |
| round-390x390-amoled-5btn | 390x390 | AMOLED | 5-button + touch | Descent G2, Descent Mk3 43mm |
| round-416x416-amoled | 416x416 | AMOLED | Various | Venu 2/2+, epix Gen 2, epix Pro 42mm, FR 265, Fenix 8 43mm, D2 Air X10 |
| round-454x454-amoled | 454x454 | AMOLED | Various | Venu 3 45mm, Venu 4 45mm, FR 965, FR 970, FR 570 47mm, Fenix 8 47/51mm, Fenix 8 Pro, Descent Mk3i 51mm, Instinct 3 AMOLED 50mm |
| round-360x360-amoled | 360x360 | AMOLED | Touch + buttons | Venu 2S, FR 265S |

**Important:** In practice, Connect IQ uses the device identifier string (e.g., `descentg2`, `fenix843mm`, `fr965`) in `manifest.xml` and `monkey.jungle`, not a formal "device family" grouping. Resource sharing is managed through the jungle build system (see Section 8).

---

## 5. Most Popular Garmin Watches 2025-2026

Garmin does not publish per-model sales numbers. The following is based on market analysis, review site rankings, search trends, and segment revenue data.

### Market Position
- Garmin is the **5th-best-selling wearable brand** globally (2025), with ~30% YoY growth
- **#1 in premium smartwatches** (>$500 segment)
- **Fitness segment** (Venu, Forerunner, Vivoactive) grew **33%** in 2025
- **Outdoor segment** (Fenix, Instinct, Enduro) grew only **5%** in 2025

### Most Popular Models (by review consensus and search interest)

**Tier 1 - Mass Market / High Volume:**
1. **Forerunner 265** - Most recommended mid-range AMOLED runner. Succeeded by FR 570 in 2025 but still extremely popular
2. **Vivoactive 5** / **Vivoactive 6** - Entry-level AMOLED, best value. VA6 released 2025
3. **Venu 3 / Venu 4** - Lifestyle/smartwatch focused, strong mainstream appeal

**Tier 2 - Enthusiast / Premium:**
4. **Forerunner 965** / **Forerunner 970** - Premium runner AMOLED
5. **Fenix 8 series** - Flagship multisport, premium pricing
6. **Fenix 7 / 7 Pro** - Still very widely owned (predecessor, huge installed base)
7. **epix (Gen 2) / epix Pro** - AMOLED alternative to Fenix 7

**Tier 3 - Specialty / Growing:**
8. **Instinct 3 AMOLED** - First AMOLED Instinct, strong launch 2025
9. **Forerunner 165** - Budget AMOLED runner entry point
10. **Descent G2 / Mk3** - Niche (dive) but loyal community

### Implications for Targeting
- The **Forerunner 265/570 + Vivoactive 5/6 + Venu 3/4** represent the largest user base
- All of these support API 5.0+ and have AMOLED displays
- Supporting **390x390 + 416x416 + 454x454** covers the vast majority of the AMOLED market

**Sources:** [Garmin Statistics - ElectroIQ](https://electroiq.com/stats/garmin-statistics/), [TechRadar Best Garmin](https://www.techradar.com/best/garmin-watch), [Tom's Guide Best Garmin](https://www.tomsguide.com/best-picks/best-garmin-watch), [Wareable Best Garmin](https://www.wareable.com/features/best-garmin-watch)

---

## 6. Recommended API Level Target

### Analysis

| minApiLevel | Devices Included | Devices Excluded | Key Features Available |
|---|---|---|---|
| 3.4.x | All CIQ 3 + CIQ 4 devices | None | Very limited; old MIP devices included |
| 4.0.x | All CIQ 4 devices | Old CIQ 3-only devices (FR 235, etc.) | Better type system, improved graphics |
| 5.0.0 | All modern AMOLED + recent MIP | Old Venu Sq, older MIP | 20-30% code space improvement, Communications in data fields, tuple types, Array.sort(), Always On improvements |
| 5.1.0 | System 8+ devices | Fenix 7/7 Pro (unless updated), older epix Gen 2 | Extended code space (16MB), sensor pairing API, notifications API, watch face configurations |
| 5.2.0 | Newest devices only | Most current devices | Post-install data field flows; very limited device base currently |

### Recommendation

**For maximum reach with modern features: `minApiLevel="5.0.0"`**

**Rationale:**
- Covers ALL current AMOLED watches that matter: Fenix 7/7 Pro, Fenix 8, epix Gen 2/Pro, Forerunner 255/265/570/955/965/970, Venu 2/3/4, Vivoactive 5/6, Instinct 3, Descent G2/Mk3
- API 5.0 is the "clean break" where CIQ 3 devices were dropped
- Provides 20-30% better code space efficiency
- All devices with AMOLED displays support at least 5.0

**If you need System 8 features (extended code, notifications): `minApiLevel="5.1.0"`**

This is the project's current setting and is still a good choice. It excludes some older devices that haven't been firmware-updated to 5.1, but includes all 2024-2025 devices natively.

**Avoid targeting 5.2.0 for now** -- very few devices support it, and SDK support has had issues.

---

## 7. Specific Device API Levels and Display Specs (Requested Devices)

| Device | Display | Resolution | Type | API Level | System |
|---|---|---|---|---|---|
| **Fenix 7 (47mm)** | 1.3" round | 260x260 | MIP 64-color | 5.0.x (upgraded) | 7 |
| **Fenix 7S (42mm)** | 1.2" round | 240x240 | MIP 64-color | 5.0.x (upgraded) | 7 |
| **Fenix 7X (51mm)** | 1.4" round | 280x280 | MIP 64-color | 5.0.x (upgraded) | 7 |
| **Fenix 8 (43mm)** | 1.3" round | 416x416 | AMOLED | 5.1.x | 8 |
| **Fenix 8 (47mm)** | 1.4" round | 454x454 | AMOLED | 5.1.x | 8 |
| **Fenix 8 (51mm)** | 1.4" round | 454x454 | AMOLED | 5.1.x | 8 |
| **Fenix 8 Pro (47mm)** | 1.4" round | 454x454 | AMOLED | 5.2.x | 8+ |
| **Fenix 8 Pro (51mm)** | 1.4" round | 454x454 | AMOLED | 5.2.x | 8+ |
| **epix (Gen 2)** | 1.3" round | 416x416 | AMOLED | 5.0.x (upgraded) | 7 |
| **epix Pro (Gen 2) 42mm** | 1.3" round | 416x416 | AMOLED | 5.0.x | 7 |
| **epix Pro (Gen 2) 47mm** | 1.4" round | 454x454 | AMOLED | 5.0.x | 7 |
| **epix Pro (Gen 2) 51mm** | 1.4" round | 454x454 | AMOLED | 5.0.x | 7 |
| **Venu 3 (45mm)** | 1.4" round | 454x454 | AMOLED | 5.0.x | 7 |
| **Venu 3S (41mm)** | 1.2" round | 390x390 | AMOLED | 5.0.x | 7 |
| **Venu 4 (45mm)** | 1.4" round | 454x454 | AMOLED | 5.1.x | 8 |
| **Venu 4 (41mm)** | 1.2" round | 390x390 | AMOLED | 5.1.x | 8 |
| **Vivoactive 5** | 1.2" round | 390x390 | AMOLED | 5.0.x (upgradeable to 5.1) | 7/8 |
| **Vivoactive 6** | 1.2" round | 390x390 | AMOLED | 5.2.x | 8+ |
| **Forerunner 265** | 1.3" round | 416x416 | AMOLED | 5.0.x | 7 |
| **Forerunner 265S** | 1.1" round | 360x360 | AMOLED | 5.0.x | 7 |
| **Forerunner 570 (42mm)** | 1.2" round | 390x390 | AMOLED | 5.1+ | 8 |
| **Forerunner 570 (47mm)** | 1.4" round | 454x454 | AMOLED | 5.1+ | 8 |
| **Forerunner 965** | 1.4" round | 454x454 | AMOLED | 5.0.x (upgradeable to 5.1) | 7/8 |
| **Forerunner 970** | 1.4" round | 454x454 | AMOLED | 5.1.x | 8 |
| **Instinct 3 AMOLED (45mm)** | 1.2" round | 390x390 | AMOLED | 5.1.x | 8 |
| **Instinct 3 AMOLED (50mm)** | 1.4" round | 454x454 | AMOLED | 5.1.x | 8 |
| **Instinct 3 Solar** | round | 176x176 | MIP 2-color | 5.1.x | 8 |
| **Descent G2** | 1.2" round | 390x390 | AMOLED | 5.1.x | 8 |
| **Descent Mk3 43mm** | round | 390x390 | AMOLED | 5.1.x | 8 |
| **Descent Mk3i 51mm** | round | 454x454 | AMOLED | 5.1.x | 8 |

---

## 8. Descent Series Complete Specs

| Device | Display | Resolution | Type | Colors | Shape | API Level | Notes |
|---|---|---|---|---|---|---|---|
| **Descent Mk1** | 1.2" | 240x240 | MIP | 64-color | Round | 3.1.x | Legacy; discontinued |
| **Descent Mk2** | 1.4" | 280x280 | MIP | 64-color | Round | 3.4.x | |
| **Descent Mk2i** | 1.4" | 280x280 | MIP | 64-color | Round | 3.4.x | SubWave sonar |
| **Descent Mk2S** | 1.2" | 240x240 | MIP | 64-color | Round | 3.4.x | Smaller variant |
| **Descent G1 / G1 Solar** | -- | 176x176 | MIP | 2-color | Semi-octagon | 3.4.x | Budget dive computer |
| **Descent G2** | 1.2" | 390x390 | AMOLED | 65536 | Round | 5.1.x | Current mid-range |
| **Descent Mk3 43mm** | -- | 390x390 | AMOLED | 65536 | Round | 5.1.x | Premium dive 2024 |
| **Descent Mk3i 43mm** | -- | 390x390 | AMOLED | 65536 | Round | 5.1.x | SubWave sonar |
| **Descent Mk3i 51mm** | -- | 454x454 | AMOLED | 65536 | Round | 5.1.x | Largest dive AMOLED |

**Source:** [Garmin Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/), [The Real Devices of Connect IQ Part 1](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/the-real-devices-of-connect-iq-part-1)

---

## 9. Multi-Device Support in Connect IQ

### 9.1 How It Works

Connect IQ uses a **jungle build system** to manage multi-device builds. The key file is `monkey.jungle`, which controls:
- Source file paths per device
- Resource paths per device (layouts, drawables, strings, fonts)
- Annotations for conditional compilation
- Excludes for removing code per device

When you export for the Connect IQ Store, the build system generates a `.iq` file containing compiled binaries for **every** device listed in your `manifest.xml`.

### 9.2 Device Targeting in manifest.xml

Devices are listed by their Connect IQ identifier in `<iq:products>`:

```xml
<iq:products>
    <iq:product id="descentg2"/>
    <iq:product id="fenix843mm"/>
    <iq:product id="fenix847mm"/>
    <iq:product id="fr265"/>
    <iq:product id="fr965"/>
    <iq:product id="venu3"/>
    <iq:product id="vivoactive5"/>
</iq:products>
```

### 9.3 Handling Different Screen Resolutions in monkey.jungle

The jungle system lets you define per-device resource folders:

```properties
project.manifest = manifest.xml

# Shared source for all devices
base.sourcePath = source

# Per-resolution resource folders
base.resourcePath = resources

# 390x390 AMOLED devices share resources
descentg2.resourcePath = $(descentg2.resourcePath);resources-round-390x390
vivoactive5.resourcePath = $(vivoactive5.resourcePath);resources-round-390x390
venu3s.resourcePath = $(venu3s.resourcePath);resources-round-390x390
fr165.resourcePath = $(fr165.resourcePath);resources-round-390x390
instinct3amoled45mm.resourcePath = $(instinct3amoled45mm.resourcePath);resources-round-390x390

# 416x416 AMOLED devices
fr265.resourcePath = $(fr265.resourcePath);resources-round-416x416
epix2pro42mm.resourcePath = $(epix2pro42mm.resourcePath);resources-round-416x416
fenix843mm.resourcePath = $(fenix843mm.resourcePath);resources-round-416x416

# 454x454 AMOLED devices
fr965.resourcePath = $(fr965.resourcePath);resources-round-454x454
fr970.resourcePath = $(fr970.resourcePath);resources-round-454x454
venu3.resourcePath = $(venu3.resourcePath);resources-round-454x454
fenix847mm.resourcePath = $(fenix847mm.resourcePath);resources-round-454x454
fenix851mm.resourcePath = $(fenix851mm.resourcePath);resources-round-454x454

# 360x360 devices
fr265s.resourcePath = $(fr265s.resourcePath);resources-round-360x360
```

### 9.4 Resource Folder Structure

```
resources/                      # Base resources (shared across all)
  drawables/
  fonts/
  layouts/
  strings/
resources-round-390x390/       # 390x390 specific layouts and bitmaps
  layouts/
  drawables/
resources-round-416x416/       # 416x416 specific
  layouts/
  drawables/
resources-round-454x454/       # 454x454 specific
  layouts/
  drawables/
resources-round-360x360/       # 360x360 specific
  layouts/
  drawables/
```

### 9.5 Per-Device Source Code (Annotations)

For code that differs by device, use annotations and the jungle system:

```properties
# In monkey.jungle
descentg2.sourcePath = $(descentg2.sourcePath);source-descent
```

```c
// In source, use has() to check capabilities at runtime
if (Toybox.WatchUi has :WatchFaceDelegate) {
    // Use newer API
}
```

### 9.6 Key Build Notes

- The `$(device.resourcePath)` syntax inherits the parent value, allowing additive resource paths
- Resources are merged: device-specific resources override base resources with the same name
- Layouts in device-specific folders override base layouts
- The build system picks the **last** definition when resources conflict
- Each device can also have its own `sourcePath` for device-specific code

**Sources:** [Jungle Reference Guide](https://developer.garmin.com/connect-iq/reference-guides/jungle-reference/), [Build Configuration](https://developer.garmin.com/connect-iq/core-topics/build-configuration/), [Start To Run - Jungle Tutorial](https://starttorun.info/tackling-connect-iq-versions-screen-shapes-and-memory-limitations-the-jungle-way/)

---

## 10. Practical Recommendations for the Windfall Watch Face

### Phase 1: Initial Target (Current)
- **Primary device:** Descent G2 (390x390 AMOLED, API 5.1.0)
- **minApiLevel:** 5.1.0 (good choice - covers all 2024-2025 devices)

### Phase 2: Expand to Same Resolution
Add all 390x390 AMOLED devices that share the same layout:
- Vivoactive 5, Vivoactive 6
- Venu 3S, Venu 4 (41mm)
- Forerunner 165, Forerunner 570 (42mm)
- Instinct 3 AMOLED (45mm)
- Descent Mk3 43mm / Mk3i 43mm

### Phase 3: Add Other AMOLED Resolutions
- **454x454:** Venu 3, Venu 4 (45mm), FR 965, FR 970, FR 570 (47mm), Fenix 8 47/51mm, Descent Mk3i 51mm, Instinct 3 AMOLED 50mm
- **416x416:** FR 265, epix Gen 2, epix Pro 42mm, Fenix 8 43mm
- **360x360:** FR 265S, Venu 2S (if demand exists)

### Phase 4: Consider MIP (Optional)
- Fenix 7 series (260x260 MIP) - huge installed base but very different display technology
- Requires separate visual assets optimized for low-color MIP displays

### If You Want Maximum Reach: Lower to minApiLevel 5.0.0
This adds Fenix 7/7 Pro, epix Gen 2/Pro, FR 255/265/955/965, Venu 2/3, and Vivoactive 5 at their original firmware levels. Unless you specifically need System 8 features (extended code space, notifications API), this is the best sweet spot.

---

## 11. Complete List of AMOLED Device Identifiers for manifest.xml

For reference when adding devices to the project:

```
# 390x390 AMOLED
descentg2
descentmk343mm
descentmk3i43mm
approachs50
approachs7042mm
d2air
fr165
fr165music
fr57042mm
instinct3amoled45mm
instinctcrossoveramoled
venu
venu3s
venu441mm
vivoactive5
vivoactive6

# 416x416 AMOLED
d2airx10
epix2
epix2pro42mm
fenix843mm
fenixe
fr265
venu2
venu2plus

# 454x454 AMOLED
descentmk3i51mm
epix2pro47mm
epix2pro51mm
fenix847mm
fenix851mm
fenix8pro47mm
fenix8pro51mm
fenix8solar47mm
fenix8solar51mm
fr57047mm
fr965
fr970
instinct3amoled50mm
venu3
venu445mm

# 360x360 AMOLED
fr265s
venu2s
```

**Note:** These identifiers are approximate -- always verify against the Connect IQ SDK Manager for exact device ID strings. Device IDs can differ slightly (e.g., `fenix8amoled47mm` vs `fenix847mm`). Install the SDK and check `~/.Garmin/ConnectIQ/Devices/` for definitive identifiers.

---

## Sources

- [Garmin Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Garmin Device Reference](https://developer.garmin.com/connect-iq/device-reference/)
- [The Real Devices of Connect IQ Part 1](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/the-real-devices-of-connect-iq-part-1)
- [System 7 Announcement](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/welcome-to-system-7)
- [System 8 Beta Announcement](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/system-8-beta-now-available)
- [API 5.0.0 Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/366559/api-5-0-0)
- [API 5.2 Bug Report](https://forums.garmin.com/developer/connect-iq/i/bug-reports/api-level-5-2-not-supported-by-latest-sdk-8-2-3)
- [CIQ vs API Version Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/420567/difference-between-ciq-and-api-version)
- [Device API Levels Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/354168/device-api-levels)
- [Jungle Reference Guide](https://developer.garmin.com/connect-iq/reference-guides/jungle-reference/)
- [Build Configuration](https://developer.garmin.com/connect-iq/core-topics/build-configuration/)
- [Connect IQ 8 Overview - the5krunner](https://the5krunner.com/2025/01/07/connect-iq-8-what-we-know-so-far-about-system-8/)
- [Garmin Venu 4 - garminrumors](https://garminrumors.com/models/venu-4/)
- [Vivoactive 6 SDK Announcement](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/vivoactive-6-now-available-in-the-connect-iq-sdk-manager)
- [Garmin Market Statistics - ElectroIQ](https://electroiq.com/stats/garmin-statistics/)
