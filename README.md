# EmmaTye.github.io

My personal webpage, built using jekyll.

## Quickstart

Enter the nix flake for the ruby and bundle binaries:

```sh
nix develop .
```

(or use direnv and `.envrc` setup)

```sh
bundle config set --local path 'vendor/bundle'
bundle install
```

Serve the site locally via:

```sh
bundle exec jekyll serve
```

It should be available at http://127.0.0.1:4000.

## TODOs

- [ ] Try and get ruby-nix and bundix working instead of using bundle for gem dependencies
- [ ] Add a slides tab and list for uploading presentation slides
- [ ] Upload master's thesis (and presentation slides)

