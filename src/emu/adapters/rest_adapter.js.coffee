Emu.RestAdapter = Ember.Object.extend
  init: ->
    @_serializer = @get("serializer")?.create() or Emu.Serializer.create()

  findAll: (type, store, collection) -> 
    $.ajax
      url: @_getUrlForModel(collection)
      type: "GET"
      success: (jsonData) =>
        @_didFindAll(store, collection, jsonData)

  findById: (type, store, model, id) ->
    $.ajax
      url: @_getUrlForModel(model) + "/" + id
      type: "GET"
      success: (jsonData) =>
        @_didFindById(store, model, jsonData)
      error: =>
        @_didError(store, model)

  findQuery: (type, store, collection, queryHash) ->
    $.ajax
      url: @_getUrlForType(type) + @_serializer.serializeQueryHash(queryHash)
      type: "GET"
      success: (jsonData) =>
        @_serializer.deserializeCollection(collection, jsonData)
        store.didFindQuery(collection)

  insert: (store, model) ->
    @_save(store, model, "POST") 
    
  update: (store, model) ->   
    @_save(store, model, "PUT", model.primaryKeyValue()) 

  delete: (store, model) ->
    $.ajax
      url: @_getUrlForModel(model) + "/" + model.primaryKeyValue()
      type: "DELETE"
      success: ->
        store.didDeleteRecord(model)
  
  _save: (store, model, requestType, id) ->
    jsonData = @_serializer.serializeModel(model)
    $.ajax
      url: @_getUrlForModel(model) + if id then ("/" + id) else ""
      data: jsonData
      type: requestType
      success: (jsonData) =>
        @_didSave(store, model, jsonData)
  
  _didFindAll: (store, collection, jsonData) ->
    @_serializer.deserializeCollection(collection, jsonData)
    store.didFindAll(collection)
  
  _didFindById: (store, model, jsonData) ->
    @_serializer.deserializeModel(model, jsonData)
    store.didFindById(model)

  _didError: (store, model) ->
    store.didError(model)
  
  _didSave: (store, model, jsonData) ->
    @_serializer.deserializeModel(model, jsonData)
    store.didSave(model)
    
  _getUrlForModel: (model) ->
    url = if model.constructor == Emu.ModelCollection then @_serializer.serializeTypeName(model.get("type")) else ""
    currentModel = model
    buildUrl = =>
      currentModel = currentModel.get("parent")
      if currentModel.constructor == Emu.ModelCollection
        url = @_serializer.serializeTypeName(currentModel.get("type")) + (if url then "/" + url else "")
      else
        url = currentModel.primaryKeyValue() + "/" + url 
    buildUrl() while currentModel.get("parent")
    @_getBaseUrl() + url

  _getUrlForType: (type) ->
    @_getBaseUrl() + @_serializer.serializeTypeName(type)
  
  _getBaseUrl: ->
    if @get("namespace") then @get("namespace") + "/" else ""