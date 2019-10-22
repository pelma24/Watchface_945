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
	var secondsLayer = null;
	
	var bluetooth;
	var messages;
		
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	setLayout(Rez.Layouts.WatchFace(dc));
        
        bluetooth = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.bluetoothIcon,
        :locX=>80,
        :locY=>20
        });
        messages = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.messagesIcon,
        :locX=>145,
        :locY=>17
        });
        
        var settings = System.getDeviceSettings();
    	
    	var width = settings.screenWidth;
    	var height = settings.screenHeight;
        
        var clockFont = Graphics.FONT_NUMBER_THAI_HOT;
        var font = Graphics.FONT_MEDIUM;
        var smallFont = Gfx.FONT_SMALL;
        
        var clockFontHeight = Graphics.getFontHeight(clockFont);
        var clockFontWidth = clockFontHeight * 2 / 3;
        
        var smallFontHeight = Gfx.getFontHeight(smallFont);
        var smallFontWidth = smallFontHeight * 2 / 3;
        
        var fontHeight = Graphics.getFontHeight(font);
        var fontWidth = fontHeight * 2 / 3;
        
        var drawLayerWidth = fontWidth * 7.5;
          
        background = new WatchUi.Layer({}); 
        
        /*layer = new WatchUi.Layer({
            :locX => (width - drawLayerWidth) / 2,
            :locY => height / 3,
            :width => drawLayerWidth,
            :height => fontHeight + 50});
         */  
        secondsLayer = new WatchUi.Layer({
        	:locX => (width - drawLayerWidth) / 2 + drawLayerWidth,
        	:locY => height / 3,
        	:width => smallFontWidth * 2,
        	:height => smallFontHeight});
        
        addLayer(background);   
        //addLayer(layer);
        addLayer(secondsLayer);
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
    
        var backgroundDC = background.getDc();
		//var layerDC = layer.getDc();
		var secondsLayerDC = secondsLayer.getDc();
			
		backgroundDC.clear();
		secondsLayerDC.clear();
		//layerDC.clear();
		
		var clockTime = System.getClockTime();
		var today = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var hourString = Lang.format("$1$", [clockTime.hour]);
        var minString = Lang.format("$1$", [clockTime.min.format("%02d")]);
        var secString = Lang.format( "$1$", [clockTime.sec.format("%02d")] );
        
        backgroundDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        backgroundDC.clear();
        
        backgroundDC.drawText(settings.screenWidth / 2, settings.screenHeight / 4, Gfx.FONT_NUMBER_THAI_HOT, hourString, Gfx.TEXT_JUSTIFY_RIGHT);
		
		backgroundDC.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		backgroundDC.drawText(settings.screenWidth / 2, settings.screenHeight / 4, Gfx.FONT_NUMBER_THAI_HOT, minString, Gfx.TEXT_JUSTIFY_LEFT);
		
		
		
		//layerDC.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        //layerDC.clear();
        
        /*var heartrate = "--";	
        	
        // get a HeartRateIterator object; oldest sample first
		var hrIterator = ActivityMonitor.getHeartRateHistory(1, false);
		var sample = hrIterator.next();                                   // get the previous HR

	    if (null != sample) {                                           // null check
	        if (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
	        	heartrate = sample.heartRate;
	        }
	    }
        */
             	
        //layerDC.drawText(0, 50, Gfx.FONT_MEDIUM, heartrate, Gfx.TEXT_JUSTIFY_LEFT);
        //layerDC.drawText(0, 50, Gfx.FONT_MEDIUM, settings.notificationCount + " " + settings.phoneConnected, Gfx.TEXT_JUSTIFY_LEFT);
        
        if (settings.phoneConnected) {
        	bluetooth.draw(backgroundDC);
        }
        
 		drawNotifications(settings.notificationCount, backgroundDC);
        drawStepsArc(settings.screenWidth, settings.screenHeight, info.steps, info.stepGoal, backgroundDC);
        drawBattery(backgroundDC, myStats.battery);
        
        //seconds
        secondsLayerDC.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
        secondsLayerDC.drawText(0, 0, Gfx.FONT_SMALL, clockTime.sec.format("%02d"), Gfx.TEXT_JUSTIFY_LEFT);
    }

	function onPartialUpdate(dc) {
		
		var secondsDC = secondsLayer.getDc();
		secondsDC.clear();	
		var clockTime = System.getClockTime();
		
		secondsDC.drawText(0, 0, Gfx.FONT_SMALL, clockTime.sec.format("%02d"), Gfx.TEXT_JUSTIFY_LEFT);		
	}

    
    
    function drawBattery(dc, battery) {
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	dc.setPenWidth(1);
    	
    	dc.drawLine(100, 15, 140, 15);
    	dc.drawLine(100, 15, 100, 35);
    	dc.drawLine(100, 35, 140, 35);
    	dc.drawLine(140, 15, 140, 35);
    	
    	var rectangleFill = 38 * battery / 100.0;
    	
    	if (battery >= 50) {
 			dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
    	}
    	else if (battery >= 20) {
    		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
    	}
    	else {
    		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
    	}
    	
    	dc.fillRectangle(102, 17, rectangleFill, 17);
    	
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	
    	dc.drawText(105, 15, Gfx.FONT_XTINY, battery.format("%3d") + "%", Gfx.TEXT_JUSTIFY_LEFT);
    }
    
    function drawStepsArc(width, height, steps, stepGoal, dc) {
		steps = 5000;
		
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		
        dc.setPenWidth(3);
        
        var progress = steps.toFloat() / stepGoal;
        
        if (progress == 0) {
        	dc.drawLine(120, 0, 120, 8);
        	return;
        }        
        
        if (progress >= 1) {
        	progress = 1;
        	dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
        }
        else if (progress > 0.8 ) {
        	dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_BLACK);
        }        
        else {
        	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        }   
        
        dc.drawArc(width / 2, height / 2, width / 2 - 3, Graphics.ARC_CLOCKWISE, 90, 360 - (progress * 360 - 90));
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		
		dc.drawLine(120, 0, 120, 8);
	}
	
	function drawNotifications(notificationCount, dc) {

		if (notificationCount > 0) {
			if (notificationCount > 9) {
				notificationCount = "";
			}
			messages.draw(dc);
        	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        	dc.drawText(152, 17, Gfx.FONT_SYSTEM_XTINY, notificationCount, Gfx.TEXT_JUSTIFY_LEFT);
        }
	}    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {

    }

}
