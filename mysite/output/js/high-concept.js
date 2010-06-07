jQuery(document).ready(function(){
	var mgr = jQuery.vizzle.newLigatureManager(jQuery('#fig-2'));
	jQuery('.square.ruby').
		vizzle_when_you_mouseover_it_changes_color('#ff00dd');
	jQuery('.square.app').
		vizzle_when_you_mouseover_it_changes_color('#66bbff');
	jQuery('.square').draggable({
		containment: jQuery('#fig-2'),
		drag: function(e, ui){ return mgr.dragNotify(e, ui); },
		cursor: 'crosshair',
		opacity: 0.10, /* not working ? */
		revert: true,
		revertAnimationOpts: {
			queue:false,
			duration: 1000,
			easing: 'easeNandocCustomExperiment1'
		},
		scrollSensitivity: 0,
		scrollSpeed: 5,
		start: function(e, ui){ return mgr.dragStartNotify(e, ui); },
		stop: function(e, ui){ return mgr.dragStopNotify(e, ui); },
		zIndex: 1
	});
	jQuery.easing.easeNandocCustomExperiment1 = function (x, t, b, c, d) {
		return mgr.customEaseExperiment(x, t, b, c, d);
	};

	// ########## stuff for the slide controller #######################
	var slideMgr = jQuery.vizzle.newSlideManager(jQuery('#fig-2'));

	// ############### this is stuff for the several(?) "remote controls"
	jQuery('#fig-2 .step').vizzle_mouseenter({
		border: '2px solid #999999',
		color: '#333333',
		background: '#dddddd',
		width: '11px',
		height: '11px'
	});
	slideMgr.setSlideControls(jQuery('#fig-2 .slide-control'));
	slideMgr.setBalloonNextButtons(jQuery('#fig-2 .balloon .next'));

	// ############## the below chunk is just for animating the big button ####
	var frame = jQuery('#fig-2 .big-button-overlay .frame');
	var banner, thingsAreSet, arrowSvg, arrowBorder, arrow;
	var setThings = function(){
		banner = frame.find('.banner');
		arrowSvg = frame.find('.button-play .arrow-svg');
		var paths = frame.find('.button-play').find('path');
		arrowBorder = paths.first();
		arrow = paths.last();
		thingsAreSet = true;
	};
	frame.mouseenter(function(){
		if (!thingsAreSet) setThings();
		frame.css('background', '#aaaaaa');
		banner.css({
			background: '#ffffff',
			color:      '#999999'
		});
    arrowBorder.attr('fill', '#ffffff');
    arrow.attr('fill','#aaaaaa');
	});
	frame.mouseleave(function(){
		if (!thingsAreSet) setThings();
		frame.css('background', '#ffffff');
		banner.css({
			background: '#aaaaaa',
			color:      '#ffffff'
		});
    arrowBorder.attr('fill', '#aaaaaa');
    arrow.attr('fill','#ffffff');
	});
});
