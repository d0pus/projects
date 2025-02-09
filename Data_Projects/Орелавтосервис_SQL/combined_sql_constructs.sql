/*69.	 Найти автомобили, выпущенные в Евросоюзе. Выдать государственные номер-ные знаки, государственную принадлежность и наименование завода-изготовителя, его фактический адрес и телефон.
Ответ: 44 автомобиля из ФРГ и Франции.*/

SELECT v.gnz,
st.name,
f.factory_name,
f.legal_addr,
f.phone
FROM vehicle v
JOIN state st ON st.st_id = v.st_id
JOIN factory f ON f.idf = v.idf
WHERE st.euro_union = '1';

/*70.	 Найти автомобили, которые проходили на предприятии только предпродажную подготовку. Указать их государственные номерные знаки, дату предпродажной под-готовки, фамилию и инициалы механика, проводившего работы.
Ответ: 86 автомобилей, один из которых "e346kx57".*/

SELECT gnz AS "ГНЗ",
TO_CHAR (date_work, 'DD.MM.YYYY') AS "Дата предпродажной подготовки", sname_initials AS "Инициалы"
	FROM maintenance
JOIN mechanic ON maintenance.id_mech = mechanic.id_mech
JOIN maintenancetype ON maintenance.mt_id = maintenancetype.mt_id
	WHERE maintenancetype.name = 'Предпродажная подготовка';

/*71.	 Определить автомобильный бренд, на который клиенты предприятия, вместе по-тратили больше всех денег (найти «автомобиль богатых»).
Ответ: Mercedes-Benz.*/

SELECT brand.name
FROM vehicle
JOIN brand ON vehicle.idb = brand.idb
GROUP BY brand.name
ORDER BY SUM(cost) DESC
LIMIT 1;

/*72.	 Определить, сколько автобусов обслужено механиком Кротовым К.О.
Ответ: 4 автобуса.*/

SELECT mc.sname_initials, COUNT(ma.gnz)
FROM maintenance ma
JOIN mechanic mc ON mc.id_mech = ma.id_mech
JOIN transpgroup tg ON tg.id_tg = ma.id_tg
WHERE tg.name = 'Автобусы' 
AND mc.sname_initials = 'Кротов К.О.'
GROUP BY mc.sname_initials;

/*73.	 Найти автомобили, которые были приобретены не новыми (интервал между да-той выдачи свидетельства о регистрации транспортного средства и датой начала эксплуатации больше двух недель). Выдать государственные номерные знаки, про-изводителя, марку, модель, серию, номер и дату выдачи свидетельства о регистра-ции транспортного средства, дату начала эксплуатации. Все данные, кроме даты начала эксплуатации организовать одним столбцом по формату: <Государственный номерной знак><Производитель><Марка><Модель>, Свидетельство о регистрации <Серия СРТС> № <Номер СРТС> выдано: <Дата выдачи СРТС>.
Ответ: 44 автомобиля.*/

SELECT 
	CONCAT(
		gnz, ' ', 
		COALESCE(brand.name, ''), ' ', 
		COALESCE(marka.name, ''), ' ', 
		COALESCE(model.model_name, ''), 
		' Свидетельство о регистрации: ', 
		ser$reg_certif, '№', 
		num$reg_certif, 
		' выдано: ', 
		date$reg_certif
	) AS "<Государственный номерной знак><Производитель><Марка><Модель>, Сви-детельство о регистрации <Серия СРТС> № <Номер СРТС> выдано: <Дата выда-чи СРТС>.",
	date_use
FROM vehicle 
	JOIN brand USING(idb)
	JOIN marka USING(idm)
	JOIN model USING(idmo)
WHERE ABS(DATE_PART('day', AGE(date$reg_certif, date_use))) > 14;

/*74.	 Сформировать список заводов по производству автомобилей, размещенных на территории Российской Федерации, и, в зависимости от того, входит ли страна бренда в Европейский союз или нет, указать наименование бренда, предприятия, почтовый или фактический адрес соответственно (для стран Евросоюза указывать почтовый адрес), телефон.
Ответ: 7 строк, 4 столбца.*/

SELECT b.name,
f.factory_name,
CASE WHEN st.euro_union = '1'
	THEN f.post_addr
	ELSE f.legal_addr
END as "addr",
f.phone
FROM factory f
JOIN brand b ON b.idb = f.idb
JOIN state st ON st.st_id = f.st_id
WHERE f.legal_addr LIKE '%Россия%';

/*75.	 Найти производителей, автомобили которых в 2018 году реже остальных требо-вали ремонта. Выдать названия брендов и количество ремонтов их автомобилей.
Ответ: "Peugeot" – 2 ремонта.*/

