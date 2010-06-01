(function(){
	jQuery.fn.vizzle_when_you_mouseover_it_changes_color = function(bgColor, opts) {
	  return this.each(function(){
			var someFucker = jQuery(this);
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
	var VizzleThing = null; // forward declaration for class below
	var commonFailure = function(msg){
		throw new Error(msg);
	};
	var firstWordAssert = function(str){
		var md = /^[^ ]+/.exec(str);
		if (!md) {
			return this.fail("not string or empty string: "+str);
		}
		return md[0];
	};
	var mylog = function(msg){
		if (window.console && window.console.log) {
			window.console.log(msg);
		} else {
			// meh
		}
	};
	window.didTheseLerts = {};
	var mylert = function(msg){
		if (!window.didTheseLerts[msg]){
			alert(msg);
			window.didTheseLerts[msg] = true;
		} else {
			mylog(msg);
		}
	};
	/**
	* construct this with a jquery selection that has your entire ligature
	* model, including svg.  Svg's must be in an element with a class 'backlay'
	*
	*/
	var LigatureManager = function(elems){
		if (elems.length != 1) return this.fail("LiagureManger won't run.");
		this.mylog("ligature manager LM"); LM = this;
		this.elems = elems;
		if (jQuery.ui.ddmanager){
			return this.fail("for now LigatureManager wants to be the ddmanager");
		}
		jQuery.ui.ddmanager = this;
		return null;
	};
	var vizzleThingFactory = null;
	LigatureManager.prototype = {
		current: null, // the current draggable (just for ddmanager api)
		/**
		* @return btwn 0 & 1 float of where to be at this point
		*
		* @param x - what ratio from start to done
		* @param t - how much time has elapsed
		* @param b - dunno -- always zero?
		* @param c - dunno -- always one?
		* @param d - duration as per options
		*
		*/
		customEaseExperiment: function(x, t, b, c, d) {
			var res = null;
			if ((t/=d) < (1/2.75)) {
				res = c*(7.5625*t*t) + b;
			} else if (t < (2/2.75)) {
				res = c*(7.5625*(t-=(1.5/2.75))*t + 0.75) + b;
			} else if (t < (2.5/2.75)) {
				res = c*(7.5625*(t-=(2.25/2.75))*t + 0.9375) + b;
			} else {
				res = c*(7.5625*(t-=(2.625/2.75))*t + 0.984375) + b;
			}
			if (this.listeningToThisDrag) {
				var i = this.listeningToThisDrag.length;
				while (i--) {
					this.listeningToThisDrag[i].easeBackToHere(res);
				}
			}
			return res;
		},
		drag: function(ui, event){
			// just part of ddmanager api, ignored for now
		},
		dragStart: function(event, ui){
			var thingName = firstWordAssert(jQuery(event.target).attr('class'));
			this.setListenersForExternalThing(thingName, event, ui);
		},
		dragActual: function(e, ui){
			if (this.listeningToThisDrag) {
				var i = this.listeningToThisDrag.length;
				while (i--) {
					this.listeningToThisDrag[i].thingDragged(e, ui);
				}
			}
		},
		// this is called after ease-back
		dragStop: function(event, ui){
			if (!this.listeningToThisDrag) return null;
			var i = this.listeningToThisDrag.length;
			while (i--) {
				this.listeningToThisDrag[i].thingDragStop(event, ui);
			}
			return null;
		},
		// part of ddmanager api
		drop: function(ui, event){
			if (this.listeningToThisDrag){
				var i = this.listeningToThisDrag.length;
				while (i--) {
					this.listeningToThisDrag[i].thingDrop(ui, event);
				}
			}
			return false; // i don't know but this is blah blah look at draggable
		},
		firstWordAssert: firstWordAssert,
		getLiggedVizzleThings: function(thingName){
			var pairs = [], rec, lig;
			if ((rec = this.getLigsRecord(thingName))) {
				var i = rec.ligs.length;
				while (i--) {
					lig = rec.ligs[i];
					var vizzleThing = this.getVizzleThingForDomElement(lig.elem);
					var subLig = this.findRelevantLig(lig, thingName);
					pairs.push([vizzleThing, subLig[0], subLig[1]]);
				}
			}
			return pairs;
		},
		getThing: function(thingName){
			if (!this.mapIsSetup) this.setupMap();
			var result = null;
			if (this.nameToElem[thingName]) {
				alert("implement me lskfjsliejflsa");
			} else {
				var these = this.elems.find('.'+thingName);
				if (these.length != 1) {
					return this.fail("couldn't find one "+thingName);
				}
				result = these;
			}
			return result;
		},
		// private
		addDragListener: function( vizzleThing ){
			if (!this.listeningToThisDrag) this.listeningToThisDrag = [];
			this.listeningToThisDrag.push( vizzleThing );
		},
		backlay: function(){
			if (!this.backlayElems) {
				this.backlayElems = this.elems.find('.backlay');
				if (this.backlayElems.length != 1 ) {
					return this.fail("one backlay not found");
				}
			}
			return this.backlayElems;
		},
		fail: commonFailure,
		getLigsRecord: function(thingName){
			if (!this.mapIsSetup) this.setupMap();
			return this.ligs[thingName]; // null ok ?
		},
		getVizzleThingForDomElement: function(ordinaryElement){
			var elem = jQuery(ordinaryElement);
			var vizzleThing = null;
			if (elem.data('vizzleThing')) {
				vizzleThing = elem.data('vizzleThing');
			} else {
				vizzleThing = vizzleThingFactory(this, elem);
				elem.data('vizzleThing', vizzleThing);
			}
			return vizzleThing;
		},
		findRelevantLig: function(lig, thingName){
			var found = null;
			var j, subLig, subLigIdx;
			j = lig.ligs.length;
			while (j--) {
				if (lig.ligs[j][1] == thingName) {
					if (found) {
						return this.fail("found > 1 association for "+thingName);
					} else {
						found = true;
						subLig = lig.ligs[j];
						subLigIdx = j;
					}
				}
			}
			if (! found) {
				return this.fail("found 0 associations for el "+thingName);
			}
			return [subLig, subLigIdx];
		},
		mylog: mylog,
		mylert: mylert,
		prepareOffsets: function(ui, event){
			// ignored for now, just part of ddmanager api
		},
		processLig: function(elem, md, lastName){
			var these = md[3].split('--'), part, md2;
			var ligs = [];
			var ligRecord = {
				elem: elem
			};
			for (var i = 0; i < these.length; i++ ){ // need to go ascending for ligs!
				part = these[i];
				if (null == (md2 = /^(?:(pos-)|(tail-))(.+)$/.exec(part))) {
					return this.fail("bad lig element: "+part);
				}
				var thingName = md2[3];
				if (! this.ligs[thingName] ) this.ligs[thingName] = {ligs:[]};
				this.ligs[thingName].ligs.push(ligRecord);
				if (md2[1]) {
					ligs.push(['pos', md2[3]]);
				} else {
					ligs.push(['tail', md2[3]]);
				}
			}
			ligRecord['ligs'] = ligs;
			return null;
		},
		/*
		* you have the name of a thing that is moving.
		* setup listeners that will receive updates on the thing as it moves.
		*/
		setListenersForExternalThing: function(thingName, e, ui){
			this.listeningToThisDrag = null;
			var pairs = this.getLiggedVizzleThings(thingName);
			var i = pairs.length;
			while (i--) {
				var pair = pairs[i];
				var vizzleThing = pair[0];
				var subLig = pair[1];
				var subLigIdx = pair[2];
				vizzleThing.thingDragStart(thingName, subLig, subLigIdx);
				this.addDragListener(vizzleThing);
			}
			return null;
		},
		setupMap: function(){
			this.mapIsSetup = true;
			var bl = this.backlay();
			this.ligs = {};
			this.nameToElem = {};
			var foundThese = this.backlay().find('path, circle');
			var i = foundThese.length;
			var elem;
			while (i--) {
				elem = foundThese[i];
				var classesStr = elem.getAttribute('class');
				if (!classesStr) continue;
				classes = classesStr.split(' ');
				for (var j = classes.length; j--; ) {
					var cls = classes[j], md;
					var lastName = null;
					if (null != (md = /^(?:(name)|(lig))-(.+)$/.exec(cls))) {
						if (md[1]) {
							lastName = md[3];
							this.nameToElem[md[3]] = elem;
						} else {
							this.processLig(elem, md, lastName);
						}
					} else {
						// we will almost certainly want to ignore non-magic class names one day
						// but for now we bark
						this.mylog("whuh: "+cls);
					}
				}
			}
			return null;
		}
	};
	vizzleThingFactory = function(mgr, elem){
		var specialClass = firstWordAssert(elem.attr('class'));
		var md;
		if (!(md = /^name-((a|c).+)$/.exec(specialClass))) {
			return commonFailure("class name not special: "+specialClass);
		}
		var ret;
		switch(md[2]){
			case 'a':
				ret = new VizzleArc(mgr, elem, md[1]);
			break;
			case 'c':
				ret = new VizzleCircle(mgr, elem, md[1]);
			break;
		}
		return ret;
	};
	VizzleAbstract = {
		vizzleThingInit: function(mgr, elem, name){
			this.mylog("made a VizzleThing for <"+elem[0].nodeName+"> ("+name+")");
			this.mgr = mgr;
			this.name = name;
			this.svgElem = elem;
		},
		easeBackInit: function(){
			this.mylog("initting ease back");
		},
		easeBackToHere: function(ratio){
			dx = this.distX * ( 1 - ratio );
			dy = this.distY * ( 1 - ratio );
			this.moveYourBody(dx, dy);
		},
		thingDragStart: function(thingNameOrThing, subLig, subLigIdx){
			var theThing = ('object'==typeof(thingNameOrThing)) ?
			  thingNameOrThing : this.mgr.getThing(thingNameOrThing);
			this.trackingThisThing = theThing; // maybe, maybe not
			this.subLig = subLig;
			this.subLigIdx = subLigIdx;
			this.svgElemDragStart();
			this.thingStartPosition = theThing.position();
		},
		// two ways to do this -- use a stored elem or the one in the event.
		thingDragged: function(e, ui){
			if (e && (e.target != this.trackingThisThing[0])) {
				return this.fail("what happened here?");
			}
			var currentPos = 	this.trackingThisThing.position();
			var dx = currentPos.left - this.thingStartPosition.left;
			var dy = currentPos.top - this.thingStartPosition.top;
			if (dx || dy) {
				this.moveYourBody(dx, dy);
			}
			return null;
		},
		thingDragStop: function(e, ui){
			this.moveYourBody(0, 0);
		},
		// private
		fail: commonFailure,
		mylert: mylert,
		mylog: mylog
	};
	VizzleArc = function(mgr, elem, name){
		this.vizzleThingInit(mgr, elem, name);
	};
	var f = '-?\\d+(?:\\.\\d+)?';
	VizzleArc.ReHead = new RegExp('^M ('+f+'),('+f+')( '+f+','+f+')$');
	VizzleArc.ReTail = new RegExp('^(M '+f+','+f+' )('+f+'),('+f+')$');
	VizzleArc.prototype = jQuery.extend({}, VizzleAbstract, {
 		svgElemDragStart: function(){
			switch(this.subLigIdx){
				case 0:
					this.getArcPath = this.getArcPathHead;
					this.moveYourBody = this.moveYourBodyHead;
				break;
				case 1:
					this.getArcPath = this.getArcPathTail;
					this.moveYourBody = this.moveYourBodyTail;
				break;
				default:
					this.fail("unexpected sublig index: "+this.subLigIdx);
			}
 			this.arcPathHome = this.getArcPath();
			return null;
 		},
		thingDrop: function(ui, e){
			this.arcPathDrop = this.getArcPath();
			this.distX = this.arcPathDrop[1] - this.arcPathHome[1];
			this.distY = this.arcPathDrop[2] - this.arcPathHome[2];
		},
		// private
		getArcPathHead: function(){
			var md = VizzleArc.ReHead.exec(this.svgElem.attr('d'));
			if (!md) return this.fail("failed for head: "+this.svgElem.attr('d'));
			md[1] = parseFloat(md[1]);
			md[2] = parseFloat(md[2]);
			return md;
		},
		getArcPathTail: function(){
			var md = VizzleArc.ReTail.exec(this.svgElem.attr('d'));
			if (!md) return this.fail("failed for tail: "+this.svgElem.attr('d'));
			md[2] = parseFloat(md[2]);
			md[3] = parseFloat(md[3]);
			return md;
		},
		moveYourBodyHead: function(dx, dy){
			var newD = 'M '+(this.arcPathHome[1]+dx)+','+(this.arcPathHome[2]+dy)+
			            this.arcPathHome[3];
			this.svgElem.attr('d',newD);
			return null;
		},
		moveYourBodyTail: function(dx, dy){
			var newD = this.arcPathHome[1] + (this.arcPathHome[2]+dx)+','+
					(this.arcPathHome[3]+dy);
			this.svgElem.attr('d',newD);
			return null;
		}
	});
	/**
	* for now a circle must have exactly one position
	* listener: the attached arc.
	*/
	VizzleCircle = function(mgr, elem, name){
		this.positionListener = null;
		this.vizzleThingInit(mgr, elem, name);
	};
	VizzleCircle.prototype = jQuery.extend({}, VizzleAbstract, {
		position: function(){
			return this.getCirclePosition();
		},
 		svgElemDragStart: function(){
 			this.circlePosHome = this.getCirclePosition();
			var things = this.mgr.getLiggedVizzleThings(this.name);
			if (things.length != 1){
				return this.fail("don't want "+things.length+" things for now: "+this.name);
			}
			var vizzle = things[0][0];
			var subLig = things[0][1];
			var subLigIdx = things[0][2];
			vizzle.thingDragStart(this, subLig, subLigIdx);
			this.positionListener = vizzle;
			return null;
 		},
		thingDrop: function(ui, e){
			this.circlePosDrop = this.getCirclePosition();
			this.distX = this.circlePosDrop.left - this.circlePosHome.left;
			this.distY = this.circlePosDrop.top - this.circlePosHome.top;
		},
		// private
		getCirclePosition: function(){
			var x = parseFloat(this.svgElem.attr('cx'));
			var y = parseFloat(this.svgElem.attr('cy'));
			return {left: x, top: y};
		},
		moveYourBody: function(dx, dy){
			var newX = this.circlePosHome.left + dx;
			var newY = this.circlePosHome.top + dy;
			this.svgElem.attr('cx', newX);
			this.svgElem.attr('cy', newY);
			if (this.positionListener) {
				this.positionListener.moveYourBody(dx, dy);
			}
			return null;
		}
	});
	// public api
	jQuery.vizzle = {
		newLigatureManager: function(x){
			return new LigatureManager(x);
		}
	};
})();
