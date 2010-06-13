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

<div class="crazy-pic" id="fig-1">
  <div class="wrap-1">
    <div class="wrap-2">
      <div class="you box"><div class="label">you</div></div>
      <div class="opl box"><div class="label">app</div></div>
    </div>
    <div class="backlay">
      <svg preserveAspectRatio="xMidYMid slice" style="width:100%; height:100%; position:absolute; top:0; left:2px; z-index:-1;" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
        <g id='thing-to-spin' transform='rotate(0, 0, 0)'>
          <path d="M100,30 C 120,20 160,20 188,30 l0,-10 l10,18 l-16,14 l4,-12 C 160,30 120,30 103,40 L100,30 " fill="#cceeff" id="arrow1" stroke-width="2" stroke="#777777" />

          <path d="M188,68 C 160,78 140,78 110,68 L 110,80 102,60 115,44 111,58 C 140,67 170,67 185,58 z" fill="#cceeff" id="arrow2" stroke-width="2" stroke="#777777" />

          <path d="M110,65 C 140,75 160,75 188,65" fill="none" id="words2" stroke="none" />

          <text fill="black" font-size="10.5">
            <textPath xlink:href="#words2">&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;dreams</textPath>
          </text>

          <path d="M100,37 C 120,29 138,24 180,37" fill="none" id="words1" stroke="none" />
          <text fill="black" font-size="10.5">
            <textPath xlink:href="#words1">&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;wishes</textPath>
          </text>
        </g>
      </svg>
    </div>
    <div class='click-overlay'>
      <div class='left-half'>
      </div>
      <div class='right-half'>
      </div>
    </div>
  </div>
  <div class="caption">
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
        <path class="name-arcmodmeth lig-pos-mod--pos-circmeth slide-1" d="M 72,35 72,59" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circmeth lig-pos-meth--tail-arcmodmeth slide-1" cx="72" cy="63.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-arcmethparam lig-pos-meth--pos-circparam slide-6" d="M 72,100 72,127" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circparam lig-pos-param--tail-arcmethparam slide-6" cx="72" cy="130.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-ridgidoptsparam lig-pos-param--tail-arcoptsparam slide-11" d="M 105,159 l 15,-5 0,10 z" fill="none" stroke-width="2" stroke="#777777" />
        <path class="name-arcoptsparam lig-pos-ridgidoptsparam--pos-opts slide-11" d="M 119,159 130,159 130,220" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-arctrailparam lig-pos-ridgidtrailparam--pos-trail slide-16" d="M 15,201 15,285" fill="#777777" stroke-width="2" stroke="#777777" />
        <path class="name-ridgidtrailparam lig-pos-param--pos-arctrailparam slide-16" d="M 10,201 l 5,-13 5,13 z" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-rsplat lig-pos-trail--tail-asplat slide-21" d="M 10,365 l 5,-13 5,13 z" fill="none" stroke-width="2" stroke="#777777" />
        <path class="name-asplat lig-pos-rsplat--pos-splat slide-21" d="M 15,364 15,390" fill="#777777" id="tallz" stroke-width="2" stroke="#777777" />

        <path class="name-arcintrcmd lig-pos-intr--pos-circcmd slide-51" d="M 358,35 358,59" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circcmd lig-pos-cmd--pos-arcintrcmd slide-51" cx="358" cy="63.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-arccmdarg lig-pos-cmd--pos-circarg slide-56" d="M 358,100 358,127" fill="#777777" stroke-width="2" stroke="#777777" />
        <circle class="name-circarg lig-pos-arccmdarg--pos-arg slide-56" cx="358" cy="130.5" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-arccmdopts2 lig-pos-cmd--pos-opts2 slide-61" d="M 407,100 407,220" fill="#777777" stroke-width="2" stroke="#777777" />

        <path class="name-arctrail2arg lig-pos-ridgidtrail2arg--pos-trail2 slide-66" d="M 298,201 298,285" fill="#777777" stroke-width="2" stroke="#777777" />
        <path class="name-ridgidtrail2arg lig-pos-arg slide-66" d="M 292,201 l 6,-13 5,13 z" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-arcopts2opt lig-pos-opts2--pos-circopt slide-76" d="M 415,255 415,278" fill="#777777" id="opt" stroke-width="2" stroke="#777777" />
        <circle class="name-circopt lig-pos-opt slide-76" cx="415" cy="281" fill="none" r="3.5" stroke-width="1.66" stroke="#555555" />

        <path class="name-ridgidsplat2 lig-pos-trail2--pos-arcsplat2 slide-71" d="M 292,365 l 6,-13 5,13 z" fill="none" id="bliz9" stroke-width="2" stroke="#777777" />
        <path class="name-arcsplat2 lig-pos-ridgidsplat2--pos-splat2 slide-71" d="M 298,364 298,390" fill="#777777" stroke-width="2" stroke="#777777" />

        <path class="name-arcswitch lig-pos-switch slide-81" d="M 417,397 427,397 427,367 410,367 410,340" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-arcpr lig-pos-pr slide-86" d="M 417,464 427,464 427,397" fill="none" stroke-width="2" stroke="#777777" />

        <path class="name-atall lig-pos-po--pos-ridgidopt slide-91" d="M 417,517 427,517 427,367 410,367 410,340" fill="none" stroke-width="2" stroke="#777777" />
        <path class="name-ridgidopt lig-pos-opt--tail-atall slide-81" d="M 411,339 l -6,0 5,-15 5,15 z" fill="none" stroke-width="2" stroke="#777777" />

      </svg>

    </div>
    <div class="left-col">

      <div class="mod   ruby-construct square short slide-1">ruby module</div>
      <div class="meth  ruby-construct square short slide-1">public method</div>
      <div class="param ruby-construct square dubs slide-6" style="width: 81px">method parameter</div>
      <div class="opts  ruby-construct square short slide-11">option hash</div>
      <div class="trail ruby-construct square slide-16">trailing optional parameter</div>
      <div class="splat ruby-construct square slide-21">splat</div>

      <div class="expl arc-1 mod-meth has-many slide-1">has many</div>
      <div class="expl arc-2 mod-meth has-many slide-6">has many</div>
      <div class="expl arc-3 mod-meth is-a slide-11">is a</div>
      <div class="expl arc-4 mod-meth is-a slide-16">is a</div>
      <div class="expl arc-5 mod-meth is-a slide-21">is a</div>

    </div>
    <div class="mid-col">

      <div class="iso iso-1 slide-201"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-2 slide-201"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-3 slide-201"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-4 slide-201"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-5 slide-201"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>
      <div class="iso iso-6 slide-201"><div class="l"><object class="arrow-left" data="/svg/arrow-left.svg" type="image/svg+xml" /></div><div class="m">isomorphs</div><div class="r"><object class="arrow-right" data="/svg/arrow-right.svg" type="image/svg+xml" /></div></div>

    </div>
    <div class="right-col">
      <div class="intr app square short slide-51">app interface</div>
      <div class="cmd  app square short slide-51">command</div>
      <div class="arg app square dubs slide-56" style="width: 81px">positional argument</div>
      <div class="opts2 app square slide-61">options</div>

      <div class="opt app square slide-76">opt</div>

      <div class="switch app square slide-81">switch</div>
      <div class="pr app square slide-86">param. required</div>
      <div class="po app square slide-91">param. optional</div>

      <div class="trail2 app square slide-66">trailing optional argument</div>
      <div class="splat2 app square slide-71">splat arg</div>

      <div class="expl arc-21 mod-meth has-many slide-51">has many</div>
      <div class="expl arc-22 mod-meth has-many slide-56">has many</div>
      <div class="expl arc-23 mod-meth is-a slide-66">is a</div>
      <div class="expl arc-24 mod-meth has-one slide-61">has one</div>
      <div class="expl arc-26 mod-meth is-a slide-71">is a kind of</div>

    </div>
    <div class="balloon balloon-1 slide-1-only">
        <p>
        A ruby module has zero or more methods.  (Classes are modules too!)
        </p>
