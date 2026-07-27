import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Activity;
import Toybox.FitContributor;

// Data field logging barometric pressure into custom FIT fields.
//
// All values come from Activity.Info, which is handed to compute()
// automatically. Sensor.getInfo() is NOT usable here - Garmin's docs
// state it crashes when called from a data field app.
//
// Field budget: 4 floats + 1 uint8 = 17 bytes, well under
// Garmin's 16-field / 256-byte FitContributor cap.
class RawLoggerView extends WatchUi.DataField {

    hidden var fieldRawPressure as FitContributor.Field?;
    hidden var fieldAmbientPressure as FitContributor.Field?;
    hidden var fieldMslPressure as FitContributor.Field?;
    hidden var fieldAltitude as FitContributor.Field?;
    hidden var fieldGpsAccuracy as FitContributor.Field?;

    // Last values for on-screen display
    hidden var lastRawPressure as Float?;
    hidden var lastAmbientPressure as Float?;
    hidden var lastGpsAccuracy as Number?;

    function initialize() {
        DataField.initialize();

        // fieldId values are unique small ints within this app only -
        // they are not standard FIT field numbers.
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

        fieldAltitude = createField(
            "altitude_m",
            3,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "m" }
        );

        // GPS fix quality, 0-4. UINT8 rather than FLOAT: it is a small
        // integer, and this costs 1 byte instead of 4.
        fieldGpsAccuracy = createField(
            "gps_accuracy",
            4,
            FitContributor.DATA_TYPE_UINT8,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "" }
        );
    }

    // Called ~once per second while an activity is recording.
    // Every field is null-guarded: Activity.Info fields can return
    // null before the sensor/GPS has settled.
    function compute(info as Activity.Info) as Void {

        // Temperature-compensated reading straight off the barometer.
        if (info has :rawAmbientPressure && info.rawAmbientPressure != null) {
            lastRawPressure = info.rawAmbientPressure;
            if (fieldRawPressure != null) {
                fieldRawPressure.setData(info.rawAmbientPressure);
            }
        }

        // Same measurement, two-stage filtered by the device.
        if (info has :ambientPressure && info.ambientPressure != null) {
            lastAmbientPressure = info.ambientPressure;
            if (fieldAmbientPressure != null) {
                fieldAmbientPressure.setData(info.ambientPressure);
            }
        }

        // Sea-level calibrated - needs a GPS fix first, so this stays
        // null until positioning settles.
        if (info has :meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
            if (fieldMslPressure != null) {
                fieldMslPressure.setData(info.meanSeaLevelPressure);
            }
        }

        if (info has :altitude && info.altitude != null) {
            if (fieldAltitude != null) {
                fieldAltitude.setData(info.altitude);
            }
        }

        // 0 = no accuracy value available, 4 = good fix. Useful later
        // as a QC channel for discarding records taken on a poor fix.
        if (info has :currentLocationAccuracy && info.currentLocationAccuracy != null) {
            lastGpsAccuracy = info.currentLocationAccuracy;
            if (fieldGpsAccuracy != null) {
                fieldGpsAccuracy.setData(info.currentLocationAccuracy);
            }
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var status = (fieldRawPressure == null) ? "NULL" : "OK";
        dc.drawText(
            dc.getWidth() / 2, dc.getHeight() / 2,
            Graphics.FONT_SMALL, status,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
