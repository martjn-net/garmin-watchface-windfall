import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class WindfallApp extends Application.AppBase {

    hidden var _view as WindfallView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new WindfallView();
        return [_view];
    }

    function onSettingsChanged() as Void {
        if (_view != null) {
            _view.reloadSettings();
        }
        WatchUi.requestUpdate();
    }
}
