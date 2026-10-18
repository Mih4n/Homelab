---
name: typst-reports
description: Writing reports in Typst with the @mih4n/ghost 2.0 library (lab and course works by GSTU guide 4334 - title page, figures, tables, formulas, sources, appendices) and building them - PDF, docx, diagrams, charts. Load before creating or building a Typst document.
---

# Typst-отчёты

## Библиотека ghost 2.0

Исходники и полный README: `~/Work/Ghost`, примеры `examples/lab.typ` и
`examples/course.typ`. Старые отчёты на `@mih4n/ghost:1.0.0` не переводить
на 2.0 без просьбы: API другое.

```typst
#import "@mih4n/ghost:2.0.0": *

#show: ghost.with(
  kind: "course",                 // "lab": + number: 3, без содержания
  discipline: [Базы данных],
  theme: [Учёт договоров с поставщиками],
  student: "Лосев М. А.",
  group: "ИТП-21",
  supervisor: ("Асенчик О. Д.", "доцент"),
  task: image("task.pdf"),        // только курсовая, лист задания
  abstract: [Текст реферата.],    // объём работы считается сам
  keywords: ("база данных", "SQL"),
  abbreviations: ("СУБД": [система управления базами данных]),
  draft: true,                    // пометки о рисунках и источниках без ссылок
)

= Введение                         // без номера, по центру
= Анализ предметной области        // раздел 1, с новой страницы
== Постановка задачи

Схема показана на рисунке @er-diagram, данные в таблице @data, модель
описывается уравнением @w, по данным #src("date") ...

#picture(image("img/er-diagram.png", width: 70%), [ER-диаграмма базы данных])
#tbl(table(columns: 2, [Параметр], [Значение], [a], [1]), [Исходные данные], name: "data")
#formula($ W(s) = 1 / (m s^2 + k) $, name: "w")
#where(($m$, [масса системы]), ($k$, [коэффициент жёсткости]))
#code-figure(path("src/Save.cs"), [Метод сохранения])   // фрагмент ≤ 0,5 стр.

- пункт списка;                    // «–»
+ пункт перечисления;              // «а)», вложенный «1)»

= Заключение

#sources(date: [Дейт, К. Дж. Введение в системы баз данных / К. Дж. Дейт. – 8-е изд. – М. : Вильямс, 2006. – 1328 с.])

#appendix([Листинг программы], name: "code")   // в тексте: «в приложении @code»
#listing(path("src/Program.cs"))
```

Правила:

- Ничего не переопределять через `set page`, `set text`, `set heading`: поля,
  шрифт, интервал, номера страниц и отступы уже заданы.
- Пустые строки `\` вокруг заголовков, рисунков и таблиц не ставить.
- Метка рисунка берётся из имени файла (`img/er-diagram.png` даёт
  `@er-diagram`), у таблиц и формул метка задаётся через `name:`.
- Ссылка выводит только номер, падеж пишется словами: «на рисунке
  @er-diagram», «по таблице @data», «уравнением @w» (скобки ставятся сами).
- На каждый рисунок, таблицу, приложение и источник должна быть ссылка в
  тексте. `draft: true` показывает, где её нет.
- Файлы кода и картинки передаются как `path("...")` или `image("...")`
  из самого отчёта, строка с путём внутри пакета не найдётся.
- Источники пишутся вручную по ГОСТ 7.1 (skill `gost-4334`), нумеруются сами
  по первой ссылке `#src("key")`.
- Рисунки класть в `img/`, исходники диаграмм (`.d2`, `.mmd`, `.dot`, `.puml`)
  рядом с ними, код программы в `src/`.

## Сборка

Сборку, конвертацию и рендер диаграмм выполняет `@builder`.

| Задача | Команда |
|---|---|
| PDF | `typst compile report.typ` |
| Следить за изменениями | `typst watch report.typ` |
| Форматирование | `typstyle -i report.typ` |
| docx | `soffice --headless --infilter=writer_pdf_import --convert-to docx report.pdf` |
| Диаграммы | `d2 a.d2 a.svg`, `mmdc -i a.mmd -o a.svg`, `dot -Tsvg a.dot -o a.svg`, `plantuml -tsvg a.puml` |
| Графики | `python3 plot.py` (matplotlib, сохранять в `img/*.svg`) |

docx из Typst получается только с потерями: импорт PDF через LibreOffice
сохраняет вид, но абзацы превращаются во фреймы. HTML-экспорт Typst с ghost
не работает.
