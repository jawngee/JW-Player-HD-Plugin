
package com.jeroenwijering.plugins {


import com.jeroenwijering.events.*;

import flash.display.*;
import flash.events.Event;
import flash.text.TextField;

/**
* HD Plugin; implements an HD toggle.
**/
public class HD extends MovieClip implements PluginInterface {


	[Embed(source="../../../controlbar.png")]
	private const ControlbarIcon:Class;
	[Embed(source="../../../dock.png")]
	private const DockIcon:Class;


	/** Reference to the dock button. **/
	private var button:MovieClip;
	/** Initial bitrate check. **/
	private var checked:Boolean;
	/** List with configuration settings. **/
	public var config:Object = {
		bitrate:1500,
		autoswitch:false,
		file:undefined,
		fullscreen:false,
		state:true
	};
	/** Reference to the clip on stage. **/
	private var icon:Bitmap;
	/** reference to the original file. **/
	private var original:String;
	/** The curren position inside a video. **/
	private var position:Number = 0;
	/** Reference to the View of the player. **/
	private var view:AbstractView;


	/** Constructor; nothing going on. **/
	public function HD():void {};


	/** HD button is clicked, so change the video. **/
	private function clickHandler(evt:Event=null):void {
		config['state'] = !config['state'];
		view.config['autostart'] = true;
		reLoad();
		setUI();
	};


	/** The initialize call is invoked by the player View. **/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		original = view.config['file'];
		if(view.config['hd.file']) {
			config['file'] = view.config['hd.file'];
		}
		if(view.config['hd.bitrate']) {
			config['bitrate'] = view.config['hd.bitrate'];
		}
		if(view.config['hd.autoswitch']) {
			config['autoswitch'] = view.config['hd.autoswitch'];
		}
		if(config['state'] == true) {
			view.config['file'] = config['file'];
		}
		view.addModelListener(ModelEvent.META,metaHandler);
		view.addModelListener(ModelEvent.TIME,timeHandler);
		if(config['fullscreen']) {
			view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
		}
		if(view.getPlugin('dock') && view.config['dock']) {
			icon = new DockIcon();
			button = view.getPlugin('dock').addButton(icon,'is on',clickHandler);
		} else if (view.getPlugin('controlbar')) {
			icon = new ControlbarIcon();
			view.getPlugin('controlbar').addButton(icon,'hd',clickHandler);
		}
		setUI();
	};


	/** Reload the playlist with either the HD or default video. **/
	private function reLoad():void {
		var fil:String;
		if(config['state'] == false) {
			fil = original;
		} else {
			fil = config['file'];
		}
		if(view.playlist.length == 1) {
			view.config['file'] = fil;
			view.config['start'] = position;
			view.sendEvent('LOAD',view.config);
		} else {
			view.sendEvent('LOAD',fil);
		}
	};


	/** check the metadata for bandwidth. **/ 
	private function metaHandler(evt:ModelEvent):void {
		if(evt.data.bitrate) {
			config['bitrate'] = evt.data.bitrate;
		}
		if(evt.data.bandwidth && !checked) {
			checked = true;
			if(((evt.data.bandwidth < config['bitrate']) == config['state']) && (config['autoswitch'])) {
				clickHandler();
			}
		}
	};


	/** Upon resize, check for fullscreen switches. Switch the state if so. **/
	private function resizeHandler(evt:ControllerEvent):void {
		if(evt.data.fullscreen != config['state'] && view.config['state'] != ModelStates.IDLE) {
			clickHandler();
		}
	};


	/** Set the HD button state. **/
	private function setUI():void {
		if(config['state'] == false) {
			if(button) { 
				button.field.text = 'is off'; 
			} else {
			icon.alpha = 0.3;
			}
		} else {
			if(button) { 
				button.field.text = 'is on'; 
			} else {
				icon.alpha = 1;
			}
		}
	};


	/** Save the position inside a video. **/ 
	private function timeHandler(evt:ModelEvent):void {
		position = evt.data.position;
	};


};


}