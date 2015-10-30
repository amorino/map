class MainController

    index:()=>
        @setPageTitle("HOME")


    dashboard:()=>
        @setPageTitle("DASHBOARD")


    setPageTitle: (sub=null) ->

        title = App.data.name + " - " + sub
        if window.document.title isnt title then window.document.title = title
        return null


module.exports = MainController
