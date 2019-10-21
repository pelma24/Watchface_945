using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.Graphics as Gfx;



class WatchfaceView extends WatchUi.WatchFace {

	var sleep = true;
	
	var background = null;
	var layer = null;
	var timeLayer = null;
	
	var bluetooth;
		
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	setLayout(Rez.Layouts.WatchFace(dc));
        
        bluetooth = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.bluetoothIcon,
        :locX=>100,
        :locY=>10
        });
        
        var settings = System.getDeviceSettings();
    	
    	var width = settings.screenWidth;
    	var height = settings.screenHeight;
        
        var clockFont = Graphics.FONT_NUMBER_THAI_HOT;
        var font = Graphics.FONT_MEDIUM;
        
        var clockFontHeight = Graphics.getFontHeight(clockFont);
        var clockFontWidth = clockFontHeight * 2 / 3;
        
        var fontHeight = Graphics.getFontHeight(font);
        var fontWidth = fontHeight * 2 / 3;
        
        var drawLayerWidth = fontWidth * 7;
          
        background = new WatchUi.Layer({}); 
        
        layer = new WatchUi.Layer({
            :locX => (width - drawLayerWidth) / 2,
            :locY => height / 3,
            :width => drawLayerWidth,
            :height => fontHeight + 50});
        
        addLayer(background);   
        addLayer(layer);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	
    	var info = ActivityMonitor.getInfo();
        var myStats = System.getSystemStats();
        var settings = System.getDeviceSettings();
    
        // Get and show the current time
		var backgroundDC = background.getDc();
		var layerDC = layer.getDc();
			
		backgroundDC.clear();
		
		var clockTime = System.getClockTime();
        var hourMinString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var secString = Lang.format( "$1$", [clockTime.sec.format("%02d")] );
        
        backgroundDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        backgroundDC.clear();
        
        backgroundDC.drawText(200, 50, Gfx.FONT_NUMBER_THAI_HOT, hourMinString, Gfx.TEXT_JUSTIFY_RIGHT);
			
		layerDC.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        layerDC.clear();
        
        var heartrate = "--";	
        	
        // get a HeartRateIterator object; oldest sample first
		var hrIterator = ActivityMonitor.getHeartRateHistory(1, false);
		var sample = hrIterator.next();                                   // get the previous HR

	    if (null != sample) {                                           // null check
	        if (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
	        	heartrate = sample.heartRate;
	        }
	    }
        
        //layerDC.drawText(0, 50, Gfx.FONT_MEDIUM, myStats.battery.format("%02d") + "%", Gfx.TEXT_JUSTIFY_LEFT);
		//layerDC.drawText(0, 50, Gfx.FONT_MEDIUM, info.steps + "/" + info.stepGoal, Gfx.TEXT_JUSTIFY_LEFT);                	
        //layerDC.drawText(0, 50, Gfx.FONT_MEDIUM, heartrate, Gfx.TEXT_JUSTIFY_LEFT);
        layerDC.drawText(0, 50, Gfx.FONT_MEDIUM, settings.notificationCount + " " + settings.phoneConnected, Gfx.TEXT_JUSTIFY_LEFT);
        
        bluetooth.draw(backgroundDC);
        
        drawStepsArc(settings, backgroundDC);
        drawBattery(backgroundDC);
    }

	function onPartialUpdate(dc) {
		
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    
    function drawBattery(dc) {
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	
    	dc.drawLine(100, 100, 140, 100);
    	dc.drawLine(100, 100, 100, 120);
    	dc.drawLine(100, 120, 140, 120);
    	dc.drawLine(140, 100, 140, 120);
    	
 		dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
    	
    	dc.fillRectangle(101, 101, 39, 19);
    	
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	
    	dc.drawText(105, 100, Gfx.FONT_XTINY, "100%", Gfx.TEXT_JUSTIFY_LEFT);
    }
    
    function drawStepsArc(settings, dc) {
        
        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
        
        dc.drawArc(settings.screenWidth / 2, settings.screenHeight / 2, settings.screenWidth / 2 - 3, Graphics.ARC_CLOCKWISE, 90, 90 - 0.75 * 360);
	}    
    
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {

    }

}
