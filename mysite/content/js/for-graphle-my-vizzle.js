(function(){
	jQuery.fn.vizzle_when_you_mouseover_it_changes_color = function(bgColor, opts) {
		var $ = jQuery;
	  return this.each(function(){
			var someFucker = $(this);
			var currentColor = someFucker.css('background-color');
			var highlight = function(){
				someFucker.css('background-color', bgColor);
			};
			var lowlight = function(){
				someFucker.css('background-color', currentColor);
			};
			someFucker.mouseenter(function(){
				highlight();
			});
			someFucker.mouseleave(function(){
				lowlight();
			});
	  });
	};
})();
