/*31.	 Сформировать список производителей автомобилей и принадлежащих им заво-дов, отсортированный по столбцу "Производитель" по алфавиту. Столбец с назва-ниями заводов именовать как "Завод".
Ответ: 22 строки,  2 столбца.*/

SELECT brand.name AS "Производитель",
factory_name AS "Завод"
FROM brand
JOIN factory ON factory.idb = brand.idb
ORDER BY brand.name;

/*32.	 Составить список автомобилей с указанием их государственного номерного зна-ка (таблица vehicle), производителя (таблица brand), наименования марки (таблица marka) и модели (таблица model). Выдачу сформировать в виде двух столбцов – "Государственный номерной знак" и "Автомобиль". Во втором столбце должны быть через запятую указаны производитель, марка и модель. Учесть, что при конка-тенации строк если одно из выражений возвращает NULL, то и вся строка примет значение NULL (использовать функцию COALESCE).
Ответ: 161 строка, 2 столбца.*/

SELECT 
 v.gnz AS "Государственный номерной знак",
 CONCAT(COALESCE(b.name, ''), ', ', COALESCE(m.name, ''), ', ', COALESCE(mo.model_name, '')) AS "Автомобиль"
FROM vehicle v
JOIN brand b ON v.idb = b.idb
JOIN model mo ON v.idmo = mo.idmo
JOIN marka m ON mo.idm = m.idm;

/*33.	 Создать список контактных телефонов производителей (телефоны заводов), по которым могут обратиться владельцы автомобилей. Указать государственный но-мерной знак автомобиля, наименование производителя и контактный телефон заво-да, на котором произведен автомобиль. 
Ответ: 161 строка, 3 столбца.*/

SELECT 
 v.gnz AS "Государственный номерной знак",
 b.name AS "Производитель",
 f.phone AS "Телефон завода"
FROM vehicle v
JOIN brand b ON v.idb = b.idb
JOIN factory f ON v.idf = f.idf;

/*34.	 Составить список механиков, обслуживавших автомобиль с государственным номерным знаком " c112op57". В выдачу включить дату проведения работ в форма-те "dd.mm.yyyy" и фамилию и инициалы механика. Результат отсортировать в хро-нологическом порядке.
Ответ: 7 строк, 2 столбца.*/

SELECT TO_CHAR(maintenance.date_work, 'DD.MM.YYYY'),
mechanic.sname_initials
FROM mechanic
JOIN maintenance ON maintenance.id_mech = mechanic.id_mech
WHERE maintenance.gnz = 'c112op57'
ORDER BY maintenance.date_work;

/*35.	 Найти автомобили производства Японии. Указать производителя, марку, мо-дель, разделенные пробелами в одном столбце, и государственный номерной знак. Учесть, что ряд автомобилей в атрибуте marka имеют значение NULL.
Ответ: 22 строки, 2 столбца.*/

SELECT 
 CONCAT(COALESCE(b.name, ''), ' ', COALESCE(m.name, ''), ' ', COALESCE(mo.model_name, '')) AS "Автомобиль",
 v.gnz AS "Государственный номерной знак"
FROM vehicle v
JOIN brand b ON v.idb = b.idb
JOIN model mo ON v.idmo = mo.idmo
JOIN marka m ON mo.idm = m.idm
JOIN state s ON v.st_id = s.st_id
WHERE s.name = 'Япония';

/*36.	 Сформировать список автомобилей, сменивших владельца (самосоединение таб-лицы vehicle со своей копией, совпадают даты изготовления, производители, марки, модели; различаются государственные номерные знаки, серии, номера и даты выда-чи свидетельств о регистрации транспортных средств). В выдачу включить столбец "Дата изготовления", указать установленный ранее государственный номерной знак, серию, номер и дату (в формате "dd.mm.yyyy") выдачи свидетельства о регистрации транспортного средства в одном столбце, разделив пробелами. Такие же данные должны быть приведены по новому государственному регистрационному знаку и свидетельству о регистрации транспортного средства (всего в результирующей вы-борке должно быть 5 столбцов).
Ответ: один автомобиль (изготовлен 12 июля 2018 года).*/

SELECT TO_CHAR(v1.date_made, 'DD.MM.YYYY') AS "Дата изготовления",
       v1.gnz,
       CONCAT(' ', v1.ser$reg_certif, ' ', v1.num$reg_certif, ' ', TO_CHAR(v1.date$reg_certif, 'DD.MM.YYYY')) AS "Старый",
 	   v2.gnz,
       CONCAT(' ', v2.ser$reg_certif, ' ', v2.num$reg_certif, ' ', TO_CHAR(v2.date$reg_certif, 'DD.MM.YYYY')) AS "Новый"