<pre class='ruby example-smaller'><span class="keyword">module </span><span class="module">SomeModule</span>
  <span class="keyword">def </span><span class="method">foo</span>
  <span class="keyword">end</span>
  <span class="keyword">def </span><span class="method">bar</span>
  <span class="keyword">end</span>
<span class="keyword">end</span>
</pre>
        <button class="next">&#187;</button>
    </div>



    <div class="balloon balloon-2 slide-6-only">
        <p>A ruby method <em>has many</em> parameters --
        A ruby method signature defines the names (and maybe default values)
        for the zero or more formal parameters it takes.
        (A ruby method call has zero or more arguments.)
        </p>
<pre class='ruby example-smaller'><span class="keyword">def </span><span class="method">foo</span> <span class="ident">arg1</span><span class="punct">,</span> <span class="ident">arg2</span><span class="punct">='</span><span class="string">blah</span><span class="punct">'</span>
  <span class="comment"># do some foo...</span>
<span class="keyword">end</span>
</pre>
        <button class="next">&#187;</button>
    </div>




    <div class="balloon balloon-3 slide-11-only" style='width: 268px'>
        <p>An "options hash" is a <em>kind of</em> method parameter.</p>
<pre class='ruby' style='width: 257px'><span class="keyword">def </span><span class="method">foo</span> <span class="ident">arg1</span><span class="punct">,</span> <span class="ident">opts</span><span class="punct">={}</span>
  <span class="ident">opts</span> <span class="punct">=</span> <span class="punct">{</span><span class="symbol">:some=</span><span class="punct">&gt;'</span><span class="string">default</span><span class="punct">'}.</span><span class="ident">merge</span><span class="punct">(</span><span class="ident">opts</span><span class="punct">)</span>
  <span class="comment"># ...</span>
