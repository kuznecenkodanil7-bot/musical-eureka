# Asset Manifest — что за что отвечает

Каждая строка — отдельный ассет/слот для замены. Сейчас часть объектов используется как процедурная заглушка в `scripts/Main.gd`, но файлы уже разложены по папкам для будущей замены.

| ID | Тип | Файл | Для чего нужен | Чем заменить | Приоритет |
|---|---|---|---|---|---|
| `icon_placeholder` | texture | `assets/textures/icon_placeholder.png` | Иконка проекта Godot, можно заменить на лого игры. | PBR/PNG texture with matching mood | medium |
| `wood_floor_old` | texture | `assets/textures/wood_floor_old.png` | Старый деревянный пол в квартире. | PBR/PNG texture with matching mood | high |
| `wall_plaster_sepia` | texture | `assets/textures/wall_plaster_sepia.png` | Потёртые стены в гостиной/коридоре. | PBR/PNG texture with matching mood | high |
| `wall_plaster_cold` | texture | `assets/textures/wall_plaster_cold.png` | Холодная версия стен при росте безумия. | PBR/PNG texture with matching mood | medium |
| `old_letter_paper` | texture | `assets/textures/old_letter_paper.png` | Бумага писем Анны и UI-письма. | PBR/PNG texture with matching mood | high |
| `mailbox_dark_red` | texture | `assets/textures/mailbox_dark_red.png` | Старый тёмно-красный почтовый ящик. | PBR/PNG texture with matching mood | high |
| `blood_stain_overlay` | texture | `assets/textures/blood_stain_overlay.png` | Кровавые пятна/следы при высокой вине. | PBR/PNG texture with matching mood | medium |
| `mirror_dirty_glass` | texture | `assets/textures/mirror_dirty_glass.png` | Грязное зеркало в спальне. | PBR/PNG texture with matching mood | medium |
| `photo_frame_aged` | texture | `assets/textures/photo_frame_aged.png` | Старая рамка фотографии Анны. | PBR/PNG texture with matching mood | medium |
| `anna_dress_fabric` | texture | `assets/textures/anna_dress_fabric.png` | Платье Анны в спальне. | PBR/PNG texture with matching mood | medium |
| `rain_window_glass` | texture | `assets/textures/rain_window_glass.png` | Окно с дождевыми потёками. | PBR/PNG texture with matching mood | medium |
| `sofa_worn_fabric` | texture | `assets/textures/sofa_worn_fabric.png` | Потёртая ткань дивана. | PBR/PNG texture with matching mood | medium |
| `kitchen_tile_dirty` | texture | `assets/textures/kitchen_tile_dirty.png` | Грязная кухонная плитка/поверхности. | PBR/PNG texture with matching mood | medium |
| `bottle_dark_glass` | texture | `assets/textures/bottle_dark_glass.png` | Стекло бутылки, связанной с виной героя. | PBR/PNG texture with matching mood | medium |
| `wall_writing_late` | texture | `assets/textures/wall_writing_late.png` | Надписи на стене на поздней стадии безумия. | PBR/PNG texture with matching mood | medium |
| `burnt_paper_edges` | texture | `assets/textures/burnt_paper_edges.png` | Обгоревшие края писем для финала. | PBR/PNG texture with matching mood | medium |
| `old_apartment_room` | model | `assets/models/old_apartment_room.obj` | Базовая модель квартиры/комнат вместо примитивных стен. | Low-poly or realistic 3D model, GLB/FBX/OBJ | high |
| `old_mailbox` | model | `assets/models/old_mailbox.obj` | Почтовый ящик — главный интерактив для писем. | Low-poly or realistic 3D model, GLB/FBX/OBJ | high |
| `wooden_table` | model | `assets/models/wooden_table.obj` | Старый стол в гостиной для финального выбора. | Low-poly or realistic 3D model, GLB/FBX/OBJ | high |
| `paper_letter_stack` | model | `assets/models/paper_letter_stack.obj` | Стопка писем/конверты на столе. | Low-poly or realistic 3D model, GLB/FBX/OBJ | high |
| `worn_sofa` | model | `assets/models/worn_sofa.obj` | Старый диван в гостиной. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `old_bed` | model | `assets/models/old_bed.obj` | Кровать в спальне. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `anna_dress` | model | `assets/models/anna_dress.obj` | Платье Анны, интерактивный объект памяти. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `antique_mirror` | model | `assets/models/antique_mirror.obj` | Зеркало для horror-эффектов. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `dark_bottle` | model | `assets/models/dark_bottle.obj` | Бутылка как предмет вины. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `old_phone` | model | `assets/models/old_phone.obj` | Телефон с пропущенными звонками. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `photo_frame` | model | `assets/models/photo_frame.obj` | Фотография Анны. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `old_door` | model | `assets/models/old_door.obj` | Дверь финального перехода. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `rain_window` | model | `assets/models/rain_window.obj` | Окно с дождём. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `corridor_hallway` | model | `assets/models/corridor_hallway.obj` | Коридор квартиры. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `flower_vase` | model | `assets/models/flower_vase.obj` | Романтический объект при высоком love_score. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |
| `candle` | model | `assets/models/candle.obj` | Свеча/источник атмосферы. | Low-poly or realistic 3D model, GLB/FBX/OBJ | medium |