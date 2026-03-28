import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Application;

class WindfallView extends WatchUi.WatchFace {

    hidden var _isAwake as Boolean = true;

    // Cached settings
    hidden var _stepsGoal as Number = 10000;
    hidden var _calsGoal as Number = 2000;
    hidden var _activeMinsGoal as Number = 150;

    // Colors — saturated for AMOLED
    hidden const COLOR_WHITE = 0xFFFFFF;
    hidden const COLOR_LIGHT_GRAY = 0xB0B0B0;
    hidden const COLOR_MID_GRAY = 0x606060;
    hidden const COLOR_DARK_GRAY = 0x333333;
    hidden const COLOR_RING_TRACK = 0x1A1A1A;
    hidden const COLOR_TEAL = 0x00D4D8;
    hidden const COLOR_GREEN = 0x30D158;
    hidden const COLOR_ORANGE = 0xFF9F0A;
    hidden const COLOR_RED = 0xFF453A;
    hidden const COLOR_BLUE = 0x0A84FF;
    hidden const COLOR_BATTERY = 0xCCCCCC;

    // AOD
    hidden const COLOR_AOD_TIME = 0x808080;
    hidden const COLOR_AOD_DATE = 0x444444;

    // Ring
    hidden const RING_INSET = 10;
    hidden const RING_WIDTH = 4;
    hidden const RING_GAP = 5;

    // Burn-in
    hidden const BI_X = [-3, -2, -1, 0, 1, 2, 3, 2, 1, 0, -1, -2];
    hidden const BI_Y = [0, 1, 2, 3, 2, 1, 0, -1, -2, -3, -2, -1];

    function initialize() {
        WatchFace.initialize();
        loadSettings();
    }

    function onLayout(dc as Dc) as Void {
    }

    hidden function loadSettings() as Void {
        var s = Application.Properties.getValue("StepsGoal");
        _stepsGoal = (s != null && s >= 1000) ? s as Number : 10000;
        var c = Application.Properties.getValue("CaloriesGoal");
        _calsGoal = (c != null && c >= 1000) ? c as Number : 2000;
        var a = Application.Properties.getValue("ActiveMinutesGoal");
        _activeMinsGoal = (a != null && a >= 30) ? a as Number : 150;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = (width < height) ? width / 2 : height / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var clockTime = System.getClockTime();

        if (_isAwake) {
            drawActiveMode(dc, cx, cy, radius, clockTime);
        } else {
            var idx = clockTime.min % 12;
            drawAodMode(dc, cx + BI_X[idx], cy + BI_Y[idx], clockTime);
        }
    }

