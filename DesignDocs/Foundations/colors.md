# Colors

## Основная палитра

| Token | Hex | Назначение | Текст поверх |
| --- | --- | --- | --- |
| `ink900` | `#121319` | Основной фон и основной текст | `bone50` |
| `ink800` | `#20222B` | Поднятая тёмная поверхность | `bone50` |
| `bone50` | `#F4EFE6` | Основная светлая поверхность | `ink900` |
| `bone100` | `#E7E0D6` | Вторичная и disabled поверхность | `ink900` |
| `cobalt500` | `#3157FF` | Primary action и информационный акцент | `bone50` |
| `chartreuse500` | `#C7F000` | Success и угаданное слово | `ink900` |
| `vermilion500` | `#FF4D2E` | Skip, danger и critical countdown | `ink900` |
| `amber500` | `#FFB11B` | Warning и приближение critical state | `ink900` |

## Семантические роли

| Semantic token | Reference |
| --- | --- |
| `backgroundPrimary` | `ink900` |
| `backgroundElevated` | `ink800` |
| `surfacePrimary` | `bone50` |
| `surfaceMuted` | `bone100` |
| `textOnDark` | `bone50` |
| `textOnLight` | `ink900` |
| `actionPrimary` | `cobalt500` |
| `feedbackSuccess` | `chartreuse500` |
| `feedbackDanger` | `vermilion500` |
| `feedbackWarning` | `amber500` |
| `borderStrong` | `ink900` |

## Проверенные контрастные пары

| Пара | Контраст | Использование |
| --- | ---: | --- |
| Ink / Bone | 16.18:1 | Любой текст |
| Ink / Vermilion | 5.61:1 | Обычный и крупный текст |
| Ink / Chartreuse | 14.03:1 | Любой текст |
| Ink / Amber | 10.20:1 | Любой текст |
| Bone / Cobalt | 4.66:1 | Обычный и крупный текст |
| Ink / Cobalt | 3.48:1 | Только крупный текст и графика |
| Bone / Vermilion | 2.89:1 | Не использовать для текста |
| Bone / Chartreuse | 1.15:1 | Не использовать для текста |

## Правила состояний

- Pressed-состояние не затемняет semantic fill. Физическая обратная связь создаётся смещением компонента и уменьшением flat shadow.
- Disabled-компонент использует `surfaceMuted`, `textOnLight` с opacity 38% и не имеет flat shadow.
- Цвет не является единственным способом различать success, warning и danger.
- Success всегда сопровождается checkmark или текстом «Угадано».
- Skip и danger всегда сопровождаются `xmark`, направлением жеста или явной подписью.
- Critical countdown меняет цвет и форму или ритм, а не только цвет.
- На одном обычном экране допускается один доминирующий сигнальный цвет.

## Expressive-исключение Game Pulse

Пара hero-карточек `До победы / Раунд` может одновременно использовать raw palette colors `chartreuse500` и `vermilion500` как плакатные поля. Это допустимо только при выполнении всех условий:

- используются закрытые product variants `targetScore` и `roundDuration`, а не публичный произвольный accent;
- цвет не сообщает success, danger или validation state;
- на карточках всегда присутствуют явные labels и units;
- success/danger symbols на них отсутствуют;
- исключение не переносится на другие setting cards или обычные экраны.

Во всех остальных случаях chartreuse, vermilion и amber используются через semantic roles.

## Командная палитра

Командный цвет обозначает принадлежность, но никогда не заменяет semantic colors.

| Team token | Hex | Текст | Дополнительный знак |
| --- | --- | --- | --- |
| `team1` | `#8365FF` | `ink900` | Диагональная полоса |
| `team2` | `#23B9A9` | `ink900` | Разделённый круг |
| `team3` | `#F28C28` | `ink900` | Крест |
| `team4` | `#E6538A` | `ink900` | Две точки |
| `team5` | `#72A447` | `ink900` | Chevron |

Правила:

- Командный цвет используется в badge, подложке результата и маркере очереди.
- Primary, success и skip actions не перекрашиваются в цвет команды.
- Название и знак команды показываются вместе с цветом.
- В таблице результатов цвет занимает не более 20% строки.
- Пользователь не обязан различать команды только по цвету.
