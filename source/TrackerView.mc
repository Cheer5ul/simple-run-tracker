import Toybox.Graphics;
import Toybox.WatchUi;

import Toybox.System;
import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.Position;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Lang;

class TrackerView extends WatchUi.View {

    public var isRun as Boolean;
    private var _session as Session?;
    private var _info as Activity.Info?;
    private var _distance as Float?;
    private var _timer as Timer.Timer?;
    private var _screenShape as ScreenShape?;

    private var _averageSpeed as String;
    private var _currentSpeed as String;
    private var _maxSpeed as String;
    private var _elapsedDistance as String;
    private var _averageHeartRate as String;
    private var _currentHeartRate as String;
    private var _maxHeartRate as String;
    private var _elapsedTime as Float;

    function initialize() {
        try {

        View.initialize();
        isRun = true;

        _averageSpeed = "0";
        _currentSpeed = "0";
        _maxSpeed = "0";
        _elapsedDistance = "0";
        _averageHeartRate = "0";
        _currentHeartRate = "0";
        _maxHeartRate = "0";
        _elapsedTime = 0.0;
        _screenShape = System.getDeviceSettings().screenShape;
        _session = ActivityRecording.createSession({
            :name => "Simple running",
            :sport => ActivityRecording.SPORT_RUNNING,
            :subSport => ActivityRecording.SUB_SPORT_STREET
        });
        if(_session has :setTimerEventListener){
            _session.setTimerEventListener(method(:onSessionTimer));
        }
        _session.start();
        }
        catch (e) {
            System.println("Error in Tracking init");
        }
    }

    function onSessionTimer(eventType as ActivityRecording.TimerEventType, eventData as Lang.Dictionary) as Void {
        try {
            switch(eventType) {
                case ActivityRecording.TIMER_EVENT_START: {
                    isRun = true;
                    break;
                }
                case ActivityRecording.TIMER_EVENT_STOP: {
                    isRun = false;
                    break;
                }
                case ActivityRecording.TIMER_EVENT_PAUSE: {
                    isRun = false;
                    break;
                }
                case ActivityRecording.TIMER_EVENT_RESUME: {
                    isRun = true;
                    break;
                }
                case ActivityRecording.TIMER_EVENT_LAP: {

                    break;
                }
                case ActivityRecording.TIMER_EVENT_RESET: {
                    
                    break;
                }
                case ActivityRecording.TIMER_EVENT_WORKOUT_STEP_COMPLETE: {
                    
                    break;
                }
                case ActivityRecording.TIMER_EVENT_NEXT_MULTISPORT_LEG: {
                    
                    break;
                }
            }
        }
        catch (e) {
            System.println("Error in onSessionTimer");
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, true);
    }

    public function isSessionRecording() as Boolean {
        if(_session != null){
            return _session.isRecording();
        }
        return false;
    }

    function onTimer() {
        try {
            if(isSessionRecording() && isRun){
                var localInfo = Activity.getActivityInfo();
                if(localInfo has :timerState){
                    if(localInfo.timerState == 3) {
                        _info = localInfo;
                        updateData(localInfo);
                        WatchUi.requestUpdate();
                    }
                }
                else {
                    _info = localInfo;
                    updateData(localInfo);
                    WatchUi.requestUpdate();
                }
            }
        }
        catch (e) {
            System.println("Error in onTimer");
        }
    }

    function updateData(info as Info) as Void {
        if(info) {
            System.println(info);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;

        dc.drawText(x, y, Graphics.FONT_TINY, "Tracking!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        _timer.stop();
        _timer = null;   
    }

    function onPosition(info as Info) {
        System.println("OnPosition");
    }

    function Stop() {
        isRun = false;
        if(Toybox has :ActivityRecording && isSessionRecording()){
            if(_session != null){
                _session.stop();
            }
        }
    }

    function Continue(){
        isRun = true;
        if(Toybox has :ActivityRecording && !isSessionRecording()){
            if(_session != null){
                _session.start();
            }
        }
        WatchUi.requestUpdate();
    }

    function Save(){
        isRun = false;
        if(Toybox has :ActivityRecording && !isSessionRecording()){
            if(_session != null){
                _session.save();
                _session = null;
            }
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function Remove(){
        isRun = false;
        if(Toybox has :ActivityRecording && !isSessionRecording()){
            if(_session != null){
                _session.discard();
                _session = null;
            }
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }
}
