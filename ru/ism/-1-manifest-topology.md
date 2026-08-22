# ISM Manifest: Topology

**Версия:** 0.7  
**Статус:** Нормативный

## Имена

Формы ISM-файлов:

```text
-[order-]manifest-[name].md
-[order-]meta-[name].md
-[order-]spec-[target].md
-[order-]exact-[target]
```

`order` — необязательное неотрицательное целое. Он задаёт только канонический порядок чтения и отображения; семантический приоритет от `order` не зависит.

Каноническая сортировка внутри директории:

1. файлы с `order` — по числовому `order`;
2. затем файлы без `order`;
3. равенство — по имени файла.

`target` — полное имя Target, включая расширение.

Примеры:

```text
-10-spec-login.ts.md  -> login.ts
-20-exact-login.ts    -> login.ts
-spec-README.md.md    -> README.md
-exact-README.md      -> README.md
```

## Definition Zone

`[root]/ism/` — Root Definition Zone. Она обязательна и содержит Manifest Set проекта.

Любая `<scope>/ism/` вне другой Definition Zone является Local Definition Zone для `<scope>`. Definition Zone не может находиться внутри другой Definition Zone.

Для Definition Zone `D = <scope>/ism/`:

```text
D/<path>/...  <->  <scope>/<path>/...
```

Definition Zone задаёт координаты. Владение Target задаёт только Spec.

Символические ссылки не расширяют область ISM за Project Root и не должны использоваться для обхода внешних директорий.

## Manifest

Manifest допустим только непосредственно в Root Definition Zone.

Все `manifest`-файлы образуют **Manifest Set**. Их количество не ограничено. Они совместно определяют ISM-протокол проекта.

Manifest Set неизменяем во время обычных проектных операций. Его изменение является обновлением ISM.

## Meta

Meta задаёт правила для соответствующей директории Projection и её потомков.

Все Meta, отображаемые на одну область, образуют **Meta Set**. Количество Meta в области не ограничено.

Для Target применяются Meta от общей области к более конкретной. Более конкретная Meta переопределяет менее конкретную. Несовместимые Meta одной области образуют Collision.

Meta не создаёт Managed Target.

## Semantic Spec

`-[order-]spec-[target].md` описывает требуемый смысл одного Target: поведение, ограничения, контракты и намерение.

Для одного Target допускается не более одной Semantic Spec во всех Definition Zone проекта.

## Exact Spec

`-[order-]exact-[target]` содержит точное содержимое одного Target.

Exact Spec не содержит ISM-директив. Содержимое Target должно точно совпадать с Exact Spec.

Для одного Target допускается не более одной Exact Spec во всех Definition Zone проекта.

## Target Spec Set

Semantic и Exact Spec одного Target образуют **Target Spec Set** и могут существовать совместно. Они обязаны быть совместимы; противоречие является Collision.

Наличие Spec делает Target managed. Удаление последней Spec делает существующий файл unmanaged и само по себе не разрешает его удаление.

`@ABSENT` в Semantic Spec означает, что Target не должен существовать. Такая Spec несовместима с Exact Spec.
