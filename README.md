## Run dev server (local)

## Better performances

```shell
bundle exec rerun -- rhino -p 8080 www/config.ru start
```

## Better debugging

Use tyhe following commands, when you are trying to
[troubleshoot an issue][better_errors#multi-worker-servers] in development.

```shell
bundle exec rerun -- rackup -p 8080 -s thin www/config.ru
```

```shell
bundle exec rerun -- rackup -p 8080 -s webrick www/config.ru
```

<!-- hypelinks -->

[better_errors#multi-worker-servers]: https://github.com/BetterErrors/better_errors#unicorn-puma-and-other-multi-worker-servers
