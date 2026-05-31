import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class PeacelyView extends WatchUi.WatchFace {

    const THEME_SAGE = 0;
    const THEME_WARM = 1;
    const THEME_NIGHT = 2;

    var currentTheme = THEME_SAGE;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        drawBackground(dc);
        drawDate(dc);
        drawTime(dc);
        drawBattery(dc);
        drawSteps(dc);
    }

    function drawBackground(dc as Dc) as Void {
        var backgroundColor = getBackgroundColor();
        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();
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

    function drawBatteryIcon(dc as Dc, x as Number, y as Number, percent as Number) as Void {
        dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);

        dc.drawRectangle(x, y, 18, 10);
        dc.fillRectangle(x + 18, y + 3, 2, 4);

        var fillWidth = ((percent * 14) / 100).toNumber();

        dc.fillRectangle(x + 2, y + 2, fillWidth, 6);
    }

    function drawTime(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);

        dc.setColor(getPrimaryTextColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 4,
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
            dc.getHeight() / 2 - 62,
            Graphics.FONT_SMALL,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawBattery(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var battery = stats.battery.toNumber();

        var rowY = 22;
        var iconX = dc.getWidth() / 2 - 30;
        var iconY = rowY + 12;
        var textX = dc.getWidth() / 2 + 18;

        drawBatteryIcon(dc, iconX, iconY, battery);

        dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            textX,
            rowY,
            Graphics.FONT_XTINY,
            battery.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawSteps(dc as Dc) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps == null ? 0 : info.steps;

        var rowY = dc.getHeight() - 60;
        var iconX = dc.getWidth() / 2 - 22;
        var iconY = rowY + 14;
        var textX = dc.getWidth() / 2 + 12;

        var stepsIcon = getStepsIcon();
        dc.drawBitmap(iconX, iconY, stepsIcon);

        dc.setColor(getSecondaryTextColor(), Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            textX,
            rowY,
            Graphics.FONT_SMALL,
            steps.toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
}