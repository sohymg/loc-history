# LOC History

This is a script to auto pull a Github repo and generate the total Lines of Code (LOC) per month. It works by checking out the first commit of each month and running `cloc`.

## How to use

1. Install `cloc`.
1. Run `bundle install`.
1. Run `ruby main.go <github api url> <github personal access token> <org> <repo> <branch>`.
1. CSV report will be saved to `output/`.

## Example usage

Command: `ruby main.go "https://api.github.com" "abcdef" "ruby" "rake" "master"`

CSV report:

```
Month,SHA,LOC
2016-12,0c6cb8f02dcbb75bc36418b74614abf105396838,27104
2017-01,40405fa09d9b9829d2a330bfe82140478e1f61f8,164971
2017-02,d0757e655d08a91dcb767ae923908a5eec885c9d,167210
...
```
