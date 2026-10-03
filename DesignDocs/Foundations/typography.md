# Typography

## Шрифтовая система

### Display: Sofia Sans Extra Condensed

Используется для:

- игрового слова;
- крупных результатов;
- display-заголовков;
- номеров раунда;
- коротких кульминационных сообщений.

Рабочее начертание: **Black**. Допустимое резервное начертание: ExtraBold.

Причины выбора:

- выраженная вертикальная энергия;
- хорошая экономия ширины;
- расширенная кириллица;
- широкий диапазон веса;
- открытая лицензия SIL OFL 1.1;
- связь с технической и плакатной типографикой без ощущения esports UI.

### Interface: SF Pro

Используется для:

- кнопок;
- навигации;
- инструкций;
- настроек;
- body и caption;
- accessibility-размеров.

Таймер использует системный SF Pro Black с condensed width и tabular digits. Это обеспечивает стабильную ширину цифр и естественную интеграцию с iOS.

## Типографическая шкала

| Style | Family | Size | Weight | Usage |
| --- | --- | ---: | --- | --- |
| `scoreHero` | Sofia Sans Extra Condensed | 88 | Black | Победный счёт и кульминация |
| `displayHero` | Sofia Sans Extra Condensed | 72 | Black | Брендовый display и крупный заголовок |
| `gameWord` | Sofia Sans Extra Condensed | 64 | Black | Текущее слово |
| `gameTimer` | SF Pro Condensed | 56 | Black | Таймер с tabular digits |
| `screenTitle` | Sofia Sans Extra Condensed | 40 | Black | Короткий заголовок экрана |
| `sectionTitle` | SF Pro | 24 | Bold | Разделы и крупные значения |
| `actionLabel` | SF Pro | 20 | Bold | Кнопки и игровые действия |
| `bodyEmphasis` | SF Pro | 17 | Semibold | Важный интерфейсный текст |
| `body` | SF Pro | 17 | Regular | Основной текст |
| `bodySmall` | SF Pro | 15 | Regular | Вторичный текст |
| `caption` | SF Pro | 13 | Medium | Метаданные и краткие пояснения |

## Игровое слово

- По умолчанию отображается uppercase.
- Максимум две строки.
- Базовый размер 64 pt.
- Допустимый минимум при автоматическом уменьшении — 40 pt.
- Межстрочный интервал компактный, но буквы не соприкасаются.
- Горизонтальный внутренний отступ карточки — минимум 24 pt.
- Для слов, которые не помещаются в две строки при 40 pt, используется отдельная адаптивная компоновка, а не дальнейшее бесконтрольное уменьшение.
- Нельзя искажать ширину или высоту глифов ради помещения текста.

## Dynamic Type

- Все interface styles строятся относительно системных text styles и поддерживают Dynamic Type.
- `gameWord`, `gameTimer` и `scoreHero` масштабируются в пределах доступной композиции, а не бесконечно увеличивают экран.
- При accessibility-размерах вторичные элементы переходят в вертикальную компоновку.
- Полное слово и значение таймера дублируются для VoiceOver независимо от визуального масштаба.
- Кнопки допускают две строки, но не обрезают смысл действия.

## Ограничения

- Sofia Sans не используется для длинных инструкций.
- На одном экране используется не более двух семейств.
- Italic не входит в основную систему.
- Letter spacing для display-текста остаётся нейтральным или слегка отрицательным; для uppercase caption допускается положительный tracking.
- Деформация букв разрешена только в motion-переходах и не применяется к активному слову во время чтения.

## Источники

- [Sofia Sans repository and OFL license](https://github.com/lettersoup/Sofia-Sans)
- [Apple design resources: SF Pro](https://developer.apple.com/design/resources/)
- [Apple typography guidance](https://developer.apple.com/design/human-interface-guidelines/typography)

