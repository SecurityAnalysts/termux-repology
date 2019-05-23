# Utility for generating Repology metadata

[![Powered by JFrog Bintray](./.github/static/powered-by-bintray.png)](https://bintray.com)

There are located scripts for generating package metadata for [Repology](https://repology.org/) -
a service for tracking information about packages from various distributions.

## How to

1. Clone repository:
   ```ShellSession
   git clone https://github.com/termux/termux-repology
   ```

2. Initialize submodules:
   ```ShellSession
   cd termux-repology
   git submodule update --init
   ```

3. Execute script:
   ```ShellSession
   ./generate-repology-metadata.sh > ./packages.json
   ```

## Uploading (only for maintainers!)

Use script `./bintray_publish.sh`. It will do everything automatically, just ensure
that package at URL `https://bintray.com/termux/metadata/repology` exists. If not,
create package 'repology' from web interface on [Bintray](https://bintray.com/termux).

If have trouble with authentication, check if variables `BINTRAY_USERNAME` and
`BINTRAY_API_KEY` are set to correct values.

For now uploading is done automatically through CI, so you only need to push
updated submodules and metadata will be regenerated automatically.
