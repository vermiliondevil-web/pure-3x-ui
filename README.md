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
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/v3.10.0/install.sh)
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
