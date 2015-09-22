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
* [FBLogin](https://github.com/joallard/fb-login)
* jQuery
* Lo-dash

Options
-------
### selectCallback
Default: `function(friend){}`

Called when user has made a selection. `friend` is an object 
with properties `name` and `id` (which corresponds to an
element of the array of the response to `FB.api('/me/friends')`)

Example: `friend = {name: "Max Power", id: 4294967296}`

### confirm
Default: `true`

Determines what happens when the user selects a friend.
Setting it to `false` will hide the Choose button, and
trigger `selectCallback` as soon as the friend is clicked on.

### dictionary
Default: 
```
{
    title: 'Choose a friend',
    confirm: 'Choose',
    loading: 'Loading...',
    noFriends: 'No friends are using this app yet.'
}
```

Dictionary of strings displayed to the user. Useful for I18n.

### elementSelector
Default: `'[data-friend-selector]'`

Selector for the empty element Friend Selector will make
its nest in.

### pagination
Default: 10

Maximum number of friends displayed per selector page.

Contributing
------------
Yes.
