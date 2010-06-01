jQuery(document).ready(function(){
	var mgr = jQuery.vizzle.newLigatureManager(jQuery('#fig-2'));
	jQuery('.square.ruby').vizzle_when_you_mouseover_it_changes_color('#ff00dd');
	jQuery('.square.app').vizzle_when_you_mouseover_it_changes_color('#66bbff');
	jQuery('.square').draggable({
		containment: jQuery('#fig-2'),
		drag: function(e, ui){ return mgr.dragActual(e, ui); },
		cursor: 'crosshair',
		opacity: 0.10, /* not working ? */
		revert: true,
		revertAnimationOpts: {
			complete: function(){ alert('com2'); },
			queue:false,
			duration: 1000,
			easing: 'easeNandocCustomExperiment1'
		},
		scrollSensitivity: 0,
		scrollSpeed: 5,
		start: function(e, ui){ return mgr.dragStart(e, ui); },
		stop: function(e, ui){ return mgr.dragStop(e, ui); },
		zIndex: 1
	});
	jQuery.easing.easeNandocCustomExperiment1 = function (x, t, b, c, d) {
		return mgr.customEaseExperiment(x, t, b, c, d);
	};
});
