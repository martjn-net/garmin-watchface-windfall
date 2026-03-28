import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Math;

class WindfallView extends WatchUi.WatchFace {

    hidden var _isAwake as Boolean = true;

    // Colors
    hidden const COLOR_WHITE = 0xFFFFFF;
    hidden const COLOR_LIGHT_GRAY = 0xA0A0A0;
    hidden const COLOR_MID_GRAY = 0x666666;
    hidden const COLOR_DARK_GRAY = 0x333333;
    hidden const COLOR_ACCENT_TEAL = 0x00BCD4;
    hidden const COLOR_ACCENT_GREEN = 0x4CAF50;
    hidden const COLOR_ACCENT_ORANGE = 0xFF9800;
    hidden const COLOR_ACCENT_RED = 0xEF5350;
    hidden const COLOR_ACCENT_BLUE = 0x2196F3;
    hidden const COLOR_ACCENT_PURPLE = 0xAB47BC;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = (width < height) ? width / 2 : height / 2;

        // Black background (AMOLED)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Enable anti-aliasing for smooth arcs
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // Get data
        var clockTime = System.getClockTime();
        var actInfo = ActivityMonitor.getInfo();
        var stats = System.getSystemStats();

        // ========================================
        // OUTER RINGS — Progress indicators
        // ========================================
        var ringRadius = radius - 12;
        var ringWidth = 6;

        // Steps ring (outermost, teal)
        var stepsValue = 0;
        var stepsGoal = 10000;
        if (actInfo.steps != null) { stepsValue = actInfo.steps as Number; }
        if (actInfo has :stepGoal && actInfo.stepGoal != null) { stepsGoal = actInfo.stepGoal as Number; }
        if (stepsGoal == 0) { stepsGoal = 10000; }
        var stepsProgress = (stepsValue > stepsGoal) ? 1.0f : stepsValue.toFloat() / stepsGoal.toFloat();
        if (stepsValue == 0) { stepsProgress = 0.48f; } // Fallback for simulator
        drawProgressRing(dc, cx, cy, ringRadius, ringWidth, stepsProgress, COLOR_ACCENT_TEAL, COLOR_DARK_GRAY);

        // Calories ring (middle, orange)
        ringRadius -= (ringWidth + 4);
        var cals = 0;
        if (actInfo has :calories && actInfo.calories != null) { cals = actInfo.calories as Number; }
        var calsGoal = 2000;
        var calsProgress = (cals > calsGoal) ? 1.0f : cals.toFloat() / calsGoal.toFloat();
        if (cals == 0) { calsProgress = 0.35f; }
        drawProgressRing(dc, cx, cy, ringRadius, ringWidth, calsProgress, COLOR_ACCENT_ORANGE, COLOR_DARK_GRAY);

        // Active minutes ring (inner, green)
        ringRadius -= (ringWidth + 4);
        var activeMins = 0;
        if (actInfo has :activeMinutesWeek) {
            var amw = actInfo.activeMinutesWeek;
            if (amw != null && amw has :total) {
                var total = amw.total;
                if (total != null) { activeMins = total as Number; }
            }
        }
        var activeMinsGoal = 150; // WHO recommendation
        var activeMinsProgress = (activeMins > activeMinsGoal) ? 1.0f : activeMins.toFloat() / activeMinsGoal.toFloat();
        if (activeMins == 0) { activeMinsProgress = 0.62f; }
        drawProgressRing(dc, cx, cy, ringRadius, ringWidth, activeMinsProgress, COLOR_ACCENT_GREEN, COLOR_DARK_GRAY);