SELECT b.name AS "Марка",
COUNT(ma.gnz) AS "Кол-во ремонтов"
FROM maintenance ma 
JOIN brand b ON b.idb = ma.idb 
JOIN maintenancetype mt ON mt.mt_id = ma.mt_id
WHERE date_part('year', ma.date_work) = '2018' AND mt.name = 'Ремонт'
GROUP BY b.name
ORDER BY COUNT(ma.gnz) LIMIT 1;

/*76.	 Найти механиков, которые выполнили больше работ, чем Голубев Д.Н. В выда-чу включить фамилии и инициалы этих людей.
Ответ: семь механиков, один из которых – Лосев П.Л.*/

SELECT sname_initials
FROM maintenance
JOIN mechanic ON maintenance.id_mech = mechanic.id_mech
GROUP BY sname_initials
HAVING COUNT(tech_cond_resume) > (
   SELECT COUNT(tech_cond_resume)
   FROM maintenance
   JOIN mechanic ON maintenance.id_mech = mechanic.id_mech
   WHERE sname_initials = 'Голубев Д.Н.'
);

/*77.	 Найти автомобили, зарегистрированные в один и тот же день. Выдать государ-ственные номерные знаки, в одном столбце через пробел производителя, марку и модель каждого из них, дату регистрации.
Ответ: 24 строки, 3 столбца.*/

SELECT 
 v1.gnz,
 CONCAT(
   b.name, ' ',
   mk.name, ' ',
   mo.model_name
 ),
 v1.date$reg_certif
FROM vehicle v1
JOIN brand b ON b.idb = v1.idb
JOIN marka mk ON mk.idm = v1.idm
JOIN model mo ON mo.idmo = v1.idmo
JOIN vehicle v2 ON v2.date$reg_certif = v1.date$reg_certif
AND v2.gnz != v1.gnz;

/*78.	 Для каждого автомобиля указать число посещения им предприятия (учитывать, что могут быть автомобили, которые ни разу не обслуживались, в этом случае вы-водить значение 0). Вывести государственные номерные знаки, серии, номера и даты их свидетельств о регистрации транспортного средства и количество посещений. Выдачу отсортировать по количеству посещений.
Ответ: 161 строка, 5 столбцов.*/

SELECT  v.gnz AS "ГНЗ",
v.ser$reg_certif AS "Серия свидетельства о регистрации",
v.num$reg_certif  AS "Номер свидетельства о регистрации",
v.date$reg_certif AS "Дата свидетельства о регистрации",
COUNT(mt.date_work) AS "Кол-во посещений"
FROM maintenance mt
RIGHT JOIN vehicle v ON mt.gnz = v.gnz
GROUP BY 1,2,3,4
ORDER BY "Кол-во посещений" DESC;

/*79.	 Найти автомобили, которые в 2016, 2017 и 2018 годах совершили 80% и более посещений предприятия от всего объема их обслуживания за все время. Вывести их государственные номерные знаки. 
Ответ: 22 автомобиля, один из которых – "y777yy57".*/

SELECT m.gnz 
FROM maintenance m 
GROUP BY m.gnz 
HAVING (COUNT(m.date_work)*0.8) <= COUNT(CASE 
          WHEN TO_CHAR(m.date_work, 'YYYY') ='2016' 
          OR TO_CHAR(m.date_work, 'YYYY') ='2017' 
          OR TO_CHAR(m.date_work, 'YYYY') ='2018' 
          THEN m.date_work 
          END);

/*80.	 Найти механиков, получивших сертификат на работу после достижения ими пен-сионного возраста. Учесть, что до 2018 года возраст выхода на пенсию для мужчин составлял 60, а для женщин – 55 лет, а с 2018 года эти показатели увеличены на 5 лет и действуют относительно тех, кому настал срок выхода на пенсию. Прогрессив-ную шкалу роста пенсионного возраста не учитывать. Выдать фамилии, инициалы и даты рождения механиков, даты получения ими сертификатов и приема на работу.
Ответ: два человека (Савостьянова Н.М. и Бекетов А.С.).*/

SELECT m.sname_initials AS "Фамилия и инициалы",
    m.born AS "Дата рождения",
    m.certif_date AS "Дата получения сертификата",
    m.work_in_date AS "Дата приема на работу"
FROM
    mechanic m
WHERE EXTRACT(YEAR FROM AGE(m.certif_date, m.born)) >=
        CASE
        WHEN EXTRACT(YEAR FROM m.certif_date) < 2018 THEN 60
        ELSE 55
        END;

/*81.	 Сформировать отчет о выполненных ремонтах автомобилей за все время работы предприятия. В отчете отобразить: государственный номерной знак; в одном столб-це через запятую наименование производителя, марку и модель; также в одном столбце указать через пробел серию, номер и дату выдачи свидетельства о реги-страции транспортного средства; дату проведения ремонта; фамилию и инициалы механика, выполнившего ремонт; техническое заключение по ремонту. Все даты приводить в формате "dd.mm.yyyy".
Ответ: 997 строк, 6 столбцов.*/

