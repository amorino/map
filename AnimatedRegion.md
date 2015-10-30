# Animated Region

The `AnimatedRegion` class, is an extension of the default `Marionette.Region` class, adding the functionality to simultaneously show and hide a new and old `View`.

The transitions are made with javascript, ideally with [Greensock](http://greensock.com).

To use the `AnimatedRegion` we have to add a region with a regionClass, calling the method `region.transitionToView(newView)` instead of `region.show(newView)` whenever we want to show a new view. 

	AnimatedRegion = require "base/AnimatedRegion"
	
	class AppLayout exetnds Marionette.LayoutView
		el: "main"
		template: Template
		regions:{
			header:"header",
			content:{
				el:"#content",
				regionClass:AnimatedRegion
			}
		}
		
		onRender:()=>
			@home = new HomeView()
			@about = new AboutView()
			
			#We show initial view
			@getRegion("content").transitionToView(@home)
	
			#We transition to the new view
			@getRegion("content").transitionToView(@about)



The views to be animated need to implement two additional methods (listeners) `onTransitionHide` and `onTransitionShow`, and need to trigger the events `transition:hiden` and `transition:shown` when the animation has completed. As follows:

	class HomeView extends Marionette.ItemView
		
		onTransitionHide:()=>
			TweenMax.to(@$el, 0.5, {autoAlpha:0, onComplete:@onTransitionComplete})
			
		onTransitionComplete:()=>
        	@triggerMethod('transition:hiden')

		onTransitionShow:()=>
        	TweenMax.from(@$el, 0.5, {y:"+100%", onComplete:@onTransitionComplete})
        	
        onTransitionComplete:()=>
        	@triggerMethod('transition:shown')
        	
       	onShow:()=>
        	console.log("show HomeView")
        	
The `onShow` method remains untouched, and can be used to perfom actions after the animation ShowAnimation has been completed. It will be called from the `AnimatedRegion`. 

The `AnimatedRegion` will destroy and create the views properlly, avoiding memory leaks.