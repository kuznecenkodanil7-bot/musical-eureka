# Как собрать Windows .exe в Godot

1. Открой проект через `project.godot`.
2. В Godot открой меню **Project → Export**.
3. Нажми **Add...**.
4. Выбери **Windows Desktop**.
5. Если Godot попросит экспортные шаблоны, нажми **Manage Export Templates** и установи их.
6. В поле экспорта укажи путь, например:

```text
build/LastLetter3D.exe
```

7. Нажми **Export Project**.

После экспорта у тебя будет обычный `.exe`, который запускается без браузера.

## Что НЕ нужно

Для desktop-игры не нужен GitHub Pages и не нужен workflow `main.yml` для сайта. Если у тебя остался файл:

```text
.github/workflows/main.yml
```

и он был создан для GitHub Pages — его можно удалить.
