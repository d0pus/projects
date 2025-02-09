/*58.	 Определить количество работ, выполненных в 2017 году. 
Ответ: закрыто 98 заказов.*/

SELECT COUNT(*)
FROM maintenance
WHERE date_part('year', date_work) = '2017';

/*59.	 Рассчитать общую сумму НДС, уплаченную в 2016 году (НДС рассчитывается как 18% от суммы платежа) за приобретенные автомобили. Результат округлить до копеек и представить в виде количества рублей и копеек. 
Ответ: 7 021 189 руб. 80 коп.*/

SELECT CAST(SUM(v.cost * 0.18) AS INT) || 'руб.' || CAST(SUM(v.cost * 0.18) % 1 * 100 AS INT) || 'коп.'
FROM vehicle v
WHERE date_part('year', date_made) = '2016';

/*60.	 Определить, сколько учтено автомобилей, зарегистрированных в Орловской об-ласти. 
Ответ: 146 автомобилей.*/

SELECT COUNT(*)
FROM vehicle
WHERE SUBSTRING(gnz from 7)::INTEGER IN (57, 157, 757);

/*61.	 Определить средний возраст механиков предприятия с точностью до двух зна-чащих цифр мантиссы.
Ответ: по состоянию на ноябрь 2022 года –  42.7 года.*/

SELECT TO_CHAR(
  (DATE_PART('year', AVG(AGE(born))) +
  DATE_PART('month', AVG(AGE(born))) / 12), 
  'FM99.99'
) 
FROM mechanic;

/*62.	 Определить общую и среднюю стоимость с точностью до копейки, общий и средний пробег с точностью до 100 м всех зарегистрированных автомобилей. Ука-зать в качестве имен столбцов требуемые вычисления.
Ответ: 368 750 290.00, 2 290 374.47, 26 075 702.0, 161 960.8.*/

SELECT TRUNC(SUM(cost), 2) as "sum(cost)",
TRUNC(AVG(cost), 2) as "sum(cost)",
TRUNC(SUM(run),1) as "sum(run)",
TRUNC(AVG(run), 1) as "avg(run)"
FROM vehicle

/*63.	 Определить средний пробег автомобилей каждого бренда. Результат округлить до 10 м. 
Ответ: 10 строк, 2 столбца. Средний пробег автомобилей BMW 70937.40 км.*/

SELECT b.name,
TRUNC(AVG(v.run), 2)
FROM vehicle v
JOIN brand b ON b.idb = v.idb
GROUP BY b.name;

/*64.	 Рассчитать среднюю стоимость с точностью до копейки каждой марки зареги-стрированных автомобилей. В выдачу включить наименование бренда, марки и среднюю стоимость.
Ответ: 47 строк, 3 столбца.*/

SELECT 
 brand.name AS "Бренд", 
 mk.name AS "Марка", 
 ROUND(AVG(vehicle.cost), 2) AS "Средняя стоимость"
FROM vehicle
JOIN brand ON brand.idb = vehicle.idb
JOIN marka mk ON mk.idm = vehicle.idm
GROUP BY brand.name, mk.name;

/*65.	 Определить с точностью до двух значащих цифр мантиссы средний возраст ав-томобилей каждой марки. Для автомобилей, у которых не предусмотрена марка, указывать модель.
Ответ: 49 строк, 2 столбца.*/

SELECT 
 COALESCE(mk.name, mo.model_name) AS "Name", 
 ROUND(AVG(date_part('year', age(now(), v.date_made)) +
          date_part('month', age(now(), v.date_made)) / 12)::NUMERIC, 2) AS "Средний возраст"
FROM vehicle AS v
JOIN marka AS mk ON mk.idm = v.idm
JOIN model AS mo ON mo.idmo = v.idmo
GROUP BY COALESCE(mk.name, mo.model_name);

/*66.	 Определить год, за который поступило больше всего заказов (относительно дру-гих лет).
Ответ: 2019 год.*/

SELECT date_part('year', ma.date_work) as "Год"
FROM maintenance ma
GROUP BY date_part('year', ma.date_work)
ORDER BY count(ma.date_work) DESC
LIMIT 1;

/*67.	 Построить распределение марок автомобилей, ограничив список марками, встречающимися не менее 8 раз. Список упорядочить по уменьшению количества экземпляров марки.
Ответ: "ГАЗ Газель" (24), "ВАЗ Веста" (16), "BMW Serie 3" (8).*/

SELECT CONCAT(brand.name, ' ', marka.name, ' (', COUNT(*), ')') AS "Результат"
FROM vehicle
JOIN marka ON vehicle.idm = marka.idm
JOIN brand ON vehicle.idb = brand.idb
GROUP BY brand.name, marka.name
HAVING COUNT(*) >= 8
ORDER BY COUNT(*) DESC;

/*68.	 Найти автомобили, владельцы которых за все время разместили заказ только один раз. Выдать государственные номерные знаки.
Ответ: 35 автомобилей, один из которых "y474kx57".*/

SELECT gnz
FROM maintenance
GROUP BY gnz HAVING COUNT(gnz) = 1;