<span class="keyword">end</span>
</pre>
<p>
Ruby has 'syntactic sugar' that allows name-value paired option
hashes appearing at the end of a method call not need the curly braces.
</p>
<pre class='ruby' style='border:4px solid #DDDDDD; width:308px;'><span class="ident">foo</span> <span class="punct">&quot;</span><span class="string">bar</span><span class="punct">&quot;,</span> <span class="symbol">:bob</span> <span class="punct">=&gt;</span> <span class="punct">&quot;</span><span class="string">loblaw's</span><span class="punct">&quot;,</span> <span class="symbol">:law</span> <span class="punct">=&gt;</span> <span class="punct">'</span><span class="string">blog</span><span class="punct">'</span><span class="string"><span class="normal">
</span></span></pre>

<p>
So typically when a method takes an "options hash" it appears as the last parameter.
</p>
<p style='font-size: 0.8em'><em>For reasons that might become clear,
  optparse-lite does not utilize this idiom as an isomorphicism.
</em></p>

<div class='spacer-gif'>&#160;</div>
<button class="next lower">&#187;</button>
    </div>
    <div class="balloon balloon-4 slide-16-only" style='width: 267px'>
      <p>Actual parameters passed to a method call are <em>positionally semantic</em>, by which i mean that the interpreter
        figures out which actual parameters correspond to which formal parameters by their order (i.e. index)
        (a ridiculously obvious point which sounds confusing when you explain it).
      </p>
      <p>Although it wouldn't necessarily have to be this way, ruby follows the syntax rule for all other
        such programming languages and allows you to specify default arguments for parameters IFF they are
        contiguous and at the end of the list of parameters.</p>
<pre class='ruby'><span class="keyword">def </span><span class="method">baby</span> <span class="ident">jug</span><span class="punct">,</span> <span class="ident">funny</span><span class="punct">='</span><span class="string">default</span><span class="punct">';</span> <span class="keyword">end</span>
</pre>
<pre class='ruby'><span class="ident">baby</span><span class="punct">('</span><span class="string">funny</span><span class="punct">')</span> <span class="comment"># not funny</span>
</pre>
      <p>(Imagine a method that takes five arguments where the first, third and last have defaults and are
        thereby optional. No reason. just for fun.  Some SQL syntax is sorta like this.)</p>
      <p>The only point in all this is that contiguous trailing parameters of a method
        who take defaults are effectively optional. </p>
        <div class='spacer-gif'></div>
        <button class="next">&#187;</button>
    </div>



    <div class="balloon balloon-5 slide-21-only">
        <p>One <em>kind of</em> trailing option parameter is a splat.</p>
        <p>(in ruby 1.8.7 the splat must be the last parameter.)</p>
        <p>A splat means that the method can take an infinite number of arguments
            (or some big number of them), and that those arguments that don't have a
            positional named parameter at the beginning get turned into elements of an
            array that is passed as the effective last parameter of the method call.
        </p>
