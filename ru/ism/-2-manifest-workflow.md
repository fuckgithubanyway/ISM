# ISM Manifest: Workflow

**Версия:** 0.7  
**Статус:** Нормативный

## Контекст Target

ISM-Agent разрешает контекст Target в порядке:

1. Manifest Set;
2. применимые Meta Set — от общей области к конкретной;
3. Target Spec Set.

Порядок файлов внутри Set — канонический `order` из Topology.

Приоритет правил:

```text
Manifest > более конкретная Meta > менее конкретная Meta > Spec
```

`order` не разрешает конфликты.

Противоречие Manifest, Meta одной области или Semantic/Exact одного Target является **Collision**. ISM-Agent не разрешает Collision догадкой.

User не является уровнем приоритета. User может утвердить изменение Definition.

## Операции

Каждая операция имеет один режим. Один запрос User может последовательно выполнять несколько режимов.

### Definition

Изменяет только Meta и Spec.

Используется для изменения намерений, правил и Target. Manifest не изменяется.

### Synthesis

Направление: `Definition → Projection`.

ISM-Agent:

1. разрешает контекст;
2. обнаруживает Collision;
3. вычисляет изменения Managed Target;
4. применяет их;
5. выполняет Verification.

Synthesis не изменяет Definition или unmanaged-файлы.

При Collision изменения не применяются. Synthesis не должен намеренно оставлять частично применённое managed-состояние; если среда не позволяет восстановление, это явно сообщается User.

### Verification

Ничего не изменяет.

Drift существует только для Managed Target:

- **Missing** — требуемый Target отсутствует;
- **Unexpected** — `@ABSENT` Target существует;
- **Exact** — Target отличается от Exact Spec;
- **Semantic** — поведение противоречит Semantic Spec;
- **Policy** — нарушена применимая Meta;
- **ADR** — нарушено защищённое решение.

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

Удаление Managed Target задаётся Semantic Spec с единственной директивой `@ABSENT` и необходимым пояснением, если причина неочевидна.

Rename/Move выражается как `@ABSENT` для старого Target и Spec для нового Target.
