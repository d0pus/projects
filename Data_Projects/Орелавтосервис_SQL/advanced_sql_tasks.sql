/*85.	 Определить самый не надежный автомобиль, который имеет наименьший интер-вал между двумя любыми ремонтами. Указать его государственный номерной знак и наименьший интервал между ремонтами в секундах.
Ответ: автомобиль с государственным номерным знаком "a964oa57". Интервал составляет 18720 сек.*/

WITH intervals AS (
    SELECT gnz, 
    EXTRACT(epoch FROM LEAD(date_work) OVER (PARTITION BY gnz ORDER BY date_work)) -
    EXTRACT(epoch FROM date_work) AS interval
    FROM maintenance)
SELECT gnz, interval AS "Интервал"
FROM intervals
ORDER BY interval
LIMIT 1;

/*86.	 Найти объем убыли клиентов с ростом возраста автомобилей, составив таблицу, где в одном столбце указан номер ТО, а в другом – число выполненных работ соот-ветствующего вида. Данные должны быть отсортированы по номеру и виду ТО, сначала ТО-1. После перечисления всех видов ТО приводятся сведения по ТО для японских автомобилей.
Ответ: 16 строк, 2 столбца.*/

(SELECT name, COUNT(tech_cond_resume)
	FROM maintenance m
	JOIN maintenancetype mt ON m.mt_id = mt.mt_id
	WHERE name LIKE 'ТО-_'
	GROUP BY name
	ORDER BY name
)

UNION ALL

(SELECT name, COUNT(tech_cond_resume)
	FROM maintenance m
	JOIN maintenancetype mt ON m.mt_id = mt.mt_id
	WHERE name LIKE 'ТО%японских%'
	GROUP BY name
	ORDER BY name
);

/*87.	 Составить таблицу изменения рентабельности предприятия по годам, где показа-ны абсолютное число выполненных заказов, относительное число заказов на один зарегистрированный автомобиль (учесть, что после выполнения предпродажной подготовки, автомобиль более не является зарегистрированным, хотя данные о нем сохраняются в базе данных), абсолютный прирост числа заказов, упущенная выгода в виде не добранных процентов если считать за 100% ситуацию, когда все зареги-стрированные автомобили прибывают на предприятие один раз в год.
Ответ: 25 строк, 4 столбца.*/

SELECT 
   "Год", 
   "Абсолютное число заказов", 
   "Относительное число заказов",
   "Абсолютное число заказов" - LAG("Абсолютное число заказов") OVER (ORDER BY "Год") AS "Абсолютный прирост числа заказов",
   (1 - "Относительное число заказов") * 100 AS "Упущенная выгода (%)"
FROM (SELECT EXTRACT(YEAR FROM a.date_work) AS "Год", 
       COUNT(DISTINCT b.gnz) AS "Число зарегистрированных автомобилей",
       COUNT(*) AS "Абсолютное число заказов", 
       COUNT(*) / COUNT(DISTINCT b.gnz) AS "Относительное число заказов"
       FROM maintenance a
       JOIN vehicle b ON a.gnz = b.gnz
       GROUP BY "Год"
   ) AS subquery

/*88.	 Составить "возрастную карту" зарегистрированных автомобилей, включив в нее столбец наименований изготовителей, столбцы для указания доли в процентах, округленной до двух значащих цифр мантиссы, автомобилей в возрасте от 0 до 6 лет, от 7 до 10 лет, от 11 до 13 лет, от 14 до 18 лет и старше 18 лет.
Ответ: 10 строк, 6 столбцов.*/

WITH total_vehicles AS (
	SELECT COUNT(gnz) AS total
	FROM vehicle
),
vehicles_by_age AS (
 SELECT 
   b.name, 
   DATE_PART('year', AGE(v.date_made)) AS age, 
   COUNT(v.gnz) AS count
 FROM vehicle v 
 JOIN brand b USING (idb)
 GROUP BY b.name, age
)
SELECT 
 b.name, 
 ROUND((SELECT SUM(count) FROM vehicles_by_age WHERE age BETWEEN 0 AND 6 AND b.name = name)::numeric / (SELECT total FROM total_vehicles) * 100, 2) AS age_0_6,
 ROUND((SELECT SUM(count) FROM vehicles_by_age WHERE age BETWEEN 7 AND 10 AND b.name = name)::numeric / (SELECT total FROM total_vehicles) * 100, 2) AS age_7_10,
 ROUND((SELECT SUM(count) FROM vehicles_by_age WHERE age BETWEEN 11 AND 13 AND b.name = name)::numeric / (SELECT total FROM total_vehicles) * 100, 2) AS age_11_13,
 ROUND((SELECT SUM(count) FROM vehicles_by_age WHERE age BETWEEN 14 AND 18 AND b.name = name)::numeric / (SELECT total FROM total_vehicles) * 100, 2) AS age_14_18,
 ROUND((SELECT SUM(count) FROM vehicles_by_age WHERE age > 18 AND b.name = name)::numeric / (SELECT total FROM total_vehicles) * 100, 2) AS age_gt_18
