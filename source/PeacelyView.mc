import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.SensorHistory;
import Toybox.Application;

class PeacelyView extends WatchUi.WatchFace {

    const THEME_SAGE = 0;
    const THEME_WARM = 1;
    const THEME_NIGHT = 2;

    const METRIC_STEPS = 0;
    const METRIC_HEART_RATE = 1;

var currentTheme = THEME_SAGE;
var currentMetric = METRIC_STEPS;
var currentTimeFormat = 0;

    function initialize() {
        WatchFace.initialize();
    }

    function loadSettings() as Void {
    var app = Application.getApp();

    currentTheme = (app.getProperty("theme") as Number);
    currentMetric = (app.getProperty("metric") as Number);
    currentTimeFormat = (app.getProperty("timeFormat") as Number);

    if (currentTheme == null) {
        currentTheme = THEME_SAGE;
    }

    if (currentMetric == null) {
        currentMetric = METRIC_STEPS;
    }

    if (currentTimeFormat == null) {
        currentTimeFormat = 0;
    }
}

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
    loadSettings();

    drawBackground(dc);
    drawDate(dc);
    drawTime(dc);
    drawBattery(dc);
    drawBottomMetric(dc);
}

    

    function drawBackground(dc as Dc) as Void {
    var backgroundColor = getBackgroundColor();
    dc.setColor(backgroundColor, backgroundColor);
    dc.clear();

    var background;

    if (currentTheme == THEME_WARM) {
        background = WatchUi.loadResource(Rez.Drawables.WarmBackground) as BitmapResource;
    } else if (currentTheme == THEME_NIGHT) {
        background = WatchUi.loadResource(Rez.Drawables.NightBackground) as BitmapResource;
    } else {
        background = WatchUi.loadResource(Rez.Drawables.SageBackground) as BitmapResource;
    }

    dc.drawBitmap(0, 0, background);
}

    function getBackgroundColor() as Number {
        if (currentTheme == THEME_WARM) {
            return 0xE8D6BC;
        }

        if (currentTheme == THEME_NIGHT) {
            return 0x1A2024;
        }

        return 0xB8C8B2;
    }

    function getPrimaryTextColor() as Number {
        if (currentTheme == THEME_WARM) {
            return 0x5A351E;
        }

        if (currentTheme == THEME_NIGHT) {
            return 0xC8C9CC;
        }

        return 0x243428;
    }

    function getSecondaryTextColor() as Number {
        if (currentTheme == THEME_WARM) {
            return 0x9A7A58;
        }

        if (currentTheme == THEME_NIGHT) {
            return 0x8E9296;
        }

        return 0x4B5C50;
    }

    function getStepsIcon() {
        if (currentTheme == THEME_WARM) {
            return WatchUi.loadResource(Rez.Drawables.StepsWarm);
        }

        if (currentTheme == THEME_NIGHT) {
            return WatchUi.loadResource(Rez.Drawables.StepsNight);
        }

        return WatchUi.loadResource(Rez.Drawables.StepsSage);
    }

    function getHeartIcon() {
    if (currentTheme == THEME_WARM) {
        return WatchUi.loadResource(Rez.Drawables.HeartWarm);
    }

    if (currentTheme == THEME_NIGHT) {
        return WatchUi.loadResource(Rez.Drawables.HeartNight);
    }

    return WatchUi.loadResource(Rez.Drawables.HeartSage);
}

    function drawBatteryIcon(dc as Dc, x as Number, y as Number, percent as Number) as Void {
    dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);

    dc.drawRectangle(x, y, 22, 12);
    dc.fillRectangle(x + 22, y + 4, 3, 4);

    var fillWidth = ((percent * 18) / 100).toNumber();

    dc.fillRectangle(x + 2, y + 2, fillWidth, 8);
}

    function drawTime(dc as Dc) as Void {
    var clockTime = System.getClockTime();
    var hour = clockTime.hour;

    if (currentTimeFormat == 1) {
        hour = hour % 12;

        if (hour == 0) {
            hour = 12;
        }
    }

    var timeString = Lang.format("$1$:$2$", [
        hour.format("%02d"),
        clockTime.min.format("%02d")
    ]);

    dc.setColor(getPrimaryTextColor(), Graphics.COLOR_TRANSPARENT);
    dc.drawText(
        dc.getWidth() / 2,
        dc.getHeight() / 2 - 14,
        Graphics.FONT_NUMBER_HOT,
        timeString,
        Graphics.TEXT_JUSTIFY_CENTER
    );
}

    function drawDate(dc as Dc) as Void {
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

        var dateString = Lang.format("$1$ $2$", [
            dayNames[dateInfo.day_of_week - 1],
            dateInfo.day
        ]);

        dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 74,
            Graphics.FONT_SMALL,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawBattery(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var battery = stats.battery.toNumber();

        var rowY = 22;
        var iconX = dc.getWidth() / 2 - 42;
        var iconY = rowY + 19;
        var textX = dc.getWidth() / 2 + 22;

        drawBatteryIcon(dc, iconX, iconY, battery);

        dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            textX,
            rowY,
            Graphics.FONT_SMALL,
            battery.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawSteps(dc as Dc) as Void {
    var info = ActivityMonitor.getInfo();
    var steps = info.steps == null ? 0 : info.steps;
    var stepsString = steps.toString();

    drawBottomMetricRow(dc, getStepsIcon(), stepsString);
}

function drawBottomMetricRow(dc as Dc, icon, valueText as String) as Void {
    var rowY = dc.getHeight() - 60;

    var iconWidth = 24;
    var gap = 10;

    var textFont = Graphics.FONT_SMALL;
    var textWidth = dc.getTextWidthInPixels(valueText, textFont);

    var totalWidth = iconWidth + gap + textWidth;
    var startX = (dc.getWidth() - totalWidth) / 2;

    var iconX = startX;
    var iconY = rowY + 14;

    var textX = startX + iconWidth + gap + (textWidth / 2);

    dc.drawBitmap(iconX, iconY, icon);

    dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);

    dc.drawText(
        textX,
        rowY,
        textFont,
        valueText,
        Graphics.TEXT_JUSTIFY_CENTER
    );
}

function drawBottomMetric(dc as Dc) as Void {
    if (currentMetric == METRIC_HEART_RATE) {
        drawHeartRate(dc);
    } else {
        drawSteps(dc);
    }
}

function drawHeartRate(dc as Dc) as Void {
    var heartRateString = "--";

    var iterator = SensorHistory.getHeartRateHistory({
        :period => 1,
        :order => SensorHistory.ORDER_NEWEST_FIRST
    });

    var sample = iterator.next();

    if (sample != null && sample.data != null) {
        heartRateString = sample.data.toNumber().toString();
    }

    drawBottomMetricRow(dc, getHeartIcon(), heartRateString);
}

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
}