SELECT 
    m.gnz, 
    CONCAT_WS(', ', b.name, ma.name, mo.model_name) AS car_info,  
    CONCAT_WS(' ', v.ser_reg_certif, v.num_reg_certif, TO_CHAR(v.date_reg_certif, 'DD.MM.YYYY')) AS registration_info,
    TO_CHAR(m.date_work, 'DD.MM.YYYY') AS repair_date, 
    me.sname_initials AS mechanic, 
    m.tech_cond_resume AS repair_summary
FROM maintenance m
LEFT JOIN brand b ON m.idb = b.idb 
LEFT JOIN marka ma ON m.idm = ma.idm 
LEFT JOIN model mo ON m.idmo = mo.idmo 
LEFT JOIN vehicle v ON m.gnz = v.gnz 
LEFT JOIN mechanic me ON m.id_mech = me.id_mech;

/*82.	 Определить долю в процентах (с точностью до двух значащих цифр мантиссы) в общем результате предприятия механика Савостьянова А.В. Считать, что все рабо-ты (заказы на ремонт или обслуживание) являются одинаково весомыми в общих итогах работы предприятия. 
Ответ:  6,44%.*/

SELECT
   ROUND(COUNT(CASE WHEN mc.sname_initials = 'Савостьянов А.В.' THEN 1 END) 
   / COUNT(*)::NUMERIC * 100.0, 2) 
FROM maintenance ma
JOIN mechanic mc ON mc.id_mech = ma.id_mech
JOIN factory f ON f.idf = ma.idf
WHERE f.factory_name IN (
        SELECT factory_name
        FROM factory
        WHERE idf IN (
            SELECT idf
            FROM mechanic
            WHERE sname_initials = 'Савостьянов А.В.'
        )
    );

/*83.	 Сформировать список инвестиционно не выгодных автомобилей. К таковым от-носятся автомобили с пробегом не менее 100 000 км, или имеющие возраст 3 и более года, или побывавшие в ремонте хотя бы один раз, а также автомобили из транс-портных групп "Специальные автомобили", "Специализированные автомобили", "Спортивные автомобили" или "Спортивные мотоциклы". В список включить столб-цы: "Государственный номерной знак", "Возраст", "Пробег" и "Дата последнего ре-монта". Если автомобиль в ремонте не был, то в последнем столбце должен хранить-ся пробел. 
Ответ: 131 строка, 4 столбца.*/

SELECT
    v.gnz AS "ГНЗ",
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM v.date_made) AS "Возраст",
    v.run AS "Пробег",
    COALESCE(TO_CHAR(MAX(ma.date_work), 'DD.MM.YYYY'), '') AS "Дата по-следнего ремонта"
FROM vehicle v
LEFT JOIN maintenance ma ON v.gnz = ma.gnz
LEFT JOIN transpgroup tg ON v.id_tg = tg.id_tg
JOIN maintenancetype mt ON mt.mt_id = ma.mt_id
WHERE v.run >= 100000
    OR (22 - EXTRACT(YEAR FROM v.date_made)) >= 3
    OR (ma.gnz IS NOT NULL AND mt.name = 'Ремонт')
    OR tg.name IN ('Специальные автомобили', 'Специализированные автомобили', 'Спортивные автомобили', 'Спортивные мотоциклы')
GROUP BY v.gnz, v.date_made, v.run
ORDER BY "Возраст" DESC, "Пробег" DESC;

/*84.	 Определить проводилось ли не регламентное техническое обслуживание автомо-билей японского производства. Не регламентным считается любое техническое об-служивание, не предусмотренное для автомобилей, выпущенных японскими произ-водителями. В выдаче указать государственные номерные знаки, производителя, марку, модель автомобиля, вид, дату и заключение по проведенному не регламент-ному ТО, фамилию и инициалы механика, выполнявшего работы.
Ответ: 10 строк, 8 столбцов, два автомобиля с государственными номерными зна-ками "a450ox57" и "k161op57".*/

SELECT 
    v.gnz AS "Государственный номерной знак",
    b.name AS "Производитель",
    ma.name AS "Марка",
    mo.model_name AS "Модель",
    mt.name AS "Вид ТО",
    TO_CHAR(m.date_work, 'DD.MM.YYYY') AS "Дата ТО",
    m.tech_cond_resume AS "Заключение по ТО",
    mech.sname_initials AS "Механик"
FROM vehicle v
JOIN model mo ON v.idmo = mo.idmo 
JOIN marka ma ON mo.idm = ma.idm 
JOIN brand b ON ma.idb = b.idb
JOIN maintenance m ON v.gnz = m.gnz
JOIN maintenancetype mt ON m.mt_id = mt.mt_id
JOIN mechanic mech ON m.id_mech = mech.id_mech
JOIN state st ON st.st_id = v.st_id
WHERE st.name = 'Япония' AND mt.name LIKE '%ТО__' 
ORDER BY v.gnz, m.date_work;