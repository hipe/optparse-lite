---
stylesheets: hopes-and-dreams

javascripts:
# - /vendor/jquery-current/dist/jquery.js
  - /js/jquery-1.4.3.pre-hack-me.js
  - /vendor/jquery-ui/ui/jquery.ui.core.js
  - /vendor/jquery-ui/ui/jquery.ui.widget.js
  - /vendor/jquery-ui/ui/jquery.ui.mouse.js
  - /js/jquery.ui.draggable-hack-me.js
  - /js/for-graphle-my-vizzle.js
  - self

javascripts-off: [/vendor/jquery-1.3.js]
---
# optparse-lite

## high concept

[Trollop](http://trollop.rubyforge.org/) "doesn't require you to subclass some shit just to use a damn option parser."  To use Optparse-lite, however, you will need to make at least one module or class and `include OptparseLite` unto it.  Here's why:

OptparseLite (at least partially) parses a stream of input characters, turns them into a parse tree[^tree] of a request and dispatches it to the appropriate locus of logic which fulfills the user's wishes and presents a response in the form of the user's fulfilled dreams _(fig. 1)_.

<div id='fig-1' class='crazy-pic'>
  <div class='wrap-1'>
    <div class='wrap-2'>
      <div class='you box'><div class='label'>you</div></div>
      <div class='opl box'><div class='label'>app</div></div>
    </div>
    <div class='backlay'>
      <svg xmlns="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        version="1.1"
        preserveAspectRatio="xMidYMid slice"
        style="width:100%; height:100%; position:absolute; top:0; left:2px; z-index:-1;">
        <path id="arrow1" d="M100,30 C 120,20 160,20 188,30 l0,-10 l10,18 l-16,14 l4,-12 C 160,30 120,30 103,40 L100,30 " stroke="#777777" stroke-width="2" fill="#cceeff" />

        <path id="arrow2" d="M188,68 C 160,78 140,78 110,68 L 110,80 102,60 115,44 111,58 C 140,67 170,67 185,58 z" stroke="#777777" stroke-width="2" fill="#cceeff" />

        <path id="words2" d="M110,65 C 140,75 160,75 188,65" fill='none' stroke='none' />

        <text font-size="10.5" fill="black">
          <textPath xlink:href="#words2">&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;dreams</textPath>
        </text>

        <path id="words1" d="M100,37 C 120,29 138,24 180,37" fill='none' stroke='none' />
        <text font-size="10.5" fill="black">
          <textPath xlink:href="#words1">&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;wishes</textPath>
        </text>
      </svg>
    </div>
  </div>
  <div class='caption'>
    fig. 1 - apps turn your wishes into dreams
  </div>
</div>

Conceptually these loci are usually referred to as `command`s.  In practice it makes good sense for them to be implemented by ruby methods, which form a clean analog / isomorphicism with cli commands for several reasons expounded on below with vivid math.[^nomod]

None of this is especially unique to OptparseLite, but it is important that we frame the discussion in these terms to understand this important emerging field of command line processing.

However note that most option parsing libraries don't need to address some of the below issues because they don't deal with _what_ the commands are, they just deal with parsing the options _of_ the command(s).[^nocom]

It is a philosophical burden that OptparseLite alone must bear on its narrowly set but ample shoulders; because unlike its peers it cannot remain blissfully ignorant of the exquisite symphony of the stars that governs the motion of planets of data guided as they are by their gravitational forces of logic along their predetermined (and sometimes determinate) paths in the infinite tango that plays out below our fingertips daily.

### modules can model user interfaces

OptparseLite effectively lets you model the user interface of your application in terms of a [set](/high-concept/terms#set) of commands, each of which takes a [set](/high-concept/terms#set) of zero or more options and a [list](/high-concept/terms#list) of zero or more arguments.  OptparsLite is a grammar for defining interfaces composed of commands, and a tool for parsing requests per the interface defined by the grammar you create in this grammar.

The grammar you define with OptparseLite defines the [set](/high-concept/terms#set) (or a superset) of all valid requests for your application.  You do this by defining the set of all valid commands.  You define a command by defining the set of all valid requests for each command.  You do this by defining the set of all valid options and arguments each command takes.  You do this by defining a set of valid values that each option/argument takes.


<div id="fig-2">
  <h3>the grand isomorphicism</h3>
  <h4><em>a grand meta-narrative</em></h4>
  <div class="snack-wrap">
    <div class="backlay">
      <svg preserveAspectRatio="xMidYMid slice" style="width:100%; height:100%; position:absolute; top:0; left:0px; z-index:-1;" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
        <path class="name-arcmodmeth lig-pos-mod--pos-circmeth" d="M 72,35 72,59" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circmeth lig-pos-meth--tail-arcmodmeth" cx="72" cy="63.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-arcmethparam lig-pos-meth--pos-circparam" d="M 72,100 72,127" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circparam lig-pos-param--tail-arcmethparam" cx="72" cy="130.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-ridgidoptsparam lig-pos-param--tail-arcoptsparam" d="M 105,159 l 15,-5 0,10 z" fill="none" stroke-width="2" stroke="#777777" />
        <path class="name-arcoptsparam lig-pos-ridgidoptsparam--pos-opts" d="M 119,159 130,159 130,220" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-arctrailparam lig-pos-ridgidtrailparam--pos-trail" d="M 15,201 15,285" fill="#777777" stroke-width="2" stroke="#777777" />
        <path class="name-ridgidtrailparam lig-pos-param--pos-arctrailparam" d="M 10,201 l 5,-13 5,13 z" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-rsplat lig-pos-trail--tail-asplat" d="M 10,365 l 5,-13 5,13 z" fill="none" stroke-width="2" stroke="#777777" />
        <path class="name-asplat lig-pos-rsplat--pos-splat" d="M 15,364 15,390" fill="#777777" id="tallz" stroke-width="2" stroke="#777777" />

        <path class="name-arcintrcmd lig-pos-intr--pos-circcmd" d="M 358,35 358,59" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circcmd lig-pos-cmd--pos-arcintrcmd" cx="358" cy="63.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-arccmdarg lig-pos-cmd--pos-circarg" d="M 358,100 358,127" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circarg lig-pos-arccmdarg--pos-arg" cx="358" cy="130.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-arccmdopts2 lig-pos-cmd--pos-opts2" d="M 407,100 407,220" fill="#777777" stroke-width="2" stroke="#777777" />

        <path class="name-arctrail2arg lig-pos-ridgidtrail2arg--pos-trail2" d="M 298,201 298,285" fill="#777777" stroke-width="2" stroke="#777777" />
        <path class="name-ridgidtrail2arg lig-pos-arg" d="M 292,201 l 6,-13 5,13 z" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-arcopts2opt lig-pos-opts2--pos-circopt" d="M 415,255 415,278" fill="#777777" id="opt" stroke-width="2" stroke="#777777" />
        <circle class="name-circopt lig-pos-opt" cx="415" cy="281" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-ridgidsplat2 lig-pos-trail2--pos-arcsplat2" d="M 292,365 l 6,-13 5,13 z" fill="none" id="bliz9" stroke-width="2" stroke="#777777" />
        <path class="name-arcsplat2 lig-pos-ridgidsplat2--pos-splat2" d="M 298,364 298,390" fill="#777777" stroke-width="2" stroke="#777777" />

        <path class="name-arcswitch lig-pos-switch" d="M 417,397 427,397" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-arcpr lig-pos-pr" d="M 417,464 427,464" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-atall lig-pos-po--pos-ridgidopt" d="M 417,517 427,517 427,367 410,367 410,340" fill="none" stroke-width="2" stroke="#777777" />
        <path class="name-ridgidopt lig-pos-opt--tail-atall" d="M 411,339 l -6,0 5,-15 5,15 z" fill="none" stroke-width="2" stroke="#777777" />

      </svg>

    </div>
    <div class="left-col">

      <div class="mod   ruby square short">ruby module</div>
      <div class="meth  ruby square short">public method</div>
      <div class="param ruby square dubs" style="width: 81px">method parameter</div>
      <div class="opts  ruby square short">option hash</div>
      <div class="trail ruby square">trailing optional parameter</div>
      <div class="splat ruby square">splat</div>

      <div class="expl arc-1 mod-meth has-many">has many</div>
      <div class="expl arc-2 mod-meth has-many">has many</div>
      <div class="expl arc-3 mod-meth is-a">is a</div>
      <div class="expl arc-4 mod-meth is-a">is a</div>
      <div class="expl arc-5 mod-meth is-a">is a</div>

    </div>
    <div class="mid-col">

      <div class="iso iso-1"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-2"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-3"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-4"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-5"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-6"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>

    </div>
    <div class="right-col">
      <div class="intr   app square short">app interface</div>
      <div class="cmd  app square short">command</div>
      <div class="arg app square dubs" style="width: 81px">positional argument</div>
      <div class="opts2  app square">options</div>

      <div class="opt app square">opt</div>

      <div class="switch app square">switch</div>
      <div class="pr app square">param. required</div>
      <div class="po app square">param. optional</div>

      <div class="trail2 app square">trailing optional argument</div>
      <div class="splat2 app square">splat arg</div>

      <div class="expl arc-21 mod-meth has-many">has many</div>
      <div class="expl arc-22 mod-meth has-many">has many</div>
      <div class="expl arc-23 mod-meth is-a">is a</div>
      <div class="expl arc-24 mod-meth has-one">has one</div>
      <div class="expl arc-26 mod-meth is-a">is a kind of</div>

    </div>
    <div class="clear"></div>
  </div>
  <div class='slide-controller slide-controller-top-left'>
    <div class='back-bar back-bar-lvl-1'>&#160;</div>
    <div class='step step-1'>1</div>
    <div class='step step-2'>2</div>
    <div class='step step-3'>3</div>
    <div class='step step-4'>4</div>
    <div class='step step-5'>5</div>
  </div>
  <div class='slide-controller slide-controller-bottom-left'>
    <div class='back-bar back-bar-lvl-1'>&#160;</div>
    <div class='step step-1'>1</div>
    <div class='step step-2'>2</div>
    <div class='step step-3'>3</div>
    <div class='step step-4'>4</div>
    <div class='step step-5'>5</div>
  </div>

  <div class='big-button-overlay'>
    <div class='opaque-backlay'>&#160;</div>
    <div class='frame'>
      <div class='banner top-banner'>PUT ON YOUR LEARNING HAT</div>
      <div class='button-play'>
        <svg preserveAspectRatio="xMidYMid slice" style="width:100%; height:100%; position:absolute; top:0; left:0px; z-index:0;" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
          <path class='arrow-border' d="M 2,40 C 2,2 2,2 40,2 L 133,2 C 170,2 170,2 170,40 L 170,120 C 170,159 170,159 143,159 L 20,159 C 2,159 2,159 2,120 z" fill="#aaaaaa" stroke='#777777' stroke-width="2" />
          <path class='arrow' d="M 27,18 l 115,65 -115,65  z" fill="#ffffff" stroke-width="2" stroke="#777777" />
        </svg>
      </div>
      <div class='banner bottom-banner'>AND LET THE AWESOME BEGIN</div>
    </div>
  </div>
</div>


You don't have to think of it this way if you're not into that kind of thing.  This is no different from any other option parser; I just wanted to frame the discussion a bit.

Check out the awesome [usage](/usage/)

<br />
<hr />
### _feetnote_ ###
[^tree]: the arguments node of your tree may have order that is semantic.
[^nocom]: `Trollop`, `OptionParser` and `Getopt::Long` are examples of option-parsing solutions that don't address the issue of parsing out the command.
[^nomod]: Using defined methods belonging to a special module isn't the only way to model commands.  [Cri](http://rubygems.org/gems/cri) uses a class to model each command.  [rip](http://hellorip.com/) at one point, like [rvm](http://rvm.beginrescueend.com/) uses a separate executable file for each command, in the conventional unix tradition.  (But in fact an earlier version of rip was the inspiration for this whole project.)