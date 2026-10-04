# Homelab

flake-parts + `import-tree`: любой `.nix` в репозитории подхватывается сам, регистрировать его нигде не нужно. Файлы с `_` в начале имени игнорируются.

## Хосты

| Хост | Роль | Деплой |
|---|---|---|
| `laptop` | Framework, niri | локально |
| `desktop` | рабочая станция, niri | локально |
| `vpn` | traefik + headscale, единственный публичный | `deploy .#vpn` |
| `bytes` | proxmox, dnsmasq, authentik, роутер сети | `deploy .#bytes` |
| `git` | forgejo + runner | `deploy .#git` |
| `nextcloud` | nextcloud | `deploy .#nextcloud` |
| `polygon` | mysql / postgres / sqlserver / сайты | `deploy .#polygon` |

## Команды

```bash
nh os switch                  # локально (laptop/desktop, путь к флейку прошит в конфиге)
nh os test                    # то же без записи в загрузчик
deploy .#git                  # удалённо, через deploy-rs
deploy .#git --dry-activate   # собрать и залить, но не активировать
```

Новый файл обязательно `git add` — flake читает дерево через git, и незакоммиченного файла для него не существует.

## Где что менять

| Нужно | Файл |
|---|---|
| домен, юзер, IP, порт, email, ssh-ключ | `settings/settings.nix` |
| цвета | `settings/palette.nix` |
| шрифты | `settings/fonts.nix` |
| тема (stylix, GTK, Qt / KDE-приложения) | `modules/features/theme/` |
| публичный поддомен | `settings/settings.nix` + роутер в `modules/hosts/vpn/features/traefik.nix` |
| секрет | `secrets/secrets.yaml` + объявление в `modules/features/sops.nix` |
| новый хост | `modules/hosts/<имя>/{configuration,hardware,deploy}.nix` |
| общая фича | `modules/features/` → подключить в `imports` хоста |
| пер-хостовая опция | `modules/features/options/` (пространство `bytes.*`) |

## settings/settings.nix

Общие константы, доступны как `self.settings` — в nixosModules, homeConfigurations, deploy.nodes и perSystem:

```nix
{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.foo = { ... }: {
        services.foo.domain = s.domains.git;
    };
}
```

Группы: `domains` (публичные имена), `hosts` (имена MagicDNS внутри сети), `net` (подсеть, шлюз, DNS, IP хостов), `users`, `emails`, `ports`, `sshKeys` (`sshKeys.yubikeys` — обе железки списком).

В `ports` лежат только порты, которые нужно держать синхронными между разными файлами: `forgejoHttp` (forgejo + бэкенд traefik), `forgejoSsh` (entrypoint traefik + firewall на vpn + `SSH_PORT` в forgejo), `headscale` (сервис + listen_addr + бэкенд traefik).

## SSH до forgejo

`git.mih4n.xyz` указывает на `vpn`, а traefik проксирует только HTTP. SSH идёт отдельным TCP-роутером:

```
vpn:2222  →  git.bytes:22  →  forced command forgejo
```

Отсюда `ssh://forgejo@git.mih4n.xyz:2222/<owner>/<repo>.git`. Порт 22 на этом домене — это sshd самого vpn, forgejo там нет.

Ключи — резидентные FIDO2 с `verify-required`, так что при пуше запрашивается PIN и касание. Хэндлы лежат в `modules/features/yubikey/keys/` и подключаются через `IdentityFile`; приватного материала в них нет, подпись делает только железка. `ssh-add -K` не поможет: в `SSH_AUTH_SOCK` сидит gpg-agent, а он `sk-*` не умеет.

## Sops

```bash
sops secrets/secrets.yaml            # править
sops updatekeys secrets/secrets.yaml # после добавления получателя в .sops.yaml
```

Age-ключ хоста выводится из его ssh host key:

```bash
sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key \
  | nix shell nixpkgs#age -c age-keygen -y
```

## Новая машина

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#<host> \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix user@host
```

Для ISO нужна отдельная конфигурация — `base` это nixosModule, а не nixosConfiguration,
поэтому `nixos-generators --flake .#base` из старого README не работает:

```bash
nix run nixpkgs#nixos-generators -- --format iso --flake .#<host> -o result
```

## Сеть

```bash
ip route | grep default      # устройства на виртуальном бридже
ip neigh show dev vmbrlo
```
