# ISM Manifest: Topology

**Версия:** 0.9  
**Статус:** Нормативный

## Имена

Формы ISM-файлов:

```text
-[order-]manifest-[name].md
-[order-]meta-[name].md
-[order-]spec-[target].md
-[order-]exact-[target]
```

`order` — необязательное неотрицательное целое. Он задаёт только канонический порядок файлов и не влияет на смысл, область или разрешение конфликтов.

Канонический порядок внутри директории:

1. ISM-файлы с `order` — по числовому `order`, затем по имени;
2. остальные элементы — по имени.

В Root Definition Zone все Manifest должны предшествовать остальным ISM-файлам в каноническом порядке.

`target` — полное имя Target без пути, включая расширение. Путь задаётся расположением Spec.

Примеры:

```text
-10-spec-login.ts.md  -> login.ts
-20-exact-login.ts    -> login.ts
-spec-README.md.md    -> README.md
-exact-README.md      -> README.md
```

Нормативны только файлы, соответствующие формам ISM. В Definition Zone имена файлов с префиксом `-` зарезервированы для ISM; несоответствие грамматике является ошибкой Definition. Остальные файлы ненормативны.

## Definition Zone

`[root]/ism/` — Root Definition Zone. Она обязательна и содержит Manifest Set проекта. Если Project Root не задан средой, им считается ближайший предок, чей `ism/` содержит Manifest Set.

Имя директории `ism` внутри ISM-проекта зарезервировано для Definition Zone.

Любая `<scope>/ism/` вне другой Definition Zone является Local Definition Zone для `<scope>`. Definition Zone не может находиться внутри другой Definition Zone.

Для Definition Zone `D = <scope>/ism/`:

```text
D/<path>/...  <->  <scope>/<path>/...
```

Definition Zone задаёт координаты. Только Spec определяет Target.

Символические ссылки не расширяют область ISM за Project Root и не используются для обхода внешних директорий.

## Manifest

Manifest допустим только непосредственно в Root Definition Zone.

Все Manifest образуют **Manifest Set**. Их количество не ограничено; совместно они задают ISM-протокол проекта.

Manifest Set неизменяем во время обычных проектных операций. Его изменение является обновлением ISM.

## Meta

Meta задаёт правила для соответствующей директории Projection и её потомков.

Все Meta одной области образуют **Meta Set**. Их количество не ограничено.

Для Target применяются Meta от общей области к более конкретной. Более конкретная Meta может переопределить менее конкретную. Несовместимые Meta одной области образуют Collision.

Meta не определяет Target.

## Semantic Spec

`-[order-]spec-[target].md` описывает требуемый смысл одного Target: поведение, ограничения, контракты и намерение.

Для одного Target допускается не более одной Semantic Spec во всех Definition Zone проекта.

## Exact Spec

`-[order-]exact-[target]` задаёт точное содержимое одного Target.

Содержимое Exact Spec непрозрачно для ISM и интерпретируется только как содержимое Target. Target должен совпадать с Exact Spec точно.

Для одного Target допускается не более одной Exact Spec во всех Definition Zone проекта.

## Target Spec Set

Semantic и Exact Spec одного Target образуют **Target Spec Set** и могут существовать совместно. Они обязаны быть совместимы; противоречие является Collision.

Удаление последней Spec перестаёт определять Target и само по себе не разрешает удаление существующего файла.

`@ABSENT` в Semantic Spec означает, что Target не должен существовать. Такая Spec несовместима с Exact Spec.
