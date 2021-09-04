## Run dev server (local)

### Better performances

```shell
bundle exec rerun -b -- rhino -p 8080 www/config.ru start
```

### Better debugging

Use the following commands, when you are trying to
[troubleshoot an issue][better_errors#multi-worker-servers] in development.

```shell
bundle exec rerun -b -- rackup -p 8080 -s thin www/config.ru
```

```shell
bundle exec rerun -b -- rackup -p 8080 -s webrick www/config.ru
```

### ```exe/server```

```shell
bundle exec rerun -b -- exe/server --server thin
```

<!-- hypelinks -->

[better_errors#multi-worker-servers]: https://github.com/BetterErrors/better_errors#unicorn-puma-and-other-multi-worker-servers
