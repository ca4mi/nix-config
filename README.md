### Git with ssh
copy ssh keys

```sh
mkdir -p ~/.ssh
# copy private key to .ssh and perm
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/<key_name>
# Identity added: ...
# add <key_name>.pub key to github and check to connection
ssh -T git@github.com
```

### Enable flakes

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
# add git configs
nix-env -f '<nixpkgs>' -iA git
nix-env -f '<nixpkgs>' -iA vim
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
### nix-configs

```sh
git clone git@github.com:ca4mi/nix-config.git
```
