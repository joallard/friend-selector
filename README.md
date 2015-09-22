# friend-selector
A friend selector in Javascript

[Demo](https://joallard.github.io/friend-selector)

Usage
-----
Put an empty `div` for FS to do its dirty business in:

```html
<div data-friend-selector=""></div>
```

Set a callback and maybe some options:
```js
FriendSelector.options({
  selectCallback: function(friend){
    console.log("You selected " + friend.name + " who has id: " friend.id)
  }
})
```

And have it launched:

```js
$("#foo").click(function(){
  FriendSelector.launch()
}
```

That's pretty much it.

### Dependencies
* jQuery
* Lo-dash


Options
-------

    elementSelector: '[data-friend-selector]',
    pagination: 10,
    selectCallback: function (friend){},
    confirm: true,
    dictionary: {
        title: 'Choose a friend',
        confirm: 'Choose',
        loading: 'Loading...',
        noFriends: 'No friends are using this app yet.'
    }

Contributing
------------
Yes.
