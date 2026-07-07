# Сборка Windows EXE через GitHub Actions

Это не GitHub Pages. Этот workflow собирает обычный `.exe` файл Godot-игры.

## Структура в репозитории

В корне должны лежать:

```text
project.godot
export_presets.cfg
.github/workflows/main.yml
assets/
docs/
scenes/
scripts/
```

## Как запустить сборку

1. Загрузи проект в GitHub.
2. Открой вкладку `Actions`.
3. Выбери `Build Godot Windows EXE`.
4. Нажми `Run workflow`.
5. Дождись зелёной галочки.
6. Открой завершённый запуск.
7. Внизу скачай artifact `HomeThatRemembers_Windows`.
8. Внутри будет `HomeThatRemembers.exe`.

## Если Godot не скачивается

Workflow скачивает Godot с GitHub Releases. Если GitHub временно не отдаёт файл, просто запусти сборку ещё раз.
