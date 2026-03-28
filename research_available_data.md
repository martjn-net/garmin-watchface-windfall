# Available Data Fields for Garmin Descent G2 Watch Face

> Research document for the Windfall watch face project.
> Target device: Descent G2 (390x390 AMOLED, round, Connect IQ API Level 5.1.0)
> Memory limit for watch faces: 128 KB (131,072 bytes)
> Background service memory: 64 KB (65,536 bytes)

---

## Table of Contents

1. [Device Specifications](#1-device-specifications)
2. [Watch Face Permission Model](#2-watch-face-permission-model)
3. [ActivityMonitor Module](#3-activitymonitor-module)
4. [SensorHistory Module](#4-sensorhistory-module)
5. [Weather Module](#5-weather-module)
6. [System Module](#6-system-module)
7. [Time Module](#7-time-module)
8. [UserProfile Module](#8-userprofile-module)
9. [Position & Location](#9-position--location)
10. [Sensor Module](#10-sensor-module)
11. [Complications API](#11-complications-api)
12. [Activity Module](#12-activity-module)
13. [Manifest Permissions Reference](#13-manifest-permissions-reference)
14. [Most Popular Watch Face Data Fields](#14-most-popular-watch-face-data-fields)
15. [Descent G2 Dive-Specific Notes](#15-descent-g2-dive-specific-notes)

---

## 1. Device Specifications

| Property | Value |
|---|---|
| Device ID | `descentg2` |
| Display | 390x390 AMOLED, round |
| Connect IQ Version | 5.1.0 |
| Bits per pixel | 16 |
| Display type | AMOLED (requires burn-in protection) |
| Watch face memory | 128 KB (131,072 bytes) |
| Background memory | 64 KB (65,536 bytes) |
| Glance memory | 64 KB (65,536 bytes) |
| App storage capacity | 10 MB |
| Touch screen | Yes |
| Alpha blending | Yes |
| Complication icon size | 40x40 px |
| Launcher icon size | 60x60 px |
| Part number | 006-B4588-00 |

Source: `/home/arens/.Garmin/ConnectIQ/Devices/descentg2/compiler.json`

---

## 2. Watch Face Permission Model

Watch faces have **restricted permissions** compared to apps and widgets, primarily for battery conservation. The following permissions are relevant:

### Permissions Available for Watch Faces

| Permission | Available | Notes |
|---|---|---|
| **UserProfile** | YES | Access user profile data |
| **SensorHistory** | YES | Required for body battery, stress, SpO2, HR history |
| **Weather** | YES | Built-in weather API (no API key needed since CIQ 3.2) |
| **Background** | YES | Background service for communications |
| **Communications** | YES | Only via background service |
| **Complications** | YES | Since API 4.2.0, built-in |
| **Positioning** | NO | GPS not available for watch faces |
| **Sensor** | NO | Real-time sensor module not available for watch faces |
| **FIT** | NO | Activity recording not available |

### Modules Available Without Permissions

These modules require **no manifest permission** and are freely accessible:

- **ActivityMonitor** - steps, calories, floors, distance, active minutes, etc.
- **System** (DeviceSettings, Stats) - battery, notifications, bluetooth, DND, alarms
- **Time** - current time, date, durations
- **Activity** (read-only) - last known location via `Activity.getActivityInfo()`

---

## 3. ActivityMonitor Module

**No permission required.** Access via `ActivityMonitor.getInfo()`.

```monkey-c
var info = ActivityMonitor.getInfo();
```

### All Properties of ActivityMonitor.Info

| Property | Type | API Level | Description |
|---|---|---|---|
| `steps` | Number? | 1.0.0 | Step count since midnight |
| `stepGoal` | Number? | 1.0.0 | Daily step goal |
| `calories` | Number? | 1.0.0 | Calories burned today (kCal) |
| `distance` | Number? | 1.0.0 | Distance since midnight (cm) |
| `moveBarLevel` | Number? | 1.0.0 | Current move bar level (MOVE_BAR_LEVEL_MIN to MOVE_BAR_LEVEL_MAX) |
| `activeMinutesDay` | ActiveMinutes? | 2.1.0 | Moderate, vigorous, and total minutes today |
| `activeMinutesWeek` | ActiveMinutes? | 2.1.0 | Weekly active minutes breakdown |
| `activeMinutesWeekGoal` | Number? | 2.1.0 | Weekly active minutes target |
| `floorsClimbed` | Number? | 2.1.0 | Floors climbed today |
| `floorsClimbedGoal` | Number? | 2.1.0 | Daily floor climb goal |
| `floorsDescended` | Number? | 2.1.0 | Floors descended today |
| `metersClimbed` | Float? | 2.1.0 | Vertical elevation gained (m) |
| `metersDescended` | Float? | 2.1.0 | Vertical elevation lost (m) |
| `respirationRate` | Number? | 3.3.0 | Current breathing rate (breaths/min) |
| `timeToRecovery` | Number? | 3.3.0 | Hours to recovery from last activity |
| `stressScore` | Number? | 5.0.0 | Current stress level (0-100) |
| `pushes` | Number? | 4.2.3 | Wheelchair push count (if applicable) |
| `pushGoal` | Number? | 4.2.3 | Daily wheelchair push target |
| `pushDistance` | Number? | 4.2.3 | Wheelchair push distance (cm) |

### ActiveMinutes Object

```monkey-c
var am = info.activeMinutesDay;
// am.moderate - moderate active minutes
// am.vigorous - vigorous active minutes
// am.total - total active minutes
```

### Usage Example

```monkey-c
var info = ActivityMonitor.getInfo();
var steps = info.steps;           // e.g., 8432
var goal = info.stepGoal;         // e.g., 10000
var pct = steps.toFloat() / goal; // 0.84 = 84%
var cal = info.calories;          // e.g., 1842 kCal
var dist = info.distance / 100000.0; // convert cm to km
var floors = info.floorsClimbed;
var stress = info.stressScore;    // 0-100, null if unavailable
```

---

## 4. SensorHistory Module

**Requires `SensorHistory` permission in manifest.xml.**

```xml
<iq:permissions>
    <iq:uses-permission id="SensorHistory"/>
</iq:permissions>
```

All methods return a `SensorHistoryIterator`. The most recent value can be obtained by getting the first sample with `ORDER_NEWEST_FIRST`.

### Available History Methods

| Method | Returns | API Level | Unit |
|---|---|---|---|
| `getHeartRateHistory(options)` | Iterator | 2.1.0 | bpm |
| `getTemperatureHistory(options)` | Iterator | 2.1.0 | degrees Celsius |
| `getPressureHistory(options)` | Iterator | 2.1.0 | Pascals (Pa) |
| `getElevationHistory(options)` | Iterator | 2.1.0 | meters (m) |
| `getOxygenSaturationHistory(options)` | Iterator | 3.2.0 | percent (%) |
| `getStressHistory(options)` | Iterator | 3.3.0 | 0-100 scale |
| `getBodyBatteryHistory(options)` | Iterator | 3.3.0 | 0-100 scale |

### Options Parameter

```monkey-c
{
    :period => duration_or_seconds,  // Time.Duration or Number (seconds)
    :order => SensorHistory.ORDER_NEWEST_FIRST  // or ORDER_OLDEST_FIRST
}
```

### Usage Example - Get Latest Values

```monkey-c
// Get most recent heart rate
var hrIter = SensorHistory.getHeartRateHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var hrSample = hrIter.next();
var heartRate = (hrSample != null) ? hrSample.data : null;

// Get most recent body battery
var bbIter = SensorHistory.getBodyBatteryHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var bbSample = bbIter.next();
var bodyBattery = (bbSample != null) ? bbSample.data : null;

// Get most recent stress
var stressIter = SensorHistory.getStressHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var stressSample = stressIter.next();
var stress = (stressSample != null) ? stressSample.data : null;

// Get most recent SpO2
var spo2Iter = SensorHistory.getOxygenSaturationHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var spo2Sample = spo2Iter.next();
var spo2 = (spo2Sample != null) ? spo2Sample.data : null;

// Get most recent elevation
var elevIter = SensorHistory.getElevationHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var elevSample = elevIter.next();
var elevation = (elevSample != null) ? elevSample.data : null;

// Get most recent pressure
var pressIter = SensorHistory.getPressureHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var pressSample = pressIter.next();
var pressure = (pressSample != null) ? pressSample.data : null;

// Get most recent temperature
var tempIter = SensorHistory.getTemperatureHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
var tempSample = tempIter.next();
var temperature = (tempSample != null) ? tempSample.data : null;
```

### SensorSample Properties

Each sample from the iterator has:
- `data` - the sensor value (Number or Float, or null)
- `when` - Time.Moment of the reading

### Note on Respiration Rate

Respiration rate is available directly via `ActivityMonitor.getInfo().respirationRate` (API 3.3.0). There is no separate `SensorHistory.getRespirationRateHistory()` method.

---

## 5. Weather Module

**Requires `Weather` permission in manifest.xml** (available for watch faces since API 3.2.0).

```xml
<iq:permissions>
    <iq:uses-permission id="Weather"/>
</iq:permissions>
```

### Weather Methods

| Method | Returns | API Level |
|---|---|---|
| `Weather.getCurrentConditions()` | CurrentConditions? | 3.2.0 |
| `Weather.getDailyForecast()` | Array\<DailyForecast\>? | 3.2.0 |
| `Weather.getHourlyForecast()` | Array\<HourlyForecast\>? | 3.2.0 |
| `Weather.getSunrise(location, today)` | Time.Moment? | 3.3.0 |
| `Weather.getSunset(location, today)` | Time.Moment? | 3.3.0 |

### CurrentConditions Properties

| Property | Type | API Level | Description |
|---|---|---|---|
| `temperature` | Numeric? | 3.2.0 | Current temperature (Celsius) |
| `feelsLikeTemperature` | Float? | 3.2.0 | Wind chill / heat index (Celsius) |
| `highTemperature` | Numeric? | 3.2.0 | Forecasted high today (Celsius) |
| `lowTemperature` | Numeric? | 3.2.0 | Forecasted low today (Celsius) |
| `windSpeed` | Float? | 3.2.0 | Wind speed (m/s) |
| `windBearing` | Number? | 3.2.0 | Wind direction (degrees, 0=N, 90=E, 180=S, 270=W) |
| `relativeHumidity` | Number? | 3.2.0 | Humidity (0-100%) |
| `precipitationChance` | Number? | 3.2.0 | Precipitation probability (0-100%) |
| `condition` | Number? | 3.2.0 | Weather condition (CONDITION_* constant) |
| `observationTime` | Time.Moment? | 3.2.0 | UTC time of observation |
| `observationLocationPosition` | Position.Location? | 3.2.0 | Location of observation |
| `observationLocationName` | String? | 3.2.0 | Location name (DEPRECATED) |
| `uvIndex` | Float? | **5.1.0** | UV index (0-10) |
| `dewPoint` | Float? | **5.1.0** | Dew point (Celsius) |
| `visibility` | Float? | **5.1.0** | Visibility distance (m) |
| `pressure` | Float? | **5.1.0** | Air pressure (Pa) |
| `cloudCover` | Number? | **5.1.0** | Cloud cover (0-100%) |

> **Note:** The properties marked 5.1.0 are brand new and available on the Descent G2.

### DailyForecast Properties

| Property | Type | API Level | Description |
|---|---|---|---|
| `condition` | Condition? | 3.2.0 | Weather condition |
| `forecastTime` | Time.Moment? | 3.2.0 | Forecast valid time (UTC) |
| `highTemperature` | Numeric? | 3.2.0 | High temperature (Celsius) |
| `lowTemperature` | Numeric? | 3.2.0 | Low temperature (Celsius) |
| `precipitationChance` | Number? | 3.2.0 | Precipitation chance (0-100%) |

### HourlyForecast Properties

| Property | Type | API Level | Description |
|---|---|---|---|
| `condition` | Condition? | 3.2.0 | Weather condition |
| `forecastTime` | Time.Moment? | 3.2.0 | Forecast valid time (UTC) |
| `temperature` | Numeric? | 3.2.0 | Temperature (Celsius) |
| `precipitationChance` | Number? | 3.2.0 | Precipitation chance (0-100%) |
| `relativeHumidity` | Number? | 3.2.0 | Humidity (0-100%) |
| `windSpeed` | Float? | 3.2.0 | Wind speed (m/s) |
| `windBearing` | Number? | 3.2.0 | Wind direction (degrees) |
| `uvIndex` | Float? | **5.1.0** | UV index (0-10) |
| `dewPoint` | Float? | **5.1.0** | Dew point (Celsius) |
| `cloudCover` | Number? | **5.1.0** | Cloud cover (0-100%) |

### Weather Condition Constants (54 values)

Key conditions: `CONDITION_CLEAR`, `CONDITION_PARTLY_CLOUDY`, `CONDITION_MOSTLY_CLOUDY`, `CONDITION_RAIN`, `CONDITION_SNOW`, `CONDITION_WINDY`, `CONDITION_THUNDERSTORMS`, `CONDITION_FOG`, `CONDITION_HAZE`, `CONDITION_HAIL`, `CONDITION_SCATTERED_SHOWERS`, `CONDITION_SCATTERED_THUNDERSTORMS`, `CONDITION_UNKNOWN`, etc.

### Sunrise / Sunset

```monkey-c
// Get location from weather observation or last activity
var conditions = Weather.getCurrentConditions();
var loc = null;
if (conditions != null) {
    loc = conditions.observationLocationPosition;
}
if (loc == null) {
    var actInfo = Activity.getActivityInfo();
    if (actInfo != null) {
        loc = actInfo.currentLocation;
    }
}

if (loc != null) {
    var today = Time.today();
    var sunrise = Weather.getSunrise(loc, today);
    var sunset = Weather.getSunset(loc, today);
}
```

---

## 6. System Module

**No permission required.**

### System.getDeviceSettings()

```monkey-c
var settings = System.getDeviceSettings();
```

| Property | Type | API Level | Description |
|---|---|---|---|
| `notificationCount` | Number | 1.2.0 | Active notification count |
| `alarmCount` | Number | 1.2.0 | Configured alarm count |
| `phoneConnected` | Boolean | 1.1.0 | Phone Bluetooth connection status |
| `connectionAvailable` | Boolean | 3.0.0 | Any communication channel available |
| `connectionInfo` | Dictionary | 3.0.0 | BT, WiFi, LTE connection states |
| `doNotDisturb` | Boolean | 2.1.0 | DND mode active |
| `is24Hour` | Boolean | 1.0.0 | 24h vs 12h clock format |
| `distanceUnits` | UnitsSystem | 1.0.0 | Metric or statute |
| `temperatureUnits` | UnitsSystem | 1.0.0 | Celsius or Fahrenheit |
| `elevationUnits` | UnitsSystem | 1.0.0 | Meters or feet |
| `heightUnits` | UnitsSystem | 1.0.0 | Metric or statute |
| `weightUnits` | UnitsSystem | 1.0.0 | Kg or lbs |
| `paceUnits` | UnitsSystem | 1.0.0 | km/h or mph |
| `activityTrackingOn` | Boolean | 1.2.0 | Activity tracking enabled |
| `firmwareVersion` | Number[2] | 1.2.0 | [major, minor] |
| `monkeyVersion` | Number[3] | 1.0.0 | CIQ version [major, minor, micro] |
| `screenWidth` | Number | 1.2.0 | Screen width (px) |
| `screenHeight` | Number | 1.2.0 | Screen height (px) |
| `screenShape` | ScreenShape | 1.2.0 | Round, square, etc. |
| `isTouchScreen` | Boolean | 1.2.0 | Touch screen support |
| `tonesOn` | Boolean | 1.0.0 | Audio tones enabled |
| `vibrateOn` | Boolean | 1.0.0 | Vibration enabled |
| `firstDayOfWeek` | DayOfWeek | 3.0.0 | Calendar start day |
| `systemLanguage` | Language | 3.1.0 | Active system language |
| `requiresBurnInProtection` | Boolean | 3.0.12 | AMOLED burn-in protection needed |
| `isNightModeEnabled` | Boolean | 4.1.2 | Night mode colors active |
| `isEnhancedReadabilityModeEnabled` | Boolean | 4.2.3 | Enhanced readability active |
| `fontScale` | Float | 5.0.1 | Font scale factor |
| `phoneOperatingSystem` | PhoneOS? | 5.0.1 | Connected phone OS type |
| `isGlanceModeEnabled` | Boolean | 3.1.4 | Widget glances enabled |
| `uniqueIdentifier` | String? | 2.4.1 | Unique device ID (per app) |
| `partNumber` | String | 1.2.0 | Device part number |
| `inputButtons` | ButtonInputs | 1.2.0 | Physical buttons supported |

### System.getSystemStats()

```monkey-c
var stats = System.getSystemStats();
```

| Property | Type | API Level | Description |
|---|---|---|---|
| `battery` | Float | 1.0.0 | Battery remaining (%) |
| `batteryInDays` | Float | 3.3.0 | Battery remaining (days) |
| `charging` | Boolean | 3.0.0 | Connected to charger |
| `solarIntensity` | Number? | 3.2.0 | Solar panel intensity (0-100, null if unsupported) |
| `freeMemory` | Number | 1.0.0 | Free memory (bytes) |
| `totalMemory` | Number | 1.0.0 | Total memory (bytes) |
| `usedMemory` | Number | 1.0.0 | Used memory (bytes) |

### Usage Example

```monkey-c
var stats = System.getSystemStats();
var battery = stats.battery;           // e.g., 72.5
var batteryDays = stats.batteryInDays; // e.g., 5.2
var isCharging = stats.charging;       // true/false

var settings = System.getDeviceSettings();
var notifications = settings.notificationCount;
var alarms = settings.alarmCount;
var btConnected = settings.phoneConnected;
var dnd = settings.doNotDisturb;
var is24h = settings.is24Hour;
```

---

## 7. Time Module

**No permission required.**

### Core Methods

| Method | Returns | API Level | Description |
|---|---|---|---|
| `Time.now()` | Moment | 1.0.0 | Current time |
| `Time.today()` | Moment | 1.0.0 | Midnight today |
| `Time.getCurrentTime(options)` | Moment | 3.0.10 | Time from specified source |

### Time.Gregorian Methods

```monkey-c
var now = Time.now();
var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
// info.year    = 2026
// info.month   = 3
// info.day     = 28
// info.day_of_week = 6  (Saturday)
// info.hour    = 14
// info.min     = 30
// info.sec     = 45
```

### Sunrise / Sunset via Weather Module

```monkey-c
// Weather.getSunrise(location, date) - since API 3.3.0
// Weather.getSunset(location, date)  - since API 3.3.0
// Requires Weather permission and a valid location
```

### Getting Location for Sunrise/Sunset

Watch faces cannot use GPS directly. Location sources:
1. `Weather.getCurrentConditions().observationLocationPosition` (from weather data)
2. `Activity.getActivityInfo().currentLocation` (last GPS fix, goes stale after ~1-2 hours)
3. Save valid location to `Application.Storage` for persistent use

---

## 8. UserProfile Module

**Requires `UserProfile` permission in manifest.xml.**

```xml
<iq:permissions>
    <iq:uses-permission id="UserProfile"/>
</iq:permissions>
```

### Profile Properties

```monkey-c
var profile = UserProfile.getProfile();
```

| Property | Type | API Level | Description |
|---|---|---|---|
| `activityClass` | Number? | 1.0.0 | Activity level (0-100) |
| `birthYear` | Number? | 1.0.0 | Four-digit birth year |
| `gender` | Gender? | 1.0.0 | GENDER_MALE, GENDER_FEMALE, GENDER_UNSPECIFIED |
| `height` | Number? | 1.0.0 | Height in centimeters (cm) |
| `weight` | Number? | 1.0.0 | Weight in grams (g) |
| `restingHeartRate` | Number? | 1.0.0 | User-configured resting HR (bpm) |
| `averageRestingHeartRate` | Number? | 3.2.0 | 7-day average resting HR (bpm) |
| `runningStepLength` | Number? | 1.0.0 | Running step length (mm) |
| `walkingStepLength` | Number? | 1.0.0 | Walking step length (mm) |
| `sleepTime` | Duration? | 1.0.0 | Typical sleep time (since midnight) |
| `wakeTime` | Duration? | 1.0.0 | Typical wake time (since midnight) |
| `vo2maxRunning` | Number? | 3.3.0 | VO2max running (mL/kg/min) |
| `vo2maxCycling` | Number? | 3.3.0 | VO2max cycling (mL/kg/min) |

### Heart Rate Zone Methods

```monkey-c
var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
// Returns array of HR thresholds in bpm: [zone1_min, zone2_min, zone3_min, zone4_min, zone5_min, zone5_max]
```

### Other Methods

| Method | Returns | API Level | Description |
|---|---|---|---|
| `getProfile()` | Profile | 1.0.0 | User profile object |
| `getHeartRateZones(sport)` | Array\<Number\> | 1.0.0 | HR zone thresholds (bpm) |
| `getHeartRateZones2(sport)` | Array\<Number\> | 3.3.0 | HR zones using Activity.Sport enum |
| `getCurrentSport()` | SportHrZone | 1.0.0 | Current HR zone sport |
| `getCurrentSport2()` | Dictionary | 3.3.0 | Current sport and subsport |
| `getFunctionalThresholdPower(sport)` | Number? | 3.3.0 | FTP for sport (watts) |
| `getPowerZones(sport)` | Array\<Number\>? | 3.3.0 | Power zone thresholds |
| `getUserActivityHistory()` | UserActivityHistoryIterator | 3.3.0 | Activity history |

---

## 9. Position & Location

### Watch Face Limitations

- **Position module** (GPS) is NOT available for watch faces
- No `Positioning` permission allowed for watch faces
- GPS is a major battery drain, so Garmin restricts it

### Workarounds for Location Data

```monkey-c
// Option 1: Weather observation location (best for watch faces)
var conditions = Weather.getCurrentConditions();
if (conditions != null && conditions.observationLocationPosition != null) {
    var loc = conditions.observationLocationPosition;
    // Use for sunrise/sunset calculation
}

// Option 2: Last activity location (may be stale)
var actInfo = Activity.getActivityInfo();
if (actInfo != null && actInfo.currentLocation != null) {
    var loc = actInfo.currentLocation;
    // Save to Application.Storage for later use
    Application.Storage.setValue("lastLoc", loc.toDegrees());
}
```

### What Position Data IS Available (via SensorHistory, no GPS)

- **Elevation**: `SensorHistory.getElevationHistory()` - barometric altitude (m)
- **Pressure**: `SensorHistory.getPressureHistory()` - barometric pressure (Pa)

---

## 10. Sensor Module

**NOT available for watch faces.** The Sensor module (real-time sensor readings) requires the `Sensor` permission which is restricted to apps and widgets only.

### What You Would Get (Apps/Widgets Only)

For reference, Sensor.Info properties (NOT available in watch faces):

| Property | Type | Description |
|---|---|---|
| `heartRate` | Number? | Current HR (bpm) |
| `altitude` | Float? | Altitude above MSL (m) |
| `heading` | Float? | True north heading (radians) |
| `pressure` | Float? | Barometric pressure (Pa) |
| `temperature` | Float? | Temperature (Celsius) |
| `oxygenSaturation` | Number? | SpO2 (%) |
| `accel` | Array? | Accelerometer x, y, z (milli-g) |
| `mag` | Array? | Magnetometer x, y, z (milli-Gauss) |
| `speed` | Float? | Speed (m/s) |
| `cadence` | Number? | Cadence (rpm) |
| `power` | Number? | Power (watts) |

### Watch Face Alternatives

| Sensor Data | Watch Face Alternative |
|---|---|
| Heart rate | `SensorHistory.getHeartRateHistory()` or Complications |
| Altitude | `SensorHistory.getElevationHistory()` |
| Pressure | `SensorHistory.getPressureHistory()` |
| Temperature | `SensorHistory.getTemperatureHistory()` |
| SpO2 | `SensorHistory.getOxygenSaturationHistory()` |
| Heading | Not available in watch faces |

---

## 11. Complications API

**Available since API Level 4.2.0.** No special permission needed - built into the system.

Complications allow watch faces to subscribe to system and third-party data providers.

### How to Use Complications in a Watch Face

```monkey-c
// 1. Register for change notifications
Complications.registerComplicationChangeCallback(method(:onComplicationChanged));

// 2. Subscribe to specific complications by type
var iter = Complications.getComplications();
var complication = iter.next();
while (complication != null) {
    if (complication.getType() == Complications.COMPLICATION_TYPE_HEART_RATE) {
        Complications.subscribeToUpdates(complication.complicationId);
    }
    complication = iter.next();
}

// 3. Read complication data
function onComplicationChanged(complicationId as Complications.Id) as Void {
    var complication = Complications.getComplication(complicationId);
    var value = complication.value;
    // Update display
}
```

### All Complication Types (API 4.2.0+)

| Complication Type | Value Type | Description |
|---|---|---|
| `COMPLICATION_TYPE_BATTERY` | Number (0-100) | Battery charge percentage |
| `COMPLICATION_TYPE_STEPS` | Number | Daily step count |
| `COMPLICATION_TYPE_CALORIES` | Number | Daily calories burned |
| `COMPLICATION_TYPE_HEART_RATE` | Number? | Heart rate (bpm) |
| `COMPLICATION_TYPE_ALTITUDE` | Float? | Altitude (m) |
| `COMPLICATION_TYPE_CURRENT_TEMPERATURE` | Float? | Temperature (Celsius) |
| `COMPLICATION_TYPE_DATE` | String | Date (e.g., "28 Mar") |
| `COMPLICATION_TYPE_WEEKDAY_MONTHDAY` | String | Day+date (e.g., "Mon 28") |
| `COMPLICATION_TYPE_SUNRISE` | Number? | Seconds since midnight |
| `COMPLICATION_TYPE_SUNSET` | Number? | Seconds since midnight |
| `COMPLICATION_TYPE_BODY_BATTERY` | Number? | Body battery (0-100) |
| `COMPLICATION_TYPE_STRESS` | Number? | Stress level (0-100) |
| `COMPLICATION_TYPE_PULSE_OX` | Number? | SpO2 (0-100%) |
| `COMPLICATION_TYPE_RESPIRATION_RATE` | Number? | Respiration (bpm) |
| `COMPLICATION_TYPE_VO2MAX_RUN` | Number? | VO2max running |
| `COMPLICATION_TYPE_VO2MAX_BIKE` | Number? | VO2max cycling |
| `COMPLICATION_TYPE_TRAINING_STATUS` | String? | Training status text |
| `COMPLICATION_TYPE_SOLAR_INPUT` | Number? | Solar intensity (0-100) |
| `COMPLICATION_TYPE_RACE_PREDICTOR_5K` | Number? | Predicted 5K time (seconds) |
| `COMPLICATION_TYPE_RACE_PREDICTOR_10K` | Number? | Predicted 10K time (seconds) |
| `COMPLICATION_TYPE_RACE_PREDICTOR_HALF_MARATHON` | Number? | Predicted half marathon (seconds) |
| `COMPLICATION_TYPE_RACE_PREDICTOR_MARATHON` | Number? | Predicted marathon (seconds) |
| `COMPLICATION_TYPE_RACE_PACE_PREDICTOR_5K` | Float? | Predicted 5K pace (m/s) |
| `COMPLICATION_TYPE_RACE_PACE_PREDICTOR_10K` | Float? | Predicted 10K pace (m/s) |
| `COMPLICATION_TYPE_RACE_PACE_PREDICTOR_HALF_MARATHON` | Float? | Predicted half pace (m/s) |
| `COMPLICATION_TYPE_RACE_PACE_PREDICTOR_MARATHON` | Float? | Predicted marathon pace (m/s) |
| `COMPLICATION_TYPE_WHEELCHAIR_PUSHES` | Number? | Daily push count (API 4.2.3) |
| `COMPLICATION_TYPE_LAST_GOLF_ROUND_SCORE` | String? | Last golf score (API 5.0.0) |
| `COMPLICATION_TYPE_INVALID` | - | Invalid/unknown type |

### Complication Units

| Unit Constant | Value | Description |
|---|---|---|
| `UNIT_INVALID` | 0 | No unit |
| `UNIT_DISTANCE` | 1 | Meters |
| `UNIT_ELEVATION` | 2 | Meters |
| `UNIT_HEIGHT` | 3 | Meters |
| `UNIT_SPEED` | 4 | m/s |
| `UNIT_TEMPERATURE` | 5 | Celsius |
| `UNIT_WEIGHT` | 6 | Grams |

### Complication Data Structure

Each complication provides:
- `value` - the actual data value (String, Number, Float, etc.)
- `shortLabel` - short description label
- `unit` - unit constant
- `ranges` - min/max range values if applicable

---

## 12. Activity Module

**No permission required for read-only access.**

```monkey-c
var actInfo = Activity.getActivityInfo();
```

Useful properties for watch faces:

| Property | Type | API Level | Description |
|---|---|---|---|
| `currentLocation` | Position.Location? | 1.0.0 | Last known location (goes stale) |
| `currentHeartRate` | Number? | 1.0.0 | Current heart rate (bpm) |
| `altitude` | Float? | 1.0.0 | Altitude above MSL (m) |
| `currentHeading` | Float? | 1.0.0 | True north heading (radians) |
| `currentOxygenSaturation` | Number? | 3.2.0 | SpO2 (%) |

> **Note:** Most Activity.Info properties are only populated during an active recording session and will be null on the watch face. The `currentLocation` is the main useful field.

---

## 13. Manifest Permissions Reference

### Recommended Manifest for Windfall Watch Face

```xml
<iq:permissions>
    <iq:uses-permission id="UserProfile"/>
    <iq:uses-permission id="SensorHistory"/>
    <iq:uses-permission id="Weather"/>
    <iq:uses-permission id="Background"/>
    <iq:uses-permission id="Communications"/>
</iq:permissions>
```

### Permission Details

| Permission | Purpose | Required For |
|---|---|---|
| `UserProfile` | User profile, HR zones, VO2max | UserProfile module |
| `SensorHistory` | Historical sensor data | Body battery, stress, SpO2, HR history, elevation, pressure, temperature |
| `Weather` | Built-in weather data | Current conditions, forecast, sunrise/sunset |
| `Background` | Background service | Background communications (e.g., fetching external data) |
| `Communications` | Network access | HTTP requests from background service |

### Permissions NOT Available for Watch Faces

| Permission | Reason |
|---|---|
| `Positioning` | GPS drains battery; not allowed for watch faces |
| `Sensor` | Real-time sensors not available; use SensorHistory instead |
| `FIT` | Activity recording not relevant for watch faces |

---

## 14. Most Popular Watch Face Data Fields

Based on research of popular Garmin watch faces (Crystal, Data Lover, Infocal, Portal Hybrid) and user feedback from forums:

### Tier 1 - Essential (almost every watch face includes these)

| Data | API Call | Permission |
|---|---|---|
| **Time (digital/analog)** | `Time.Gregorian.info(Time.now(), ...)` | None |
| **Date** | `Time.Gregorian.info(...)` .day, .month, .day_of_week | None |
| **Battery %** | `System.getSystemStats().battery` | None |
| **Steps** | `ActivityMonitor.getInfo().steps` | None |
| **Step goal progress** | `steps / stepGoal` | None |
| **Heart rate** | `SensorHistory.getHeartRateHistory(...)` | SensorHistory |
| **Bluetooth status** | `System.getDeviceSettings().phoneConnected` | None |
| **Notification count** | `System.getDeviceSettings().notificationCount` | None |

### Tier 2 - Very Popular

| Data | API Call | Permission |
|---|---|---|
| **Calories** | `ActivityMonitor.getInfo().calories` | None |
| **Distance** | `ActivityMonitor.getInfo().distance` (cm) | None |
| **Floors climbed** | `ActivityMonitor.getInfo().floorsClimbed` | None |
| **Weather temperature** | `Weather.getCurrentConditions().temperature` | Weather |
| **Weather condition** | `Weather.getCurrentConditions().condition` | Weather |
| **Sunrise/Sunset** | `Weather.getSunrise/getSunset(loc, date)` | Weather |
| **Body battery** | `SensorHistory.getBodyBatteryHistory(...)` | SensorHistory |
| **Active minutes** | `ActivityMonitor.getInfo().activeMinutesDay` | None |
| **DND indicator** | `System.getDeviceSettings().doNotDisturb` | None |
| **Alarm count** | `System.getDeviceSettings().alarmCount` | None |

### Tier 3 - Enthusiast Features

| Data | API Call | Permission |
|---|---|---|
| **Stress level** | `ActivityMonitor.getInfo().stressScore` or SensorHistory | None / SensorHistory |
| **SpO2** | `SensorHistory.getOxygenSaturationHistory(...)` | SensorHistory |
| **Respiration rate** | `ActivityMonitor.getInfo().respirationRate` | None |
| **Altitude/Elevation** | `SensorHistory.getElevationHistory(...)` | SensorHistory |
| **Barometric pressure** | `SensorHistory.getPressureHistory(...)` | SensorHistory |
| **Wind speed/direction** | `Weather.getCurrentConditions().windSpeed/windBearing` | Weather |
| **Humidity** | `Weather.getCurrentConditions().relativeHumidity` | Weather |
| **Precipitation chance** | `Weather.getCurrentConditions().precipitationChance` | Weather |
| **UV Index** | `Weather.getCurrentConditions().uvIndex` (API 5.1) | Weather |
| **Recovery time** | `ActivityMonitor.getInfo().timeToRecovery` | None |
| **Battery days remaining** | `System.getSystemStats().batteryInDays` | None |
| **High/Low temperature** | `Weather.getCurrentConditions().highTemperature/lowTemperature` | Weather |
| **Weekly active minutes** | `ActivityMonitor.getInfo().activeMinutesWeek` | None |
| **VO2max** | `UserProfile.getProfile().vo2maxRunning` | UserProfile |
| **Move bar** | `ActivityMonitor.getInfo().moveBarLevel` | None |

### Tier 4 - Niche / Dive-Specific

| Data | API Call | Permission |
|---|---|---|
| **Temperature (sensor)** | `SensorHistory.getTemperatureHistory(...)` | SensorHistory |
| **Feels-like temp** | `Weather.getCurrentConditions().feelsLikeTemperature` | Weather |
| **Dew point** | `Weather.getCurrentConditions().dewPoint` (API 5.1) | Weather |
| **Cloud cover** | `Weather.getCurrentConditions().cloudCover` (API 5.1) | Weather |
| **Visibility** | `Weather.getCurrentConditions().visibility` (API 5.1) | Weather |
| **Weather pressure** | `Weather.getCurrentConditions().pressure` (API 5.1) | Weather |
| **Hourly forecast** | `Weather.getHourlyForecast()` | Weather |
| **Daily forecast** | `Weather.getDailyForecast()` | Weather |
| **HR zones** | `UserProfile.getHeartRateZones(sport)` | UserProfile |
| **Resting HR** | `UserProfile.getProfile().averageRestingHeartRate` | UserProfile |
| **Race predictions** | Complications API | None |
| **Training status** | Complications API | None |

---

## 15. Descent G2 Dive-Specific Notes

The Descent G2 is a dive computer with these built-in sensors:
- Depth sensor
- Temperature sensor
- 3-axis compass
- Gyroscope
- Barometric altimeter
- Pulse oximeter (SpO2)

### Dive Data in Connect IQ

**Important limitation:** Dive-specific data (current depth, water temperature, dive time, NDL, ascent rate, gas mix) is handled by the **native dive mode** firmware and is **NOT accessible through the Connect IQ API** on the watch face. Connect IQ watch faces only run on the surface, not during dives.

However, the following dive-adjacent data IS available:

| Data Point | How to Access | Notes |
|---|---|---|
| Surface temperature | `SensorHistory.getTemperatureHistory()` | Ambient temp, may reflect wrist temp |
| Barometric altitude | `SensorHistory.getElevationHistory()` | Useful for dive planning (altitude diving) |
| Barometric pressure | `SensorHistory.getPressureHistory()` | Weather/altitude context |
| SpO2 | `SensorHistory.getOxygenSaturationHistory()` | Surface-level pulse oximetry |
| Heart rate | `SensorHistory.getHeartRateHistory()` | Resting/surface HR |
| Body battery | `SensorHistory.getBodyBatteryHistory()` | Recovery status before dive |
| Recovery time | `ActivityMonitor.getInfo().timeToRecovery` | Post-activity recovery estimate |
| Stress | `SensorHistory.getStressHistory()` | Pre-dive stress assessment |

### Potential Dive-Themed Watch Face Features

For a Descent G2 watch face, consider highlighting:
- **Surface interval timer** (time since last dive, calculable if dive end time is stored)
- **Altitude** (important for altitude diving adjustments)
- **Weather/barometric pressure** (weather window for dive planning)
- **Body battery + recovery** (physical readiness indicator)
- **Sunrise/sunset** (dive planning, visibility)
- **UV index** (sun protection for boat days)
- **Water temperature** (from last sensor reading, if available in SensorHistory)

---

## Sources

- [Garmin Connect IQ API Docs - ActivityMonitor.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html)
- [Garmin Connect IQ API Docs - SensorHistory](https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html)
- [Garmin Connect IQ API Docs - Weather](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather.html)
- [Garmin Connect IQ API Docs - Weather.CurrentConditions](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather/CurrentConditions.html)
- [Garmin Connect IQ API Docs - Weather.HourlyForecast](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather/HourlyForecast.html)
- [Garmin Connect IQ API Docs - Weather.DailyForecast](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather/DailyForecast.html)
- [Garmin Connect IQ API Docs - System.DeviceSettings](https://developer.garmin.com/connect-iq/api-docs/Toybox/System/DeviceSettings.html)
- [Garmin Connect IQ API Docs - System.Stats](https://developer.garmin.com/connect-iq/api-docs/Toybox/System/Stats.html)
- [Garmin Connect IQ API Docs - UserProfile](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile.html)
- [Garmin Connect IQ API Docs - UserProfile.Profile](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile/Profile.html)
- [Garmin Connect IQ API Docs - Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- [Garmin Connect IQ API Docs - Sensor.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/Sensor/Info.html)
- [Garmin Connect IQ API Docs - Position](https://developer.garmin.com/connect-iq/api-docs/Toybox/Position.html)
- [Garmin Connect IQ API Docs - Activity.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity/Info.html)
- [Garmin Connect IQ Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Garmin Connect IQ Complications Core Topic](https://developer.garmin.com/connect-iq/core-topics/complications/)
- [Garmin Connect IQ Manifest and Permissions](https://developer.garmin.com/connect-iq/core-topics/manifest-and-permissions/)
- [Garmin Connect IQ Core Topics - Quantifying the User](https://developer.garmin.com/connect-iq/core-topics/quantifying-the-user/)
- [Garmin Forum - Watch Face Permissions Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/2068/question-about-location-sensors-and-other-things-inside-watchface)
- [Garmin Forum - Sunrise/Sunset Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/3078/sun-rise-sunset)
- [Garmin Forum - Device Memory Limits](https://forums.garmin.com/developer/connect-iq/f/discussion/257633/devices-memory-limit-for-a-watchface-widget-etc)
- [Crystal Face (GitHub)](https://github.com/warmsound/crystal-face)
- [Infocal Watch Face (GitHub)](https://github.com/RyanDam/Infocal)
- [Medium - ConnectIQ Manifest and Permissions](https://medium.com/@anderssonfilip/connnectiq-manifest-and-app-permissions-d8475ded767a)
