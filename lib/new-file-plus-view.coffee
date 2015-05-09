path = require 'path'
{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class NewFilePlusView extends View
    @content: ->
        @div =>
            @div 'Enter the path for the new file(s)', class: 'icon icon-plus'
            @subview 'editor', new TextEditorView mini: true

    initialize: ->
        if atom.project.getPaths().length > 0
            relPath = path.relative atom.config.get('new-file-plus.baseDir'), atom.project.getPaths()[0]
            @editor.setText relPath + path.sep

        @on 'core:confirm', =>
            if path.isAbsolute @editor.getText()
                newFile = @editor.getText()
            else
                newFile = path.join atom.config.get('new-file-plus.baseDir'), @editor.getText()
            atom.workspace.open(newFile).then (fufilled, rejected, progressed) ->
                if rejected
                    console.error rejected
                else if atom.config.get('new-file-plus.saveOnCreation')
                    fufilled.save()
            atom.commands.dispatch atom.views.getView(atom.workspace), 'new-file-plus:toggle'

    parseInput: (input) ->
        initial = input.split /\s+/
        initial.map (string) ->
            return string unless /\{(\w\.\.\w|\d\.\.\d)\}/.test