FROM brand b
GROUP BY b.name;

/*89.	 Определить завод-изготовитель, продукция которого больше других требует ремонта (гарантийный срок не учитывать) в абсолютных показателях и завод с наибольшей долей отказов продукции (число ремонтов на один зарегистрирован-ный в базе данных автомобиль). Выдать наименования, принадлежность брендам, страны брендов, почтовые адреса и телефоны (в двух столбцах), количество ремон-тов выпущенных ими автомобилей и долю ремонтов на один зарегистрированный автомобиль.
Ответ: по обоим показателям один и тот же завод "Austria Bavarischen motorwerke" с абсолютным показателем 3 отказа и долей в 0.666667.*/

SELECT factory_name, b.name, s.name, f.post_addr, f.phone,
       (SELECT COUNT(*) FROM maintenance AS mt WHERE mt.idf = f.idf),
       (SELECT (SELECT COUNT(*) FROM vehicle AS v WHERE f.idf = v.idf) /
               (SELECT COUNT(*) FROM maintenance AS mt WHERE mt.idf = f.idf)::NUMERIC
        WHERE (SELECT COUNT(*) FROM vehicle AS v WHERE f.idf = v.idf) != 0) bb
FROM factory f 
JOIN state s ON f.st_id = s.st_id 
JOIN brand b on b.idb = f.idb 
WHERE (SELECT COUNT(*) FROM vehicle AS v WHERE f.idf = v.idf) != 0 
ORDER BY bb DESC 
LIMIT 1;

/*90.	 Найти автомобили с заводским браком (интервал времени между датой реги-страции и первым ремонтом, не превышающий 1 года). Выдать их государственные номерные знаки; производителя, марку и модель в одном столбце; дату регистра-ции; дату первого ремонта; интервал в днях от регистрации до первого ремонта.
Ответ: 3 автомобиля, два NISSAN и один ГАЗ.*/

SELECT m.gnz, 
  CONCAT(brand.name, ' ', marka.name, ' ', model.model_name),
  v.date$reg_certif, 
  m.date_work,
  ROUND(EXTRACT(EPOCH FROM AGE(m.date_work, v.date$reg_certif))/3600/24)
FROM maintenance m
JOIN vehicle v ON m.gnz = v.gnz 
JOIN brand ON m.idb = brand.idb
JOIN marka ON m.idm = marka.idm
JOIN model ON m.idmo = model.idmo
WHERE m.date_work > v.date$reg_certif 
  AND AGE(m.date_work, v.date$reg_certif) < '1 year'
  AND m.mt_id::int = 20
ORDER BY AGE(m.date_work, v.date$reg_certif) DESC

/*91.	 Найти автомобили, которые в течение одного года обслуживались или ремонти-ровались только у разных механиков. Выдать их государственные номерные знаки, даты, когда проводилось обслуживание или ремонт, фамилии и инициалы механи-ков. Учесть, что автомобили, посещавшие предприятие один раз в году, также отно-сятся к обслуженным разными механиками в этом году, отсортировать выдачу по государственным номерным знакам.
Ответ: 340 строк, 3 столбца.*/

SELECT m1.gnz, date_work, sname_initials
FROM maintenance AS m1 JOIN mechanic AS mech1 ON m1.id_mech = mech1.id_mech,
     (SELECT gnz, mech2.id_mech, date_part('year', date_work) AS year
      FROM maintenance AS m2 JOIN mechanic AS mech2 ON m2.id_mech = mech2.id_mech
      WHERE m2.id_mech = mech2.id_mech) AS t1
WHERE m1.gnz = t1.gnz AND m1.id_mech != t1.id_mech AND date_part('year', m1.date_work) = t1.year
GROUP BY m1.gnz, m1.date_work, mech1.sname_initials
ORDER BY m1.gnz DESC;

/*92.	 Определить медианное значение и разброс стоимости зарегистрированных авто-мобилей, считая, что стоимость распределена нормально. Для определения медиан-ного значения стоимости использовать математическое ожидание, рассчитанное, как сумма произведений каждой стоимости на количество ее повторов в ряду стоимо-стей, деленное на общее число зарегистрированных автомобилей. Разброс рассчи-тать, как квадратный корень из разности медианы ранжированного ряда квадратов стоимости и квадрата медианы.
Ответ: медиана – 2 290 301 руб., разброс – 3 932 362 руб.*/

SELECT 
  ROUND(SUM(t1.cost * t1.count / vehicle_count.count)) AS "Медиана",
  ROUND(SQRT(SUM(POWER(t1.cost, 2) * t1.count / vehicle_count.count) - POWER(SUM(t1.cost * t1.count / vehicle_count.count), 2))) AS "Разброс"
FROM 
  (SELECT cost, COUNT(cost)
   FROM vehicle
   GROUP BY cost) AS t1,
  (SELECT COUNT(*) FROM vehicle) AS vehicle_count;