<pre class='ruby'><span class="keyword">def </span><span class="method">splat</span><span class="punct">(*</span><span class="ident">blah</span><span class="punct">)</span>
  <span class="ident">puts</span> <span class="ident">blah</span><span class="punct">.</span><span class="ident">map</span><span class="punct">(&amp;</span><span class="symbol">:upcase</span><span class="punct">).</span><span class="ident">join</span><span class="punct">('</span><span class="string"> </span><span class="punct">')</span>
<span class="keyword">end</span>
<span class="ident">splat</span> <span class="punct">'</span><span class="string">baby</span><span class="punct">',</span> <span class="punct">'</span><span class="string">jug</span><span class="punct">',</span> <span class="punct">'</span><span class="string">not</span><span class="punct">',</span> <span class="punct">'</span><span class="string">funny</span><span class="punct">'</span>
<span class="comment"># BABY JUG NOT FUNNY</span>
</pre>
        <div class='spacer-gif'>&#160;</div>
        <button class="next">&#187;</button>
    </div>
    <div class="balloon balloon-6 slide-51-only">
        <p>An application interface is made up of <em>many</em> commands.</p>
        <p><em>(note API's's are, too)</em></p>
        <div style='height: 2px'>&#160;</div>
        <button class="next">&#187;</button>
    </div>
    <div class="balloon balloon-7 slide-56-only">
        <p>A CLI command <em>has many</em> (positional) arguments.</p>
        <p>It could have zero.  Note this isomorphs with parameters of a method.</p>
<pre class='terminal' style='border:8px solid #DDDDDD; width: 302px'><span class='prompt'>~ &#62;</span> git checkout -h
usage: git checkout [options] &#60;branch&#62;
</pre>
<p>The above git command has one required positional argument.</p>
        <div class='spacer-gif'></div>
        <button class="next">&#187;</button>
    </div>
    <div class="balloon balloon-8 slide-61-only">
        <p>An optparse-lite command (method) gets passed one (or zero) options structure (hash).</p>
<pre class='ruby'><span class="ident">opts</span> <span class="punct">{</span>
  <span class="ident">opt</span> <span class="punct">'</span><span class="string">--[no-]mames</span><span class="punct">',</span> <span class="symbol">:juae</span>
<span class="punct">}</span>
<span class="keyword">def </span><span class="method">do_it</span> <span class="ident">opts</span><span class="punct">,</span> <span class="ident">a</span><span class="punct">,</span> <span class="ident">b</span><span class="punct">=</span><span class="constant">nil</span>
  <span class="comment"># do it</span>
<span class="keyword">end</span>
</pre>
<p><b>opts</b> is passed as the first parameter above.</p>
        <div style='top: 2px'></div>
        <button class="next">&#187;</button>
    </div>



    <div class="balloon balloon-9 slide-66-only">
        <p>One kind of positional argument <em>is a</em> trailing optional argument.</p>
<pre class='ruby'><span class="keyword">def </span><span class="method">do_it</span> <span class="ident">opts</span><span class="punct">,</span> <span class="ident">foo</span><span class="punct">,</span> <span class="ident">bar</span><span class="punct">=</span><span class="constant">nil</span>
  <span class="comment"># do it</span>
<span class="keyword">end</span>
</pre>
<p><b>bar</b> is a trailing optional argument above.
</p>
        <div style='top: 2px'></div>
        <button class="next">&#187;</button>
    </div>
    <div class="balloon balloon-10 slide-71-only">
        <p>One kind of trailing optional argument <em>is a</em> splat argument.</p>
        <p><em>Note that if you have any splat argument, you can only have one.</em></p>
        <div style='text-align: right; float: right' class='slide-71-only'>
          <button class="next" style='position: relative; bottom: 0px; right: 0px'>&#187;</button>
        </div>
        <p>In the below git command, <b>filepattern</b> is a splat argument.</p>
<pre class='terminal' style='width: 369px; border: 8px solid #DDDDDD;'>~ &#62; git add -h
usage: git add [options] [--] &#60;filepattern&#62;...
</pre>
    </div>
    <div class="balloon balloon-11 slide-76-only">
        <p>An options structure (hash) is made up of <em>many</em> options.</p>
        <p><em>(as a hash is made up of many elements)</em></p>
        <div class='spacer-gif'></div>
        <button class="next">&#187;</button>
    </div>
    <div class="balloon balloon-12 slide-81-only">
        <p>One kind of option <em>is a</em> switch (or <em>'flag'</em>)</p>
        <p>This kind of option does not (and cannot) take an argument.</p>
