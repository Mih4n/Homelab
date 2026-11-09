---
name: document-recognition
description: Extracting text, tables and figures from PDF, scans, images and office files - pdftotext, ocrmypdf rus+eng, page images for vision, markitdown. Load before reading a document that is not plain text.
---

# Распознавание документов

Этим занимается `@reader`. Порядок:

1. Текстовый PDF: `pdftotext -layout file.pdf -`. Проверить, что текст не пустой
   и не мусор.
2. Скан: `ocrmypdf -l rus+eng --skip-text file.pdf ocr.pdf`, затем `pdftotext`.
3. Сложные таблицы, схемы, формулы: `pdftoppm -r 150 -png -f N -l N file.pdf page`
   и смотреть PNG зрением модели, по одной странице за раз.
4. docx, xlsx, pptx, html: `markitdown file.docx` или MCP `markitdown`.

Результат сохранять в markdown рядом с исходником, чтобы не распознавать дважды.
