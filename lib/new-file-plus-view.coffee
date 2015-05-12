path = require 'path'
mkdirp = require 'mkdirp'
expand = require 'brace-expansion'
{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class NewFilePlusView extends View
    @content: ->
        @div =>
            @div 'Enter the path for the new file(s) or directory(ies)', class: 'icon icon-plus'
            @subview 'editor', new TextEditorView mini: true

    initialize: ->
        @on 'core:cancel', =>
            atom.commands.dispatch this[0], 'new-file-plus:toggle'
        @on 'core:confirm', =>
            files = expand @editor.getText()
            atom.commands.dispatch this[0], 'new-file-plus:toggle'
            for file in files
                unless path.isAbsolute file
                    file = path.join atom.config.get('new-file-plus.baseDir'), file
                do(file) ->
                    fs.access file, (err) ->
                        if err
                            if RegExp(path.sep + '$').test file
                                mkdirp file, (err) ->
                                    if err then atom.notifications.addError err.toString()
                            else
                                atom.workspace.open(file).then (fufilled, rejected) ->
                                    if rejected then atom.notifications.addError rejected.toString()
                                    else if atom.config.get('new-file-plus.saveOnCreation') then fufilled.save()
                        else
                            if atom.config.get 'new-file-plus.safeMode'
                                atom.notifications.addError "file: #{file} already exists"
                            else
                                fs.unlink file, (err) ->
                                    if err then return atom.notifications.addError err.toString()
                                    if RegExp(path.sep + '$').test file
                                        mkdirp file, (err) ->
                                            if err then atom.notifications.addError err.toString()
                                    else
                                        atom.workspace.open(file).then (fufilled, rejected) ->
                                            if rejected then atom.notifications.addError rejected.toString()
                                            else if atom.config.get('new-file-plus.saveOnCreation') then fufilled.save()
            return

    cwd: ->
        projectPaths = atom.project.getPaths()
        activeTextEditor = atom.workspace.getActiveTextEditor()
        activePath = path.dirname(activeTextEditor.getPath()) if activeTextEditor and activeTextEditor.getPath()

        if activePath
            return activePath
        else if projectPaths.length is 1
            return projectPaths[0]
        return atom.config.get 'new-file-plus.baseDir'
