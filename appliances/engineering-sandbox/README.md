# Engineering Sandbox Appliance

The *Engineering Sandbox* is a Linux based polyglot software engineering appliance.

## Polyglot Debian Engineering Sandbox Setup

If you're using Windows 10 with WSL2, create a "disposable" Debian WSL2 instance using Windows Store. This project treats the WSL2 instance as "disposable" meaning it's for development only and can easily be destroyed and recreated whenever necessary. The cost for creation and destruction for a Engineering Sandbox should be so low that it should be treated almost as a container rather than a VM. 

If you're using a Debian-based distro you should be able to run this repo in any Debian user account.

## Understand how to manage your secrets and other confidential configurations

It's crucial that confidential config settings and secrets are never acccidentally stored in project Git repositories so it's important to manage secrets in your $HOME directory. You can then source them into projects as you need them explicitly. 

By explicitly managing secrets you will be sure that passwords and other secrets never get put into scripts and are always sourced from the environment or external "vaults".

By convention, all secrets are stored in `$HOME/.engrsb/secrets.d` as separate secrets "groups" so let's prepare the directory:

    cd $HOME/.engrsb
    ./install-secrets.sh

Edit `secrets.d/git.env` and `secrets.d/github.com.env` and add your credentials. You should segment your secrets into separate files so that they're easy to find and edit. Then, when you need them you can use this in your terminal/shell:

    source $SANDBOX_CONF_HOME/secrets.env

The default `$SANDBOX_CONF_HOME/secrets.env` just loops through each file in `$HOME/.engrsb/secrets.d` and `source`s them into the active shell. If you only need to pull in a particular secrets group you can run something like this:

    source $SANDBOX_CONF_SECRETS_HOME/git.env
    source $SANDBOX_CONF_SECRETS_HOME/github.com.env

## TODO: explain Run setup

Once you've cloned the repo and setup your secrets, run the setup from your `$HOME` directory. 

    cd $HOME
    sudo .engrsb/setup-privileged-common.sh   # run only when necessary, system-wide (should be done by admin)
    .engrsb/setup.sh                          # run regularly, in each home (safe, does not require `sudo`)
    sudo usermod --shell /bin/zsh $USER       # only required once (should be done by admin)

The above setup steps are generally idempotent and can be run multiple times, whenever you need to update your sandbox.

## TODO: explain what was installed

* zsh as the default shell
* rupa/z directory navigation utility
* Antigen and oh-my-zsh script framework
  * [git-auto-fetch](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-auto-fetch) is turned on, see instructions to turn it off for certain repos
* GitHub CLI (official), `glab` GitLab CLI (unofficial)
* `git-semver` script courtesy of [semtag](https://github.com/pnikosis/semtag)
* Powerline 10k Theme with nice defaults
* Python with pyenv
* Hugo, Deno in .engrsb/bin (and in $PATH)
* Google Go in .engrsb/lang/go
* Update Deno Dependencies (UDD) utility for `deps.ts` and module versions management
* nvm, NodeJS LTS release, ESlint and Typescript as peer dependency for ESlint.
* SDKMAN! Java toolchain (TODO: move from `$HOME` to `.engrsb/lang/java`)
* Rust toolchain (TODO: move from `$HOME/.rustup` to `.engrsb/lang/rustup`)
* Julia toolchain
* Lazy Docker in /usr/local/bin
* git-extras

## TODO: explain what is optional

* Haxe and Neko toolchain (not installed by default, use `cd $HOME && .engrsb/install-haxe.sh` to setup)
* Common data engineering utilities (use `cd $HOME && .engrsb/install-data-engr.sh` to setup)
* Dolt toolchain (use `cd $HOME && .engrsb/install-dolt.sh` to setup)

# Python Notes

Python is installed using `pyenv`. Before using it for the first time:

```bash
pyenv install-latest
pyenv global $(pyenv install --list | grep -v - | grep -v b | tail -1)
python -m pip install --upgrade pip
pip install pylint
```

# Java Notes

Java is installed using `SDKMAN!`. Before using it for the first time:

```bash
sdk install java
sdk use java <version>
```

# NodeJS and NPM Packaging Notes

We use GitHub NPM Package Registry. Use [these instructions](https://docs.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-npm-for-use-with-github-packages).

Create `$HOME/.npmrc` with the following contents:

    //npm.pkg.github.com/:_authToken=<Personal Access Token>

Then:

    npm login --registry=https://npm.pkg.github.com

# Julia Notes

Multiple versions of Julia are supported in `$HOME/.engrsb/lang/julia/julia-X.Y.Z` with `$HOME/.engrsb/lang/julia/latest` symlink and `$HOME/.engrsb/lang/julia/latest/bin` in path.
