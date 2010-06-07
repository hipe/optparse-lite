(function(){
	jQuery.fn.vizzle_when_you_mouseover_it_changes_color =
		function(bgColor, opts) {
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

	jQuery.fn.vizzle_mouseenter = function(newStyle){
		return this.each(function(){
			var someFucker = jQuery(this);
			var coolStyle = {};
			for (var i in newStyle) {
				coolStyle[i] = someFucker.css(i);
			}
			someFucker.mouseenter(function(){
				someFucker.css(newStyle);
			});
			someFucker.mouseleave(function(){
				someFucker.css(coolStyle);
			});
		});
	};

	// common methods used in classes like mixins
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
	/*
	* this was prettier as an extension to regexp but safari doesn't want
	* us to extend regexp objects
	*/
	var MyRegExp = function(re, name){
		if ('string'==typeof(re)) re = new RegExp(re);
		this.regexp = re;
		this.name = name;
	};
	MyRegExp.prototype = {
		someName: function(){
			return this.name ? this.name : this.regexp;
		},
		execAssert: function(str){
			var md = this.regexp.exec(str);
			if (!md) {
				return commonFailure("failed to match "+this.someName()+
					" against "+str
				);
			}
			return md;
		}
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
		* adapted from George McGinley Smith's work
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
		dragNotify: function(e, ui){
			if (this.listeningToThisDrag) {
				var i = this.listeningToThisDrag.length;
				while (i--) {
					this.listeningToThisDrag[i].dragNotify(e, ui);
				}
			}
		},
		// called by hooks into jquery ui draggable
		dragStartNotify: function(event, ui){
			var thingName = firstWordAssert(jQuery(event.target).attr('class'));
			this.setListenersForExternalThing(thingName, event, ui);
		},
		// called after ease-back by hook into jquery ui draggable
		dragStopNotify: function(event, ui){
			if (!this.listeningToThisDrag) return null;
			var i = this.listeningToThisDrag.length;
			while (i--) {
				this.listeningToThisDrag[i].dragStopNotify(event, ui);
			}
			return null;
		},
		// part of ddmanager api
		drop: function(ui, event){
			if (this.listeningToThisDrag) {
				var i = this.listeningToThisDrag.length;
				while (i--) {
					this.listeningToThisDrag[i].dropNotify(ui, event);
				}
			}
			return false; // i don't know but this is blah blah look at draggable
		},
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
		getThingElement: function(thingName){
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
			// need to go ascending for ligs!
			for (var i = 0; i < these.length; i++ ){
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
				vizzleThing.dragStartNotify(thingName, subLig, subLigIdx);
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
						// it's ok for lig svg elements to have non-magic classnames
					}
				}
			}
			return null;
		}
	};
	vizzleThingFactory = function(mgr, elem){
		var specialClass = firstWordAssert(elem.attr('class'));
		var md;
		if (!(md = /^name-((a|c|r).+)$/.exec(specialClass))) {
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
			case 'r':
			  ret = new VizzleRidgidBody(mgr, elem, md[1]);
			break;
		}
		return ret;
	};
	var VizzleThingAbstract = {
		vizzleThingInit: function(mgr, elem, name){
			this.mylog("made a VizzleThing for <"+elem[0].nodeName+"> ("+name+")");
			this.mgr = mgr;
			this.name = name;
			this.svgElem = elem;
		},
		dragStartNotify: function(thingNameOrThing, subLig, subLigIdx){
			var theThing = ('object'==typeof(thingNameOrThing)) ?
				thingNameOrThing : this.mgr.getThingElement(thingNameOrThing);
			this.trackingThisThing = theThing; // maybe, maybe not
			this.subLig = subLig;
			this.subLigIdx = subLigIdx;
			this.svgElemDragStart();
			this.thingStartPosition = theThing.position();
		},
		easeBackToHere: function(ratio){
			dx = this.distX * ( 1 - ratio );
			dy = this.distY * ( 1 - ratio );
			this.moveYourBody(dx, dy);
		},
		// two ways to do this -- use a stored elem or the one in the event.
		dragNotify: function(e, ui){
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
		dragStopNotify: function(e, ui){
			this.moveYourBody(0, 0);
		},
		// private
		fail: commonFailure,
		mylert: mylert,
		mylog: mylog
	};

	// in graph theory 'arc' is the thing that connects two nodes
	VizzleArc = function(mgr, elem, name){
		this.vizzleThingInit(mgr, elem, name);
	};
	var F = '-?\\d+(?:\\.\\d+)?'; // used in several places in this file
	VizzleArc.ReHead = new MyRegExp('^M ('+F+'),('+F+')(.*)$', 'ReHead');
	VizzleArc.ReTail = new MyRegExp('^(M .*?)('+F+'),('+F+')$', 'ReTail');

	VizzleArc.prototype = jQuery.extend({}, VizzleThingAbstract, {
		// name needs to correspond to jquery selection method name
		position: function(){
			this.fail("do we use this?");
		},
		svgElemDragStart: function(){
			switch(this.subLigIdx){
				case 0:
					this.getPathData = this.getPathDataHead;
					this.moveYourBody = this.moveYourHead;
					this.pathData = this.getPathData();
					this.posHome = {left: this.pathData[1], top: this.pathData[2]};
					this.posNow = {};
				break;
				case 1:
					this.getPathData = this.getPathDataTail;
					this.moveYourBody = this.moveYourTail;
					this.pathData = this.getPathData();
					this.posHome = {left: this.pathData[2], top: this.pathData[3]};
					this.posNow = {};
				break;
				default:
					this.fail("unexpected sublig index: "+this.subLigIdx);
			}
			return null;
		},
		// called by lig manager
	 	dropNotify: function(ui, e){
			this.distX = this.posNow.left - this.posHome.left;
			this.distY = this.posNow.top - this.posHome.top;
			return null;
		},
		// private
		getPathDataHead: function(){
			var md = VizzleArc.ReHead.execAssert(this.svgElem.attr('d'));
			md[1] = parseFloat(md[1]);
			md[2] = parseFloat(md[2]);
			return md;
		},
		getPathDataTail: function(){
			var md = VizzleArc.ReTail.execAssert(this.svgElem.attr('d'));
			md[2] = parseFloat(md[2]);
			md[3] = parseFloat(md[3]);
			return md;
		},
		moveYourHead: function(dx, dy){
			this.posNow.left = this.posHome.left + dx;
			this.posNow.top = this.posHome.top + dy;
			var pathData = 'M ' + (this.posNow.left) + ',' + (this.posNow.top) +
				this.pathData[3];
			this.svgElem.attr('d',pathData);
			return null;
		},
		moveYourTail: function(dx, dy){
			this.posNow.left = this.posHome.left + dx;
			this.posNow.top = this.posHome.top + dy;
			var pathData = this.pathData[1] +
				(this.posNow.left)+','+(this.posNow.top);
			this.svgElem.attr('d',pathData);
			return null;
		}
	});
	// might be shared among ridgid bodies
	// for now it only wants to work with one listener
	var setPositionListenersAndNotifyOfDragStart = function(){
		var things = this.mgr.getLiggedVizzleThings(this.name);
		if (things.length != 1){
			return this.fail("Why did we get "+things.length+" things connected "+
			  "to " + this.name + "? Want exactly one.");
		}
		var vizzle = things[0][0];
		var subLig = things[0][1];
		var subLigIdx = things[0][2];
		vizzle.dragStartNotify(this, subLig, subLigIdx);
		this.positionListener = vizzle;
		return null;
	};

	/**
	* for now a circle must have exactly one position
	* listener: the attached arc.
	*/
	VizzleCircle = function(mgr, elem, name){
		this.vizzleThingInit(mgr, elem, name);
	};
	VizzleCircle.prototype = jQuery.extend({}, VizzleThingAbstract, {
		positionListener: null,
		dropNotify: function(ui, e){
			posDrop = this.getPosition();
			this.distX = posDrop.left - this.posHome.left;
			this.distY = posDrop.top - this.posHome.top;
		},
		// name needs to correspond to jquery selection method name
		position: function(){
			return this.posNow ? this.posNow : this.getPosition();
		},
		svgElemDragStart: function(){
			this.posHome = this.getPosition();
			this.setPositionListenersAndNotifyOfDragStart();
		},
		// private
		getPosition: function(){
			this.posNow.left = parseFloat(this.svgElem.attr('cx'));
			this.posNow.top = parseFloat(this.svgElem.attr('cy'));
			// either here or in caller you have to make the below a dup not orig
			return { left: this.posNow.left, top: this.posNow.top };
		},
		moveYourBody: function(dx, dy){
			this.posNow.left = this.posHome.left + dx;
			this.posNow.top = this.posHome.top + dy;
			this.svgElem.attr('cx', this.posNow.left);
			this.svgElem.attr('cy', this.posNow.top);
			if (this.positionListener) {
				this.positionListener.moveYourBody(dx, dy);
			}
			return null;
		},
		posNow: {},
		setPositionListenersAndNotifyOfDragStart:
			setPositionListenersAndNotifyOfDragStart
	});
	VizzleRidgidBody = function(mgr, elem, name){
		if (elem[0].nodeName != 'path') {
			return this.fail("bad element type for rigid body:"+elem[0].nodeName);
		}
		this.positionListener = null;
		this.vizzleThingInit(mgr, elem, name);
		return null;
	};
	VizzleRidgidBody.re = new MyRegExp(
		'^M ('+F+'),('+F+')(.+)$', 'rigid body D attr regexp'
	);

	VizzleRidgidBody.prototype = jQuery.extend({}, VizzleThingAbstract, {
		position: function(){
			return this.posNow ? this.posNow : this.getPosition();
		},
		svgElemDragStart: function(){
			this.getPosition(); // set posNow!
			this.posHome = {left: this.posNow.left, top: this.posNow.top};
			this.setPositionListenersAndNotifyOfDragStart();
		},
		// private
		getPosition: function(){
			if (!this.posNow) this.posNow = {};
			var md = this.getPathData();
			this.posNow.left = md[1];
			this.posNow.top = md[2];
			return this.posNow;
		},
		getPathData: function(){
			var md = VizzleRidgidBody.re.execAssert(this.svgElem.attr('d'));
			md[1] = parseFloat(md[1]);
			md[2] = parseFloat(md[2]);
			this.lastPathData = md;
			return md;
		},
		// @api private, called by dragNotify
		moveYourBody: function(dx, dy){
			this.posNow.left = this.posHome.left + dx;
			this.posNow.top = this.posHome.top + dy;
			var newPathData = 'M ' + this.posNow.left + ',' +
				this.posNow.top + this.lastPathData[3];
			this.svgElem.attr('d', newPathData);
			if (this.positionListener) {
				this.positionListener.moveYourBody(dx, dy);
			}
		},
		setPositionListenersAndNotifyOfDragStart:
			setPositionListenersAndNotifyOfDragStart,
		dropNotify: function(ui, e){
			this.distX = this.posNow.left - this.posHome.left;
			this.distY = this.posNow.top - this.posHome.top;
		}
	});
	var SlideManager = function(elems){
		this.elems = elems;
		this.slideManagerInit();
	};
	// not special because no need to assert
	SlideManager.reSlide = new MyRegExp(/\bslide-(\d+)(-only)?/, 'slide');
	SlideManager.reStep = new MyRegExp(/\bstep-(\d+)/, 'step');
	SlideManager.recognizedThings = ['current', 'obscured', 'mouseenter'];
	SlideManager.prototype = {
		setBalloonNextButtons: function(jqElems){
			var self = this;
			jqElems.click(function(){
				self.balloonNextButtonClicked(this);
			});
		},
		setSlideControls: function(jqElems){
			var self = this;
			var stepJqElems = jqElems.find('.step');
			stepJqElems.click(function(){self.stepButtonClick(this);});
			stepJqElems.mouseenter(function(){self.stepButtonMouseenter(this);});
			stepJqElems.mouseleave(function(){self.stepButtonMouseleave(this);});
			this.slideControls = jqElems;
		},
		setSlideControlStyle: function(name, stuffs){
			for (i in stuffs) { // todo are there goddam set operations?
				if (-1 == SlideManager.recognizedThings.indexOf(i))
					return this.fail("not ok kind of thing: "+i);
			}
			if (!this.slideControlStyles) this.slideControlStyles = {};
			if (this.slideControlStyles[name]) return this.fail("no: "+name);
			this.slideControlStyles[name] = stuffs;
			return null;
		},
		slideManagerInit: function(){
			this.playButtonOverlay = this.elems.find('.big-button-overlay');
			mylog("PBO"); PBO = this.playButtonOverlay;
			this.frame = this.playButtonOverlay.find('.frame');
			var self = this;
			this.frame.click(function(e){
				self.playWasClicked(e);
			});
		},
		// ############### private #######################
		balloonNextButtonClicked: function(butt){
			var jqButt = jQuery(butt);
			var classes = jqButt.parent().attr('class');
			var md = SlideManager.reSlide.execAssert(classes);
			var slideNumber = parseInt(md[1],10);
			var stepNumberOfThisSlide = this.slideNumberToStepNumber(slideNumber);
			var nextStepNumber = stepNumberOfThisSlide + 1;
			this.goToStep(nextStepNumber);
		},
		fail: commonFailure,
		// ignoring semi-opaque crap for now
		goToStep: function(step){
			if ('number' != typeof(step)) return this.fail("not a number: "+step);
			if (!this.mapIsSetup) this.setupSlideMap();
			this.stepButtonChangeButtonsPerCurrent(step);
			var slideNumberIndex = step - 1;
			if (slideNumberIndex < 0 ||
				slideNumberIndex >= this.slideNumbers.length
			) {
				return this.fail("invalid step number: "+step);
			}
			this.currentStepNumber = step;//after stepButtonChangeButtonsPerCurrent
			this.elementsToShow = [];
			this.elementsToHide = [];
			var i, j, k, rec, jqEl, isVisible, showIt;
			var last = this.slideNumbers.length - 1;
			for (i=0; i<=last; i++) { // could be faster, more code
				j = this.slideNumbers[i];
				k = this.slides[j].length;
				while (k--) {
					rec = this.slides[j][k];
					jqEl = rec.jqElem;
					isVisible = ('none' != jqEl.css('display'));
					showIt = null;
					if (rec.only) {
						if (i == slideNumberIndex) {
							if (!isVisible) showIt = true;
						} else {
							if (isVisible) showIt = false;
						}
					} else if (i <= slideNumberIndex) {
						if (!isVisible) showIt = true;
					} else {
						if (isVisible) showIt = false;
					}
					if (null!==showIt) {
						this[showIt ? 'elementsToShow' : 'elementsToHide'].push(jqEl[0]);
					}
				}
			}
			// hide all visible elements who have
			this.runTransition();
			return null;
		},
		mapIsSetup: false,
		mylog: mylog,
		playWasClicked: function(e){
			var pbo = this.playButtonOverlay;
			var self = this;
			tardNuggetFadeTo(pbo,
				444, 0.0, function(){
					pbo.css('display','none');
					self.goToStep(1);
				}
			);
		},
		runTransition: function(){
			var hideThese = jQuery(this.elementsToHide);
			var showThese = jQuery(this.elementsToShow);
			tardNuggetFadeTo(hideThese, 444, 0.0, function(){
				hideThese.css('display','none'); }
			);
			showThese.css('display', 'block');
			tardNuggetSetOpacity(showThese, 0.0);
			tardNuggetFadeTo(showThese, 444, 1.0);
		},
		/**
		* with each and every element we do this crap b/c a) we can't easily crawl
		* into svg elements with jquery selectors and b) it's too much visual
		* noise to say 'class ="slide slide-1"'
		* @post set this.slides and this.slideNumbers
		* we don't like that we are creating an individual jqElem array object for
		* each individual element but a) we need to use it to get the css.display
		* style attribute value and b) we can't group these together yet b/c their
		* individual visibility will change
		*/
		setupSlideMap: function(){
			this.mylog("setting up map");
			this.mapIsSetup = true;
			var all = this.elems.find('*'), matched = [],
				re = SlideManager.reSlide.regexp;
			var i = all.length;
			this.slides = [];
			this.slideNumbers = [];
			while (i--) {
				if (!(md=re.exec(all[i].getAttribute('class')))) continue;
				var slideIdx = parseInt(md[1], 10);
				if (!this.slides[slideIdx]) {
					this.slides[slideIdx] = [];
					this.slideNumbers.push(slideIdx);
				}
				// although opacity is all whacked up with jqElem.css('opacity'),
				// we need to use jqElem to read 'display':'none' so we incur this
				// overhead
				var record = {jqElem : jQuery(all[i])};
				if (md[2]) { record.only = true; }
				this.slides[slideIdx].push(record);
			}
			this.slideNumbers.sort(function(a,b){ return a - b; });
		},
		slideNumberToStepNumber: function(slideNumber){
			var num;
			if (-1 == (num = this.slideNumbers.indexOf(slideNumber))) {
				return this.fail("no slides for slide number "+slideNumber);
			}
			return num + 1; // index to count
		},
		// currentStepNumber is ok
		stepButtonChangeButtonsPerCurrent: function(newStepNumber){
			if (!this.storedUnfuctButtonStyles) this.stepButtonStoreUnfuctStyles();
			if (newStepNumber == this.currentStepNumber) return null;
			if ('number'==typeof(this.currentStepNumber)){
				this.stepButtonMulticastStyleRevert(
					this.currentStepNumber, 'beforeCurrent'
				);
			}
			var useThisStyle = this.slideControlStyles['default']['current'];
			if (!useThisStyle) return null;
			this.stepButtonMulticastStyleChange(
				newStepNumber, useThisStyle, 'beforeCurrent'
			);
			this.stepButtonObscurity(newStepNumber);
			return null;
		},
		stepButtonClick: function(stepEl){
			if (!this.mapIsSetup) this.setupMap();
			this.stepButtonMouseleave(stepEl);
			var step = this.stepNumberFromElement(stepEl);
			if (this.currentStepNumber == step) return null;
			this.goToStep(step);
			return null;
		},
		stepButtonMouseenter: function(stepEl){
			var step = this.stepNumberFromElement(stepEl);
			if (this.currentStepNumber == step) return null;
			var useStyles = this.slideControlStyles['default'];
			if (!useStyles) return null;
			var useStyle = useStyles.mouseenter;
			if (!useStyle) return null;
			this.stepButtonMulticastStyleChange(step, useStyle, 'beforeMouseenter');
			return null;
		},
		// careful this is called at click to restore styles!
		stepButtonMouseleave: function(stepEl){
			var step = this.stepNumberFromElement(stepEl);
			if (this.currentStepNumber == step) return null;
			this.stepButtonMulticastStyleRevert(step, 'beforeMouseenter');
			return null;
		},
		stepButtonMulticastStyleChange: function(step, useStyle, rememberStyle){
			var cssClass = ".step-"+step;
			var jqElems = this.slideControls.find(cssClass);
			jqElems.each(function(){
				var jqEl = jQuery(this);
				if (rememberStyle) {
					var rememberStyles = {};
					for (var i in useStyle){
						rememberStyles[i] = jqEl.css(i);
					}
					jqEl.data(rememberStyle, rememberStyles);
				}
				jqEl.css(useStyle);
			});
		},
		stepButtonMulticastStyleRevert: function(step, whichStoredStyle){
			var cssClass = '.step-'+step;
			var jqElems = this.slideControls.find(cssClass);
			var i = jqElems.length;
			while (i--) {
				var jqEl = jQuery(jqElems[i]);
				var prevStyle = jqEl.data(whichStoredStyle);
				if (!prevStyle) continue;
				jqEl.css(prevStyle);
				//jqEl.data(whichStoredStyle, null); // always keep unfuct
			};
		},
		stepButtonStoreUnfuctStyles: function(){
			var steps = this.slideControls.find('.step');
			var wierd = [];
			for (var i in this.slideControlStyles['default']) {
				for (var j in this.slideControlStyles['default'][i]) {
					if (-1 == wierd.indexOf(j)) wierd.push(j);
				}
			}
			i = steps.length;
			while (i--) {
				var el = jQuery(steps[i]);
				var storeMe = {};
				for (j in wierd) {
					var k = wierd[j];
					storeMe[k] = el.css(k);
				}
				el.data('unfuctStyle', storeMe);
			}
			this.storedUnfuctButtonStyles = true;
		},
		stepButtonObscurity: function(stepNumber){
			var useThisStyle = this.slideControlStyles['default']['obscured'];
			if (!useThisStyle) return null;
			var lastSlideNumber = this.slides.length;
			for (var i=this.currentStepNumber; i < stepNumber; i++) {
				this.stepButtonMulticastStyleRevert(i, 'unfuctStyle');
			}
			for (i=stepNumber+1; i<=lastSlideNumber; i++) {
				this.stepButtonMulticastStyleChange(i, useThisStyle);
			}
			return null;
		},
		stepNumberFromElement: function(stepEl){
			md = SlideManager.reStep.execAssert(stepEl.getAttribute('class'));
			var step = parseInt(md[1], 10);
			return step;
		}
	};

	/* wicked hack that shouldn't be here, but div.style it's not exist in xml
		so we don't have a working fadeTo(), etc
		@param (int) duration in ms
		@param (float) final between 0 and 1, 0 being transparent 1 being opaque
	*/
	var tardNuggetFadeTo = function(el, duration, toOpacity, callback){
		if (el.length == 0) return;
		if ("number" != typeof(duration) || duration < 0)
		 	return commonFailure("bad duration: "+duration);
		if ("number" != typeof(toOpacity) || toOpacity < 0.0 || toOpacity > 1.0)
		 	return commonFailure("bad opacity: "+toOpacity);
		var currentOpacity = el.css('opacity');
		if (! (/^\d+(?:\.\d+)?$/).test(currentOpacity)) {
			return commonFailure("i don't like this opacity: "+currentOpacity);
		}
		var fromOpacity = parseFloat(currentOpacity);
		var msPerStep = 1000/24; // 24 fps
		var numSteps = parseInt(duration / msPerStep, 10);
		if (numSteps == 0) return commonFailure("numSteps is zero");
		var currStep = 0;
		// assume it is at 1 if it wasn't set explicity, because it is in FF
		var opacityDiff = toOpacity - fromOpacity;
		var opacityStep = opacityDiff / numSteps;
		var func;
		func = function(){
			var nextOpacity = fromOpacity + opacityStep;
			fromOpacity = nextOpacity;
			// with floating point fuzziness there's really no good way ..?
			var opacityOk = (nextOpacity >= 0.0 && nextOpacity <= 1.0 &&
				! (/e/).test(''+nextOpacity)); // avoid numbs with scientific notation
			if (opacityOk) {
				//mylog("about to do this one: "+nextOpacity);
				tardNuggetSetOpacity(el, nextOpacity);
			}
			currStep ++;
			if (currStep < numSteps && opacityOk) {
				setTimeout(func, msPerStep);
			} else {
				if (callback) {
					setTimeout(callback, msPerStep+17); // whatever gah
				}
			}
		};
		func();
	};
	var tardNuggetSetOpacity = function(el, newOpacity){
		if (newOpacity < 0.0 || newOpacity > 1.0 ) {
			return commonFail("bad opacity: "+newOpacity);
		}
		var crazy = {
			'-moz-opacity' : newOpacity,
			'filter' : ('alpha(opacity='+(parseInt(newOpacity*100, 10))+')'),
			'-khtml-opacity' : newOpacity,
			'opacity' : newOpacity
		};
		el.css(crazy);
		return null;
	};

	// public api
	jQuery.vizzle = {
		newLigatureManager: function(x){
			return new LigatureManager(x);
		},
		newSlideManager: function(x){
			return new SlideManager(x);
		}
	};
})();