    hidden function drawActiveMode(dc as Dc, cx as Number, cy as Number,
            radius as Number, clockTime as ClockTime) as Void {
        var actInfo = ActivityMonitor.getInfo();
        var stats = System.getSystemStats();

        // ========================================
        // ACTIVITY RINGS
        // ========================================
        var ringR = radius - RING_INSET;

        var stepsValue = 0;
        if (actInfo.steps != null) { stepsValue = actInfo.steps as Number; }
        var stepsProgress = (stepsValue > 0) ? calcProgress(stepsValue, _stepsGoal) : 0.48f;
        drawRing(dc, cx, cy, ringR, stepsProgress, COLOR_TEAL);

        ringR -= (RING_WIDTH + RING_GAP);
        var cals = 0;
        if (actInfo has :calories && actInfo.calories != null) { cals = actInfo.calories as Number; }
        var calsProgress = (cals > 0) ? calcProgress(cals, _calsGoal) : 0.35f;
        drawRing(dc, cx, cy, ringR, calsProgress, COLOR_ORANGE);

        ringR -= (RING_WIDTH + RING_GAP);
        var activeMins = 0;
        if (actInfo has :activeMinutesWeek) {
            var amw = actInfo.activeMinutesWeek;
            if (amw != null && amw has :total) {
                var total = amw.total;
                if (total != null) { activeMins = total as Number; }
            }
        }
        var activeMinsProgress = (activeMins > 0) ? calcProgress(activeMins, _activeMinsGoal) : 0.62f;
        drawRing(dc, cx, cy, ringR, activeMinsProgress, COLOR_GREEN);

        // ========================================
        // DATE
        // ========================================
        dc.setColor(COLOR_LIGHT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 85, Graphics.FONT_XTINY,
            formatDate(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ========================================
        // TIME
        // ========================================
        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 20, Graphics.FONT_NUMBER_MEDIUM,
            formatTime(clockTime),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Seconds
        dc.setColor(COLOR_MID_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 24, Graphics.FONT_XTINY,
            clockTime.sec.format("%02d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ========================================
        // COMPLICATIONS — row 1: HR | BAT | STEPS
        // ========================================
        var compY = cy + 65;
        var compSpacing = 75;

        // Heart Rate — always red (no ring, own color)
        var hrValue = 0;
        if (actInfo has :currentHeartRate) {
            var hr = actInfo.currentHeartRate;
            if (hr != null) { hrValue = hr as Number; }
        }
        dc.setColor(COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - compSpacing, compY, Graphics.FONT_TINY,
            (hrValue > 0) ? hrValue.format("%d") : "72",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - compSpacing, compY + 22, Graphics.FONT_XTINY, "BPM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Battery — silver, red when low
        var battery = stats.battery;
        dc.setColor((battery > 20) ? COLOR_BATTERY : COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compY, Graphics.FONT_TINY,
            battery.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compY + 22, Graphics.FONT_XTINY, "BAT",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Steps — teal (matches ring)
        dc.setColor(COLOR_TEAL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + compSpacing, compY, Graphics.FONT_TINY,
            (stepsValue > 0) ? formatThousands(stepsValue) : "4.8K",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + compSpacing, compY + 22, Graphics.FONT_XTINY, "STEPS",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ========================================
        // BOTTOM ROW — FL | CAL
        // ========================================
        var bottomY = cy + 120;

        // Floors — blue
        var floors = 0;
        if (actInfo has :floorsClimbed && actInfo.floorsClimbed != null) {
            floors = actInfo.floorsClimbed as Number;
        }
        dc.setColor(COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 40, bottomY, Graphics.FONT_XTINY,
            (floors > 0) ? floors.format("%d") : "7",
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 36, bottomY, Graphics.FONT_XTINY, "FL",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Calories — orange (matches ring)
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 40, bottomY, Graphics.FONT_XTINY,
            (cals > 0) ? cals.format("%d") : "842",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 36, bottomY, Graphics.FONT_XTINY, "CAL",
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Always-on: minimal, dimmed, burn-in offset
    hidden function drawAodMode(dc as Dc, cx as Number, cy as Number,
            clockTime as ClockTime) as Void {
        dc.setColor(COLOR_AOD_TIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 12, Graphics.FONT_NUMBER_MEDIUM,
            formatTime(clockTime),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_AOD_DATE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 35, Graphics.FONT_XTINY,
            formatDate(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ========================================
    // HELPERS
    // ========================================

    hidden function calcProgress(value as Number, goal as Number) as Float {
        return value.toFloat() / goal.toFloat();
    }

    hidden function drawRing(dc as Dc, cx as Number, cy as Number,
            r as Number, progress as Float, color as Number) as Void {
        var startAngle = 90;

        // Track
        dc.setColor(COLOR_RING_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(RING_WIDTH);
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, startAngle, startAngle - 358);
        dc.setPenWidth(1);

        if (progress <= 0.0f) { return; }

        var mainProgress = (progress > 1.0f) ? 1.0f : progress;
        var sweepDeg = (360 * mainProgress).toNumber();
        if (sweepDeg < 2) { sweepDeg = 2; }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(RING_WIDTH);
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, startAngle, startAngle - sweepDeg);
        dc.setPenWidth(1);

        // Overflow
        if (progress > 1.0f) {
            var overflow = progress - 1.0f;
            if (overflow > 1.0f) { overflow = 1.0f; }
            var ovDeg = (360 * overflow).toNumber();
            if (ovDeg < 2) { ovDeg = 2; }
            dc.setColor(dimmedColor(color), Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(RING_WIDTH);
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, startAngle, startAngle - ovDeg);
            dc.setPenWidth(1);
        }
    }

    hidden function dimmedColor(color as Number) as Number {
        var r = ((color >> 16) & 0xFF) / 2 + 0x40;
        var g = ((color >> 8) & 0xFF) / 2 + 0x40;
        var b = (color & 0xFF) / 2 + 0x40;
        return (r << 16) | (g << 8) | b;
    }

    hidden function formatTime(clockTime as ClockTime) as String {
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hours = hours % 12;
            if (hours == 0) { hours = 12; }
        }
        return Lang.format("$1$:$2$", [
            hours.format("%02d"),
            clockTime.min.format("%02d")
        ]);
    }

    hidden function formatDate() as String {
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        return Lang.format("$1$  $2$ $3$", [
            now.day_of_week, now.day, now.month
        ]).toUpper();
    }

    hidden function formatThousands(value as Number) as String {
        if (value >= 10000) {
            return (value / 1000).format("%d") + "K";
        } else if (value >= 1000) {
            return (value / 1000).format("%d") + "." + ((value % 1000) / 100).format("%d") + "K";
        }
        return value.format("%d");
    }

    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    function reloadSettings() as Void {
        loadSettings();
    }
}
