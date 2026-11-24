## pure-3x-ui [English version](README.en.md) 

[![Build and Release](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml)
[![Sync Upstream](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml)
[![Release](https://img.shields.io/github/v/release/vermiliondevil-web/pure-3x-ui?label=release)](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
[![License](https://img.shields.io/github/license/vermiliondevil-web/pure-3x-ui)](LICENSE)

## [Как это работает](docs/how-it-works.md)
## [Известные ограничения](docs/known-limitations.md)
## [Безопасность](docs/security.md)
## [Региональные блокировки хостеров](docs/Regional-lockout.md)
## [Мнение к оригиналу](docs/Heads-up.md)
## [О проекте и автоматизации сборок](docs/project-related.md)

### Текущее состояние синхронизации и сборки

- **Форк:** [Releases](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest) **Upstream:** [Releases](https://github.com/MHSanaei/3x-ui/releases) **Лог выхода релизов:** [docs/upstream-changelog.md](docs/upstream-changelog.md)

> **Это форк.** Проект является производной работой от [3x-ui](https://github.com/MHSanaei/3x-ui) (автор — [MHSanaei](https://github.com/MHSanaei)) и распространяется под лицензией **AGPL-3.0**. Все изменения, внесённые в этот форк, публикуются под той же лицензией.

Чистая сборка [3x-ui](https://github.com/MHSanaei/3x-ui) без рекламы и донат-блоков.



## Отслеживание upstream-релизов

Этот форк **не обновляется** на каждый релиз upstream. Ниже — что выходило, что взято и почему.

| Дата | Upstream | Что в нём | Решение |
|------|----------|-----------|---------|
| 2026-10-10 | v3.10.0 | MASQUE, WARP modal, Xray 26.10.10, systemd sandbox | ✅ взято (боевой + тестовый) |
| 2026-10-13 | v3.10.2 | Shadowsocks hot apply, node sync load, vmess import, MTProto limit, sponsor SNI fix, Windows 3x-ui.exe | ❌ пропущено |

### Почему v3.10.2 пропущен

- **Shadowsocks hot apply** — только для multi-user Shadowsocks. Не используется.
- **Node sync load** — только для многонодовых сетапов. Только мастер.
- **vmess link import** — только при импорте vmess-ссылок. Не используется.
- **MTProto handshake limit** — только для MTProto. Не используется.
- **Sponsor SNI fix** — спонсоры вырезаны, неактуально.
- **Windows 3x-ui.exe** — сборка для Linux, неактуально.
- **Core crash reports** — полезно, но не критично.

---


## Установка

### Основной способ (рекомендуется)

Запустите от имени **root**:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
```

### Альтернативные способы

```bash
# 1. Через github.com/raw (редиректит на raw.githubusercontent)
bash <(curl -Ls "https://github.com/vermiliondevil-web/pure-3x-ui/raw/main/install.sh")

# 2. С конкретным тегом (стабильный релиз)
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/v3.9.22/install.sh)
```
## Docker (альтернативный форк)

Этот форк **не включает** Docker-сборку (используйте `install.sh` для личных VPS).

Если вам нужен **Docker-образ**, посмотрите форк [@Az-1-2](https://github.com/Az-1-2):
он поддерживает Docker-сборку и инструкции по установке.


### Что делает скрипт

1. Определяет ОС и архитектуру.
2. Устанавливает зависимости.
3. Скачивает последний релиз из **этого** репозитория.
4. Проверяет `.sha256`.
5. Настраивает сервис, базу данных, SSL.
6. Выводит **логин, пароль, порт, webBasePath** и **URL** панели.

---

## Управление

```bash
x-ui              # Меню управления
x-ui start        # Запустить
x-ui stop         # Остановить
x-ui restart      # Перезапустить
x-ui status       # Статус
x-ui settings     # Текущие настройки
x-ui enable       # Включить автозапуск
x-ui disable      # Отключить автозапуск
x-ui log          # Логи
x-ui banlog       # Логи банов Fail2ban
x-ui update       # Обновить
x-ui install      # Установить
x-ui uninstall    # Удалить
```

---

## Обновление

### Через UI (кнопка «Обновить»)

Панель **сама проверяет** последний релиз на GitHub через
`api.github.com/repos/vermiliondevil-web/pure-3x-ui/releases/latest`
и **скачивает** `update.sh` с `raw.githubusercontent.com`.

| Версия в файле | Тег на GitHub | Кнопка |
|---|---|---|
| `3.9.21` | `v3.9.21` | ❌ неактивна |
| `3.9.21` | `v3.9.22` | ✅ активна |
| `3.9.22` | `v3.9.22` | ❌ неактивна |

### Через `install.sh`

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
```

### Xray core

Кнопка обновления Xray в панели **безопасна** — она тянет ядро напрямую с [XTLS/Xray-core](https://github.com/XTLS/Xray-core), где **нет** рекламы.

**Важно:** обновление панели **не** перезаписывает установленное ядро Xray — версия сохраняется такой, какой ты её выбрал через Settings → Xray Updates. Подробности — [docs/xray-core-preservation.md](docs/xray-core-preservation.md).

---

## Сборка из исходников

```bash
git clone https://github.com/vermiliondevil-web/pure-3x-ui.git
cd pure-3x-ui/frontend
npm install
npm run build
cd ..
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o x-ui-main main.go
```

Бинарник появится как `./x-ui-main`.

---



## Безопасность

### CVE-2026-55477: Запись произвольных файлов аутентифицированным администратором

**Что это:** В версиях 3x-ui **до 3.3.1** аутентифицированный администратор мог через импорт базы данных или редактор конфига Xray добиться **записи произвольного файла** на сервере. Манипулируя значением `xrayTemplateConfig.log.access`, злоумышленник мог перенаправить лог доступа Xray в любой файл файловой системы — включая `~/.ssh/authorized_keys`.

**Последствия:** Если Xray запущен от имени root — **полный захват сервера**.

**Оценка CVSS:** 7.2 (High).

**Затронут ли этот форк?** **Нет.** Этот форк основан на **v3.9.22**, что значительно выше исправленной версии 3.3.1.

### Устранена утечка `sponsors.sanaei.dev`

**Что было:** `internal/web/service/panel/sponsor.go` содержал жёстко прописанные URL:

```
https://sponsors.sanaei.dev/3X/sponsors.json
https://sponsors.sanaei.dev/3X/logos/
```

При каждом открытии страницы логина панель отправляла запрос на `sponsors.sanaei.dev` — раскрывая **IP сервера** и **SNI** третьей стороне. Для операторов в странах с цензурой это позволяло DPI идентифицировать панель как 3x-ui.

**Что сделано:**

- `sponsor.go` заменён на **stub** (функции возвращают пустые значения, сетевых запросов нет).
- `scripts/remove-ads.sh` **автоматически** заменяет `sponsor.go` на stub после каждого `Sync Upstream`.

**Проверка:**

```bash
strings /usr/local/x-ui/x-ui | grep -c "sponsors.sanaei.dev"
# Ожидаемо: 0
```

### Другие меры безопасности (унаследованы)

- **Ограничение IP на клиента** с интеграцией fail2ban.
- **API-токены с гранулярными областями** (SHA-256 хеши).
- **Двухфакторная аутентификация TOTP**.
- **Защита CSRF, ограничение скорости входа, защита от SSRF**.
- **Защита от path traversal** (проверено тестом `TestGeodataRejectsBadRequests`).

### Что осталось (унаследовано, не исправлено)

- **IP-адреса клиентов хранятся в открытом виде** в базе SQLite (`inbound_client_ips`, `node_client_ip`).
- **Панель сканирует своё окружение** при запуске.

### Рекомендации для операторов

1. **Обновитесь до v3.3.1+** (этот форк уже выше).
2. **Смените учётные данные администратора** сразу после установки.
3. **Ограничьте доступ к панели** доверенными IP.
4. **Запускайте Xray с минимальными привилегиями**.
5. **Включите fail2ban**.
6. **Регулярно делайте резервные копии** базы.

---

## Происхождение и лицензия

### Это форк

`pure-3x-ui` — производная работа (форк) от [3x-ui](https://github.com/MHSanaei/3x-ui).

- Проект **не является** оригинальной разработкой.
- Основа — код [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui).
- Все изменения — надстройка над оригиналом.
- Оригинальный автор **не несёт ответственности** за этот форк.

### Лицензия AGPL-3.0

Проект распространяется под лицензией **GNU Affero General Public License v3.0** (AGPL-3.0).

**Что это значит:**

- ✅ Можно использовать, изменять, распространять.
- ✅ Можно делать форки.
- ⚠️ Обязательно сохранять ту же лицензию (AGPL-3.0).
- ⚠️ Обязательно указывать автора оригинала.
- ⚠️ Если вы даёте доступ к панели по сети — вы обязаны предоставить исходный код.
- ⚠️ Нельзя делать закрытые форки.

### Ссылки

- **Этот форк:** https://github.com/vermiliondevil-web/pure-3x-ui
- **Оригинал:** https://github.com/MHSanaei/3x-ui
- **Текст лицензии:** [LICENSE](LICENSE)

---

## Благодарности

- [MHSanaei](https://github.com/MHSanaei) — за оригинальный 3x-ui
- [XTLS/Xray-core](https://github.com/XTLS/Xray-core) — за ядро Xray
- [Acme.sh](https://github.com/acmesh-official/acme.sh) — за SSL-сертификаты
- [@Az-1-2](https://github.com/Az-1-2) — за идею очистки `SponsorsPage` из `panelRoutes.tsx` (блок `4.1b` в `remove-ads.sh`).
- Всем контрибьюторам оригинального проекта

---

## Обратная связь

- Issues: https://github.com/vermiliondevil-web/pure-3x-ui/issues
- Pull Requests: приветствуются

---

## Дисклеймер

Это **неофициальный форк**. Проект не связан с MHSanaei или XTLS.

Панель предоставляется как есть, для личного и некоммерческого использования.
