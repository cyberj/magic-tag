{CompositeDisposable} = require 'atom'

module.exports = MagicTag =
  subscriptions: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'magic-tag:delete': => @delete()

  deactivate: ->
    @subscriptions.dispose()

  delete: ->
    console.log 'MagicTag requested a delete'
    optag = edtag = null
    if editor = atom.workspace.getActiveTextEditor()
      # I can't handle multiple curors
      return false if editor.hasMultipleCursors()
      mycursor = editor.getCursorBufferPosition()
      console.log mycursor

      rangetobegin = [[0,0], mycursor]
      rangetoend = [mycursor, [Infinity, Infinity]]
      htmlregop = /<([\w \d \s]+)([^<]+)([^<]+) *[^\/?]>/g
      editor.backwardsScanInBufferRange(htmlregop, rangetobegin, (result) =>
        @optag = result.range.copy()
        console.log @optag
        @beforetag = editor.getTextInBufferRange(@optag)
        console.log "trying before = #{@beforetag}"
        # Now gets tag title
        gettag = /<([\w]+) ?/
        @beforetagtitle = gettag.exec(@beforetag)[1]
        console.log "trying beforetagtitle = #{@beforetagtitle}"
        htmlclosereg = new RegExp("<\/#{@beforetagtitle} *>")
        editor.scanInBufferRange(htmlclosereg, rangetoend, (result) =>
          @edtag = result.range.copy()
          console.log @edtag
          console.log @optag
          @aftertag = editor.getTextInBufferRange(@edtag)
          console.log "after = #{@aftertag}"
          result.stop()
        )
        if @edtag?
          console.log "Got it !"
          result.stop()
        else
          console.log "Carry on"
        console.log "end3 = #{@edtag}"
      )
      console.log "after = #{@aftertag}"
      console.log "before = #{@beforetag}"
      console.log "before2 = #{@optag}"
      console.log "end2 = #{@edtag}"
      return false if not @edtag? or not @optag?
      # and now the end
      editor.setSelectedBufferRanges([@optag, @edtag])
      editor.delete()
      editor.setCursorBufferPosition(mycursor)
      @optag = @edtag = null
