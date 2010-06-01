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
		alert(msg); // @todo
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

	/**
	* construct this with a jquery selection that has your entire ligature
	* model, including svg.  Svg's must be in an element with a class 'backlay'
	*
	*/
	var LigatureManager = function(elems){
		if (elems.length != 1) return this.fail("LiagureManger won't run.");
		console.log("ligature manager LM"); LM = this;
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
			var res = null, i;
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
				for (i in this.listeningToThisDrag) {
					this.listeningToThisDrag[i].easeBackToHere(res);
				}
			}
			// 			this.now = this.start + ((this.end - this.start) * this.pos);
			return res;
		},
		drag: function(ui, event){
			// just part of ddmanager api, ignored for now
		},
		dragStart: function(event, ui){
			var thing = firstWordAssert(jQuery(event.target).attr('class'));
			this.setListenersForThing(thing, event, ui);
		},
		dragActual: function(e, ui){
			if (this.listeningToThisDrag) {
				var i;
				for (i in this.listeningToThisDrag) {
					this.listeningToThisDrag[i].thingDragged(e, ui);
				}
			}
		},
		// this is called after ease-back		
		dragStop: function(event, ui){
			if (!this.listeningToThisDrag) return null;
			var i;
			for (i in this.listeningToThisDrag) {
				this.listeningToThisDrag[i].thingDragStop(event, ui);
			}
			return null;
		},
		// part of ddmanager api
		drop: function(ui, event){
			if (this.listeningToThisDrag){
				var i;
				for(i in this.listeningToThisDrag){
					this.listeningToThisDrag[i].thingDrop(ui, event);
				}
			}
			return false; // i don't know but this is blah blah look at draggable
		},
		firstWordAssert: firstWordAssert,
		getThing: function(mixed){
			if (!this.mapIsSetup) { this.setupMap(); }
			var result = null;
			if (this.names[mixed]) {
				alert("implement me lskfjsliejflsa");
			} else {
				var these = this.elems.find('.'+mixed);
				if (these.length != 1) {
					return this.fail("couldn't find one "+mixed);
				}
				result = these;
			}
			return result;
		},
		// private
		addDragListener: function(thing, moveMe, subLig, e, ui){
			if (!this.listeningToThisDrag) {
				this.listeningToThisDrag = [];
			}
			var elem = jQuery(moveMe);
			var vizzleThing = null;
			if (elem.data('vizzleThing')) {
				vizzleThing = elem.data('vizzleThing');
			} else {
				vizzleThing = vizzleThingFactory(this, elem);
				elem.data('vizzleThing', vizzleThing);
			}
			vizzleThing.thingDragStart(thing, subLig, e, ui);
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
		mylert: function(msg){
			console.log(msg);
		},
		mylog: mylog,
		prepareOffsets: function(ui, event){
			// ignored for now, just part of ddmanager api
		},
		processLig: function(elem, md){
			var these = md[3].split('--'), part, md2;
			var ligs = [];			
			var ligRecord = {
				elem: elem
			};
			for (var i in these) {
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
		processName: function(elem, md){
			this.names[md[3]] = elem;
		},
		/*
		* you have the name of a thing that is moving.
		* setup listeners that will receive updates on the thing as it moves.
		*/
		setListenersForThing: function(thing, e, ui){
			if (!this.mapIsSetup) this.setupMap();
			var rec;
			this.listeningToThisDrag = null;
			if (undefined != (rec = this.ligs[thing])) {
				// for each ligs associated with this thing by this name,
				// grab the dom element and find its relationship with this thing
				var i, lig;
				for (i in rec.ligs) {
					lig = rec.ligs[i];
					var moveMe = lig.elem;
					var found = null;
					var j, subLig;
					for (j in lig.ligs) {
						if (lig.ligs[j][1] == thing) {
							if (found) {
								return this.fail("found > 1 association for "+thing);
							} else {
								found = true;
								subLig = lig.ligs[j];
							}
						}
					}
					if (! found) {
						return this.fail("fond 0 associations for el "+thing);
					}
					this.addDragListener(thing, moveMe, subLig, e, ui);
				}
			} else {
				// nullify something?
			}
			return null;
		},
		setupMap: function(){
			this.mapIsSetup = true;
			var bl = this.backlay();
			this.ligs = {};
			this.names = {};
			var self = this;
			this.backlay().find('path, circle').each(function(idx){
				var classesStr = this.getAttribute('class');
				if (!classesStr) return; // next
				classes = classesStr.split(' ');
				var i;
				for (i in classes) {
					var cls = classes[i], md;
					if (null != (md = /^(?:(name)|(lig))-(.+)$/.exec(cls))) {
						if (md[1]) {
							self.processName(this, md);
						} else {
							self.processLig(this, md);
						}
					} else {
						self.mylert("whuh: "+cls);
					}
				}
			});
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
				ret = new VizzleArc(mgr, elem);
			break;
			case 'c':
				ret = new VizzleCircle(mgr, elem);
			break;
		}
		return ret;
	};
	
	VizzleAbstract = {
		vizzleThingInit: function(mgr, elem){
			mylog("made a VizzleThing for <"+elem[0].nodeName+">");
			this.mgr = mgr;
			this.svgElem = elem;			
		},
		easeBackInit: function(){
			mylog("initting ease back");
		},		
		easeBackToHere: function(ratio){
			dx = this.distX * ( 1 - ratio );
			dy = this.distY * ( 1 - ratio );
			this.moveYourBody(dx, dy);
		},
		thingDragStart: function(thing, subLig, e, ui){
			var theThing = this.mgr.getThing(thing);
			this.theThing = theThing; // maybe, maybe not
			this.subLig = subLig;
			this.svgElemDragStart();			
			this.thingStartPosition = theThing.position();
		},
		// two ways to do this -- use a stored elem or the one in the event.
		thingDragged: function(e, ui){
			if (e.target != this.theThing[0]) {
				return this.fail("what happened here?");
			}
			var currentPos = 	this.theThing.position();
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
		mylog: mylog
	};
	
	VizzleArc = function(mgr, elem){
		this.vizzleThingInit(mgr, elem);
	};
	VizzleArc.prototype = jQuery.extend({}, VizzleAbstract, {
 		svgElemDragStart: function(){
 			this.arcPathHome = this.getArcPath();
			return null;
 		},
		thingDrop: function(ui, e){
			this.arcPathDrop = this.getArcPath();
			this.distX = this.arcPathDrop[1] - this.arcPathHome[1];
			this.distY = this.arcPathDrop[2] - this.arcPathHome[2];
		},
		// private
		arcRe: /^M (-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)( -?\d+(?:\.\d+)?,-?\d+(?:\.\d+)?)$/, 		
		getArcPath: function(){
			var md = this.arcRe.exec(this.svgElem.attr('d'));
			if (!md) return this.fail("failed: "+this.svgElem.attr('d'));
			md[1] = parseFloat(md[1]);
			md[2] = parseFloat(md[2]);
			return md;
		},		
		moveYourBody: function(dx, dy){
			var newD = 'M '+(this.arcPathHome[1]+dx)+','+(this.arcPathHome[2]+dy)+
			            this.arcPathHome[3];
			this.svgElem.attr('d',newD);
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