<pre class='terminal' style='width: 369px; border:8px solid #DDDDDD; font-size: 9px'>~ &#62; git add -h
usage: git add [options] [--] &#60;filepattern&#62;...
...
    -f, --force           allow adding otherwise ignored files
...
</pre>
<p><b>--force</b> is a flag for the git <b>add</b> command.  It does not take any arguments.</p>
        <div class='spacer-gif'></div>
        <button class="next">&#187;</button>
    </div>
    <div class="balloon balloon-13 slide-86-only">
        <p>Another <em>kind of</em> option is the kind that takes a required parameter.</p>
        <p>The git <b>checkout</b> command takes a <b>--branch</b> option which takes a required parameter.</p>
        <button class="next" style=''>&#187;</button>
<pre class='terminal' style='font-size: 9px'>~ &#62; git co -h
usage: git checkout [options] &#60;branch&#62;
...
    -b &#60;new branch&#62;      branch
...
</pre>
    </div>
    <div class="balloon balloon-14 slide-91-only">
        <p>Another <em>kind of</em> option is the kind that takes a parameter optionally.</p>
        <p>The <b>git init</b> command has an option <b>--shared</b> which takes a parameter optionally.</p>
        <p><b>--template</b> takes a parameter also but note that it is not optional.</p>
<pre class='terminal' style='border:9px solid #DDDDDD;font-size:9px;left:-165px;position:relative;width:387px;'>~ &#62; git init -h
usage: git init [-q | --quiet] [--bare] [--template=&#60;template-directory&#62;]
  [--shared[=&#60;permissions&#62;]] [directory]
</pre>
        <p><em>(These are not the same as options that have default parameters -- an option
            that has a default value is not necessarily valid appearing on its own
            without a parameter.)</em></p>
        <div class='spacer-gif'></div>
        <button class="next">&#187;</button>
    </div>


    <div class="clear"></div>
  </div>
  <div class="slide-control slide-control-top-left">
    <div class="back-bar back-bar-lvl-1">&#160;</div>
    <div class="back-bar back-bar-lvl-2">&#160;</div>
    <div class="step step-1">1</div>
    <div class="step step-2">2</div>
    <div class="step step-3">3</div>
    <div class="step step-4">4</div>
    <div class="step step-5">5</div>
    <div class="step step-6">6</div>
    <div class="step step-7">7</div>
    <br/>
    <div class="step step-8">8</div>
    <div class="step step-9">9</div>
    <div class="step step-10">10</div>
    <div class="step step-11">11</div>
    <div class="step step-12">12</div>
    <div class="step step-13">13</div>
    <div class="step step-14">14</div>
    <div class="step step-15">15</div>
  </div>
  <div class="slide-control slide-control-bottom-left">
    <div class='fix'>
      <div class="back-bar back-bar-wide">&#160;</div>
      <div class="step step-1">1</div>
      <div class="step step-2">2</div>
      <div class="step step-3">3</div>
      <div class="step step-4">4</div>
      <div class="step step-5">5</div>
      <div class="step step-6">6</div>
      <div class="step step-7">7</div>
      <div class="step step-8">8</div>
      <div class="step step-9">9</div>
      <div class="step step-10">10</div>
      <div class="step step-11">11</div>
      <div class="step step-12">12</div>
      <div class="step step-13">13</div>
      <div class="step step-14">14</div>
      <div class="step step-15">15</div>
    </div>
  </div>

  <div class="big-button-overlay">
    <div class="opaque-backlay">&#160;</div>
    <div class="frame">
      <div class="banner top-banner">PUT ON YOUR LEARNING HAT</div>
      <div class="button-play">
        <svg preserveAspectRatio="xMidYMid slice" style="width:100%; height:100%; position:absolute; top:0; left:0px; z-index:0;" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
          <path class="arrow-border" d="M 2,40 C 2,2 2,2 40,2 L 133,2 C 170,2 170,2 170,40 L 170,120 C 170,159 170,159 143,159 L 20,159 C 2,159 2,159 2,120 z" fill="#aaaaaa" stroke-width="2" stroke="#777777" />
          <path class="arrow" d="M 27,18 l 115,65 -115,65  z" fill="#ffffff" stroke-width="2" stroke="#777777" />
        </svg>
      </div>
      <div class="banner bottom-banner">AND LET THE AWESOME BEGIN</div>
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