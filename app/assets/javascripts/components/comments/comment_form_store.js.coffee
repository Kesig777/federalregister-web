class @FR2.CommentFormStore
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler

    @recentlySaved = false
    @saveTimeoutDuration = 5000
    @saveTimeout = null

  commentFormEl: ->
    @commentFormHandler.commentForm.commentFormEl()

  documentNumber: ->
    @commentFormHandler.formWrapper.data('document-number')

  getStoredComment: ->
    amplify.store @documentNumber()

  setStoredComment: (commentVal)->
    if commentVal == ""
      commentVal = null

    amplify.store @documentNumber(), commentVal

  hasStoredComment: ->
    # Ensure that fields other than 'secret' are populated
    @getStoredComment()? &&
      Object.keys(@getStoredComment()).length &&
      Object.keys(@getStoredComment()) != ["comment[secret]"]

  addStorageEvents: ->
    @commentFormEl().on 'click', '.submitter-type-js', ()=>
      @_attemptSave()

    @commentFormEl().on 'keyup change', ':input', ()=>
      @_attemptSave()

  serializeForm: ->
    formInputs = @commentFormEl().find ':input'

    formInputs = formInputs
      .filter ':input[name!=authenticity_token]'
      .filter ':input[name!=utf8]'
      .filter ':input[name!="comment[confirm_submission]"]'
      .filter ':input[name!="commit"]'

    formData = _.reduce formInputs, (memo, input)->
      if $(input).val() != ""
        memo[input.name] = input.value
      memo
    , {}

    if formData['comment[comment]'] == "See attached file(s)"
      formData['comment[comment]'] = null

    formData

  clearSavedFormState: ->
    @setStoredComment null

  storeComment: ->
    @setStoredComment @serializeForm()

  _attemptSave: ->
    if !@recentlySaved && @saveTimeout == null
      @recentlySaved = true

      saveCommentAndResetTimeout = ()=>
        @setStoredComment @serializeForm()
        @recentlySaved = false
        @saveTimeout = null

      @saveTimeout = setTimeout(
        saveCommentAndResetTimeout,
        @saveTimeoutDuration
      )
