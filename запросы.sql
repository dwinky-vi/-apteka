-- производители --

-- 1. Вывести страну и количество производителей в ней. Информацию отсортировать по кол-во стран в обратном порядке, а затем в алфавитном порядке по странам --
SELECT страна, COUNT(страна) AS количество_компаний
FROM apteka.производители
GROUP BY страна
ORDER BY количество_компаний DESC, страна ASC;

-- 2. Вывести количество всех производителей --
SELECT COUNT(*) AS количество_всех_производителей
FROM apteka.производители;

-- 3. Вывести список всех производителей в алфавитном порядке --
SELECT название, страна
FROM apteka.производители
ORDER BY название;


-- сотрудники --

-- 4. Вывести информацию о сотрудниках (фамилию, номер телефона и адрес). Результат отсортировать по фамилиям в алфавитном порядке --
SELECT фио, номер_телефона, адрес
FROM apteka.сотрудники
ORDER BY фио ASC;

-- 5. Изменить номер телефона у сотрудника Гайнетдинов В.М. на новый (например: 8 (917) 980-15-33) --
UPDATE apteka.сотрудники
SET номер_телефона = '8 (917) 980-15-33'
WHERE фио = 'Гайнетдинов В.М.';


-- посетители --

-- 6. Вывести фамилию, дату рождения и адрес эл. почты посетителей у кого день рождения зимой. --
--    Также вывести месяц их рождения в столбец под названием "месяц". --
--    Результат сначала отсортировать по последнему столбцу, а затем по фамилиям в алфавитном порядке --
SELECT фио, дата_рождения, почта, MONTHNAME(дата_рождения) AS месяц
FROM apteka.посетители
WHERE MONTH(дата_рождения) IN (12, 1, 2)
ORDER BY месяц, фио;


-- 7. Вывести фамилии всех посетителей и количество бонусов на их карте в отсортированном по алфавиту --
SELECT фио, бонусы
FROM apteka.посетители
ORDER BY 1 ASC;


-- препараты --

-- 8. Вывести содержание таблицы "препараты". А именно: название, производитель, цена, проверить наличие препарата, если препарат закончился – написать, что он закончился --
SELECT препараты.название, производители.название AS производитель, цена, IF(количество > 0, количество, 'закончился') AS количество
FROM apteka.препараты
INNER JOIN apteka.производители
ON препараты.производитель = производители.id;

-- 9. Вывести все препараты с действующим веществом "Мелатонин" по возрастанию цены --
SELECT препараты.название, производители.название AS производитель, цена, IF(количество > 0, 'есть в наличии', 'закончился') AS наличие, количество AS осталось
FROM apteka.препараты
INNER JOIN apteka.производители
ON препараты.производитель = производители.id
WHERE состав = 'Мелатонин'
ORDER BY цена ASC;

-- 10. Найти все препараты омепразола (в запросе использовать: ОМЕПРАЗОЛ). Вывести название, производителя, цену и количество. Если товар закончился, то записать это в последнем столбце. Вывести по возрастанию цены --
SELECT препараты.название, производители.название AS производитель, цена, IF(количество > 0, количество, 'закончился') AS осталось
FROM apteka.препараты
INNER JOIN apteka.производители
ON препараты.производитель = производители.id
WHERE препараты.название LIKE '%ОМЕПРАЗОЛ%'
ORDER BY цена ASC;

-- 11. Вывести абсолютно всю информацию препарата "ВИАГРА" --
SELECT препараты.id, препараты.название, состав, описание, производители.название, цена, количество
FROM apteka.препараты
INNER JOIN apteka.производители
ON препараты.производитель = производители.id
WHERE препараты.название LIKE '%ВИАГРА%'\G

-- 12. Вывести сколько всего препаратов в базе данных --
SELECT COUNT(*) AS 'всего'
FROM apteka.препараты;


-- журнал_поставок --

-- 13. Вывести по журналу поставок название препарата, количество проданного препарата, кто продал и когда --
SELECT препараты.название, журнал_поставок.количество, сотрудники.фио, дата
FROM apteka.журнал_поставок
INNER JOIN apteka.препараты
ON журнал_поставок.препарат = препараты.id
INNER JOIN apteka.сотрудники
ON журнал_поставок.сотрудник = сотрудники.id
ORDER BY дата;


-- 14. Посчитать сколько единиц товара принял каждый сотрудник 15-го ноября 2021-го года --
SELECT сотрудники.фио, SUM(журнал_поставок.количество) AS 'всего принято единиц товара'
FROM apteka.журнал_поставок
INNER JOIN apteka.препараты
ON журнал_поставок.препарат = препараты.id
INNER JOIN apteka.сотрудники
ON журнал_поставок.сотрудник = сотрудники.id
WHERE журнал_поставок.дата = '2021-11-15'
GROUP BY журнал_поставок.сотрудник
ORDER BY журнал_поставок.сотрудник DESC;


-- журнал_продаж --

-- 15. Вывести журнал продаж --
SELECT препараты.название, журнал_продаж.количество, дата, посетители.фио AS кто_купил, сотрудники.фио AS кто_продал
FROM apteka.журнал_продаж
INNER JOIN apteka.сотрудники
ON журнал_продаж.сотрудник = сотрудники.id
INNER JOIN apteka.препараты
ON журнал_продаж.препарат = препараты.id
INNER JOIN apteka.посетители
ON журнал_продаж.посетитель = посетители.id
ORDER BY дата ASC;

-- 16. Посчитать сколько товаров продал каждый сотрудник --
SELECT сотрудники.фио AS кто_продал, SUM(журнал_продаж.количество) AS 'количество проданных препаратов', SUM(цена * журнал_продаж.количество) AS 'сумма'
FROM apteka.журнал_продаж
INNER JOIN apteka.сотрудники
ON журнал_продаж.сотрудник = сотрудники.id
INNER JOIN apteka.препараты
ON журнал_продаж.препарат = препараты.id
INNER JOIN apteka.посетители
ON журнал_продаж.посетитель = посетители.id
GROUP BY журнал_продаж.сотрудник
ORDER BY сотрудники.фио ASC;


