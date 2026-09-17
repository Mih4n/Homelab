# Миграция desktop на disko + preservation

Итоговая раскладка:

| Диск | Роль | Разметка |
|---|---|---|
| Kingston KC3000 1 ТБ (`nvme1n1`) | системный | ESP 1 ГБ + btrfs `system`: `@root` (стирается при каждой загрузке), `@nix`, `@persist`, `@home`, `@log`, `@swap` (swapfile 32 ГБ) |
| ADATA Legend 850 2 ТБ (`nvme0n1`) | данные | btrfs `data`: `@data` → `/mnt/data`, плюс `@games`, `@downloads`, `@videos`, `@nextcloud` → монтируются прямо в `~` |
| Samsung HM500JI 466 ГБ (`sda`) | архив | btrfs `archive` → `/mnt/archive` |

Windows удаляется вместе с разметкой Kingston, `useOSProber` в GRUB выключен.

> **Нельзя** запускать `disko --mode destroy,format,mount --flake .#desktop`: полная
> конфигурация описывает все три диска и сотрёт в том числе уже установленный Kingston.
> Для поэтапного применения есть `#desktop-stage-main` и `#desktop-stage-data`.

## Этап 0. Подготовка (на текущей системе)

1. **Сохранить ключи хоста** — из них sops выводит age-ключ, без них секреты не
   расшифруются:

   ```fish
   mkdir -p /run/media/mih4n/USB/keys
   sudo cp -a /etc/ssh/ssh_host_* /run/media/mih4n/USB/keys/
   ```

2. Закоммитить конфигурацию: флейк читает git-дерево, незакоммиченные файлы для
   `nix` не существуют.

   ```fish
   cd ~/NixOs; git add -A; git commit -m "desktop: disko + preservation"
   ```

3. Прогреть кэш, чтобы установка не качала всё с нуля:

   ```fish
   nix build ~/NixOs#nixosConfigurations.desktop-stage-main.config.system.build.toplevel
   ```

4. Записать live USB с NixOS unstable и загрузиться с него.

## Этап 1. Kingston: разметка, установка, перенос домашки

Все команды — из live-окружения, от root.

1. Смонтировать старый корень (ADATA пока не трогаем вообще):

   ```sh
   mkdir -p /old
   mount -o ro /dev/disk/by-label/root /old   # старый ext4 на ADATA
   FLAKE=/old/home/mih4n/NixOs
   ```

   Монтируем именно в `/old`, а не в `/mnt/old`: disko на следующем шаге
   смонтирует новую систему в `/mnt` и скрыл бы старый корень.

2. Разметить **только** Kingston:

   ```sh
   nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
       --mode destroy,format,mount --flake "$FLAKE#desktop-stage-main"
   ```

   Здесь же disko снимает снапшот `@root-blank` — из него initrd восстанавливает
   корень при каждой загрузке.

3. Положить сохранённые ключи хоста на постоянный том (preservation ожидает их
   именно там):

   ```sh
   mkdir -p /mnt/persist/etc/ssh
   cp -a /путь/к/USB/keys/ssh_host_* /mnt/persist/etc/ssh/
   chown root:root /mnt/persist/etc/ssh/ssh_host_*
   chmod 600 /mnt/persist/etc/ssh/ssh_host_*_key
   chmod 644 /mnt/persist/etc/ssh/ssh_host_*_key.pub
   ```

4. Установить систему в конфигурации первого этапа (ADATA и sda в ней не
   упоминаются, поэтому система загрузится, пока они ещё не размечены):

   ```sh
   nixos-install --flake "$FLAKE#desktop-stage-main" --no-root-passwd
   ```

5. Перенести домашний каталог. Тяжёлые каталоги кладём во временный
   `.migrate`, иначе после этапа 2 их скроют монтирования с ADATA:

   ```sh
   HEAVY="Games Downloads Videos Nextcloud"

   rsync -aHAX --info=progress2 \
       $(for d in $HEAVY; do echo --exclude=/$d; done) \
       /old/home/mih4n/ /mnt/home/mih4n/

   mkdir -p /mnt/home/mih4n/.migrate
   for d in $HEAVY; do
       rsync -aHAX --info=progress2 "/old/home/mih4n/$d" /mnt/home/mih4n/.migrate/
   done

   # albiononline переезжает внутрь Games, winboat не переносится вовсе
   rsync -aHAX --info=progress2 /old/home/mih4n/albiononline /mnt/home/mih4n/.migrate/Games/

   # rsync сохраняет численные uid/gid, chown нужен только если они разъехались
   chown -R 1000:100 /mnt/home/mih4n
   ```

   Всё вместе — около 590 ГБ, на Kingston это помещается (после `/nix` остаётся
   ~830 ГБ).

6. Сверить объёмы (`du -sh /old/home/mih4n /mnt/home/mih4n`), затем
   `umount -R /mnt /old` и перезагрузиться в новую систему.

7. Проверить до перехода к этапу 2:
   - система грузится, автологин работает;
   - `sudo systemctl status sops-install-secrets` — секреты расшифровались;
   - `swapon --show` показывает 32 ГБ;
   - после перезагрузки в `/` нет мусора, а `/home` и `/persist` на месте.

**Данные ADATA на этом этапе ещё целы** — если что-то пошло не так, старый корень
можно смонтировать и скопировать заново.

## Этап 2. ADATA и Samsung

1. Убедиться, что всё нужное уже на Kingston. После этого шага старый корень и
   NTFS-раздел с играми исчезнут навсегда.

2. Разметить оставшиеся два диска:

   ```fish
   sudo nix run github:nix-community/disko/latest -- \
       --mode destroy,format --flake ~/NixOs#desktop-stage-data
   ```

3. Переключиться на полную конфигурацию — она смонтирует `/mnt/data`,
   `/mnt/archive` и каталоги в `~`:

   ```fish
   sudo nixos-rebuild switch --flake ~/NixOs#desktop
   ```

4. Разложить тяжёлые каталоги по их местам на ADATA и убрать временный каталог:

   ```fish
   for d in Games Downloads Videos Nextcloud
       rsync -aHAX --info=progress2 ~/.migrate/$d/ ~/$d/
   end
   rm -rf ~/.migrate
   ```

## Этап 3. Убрать Windows из UEFI

Раздел Windows уже стёрт, но запись в NVRAM материнской платы остаётся:

```fish
sudo nix shell nixpkgs#efibootmgr -c efibootmgr          # найти Windows Boot Manager
sudo nix shell nixpkgs#efibootmgr -c efibootmgr -b XXXX -B   # XXXX — номер записи
```

## Что дальше

- Корень стирается при каждой загрузке. Если после перезагрузки пропало
  состояние какой-то службы — добавить путь в `bytes.impermanence.directories`
  или `.files` в `modules/hosts/desktop/configuration.nix`.
- `/home` постоянный, блэклист эфемерных каталогов — `bytes.impermanence.ephemeralHome`
  (они монтируются как tmpfs, по умолчанию 4 ГБ на каталог).
- `users.mutableUsers = false`: пароль задаётся только через `hashedPassword`,
  `passwd` перезагрузку не переживёт.
- Штатный откат: `btrfs subvolume snapshot` старого `@root` не сохраняется, так
  что важное состояние должно быть описано в конфиге, а не отложено «на потом».
