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
	slideMgr.setSlideControlStyle('default', {
		mouseenter: {
			border: '2px solid #999999',
			color: '#333333',
			'background-color': '#dddddd',
			width: '11px',
			height: '11px'
		},
		current: {
			'background-color': '#ffffff',
			border: '2px solid #333333',
			color: '#333333'
		},
		obscured: {
			color: '#999999'
		}
	});
	slideMgr.setSlideControls(jQuery('#fig-2 .slide-control'), 'default');
	slideMgr.setBalloonNextButtons(jQuery('#fig-2 .balloon .next'));
	slideMgr.setSlideUrlParameterName('slide');

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


	// ### silly cute spin thing
	var transformMe = $('#thing-to-spin');
	var rotateThis, rotateThisNow;
	var rotating = false;
	var stopIt;
	var rotateLeft = function(){
		if (rotating) {
			stopIt();
		} else {
			rotateThis(transformMe, -360, 142, 50, 1500, 18);
		}
	};
	var rotateRight = function(){
		if (rotating) {
			stopIt();
		} else {
			rotateThis(transformMe, 360, 142, 50, 1500, 18);
		}
	};
	var stopIt = function(){
		rotateThisNow(transformMe, 0);
		rotating = false;
	};
	rotateThis = function(elem, angle, cx, cy, timespan, fps){
		if (rotating) { return; } // just sanity
		rotating = true;
		var msPerClick = 1000.0 / fps;
		var numClicks = timespan / msPerClick;
		var anglePerClick = (1.0 * angle) / numClicks;
		var thisAndTheNext;
		var currentAngle = 0.0;
		done = ( angle < 0 ) ?
		  function(){ return (currentAngle + anglePerClick) < angle; } :
		  function(){ return (currentAngle + anglePerClick) > angle; }
		thisAndTheNext = function(){
			if (done()) {
				stopIt();
			} else {
				currentAngle += anglePerClick;
				rotateThisNow(elem, currentAngle, cx, cy);
				setTimeout(function(){ thisAndTheNext(); }, msPerClick );
			}
		}
		thisAndTheNext();
	};
	rotateThisNow = function(elem, angle, cx, cy) {
		var transValue = "rotate("+angle+", "+cx+", "+cy+")"
		elem.attr('transform', transValue);
	};
	$('#fig-1 .left-half').click(function(){
		rotateLeft();
	});
	$('#fig-1 .right-half').click(function(){
		rotateRight();
	});
});
