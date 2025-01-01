# Intro
To reproduce this bug https://github.com/wez/wezterm/issues/4785#issuecomment-2567133005

```
# They don't work as expected
cmd+shift+[
cmd+shift+]
```

```
docker build -t foobar .
docker run --rm -it foobar
```

# Faster way to reproduce
```
printf '\033[>1u' && showkey -a

# try cmd+shift+[ in both WezTerm and Ghostty
```
