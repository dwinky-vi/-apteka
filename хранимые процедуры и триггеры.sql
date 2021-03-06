-- ПРОЦЕДУРЫ --

-- 1. Добавление нового сотрудника --

DELIMITER $$
CREATE PROCEDURE apteka.add_employee(id INT, фио VARCHAR(35), номер_телефона VARCHAR(18), адрес VARCHAR(100))
BEGIN
INSERT INTO apteka.сотрудники(id, фио, номер_телефона, адрес)
VALUES (id, фио, номер_телефона, адрес);
END $$
DELIMITER ;

Вызыв процедуры:
CALL apteka.add_employee(3, 'Шамал Р.Т.', '8 (917) 988-40-12', 'Казань, Кремлёвская 18');


-- ТРИГГЕРЫ --

-- 1. После поставки препарата его количество должно увеличиться на поступившее количество --

DELIMITER $$
CREATE TRIGGER apteka.after_delivery AFTER INSERT
ON apteka.журнал_поставок 
for each row
BEGIN
UPDATE apteka.препараты
SET apteka.препараты.количество = apteka.препараты.количество + NEW.количество
WHERE NEW.препарат = apteka.препараты.id;
END $$
DELIMITER ;


-- 2. После продажи препарата его количество должно уменьшится на проданое количество --

DELIMITER $$
CREATE TRIGGER apteka.after_sale AFTER INSERT
ON apteka.журнал_продаж
for each row
BEGIN
UPDATE apteka.препараты
SET apteka.препараты.количество = apteka.препараты.количество - NEW.количество
WHERE NEW.препарат = apteka.препараты.id;
END $$
DELIMITER ;


-- 3. Начисление покупателю 5% бонусов от покупки --

DELIMITER $$
CREATE TRIGGER apteka.accrual_of_bonuses AFTER INSERT
ON apteka.журнал_продаж
for each row
BEGIN
UPDATE apteka.посетители
SET apteka.посетители.бонусы = apteka.посетители.бонусы + NEW.количество * (SELECT цена FROM apteka.препараты WHERE id = NEW.препарат) / 100 * 5
WHERE NEW.посетитель = apteka.посетители.id;
END $$
DELIMITER ;


