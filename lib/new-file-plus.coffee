path = require 'path'
{CompositeDisposable} = require 'atom'

#closures
prevPane = null

module.exports =
    view: null
    panel: null
    subscriptions: null
    config:
        safeMode:
            type: 'boolean'
            default: true
            title: 'Safe Mode'
            description: 'Prevents new-file-plus from overriding existing files'
        saveOnCreation:
            type: 'boolean'
            default: true
            title: 'Save on Creation'
            description: 'When checked, files will be immediately saved to disk when created'
        baseDir:
            type: 'string'
            default: atom.config.get 'core.projectHome'
            title: 'Base Directory'
            description: 'The path which will be prepended to all non-absolute path names'

    activate: (state) ->
        @subscriptions = new CompositeDisposable()
        @subscriptions.add atom.commands.add 'atom-workspace', 'new-file-plus:toggle': => @toggle()

    deactivate: ->
        @panel?.destroy()
        @subscriptions.dispose()

    toggle: ->
        NewFilePlusView = require './new-file-plus-view'
        @view ?= new NewFilePlusView()
        @panel ?= atom.workspace.addModalPanel item: @view, visible: false

        if @panel.isVisible()
            @panel.hide()
            prevPane.activate()
        else
            prevPane = atom.workspace.getActivePane()
            @panel.show()
            @view.editor.focus()
            relPath = path.relative atom.config.get('new-file-plus.baseDir'), @view.cwd()
            @view.editor.setText(relPath + path.sep) if relPath
