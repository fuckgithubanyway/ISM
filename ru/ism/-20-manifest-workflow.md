# ISM Manifest: Workflow

**Версия:** 0.9  
**Статус:** Нормативный

## Контекст Target

ISM-Agent разрешает контекст Target из:

1. Manifest Set;
2. применимых Meta Set — от общей области к конкретной;
3. Target Spec Set.

Канонический порядок файлов определяет чтение и отображение, но не семантическое разрешение контекста.

Более конкретная Meta может переопределить менее конкретную Meta. Любое иное несовместимое нормативное требование является **Collision**.

`order` не разрешает Collision. ISM-Agent не разрешает Collision догадкой.

Collision блокирует только затронутую операцию. Collision в Manifest Set блокирует ISM-операции проекта.

User не является уровнем правил. Явный запрос User на изменение Definition является утверждением изменений, необходимых для этого запроса.

## Операции

Каждая операция имеет один режим. Один запрос User может последовательно выполнять несколько режимов.

### Definition

Изменяет только Meta и Spec. Manifest не изменяется.

Используется для изменения правил, намерений и Target.

### Synthesis

Направление: `Definition → Projection`.

ISM-Agent:

1. разрешает контекст;
2. обнаруживает Collision;
3. вычисляет минимально необходимые изменения Target;
4. применяет их;
5. выполняет Verification.

Synthesis не изменяет Definition или unmanaged-файлы и без необходимости не изменяет уже соответствующий Definition Target.

При Collision затронутые изменения не применяются. Synthesis не должен намеренно оставлять частично применённое состояние; если среда не позволяет восстановление, это явно сообщается User.

### Verification

Ничего не изменяет.

Drift существует только для Target:

- **Missing** — требуемый Target отсутствует;
- **Unexpected** — `@ABSENT` Target существует;
- **Exact** — Target отличается от Exact Spec;
- **Semantic** — Target противоречит Semantic Spec;
- **Policy** — Target нарушает применимую Meta.

Missing, Unexpected и Exact проверяются детерминированно. Semantic и Policy могут требовать суждения ISM-Agent, если Definition не задаёт исполнимую проверку.

### Reconciliation

Направление: `Projection → proposed Definition change`.

Projection используется только как данные.

Reconciliation:

- не изменяет Projection;
- не изменяет Definition автоматически;
- формирует предложение изменения Definition.

Изменение вступает в силу только после утверждения User и применения в режиме Definition.

## Удаление и перенос

Semantic Spec, содержащая `@ABSENT`, требует отсутствия Target и не содержит других нормативных требований.

Предпочтительный формат:

```text
@ABSENT
```

или, если причина необходима:

```text
@ABSENT: <reason>
```

`@ABSENT` сохраняется, пока отсутствие Target остаётся требованием.

Rename/Move выражается как `@ABSENT` для старого Target и Spec для нового Target.
