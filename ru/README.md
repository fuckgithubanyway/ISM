# Isomorphic Specification Methodology (ISM) 0.9

ISM — spec-driven методология разработки для работы человека и AI-агента.

**Спецификация первична. Код вторичен.**  
**Код транзиентен. Намерение перманентно.**

## Модель

- `ism/` хранит Definition.
- Spec определяет конкретный Target.
- Meta задаёт правила области, но не определяет Target.
- Manifest задаёт протокол ISM проекта.
- Exact задаёт точное содержимое Target.
- `order` управляет только порядком файлов.

## Структура

```text
[root]/
├── ism/
│   ├── -00-manifest-core.md
│   ├── -10-manifest-topology.md
│   ├── -20-manifest-workflow.md
│   ├── -30-manifest-adr.md
│   └── -40-meta-project.md
│
├── backend/
│   ├── ism/
│   │   ├── -10-meta-typescript.md
│   │   └── src/
│   │       ├── -20-spec-api.ts.md
│   │       └── -30-exact-schema.json
│   └── src/
│       ├── api.ts
│       └── schema.json
│
└── README.md
```

`backend/ism/src/-20-spec-api.ts.md` определяет `backend/src/api.ts`.

В проекте может быть несколько `<scope>/ism/` Definition Zone. Manifest Set находится только в `[root]/ism/` и действует на весь проект.

## Формы файлов

```text
-[order-]manifest-[name].md
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

Используй минимальный текст, достаточный для однозначного смысла. Не повторяй известное.

Подробные правила находятся в [`ism/`](./ism/).
