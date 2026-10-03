# Motion Foundations

## Характер

Motion Card Impact ощущается как физический печатный объект: короткое сжатие, направленный выход, резкая смена цветового слоя и контролируемый snap. Он не имитирует реалистичную бумагу, инерцию камеры или 3D.

Три уровня интенсивности:

1. **Micro** — нажатие, switch, selection, stepper.
2. **Impact** — исход слова, warning, смена шага, результат раунда.
3. **Climax** — победа и редкий hero reveal.

На экране одновременно используется максимум один Impact/Climax-эффект.

## Duration tokens

| Token | Value | Usage |
| --- | ---: | --- |
| `motionInstant` | 80 ms | Highlight, numeric crossfade |
| `motionPress` | 120 ms | Button press/release |
| `motionMicro` | 160 ms | Toggle, badge, impact mark |
| `motionFeedback` | 200 ms | Semantic reveal, timer state change |
| `motionTransition` | 280 ms | Setup navigation, overlay |
| `motionCardExit` | 220 ms | Resolved word leaves screen |
| `motionCardEnter` | 160 ms | Next word enters |
| `motionResult` | 520 ms | Round result reveal |
| `motionVictory` | 720 ms | Final victory choreography |

Полный цикл замены слова занимает 380 ms: 220 ms exit + 160 ms enter.

## Easing tokens

| Token | SwiftUI intent | Usage |
| --- | --- | --- |
| `easeImpactOut` | cubic `0.20, 0.80, 0.20, 1.00` | Marks, overlay, result content |
| `easeExit` | cubic `0.40, 0.00, 1.00, 1.00` | Card leaving screen |
| `easeStandard` | cubic `0.40, 0.00, 0.20, 1.00` | Navigation and color states |
| `springReturn` | response `0.30`, damping `0.82` | Cancelled drag |
| `springEnter` | response `0.34`, damping `0.88` | Next card and result card |
| `springImpact` | response `0.28`, damping `0.72` | Score or victory hit |

Spring используется только там, где объект физически возвращается или ударно появляется. Нельзя заменять им каждый fade и navigation transition.

## Distance and scale

- Press translation: 3–4 pt вниз.
- Press scale: minimum 0.985.
- Setup transition distance: 20 pt.
- Overlay content entry: 12 pt.
- Next-card entry: 12 pt снизу.
- Normal feedback scale range: 0.96...1.04.
- Victory scale range: максимум 0.86...1.08.
- Rotation допускается только у word card и hero card; максимум 5° в gameplay.

## Input policy

- Motion никогда не определяет game state.
- Semantic action фиксируется до начала exit animation.
- Input lock длится только до готовности следующего интерактивного состояния.
- Повторный tap во время lock игнорируется, а не ставится в очередь.
- Timer продолжает работать во время card transition.
- Потеря foreground немедленно отменяет transient motion и переводит игру в Pause.

## Reduce Motion

Когда Reduce Motion включён:

- direction сохраняется через 8–12 pt translation, но большие exits и rotation убираются;
- spring заменяется `easeImpactOut`;
- scale ограничивается диапазоном 0.98...1.02;
- countdown использует dissolve;
- victory использует последовательный fade без burst expansion;
- duration не становится длиннее обычной версии.

## Запрещено

- одновременно анимировать весь экран и главный интерактивный объект;
- perpetual floating, breathing или wobble;
- bounce у системных ошибок;
- blur transition;
- overshoot больше 8%;
- haptic каждую секунду timer;
- запуск следующего game event по завершению необязательной декоративной анимации;
- sound, меняющий длительность interaction.
