path = require 'path'
{CompositeDisposable} = require 'atom'
NewFilePlusView = require './new-file-plus-view'

#closures
prevPane = null

module.exports =
    view: null
    panel: null
    subscriptions: null

    activate: (state) ->
        @view = new NewFilePlusView()
        @subscriptions = new CompositeDisposable()
        @panel = atom.workspace.addModalPanel item: @view, visible: false

        @subscriptions.add atom.commands.add 'atom-workspace', 'new-file-plus:toggle': => @toggle()

    deactivate: ->
        @panel.destroy()
        @subscriptions.dispose()

    toggle: ->
        if @panel.isVisible()
            @panel.hide()
            prevPane.activate()
            if atom.project.getPaths().length > 0
                relPath = path.relative atom.config.get('core.projectHome'), atom.project.getPaths()[0]
                @view.editor.setText relPath + '/'
        else
            prevPane = atom.workspace.getActivePane()
            @panel.show()
            @view.editor.focus()
