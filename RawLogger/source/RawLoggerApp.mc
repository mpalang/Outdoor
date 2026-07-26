import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Standard Connect IQ app entry point. Data field apps are thin -
// almost all the work happens in the View class.
class RawLoggerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Returns the data field view that gets shown on the activity screen
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new RawLoggerView() ];
    }
}

function getApp() as RawLoggerApp {
    return Application.getApp() as RawLoggerApp;
}
