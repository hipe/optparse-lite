jQuery(document).ready(function(){
  //alert("jquery loaded without error!?");

	var transformMe = $('#transform-me');
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
	$('#master-rapper .left-half').click(function(){
		rotateLeft();
	});
	$('#master-rapper .right-half').click(function(){
		rotateRight();
	});
});
