# Alias Design Documentation

Эта папка описывает работу над новым визуальным направлением Alias с чистого листа.

Если работа продолжается в новом чате, сначала необходимо прочитать [HANDOFF.md](HANDOFF.md). В нём зафиксированы контекст проекта, принятые решения, стиль взаимодействия с владельцем продукта и точка продолжения.

Выбранное направление — **Kinetic Play**: энергичное мобильное игровое шоу с крупной типографикой, контрастной композицией, физичными жестами и выразительной сменой игровых состояний.

Направление не является гибридом с Table Talk или другими исследованными концепциями. Любое изменение этой договорённости должно быть отдельно зафиксировано как новое дизайн-решение.

## Принципы процесса

- Сначала проверяется визуальная система на ключевом игровом цикле, затем проектируются вспомогательные экраны.
- Существующие экраны, их количество, порядок и формат не являются ограничением. Сохраняются обязательные функции и игровые правила, а информационная архитектура проектируется заново.
- Один экран решает одну главную пользовательскую задачу.
- Состояния, motion и обратная связь проектируются одновременно с основным экраном.
- Дизайн проверяется на техническую реализуемость в SwiftUI до передачи в разработку.
- Декоративный эффект не должен ухудшать читаемость, доступность или скорость игрового взаимодействия.
- Каждое принятое решение должно масштабироваться на весь продукт, а не только хорошо выглядеть на одном экране.

## Последовательность работ

1. [Визуальная основа Kinetic Play](01-visual-foundation.md)
2. [Проверка на ключевых экранах](02-key-screen-validation.md)
3. [Проектирование активного раунда](03-active-round.md)
4. [Motion-язык и обратная связь](04-motion-language.md)
5. [Компоненты дизайн-системы](05-design-system.md)
6. [Оставшиеся продуктовые сценарии](06-complete-product-flow.md)
7. [Передача в SwiftUI](07-swiftui-handoff.md)
8. [Дизайн-контроль реализации](08-design-qa.md)

## Дополнительные материалы

- [Контекст для продолжения в новом чате](HANDOFF.md)
- [Выбранное креативное направление](00-creative-direction.md)
- [Card Impact Foundations v1](Foundations/README.md)
- [Визуальные исследования](VisualReferences/)
- [Experience Storyboard](VisualReferences/11-card-impact-experience-storyboard.png)
- [Game Pulse — настройки](VisualReferences/12-card-impact-game-pulse-v2.png)
- [Live Card — core states](VisualReferences/13-live-card-core-states.png)
- [Live Card — system states](VisualReferences/14-live-card-system-states.png)
- [Motion — card resolution](VisualReferences/15-motion-card-resolution.png)
- [Motion — resume countdown](VisualReferences/16-motion-resume-countdown.png)
- [Component board — Actions & Setup](VisualReferences/17-card-impact-actions-setup.png)
- [Component board — Game & Feedback](VisualReferences/18-card-impact-game-feedback.png)
- [Product flow — Entry & Setup](VisualReferences/19-card-impact-setup-flow-v2.png)
- [Product flow — Match & Results](VisualReferences/20-card-impact-match-flow.png)
- [Product flow — System States](VisualReferences/21-card-impact-system-flows-v2.png)

## Контрольные точки

Каждый этап завершается самостоятельным результатом и проверкой критериев готовности. Следующий этап может начинаться до окончательного завершения предыдущего только тогда, когда это не требует принятия ещё не подтверждённых визуальных решений.

Текущий статус: **этапы 1–7 завершены**. Зафиксированы Foundations v1, Experience Architecture v1, Live Card v1, Motion Language v1, Component Library v1, Complete Product Flow v1 и [SwiftUI Handoff v1](07-swiftui-handoff.md). Следующая работа — реализация по безопасным vertical slices; дизайн-контроль каждого собранного slice выполняется по этапу 8.

Архитектура опыта: [09-experience-architecture.md](09-experience-architecture.md).

Активный раунд: [10-live-card-spec.md](10-live-card-spec.md).

Motion: [11-motion-spec.md](11-motion-spec.md).

Компоненты: [12-component-library.md](12-component-library.md).

Оставшиеся экраны: [13-entry-and-setup-spec.md](13-entry-and-setup-spec.md), [14-match-and-results-spec.md](14-match-and-results-spec.md), [15-system-flows-and-edge-cases.md](15-system-flows-and-edge-cases.md).
