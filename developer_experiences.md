# Garmin Connect IQ Developer Experiences & Lessons Learned

A comprehensive collection of real-world developer experiences, pitfalls, tips, and community wisdom gathered from forums, blog posts, Reddit, and other sources. Last updated: March 2026.

---

## Table of Contents

1. [General Developer Sentiment](#1-general-developer-sentiment)
2. [The Monkey C Language](#2-the-monkey-c-language)
3. [Memory Limitations & Management](#3-memory-limitations--management)
4. [Performance & Watchdog Timer](#4-performance--watchdog-timer)
5. [Simulator vs. Real Device Differences](#5-simulator-vs-real-device-differences)
6. [UI/UX Challenges](#6-uiux-challenges)
7. [AMOLED & Always-On Display](#7-amoled--always-on-display)
8. [Device Compatibility & Fragmentation](#8-device-compatibility--fragmentation)
9. [Bluetooth & Communication](#9-bluetooth--communication)
10. [Background Services & Web Requests](#10-background-services--web-requests)
11. [Debugging & Testing](#11-debugging--testing)
12. [Known SDK Bugs & Limitations](#12-known-sdk-bugs--limitations)
13. [App Store & Review Process](#13-app-store--review-process)
14. [Monetization](#14-monetization)
15. [Descent G2 & Dive Watch Specifics](#15-descent-g2--dive-watch-specifics)
16. [Tips & Tricks from Experienced Developers](#16-tips--tricks-from-experienced-developers)
17. [Community Resources](#17-community-resources)
18. [Recent SDK Improvements (System 7 & 8)](#18-recent-sdk-improvements-system-7--8)

---

## 1. General Developer Sentiment

### Positive Aspects

- The development process is **relatively straightforward and genuinely open**, without requiring expensive API access fees
- The Monkey C language is **easy to pick up** for developers with Java/JavaScript experience
- Garmin has done a "very good job on their documentation and developer experience" (some developers)
- The VS Code extension provides a **complete development environment** with code highlighting, build integration, and debugging

### Common Frustrations

- **Documentation gaps**: "The main frustration is missing explanation of how functions work in specific cases in the documentation, along with small bugs and quirks that only occur on a device (not in the simulator)." -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/2388/i-give-up-on-garmin-connect-iq-my-thoughts)
- **Lack of support**: "I send emails about critical bugs and crashes. No response." Developers report waiting months or years for bug fixes.
- **Developer verification**: Some developers view requiring full personal info and an ID scan for publishing a watch face as "a completely unreasonable ask that kills grassroots support for the app ecosystem." -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/connect-iq-web-store/380158/developer-verification-is-unreasonable-and-intrusive)
- A professional app developer reported being **unable to even get started** due to login timeouts and forum access problems -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/i/bug-reports/connect-iq-sdk---impossible-to-get-started-developing)

### "I Give Up" Post (Classic Forum Thread)

One notable forum post from a developer who gave up on Connect IQ cited five primary frustrations:

1. **No file I/O**: "I have a device with 8GB of memory and I cannot read/write data from it?"
2. **HTTP limited to JSON**: "Not everybody can develop a web service that gets the information from some URL and then translates it back to JSON format."
3. **No unique device ID** for user identification
4. **Backward compatibility breaks** between SDK versions: "I see many complaints on apps working wrongly in v.1.2.2 when they were OK in v.1.2.0."
5. **No logging/debugging tools**: Developers need "the ability to create a log/trace" to diagnose user-reported issues.

Source: [Garmin Forums - I give up on Garmin Connect IQ](https://forums.garmin.com/developer/connect-iq/f/discussion/2388/i-give-up-on-garmin-connect-iq-my-thoughts)

---

## 2. The Monkey C Language

### Language Characteristics

- Synthesized from **Java, JavaScript, Python, PHP, and Ruby**
- Fully **object-oriented** with no primitive types -- integers, floats, characters are all objects
- Uses **duck typing** (dynamic typing determined at runtime)
- Uses `using` for imports (not `import`), `function` for methods, and `hidden` instead of `private`
- Variables declared with `var`, constants with `const`, type inference is automatic
- Every function returns a value, even if unspecified

### Developer Opinions on Monkey C

- "If you don't know how to code, almost any other language is better. With very limited Monkey C codebase data over the web and very cropped language capabilities, you will never properly learn about data types specifics, data structures, loops, OOP, common programming patterns." -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/363189/learning-to-code-with-monkey-c-or-is-another-language-better)
- "You can't always write canonical and nice readable OOP code in Monkey C even if you are an expert, because the device hardware is often too weak to support code patterns which you'd normally use in Java or C#, or Monkey C doesn't support such features itself."
- **Recommendation**: Learning a C-family language (Java, JavaScript) before Monkey C is always the best option
- As wearables evolve, "Monkey-C's shortcomings have put Garmin at a disadvantage compared to ecosystems like Apple's Swift and Google's Kotlin"

### Scope Pitfall

Use `hidden` instead of `private` for function scoping. One developer discovered: "I've ran into build issues when creating custom Drawables" using `private`, making `hidden` the safer choice. -- [Medium - Joshua Miller](https://medium.com/@JoshuaTheMiller/making-a-watchface-for-garmin-devices-8c3ce28cae08)

### Type System

- Monkey Types provides gradual type checking (introduced at GDVC 2020)
- Type checking levels: 0 (off), 1 (gradual/default), 2 (informative), 3 (strict)
- Compiler optimization levels: 0 (none) to 2 (release) -- performs constant folding, branch elimination, etc.
- Typing is **not required** for optimizations and can be disabled

---

## 3. Memory Limitations & Management

### Device Memory Limits (Examples)

| Device | Watch Face | Watch App | Widget | Data Field |
|--------|-----------|-----------|--------|------------|
| Epix | 1,048 KB | 1,048 KB | 1,048 KB | 128 KB |
| fenix 5 | 92 KB | -- | -- | 28 KB |
| Forerunner 920XT | 64 KB | 64 KB | 64 KB | 16 KB |
| System 5 devices | 128 KB or less | -- | 64 KB | -- |

**Critical**: If you exceed the memory limit, **the app is silently killed** by the system and the default watch face is displayed.

### The Hidden Object Limit

Beyond byte-based memory limits, there is a separate **object limit** (approximately 256 objects on some devices). Using multi-dimensional arrays burns through objects fast. One developer found that "Unexpected Type Error" messages in previously functioning code were caused by hitting the object limit, not memory limit. The fix required eliminating a layout system with ~24 label references and converting to direct drawing calls. -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/4060/understanding-connect-iq-device-memory-limits)

### Storage API Limits

- Older SDK: ~6 KB storage via Object Store
- SDK 2.4+: ~100 KB via `Application.Storage`, but each item must be under 8 KB
- `Storage.setValue()` -- if the memory limit is hit, **the app crashes without warning**. "It's difficult to guard against this." -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/i/bug-reports/holistic-review-of-ciq-limitations-for-large-applications)

### Memory Optimization Techniques

**Code-level optimizations:**
- Use `if` instead of `switch` statements
- Replace dictionaries with array lookup tables
- Use hardcoded constants instead of enums
- Flatten nested arrays
- Return arrays instead of objects for multiple return values
- Eliminate local variables where feasible; reuse variables
- Manually inline single-line function calls
- Avoid `Long` and `Double` types; prefer `Number` and `Float`
- Avoid classes when possible -- use static functions with passed references

**Resource optimizations:**
- Only include needed characters in custom fonts (use XML filter)
- Load fonts once and set on each label (don't load multiple times)
- Reduce bitmap usage; substitute with fonts or drawn shapes
- Use `BufferedBitmaps` with custom palettes containing only necessary colors
- Set bitmaps to `null` when no longer needed
- Remove `System.println()` calls entirely (causes memory spikes!)
- Hardcode strings instead of using `loadResource()` (which loads all resource tables into RAM)
- Replace font constant names with hardcoded values (saves ~2 KB)

**Advanced techniques:**
- **Bit-packing**: Store static data in bit-packed integer arrays for 4x savings
- **Function-wrapped data**: Wrap large static/const data blocks in functions so they consume peak memory only during initialization
- Store menu data in functions, loading only when needed

### Graphics Pool (Connect IQ 4.0+)

CIQ 4.0 introduced a separate **graphics pool** for bitmaps and fonts. Resources load into this pool and return a `Graphics.ResourceReference`. The pool dynamically caches, unloads, and reloads resources based on available memory -- a significant improvement for resource management.

Sources:
- [Garmin Blog - Improve Performance](https://www.garmin.com/en-US/blog/developer/improve-your-app-performance/)
- [Garmin Forums - Memory Usage Best Practices](https://forums.garmin.com/developer/connect-iq/f/discussion/252057/best-practices-for-reducing-memory-usage)

---

## 4. Performance & Watchdog Timer

### Watchdog Timer

- The watchdog is **not time-based** but counts **bytecodes executed** without returning to the VM
- Code execution timeout is approximately **5 seconds on hardware** (trips faster in simulator)
- There is only **1 timeout system-wide**
- Timeout for glances/widgets has been **shorter on vivoactive/venu** devices than forerunner/fenix
- Timeout varies by device -- always test on target hardware

**Developer frustration**: "Figuring out how long they can safely run is pure guesswork. If the API simply exposed the remaining Watchdog budget, code could be far more efficient and resilient." -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/i/bug-reports/holistic-review-of-ciq-limitations-for-large-applications)

### Rendering Performance

- Complex graphics with many polygons and texts can take **700ms to draw**, causing unresponsiveness: "When the image is still drawn, you cannot navigate from the app."
- Anti-aliased drawing with thin diagonal lines using polygons has precision issues -- pixel positions require integer values
- On older CIQ 1 devices, anti-aliasing can cause performance issues due to code execution time limitations

### onPartialUpdate Optimization

For watch faces displaying seconds in low-power mode:

- `onPartialUpdate()` is called for the first 59 seconds of every minute in low power mode
- **Power budget**: Average of **30ms per call** over a full minute. If exceeded, `onPartialUpdate` stops being called
- Must set a **clipping region** with `setClip()` to minimize the area being updated
- Load custom fonts once in `onLayout()` or `initialize()`, not during partial updates
- Only update changed elements -- check if data has changed before redrawing

### General Performance Tips

- Pre-calculate values (sunrise/sunset, BMI) and save to storage instead of recalculating
- Use the application lifecycle wisely: `initialize -> onLayout -> onShow -> onUpdate`
- Monitor memory usage in the simulator (shows peak memory consumption)
- Use `onLayout()` for static content that never changes, not `onUpdate()`

Source: [Garmin Blog - Performance](https://www.garmin.com/en-US/blog/developer/improve-your-app-performance/)

---

## 5. Simulator vs. Real Device Differences

This is one of the most consistently reported pain points. The Connect IQ simulator is **not an emulator** -- it cannot perfectly replicate hardware behavior.

### Known Discrepancies

| Issue | Simulator | Real Device |
|-------|-----------|-------------|
| GPS data | Auto-populates Activity.Info | Requires explicit `Position.enableLocationEvents()` |
| GPS acquisition | Instant | Several minutes outdoors, accuracy progresses from "none" |
| Speed/distance data | Shows with random FIT data | May not show without active GPS session |
| Font rendering | May differ between simulated devices | Device-specific font rendering |
| Text positioning | Correct per specification | Text renders **higher** (by ~3 pixels) on some devices |
| Screen clearing | Not shown | Newer devices clear screen to black before `onUpdate()` |
| Button behavior | May not call BehaviorDelegate functions | Different button mapping |
| Property access | Works | Can throw "Unhandled Exception" not seen in simulator |
| Network requests | `-402` error behavior differs | Inconsistent with simulator behavior |
| Touchscreen | Works fine | Apps can crash on real devices with certain button presses |

### Font Rendering Issues

- "If you simulate a 935, things look the same on a real 935. However, if you simulate an f3, fonts look way different on a 935."
- Differences in standard fonts between Edge 1030 series and Edge 1040 series affect layout appearance
- Workaround: Use distinct colors for text backgrounds to visualize actual text box dimensions

### Debugging Strategy

"Implement `println` calls and create a log file to identify timing and data ordering differences between simulator and actual hardware behavior." -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/219096/simulator-vs-real-device)

Sources:
- [Garmin Forums - Simulator vs Real Device](https://forums.garmin.com/developer/connect-iq/f/discussion/219096/simulator-vs-real-device)
- [Garmin Forums - Difference Between Simulator and Real Devices](https://forums.garmin.com/developer/connect-iq/f/discussion/315387/difference-between-simulator-and-real-devices)

---

## 6. UI/UX Challenges

### Round Screen Constraints

- Data fields on round watches are **obscured by the round screen** (unlike rectangular displays)
- Developers must manage **multiple screen resolutions** (240px, 260px, etc.) with arrays loaded based on screen size checks
- Battery and performance constraints are especially tight on small screens

### Widget Glances

- The glance carousel shows **three widget glances at a time**, reducing available screen real estate
- Fitting a full-screen widget's data into a glance is not feasible
- One developer's solution: Render a graph to a smaller area within the glance canvas while still displaying meaningful text elements
- Older devices do not support full user input on the initial widget view (buttons are reserved for scrolling/selecting)

### Data Field Tap Support

- Newer devices (FR955, Fenix 7+) **unofficially** support `onTap()` for data fields
- This support is **not documented** and is **not reflected in the simulator** -- only works on real devices

### Design Considerations

- **Color support varies**: Some devices support only 16 colors, others have extensive palettes
- Use `Instanceof` and `Has` checks before using device-specific features like heart rate
- Device-dependent API access requires **fallback logic** for varying hardware capabilities
- Always check `System.getDeviceSettings().is24Hour` before formatting time displays

Source: [Garmin UX Guidelines](https://developer.garmin.com/connect-iq/user-experience-guidelines/)

---

## 7. AMOLED & Always-On Display

### Burn-In Prevention Rules

| Rule | Applies To | Description |
|------|-----------|-------------|
| 10% pixel limit | All AMOLED devices | No more than 10% of pixels can be lit in sleep mode; exceeding this turns the screen black |
| 3-minute pixel rule | Venu, Venu Square (original) | No pixel can remain on for more than 3 minutes continuously |
| 3-minute rule relaxed | Epix Gen 2, Venu 2, Marq Gen 2+ | The 3-minute rule appears to be relaxed or eliminated |
| Luminance check | System 7+ | Heuristic updated from pixel-based to **luminance-based** (10% of total luminance) |

### Developer Challenges

- Data-rich watch faces with static icons/labels make it **tricky to avoid burn-in** prevention triggers
- Garmin's system **actively detects and shuts down** watch faces that pose a higher risk of burn-in
- Native Garmin watchfaces operate under **different (more permissive) rules** than Connect IQ apps

### Mitigation Strategies

- Implement small, **variable pixel offsets** to prevent static positioning (leave enough edge spacing to prevent clipping)
- Animate moving elements (watch hands) to complete full rotation, toggling pixels on/off
- Use the simulator's "Burn in state" and "Screen protection" indicators for testing
- Check if device requires burn-in protection and handle rendering differently in low power mode

Source: [Garmin Developer - AMOLED Watch Faces](https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-make-a-watch-face-for-amoled-products/)

---

## 8. Device Compatibility & Fragmentation

### SDK Version Challenges

- Using a CIQ2 feature on a CIQ1 device, or a CIQ3 feature on CIQ1/CIQ2 device will cause crashes
- Developers struggle to find a comprehensive list of watches with their supported Connect IQ versions
- "There's no way of knowing how far back you have to go to allow compatibility or what is limiting devices from being compatible"
- Build system automatically compiles for the highest supported SDK version per device

### Hardware Variation Examples

- Forerunner 245 (CIQ 3.1 device) doesn't have a barometric altimeter -- using floors in ActMon will **crash the app**
- `Activity.Info.currentHeartRate` will always be `null` on FR5X devices -- must use `getCurrentHeartRate()` history
- Some devices have touchscreens, others only buttons
- Different GPS chipsets produce different data timing and accuracy

### App Manifest

- Make sure your manifest specifies **all products you wish to support**
- Use the "Monkey C: Export Project" command to generate `.iq` files containing binaries for all supported products
- Earlier SDK targets allow apps to run on more devices (at the cost of newer features)

### Cross-Device Portability

One developer found that converting a data field from Epix (128 KB limit) to Forerunner 920XT (16 KB limit) was **essentially impossible** given the memory constraints. -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/4060/understanding-connect-iq-device-memory-limits)

Source: [Garmin - Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)

---

## 9. Bluetooth & Communication

### Communication Architecture

Two ways to use Bluetooth in CIQ:

1. **Communications module**: Companion app on phone communicates through Garmin Connect Mobile (GCM). On Android, the companion app asks GCM for available connected CIQ wearables.
2. **BLE scanning**: App scans for a specific UUID, pairs, and reads/writes characteristics. **Cannot advertise with CIQ.**

### Key Limitations

- BLE reads are limited to approximately **20 bytes**
- `sendMessage` has no set limit, but there is an implicit limit based on available memory, and large messages are slow
- After Bluetooth loses connection and re-establishes, `Toybox.Communications.transmit()` may return errors that **don't self-resolve** without manually toggling Bluetooth in Settings
- On Edge, Oregon, and Rino devices, BT is only used for communication via `makeWebRequest` -- no companion app support
- All communication with phones is routed through Garmin Connect Mobile (no direct BLE)

Source: [Garmin Forums - Bluetooth Communication](https://forums.garmin.com/developer/connect-iq/f/discussion/8269/bluetooth-communication)

---

## 10. Background Services & Web Requests

### Hard Constraints

| Constraint | Limit |
|-----------|-------|
| Minimum interval | 5 minutes between background executions |
| Maximum runtime | 30 seconds per background execution |
| Timers | **Not allowed** in background services (ServiceDelegate) |
| Web request timeout | Must complete within the 30-second window |

### Network Request Limit (-402 Error)

- Apps can hit a `-402` request limit
- Behavior is **not well documented** and **differs between the simulator and real devices**
- The limit appears to restrict how many concurrent/recent requests can be made

### Design Implications

- Web-dependent features must be designed around 5-minute update intervals
- Cannot implement real-time data streaming or frequent polling
- Must handle timeout gracefully -- if a web request takes too long, the background service is killed
- Side-loaded apps **cannot use app settings** (requires App Store connection)

Sources:
- [Garmin Developer - Background Services](https://developer.garmin.com/connect-iq/core-topics/backgrounding/)
- [Garmin Developer - REST Services FAQ](https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-use-rest-services/)

---

## 11. Debugging & Testing

### Crash Log Locations

| Log Type | Path | Format |
|----------|------|--------|
| App crash log | `/GARMIN/APPS/LOGS/CIQ_LOG.YAML` | YAML (CIQ 3.0+) |
| Legacy crash log | `/GARMIN/APPS/LOGS/CIQ_LOG.TXT` | Text (older devices) |
| Device crash log | `/GARMIN/DEBUG/ERR_LOG.TXT` | Text |
| App-specific log | `/GARMIN/APPS/LOGS/[APPNAME].TXT` | Text |

- Logs auto-archive to `.BAK` when exceeding 5 KB; maximum practical space ~10 KB

### Exception Reporting Tool (ERA)

- Released in CIQ 3.1 beta (April 2019)
- Displays crash reports with information in **plain English**
- Shows the **line of code** where the error occurred
- Available in the developer portal for published apps

### Debugging Tips

- Use `System.println()` for console output in the simulator
- Create manual log files on-device with names matching the PRG filename
- App crashes display an **"IQ!" icon** on the device
- App crashes do **not** cause device reboots -- only the app is terminated
- The Run No Evil unit testing framework is available for automated testing

### Side-Loading for Testing

1. Build the `.PRG` file using "Build for Device" from VS Code command palette
2. Connect watch to computer via USB
3. Copy `.PRG` file to `/GARMIN/Apps` folder
4. macOS users may need Android File Transfer for file access

Source: [Garmin Developer - Debugging](https://developer.garmin.com/connect-iq/core-topics/debugging/)

---

## 12. Known SDK Bugs & Limitations

### Documented Issues

- **Stack overflow in JSON parsing**: Recursive JSON structures trigger stack overflows; requires manual iteration workarounds
- **Profiler mislabeling**: The profiler can mislabel or misreport entries, making it difficult to trust for performance tuning
- **Storage crashes**: `Storage.setValue()` crashes without warning when memory limit is hit
- **Network error inconsistency**: `-402` request limit behavior differs between simulator and real devices
- **Linux SDK Manager**: Dependency on older Ubuntu libraries (workaround: use Ubuntu 22.04 + linuxdeploy AppImage)
- **Stack overflow on finally**: Fixed in SDK 6.2.1 -- previously triggered stack overflow when returning from a `finally` statement
- **Settings type instability**: Settings clients occasionally return unexpected data types. Always type-check incoming values.

### Common Error Types

| Error | Cause | Solution |
|-------|-------|----------|
| `Watchdog Tripped Error` | Code executed too long without returning to VM | Break into smaller chunks, use task queues |
| `Out of Memory Error` | Exceeded device memory limit | Optimize resources, reduce objects |
| `Out of Objects Error` | Exceeded ~256 object limit | Flatten arrays, reduce object creation |
| `Stack Overflow Error` | Too many recursive calls or temporaries | Convert to iteration, reduce parameters |
| `Unexpected Type Error` | Often caused by memory pressure | Check for object limit issues |
| `Too Many Arguments` | Missing `state` arg in `onStart()`/`onStop()` | Added as security feature in SDK 2.1.2 |

### "Too Many Arguments" Error

This was added in SDK 2.1.2 as a security feature. Common causes:
- Missing `state` arguments in `onStart()` and `onStop()` methods
- Array-based `initialize()` called without parameters
- Crashes appear in `CIQ_LOG` files on 1.3.x and 2.x devices

---

## 13. App Store & Review Process

### Submission Process

1. Submit app via the developer portal
2. Preview and download for testing while approval is pending
3. Garmin reviews the application
4. Once approved, notification is sent and app appears in store

### Rejection Reasons

- Inappropriate content or behavior
- Apps that don't function or crash frequently
- GPS data usage violating developer terms
- **Watch faces resembling Garmin's proprietary designs** (new policy as of May 2025)

### 2025 Watch Face Policy Change

As of May 27, 2025, Garmin began **rejecting watch faces that closely resemble its proprietary designs**. This prevents developers from recreating popular faces (e.g., Instinct 3 Tactical, Forerunner 970/570 faces) for older devices.

Developer reaction: "I paid $1,000 for this watch, and now I can't even get the Tactical watch face because Garmin wants to sell more Tactix units? This feels like a bait and switch." -- [Luxelion](https://luxelion.com/blog/garmin-locks-down-watch-face-designs-new-connect-iq-policy-sparks-developer-backlash)

Previously published content remains available. Garmin now sells its own watch faces for $4.99 each, creating a revenue stream that the policy protects.

### Store Quality Issues

- Good quality watch faces struggle to gain visibility because they are quickly buried beneath numerous **low-quality duplicate watch faces**
- "The Connect IQ Store is getting worse by the day by a few developers who dump a shitload of watch faces" -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/connect-iq-web-store/351765/the-connect-iq-store-is-getting-worse-by-the-day-by-a-few-developers-who-dump-a-shitload-of-watch-faces)
- App approval can take **10+ days** during busy periods

Sources:
- [Garmin - App Review Guidelines](https://developer.garmin.com/connect-iq/app-review-guidelines/)
- [Garmin Rumors - Watch Face Policy](https://garminrumors.com/garmin-tightens-watch-face-policy-on-connectiq-store-dev-creations-rejected/)

---

## 14. Monetization

### Garmin's Official Monetization System

- **Annual fee**: $100 non-refundable program fee
- **Revenue split**: Garmin takes **15%** of the tax-exclusive price
- Garmin handles credit card fees
- Digital service taxes and currency conversion costs are withheld from developer payouts
- Developers are **not required** to use Garmin's Merchant Service (can use own payment system)
- Must be in a supported country to use the Merchant Service

### Third-Party Payment

- Acceptable to list prices, link to payment sites, or ask for donations (if marked appropriately)
- App store solicitation is permitted; forum solicitation is prohibited

### Community Experience

Some developers report uncertainty about whether Garmin's built-in monetization increases or decreases sales compared to managing their own payment system. -- [Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/426202/connect-iq-monetization-system-vs-own-payment-system---increase-in-sales)

Source: [Garmin Developer - Monetization](https://developer.garmin.com/connect-iq/monetization/app-sales/)

---

## 15. Descent G2 & Dive Watch Specifics

### Connect IQ on Descent Series

- **Descent G2** (announced February 2025, $699.99): First Descent G-series with **Connect IQ support** (not available on G1)
- Descent Mk2/Mk2i/Mk2S and Mk3 series are also supported in the Connect IQ SDK
- 1.2-inch AMOLED display, sapphire lens, 10 ATM rating

### Critical Limitation: No CIQ During Dives

**Connect IQ features are NOT available while diving.** The watch is completely locked down during a dive to ensure all dive capabilities function as designed. This means:

- No Connect IQ apps, watch faces, or data fields during active dives
- No access to settings or other non-dive screens underwater
- This is a **deliberate safety measure** to prevent accidentally accessing unfamiliar screens while underwater

### Sensor Data Restrictions

- **No barometer access from data fields**: The Sensor module is not allowed for data fields, only for apps
- API returns **altitude-corrected pressure** values, not raw values needed for depth calculation
- Real-time dive data (depth, decompression, gas mix) is handled entirely by Garmin's native dive software

### What You CAN Do

- Build watch faces for above-water use
- Create apps for surface intervals, dive planning, and post-dive analysis
- Access dive logs post-dive via the Garmin Dive app
- Build companion apps that display dive log data
- Use standard smartwatch features (activity tracking, heart rate, GPS) via Connect IQ

### Dive-Specific Hardware

- Built-in ABC sensors including underwater compass
- SubWave Sonar technology (Mk3i) for tank pressure monitoring
- Up to 8 transceiver connections (T2 transceiver)
- Multiple dive modes: single/multi-gas, gauge, apnea, apnea hunt, CCR

Sources:
- [Garmin - Descent G2](https://www.garmin.com/en-US/p/1558977/)
- [Garmin Forums - Freediving Depth Data Field](https://forums.garmin.com/developer/connect-iq/f/discussion/4028/freediving-depth-data-field)

---

## 16. Tips & Tricks from Experienced Developers

### Architecture & Design

1. **Plan before coding**: Have a design in mind to enable "consecutive chunks of time programming" rather than alternating between design and code
2. **Use placeholder-driven development**: Add placeholder elements first to visualize layout and test core functionality
3. **Naming conventions**: Append "Display" to all layout items showing data for clarity
4. **Skip layouts for simple designs**: For simple watch faces, avoid the layout system entirely and use direct `dc.drawBitmap()` / `dc.drawText()` calls

### Time & Date Handling

```
// System.getClockTime() only has time, not date
// Use Gregorian for date:
var clockTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

// 12-hour format handling:
var settings = Sys.getDeviceSettings();
if (!settings.is24Hour) {
    hour = today.hour % 12;
    hour = (hour == 0) ? 12 : hour;
    AMPM = (today.hour > 11) ? "pm" : "am";
}
```

### Heart Rate Access

- Get heart rate from `Activity.Info` first, then fall back to `ActivityMonitor.HeartRateIterator` for the most recent value
- On FR5X devices, `Activity.Info.currentHeartRate` is always null -- use `getCurrentHeartRate()` instead

### Drawing Order

When using `setLayout()`, `Ui.View.onUpdate(dc)` clears the screen and draws the layout. Draw custom elements **after** the parent class update, not before:

```
function onUpdate(dc) {
    Ui.View.onUpdate(dc);  // Draw layout first
    // Then draw custom elements on top
}
```

### Settings Best Practices

- Always **type-check settings values** -- they can return unexpected types
- Validate for null before conversion
- Side-loaded apps **cannot access app settings** (requires store installation)

### Installation Shortcut

Copy `.PRG` files to `/GARMIN/Apps` on the watch via USB for quick testing, bypassing the store entirely.

Sources:
- [James R DeVries Blog](https://www.jamesrdevries.com/blog/post/2024-03-22-garmin_connectiq/)
- [Garmin Forums - Tips and Tricks for MonkeyC Noob](https://forums.garmin.com/developer/connect-iq/f/discussion/1189/tips-and-tricks-for-a-monkeyc-noob)
- [Garmin Forums - Best Practises](https://forums.garmin.com/developer/connect-iq/f/discussion/6422/best-practises)

---

## 17. Community Resources

### Official Resources

| Resource | URL |
|----------|-----|
| Connect IQ Developer Portal | https://developer.garmin.com/connect-iq/ |
| Developer Forums | https://forums.garmin.com/developer/connect-iq |
| Bug Reports | https://forums.garmin.com/developer/connect-iq/i/bug-reports |
| New Developer FAQ | https://forums.garmin.com/developer/connect-iq/w/wiki/4/new-developer-faq |
| Connect IQ FAQ | https://forums.garmin.com/developer/connect-iq/w/wiki/3/connect-iq-faq |
| API Documentation | https://developer.garmin.com/connect-iq/api-docs/ |
| Device Reference | https://developer.garmin.com/connect-iq/device-reference/ |
| UX Guidelines | https://developer.garmin.com/connect-iq/user-experience-guidelines/ |
| Direct email | ConnectIQ@garmin.com |

### GitHub Resources

| Resource | URL |
|----------|-----|
| Official sample apps | https://github.com/garmin/connectiq-apps |
| Android SDK | https://github.com/garmin/connectiq-android-sdk |
| iOS Companion SDK | https://github.com/garmin/connectiq-companion-app-sdk-ios |
| Awesome Connect IQ (curated list) | https://github.com/Fun-with-Garmin-Development/awesome-connect-iq |
| GitHub topic: garmin-connect-iq | https://github.com/topics/garmin-connect-iq |
| Performance tests | https://github.com/Ciantic/GarminPerformanceTests |
| Linux SDK Manager (AppImage) | https://github.com/pcolby/connectiq-sdk-manager |

### Community Content

| Resource | URL |
|----------|-----|
| Open source CIQ apps list | https://starttorun.info/connect-iq-apps-with-source-code/ |
| CIQ versions per watch | https://forums.garmin.com/developer/connect-iq/f/discussion/211780/ |
| DC Rainmaker CIQ Overview | https://www.dcrainmaker.com/2015/01/connect-iq-intro.html |

### Blog Posts & Tutorials

- [Making a Watchface for Garmin Devices](https://medium.com/@JoshuaTheMiller/making-a-watchface-for-garmin-devices-8c3ce28cae08) - Joshua Miller
- [Garmin IQ and Monkey C Fundamentals](https://medium.com/@earel329/garmin-iq-and-monkey-c-fundamentals-ffe83eebb3fc) - Eduardo Arellano
- [Creating a Garmin Connect IQ Application](https://danoncoding.com/creating-a-garmin-connect-iq-application-part-1-hello-monkey-c-813eff5076e6) - Dan Siwiec
- [Getting Started with Garmin Connect IQ Development](https://www.ottorinobruni.com/getting-started-with-garmin-connect-iq-development-build-your-first-watch-face-with-monkey-c-and-vs-code/) - Ottorino Bruni
- [Garmin Watch Face Development - Things I'm Learning](https://www.jamesrdevries.com/blog/post/2024-03-22-garmin_connectiq/) - James R DeVries
- [Connect IQ Development Getting Started](https://www.morgenstern-digital.de/garmin/2022/08/22/garmin-connect-iq-development-getting-started.html) - Peter Morgenstern

### Note on Discord

No dedicated Discord community for Garmin Connect IQ developers was found during this research. The Garmin Forums remain the primary community hub.

---

## 18. Recent SDK Improvements (System 7 & 8)

### System 7 (API 5.0.0)

- **Always-On Display**: Heuristic updated from pixel-based to **luminance-based** (10% of total luminance)
- **Communications for Data Fields**: Direct support for Communications module (previously required background ServiceDelegate)
- **Compiler**: `has` operator evaluated at compile time when possible (not runtime)

### System 8 (API 5.1.0)

- **New VS Code Extension**: Real-time warnings/exceptions, autocompletion, find all references, folding ranges
- **Watch Face Editor Integration**: Integration with native on-device editor on fenix 8 / tactix 8 series
- **Extended Code Space**: 16 MB of code space paged in at runtime on demand (beyond heap) for supported devices
- **Native Pairing Flow**: CIQ apps can pair as part of the device's sensor pairing UI flow
- **Exception Reporting**: Improved real-time error reporting

### SDK Version Requirements (2025)

- System 8 devices receiving 2025 Q2 QMR: Side-loaded apps **must** be built with SDK 7.4.3+
- As of July 2025: Minimum SDK version of **8.1** for uploading apps to the store

Sources:
- [Garmin Forums - Welcome to System 7](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/welcome-to-system-7)
- [NotebookCheck - Connect IQ 8 Beta](https://www.notebookcheck.net/Garmin-announces-Connect-IQ-8-beta-with-new-watch-face-and-notification-related-features.944744.0.html)

---

## Summary: Top 10 Things Every New Connect IQ Developer Should Know

1. **Memory is your biggest enemy.** Know your target device's memory limit and monitor it constantly in the simulator.
2. **The simulator lies (sometimes).** Always test on a real device before publishing. Font rendering, GPS, button behavior, and text positioning can differ.
3. **Use `hidden` not `private`** for scope in custom Drawables.
4. **Watch the object count**, not just bytes. You can hit the ~256 object limit long before running out of memory.
5. **The watchdog timer will kill your app** if any function runs too long. Break heavy computation into chunks.
6. **`System.println()` wastes memory.** Remove all debug prints before release.
7. **AMOLED has strict pixel/luminance limits** in sleep mode. Design for 10% lit pixels max.
8. **Background services run at most every 5 minutes** for at most 30 seconds. Plan accordingly.
9. **Device compatibility is a maze.** Test on your target device(s) and use `has`/`instanceof` checks for all optional features.
10. **Read the forums.** The Garmin developer forums are the single best resource -- many experienced third-party developers actively help newcomers.
