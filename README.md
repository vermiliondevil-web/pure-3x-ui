# 🌐 Pure X-UI (Clean & Independent Fork)

[Русский](#русский) | [English](#english)

---

## Русский

**Pure X-UI** — это полностью независимый, очищенный от рекламы и коммерческих трекеров форк популярной панели управления VPN/прокси-серверами 3X-UI. 

Проект создан с целью вернуть софту его первоначальный дух open-source: абсолютную прозрачность, безопасность данных пользователей и автономность работы без привязки к внешним серверам монетизации оригинального разработчика.

### 🎯 Главные отличия и улучшения:
* **100% White-Label (Без рекламы):** Полностью вырезаны спонсорские слоты (`sponsors.sanaei.dev`), рекламные баннеры на главной странице и в боковом меню, а также ссылки на донатные платформы автора.
* **Автономность и безопасность:** Из скриптов установки и веб-интерфейса удалены скрытые вызовы внешних ресурсов, которые могли использоваться для телеметрии и отслеживания активности серверов.
* **СНГ-ориентированная маршрутизация:** В экосистему встроен готовый пресет роутинга для РФ и стран СНГ на базе актуальных правил **Loyalsoldier**. Из коробки работает корректное разделение трафика (Split-DNS) для защиты сервера от обнаружения DPI/ТСПУ и блокировок со стороны локальных ресурсов.
* **Чистый код:** Проект строго следует лицензии **GNU GPL v3.0**. Весь код открыт для независимого аудита безопасности.

### 🛠 Установка
Для развертывания очищенной версии панели на вашем сервере (поддерживаются Ubuntu, Debian, CentOS, Arch, Alpine) выполните команду:
```bash
bash <(curl -Ls https://githubusercontent.com)
```


---

## English

**Pure X-UI** is a fully independent, ad-free, and open-source fork of the 3X-UI proxy management panel.

This repository was created to purge commercial monetization scripts, tracking tokens, and third-party ad platforms from the software. Our goal is to provide system administrators with a transparent, privacy-respecting, and secure tool for managing Xray-core networks.

### 🎯 Key Features & Enhancements:
* **100% Ad-Free (Pure Open-Source):** Completely removed all sponsor slots (`sponsors.sanaei.dev`), commercial trackers, and donation links embedded by the upstream developer.
* **Enhanced Privacy & Autonomy:** Eliminated background calls to third-party verification servers, ensuring your node statistics and administration habits remain entirely private.
* **Advanced Routing Out-of-the-Box:** Pre-configured with flexible routing presets (including **Loyalsoldier** rule-sets) designed to easily bypass aggressive DPI filtering, protect nodes from active probing, and handle complex Split-DNS scenarios.
* **Fully Auditable:** Compliant with the **GNU GPL v3.0** license. No hidden binaries, no obfuscated code.

### 🛠 Installation
To install this clean version on your VPS (supports Ubuntu, Debian, CentOS, Arch, Alpine), run the following command:
```bash
bash <(curl -Ls https://githubusercontent.com)
```

