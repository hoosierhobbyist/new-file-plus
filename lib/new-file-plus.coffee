fs = require 'fs'
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
        @subscriptions.add atom.commands.add '.tree-view.full-menu',
            'new-file-plus:add-file': => @addFile()
            'new-file-plus:add-folder': => @addFolder()

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
            @view.setMode()
            relPath = path.relative atom.config.get('new-file-plus.baseDir'), @view.cwd()
            @view.editor.setText(relPath + path.sep) if relPath

    addFile: ->
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
            @view.setMode('file')
            dataPath = document.querySelector('.tree-view .selected span').getAttribute('data-path')
            fs.stat dataPath, (err, stats) =>
                if err
                    return atom.notifications.addError err.toString()
                unless stats.isDirectory()
                    dataPath = path.dirname dataPath
                relPath = path.relative atom.config.get('new-file-plus.baseDir'), dataPath
                @view.editor.setText(relPath + path.sep) if relPath

    addFolder: ->
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
            @view.setMode('folder')
            dataPath = document.querySelector('.tree-view .selected span').getAttribute('data-path')
            fs.stat dataPath, (err, stats) =>
                if err
                    return atom.notifications.addError err.toString()
                unless stats.isDirectory()
                    dataPath = path.dirname dataPath
                relPath = path.relative atom.config.get('new-file-plus.baseDir'), dataPath
                @view.editor.setText(relPath + path.sep) if relPath
