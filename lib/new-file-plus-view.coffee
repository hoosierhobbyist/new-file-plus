path = require 'path'
{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class NewFilePlusView extends View
    @content: ->
        @div =>
            @div 'Enter the path for the new file(s)', class: 'icon icon-plus'
            @subview 'editor', new TextEditorView mini: true

    initialize: ->
        console.log @editor
        if atom.project.getPaths().length > 0
            relPath = path.relative atom.config.get('core.projectHome'), atom.project.getPaths()[0]
            @editor.setText relPath + '/'
