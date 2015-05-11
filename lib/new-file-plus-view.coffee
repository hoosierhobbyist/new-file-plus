path = require 'path'
_ = require 'underscore-plus'
{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class NewFilePlusView extends View
    @content: ->
        @div =>
            @div 'Enter the path for the new file(s)', class: 'icon icon-plus'
            @subview 'editor', new TextEditorView mini: true

    initialize: ->
        relPath = path.relative atom.config.get('new-file-plus.baseDir'), @cwd()
        @editor.setText(relPath + path.sep) if relPath

        @on 'core:cancel', =>
            atom.commands.dispatch this[0], 'new-file-plus:toggle'
        @on 'core:confirm', =>
            files = _.flatten [@parse(@editor.getText())]
            atom.commands.dispatch this[0], 'new-file-plus:toggle'
            for file in files
                unless path.isAbsolute file
                    file = path.join atom.config.get('new-file-plus.baseDir'), file
                do(file) ->
                    fs.access file, (err) ->
                        if err
                            atom.workspace.open(file).then (fufilled, rejected) ->
                                if rejected then atom.notifications.addError rejected.toString()
                                else if atom.config.get('new-file-plus.saveOnCreation') then fufilled.save()
                        else
                            if atom.config.get 'new-file-plus.safeMode'
                                atom.notifications.addError "file: #{file} already exists"
                            else
                                fs.unlink file, (err) ->
                                    if err then return atom.notifications.addError err.toString()
                                    atom.workspace.open(file).then (fufilled, rejected) ->
                                        if rejected then atom.notifications.addError rejected.toString()
                                        else if atom.config.get('new-file-plus.saveOnCreation') then fufilled.save()
            return

    cwd: ->
        projectPaths = atom.project.getPaths()
        activeTextEditor = atom.workspace.getActiveTextEditor()
        activePath = path.dirname(activeTextEditor.getPath()) if activeTextEditor

        if projectPaths.length is 1
            return projectPaths[0]
        else if projectPaths.length > 1 and activePath
            for projectPath in projectPaths
                if (new RegExp('^' + projectPath)).test activePath
                    return projectPath
        else if activePath
            return activePath
        return atom.config.get 'new-file-plus.baseDir'

    lowerCase =
        a: 97, b: 98, c: 99, d: 100, e: 101, f: 102
        g: 103, h: 104, i: 105, j: 106, k: 107, l: 108, m: 109
        n: 110, o: 111, p: 112, q: 113, r: 114, s: 115
        t: 116, u: 117, v: 118, w: 119, x: 120, y: 121, z: 122
    upperCase =
        A: 65, B: 66, C: 67, D: 68, E: 69, F: 70
        G: 71, H: 72, I: 73, J: 74, K: 75, L: 76, M: 77
        N: 78, O: 79, P: 80, Q: 81, R: 82, S: 83
        T: 84, U: 85, V: 86, W: 87, X: 88, Y: 89, Z: 90

    range: (input) ->
        count = -1
        end = Infinity
        start = input.indexOf '{'
        for i in [start...input.length]
            if input[i] is '{'
                count += 1
            else if input[i] is '}'
                if count > 0
                    count -= 1
                else
                    end = i
                    break
        [start, end]

    parse: (input) ->
        if /.*\{.*\}.*/.test input
            [start, end] = @range input
        else
            [start, end] = [0, input.length-1]

        if /\s+/.test input
            input.split(/\s+/).map((string) => @parse string)
        else if /^\{\d+\.\.\d+\}$/.test input.slice start, end+1
            range = input.slice(start+1, end).split '..'
            outside = input.replace(input.slice(start, end+1), '\0').split '\0'
            for i in [parseInt(range[0])..parseInt(range[1])]
                @parse outside[0] + i + outside[1]
        else if /^\{[a-z]\.\.[a-z]\}$/.test input.slice start, end+1
            range = input.slice(start+1, end).split '..'
            outside = input.replace(input.slice(start, end+1), '\0').split '\0'
            for i in [lowerCase[range[0]]..lowerCase[range[1]]]
                @parse outside[0] + String.fromCharCode(i) + outside[1]
        else if /^\{[A-Z]\.\.[A-Z]\}$/.test input.slice start, end+1
            range = input.slice(start+1, end).split '..'
            outside = input.replace(input.slice(start, end+1), '\0').split '\0'
            for i in [upperCase[range[0]]..upperCase[range[1]]]
                @parse outside[0] + String.fromCharCode(i) + outside[1]
        else if /\{[^,]+(,[^,]+)*\}/.test input.slice start, end+1
            inside = input.slice(start+1, end).match /([^,]*\{.*\}[^,]*|[^,]+)/g
            outside = input.replace(input.slice(start, end+1), '\0').split '\0'
            for string in inside
                @parse outside[0] + string + outside[1]
        else input
