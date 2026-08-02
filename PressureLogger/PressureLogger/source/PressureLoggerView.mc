import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.FitContributor;

class PressureLoggerView extends WatchUi.DataField {

    hidden var mValue as Number;
    hidden var mCounterField as FitContributor.Field?;
    hidden var mRawField as FitContributor.Field?;
    hidden var mAmbientField as FitContributor.Field?;
    hidden var mMslField as FitContributor.Field?;
    hidden var mLastRaw as Float?;

    function initialize() {
        DataField.initialize();
        mValue = 0;
        mCounterField = createField("", 0, FitContributor.DATA_TYPE_UINT16, { 
            :mesgType => FitContributor.MESG_TYPE_RECORD });

        mRawField = createField(
            "raw_pressure", 1, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "Pa" }
        );
        mAmbientField = createField(
            "ambient_pressure", 2, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "Pa" }
        );
        mMslField = createField(
            "msl_pressure", 3, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "Pa" }
        );
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label") as Text;
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 7;
        }

        (View.findDrawableById("label") as Text).setText(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        mValue = mValue + 1;
        if (mCounterField != null) {
        mCounterField.setData(mValue);
        }

        if (info has :rawAmbientPressure && info.rawAmbientPressure != null) {
            mLastRaw = info.rawAmbientPressure;
            if (mRawField != null) {
                mRawField.setData(info.rawAmbientPressure);
            }
        }

        if (info has :ambientPressure && info.ambientPressure != null) {
            if (mAmbientField != null) {
                mAmbientField.setData(info.ambientPressure);
            }
        }

        if (info has :meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
            if (mMslField != null) {
                mMslField.setData(info.meanSeaLevelPressure);
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }

        var status = (mCounterField == null) ? "NULL " : "OK ";
        value.setText(status + mValue.toString());

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
}
