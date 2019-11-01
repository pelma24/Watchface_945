using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.Graphics as Gfx;

class WatchfaceView extends WatchUi.WatchFace {
	
	var background = null;
	var secondsLayer = null;
	var secondsText;
	
	var bluetooth;
	var messages;
	var alarm;
	var moon;
	var stepsIcon;
	
	var screenHeight;
	var screenWidth;
		
	var font;
	var font2;
		
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    
    	setLayout(Rez.Layouts.WatchFace(dc));
        
        font = WatchUi.loadResource(Rez.Fonts.Arial);
        font2 = WatchUi.loadResource(Rez.Fonts.Franklin);
        
        bluetooth = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.bluetoothIcon,
        :locX=>83,
        :locY=>18
        });
        messages = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.messagesIcon,
        :locX=>147,
        :locY=>17
        });
        
        secondsText = new WatchUi.Text({
        	:text=>"",
            :color=>Graphics.COLOR_RED,
            :font=>Graphics.FONT_SMALL,
            :locX =>0,
            :locY=>0
            });
        
        alarm = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.alarmIcon,
        :locX=>60,
        :locY=>30,
        });
        
        moon = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.moonIcon,
        :locX=>175,
        :locY=>30,
        });
        
        stepsIcon = new WatchUi.Bitmap({
        :rezId=>Rez.Drawables.stepsIcon,
        :locX=>70,
        :locY=>180,
        });
        
        var settings = System.getDeviceSettings();
    	
    	screenWidth = settings.screenWidth;
    	screenHeight = settings.screenHeight;
        
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
        	:locX => (screenWidth - drawLayerWidth) / 2 + drawLayerWidth + 5,
        	:locY => screenHeight / 2.5 + 5,
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
        var stats = System.getSystemStats();
        var settings = System.getDeviceSettings();
    	
        var backgroundDC = background.getDc();
		//var layerDC = layer.getDc();
		var secondsLayerDC = secondsLayer.getDc();
			
		backgroundDC.clear();
		secondsLayerDC.clear();
		//layerDC.clear();
		
		var clockTime = System.getClockTime();
		var today = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var hourString = Lang.format("$1$", [clockTime.hour.format("%02d")]);
        var minString = Lang.format("$1$", [clockTime.min.format("%02d")]);
        
        backgroundDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        backgroundDC.clear();
        //hour
        backgroundDC.drawText(screenWidth / 2 - 9, screenHeight / 4, font2, hourString, Gfx.TEXT_JUSTIFY_RIGHT);
		//minutes
		backgroundDC.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		backgroundDC.drawText(screenWidth / 2 -1, screenHeight / 4, font2, minString, Gfx.TEXT_JUSTIFY_LEFT);
		//seconds
        secondsText.setText(clockTime.sec.format("%02d"));
        secondsText.draw(secondsLayerDC);
        
        if (settings.phoneConnected) {
        	bluetooth.draw(backgroundDC);
        }
        
 		drawNotifications(settings.notificationCount, backgroundDC);
        drawStepsArc(info.steps, info.stepGoal, backgroundDC);
        drawBattery(backgroundDC, stats.battery, stats.charging);
        drawDate(today, backgroundDC);
        drawAlarm(settings.alarmCount, backgroundDC);
        
        if (settings.doNotDisturb) {
        	moon.draw(backgroundDC);
        }        
        
        stepsIcon.draw(backgroundDC);
        backgroundDC.drawText(112, 165, Gfx.FONT_SYSTEM_TINY, info.steps + " /", Gfx.TEXT_JUSTIFY_LEFT);
        backgroundDC.drawText(112, 190, Gfx.FONT_SYSTEM_TINY, info.stepGoal, Gfx.TEXT_JUSTIFY_LEFT);
    }

	function onPartialUpdate(dc) {
		
		var secondsDC = secondsLayer.getDc();
		secondsDC.clear();
		var clockTime = System.getClockTime();
		
		secondsText.setText(clockTime.sec.format("%02d"));
		secondsText.draw(secondsDC);
		//secondsDC.drawText(0, 0, Gfx.FONT_SMALL, clockTime.sec.format("%02d"), Gfx.TEXT_JUSTIFY_LEFT);		
	}

    
    
    function drawBattery(dc, battery, charging) {
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	dc.setPenWidth(1);
    	
    	dc.drawLine(100, 15, 140, 15);
    	dc.drawLine(100, 15, 100, 35);
    	dc.drawLine(100, 35, 140, 35);
    	dc.drawLine(140, 15, 140, 35);
    	dc.drawArc(140, 25, 4, Gfx.ARC_CLOCKWISE, 90, 270);
    	    	
    	var rectangleFill = 38 * battery / 100.0;
    	
    	if (charging) {
    		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
    	}
    	else if (battery >= 50) {
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
    
    function drawStepsArc(steps, stepGoal, dc) {		
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		
        dc.setPenWidth(4);
        
        var progress = steps.toFloat() / stepGoal;   
		
		if (progress >= 1) {
			var count = steps / stepGoal;
			switch (count) {
		        		case 1:
		        		dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
		        		break;
		        		case 2:
		        		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
		        		break;
		        		case 3:
		        		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
		        		break;
		        		case 4:
		        		dc.setColor(Gfx.COLOR_PURPLE, Gfx.COLOR_BLACK);
		        		break;
		        		default:
		        		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		     }
		     
		     dc.drawArc(screenWidth / 2, screenHeight / 2, screenWidth / 2 - 3, Graphics.ARC_CLOCKWISE, 90, 90);
		     
		     progress = (steps % stepGoal).toFloat() / stepGoal;
		}
	    if (progress > 0.8 ) {
        	dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
        }        
        else {
        	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        }   
        
        if (progress != 0) {
        	dc.drawArc(screenWidth / 2, screenHeight / 2, screenWidth / 2 - 3, Graphics.ARC_CLOCKWISE, 90, 360 - (progress * 360 - 90));
        }
        
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
        	dc.drawText(154, 16, Gfx.FONT_SYSTEM_XTINY, notificationCount, Gfx.TEXT_JUSTIFY_LEFT);
        }
	}
	
	function drawDate(today, dc) {
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(120, screenHeight / 5, Gfx.FONT_SMALL, today.day_of_week + " " + today.day + " " + today.month, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function drawAlarm(alarmCount, dc) {
		if (alarmCount == 0) {
			return;
		}
		alarm.draw(dc);
	}
	
	
	 
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	background = null;
		secondsLayer = null;
		secondsText = null;
	
		bluetooth = null;
		messages = null;
		alarm = null;
		moon = null;
		stepsIcon = null;
		screenHeight = null;
		screenWidth = null;
    	
    	View.onHide();
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {

    }
}
