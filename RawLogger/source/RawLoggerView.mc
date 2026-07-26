import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.System;

// A Connect IQ Data Field that pulls as many raw sensor values as the
// device exposes and writes them into custom fields in the recorded
// FIT file, every time compute() runs (roughly once per second while
// an activity is recording).
//
// NOTE on limits: Garmin caps custom FitContributor data at 16 fields
// and 256 bytes total per FIT record. The fields below (7 x 4-byte
// floats/longs = 28 bytes) are well under that, leaving headroom if
// you want to add more later (e.g. wind, accelerometer).
class RawLoggerView extends WatchUi.DataField {

    // FitContributor.Field handles - created once in initialize()
    hidden var fieldRawPressure as FitContributor.Field?;
    hidden var fieldAmbientPressure as FitContributor.Field?;
    hidden var fieldMslPressure as FitContributor.Field?;
    hidden var fieldTemperature as FitContributor.Field?;
    hidden var fieldAltitude as FitContributor.Field?;

    // Last values, kept only so onUpdate() has something to draw
    hidden var lastAmbientPressure as Float?;
    hidden var lastRawPressure as Float?;

    function initialize() {
        DataField.initialize();

        // fieldId values just need to be unique small integers within
        // this app - they are NOT the same as standard FIT field IDs.
        fieldRawPressure = createField(
            "raw_pressure_pa",
            0,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "Pa" }
        );

        fieldAmbientPressure = createField(
            "ambient_pressure_pa",
            1,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "Pa" }
        );

        fieldMslPressure = createField(
            "msl_pressure_pa",
            2,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "Pa" }
        );

        fieldTemperature = createField(
            "temperature_c",
            3,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "C" }
        );

        fieldAltitude = createField(
            "altitude_m",
            4,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "m" }
        );
    }

function compute(info as Activity.Info) as Void {

    if (info has :ambientPressure && info.ambientPressure != null) {
        lastAmbientPressure = info.ambientPressure;
        if (fieldAmbientPressure != null) {
            fieldAmbientPressure.setData(info.ambientPressure);
        }
    }

    if (info has :altitude && info.altitude != null) {
        if (fieldAltitude != null) {
            fieldAltitude.setData(info.altitude);
        }
    }

    // Raw (unfiltered) pressure and mean-sea-level pressure are only
    // exposed via Sensor.getInfo(), which crashes in data fields -
    // so those two fields aren't obtainable this way. Ambient pressure
    // (filtered) and altitude are what's actually available here.
}

    // Minimal on-screen display so you can confirm it's working live -
    // shows the current raw and ambient pressure in Pa.
    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var ambientText = "Amb: --";
        if (lastAmbientPressure != null) {
            ambientText = "Amb: " + lastAmbientPressure.format("%.1f") + " Pa";
        }

        var rawText = "Raw: --";
        if (lastRawPressure != null) {
            rawText = "Raw: " + lastRawPressure.format("%.1f") + " Pa";
        }

        dc.drawText(
            width / 2, height / 2 - 10,
            Graphics.FONT_SMALL, ambientText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            width / 2, height / 2 + 10,
            Graphics.FONT_SMALL, rawText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
