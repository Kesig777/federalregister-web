class @FR2.UserPreferenceStore
  @init: ->
    @_updateDefaults()

  # Utility Nav Settings
  @getAllUtilityNavSettings: ->
    @_get().utilityNav

  @getUtilityNavSetting: (key)->
    @_get().utilityNav[key]

  @saveUtilityNavSetting: (setting)->
    @_save(
      {utilityNav: Object.assign(@_get().utilityNav, setting)}
    )

  # External Url Modal Settings
  @getAllExternalUrlModalSettings: ->
    @_get().externalUrlModal

  @getExternalUrlModalSetting: (key)->
    @_get().externalUrlModal[key]

  @saveExternalUrlModalSetting: (setting)->
    @_save(
      {externalUrlModal: Object.assign(@_get().externalUrlModal, setting)}
    )

  # private
  @_get: ->
    amplify.store().userPreferences

  @_save: (setting)->
    amplify.store(
      "userPreferences",
      Object.assign(@_get() || {}, setting)
    )

  @_updateDefaults: ->
    if @_get() == undefined
      @_save(@_defaults())
    else
      @_save(
        {
          "utilityNav": _.defaults(
            @_get().utilityNav || {},
            @_defaults().utilityNav
          ),
          "externalUrlModal": _.defaults(
            @_get().externalUrlModal || {},
            @_defaults().externalUrlModal
          ),
        }
      )

  @_defaults: ->
    {
      utilityNav: {
        width: "wide"
      }
      externalUrlModal: {
        optOut: 'false'
      }
    }

  # session storage access for short lived preferences - like dimissing a
  # notification

  @_getSession: ->
    Object.assign(
      @_defaultSessionStore(),
      amplify.store.sessionStorage("userPreferences") || {}
    )

  @_saveSession: (setting)->
    amplify.store.sessionStorage(
      "userPreferences",
      Object.assign(@_getSession(), setting)
    )

  @_defaultSessionStore: ->
    {
      # contentNotificationsSettings: {
      #   ignoredNotifications: []
      # }
    }
