/*52.	 Найти автомобили, претендующие на отнесение к классу раритетных. К таковым относят автомобили отечественного производства в возрасте не менее 30 лет, либо зарубежные автомобили в возрасте не менее 25 лет, либо автомобили, имеющие пробег не менее 500000 км без учета возраста. Указать государственный номерной знак, год выпуска и пробег каждого из них.
Ответ: 4 строки, 3 столбца. Автомобиль с государственным номерным знаком "c945op57" вызывает подозрение о некорректном указании пробега.*/

SELECT v.gnz, v.date_made, v.run
FROM vehicle v
JOIN state st
ON st.st_id = v.st_id
WHERE (st.name = 'Россия' AND date_part('year',age(now(), v.date_made)) >= 30)

UNION

SELECT v.gnz, v.date_made, v.run
FROM vehicle v
JOIN state st
ON st.st_id = v.st_id
WHERE (st.name != 'Россия' AND date_part('year',age(now(), v.date_made)) >= 25)

UNION

SELECT v.gnz, v.date_made, v.run
FROM vehicle v
WHERE v.run >= 500000;

/*53.	 Найти автомобили, которые посещали предприятие только по понедельникам и понедельник не является первым днем месяца. Выдать государственные номерные знаки. Решение получить с помощью теоретико-множественной операции!
Ответ: 87 автомобилей.*/

SELECT ma.gnz,
ma.date_work
FROM maintenance ma
WHERE date_part('dow', date_work) = 1
AND date_part('day', date_work) != 1

EXCEPT

SELECT ma.gnz,
ma.date_work
FROM maintenance ma
WHERE date_part('dow', date_work) != 1
AND date_part('day', date_work) = 1;

/*54.	 Найти все автомобили, обслуженные механиком Баженовым М.К. (все виды ТО), и (в том числе включительно) отремонтированные механиком Савостьяновым А.В. (только ремонты). Указать их государственные номерные знаки.
Ответ: 1 автомобиль, государственный номерной знак "k857po77".*/

(SELECT ma1.gnz
FROM maintenance ma1
JOIN maintenancetype mt ON mt.mt_id = ma1.mt_id
JOIN mechanic mc ON mc.id_mech = ma1.id_mech
WHERE mt.name LIKE '%ТО%'
AND mc.sname_initials = 'Баженов М.К.')

INTERSECT

(SELECT ma2.gnz
FROM maintenance ma2
JOIN maintenancetype mt ON mt.mt_id = ma2.mt_id
JOIN mechanic mc ON mc.id_mech = ma2.id_mech
WHERE mt.name = 'Ремонт'
AND mc.sname_initials = 'Савостьянов А.В.');

/*55.	 Найти механиков, которые в 2018 году ежемесячно (без пропусков) получали наряды на обслуживание или ремонт автомобилей. Выдать их фамилии и инициалы.
Ответ: Голубев Д.Н.*/

SELECT mc.sname_initials
FROM mechanic mc
JOIN maintenance ma ON ma.id_mech = mc.id_mech
WHERE date_part('year', ma.date_work) = '2018'
GROUP BY mc.sname_initials HAVING COUNT(ma.date_work) >= 12

EXCEPT

SELECT mc.sname_initials
FROM mechanic mc
JOIN maintenance ma ON ma.id_mech = mc.id_mech
WHERE date_part('year', ma.date_work) != '2018'
GROUP BY mc.sname_initials HAVING COUNT(ma.date_work) < 12;

/*56.	 Найти автомобили, которые обслуживались только в 2018 году. Указать госу-дарственный номерной знак, дату проведения обслуживания и техническое заклю-чение по его результатам.
Ответ: 9 строк, 3 столбца.*/

SELECT ma.gnz,
ma.date_work,
ma.tech_cond_resume
FROM maintenance ma
WHERE ma.gnz NOT IN (SELECT gnz
					FROM maintenance
					WHERE date_part('year', date_work) != '2018')

/*57.	 Выдать список рабочих дней в феврале 2018 года, в которые не выполнялись за-казы по обслуживанию или ремонту автомобилей. Выдать даты дней без заказов.
Ответ: 12 дней, в том числе 14 февраля 2018 года.*/

WITH all_days AS (
 SELECT generate_series('2018-02-01'::DATE, '2018-02-28'::DATE, '1 day'::INTERVAL)::DATE AS day
),
orders_days AS (
 SELECT DISTINCT date_trunc('day', ma.date_work)::date AS day
 FROM maintenance ma
 JOIN maintenancetype mt ON ma.mt_id = mt.mt_id
 WHERE date_part('month', ma.date_work) = 2
 AND date_part('year', ma.date_work) = 2018
 AND (mt.name = 'Ремонт'
 OR mt.name LIKE '%ТО%')
)
SELECT day
FROM all_days

EXCEPT

SELECT day
FROM orders_days;