FROM vehicle AS v1
         JOIN vehicle AS v2 ON v1.date_made = v2.date_made AND v1.idb = v2.idb AND v1.idm = v2.idm
    AND v1.idmo = v2.idmo AND v1.gnz != v2.gnz AND v1.date$reg_certif < v2.date$reg_certif
    AND CONCAT(' ', v1.ser$reg_certif, v1.num$reg_certif, TO_CHAR(v1.date$reg_certif, 'DD.MM.YYYY')) !=
        CONCAT(' ', v2.ser$reg_certif, v2.num$reg_certif, TO_CHAR(v2.date$reg_certif, 'DD.MM.YYYY'));

/*37.	 Выдать список механиков (фамилии и инициалы), государственные номерные знаки обслуженных или отремонтированных ими автомобилей и даты выполнения работ с учетом возможности отсутствия выполненных заказов некоторыми механи-ками (использовать левое внешнее соединение, left outer join). 
Ответ: 639 строк, 3 столбца. Заказы не выполняли Калатошкин М.П. и Лискунов М.В.*/

SELECT mechanic.sname_initials,
maintenance.gnz,
maintenance.date_work
FROM mechanic
LEFT JOIN maintenance ON maintenance.id_mech = mechanic.id_mech;

/*38.	 Сформировать список технических заключений по ремонтам автомобилей BMW. В выдачу включить наименование производителя, наименование завода, дату про-ведения ремонта без указания времени, формулировку технического заключения. Список технических заключений отсортировать по дате оформления.
Ответ: 11 строк, 4 столбца.*/

SELECT 
 brand.name AS "Наименование производителя",
 factory.factory_name AS "Наименование завода",
 TO_CHAR(maintenance.date_work, 'DD.MM.YYYY') AS "Дата проведения ремонта",
 maintenance.tech_cond_resume AS "Техническое заключение"
FROM maintenance
JOIN brand ON maintenance.idb = brand.idb
JOIN factory ON maintenance.idf = factory.idf
JOIN maintenancetype ON maintenance.mt_id = maintenancetype.mt_id
WHERE brand.name = 'BMW'
AND maintenancetype.name = 'Ремонт'
ORDER BY maintenance.date_work;

/*39.	 Найти автомобильные предприятия, расположенные на той же улице, что и "ОАО АВТОВАЗ". Выдать наименование, почтовый и фактический адрес, контакт-ный телефон. Использовать самосоединение.
Ответ: Опытный завод специальных автомобилей ОАО АВТОВАЗ.*/

SELECT f1.factory_name,
f1.post_addr,
f1.legal_addr,
f1.phone
FROM factory f1
JOIN factory f2 ON f1.legal_addr = f2.legal_addr
WHERE f1.factory_name LIKE '%ОАО АВТОВАЗ%'
ORDER BY f1.factory_name DESC
LIMIT 1;

/*40.	 Найти автомобили, которые обслуживал тот же механик, что и автомобиль с гос-ударственным номерным знаком "o929ao57". Выдать государственные номерные знаки обслуженных автомобилей, даты выполнения работ и в отдельном столбце время выполнения работ в 24-часовом формате без указания секунд.
Ответ: 40 строк, 3 столбца.*/

SELECT 
 ma.gnz, 
 CAST(ma.date_work AS DATE) AS "Date of work",
 TO_CHAR(ma.date_work, 'HH24:MI')
FROM maintenance me
JOIN maintenance ma ON ma.id_mech = me.id_mech 
   AND me.gnz = 'o929ao57'

/*41.	 Сформировать список автомобилей, свидетельство о регистрации транспортного средства которых имеет ту же серию, что и документ автомобиля с государственным номерным знаком "c172ac57". В выдачу включить только автомобили того же про-изводителя, что и автомобиль с государственным номерным знаком "c172ac57", указать их государственный номерной знак, наименование производителя, дату вво-да в эксплуатацию (date_use).
Ответ: 3 строки, 3 столбца. В выдаче не должно быть строки с данными об авто-мобиле с государственным номерным знаком "c172ac57".*/

SELECT v2.gnz, b.name, v2.date_use
FROM vehicle AS v1,
     vehicle AS v2,
     brand AS b
WHERE v1.gnz = 'c172ac57'
  AND v1.ser$reg_certif = v2.ser$reg_certif
  AND v1.idb = b.idb
  AND v2.idb = b.idb
  AND v1.gnz != v2.gnz;

/*42.	 Составить бригады из трех механиков при условии, что они все одногодки. В выдачу включить фамилии и инициалы механиков, год их рождения.
Ответ: 1 бригада 1994 года рождения.*/

SELECT sname_initials,
TO_CHAR(born, 'yyyy')
FROM mechanic 
WHERE date_part('year', born) = (SELECT date_part('year', born) 
FROM mechanic
GROUP BY date_part('year', born) HAVING COUNT(sname_initials) = 3);