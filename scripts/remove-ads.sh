#!/bin/bash
# scripts/remove-ads.sh
# Удаляет рекламу и донаты из репозитория pure-3x-ui.
# Запускать из корня репозитория: bash scripts/remove-ads.sh

set -e
cd "$(dirname "$0")/.."

echo "==> [1/6] Удаляем файлы рекламы..."
rm -rf frontend/src/components/sponsor/
rm -f  frontend/src/api/queries/useSponsorsQuery.ts
rm -f  frontend/src/lib/sponsors.ts
rm -f  frontend/src/test/sponsors.test.tsx
rm -rf frontend/src/pages/sponsors/

echo "==> [2/6] Правим AppSidebar.tsx..."
ASB=frontend/src/layouts/AppSidebar.tsx
if [[ -f "$ASB" ]]; then
  # Удаляем импорты
  sed -i '/^  CrownOutlined,$/d' "$ASB"
  sed -i '/^  HeartOutlined,$/d' "$ASB"
  sed -i '/^import SponsorSlot from/d' "$ASB"

  # Удаляем DONATE_URL
  sed -i "/^const DONATE_URL = /d" "$ASB"

  # Удаляем sponsors: CrownOutlined из iconByName
  sed -i '/^  sponsors: CrownOutlined,$/d' "$ASB"

  # Удаляем функцию DonateButton — от строки 'function DonateButton' до закрывающей '}'
  awk '
    /^function DonateButton\(/ { skip=1 }
    skip && /^}$/ { skip=0; next }
    !skip
  ' "$ASB" > "$ASB.tmp" && mv "$ASB.tmp" "$ASB"

  # Удаляем вызовы <DonateButton ... />
  sed -i '/<DonateButton /d' "$ASB"

  # Удаляем <SponsorSlot ... />
  sed -i '/<SponsorSlot /d' "$ASB"
fi

echo "==> [3/6] Правим LoginPage.tsx..."
LGP=frontend/src/pages/login/LoginPage.tsx
if [[ -f "$LGP" ]]; then
  sed -i '/<SponsorSlot /d' "$LGP"
  sed -i '/^import SponsorSlot from/d' "$LGP"
fi

echo "==> [4/6] Правим routes.tsx..."
RTS=frontend/src/routes.tsx
if [[ -f "$RTS" ]]; then
  sed -i "/path: 'sponsors', element:/d" "$RTS"
  sed -i "/SponsorsPage/d" "$RTS"
fi

echo "==> [5/6] Правим usePageTitle.ts и CommandPalette.tsx..."
UPT=frontend/src/hooks/usePageTitle.ts
if [[ -f "$UPT" ]]; then
  sed -i "/'\/sponsors':/d" "$UPT"
fi

CP=frontend/src/components/command-palette/CommandPalette.tsx
if [[ -f "$CP" ]]; then
  awk '
    /path: .\/sponsors./ { skip=1 }
    skip && /},/ { skip=0; next }
    !skip
  ' "$CP" > "$CP.tmp" && mv "$CP.tmp" "$CP"
  sed -i '/^  CrownOutlined,$/d' "$CP"
fi

EP=frontend/src/pages/api-docs/endpoints.ts
if [[ -f "$EP" ]]; then
  awk '
    /path: .\/sponsors./ { skip=2 }
    skip == 1 && /},/ { skip=0; next }
    skip > 0 { skip--; next }
    !skip
  ' "$EP" > "$EP.tmp" && mv "$EP.tmp" "$EP"
fi

echo "==> [6/6] Чистим локали..."
for f in internal/web/translation/*.json; do
  # Удаляем ключ "donate": "..." и "sponsors": "..." (однострочные)
  sed -i '/"donate"[[:space:]]*:/d' "$f"
  sed -i '/"sponsors"[[:space:]]*:[[:space:]]*"/d' "$f"

  # Удаляем блок "sponsors": { ... } — многострочный
  awk '
    /"sponsors"[[:space:]]*:[[:space:]]*\{/ { depth=1; next }
    depth > 0 {
      for (i=1; i<=length($0); i++) {
        c = substr($0, i, 1)
        if (c == "{") depth++
        if (c == "}") depth--
      }
      if (depth == 0) { next }
    }
    !depth
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

echo ""
echo "==> Готово. Проверьте результат:"
echo "    git status"
echo "    git diff --stat"
echo ""
echo "Если всё устраивает:"
echo "    git add -A"
echo "    git commit -m 'chore: strip ads and donations'"
