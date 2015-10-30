# Created by mendieta on 4/24/15.

class AnimatedRegion extends Marionette.Region

    initialize: ()=>
        @transHidenEvent = "transition:hiden"
        @transHideEvent = "transition:hide"

        @transShownEvent = "transition:shown"
        @transShowEvent = "transition:show"

    transitionToView: (newView)=>
        #We make a reference to the view to be shown
        @newView = newView

        #If the current view is Null or has been destroyed, we continue to show the new view
        if !@currentView || @currentView.isDestroyed
            @show newView
            return

        #We stop listening to the render event on the new view, we will render manually
        @stopListening(newView, "render")
        @listenTo(newView, "render", @onListenRender)
        newView.render()

    onListenRender: ()=>
        #We append the new view element manually
        @.$el.append(@newView.el)

        #We listen to the current view to finish its hide transition
        @currentView.on(@transHidenEvent, @onTransitionHiden)
        #We trigger the hide transition on the current view
        Marionette.triggerMethod(@currentView, @transHideEvent)

        #We listen to the new view to finish its show transition
        @newView.on(@transShownEvent, @onTransitionShown)
        #We trigger the show transition on the new view
        Marionette.triggerMethodOn(@newView, @transShowEvent)


    #TODO: Find if by only destroying the current view os enough, to do a cleanup of the region.
    onTransitionShown: ()=>
        #We destroy the currentView
        @currentView.destroy()
        #We reset the region, cleaning it.
        @reset()
        #We create a reference to the new view
        @currentView = @newView

        #We (re)show the new view , without animation.
        #Can this possibly be enhanced??
        Marionette.triggerMethod.call(@newView, "show")
        Marionette.triggerMethod.call(@, "show", @newView)

    onTransitionHiden: ()->
        return
        #Do something when the old view is hiden. Can be omited?


module.exports = AnimatedRegion
