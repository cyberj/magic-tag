# magic-tag package

Little package to play with HTML tags

* `ctrl-t ctrl-d` Delete outer HTML tags

Before :
```html
<body>
  <ul>
    <li class="myclass">Hello |world</li>
  </ul>
</body>
```

After :
```html
<body>
  <ul>
    Hello |world
  </ul>
</body>
```

## TODO

* Select all code inside HTML tags
* Insert tags around a selection
* Handle multiple cursors

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
