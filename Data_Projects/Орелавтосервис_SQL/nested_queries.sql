/*43.	 Найти автомобили, которые никогда не обслуживались предприятием. Выдать список государственных номерных знаков этих автомобилей.
Ответ: 2 строки, 1 столбец. Автомобили "c519op57"и "a333aa57".*/

SELECT gnz
FROM vehicle
WHERE gnz NOT IN (SELECT gnz FROM maintenance);

/*44.	 Составить список автомобилей (государственный номерной знак и стоимость), которые стоят не более средней стоимости всех зарегистрированных автомобилей.
Ответ: 111 строк, 2 столбца. 
Сумма стоимости найденных автомобилей 83 170 150 руб. 00 коп.*/

SELECT gnz, cost
FROM vehicle
WHERE cost <= (SELECT AVG(cost) FROM vehicle);

SELECT SUM(cost)
FROM vehicle
WHERE cost <= (SELECT AVG(cost) FROM vehicle);

/*45.	 Найти автомобили, которые были приобретены не новыми. К таким можно отне-сти экземпляры, у которых год и месяц начала эксплуатации и год и месяц даты вы-дачи свидетельства о регистрации транспортного средства не совпадают.
Ответ: 76 автомобилей, один из которых имеет государственный номерной знак "o002oo57".*/

SELECT gnz
FROM vehicle
WHERE TO_CHAR(date_use, 'MM.YYYY') != TO_CHAR(date$reg_certif, 'MM.YYYY');

/*46.	 Найти автомобили, изготовленные на том же заводе, что и автомобиль с госу-дарственным номерным знаком "x027kp57". Выдать их государственные номерные знаки, наименование, почтовый адрес и контактный телефон завода. 
Ответ: автомобиль с государственным номерным знаком "c014xp57", изготовлен-ный на заводе BMW в Австрии.*/

SELECT v.gnz,
f.factory_name,
f.post_addr,
f.phone
FROM vehicle v
JOIN factory f ON v.idf = f.idf
JOIN (SELECT idf FROM vehicle WHERE gnz = 'x027kp57') v2 ON v.idf = v2.idf
WHERE v.gnz != 'x027kp57';

/*47.	 Составить список автомобильных брендов, не имеющих собственного производ-ства на территории Российской Федерации. Указать их наименования, государ-ственную принадлежность.
Ответ: 5 компаний, одна из ФРГ, по две из Франции и Японии.*/

SELECT b.name AS brand_name,
       st.name AS state_name
FROM brand b, state st
WHERE st.st_id = b.st_id
AND NOT EXISTS (
    SELECT 1
    FROM factory f
    WHERE f.idb = b.idb
    AND f.legal_addr LIKE '%Россия%'
)

/*48.	 Найти производителей, которые имеют заводы, как на территории Российской Федерации, так и за ее пределами. Указать наименование бренда, название и адрес размещения завода.
Ответ: производители "BMW" и "Mercedes-Benz". Всего 6 строк.*/

SELECT b.name, f.factory_name, f.legal_addr
FROM brand b
JOIN factory f ON b.idb = f.idb
WHERE b.idb IN (
   SELECT idb
   FROM factory
   WHERE legal_addr LIKE '%Россия%'
   
   INTERSECT
   
   SELECT idb
   FROM factory
   WHERE legal_addr NOT LIKE '%Россия%'
);

/*49.	 Определить почтовый адрес завода, изготовившего автомобиль с государствен-ным номерным знаком "a723ak57", для направления претензии по недостатку, вы-явленному в ходе проведения ремонта 6 ноября 2018 года. В выдачу включить гос-ударственный номерной знак, производителя, марку и модель автомобиля в одной колонке через запятую, дату изготовления автомобиля, наименование завода-изготовителя, его почтовый адрес, дату проведения ремонта, серию и номер выдан-ной диагностической карты в одной колонке через пробел, техническое заключение по ремонту.
Ответ: 1 строка, 8 столбцов.*/

SELECT ma.gnz,
      CONCAT(b.name, ',', mk.name, ',', mo.model_name),
      v.date_made,
      f.factory_name,
      f.post_addr,
      ma.date_work,
      CONCAT(ma.s$diag_chart, ' ', ma.n$diag_chart),
      ma.tech_cond_resume
FROM maintenance ma
JOIN brand b ON b.idb = ma.idb
JOIN factory f ON f.idf = ma.idf
JOIN model mo ON mo.idmo = ma.idmo
JOIN marka mk ON mk.idm = ma.idm
JOIN vehicle v ON v.gnz = ma.gnz
JOIN maintenancetype mt ON mt.mt_id = ma.mt_id
WHERE ma.gnz = 'a723ak57'
AND mt.name = 'Ремонт'
AND DATE(ma.date_work) = TO_DATE('06.11.2018', 'DD.MM.YYYY');

/*50.	 Рассчитать количество заказов по видам работ. Выдачу сформировать в виде таблицы, где предусмотреть три столбца: "Техническое обслуживание", включив в подсчет все виды технического обслуживания; "Ремонт"; "Предпродажная подготов-ка". 
Ответ: 413 ТО, 138 ремонтов, 86 предпродажных подготовок.*/

SELECT COUNT(*) FILTER(WHERE ma.name LIKE '%ТО%') AS "Техническое об-служивание",
COUNT(*) FILTER(WHERE ma.name = 'Ремонт') AS "Ремонт",
COUNT(*) FILTER(WHERE ma.name = 'Предпродажная подготовка') AS "Предпро-дажная подготовка"
FROM maintenance m
JOIN maintenancetype ma ON ma.mt_id = m.mt_id; 

SELECT 
   SUM(CASE WHEN ma.name LIKE '%ТО%' THEN 1 ELSE 0 END) AS "Техническое обслуживание",
   SUM(CASE WHEN ma.name = 'Ремонт' THEN 1 ELSE 0 END) AS "Ремонт",
   SUM(CASE WHEN ma.name = 'Предпродажная подготовка' THEN 1 ELSE 0 END) AS "Предпродажная подготовка"
FROM maintenance m
JOIN maintenancetype ma ON ma.mt_id = m.mt_id;

/*51.	 Найти механиков, которые выполнили 2 и более заказов в один день. Выдать их фамилии и инициалы.
Ответ: 8 механиков, один из которых Слепцов П.Н.*/

SELECT mc.sname_initials
FROM mechanic mc
JOIN maintenance ma ON ma.id_mech = mc.id_mech
JOIN maintenance ma2 ON ma2.id_mech = mc.id_mech
WHERE DATE(ma.date_work) = DATE(ma2.date_work)
AND ma.n$diag_chart != ma2.n$diag_chart
GROUP BY mc.sname_initials;