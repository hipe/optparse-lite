# optparse-lite

# usage

## including optparse lite turns a class into a cli app


The excellent option parser [Trollop](http://trollop.rubyforge.org/) "doesn't require you to subclass some shit just to use a damn option parser."  To use `optparse-lite`, however, you will need to make at least one module or class and `include OptparseLite` unto it.  (It's probably better if you [don't ask why](/high-concept/)):

(see: test.rb - app - 'empty app' - full)

We throw the above in a file called `emtpy-app.rb` (for example), and after making sure it is executable (as per your os),

from the command line:
~~~
~ > chmod u+x empty-app.rb
~~~

we ask ourselves, what can we do with an empty app with no methods (commands)?  Let's try running it:

(see: test.rb - playback - 'empty-app.rb must work')

That's right.  Nothing.

But things are about to get crazy-go-nuts when we turn it up a notch and add a method:

(see: test.rb - app - 'one meth')

We don't have to, but we are using the `$stdout` wrapper `ui` to call the standard output methods.  It makes testing easier, and insulates the application code from having to know which stream it should actually be writing to, if so desired.

We run it by invoking the one command name from the command line:

(see: test.rb - playback - 'one-meth-app.rb runs')

So far so good.  Amazing, in fact.

Why and how did it allow us to use an instance method defined in our class as a command accessible from the command line?  These and more important questions will be explored below...

But what happens when we request a command (method) that we haven't defined !!??!??

(see: test.rb - playback - 'one-meth-app.rb works like help when the command is not found')

Hm.  Walk north.  Use door.

(see: test.rb - playback - 'one-meth-app.rb ask for help must work')

Ok, so we get a nice little listing of all the (one) commands available.

As we've seen from the above minimal example, `OptparseLite` can receive a request from the command line and route it to the appropriate method to carry out the request.  But before we do anything useful with this, let's take a minute to see what's going on behind the scenes...


## command interpreter objects are memory persistent

What happens if *in the same course of execution* we invoke `run` multiple times?

(see: test.rb - app - 'persistent' - full)

Above we set up some stuff in an initialize method, and each time the `ping` command is carried out, we increment the little jobber dohickey.

(This is a contrived example - you couldn't do this from the command line as it is written:)

(see: test.rb - playback - 'persistent-service-app.rb multiple requests')

The above output is generated from a unit test that ran the same command two times in the same process.  Your mileage would vary if you actually ran it from the command line; but the uptake of it is that when the `OptparseLite` class goes to create a command interpreter object, it reuses any existing such object if one has yet been created for that class.

This would be relevant if you adapt an `OptparseLite` app to work as a service or alongside, within or as[^no] a web app.  It is premature to point it out now, but I am following the order of stuff as it is shown in the unit tests `:P`  I just work here.


## method signatures and command signatures are isomorphic

Let's make an app with a single, minimal command like above (this one does absolutely nothing), but this time it uses the splat operator in its method signature (`splat` means the method can take any number of arguments):

(see: test.rb - app - 'neg arity' - full)

We run this bad boy with no arguments to see a summary of the commands available:

(see: test.rb - playback - 'one-meth-with-neg-arity-app.rb must work')

Because ruby method reflection can't discern between `def foo(bar=nil)` and `def foo(*bar)`, it treats it as the former, and gives us a command which takes an optional argument.  But the point is optional arguments to a command appear as optional parameters to a method.  Welcome to that idea.


## a rake-like dsl exists for describing things

A rake-like DSL exists for describing our app and its commands:

(see: test.rb - app - 'one meth desc')

`include`ing `OptparseLite` unto your class hackishly `extend`s it with another module, as has been known to happen sometimes when you go around including stranger's modules willy-nilly.  So you get a few methods, some of which are `app` and `desc`.

`app` is for describing and defining aspects of the cli application as a whole.  `desc` is for describing whatever following command (method) is defined.

So now when we see the general help screen we see our description for the whole app, and any descriptions we have added for the commands:

(see: test.rb - playback - 'one-meth-desc-app.rb must work')


Of course looking at help for the specific command we see our `desc` string:

(see: test.rb - playback - 'one-meth-desc-app.rb ask for help must work')

Big whoop.


## usage vs. description

Separate from the description of the command there is also the usage string used to describe its usage, usually following some BNF-like conventions:

(see: test.rb - app - 'one meth usage')

If you didn't want your command parameters to be described as `arg1` and `arg2`, which I understand if you don't, we instead get[^abs]:

(see: test.rb - playback - 'one-meth-usage-app.rb must work')

One thing to note about the above is that the command name is added automatically for us in our usage string.  We don't get to type that ourselves.


### more on usage:

Your usage string doesn't have to correspond at all to the method's actual signature:

(see: test.rb - app - 'more usage')

and it will still show it as you like it:

(see: test.rb - playback - 'cov-patch-app.rb displays wierd usage (no validation!?)' - {"id":"blah1"})

But if you use the string <code>[&lt;args&gt;]</code> in there, it will substitute `arg1`..`argn` there:

(see: test.rb - playback - 'cov-patch-app.rb interpolates args for no reason' - {"id":"blah2"})




If you are bored at this point it is because all of this is really boring.


## still boring

one app. three commands. one cup.

(see: test.rb - app - 'three meth')


Help screen lists the methods with stuff aligned properly:

(see: test.rb - playback - 'three-meth-app.rb no args must work')

note the generated usage, and note that only the first `desc` line for `faz` is shown.

Ask for help for an invalid command:

(see: test.rb - playback - 'three-meth-app.rb help requested command not found must work')

Ask for help with an ambiguous command name:

(see: test.rb - playback - 'three-meth-app.rb help requested partial match must work 1')

Ask for help for an incomplete but unambiguous command name:[^cred1]

(see: test.rb - playback - 'three-meth-app.rb help requested partial match must work 2')


## can we please parse some goddam options now

`OptparseLite`'s focus is not parsing options[^clev] for that is already a well-traveled space not in need of further innovation, even from the neo-minimalist camp.  However, it tries to do a minimalist, good enough job of it; like Henry David Thoreau trying to help design the interior of a Starbuck's corporate headquarters.

(see: test.rb - app - 'finally' - {"wrap":80})

When you `include` `OptparseLite`, you get an `opts` method that takes a block for defining your options.  In there you get `banner` for throwing a descriptive string in there at that point.  You get an `opt` method for defining an option.

The `opt` method has a syntax that is an amalgam of some different stuff i seen before. The first argument to it is a string describing the syntax of your option.  You can define either or both a short and a long version of your option and either none or an optional or a required parameter.  Note the '--[no-]' form.

Any subsequent strings will be used as description strings.  What the `:symbol` does will be covered later.

Here's help for the whole app.  The whole syntax for the command is crammed into one line:

(see: test.rb - playback - 'finally-app.rb general help' - {"wrap":80})

If we look at help for the individual command it will show all our banner lines and description lines:

(see: test.rb - playback - 'finally-app.rb command help' - {"wrap":80})

Note that banners that 'look like' headers get treated and highlighted as headers.

If we call the command with invalid options of some form or another, all the errors get reported.  This differs from every option parser I have yet seen, which craps out on the first error:

(see: test.rb - playback - 'finally-app.rb complains on optparse errors' - {"id":"blah3","wrap":80})

money has been shown.


## this is important and useful

this is like above but it's all finackley and dankley:

(see: test.rb - app - 'agg opts' - {"wrap":80})

foodey boodey shoodey:

(see: test.rb - playback - 'agg-opts-app.rb help display' - {"wrap":80})

fazzle dazzle:

(see: test.rb - playback - 'agg-opts-app.rb opt validation' - {"wrap":80})

bliff spliff gliff:

(see: test.rb - playback - 'agg-opts-app.rb must work' - {"wrap":80})

dinkle dankle.



## subcommands are private methods and blah blah

You have passed through a solid wall near the World 1-2 exit and now you are in "World -1",  also known as the "Minus World".

What I haven't been telling you thus far is that public methods to a class or module that you extend with `OptparseLite` become commands for your app.  Private/protected methods are yours to do with what you will.  *Unless* you declare them as subcommands:

(see: test.rb - app - 'sub' - {"wrap":80})

If I just call the `foo` command and don't give it any arguments, it will show me a list of all its available subcommands:

(see: test.rb - playback - 'sub-app.rb with command with no arg shows subcommand list' - {"wrap":80})

I ask "foo" for help on the "fric" subcommand:

(see: test.rb - playback - 'sub-app.rb shows help on sub-command' - {"wrap":80})


I call the "foo fric" subcommand and pass it the argument "frak":

(see: test.rb - playback - 'sub-app.rb must work' - {"wrap":80})

Welcome to a world where all of your problems have already been solved for you before you even knew you had them.  Welcome to `OptparseLite`.

[^no]: part of optparse-heavy vaporware
[^abs]: if we were serious with this kind of absurdity we could of course use ruby2ruby to blah blah you know whatever... generate a gui programmatically from assembler code.
[^cred1]: i first saw this pattern in wanstrath's code and in git source.
[^clev]: nor in being light; these are just clever marketing terms