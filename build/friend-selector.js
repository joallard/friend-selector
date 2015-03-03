(function() {
  var FriendSelector;

  FriendSelector = {
    friends: [],
    elements: {},
    _options: {
      elementSelector: "[data-friend-selector]",
      pagination: 10,
      selectCallback: function() {},
      confirm: true,
      injectStyle: "full",
      dictionary: {
        title: "Choose a friend",
        confirm: "Choose",
        loading: "Loading...",
        noFriends: "No friends are using this app yet."
      }
    },
    options: function(options) {
      if (!options) {
        return this._options;
      }
      return this._options = _.merge(this._options, options);
    },
    launch: function() {
      var _this, promise;
      _this = FriendSelector;
      promise = FBLogin.ensurePermission("user_friends");
      promise.done(function() {
        return _this.open();
      });
      promise.fail(function() {
        return _this._complainAboutPermissions();
      });
    },
    open: function() {
      this._findElement();
      this.element.style.display = "block";
      this._basicDOMElements();
      this._fetchFriends().done((function(_this) {
        return function() {
          return _this._showFriends();
        };
      })(this));
    },
    close: function() {
      this.element.style.display = "none";
      this.elements.overlay.remove();
      this.dialog.remove();
    },
    _fetchFriends: function() {
      var defer;
      this._toggleLoading(true);
      defer = $.Deferred();
      FB.api('/me/friends', (function(_this) {
        return function(response) {
          if (response.data) {
            if (response.data.length !== 0) {
              _this.friends = response.data;
              return defer.resolve();
            } else {
              console.warn("FriendSelector: No friends found");
              _this._infoNoFriends();
              defer.reject();
              return _this._toggleLoading(false);
            }
          } else {
            console.error("FriendSelector: Not logged in");
            defer.reject();
            return _this._toggleLoading(false);
          }
        };
      })(this), {
        limit: 9999
      });
      return defer.promise();
    },
    _basicDOMElements: function() {
      var actions, closeLink, confirm, controls, dialog, friends, next, pagination, prev, title, titleBar;
      this.elements.overlay = this._createElement("div", {
        "class": "overlay",
        "in": this.element
      });
      dialog = this._createElement("div", {
        "class": "dialog"
      });
      titleBar = this._createElement("div", {
        "class": "title-bar"
      });
      friends = this._createElement("div", {
        "class": "friends"
      });
      controls = this._createElement("div", {
        "class": "controls"
      });
      pagination = this._createElement("div", {
        "class": "pagination",
        "in": controls
      });
      this.elements.prev = prev = this._createElement("button", {
        "in": pagination,
        content: "&#x25c4;"
      });
      this.elements.next = next = this._createElement("button", {
        "in": pagination,
        content: "&#x25ba;"
      });
      prev.disabled = true;
      next.disabled = true;
      prev.addEventListener("click", (function(_this) {
        return function() {
          return _this.prevPage();
        };
      })(this));
      next.addEventListener("click", (function(_this) {
        return function() {
          return _this.nextPage();
        };
      })(this));
      this.elements.paginationCount = this._createElement("span", {
        "class": "page-numbers",
        "in": pagination
      });
      actions = this._createElement("div", {
        "class": "actions",
        "in": controls
      });
      if (this._options.confirm) {
        confirm = this._createElement("button", {
          content: this._options.dictionary.confirm,
          "class": "confirm",
          "in": actions
        });
        confirm.disabled = true;
        confirm.setAttribute("data-confirm", "");
        confirm.addEventListener("click", (function(_this) {
          return function() {
            return _this._confirm();
          };
        })(this));
        this.elements.confirm = confirm;
      }
      closeLink = this._createElement("a", {
        content: "&times;",
        "in": titleBar,
        "class": "close"
      });
      closeLink.href = "#";
      closeLink.addEventListener("click", (function(_this) {
        return function() {
          return _this.close();
        };
      })(this));
      title = this._createElement("h1", {
        "in": titleBar,
        content: this._options.dictionary.title
      });
      this.element.appendChild(dialog);
      dialog.appendChild(titleBar);
      dialog.appendChild(friends);
      dialog.appendChild(controls);
      this.dialog = dialog;
      this.elements.friends = friends;
    },
    _toggleLoading: function(up) {
      if (up) {
        this._flushFriends();
        return this.elements.loading = this._createElement("div", {
          "class": "loading info message",
          "in": this.elements.friends,
          content: this._options.dictionary.loading
        });
      } else {
        return this.elements.loading.remove();
      }
    },
    _infoNoFriends: function() {
      this._createElement("div", {
        "class": "no-friends info message",
        "in": this.elements.friends,
        content: this._options.dictionary.noFriends
      });
    },
    _showFriends: function() {
      this._nPages = Math.ceil(this.friends.length / this._options.pagination);
      if (this._nPages > 1) {
        this._enablePagination;
      }
      return this._showPage(0);
    },
    _showPage: function(n) {
      var first, last, pagination, records;
      if ((n < 0) || (n > this._nPages - 1)) {
        return;
      }
      this._nPage = n;
      this._ablePaginationButtons();
      this._reflectPaginationCount();
      pagination = this._options.pagination;
      first = n * pagination;
      last = (n + 1) * pagination;
      records = _.slice(this.friends, first, last);
      this._flushFriends();
      _.each(records, (function(_this) {
        return function(f) {
          return _this._addDOMFriend(f);
        };
      })(this));
    },
    nextPage: function() {
      return this._showPage(this._nPage + 1);
    },
    prevPage: function() {
      return this._showPage(this._nPage - 1);
    },
    _ablePaginationButtons: function() {
      if (this._nPages < 2) {
        this.elements.prev.disabled = true;
        return this.elements.next.disabled = true;
      } else if (this._nPage === 0) {
        this.elements.prev.disabled = true;
        return this.elements.next.disabled = false;
      } else if (this._nPage === this._nPages - 1) {
        this.elements.prev.disabled = false;
        return this.elements.next.disabled = true;
      } else {
        this.elements.prev.disabled = false;
        return this.elements.next.disabled = false;
      }
    },
    _reflectPaginationCount: function() {
      return this.elements.paginationCount.innerHTML = (this._nPage + 1) + "/" + this._nPages;
    },
    _flushFriends: function() {
      return this.elements.friends.innerHTML = "";
    },
    _addDOMFriend: function(friend) {
      var element, link, picture;
      element = this._createElement("div", {
        "in": this.elements.friends,
        "class": "friend"
      });
      link = document.createElement("a");
      link.href = "#";
      link.innerHTML = friend.name;
      link.addEventListener("click", (function(_this) {
        return function() {
          return _this._selectFriend(friend, element);
        };
      })(this));
      picture = document.createElement("img");
      picture.src = "//graph.facebook.com/" + friend.id + "/picture";
      element.appendChild(picture);
      return element.appendChild(link);
    },
    _selectFriend: function(friend, el) {
      this._resetSelection();
      el.className += " selected";
      this.selection = friend;
      if (this._options.confirm) {
        return this.elements.confirm.disabled = false;
      } else {
        return this._confirm();
      }
    },
    _resetSelection: function() {
      var selected;
      selected = this.elements.friends.querySelector(".selected");
      if (!selected) {
        return;
      }
      selected.className = selected.className.replace(" selected", "");
    },
    _confirm: function() {
      if (!this.selection) {
        return;
      }
      this._options.selectCallback.call(this, this.selection);
      return this.close();
    },
    _findElement: function() {
      this.element || (this.element = document.querySelector(this._options.elementSelector));
      if (!this.element) {
        throw "FriendSelector: Element not found";
      }
    },
    _complainAboutPermissions: function() {
      return console.error("FriendSelector: Permission to Facebook friends denied");
    },
    _createElement: function(element, args) {
      var el;
      if (args == null) {
        args = {};
      }
      el = document.createElement(element);
      if (args["class"]) {
        el.className = args["class"];
      }
      if (args.content) {
        el.innerHTML = args.content;
      }
      if (args["in"]) {
        args["in"].appendChild(el);
      }
      return el;
    }
  };

  window.FriendSelector = FriendSelector;

}).call(this);
