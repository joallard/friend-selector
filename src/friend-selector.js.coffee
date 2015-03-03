FriendSelector =
  friends: []
  elements: {}

  _options:
    elementSelector: "[data-friend-selector]"
    pagination: 10
    selectCallback: ->
    confirm: true
    injectStyle: "full" # none/minimal/full
    dictionary:
      {
        title: "Choose a friend"
        confirm: "Choose"
        loading: "Loading..."
        noFriends: "No friends are using this app yet."
      }

  options: (options) ->
    return @_options unless options
    @_options = _.merge(@_options, options)

  launch: ->
    _this = FriendSelector
    promise = FBLogin.ensurePermission "user_friends"
    promise.done ->
      _this.open()
    promise.fail ->
      _this._complainAboutPermissions()

    return

  open: ->
    @_findElement()
    @element.style.display = "block"
    @_basicDOMElements()
    @_fetchFriends().done => @_showFriends()
    return

  close: ->
    @element.style.display = "none"
    @elements.overlay.remove()
    @dialog.remove()
    return

  _fetchFriends: ->
    @_toggleLoading(true)
    defer = $.Deferred()

    FB.api '/me/friends', (response) =>
      if response.data
        unless response.data.length == 0
          @friends = response.data
          defer.resolve()
        else
          console.warn "FriendSelector: No friends found"
          @_infoNoFriends()
          defer.reject()
          @_toggleLoading(false)
      else
        console.error "FriendSelector: Not logged in"
        defer.reject()
        @_toggleLoading(false)

    , limit: 9999


    defer.promise()

  _basicDOMElements: ->
    @elements.overlay = @_createElement("div", class: "overlay", in: @element)

    dialog = @_createElement("div", class: "dialog")
    titleBar = @_createElement("div", class: "title-bar")
    friends = @_createElement("div", class: "friends")
    controls = @_createElement("div", class: "controls")

    pagination = @_createElement("div", class: "pagination", in: controls)

    @elements.prev =
      prev = @_createElement("button", in: pagination, content: "&#x25c4;")
    @elements.next =
      next = @_createElement("button", in: pagination, content: "&#x25ba;")

    prev.disabled = true
    next.disabled = true
    prev.addEventListener("click", => @prevPage())
    next.addEventListener("click", => @nextPage())

    @elements.paginationCount =
      @_createElement("span", class: "page-numbers", in: pagination)

    actions = @_createElement("div", class: "actions", in: controls)

    if @_options.confirm
      confirm = @_createElement("button",
        content: @_options.dictionary.confirm, class: "confirm", in: actions)
      confirm.disabled = true
      confirm.setAttribute("data-confirm", "")
      confirm.addEventListener("click", => @_confirm())
      @elements.confirm = confirm

    closeLink = @_createElement("a", content: "&times;", in: titleBar, class: "close")
    closeLink.href = "#"
    closeLink.addEventListener("click", => @close())

    title = @_createElement("h1", in: titleBar, content: @_options.dictionary.title)

    @element.appendChild dialog
    dialog.appendChild titleBar
    dialog.appendChild friends
    dialog.appendChild controls

    @dialog = dialog
    @elements.friends = friends

    return

  _toggleLoading: (up) ->
    if up
      @_flushFriends()
      @elements.loading = @_createElement("div",
        class: "loading info message", in: @elements.friends,
        content: @_options.dictionary.loading)
    else
      @elements.loading.remove()

  _infoNoFriends: ->
    @_createElement("div",
      class: "no-friends info message",
      in: @elements.friends,
      content: @_options.dictionary.noFriends
    )
    return

  _showFriends: ->
    @_nPages = Math.ceil @friends.length/@_options.pagination
    @_enablePagination if @_nPages > 1
    @_showPage(0)

  # pages are zero-indexed
  _showPage: (n) ->
    return if (n < 0) || (n > @_nPages-1)
    @_nPage = n
    @_ablePaginationButtons()
    @_reflectPaginationCount()

    pagination = @_options.pagination

    first = n * pagination
    last = (n + 1)*pagination

    records = _.slice(@friends, first, last)

    @_flushFriends()
    _.each records, (f) =>
      @_addDOMFriend(f)

    return

  # gets called before nPage is changed
  nextPage: ->
    @_showPage(@_nPage+1)
  prevPage: ->
    @_showPage(@_nPage-1)

  _ablePaginationButtons: ->
    if @_nPages < 2
      @elements.prev.disabled = true
      @elements.next.disabled = true
    else if @_nPage == 0
      @elements.prev.disabled = true
      @elements.next.disabled = false
    else if @_nPage == @_nPages-1
      @elements.prev.disabled = false
      @elements.next.disabled = true
    else
      @elements.prev.disabled = false
      @elements.next.disabled = false

  _reflectPaginationCount: ->
    @elements.paginationCount.innerHTML = "#{@_nPage+1}/#{@_nPages}"

  _flushFriends: ->
    @elements.friends.innerHTML = ""

  _addDOMFriend: (friend) ->
    element = @_createElement("div", in: @elements.friends, class: "friend")

    link = document.createElement("a")
    link.href = "#"
    link.innerHTML = friend.name
    link.addEventListener("click", => @_selectFriend(friend, element))

    picture = document.createElement("img")
    picture.src = "//graph.facebook.com/#{friend.id}/picture"

    element.appendChild picture
    element.appendChild link

  _selectFriend: (friend, el) ->
    @_resetSelection()
    el.className += " selected"
    @selection = friend

    if @_options.confirm
      @elements.confirm.disabled = false
    else
      @_confirm()

  _resetSelection: ->
    selected = @elements.friends.querySelector(".selected")
    return unless selected

    selected.className = selected.className.replace(" selected", "")
    return

  _confirm: ->
    return unless @selection
    @_options.selectCallback.call(@, @selection)
    @close()

  _findElement: ->
    @element ||= document.querySelector(@_options.elementSelector)
    throw "FriendSelector: Element not found" unless @element

  _complainAboutPermissions: ->
      console.error "FriendSelector: Permission to Facebook friends denied"

  # Usage:
  # _createElement("div", in: parent, class: "friend", content: "Foo")
  _createElement: (element, args = {}) ->
    el = document.createElement(element)

    el.className = args.class if args.class
    el.innerHTML = args.content if args.content
    args.in.appendChild el if args.in

    el

window.FriendSelector = FriendSelector
