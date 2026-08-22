# Isomorphic Specification Methodology (ISM) 0.7

ISM — spec-driven методология разработки для работы человека и AI-агента.

**Спецификация первична. Код вторичен.**  
**Код транзиентен. Намерение перманентно.**

## Модель

- `ism/` хранит Definition.
- Spec делает конкретный Target управляемым.
- Meta задаёт правила области, но не создаёт Target.
- Projection является результатом и может быть восстановлена для Managed Target.
- `order` управляет порядком контекста, но не приоритетом правил.

## Структура

```text
[root]/
├── ism/
│   ├── -0-manifest-core.md
│   ├── -1-manifest-topology.md
│   ├── -2-manifest-workflow.md
│   ├── -3-manifest-adr.md
│   └── -meta-project.md
│
├── backend/
│   ├── ism/
│   │   ├── -0-meta-typescript.md
│   │   └── src/
│   │       ├── -10-spec-api.ts.md
│   │       └── -20-exact-schema.json
│   └── src/
│       ├── api.ts
│       └── schema.json
│
└── README.md
```

`backend/ism/src/-10-spec-api.ts.md` определяет `backend/src/api.ts`.

В проекте может быть несколько Definition Zone `<scope>/ism/`. Manifest Set находится только в `[root]/ism/` и действует на весь проект.

## Спецификации

```text
-[order-]meta-[name].md
-[order-]spec-[target].md
-[order-]exact-[target]
```

Semantic Spec описывает требуемый смысл. Exact Spec задаёт точное содержимое Target.

## Жизненный цикл

- **Definition** — изменение Meta/Spec.
- **Synthesis** — Definition → Projection.
- **Verification** — проверка Drift без изменений.
- **Reconciliation** — Projection → предложение изменения Definition.

## Принцип записи

Пиши минимально достаточный текст. Не повторяй известное. Сохраняй всю информацию, необходимую для однозначного результата.

Подробные правила находятся в [`ism/`](./ism/).
