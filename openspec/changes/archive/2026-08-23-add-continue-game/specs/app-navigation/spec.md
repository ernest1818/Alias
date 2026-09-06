## ADDED Requirements

### Requirement: Continue game entry point

Главное меню SHALL показывать пункт `Continue Game` и SHALL разрешать его выбор
только при наличии корректного сохранения незавершённой игры.

#### Scenario: Continue a saved game

- **GIVEN** существует корректное сохранение незавершённой игры
- **WHEN** пользователь выбирает `Continue Game`
- **THEN** приложение SHALL открыть сохранённую игру

#### Scenario: No game to continue

- **GIVEN** корректного сохранения незавершённой игры нет
- **WHEN** отображается главное меню
- **THEN** пункт `Continue Game` SHALL оставаться видимым
- **AND** SHALL быть визуально и функционально неактивным

### Requirement: Confirm replacement by a new game

Приложение SHALL запросить подтверждение перед началом новой игры, если это
приведёт к удалению существующего сохранения.

#### Scenario: Cancel saved game replacement

- **GIVEN** существует сохранённая незавершённая игра
- **WHEN** пользователь выбирает `New Game` и отменяет замену
- **THEN** приложение SHALL оставить пользователя в главном меню
- **AND** MUST NOT изменять существующее сохранение

#### Scenario: Confirm saved game replacement

- **GIVEN** существует сохранённая незавершённая игра
- **WHEN** пользователь выбирает `New Game` и подтверждает замену
- **THEN** приложение SHALL удалить существующее сохранение
- **AND** SHALL открыть первый шаг создания новой игры

### Requirement: Distinct rules navigation

Пункт `Rules` MUST NOT использовать действие продолжения игры и MUST NOT читать,
изменять или открывать активное сохранение.

#### Scenario: Open rules while a game is saved

- **GIVEN** существует сохранённая незавершённая игра
- **WHEN** пользователь выбирает `Rules`
- **THEN** приложение MUST NOT открывать сохранённую игру
- **AND** MUST NOT изменять её данные

## MODIFIED Requirements

### Requirement: Return to main menu from a game

Во время игрового потока приложение SHALL позволять пользователю безопасно
сохранить незавершённую игру и вернуться в главное меню.

#### Scenario: Leave an active game

- **GIVEN** пользователь находится на экране игрового потока
- **WHEN** пользователь выбирает действие «Меню»
- **THEN** работающий таймер SHALL остановиться
- **AND** текущее игровое состояние SHALL быть сохранено
- **AND** приложение SHALL закрыть весь текущий игровой маршрут
- **AND** SHALL показать главное меню