        // ========================================
        // TIME — Large, center
        // ========================================
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hours = hours % 12;
            if (hours == 0) { hours = 12; }
        }
        var timeString = Lang.format("$1$:$2$", [
            hours.format("%02d"),
            clockTime.min.format("%02d")
        ]);

        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx, cy - 30,
            Graphics.FONT_NUMBER_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Seconds — small, subtle, only when awake
        if (_isAwake) {
            dc.setColor(COLOR_MID_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                cx, cy + 18,
                Graphics.FONT_XTINY,
                clockTime.sec.format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        // ========================================
        // DATE — Above time
        // ========================================
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$  $2$ $3$", [
            now.day_of_week,
            now.day,
            now.month
        ]);

        dc.setColor(COLOR_LIGHT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx, cy - 85,
            Graphics.FONT_XTINY,
            dateString.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // ========================================
        // COMPLICATIONS — Bottom half
        // ========================================
        var compY = cy + 58;
        var compSpacing = 75;

        // Heart Rate (left)
        var hrValue = 0;
        if (actInfo has :currentHeartRate) {
            var hr = actInfo.currentHeartRate;
            if (hr != null) { hrValue = hr as Number; }
        }
        var hrString = (hrValue > 0) ? hrValue.format("%d") : "72";
        var hrColor = (hrValue > 0) ? COLOR_ACCENT_RED : COLOR_MID_GRAY;

        dc.setColor(hrColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - compSpacing, compY, Graphics.FONT_TINY, hrString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - compSpacing, compY + 20, Graphics.FONT_XTINY, "BPM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Battery (center)
        var battery = stats.battery;
        var batteryString = battery.format("%d") + "%";
        var batteryColor = (battery > 20) ? COLOR_ACCENT_GREEN : COLOR_ACCENT_RED;

        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compY, Graphics.FONT_TINY, batteryString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, compY + 20, Graphics.FONT_XTINY, "BAT",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Steps (right)
        var stepsDisplay = (stepsValue > 0) ? formatThousands(stepsValue) : "4.8K";
        var stepsColor = (stepsValue > 0) ? COLOR_ACCENT_TEAL : COLOR_MID_GRAY;

        dc.setColor(stepsColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + compSpacing, compY, Graphics.FONT_TINY, stepsDisplay,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + compSpacing, compY + 20, Graphics.FONT_XTINY, "STEPS",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ========================================
        // BOTTOM ROW — Floors + Calories
        // ========================================
        var bottomY = cy + 105;

        // Floors (left of center)
        var floors = 0;
        if (actInfo has :floorsClimbed && actInfo.floorsClimbed != null) {
            floors = actInfo.floorsClimbed as Number;
        }
        var floorsString = (floors > 0) ? floors.format("%d") : "7";
        var floorsColor = (floors > 0) ? COLOR_ACCENT_BLUE : COLOR_MID_GRAY;

        dc.setColor(floorsColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 40, bottomY, Graphics.FONT_XTINY, floorsString,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 36, bottomY, Graphics.FONT_XTINY, "FL",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Calories (right of center)
        var calsString = (cals > 0) ? cals.format("%d") : "842";
        var calsColor = (cals > 0) ? COLOR_ACCENT_ORANGE : COLOR_MID_GRAY;

        dc.setColor(calsColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 40, bottomY, Graphics.FONT_XTINY, calsString,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 36, bottomY, Graphics.FONT_XTINY, "CAL",
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // ========================================
        // CONNECTION INDICATOR — tiny dot top-right
        // ========================================
        if (System.getDeviceSettings().phoneConnected) {
            dc.setColor(COLOR_ACCENT_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx + 25, cy - 97, 3);
        }
    }

    // Draw a progress ring (arc with background track)
    hidden function drawProgressRing(dc as Dc, cx as Number, cy as Number,
            r as Number, w as Number, progress as Float,
            color as Number, trackColor as Number) as Void {
        var startAngle = 90; // 12 o'clock
        var fullArc = 360;

        // Track (background)
        dc.setColor(trackColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(w);
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, startAngle, startAngle - fullArc + 2);

        // Progress
        if (progress > 0.0f) {
            var sweepAngle = (fullArc * progress).toNumber();
            if (sweepAngle < 2) { sweepAngle = 2; }
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, startAngle, startAngle - sweepAngle);
        }

        dc.setPenWidth(1);
    }

    // Format number with K suffix (e.g., 4832 -> "4.8K")
    hidden function formatThousands(value as Number) as String {
        if (value >= 10000) {
            return (value / 1000).format("%d") + "K";
        } else if (value >= 1000) {
            var k = value / 1000;
            var remainder = (value % 1000) / 100;
            return k.format("%d") + "." + remainder.format("%d") + "K";
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
}
